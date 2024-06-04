#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(decode_json encode_json);

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $logconf = q(
  log4perl.category.MyLogger         = DEBUG, Screen
  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init( \$logconf );

my $log = Log::Log4perl::get_logger("MyLogger");
my @d = localtime(time);
my $now = sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", $d[5]+1900, $d[4]+1, $d[3], $d[2], $d[1], $d[0]);
$log->info("checkExpiredRights: started now[$now]");

my $ua = Mojo::UserAgent->new;
my $admin_credentials = $ENV{PHAIDRA_ADMIN_USER}.":".$ENV{PHAIDRA_ADMIN_PASSWORD};
my $api_url = "http://api:3000";

sub updateRights {
  my ($ua, $api_url, $pid, $now) = @_;
  my $urlapi = Mojo::URL->new("$api_url/object/$pid/rights")->userinfo($admin_credentials);
  my $apires = $ua->get($urlapi)->result;
  if ($apires->code != 200) {
    if (defined($apires->json->{alerts})) {
      for my $a (@{$apires->json->{alerts}}) {
        $log->error("checkExpiredRights: pid[$pid] get rights result code[".$apires->code."]:".$a->{msg});
        return 0;
      }
    }
  }

  $log->debug(Dumper($apires->json->{metadata}));

  unless ($apires->json->{metadata}) {
    $log->error("checkExpiredRights: pid[$pid] invalid response");
    return 0;
  }
  unless ($apires->json->{metadata}->{rights}) {
    $log->error("checkExpiredRights: pid[$pid] invalid response");
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
            $log->info("checkExpiredRights: pid[$pid] expires[$rule->{expires}] lt [$now], removing rule type[$type] value[$rule->{value}]");
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
    $apires = $ua->post($urlapi => form => { metadata => encode_json({ metadata => { rights => $rights } }) })->result;
    if ($apires->code != 200) {
      if (exists($apires->json->{alerts})) {
        for my $a (@{$apires->json->{alerts}}) {
          $log->error("checkExpiredRights: pid[$pid] save rights result code[".$apires->code."]:".$a->{msg});
          return 0;
        }
      }
    }
  } else {
    $log->error("checkExpiredRights: pid[$pid] found no rules to remove!");
    return 0;
  }

  return 1;
}

my $urlsolr = Mojo::URL->new;
$urlsolr->scheme("http");
$urlsolr->host($ENV{SOLR_HOST});
$urlsolr->port(8983);
$urlsolr->path("/solr/phaidra/select");

$urlsolr->query(q => "*:*", fq => "checkafter:[* TO $now]", fl => "pid", rows => "1", wt => "json");
my $solrres = $ua->get($urlsolr)->result;
unless ($solrres->is_success) {
  $log->error("checkExpiredRights: error querying solr: ".$solrres->code." ".$solrres->message);
  exit(1);
}
my $total = $solrres->json->{response}->{numFound};

$log->info("checkExpiredRights: found $total objects");

if ($total < 1) {
  $log->info("checkExpiredRights: nothing to do");
  exit(0);
}

$urlsolr->query(q => "*:*", fq => "checkafter:[* TO $now]", fl => "pid,owner", rows => $total, wt => "json");
$solrres = $ua->get($urlsolr)->result;
unless ($solrres->is_success) {
  $log->error("checkExpiredRights: error querying solr: ".$solrres->code." ".$solrres->message);
  exit(1);
}

my $docs = $solrres->json->{response}->{docs};

my $checkedpids;
my $modified = 0;

for my $d (@{$docs}){
  my $pid = $d->{pid};
  if ($checkedpids->{$pid}) {
    $log->error("checkExpiredRights: object [$pid] was already processed!");
    exit(1);
  }
  $checkedpids->{$pid} = 1;
  $log->info("checkExpiredRights: pid[$pid] owner[$d->{owner}] processing");
  if (updateRights($ua, $api_url, $pid, $now)) {
    $modified++;
  } else {
    $log->error("checkExpiredRights: pid[$pid] error processing");
    exit(1);
  }
}

my @checked = keys %{$checkedpids};
my $nrChecked = scalar @checked;
$log->info("checkExpiredRights: done, found = $total, checked = $nrChecked, modified = $modified");

__END__


