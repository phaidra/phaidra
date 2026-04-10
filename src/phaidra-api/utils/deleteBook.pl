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

Log::Log4perl::init(\$logconf);
my $log = Log::Log4perl::get_logger("MyLogger");

my $bookpid = shift(@ARGV);

unless ($bookpid) {
  $log->error("missing PID param");
  return 0;
}

my $ua = Mojo::UserAgent->new;

# this is the maximum in fcrepo simple search
my $pagesize = 100;
my $page     = 0;
my $failed   = 0;
my $ok       = 0;

my $api = Mojo::URL->new;
$api->scheme('http');
$api->host($ENV{PHAIDRA_API_HOST});
$api->port(3000);
$api->userinfo($ENV{PHAIDRA_ADMIN_USER} . ':' . $ENV{PHAIDRA_ADMIN_PASSWORD});

sub deleteObject {
  my ($pid) = @_;

  my $url    = $api->clone->path("/object/$pid/delete");
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

  my $params = {
    core => 'phaidra_pages',
    q    => '*:*',
    fq   => 'ispartof:"' . $bookpid . '"'
  };

  my $url = $api->clone->path('search/select')->query($params);

  my $apires = $ua->post($url)->result;

  if ($apires->code != 200) {
    if (exists($apires->json->{alerts})) {
      for my $a (@{$apires->json->{alerts}}) {
        $log->error("pid[$bookpid] index result code[" . $apires->code . "]:" . $a->{msg});
        return 0;
      }
    }
  }

  return $apires->json->{response}->{docs};
}

$log->info("get pages of $bookpid");

my $pages = getPages($bookpid);

my $i   = 0;
my $cnt = scalar @{$pages};
for my $pagedoc (@{$pages}) {
  $i++;
  $log->info("[$i/$cnt] deleting page " . $pagedoc->{pid});
  unless (deleteObject($pagedoc->{pid})) {
    $log->info("error deleting page " . $pagedoc->{pid});
    die();
  }
  sleep(1);
}

$log->info("deleting book " . $bookpid);
unless (deleteObject($bookpid)) {
  $log->info("error deleting book " . $bookpid);
  die();
}

$log->info("done");

__END__


