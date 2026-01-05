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

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (92,'it','ÖFOS',9);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (10936,'en','Physics and Astronomy Classification Scheme',45);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (10936,'de','Physics and Astronomy Classification Scheme',45);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (10936,'it','Physics and Astronomy Classification Scheme',45);


  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1552001,'it','University of Vienna',30);


  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1552264,'it','Basisklassifikation',30);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1554398,'it','OSNO - Opšta sistematizacija naučnih oblasti',35);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557234,'de','Conferences',41);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557234,'it','Conferences',41);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1559939,'de','BIC Standard Subject Qualifiers',43);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1559939,'it','BIC Standard Subject Qualifiers',43);


  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557244,'de','BIC Standard Subject Categories',42);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557244,'it','BIC Standard Subject Categories',42);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562584,'it','ÖFOS 2012',44);

  ");


$log->info("finished migration to v3.3.17");

__END__


