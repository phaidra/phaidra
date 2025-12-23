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
CREATE TABLE ip2location_v4 (
  start_ip INT UNSIGNED NOT NULL,
  end_ip   INT UNSIGNED NOT NULL,
  country  CHAR(2) NOT NULL,
  KEY ix_range (start_ip, end_ip)
) ENGINE=InnoDB;
");

$cntr->dbh->do("
CREATE TABLE ip2location_v6 (
  start_ip VARBINARY(16) NOT NULL,
  end_ip   VARBINARY(16) NOT NULL,
  country  CHAR(2) NOT NULL,
  KEY ix_range_v6 (start_ip, end_ip)
) ENGINE=InnoDB;
");

$cntr->dbh->do("
CREATE TABLE usage_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  action ENUM('info','preview','get','download') NOT NULL,
  pid_num INT UNSIGNED NOT NULL,
  visitor_id BIGINT UNSIGNED NOT NULL,
  ip_version TINYINT NOT NULL,
  ip_v4 INT UNSIGNED NULL,
  ip_v6 VARBINARY(16) NULL,
  country CHAR(2) NULL,
  created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_pidnum_created (pid_num, created),
  KEY ix_visitor_created (visitor_id, created),
  KEY ix_created (created),
  KEY ix_ip_v4 (ip_v4),
  KEY ix_ip_v6 (ip_v6)
) ENGINE=InnoDB;
");

$cntr->dbh->do("
CREATE TABLE usage_statistics (
  pid_num INT UNSIGNED NOT NULL,
  `info`     INT UNSIGNED NOT NULL DEFAULT 0,
  `preview`  INT UNSIGNED NOT NULL DEFAULT 0,
  `get`      INT UNSIGNED NOT NULL DEFAULT 0,
  `download` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (pid_num)
) ENGINE=InnoDB;
");

$cntr->dbh->do("
CREATE TABLE usage_statistics_state (
  singleton TINYINT NOT NULL DEFAULT 1,
  last_processed_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (singleton)
) ENGINE=InnoDB;

INSERT INTO usage_statistics_state (singleton, last_processed_id) VALUES (1, 0)
ON DUPLICATE KEY UPDATE last_processed_id = last_processed_id;
");

$log->info("finished migration to v3.3.17");

__END__


