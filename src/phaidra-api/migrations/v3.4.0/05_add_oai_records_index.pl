#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use MongoDB;

# Usage: docker exec -it phaidra-api-1 perl migrations/<VERSION>/<SCRIPT>.pl

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

$log->info("adding oai_records index");

my $mongodb = MongoDB::MongoClient->new(
  host               => 'mongodb-phaidra',
  port               => '27017',
  username           => $ENV{MONGODB_PHAIDRA_USER},
  password           => $ENV{MONGODB_PHAIDRA_PASSWORD},
  connect_timeout_ms => 300000,
  socket_timeout_ms  => 300000,
)->get_database('mongodb');

$mongodb->get_collection('oai_records')->indexes->create_one([ deleted => 1, pid => 1 ]);

$log->info("finished adding oai_records index");

__END__
