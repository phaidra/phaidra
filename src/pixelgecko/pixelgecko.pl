use strict;

use Data::Dumper;
$Data::Dumper::Indent= 1;
use lib qw(/opt/pixelgecko/perl_modules);
use PAF::JobQueue;
use PAF::Activity;
use YAML::Syck;
use FileHandle;
use File::Fetch;
use Net::Amazon::S3;
use Net::Amazon::S3::Vendor::Generic;
use Net::Amazon::S3::Authorization::Basic;

autoflush STDOUT 1;
autoflush STDERR 1;

my $fnm_config= './pixelgecko_conf.yml';
# my $config= YAML::Syck::LoadFile($fnm_config);

my $config = {
  'pixelgecko' => {
    'mongodb' => {
      'host' => $ENV{MONGODB_HOST},
      'db_name' => 'admin',
      'database' => 'paf_mongodb',
      'username' => $ENV{MONGODB_PHAIDRA_USER},
      'password' => $ENV{MONGODB_PHAIDRA_PASSWORD},
      'col' => 'jobs',
      'activity' => 'activity'
    },
    'store' => $ENV{CONVERTED_IMAGES_PATH},
    'temp_path' => '/tmp',
    'sleep_time' => $ENV{IMAGE_CONVERSION_INTERVAL},
  },
  's3' => {
    'use_s3' => $ENV{S3_ENABLED},
    'aws_access_key_id' => $ENV{S3_ACCESS_KEY},
    'aws_secret_access_key' => $ENV{S3_SECRET_KEY},
    's3_endpoint' => $ENV{S3_ENDPOINT},
    'bucketname' => $ENV{S3_BUCKETNAME}
  },
  'fedora' => {
    'admin_user' => $ENV{FEDORA_ADMIN_USER},
    'admin_pass' => $ENV{FEDORA_ADMIN_PASS},
    'host' => $ENV{FEDORA_HOST},
    'protocol' => $ENV{FEDORA_PROTOCOL},
    'port' => $ENV{FEDORA_PORT}
  },
};


my $op_mode;

my $agent_name= 'pige';

my @JOBS;
while (defined (my $arg= shift (@ARGV))) {
  if ($arg eq '--') {
    push (@JOBS, @ARGV); @ARGV= ();
  } elsif ($arg =~ /^--(.+)/) {
    my ($opt, $val)= split ('=', $1, 2);

    if ($opt eq 'direct') {
      $op_mode= 'direct';
    } elsif ($opt eq 'watch') {
      $op_mode= 'watch';
    } elsif ($opt eq 'config') {
      $fnm_config= $val||shift (@ARGV);
    } else {
      usage ("unknown option '$arg'");
    }
  } elsif ($arg =~ /^-(.+)/) {
    usage ("unknown option '$arg'");
  } else {
    push (@JOBS, $arg);
  }
}

if ($op_mode eq 'direct') {
  while (my $pid= shift (@JOBS)) {
    my $rc= process_image ($pid);
  }
  exit (0);
} elsif ($op_mode eq 'watch') {
} else {
  usage("unknown op_mode '$op_mode'");
  exit(0);
}

my $jq= new PAF::JobQueue( mongodb => $config->{pixelgecko}->{mongodb} );
my $mdb= $jq->get_database();
my $activity;

if (exists ($config->{pixelgecko}->{mongodb}->{activity})) {
  $activity= new PAF::Activity ($mdb, $config->{pixelgecko}->{mongodb}->{activity}, $agent_name);
}

process_job_queue($jq, $activity);

exit (0);

sub usage
  {
    my $msg= shift;
    if ($msg) {
      print scalar localtime(), " ", $msg, "\n";
      sleep (3);
    }
    system ('/usr/bin/perldoc', $0);
    exit(0);
  }

sub process_job_queue
  {
    my $jq= shift;
    my $activity= shift;

    # print __LINE__, " activity: ", Dumper ($activity);
    my %activity_record=
      (
       agent   => $agent_name,
       status  => 'starting',
       procid  => $$,
       e       => 0,
      );

  JOB: while (1)
      {
        my $job= $jq->get_job ( $agent_name );

        unless (defined ($job))
          {
            my $db = exists($config->{pixelgecko}->{mongodb}->{database}) ?
              $config->{pixelgecko}->{mongodb}->{database} :
              $config->{pixelgecko}->{mongodb}->{db_name};

            if ($activity_record{e} + 600 < time () || $activity_record{status} ne 'idle') {
              $activity_record{status}= 'idle';
              $activity_record{e}=    time();
              if (exists ($activity_record{pid})) {
                delete ($activity_record{pid});
                delete ($activity_record{idhash});
              }

              $activity->save (%activity_record) if (defined ($activity));
            }

            sleep($config->{pixelgecko}->{sleep_time});
            next JOB;
          }
        print scalar localtime(), " ", "job: ", Dumper ($job);

        $activity_record{status}=   'process_image';
        $activity_record{pid}=    $job->{pid};
        $activity_record{idhash}= $job->{idhash};
        $activity_record{e}=      time();
        $activity->save (%activity_record) if (defined ($activity));

        my $rc= process_image ($job->{pid}, $job->{idhash}, $job->{ds}, $job->{cmodel}, $job->{path});

        if (!defined ($rc)) {
          $job->{'status'}= 'failed';
        } else {
          $job->{'status'}= 'finished';
          foreach my $an (keys %$rc) {
            $job->{$an}= $rc->{$an};
          }
          if ( $config->{s3}->{use_s3}  eq "true" ) {
            my $s3 = Net::Amazon::S3-> new(
              authorization_context => Net::Amazon::S3::Authorization::Basic-> new (
                aws_access_key_id => $config->{s3}->{aws_access_key_id},
                aws_secret_access_key => $config->{s3}->{aws_secret_access_key},
               ),
              retry => 1,
              vendor => Net::Amazon::S3::Vendor::Generic->new(
                host => $config->{s3}->{s3_endpoint} =~ s/^https?:\/\///r,
                use_virtual_host => 0,
                use_https => !($config->{s3}->{s3_endpoint} =~ qr/^http:\/\/.*/),
                default_region => "eu-central-1",
              ),
             );
            my $bucket = $s3->bucket($config->{s3}->{bucketname});
            $bucket->add_key_filename( $rc->{'image'}, $rc->{'image'},
                                       { content_type => 'image/tiff', },
                                      ) or die $s3->err . ": " . $s3->errstr;
            $job->{'s3_bucket'}=$config->{s3}->{bucketname};
            unlink $rc->{'image'};
          }
        }

        $jq->update_job ($job);

        # sleep(5);
      }
  }


sub process_image
  {
    my $pid= shift;
    my $idhash= shift;
    my $ds= shift;
    my $cmodel = shift;
    my $path = shift;

    my $tmp_dir= $config->{pixelgecko}->{temp_path};
    # directory for downloaded files
    my $dl_tmp_dir;
    system ('mkdir', '-p', $tmp_dir) unless (-d $tmp_dir);

    my $img_fnm= $pid;
    $img_fnm = $img_fnm."_$ds" if defined $ds;
    $img_fnm=~ s#:#_#g;
    my $tmp_img= join ('/', $tmp_dir, $img_fnm);

    my $out_img;
    if (defined($idhash) && $idhash =~ /\b([a-f0-9]{40})\b/) {
      my $lvl1= substr($idhash, 0, 1);
      my $lvl2= substr($idhash, 1, 1);
      my $out_dir= join ('/', $config->{pixelgecko}->{store}, $lvl1, $lvl2);
      system ('mkdir', '-p', $out_dir) unless (-d $out_dir);
      $out_img= join ('/', $out_dir, $idhash.'.tif');
    } else {
      print scalar localtime(), " ", "idhash[$idhash] is not defined or is not a SHA-1 hash\n";
      $out_img= join ('/', $config->{pixelgecko}->{store}, $img_fnm.'.tif');
    }

    my @curl_lines;
    my $original_img;

    if (defined $path && -f $path)
      { $original_img = $path;
        `cp $path $tmp_img`;
        $original_img = $tmp_img;
        print scalar localtime(), " path: ", "$original_img\n";
      }
    else
      {
        my $url =
          $config->{fedora}->{protocol}."://".
          $config->{fedora}->{admin_user}.":".
          $config->{fedora}->{admin_pass}."@".
          $config->{fedora}->{host}.":".
          $config->{fedora}->{port}.
          "/fcrepo/rest/$pid/OCTETS"
          ;

        my $ff = File::Fetch->new(uri => $url);
        my $pid_for_path = $pid =~ s/:/_/r;
        $dl_tmp_dir = "$tmp_dir/$pid_for_path";
        $tmp_img = $ff->fetch( to => $dl_tmp_dir);
        $original_img = $tmp_img;

        unless (-f $tmp_img)
          {
            print scalar localtime(), " ", "ATTN: could not retrieve [$url] and save to [$tmp_img]\n";
            return undef;
          }

        print scalar localtime(), " retrieved: ", "$tmp_img\n";
      }


    # my @tmp_st= stat($tmp_img);
    # TODO: check ....

    my @tr_lines;
    my @cast_lines;
    my @vips_lines;

    ############################################################
    # if... PDF files, else... everything else                 #
    ############################################################
    if ($cmodel && ($cmodel eq 'PDFDocument')) {
      # get the first page with white background
      my $cast_img = $tmp_img.'.jpg';
      my @cast= (qw(/usr/bin/vips copy), $original_img, $cast_img . '[background=255]'); # https://github.com/libvips/libvips/issues/379#issuecomment-181773897
      my $cast= join (' ', @cast);
      print scalar localtime(), " ", "copy: [$cast]\n";
      my $cast_txt= `@cast 2>&1`;
      print scalar localtime(), " ", "copy_txt=[$cast_txt]\n";
      @cast_lines= x_lines ($cast_txt);

      unless (-f $cast_img)
        {
          print scalar localtime(), " ", "ATTN: could not save [$cast_img] using copy=[$cast]\n";
          return undef;
        }


      my @vips= (qw(/usr/bin/vips im_vips2tiff --vips-progress --vips-concurrency=4), $cast_img,
                 $out_img.':jpeg:85,tile:256x256,pyramid');
      my $vips= join (' ', @vips);
      print scalar localtime(), " ", "vips: [$vips]\n";
      my $vips_txt= `@vips 2>&1`;
      print scalar localtime(), " ", "vips_txt=[$vips_txt]\n";
      @vips_lines= x_lines ($vips_txt);

      unless (-f $out_img)
        {
          print scalar localtime(), " ", "ATTN: could not save [$out_img] using vips=[$vips]\n";
          return undef;
        }
      my @out_st= stat(_);
      # TODO: check ....

      unlink ($cast_img);
      unlink ($tmp_img) if (-f $tmp_img);
      rmdir ($dl_tmp_dir) if (defined ($dl_tmp_dir) && -d $dl_tmp_dir);
    } else {

      my $tr_img = $tmp_img;
      my $test_icc= `identify -quiet -format "%r" "$tr_img"`;
      $test_icc =~ s/^\s+|\s+$//g;
      print scalar localtime(), " ", "Color profile [$test_icc]\n";
      if ($test_icc eq "DirectClass sRGB") {
        # transform color profile
        $tr_img = $tmp_img.'.v';
        my @tr= (qw(/usr/bin/vips icc_transform --input-profile=sRGB.icm --embedded=true), $tmp_img, $tr_img, 'sRGB.icm');
        my $tr= join (' ', @tr);
        print scalar localtime(), " ", "tr: [$tr]\n";
        my $tr_txt= `@tr 2>&1`;
        print scalar localtime(), " ", "tr_txt=[$tr_txt]\n";
        @tr_lines= x_lines ($tr_txt);
        unless (-f $tr_img)
          {
            print scalar localtime(), " ", "ATTN: could not save [$tr_img] using tr=[$tr]\n";
            return undef;
          }
      }

      # we have to cast 16bit to 8bit when using jpeg compression
      my $cast_img = $tr_img.'.v'; # vips format, see https://github.com/jcupitt/libvips/issues/8#issuecomment-12292039
      my @cast= (qw(/usr/bin/vips im_msb), $tr_img, $cast_img);
      my $cast= join (' ', @cast);
      print scalar localtime(), " ", "cast: [$cast]\n";
      my $cast_txt= `@cast 2>&1`;
      print scalar localtime(), " ", "cast_txt=[$cast_txt]\n";
      @cast_lines= x_lines ($cast_txt);

      unless (-f $cast_img)
        {
          print scalar localtime(), " ", "ATTN: could not save [$cast_img] using cast=[$cast]\n";
          return undef;
        }


      my @vips= (qw(/usr/bin/vips im_vips2tiff --vips-progress --vips-concurrency=4),
                 $cast_img, $out_img.':jpeg:85,tile:256x256,pyramid');
      my $vips= join (' ', @vips);
      print scalar localtime(), " ", "vips: [$vips]\n";
      my $vips_txt= `@vips 2>&1`;
      print scalar localtime(), " ", "vips_txt=[$vips_txt]\n";
      @vips_lines= x_lines ($vips_txt);

      unless (-f $out_img)
        {
          print scalar localtime(), " ", "ATTN: could not save [$out_img] using vips=[$vips]\n";
          return undef;
        }
      my @out_st= stat(_);
      # TODO: check ....

      unlink ($tr_img);
      unlink ($cast_img);
      unlink ($tmp_img) if (-f $tmp_img);
      rmdir ($dl_tmp_dir) if (defined ($dl_tmp_dir) && -d $dl_tmp_dir);
    }

    my $result = { 'conversion' => 'ok', 'image' => $out_img,
              vips_lines => \@vips_lines, cast_lines => \@cast_lines, tr_lines => \@tr_lines };
    $result->{curl_lines} = \@curl_lines if (@curl_lines);

    return $result;
  }

sub x_lines
  {
    my $s= shift;

    my @l= split (/\n/, $s);
    my @l2= ();
    while (my $l= shift (@l)) {
      $l=~ s#.*\r##g;
      $l=~ s# *$##;
      push (@l2, $l);
    }

    (wantarray) ? @l2 : \@l2;
  }
