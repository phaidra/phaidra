#!/usr/bin/env perl

use strict;
use warnings;
use YAML::Syck;
use Data::Dumper;
use Log::Log4perl;
use File::Find qw(finddepth);
use Fcntl ':mode';
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(decode_json encode_json);

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $logconf = q(
  log4perl.category.MyLogger         = INFO, Logfile, Screen

  log4perl.appender.Logfile                          = Log::Dispatch::FileRotate
  log4perl.appender.Logfile.Threshold                = DEBUG
  log4perl.appender.Logfile.filename                 = /var/log/phaidra/indexObjects.log
  log4perl.appender.Logfile.max                      = 30
  log4perl.appender.Logfile.DatePattern              = yyyy-MM-dd
  log4perl.appender.Logfile.TZ                       = CET
  log4perl.appender.Logfile.layout                   = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Logfile.layout.ConversionPattern = [%d] [%p] [%P] %m%n
  log4perl.appender.Logfile.mode                     = append
  log4perl.appender.Logfile.binmode                  = :encoding(UTF-8)
  log4perl.appender.Logfile.utf8                     = 1

  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init( \$logconf );
my $log = Log::Log4perl::get_logger("MyLogger");

my $config;
eval { $config = YAML::Syck::LoadFile('/etc/phaidra.yml'); };
if($@)
{
  $log->error("ERR: $@\n");
  exit(1);
}

sub indexObject {
  my ($ua, $urlapi, $pid) = @_;

  $log->debug("indexing $pid");
  my $apires = $ua->post("$urlapi/object/$pid/index")->result;
  if ($apires->code != 200) {
    if (exists($apires->json->{alerts})) {
      for my $a (@{$apires->json->{alerts}}) {
        $log->error("pid[$pid] index result code[".$apires->code."]:".$a->{msg});
        return 0;
      }
    }
  }
  return 1;
}

sub isIndexed {
  my ($ua, $urlsolr, $pid) = @_;

  $log->debug("checking $pid");
  $urlsolr->query(q => "*:*", fq => "pid:\"$pid\"", fl => "owner", rows => 1, wt => "json");
  my $solrres = $ua->get($urlsolr)->result;
  unless ($solrres->is_success) {
    $log->error("error querying solr: ".$solrres->code." ".$solrres->message);
    exit(1);
  }
  for my $d (@{$solrres->json->{response}->{docs}}){
    $log->debug("owner of $pid: ".$d->{owner});
    if($d->{owner}) {
      return 1;
    }
  }
  return 0;
}

sub getInfo {
  my ($file) = @_;

  my $pidNamespace = $config->{fedora}->{pidNamespace};
  my $pid = '';
  my $state = '';
  my $cmodel = '';
  open my $fh, "<", $file  or $log->error("Can't open $file: $!");
  while (my $line = <$fh>)
  {
    if ($line =~ /foxml:digitalObject VERSION="1.1" PID="($pidNamespace:\d+)/g) {
      $pid = $1;
    }
    if ($line =~ /foxml:property NAME="info:fedora\/fedora-system:def\/model\#state" VALUE="(\w+)"/g) {
      $state = $1;
    }
    if ($line =~ /<hasModel xmlns="info:fedora\/fedora-system:def\/model\#" rdf:resource="info:fedora\/cmodel:(\w+)"/g) {
      $cmodel = $1;
    }
  }
  return ($pid, $state, $cmodel);
}

my $failed = 0;
my $ok = 0;
my $urlapi;
my $urlapinocred;

my $usage = 'Usage: ./indexObjects folder [localapiport]';
my $folder = shift (@ARGV);
unless ($folder) {
  $log->error("Error: Missing folder arg.");
  $log->info($usage);
  exit(1);
}

my $localapiport = shift (@ARGV);
if ($localapiport) {
  $urlapi = "http://$config->{fedoraadminuser}:$config->{fedoraadminpass}\@localhost:$localapiport";
  $urlapinocred = "http://localhost:$localapiport";
} else {
  $urlapi = "https://$config->{fedoraadminuser}:$config->{fedoraadminpass}\@$config->{phaidraapi}->{baseurl}/$config->{phaidraapi}->{basepath}";
  $urlapinocred = "https://$config->{phaidraapi}->{baseurl}/$config->{phaidraapi}->{basepath}";
}

$log->info("started folder[$folder] urlapinocred[$urlapinocred]");

my $ua = Mojo::UserAgent->new;

my $urlsolr = Mojo::URL->new;
$urlsolr->scheme($config->{solr}->{scheme});
$urlsolr->host($config->{solr}->{host});
$urlsolr->port($config->{solr}->{port});
if($config->{solr}->{path}){
  $urlsolr->path("/".$config->{solr}->{path}."/solr/".$config->{solr}->{core}."/select");
}else{
  $urlsolr->path("/solr/".$config->{solr}->{core}."/select");
}

$log->info("solr[$urlsolr]");

finddepth(sub {
  return if($_ eq '.' || $_ eq '..');
  my $file = $File::Find::name;

  my $mode = (stat($file))[2];
  my $is_directory = S_ISDIR($mode);
  return if $is_directory;

  my ($pid, $state, $cmodel) = getInfo($file);
  if ($state ne 'Active') {
    $log->error("ok[$ok] failed[$failed] file[$file] pid[$pid] state[$state] cmodel[$cmodel] - skipping");
    return;
  } else {
    if ($cmodel eq 'Page') {
      $log->error("ok[$ok] failed[$failed] file[$file] pid[$pid] state[$state] cmodel[$cmodel] - skipping");
      return;
    } else {
      if ($pid) {
        indexObject($ua, $urlapi, $pid);
        if (isIndexed($ua, $urlsolr, $pid)) {
          $ok++;
          $log->info("ok[$ok] failed[$failed] file[$file] pid[$pid] state[$state] cmodel[$cmodel] - ok");
        } else {
          $failed++;
          $log->info("ok[$ok] failed[$failed] file[$file] pid[$pid] state[$state] cmodel[$cmodel] - failed");
        }
      } else {
        $log->error("ok[$ok] failed[$failed] file[$file] no pid - skipping");
      }
    }
  }

}, $folder);

$log->info("ok[$ok] failed[$failed] done");

__END__


