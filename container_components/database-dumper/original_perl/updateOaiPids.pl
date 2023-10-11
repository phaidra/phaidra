#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);
use YAML::Syck;
use Data::Dumper;
use Log::Log4perl;
use Switch;
use MongoDB;

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $inserted = 0;
my $removed = 0;
my $updated = 0;
my $created = 0;
my $deleted = 0;
my $purged = 0;

my $logconf = q(
  log4perl.category.MyLogger         = DEBUG, Logfile, Screen
 
  log4perl.appender.Logfile          = Log::Log4perl::Appender::File
  log4perl.appender.Logfile.filename = /var/log/phaidra/updateOaiPid.log
  log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Logfile.layout.ConversionPattern=%d %m%n
  log4perl.appender.Logfile.utf8    = 1
 
  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init( \$logconf );
my $log = Log::Log4perl::get_logger("MyLogger");

sub _getRecordUpdate {
  my ($ua, $urlsolr, $urlapi, $pid, $doc) = @_;
  
  my $recUpdate;
  if ($doc) {
    $recUpdate = $doc;

    if (exists($doc->{ispartof})) {
      my @newIspartof;
      for my $colpid (@{$doc->{ispartof}}) {
        my $coldoc = getSolrDoc($ua, $urlsolr, $colpid);
        if ($coldoc) {
          my $ucolpid = $colpid =~ s/:/_/r;
          # this is used in primo set
          $recUpdate->{"title_of_$ucolpid"} = $coldoc->{sort_dc_title};
          push @newIspartof, $colpid;
        } else {
          $log->error("pid[$pid] could not get collection[$colpid] doc to get col title");
          # if we can't get col title, it's probably inactive -> remove from ispartof
        }
      }
      $doc->{ispartof} = \@newIspartof;
    }
  } else {
    $log->info("doc pid[$pid] not found in solr, checking phaidra-api");
    my $apires = $ua->get($urlapi."/object/".$pid."/state?foxml=1")->result;
    if ($apires->code == 404) {
      if (exists($apires->json->{alerts})) {
        for my $a (@{$apires->json->{alerts}}) {
          if ($a->{msg} eq 'Not Found') {
            $log->info("pid[$pid] get state result code[".$apires->code."], fedora msg eq 'Not Found', object seems purged, flagging as deleted");
            $recUpdate->{deleted} = 1;
            $deleted++;
          }
        }
      }
    } else {
      if ($apires->code == 301) {
        if (exists($apires->json->{state})) {
          if ($apires->json->{state} eq 'Deleted') {
            $log->info("pid[$pid] get state result code[".$apires->code."] and state eq 'Deleted', flagging as deleted");
            $recUpdate->{deleted} = 1;
            $deleted++;
          }
        }
      }
    }
    unless ($recUpdate->{deleted}) {
      if (exists($apires->json->{alerts})) {
        $log->info("pid[$pid] NOT flagging as deleted, get state result code[".$apires->code."] alerts:\n".Dumper($apires->json->{alerts}));
      } else {
        $log->info("pid[$pid] NOT flagging as deleted, get state result code[".$apires->code."]");
      }
    }
  }

  $recUpdate->{update} = 0;
  $recUpdate->{updated} = time * 1000;

  return $recUpdate;
}

sub getSolrDoc {
  my ($ua, $urlsolr, $pid) = @_;

  my $doc;
  $urlsolr->query(q => "pid:\"$pid\"", rows => "1", wt => "json");
  my $solrres = $ua->get($urlsolr)->result;
  if ($solrres->is_success) {
    for my $d (@{$solrres->json->{response}->{docs}}){
      $doc = $d;
      last;
    }
  }else{
    $log->error("error getting doc pid[$pid] from solr: ".$solrres->code." ".$solrres->message);
    return;
  }

  return $doc;
}

sub getRecordUpdate {
  my ($ua, $urlsolr, $urlapi, $pid) = @_;

  my $doc = getSolrDoc($ua, $urlsolr, $pid);
  return unless $doc;

  return _getRecordUpdate($ua, $urlsolr, $urlapi, $pid, $doc);
}

sub updateRecord {
  my ($pid, $purge, $ua, $urlapi, $urlsolr, $recordsColl) = @_;

  if ($purge) {
    my $mdbres = $recordsColl->delete_one({ pid => $pid });
    $log->debug("delete result pid[$pid] matched[".$mdbres->deleted_count."]");
    $purged++;
  } else {
    my $q = "pid:\"$pid\"";
    $urlsolr->query(q => $q, rows => 1, wt => "json");
    my $solrres = $ua->get($urlsolr)->result;
    if ($solrres->is_success) {
      for my $d (@{$solrres->json->{response}->{docs}}){
        my $docpid = $d->{pid};
        my $recUpdate = _getRecordUpdate($ua, $urlsolr, $urlapi, $docpid, $d);
        if ($recUpdate) {
          my $mdbres = $recordsColl->update_one({ pid => $docpid }, { '$set' => $recUpdate }, { upsert => 1 });
          $log->debug("update result pid[$docpid] matched[".$mdbres->matched_count."]");
          if ($mdbres->matched_count) {
            $updated++;
          } else {
            $inserted++;
          }
        }
      }
    }else{
      $log->error("error getting solr doc for query q[$q]: ".$solrres->code." ".$solrres->message);
      return undef;
    }
  }

  return 1;
}

my $config;
eval { $config = YAML::Syck::LoadFile('/etc/phaidra.yml'); };
if($@)
{
  $log->error("Error: $@\n");
  exit(1);
}

my $usage = 'Usage: ./updateOaiPids [--purge=1 | --purge=0] pid [pid ...]';
my $purge = 0;
my $purgeArg = shift (@ARGV);
switch ($purgeArg) {
  case '--purge=1' {
    $purge = 1;
  }
  case '--purge=0' {
    $purge = 0;
  }
  else {
    $log->error("Error: Missing purge argument.");
    $log->info($usage);
    exit(1);
  }
}

my $pids = \@ARGV;
if (scalar @$pids < 1) {
  $log->error("Error: Missing pids.");
  $log->info($usage);
  exit(1);
}
my $pidNamespace = $config->{fedora}->{pidNamespace};
for my $pid (@$pids) {
  unless ($pid =~ m/^$pidNamespace:(\d)+$/) {
    $log->error("Error: Wrong pid format: pid[$pid]");
    exit(1);
  }
}

$log->info("started purge[$purge]");

my $mdbcfg;
my $mdbclient;
my $mdb;
my $setColl;
my $recordsColl;
unless(exists($config->{phaidraapi}->{mongodb})) {
  $log->error("$0: phaidra-api mongodb config missing");
  exit(1);
}
$mdbcfg = $config->{phaidraapi}->{mongodb};
my %connection_pars = map { $_ => $mdbcfg->{$_} } qw(host port username password);
eval { $mdbclient= new MongoDB::MongoClient (%connection_pars); };
### eval { $mdbclient = new MongoDB::Connection(%connection_pars); };
if ($@) {
  $log->error('MongoDB connection failed: '.$@);
  exit(1);
}
unless (defined ($mdbclient)) {
  $log->error('connection not established');
  exit(1);
}
eval { $mdb = $mdbclient->get_database($mdbcfg->{database}); };
if ($@) {
  $log->error('MongoDB get_database failed: '.$@);
  exit(1);
}
unless (defined ($mdb)) {
  $log->error('MongoDB db not available');
  exit(1);
}
eval { $setColl = $mdb->get_collection('oai_sets'); };
if ($@) {
  $log->error('MongoDB get_collection oai_sets failed: '.$@);
  exit(1);
}
unless (defined ($setColl)) {
  $log->error('MongoDB collection oai_sets not available');
  exit(1);
}
my @sets;
my $setsCursor = $setColl->find();
while (my $s = $setsCursor->next) {
  push @sets, $s;
}
eval { $recordsColl = $mdb->get_collection('oai_records'); };
if ($@) {
  $log->error('MongoDB get_collection oai_records failed: '.$@);
  exit(1);
}
unless (defined ($recordsColl)) {
  $log->error('MongoDB collection oai_records not available');
  exit(1);
}

my $ua = Mojo::UserAgent->new;

my $urlapi = "https://".$config->{phaidraapi}->{baseurl}."/".$config->{phaidraapi}->{basepath};

my $urlsolr = Mojo::URL->new;
$urlsolr->scheme($config->{solr}->{scheme});
$urlsolr->host($config->{solr}->{host});
$urlsolr->port($config->{solr}->{port});
if($config->{solr}->{path}){
  $urlsolr->path("/".$config->{solr}->{path}."/solr/".$config->{solr}->{core}."/select");
}else{
  $urlsolr->path("/solr/".$config->{solr}->{core}."/select");
}

$urlsolr->query(q => "*:*", rows => "1", wt => "json");
my $solrres = $ua->get($urlsolr)->result;
unless ($solrres->is_success) {
  $log->error("error querying solr: ".$solrres->code." ".$solrres->message);
  exit(1);
}

for my $pid (@$pids) {
  $log->debug("updating pid[$pid]");
  updateRecord($pid, $purge, $ua, $urlapi, $urlsolr, $recordsColl);
}

$log->info("done updated[$updated] inserted[$inserted] deleted[$deleted] purged[$purged]");

__END__

