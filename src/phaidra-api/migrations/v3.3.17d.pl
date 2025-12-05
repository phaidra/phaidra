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

$cntr->dbh->do("

-- institutional repository tables
  CREATE TABLE `alert` (
    `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` varchar(64) NOT NULL,
    `alert_type` varchar(8) NOT NULL,
    `pids` varchar(64) DEFAULT NULL,
    `gmtimestamp` varchar(50) DEFAULT NULL,
    `processed` int(4) DEFAULT NULL,
  CONSTRAINT `PRIMARY` PRIMARY KEY (`id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  CREATE TABLE `event` (
    `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `event_type` varchar(50) DEFAULT NULL,
    `pid` varchar(250) DEFAULT NULL,
    `user_id` varchar(16) DEFAULT NULL,
    `gmtimestamp` varchar(50) DEFAULT NULL,
  CONSTRAINT `PRIMARY` PRIMARY KEY (`id`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;

  CREATE TABLE `requested_license` (
    `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `pid` varchar(250) DEFAULT NULL,
    `license` varchar(250) DEFAULT NULL,
    `user_id` varchar(16) DEFAULT NULL,
    `gmtimestamp` varchar(50) DEFAULT NULL,
  CONSTRAINT `PRIMARY` PRIMARY KEY (`id`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;


  CREATE TABLE `pureimport_locks` (
    `pureId` int(11) NOT NULL,
    `lockName` varchar(128) NOT NULL,
    `created` timestamp NOT NULL DEFAULT current_timestamp()
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
  ALTER TABLE `pureimport_locks`
    ADD PRIMARY KEY (`pureId`);

  ");

$log->info("finished migration to v3.3.17");

__END__


