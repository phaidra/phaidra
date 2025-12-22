
=head1 NAME

  Util::Filesystems

=head1 DESCRIPTION

Wrapper for Linux::Proc::Filesystems and possibly other modules to obtain
a full picture about available filesystems

Wanted information
* mount point info (Sys::Filesystem)
* free space
* LVM

=cut

use strict;

package Util::Filesystems;

use Data::Dumper;
$Data::Dumper::Indent= 1;

my $initialzed= 0;

my $have_LPM= 0;

BEGIN {
  eval {
    require Linux::Proc::Mounts;
  };

  if ($@)
  {
    # print "consider to install Linux::Proc::Mounts\n";
  }
  else
  {
    $have_LPM= 1;
  }
}

my %setable= map { $_ => 1 } qw();

my %ignore_fs_type= map { $_ => 1 } qw(none rootfs tmpfs proc devpts
  devtmpfs usbfs sysfs binfmt_misc fusectl debugfs securityfs pstore
  cgroup autofs hugetlbfs mqueue tracefs overlayfs fuse.gvfsd-fuse fuseblk
  fuse.sshfs cifs squashfs nsfs
);

my %ignore_fs_path= map { $_ => 1 } qw(tmpfs);
# print "ignore_fs_type: ", Dumper (\%ignore_fs_type);

__PACKAGE__->main() unless caller();

sub main
{

  # print join (' ', __FILE__, __LINE__, 'main: caller=['. caller(). ']'), "\n";

  my $fs= new Util::Filesystems;
  $fs->_init();
  # print __LINE__, ' fs: ', Dumper($fs);
  print "regular filesystems: ", join(' ', $fs->regular_filesystems()), "\n";
}

sub new
{
  my $class= shift;

  my $self=
  {
    '_init' => 0,
    'fs' => {},
  };
  bless $self, $class;
  $self->set (@_);

  $self;
}

sub set
{
  my $self= shift;
  my %par= @_;

  my $do_init= 0;
  foreach my $p (keys %par)
  {
    if (exists ($setable{$p})) { $self->{$p}= $par{$p}; }
    elsif ($p eq 'init' && $par{$p}) { $do_init= 1; }
    else { warn("unknown option p=[$p]"); }
  }

  $self->_init(0) if ($do_init);
}

sub _init
{
  my $self= shift;
  my $keep_mp_obj;

  my $m;
  if ($have_LPM)
  {
    $m= Linux::Proc::Mounts->read;
    # print "m: ", Dumper ($m);
  }

  my %fs;    $self->{'fs'}=     \%fs;
  my %dev;   $self->{'device'}= \%dev;
  my %c_fst; $self->{'c_fst'}=  \%c_fst;
  my $count= 0;

  if (defined ($m))
  {
    FS: foreach my $mp (@$m)
    {
      my ($fs_spec, $fs_type)= ($mp->spec(), $mp->fstype());
      # print "fs_spec=[$fs_spec] fs_type=[$fs_type] mp: ", Dumper ($mp);

      if (exists($ignore_fs_type{$fs_type}))
      {
        # print __LINE__, " ignoring [$fs_type] ", Dumper ($mp);
        next FS;
      }
      else
      {
        my ($fs_file, $opts)= ($mp->file(), $mp->opts_hash());
        # print __LINE__, " XXX: fs_file=[$fs_file] fs_spec=[$fs_spec] fs_type=$fs_type\n";
        my $x= $fs{$fs_file}=
        $dev{$fs_spec}= 
        {
          'mp'   => $fs_file,
          'spec' => $fs_spec,
          'type' => $fs_type,
          'opts' => $opts,
        };
        $x->{'_mp'}= $mp if ($keep_mp_obj);
        # $dev{$fs_spec}= $fs_file;
        $c_fst{$fs_type}++;
        $count++;
      }
    }
  }
  else
  {
    if (open (PM, '/proc/mounts'))
    {
      # print "reading /proc/mounts\n";
      FS2: while (<PM>)
      {
        chop;
        # print ">>> [$_]\n";
        my ($fs_spec, $fs_file, $fs_type, $fs_opts, $l1, $l2)= split (' ', $_, 6);

        if (exists($ignore_fs_type{$fs_type})
            || $fs_type =~ m#fuse\..*\.AppImage$#      # NOTE: is this pattern defined somewhere?
           )
        {
          # print __LINE__, " ignoring [$fs_type] [$_]\n";
          next FS2;
        }
        elsif ($fs_file =~ m#^/var/lib/schroot/#)
        {
          # print __LINE__, " ignoring schroot [$_]\n";
          next FS2;
        }
        else
        {
          # print __LINE__, " using [$fs_type] [$_]\n";
          my @opts= split (',', $fs_opts);
          # print "opts: [", join (';', @opts), "]\n";
          my %opts;
          foreach my $opt (@opts)
          {
            # print "opt=[$opt]\n";
            my ($an, $av)= split ('=', $opt, 2);
            $av= 1 unless (defined ($av));
            $opts{$an}= $av;
          }
          # print "opts: ", Dumper (\%opts);

          my $x= $fs{$fs_file}=
          $dev{$fs_spec}= 
          {
            'mp'   => $fs_file,
            'spec' => $fs_spec,
            'type' => $fs_type,
            'opts' => \%opts,
          };
          $c_fst{$fs_type}++;
          $count++;
        }
      }
      close (PM);
    }
  }

  $self->{'_init'}= 1;
  $self->{'_count'}= $count;

  $count;
}

sub regular_filesystems
{
  my $self= shift;

  $self->_init(0) unless ($self->{_init});

  my @regular_filesystems= sort keys %{$self->{fs}};

  (wantarray) ? @regular_filesystems : \@regular_filesystems;
}

sub df
{
  my $self= shift;
  my $mode= shift;

  my @cmd= ('/bin/df');

  $mode= 'k' unless ($mode =~ /^[ihkm]$/);
  push (@cmd, '-'.$mode);

  # print "running [", join (' ', @cmd), "]\n";
  my $now= time ();
  open (DF, '-|', @cmd) or die "can't df";
  my @headings;
  my $c= 0;
  my @lines= ();
  DF: while (<DF>)
  {
    chop;
    # print __LINE__, " df: [$_]\n";
    if ($c++ == 0)
    {
      @headings= split (' ', $_, 6);
      next DF;
    }

    if ($_ =~ /^ /) { $lines[$#lines] .= $_; }
    else { push (@lines, $_); }
  }

  # print "headings: ", Dumper (\@headings);
  # print "lines: ", Dumper (\@lines);

  foreach my $l (@lines)
  {
    my ($dev, $total, $used, $avail, $pct, $mp)= split (' ', $l, 6);
    my $x= $self->{'device'}->{$dev};
    $x->{$mode}=
    { 
      'e' => $now,
      'total' => $total,
      'used' => $used,
      'avail' => $avail,
      'pct' => $pct,
    };
  }

}

1;

__END__


=head1 OPTIONAL MODULES

=head2 Linux::Proc::Mounts

