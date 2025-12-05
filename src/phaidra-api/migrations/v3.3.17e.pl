#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use DBIx::Connector;

# Usage: docker exec -it phaidra-api-1 perl migrations/VERSION.pl

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

$log->info("started migration to v3.3.17");

my $cntr = DBIx::Connector->new("dbi:mysql:phaidradb:".$ENV{MARIADB_PHAIDRA_HOST}, $ENV{MARIADB_PHAIDRA_USER}, $ENV{MARIADB_PHAIDRA_PASSWORD}, {mysql_auto_reconnect => 1, mysql_multi_statements => 1});
$cntr->mode('ping');

$cntr->dbh->do("CREATE INDEX `idx_ip_created` ON `usage_stats` (`ip`,`created`);");
$cntr->dbh->do("CREATE INDEX `idx_location_created` ON `usage_stats` (`location_country`,`created`);");

$log->info("finished migration to v3.3.17");

__END__


