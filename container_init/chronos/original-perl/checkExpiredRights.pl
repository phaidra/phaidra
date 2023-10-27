#!/usr/bin/env perl

use strict;
use warnings;
use YAML::Syck;
use Data::Dumper;
use Log::Log4perl;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(decode_json encode_json);

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $logconf = q(
  log4perl.category.MyLogger         = DEBUG, Logfile, Screen

  log4perl.appender.Logfile                          = Log::Dispatch::FileRotate
  log4perl.appender.Logfile.Threshold                = DEBUG
  log4perl.appender.Logfile.filename                 = /var/log/phaidra/checkExpiredRights.log
  log4perl.appender.Logfile.max                      = 30
  log4perl.appender.Logfile.DatePattern              = yyyy-MM-dd
  log4perl.appender.Logfile.SetDate                  = CET
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

sub updateRights {
  my ($ua, $urlapi, $pid, $now) = @_;

  my $apires = $ua->get("$urlapi/object/$pid/rights")->result;
  if ($apires->code != 200) {
    if (exists($apires->json->{alerts})) {
      for my $a (@{$apires->json->{alerts}}) {
        $log->error("pid[$pid] get rights result code[".$apires->code."]:".$a->{msg});
        return 0;
      }
    }
  }

  $log->debug(Dumper($apires->json->{metadata}));

  unless ($apires->json->{metadata}) {
    $log->error("pid[$pid] invalid response");
    return 0;
  }
  unless ($apires->json->{metadata}->{rights}) {
    $log->error("pid[$pid] invalid response");
    return 0;
  }

  my $rights = $apires->json->{metadata}->{rights};

  my $found = 0;
  for my $type (keys %{$rights}) {
    my @newRules;
    for my $rule (@{$rights->{$type}}) {
      if (ref $rule eq ref {}) {
        if (exists($rule->{expires})) {
          if ($rule->{expires} lt $now) {
            $found = 1;
            $log->info("pid[$pid] expires[$rule->{expires}] lt [$now], removing rule type[$type] value[$rule->{value}]");
          } else {
            push @newRules, $rule;
          }
        } else {
          push @newRules, $rule;
        }
      } else {
        push @newRules, $rule;
      }
    }
    if (scalar @newRules > 0) {
      $rights->{$type} = \@newRules;
    } else {
      delete $rights->{$type};
    }
  }
  if ($found) {
    $apires = $ua->post("$urlapi/object/$pid/rights" => form => { metadata => encode_json({ metadata => { rights => $rights } }) })->result;
    if ($apires->code != 200) {
      if (exists($apires->json->{alerts})) {
        for my $a (@{$apires->json->{alerts}}) {
          $log->error("pid[$pid] save rights result code[".$apires->code."]:".$a->{msg});
          return 0;
        }
      }
    }
  } else {
    $log->error("pid[$pid] found no rules to remove!");
    return 0;
  }

  return 1;
}

my @d = localtime(time);
my $now = sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", $d[5]+1900, $d[4]+1, $d[3], $d[2], $d[1], $d[0]);

$log->info("started now[$now]");

my $config;
eval { $config = YAML::Syck::LoadFile('/etc/phaidra.yml'); };
if($@)
{
  $log->error("ERR: $@\n");
  exit(1);
}

my $ua = Mojo::UserAgent->new;

my $urlapi = "https://".$config->{fedoraadminuser}.":".$config->{fedoraadminpass}."\@".$config->{phaidraapi}->{baseurl}."/".$config->{phaidraapi}->{basepath};

my $urlsolr = Mojo::URL->new;
$urlsolr->scheme($config->{solr}->{scheme});
$urlsolr->host($config->{solr}->{host});
$urlsolr->port($config->{solr}->{port});
if($config->{solr}->{path}){
  $urlsolr->path("/".$config->{solr}->{path}."/solr/".$config->{solr}->{core}."/select");
}else{
  $urlsolr->path("/solr/".$config->{solr}->{core}."/select");
}
$urlsolr->query(q => "*:*", fq => "checkafter:[* TO $now]", fl => "pid", rows => "1", wt => "json");
my $solrres = $ua->get($urlsolr)->result;
unless ($solrres->is_success) {
  $log->error("error querying solr: ".$solrres->code." ".$solrres->message);
  exit(1);
}
my $total = $solrres->json->{response}->{numFound};

$log->info("found $total objects");

if ($total < 1) {
  $log->info("nothing to do");
  exit(0);
}

$urlsolr->query(q => "*:*", fq => "checkafter:[* TO $now]", fl => "pid,owner", rows => $total, wt => "json");
$solrres = $ua->get($urlsolr)->result;
unless ($solrres->is_success) {
  $log->error("error querying solr: ".$solrres->code." ".$solrres->message);
  exit(1);
}

my $docs = $solrres->json->{response}->{docs};

my $checkedpids;
my $modified = 0;

for my $d (@{$docs}){
  my $pid = $d->{pid};
  if ($checkedpids->{$pid}) {
    $log->error("object [$pid] was already processed!");
    exit(1);
  }
  $checkedpids->{$pid} = 1;
  $log->info("pid[$pid] owner[$d->{owner}] processing");
  if (updateRights($ua, $urlapi, $pid, $now)) {
    $modified++;
  } else {
    $log->error("pid[$pid] error processing");
    exit(1);
  }
}

my @checked = keys %{$checkedpids};
my $nrChecked = scalar @checked;
$log->info("done, found = $total, checked = $nrChecked, modified = $modified");

__END__


