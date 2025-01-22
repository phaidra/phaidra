#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);

# Usage: docker exec -it phaidra-api-1 perl /usr/local/phaidra/phaidra-api/utils/indexObjects.pl from-date-iso until-date-iso
#
# iso format ~ 2008-01-01T00:00:00Z

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $logconf = q(
  log4perl.category.MyLogger         = INFO, Screen

  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init( \$logconf );
my $log = Log::Log4perl::get_logger("MyLogger");

my $ua = Mojo::UserAgent->new;

my $from = _epochToIso(0);
my $until = _epochToIso(time + 86400);
my $fromParam = shift (@ARGV);
my $untilParam = shift (@ARGV);
$from = $fromParam if $fromParam;
$until = $untilParam if $untilParam;
# this is the maximum in fcrepo simple search
my $pagesize = 100;
my $page = 0;
my $failed = 0;
my $ok = 0;

my $apibaseurl_with_creds = 'http://'.$ENV{PHAIDRA_ADMIN_USER}.":".$ENV{PHAIDRA_ADMIN_PASSWORD}.'@'.$ENV{PHAIDRA_API_HOST}.':3000';
my $fedorabaseurl = 'http://'.$ENV{FEDORA_HOST}.':8080/fcrepo/rest';
my $fedoraadmin_credentials = $ENV{FEDORA_ADMIN_USER}.":".$ENV{FEDORA_ADMIN_PASS};
my $fedorasearchurl = Mojo::URL->new("$fedorabaseurl/fcr:search");
$fedorasearchurl->userinfo($fedoraadmin_credentials);
$fedorasearchurl->query(
  fields => 'fedora_id,created',
  order_by => 'created',
  order => 'asc',
  condition => 'fedora_id=o:*',
  max_results => $pagesize
);
if ($from) {
  $fedorasearchurl->query([ condition => "created>$from" ]);
}
if ($until) {
  $fedorasearchurl->query([ condition => "created<$until" ]);
}
$fedorasearchurl->query([ condition => "rdf_type=http://fedora.info/definitions/v4/repository#ArchivalGroup" ]);

sub indexObject {
  my ($pid) = @_;

  my $apires = $ua->post("$apibaseurl_with_creds/object/$pid/index")->result;
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

sub _epochToIso {
  my ($epoch) = @_;
  my $sec = $epoch;
  my ($s, $m, $h, $D, $M, $Y) = gmtime($sec);
  $M++;
  $Y += 1900;
  return sprintf("%4d-%02d-%02dT%02d:%02d:%02dZ", $Y, $M, $D, $h, $m, $s);
}

sub processPage {
  my ($page) = @_;

  $fedorasearchurl->query({ offset => $page * $pagesize });
  my $fedres = $ua->get($fedorasearchurl)->result;
  unless ($fedres->is_success) {
    $log->error("error querying fedora: ".$fedres->code." ".$fedres->message);
    exit(1);
  }

  for my $item (@{$fedres->json->{items}}) {
    my $id = $item->{fedora_id};
    next unless $id =~ m/$fedorabaseurl\/(o\:\d+)$/;
    my $pid = $1;
    if (indexObject($pid)) {
      $ok++;
      $log->info("ok[$ok] failed[$failed] pid[$pid] created[".$item->{created}."] - ok");
    } else {
      $failed++;
      $log->info("ok[$ok] failed[$failed] pid[$pid] created[".$item->{created}."] - failed");
    }
  }

  # Dump($fedres->json->{items});

  return scalar @{$fedres->json->{items}};
}


$log->info("started from[$from] until[$until]");

while (processPage($page) == $pagesize) {
  $page++;
}

$log->info("ok[$ok] failed[$failed] done");
$log->info("=== If you are migrating a PHAIDRA instanz, update the 'pidGen' table in 'phaidra' mariadb to the current highest PID ===");

__END__


