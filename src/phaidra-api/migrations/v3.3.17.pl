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

my $cntr = DBIx::Connector->new("dbi:mysql:phaidradb:".$ENV{MARIADB_PHAIDRA_HOST}, $ENV{MARIADB_PHAIDRA_USER}, $ENV{MARIADB_PHAIDRA_PASSWORD}, {mysql_auto_reconnect => 1});
$cntr->mode('ping');

$cntr->dbh->do("
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557151,'en','wallchart',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557151,'de','Wandkarte',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557151,'it','carta murale',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557152,'en','postcard',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557152,'de','Postkarte',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557152,'it','cartolina',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557153,'en','painting',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557153,'de','Malerei',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557153,'it','dipinto',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557154,'en','drawing',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557154,'de','Zeichnung',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557154,'it','disegno',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557155,'en','photograph',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557155,'de','Foto',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557155,'it','fotografia',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557156,'en','picture',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557156,'de','Bild',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557156,'it','immagine',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557157,'en','poster',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557157,'de','Plakat',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557157,'it','manifesto',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557158,'en','print',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557158,'de','drucken, Drucke',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557158,'it','stampa',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557162,'en','slide',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557162,'de','Dia',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557162,'it','diapositiva',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557163,'en','negative',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557163,'de','Negativ',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557163,'it','negativo',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557174,'en','atlas',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557174,'de','Atlas',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557174,'it','atlante',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557175,'en','map',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557175,'de','Karte',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557175,'it','carta geografica',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557178,'en','remote sensing image',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557178,'de','Fernerkundungsbild',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557178,'it','immagine di telerilevamento',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557185,'en','score',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557185,'de','Partitur',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557185,'it','partitura',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557190,'en','vocal score',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557190,'de','Singstimmen',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557190,'it','spartito',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557192,'en','article of periodical',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557192,'de','Artikel in Zeitschrift',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557192,'it','articolo di periodico',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557193,'en','book part',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557193,'de','Buch Teil',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557193,'it','parte di libro',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557194,'en','book',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557194,'de','Buch',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557194,'it','libro',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557195,'en','manuscript',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557195,'de','Manuskript',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557195,'it','manoscritto',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557196,'en','periodical',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557196,'de','Zeitschrift',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557196,'it','periodico',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557206,'en','other',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557206,'de','Andere',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557206,'it','altro',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562632,'en','letter',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562632,'de','Brief',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562632,'it','lettera',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562633,'en','sound recording',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562633,'de','sound recording',24);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562633,'it','documento sonoro',24);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561102,'en','Addressee',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561102,'de','AdressatIn',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561102,'it','Destinatario',3);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561147,'en','Conservator',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561147,'de','KonservatorIn',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561147,'it','Conservatore',3);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561168,'en','Data contributor',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561168,'de','DatenlieferantIn',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561168,'it','Fornitore dei dati',3);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561258,'en','Project director',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561258,'de','PrjektleiterIn',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561258,'it','Direttore del progetto',3);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561303,'en','Transcriber',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561303,'de','Transcriber',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1561303,'it','Trascrittore',3);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562629,'en','Copista',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562629,'de','Copista',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562629,'it','Copista',3);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562631,'en','Editor of compilation',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562631,'de','Herausgeber*in eines Sammelwerks',3);
  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1562631,'it','Curatore della collezione',3);

  INSERT INTO vocabulary_entry (veid, isocode, entry, vid) VALUES (1557130,'it','Interprete',3);
  UPDATE vocabulary_entry SET entry='Valutatore della tesi' WHERE VEID='1562799' AND isocode='it';
  UPDATE vocabulary_entry SET entry='Correlatore' WHERE VEID='1562800' AND isocode='it';
  UPDATE vocabulary_entry SET entry='Fondatore' WHERE VEID='1562634' AND isocode='it';
  UPDATE vocabulary_entry SET entry='Autore della dissertazione' WHERE VEID='1557143' AND isocode='it';
  UPDATE vocabulary_entry SET entry='Incisore su metallo' WHERE VEID='1557105' AND isocode='it';
  UPDATE vocabulary_entry SET entry='Responsabile del caricamento' WHERE VEID='1557146' AND isocode='it';
  ");
$log->info("finished migration to v3.3.17");

__END__


