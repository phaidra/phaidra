#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);

# Usage: docker exec -it phaidra-api-1 perl /usr/local/phaidra/phaidra-api/utils/indexBook.pl\

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $logconf = q(
  log4perl.category.MyLogger         = INFO, Screen

  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init(\$logconf);
my $log = Log::Log4perl::get_logger("MyLogger");

my $bookpid = shift(@ARGV);

unless ($bookpid) {
  $log->error("missing PID param");
  return 0;
}

my $ua = Mojo::UserAgent->new;

my $api = Mojo::URL->new;
$api->scheme('http');
$api->host($ENV{PHAIDRA_API_HOST});
$api->port(3000);
$api->userinfo($ENV{PHAIDRA_ADMIN_USER} . ':' . $ENV{PHAIDRA_ADMIN_PASSWORD});

sub indexObject {
  my ($pid) = @_;

  my $url    = $api->clone->path("/object/$pid/index");
  my $apires = $ua->post($url)->result;
  if ($apires->code != 200) {
    if (exists($apires->json->{alerts})) {
      for my $a (@{$apires->json->{alerts}}) {
        $log->error("pid[$pid] index result code[" . $apires->code . "]:" . $a->{msg});
        return 0;
      }
    }
  }
  return 1;
}

sub getPages {
  my ($bookpid) = @_;

  my $url    = $api->clone->path("/object/$bookpid/relationships");
  my $apires = $ua->get($url)->result;

  if ($apires->code != 200) {
    if (exists($apires->json->{alerts})) {
      for my $a (@{$apires->json->{alerts}}) {
        $log->error("pid[$bookpid] index result code[" . $apires->code . "]:" . $a->{msg});
        return 0;
      }
    }
  }

  my $members = $apires->json->{relationships}->{hasmember} || [];
  $members = [$members] unless ref($members) eq 'ARRAY';

  my @pagepids = map {s{^info:fedora/}{}r} @{$members};
  return [sort {(substr($a, 2)) <=> (substr($b, 2))} @pagepids];
}

$log->info("get pages of $bookpid");

my $pages = getPages($bookpid);

my $i   = 0;
my $cnt = scalar @{$pages};
for my $pagepid (@{$pages}) {
  $i++;
  $log->info("[$i/$cnt] indexing page " . $pagepid);
  unless (indexObject($pagepid)) {
    $log->info("error indexing page " . $pagepid);
    die();
  }
  sleep(1);
}

$log->info("indexing book " . $bookpid);
unless (indexObject($bookpid)) {
  $log->info("error indexing book " . $bookpid);
  die();
}

$log->info("done");

__END__
