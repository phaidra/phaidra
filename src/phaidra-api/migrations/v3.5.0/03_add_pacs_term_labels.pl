#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use DBIx::Connector;

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

  -- PACS (cid=4 / vid=26) term labels missing from vocabulary_entry; take from taxon.description
  INSERT IGNORE INTO vocabulary_entry (veid, isocode, entry, vid)
  SELECT tv.veid, 'en', t.description, 26
  FROM taxon t
  JOIN taxon_vocentry tv ON tv.tid = t.tid AND tv.preferred = 1
  WHERE t.cid = 4 AND t.description IS NOT NULL AND t.description <> '';

  INSERT IGNORE INTO vocabulary_entry (veid, isocode, entry, vid)
  SELECT tv.veid, 'de', t.description, 26
  FROM taxon t
  JOIN taxon_vocentry tv ON tv.tid = t.tid AND tv.preferred = 1
  WHERE t.cid = 4 AND t.description IS NOT NULL AND t.description <> '';

  INSERT IGNORE INTO vocabulary_entry (veid, isocode, entry, vid)
  SELECT tv.veid, 'it', t.description, 26
  FROM taxon t
  JOIN taxon_vocentry tv ON tv.tid = t.tid AND tv.preferred = 1
  WHERE t.cid = 4 AND t.description IS NOT NULL AND t.description <> '';

  ");

$log->info("finished migration to v3.5.0");

__END__
