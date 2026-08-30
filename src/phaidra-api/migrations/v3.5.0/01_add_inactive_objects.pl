#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use DBIx::Connector;

# Usage: docker exec -it phaidra-api-1 perl migrations/v3.5.0/01_add_inactive_objects.pl

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

$log->info("started migration to v3.5.0");

my $cntr = DBIx::Connector->new("dbi:mysql:phaidradb:" . $ENV{MARIADB_PHAIDRA_HOST}, $ENV{MARIADB_PHAIDRA_USER}, $ENV{MARIADB_PHAIDRA_PASSWORD}, {mysql_auto_reconnect => 1, mysql_multi_statements => 1});
$cntr->mode('ping');

$cntr->dbh->do("
CREATE TABLE IF NOT EXISTS `inactive_objects` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `pid` VARCHAR(64) NOT NULL,
  `owner` VARCHAR(128) NOT NULL,
  `title` VARCHAR(1024) DEFAULT NULL,
  `cmodel` VARCHAR(64) DEFAULT NULL,
  `source` VARCHAR(64) NOT NULL DEFAULT 'manual',
  `status` VARCHAR(64) NOT NULL DEFAULT 'inactive',
  `created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_inactive_pid` (`pid`),
  KEY `idx_inactive_owner_status` (`owner`, `status`),
  KEY `idx_inactive_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
");

$log->info("finished migration to v3.5.0");

__END__
