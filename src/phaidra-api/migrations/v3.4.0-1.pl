#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use MongoDB;

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

$log->info("started migration to v3.4.0-1");

my $mongodb = MongoDB::MongoClient->new(
  host               => 'mongodb-phaidra',
  port               => '27017',
  username           => $ENV{MONGODB_PHAIDRA_USER},
  password           => $ENV{MONGODB_PHAIDRA_PASSWORD},
  connect_timeout_ms => 300000,
  socket_timeout_ms  => 300000,
)->get_database('paf_mongodb')

$mongodb->get_collection('jobs')->update_many({ agent: "pige" },{ $set: { agent: "libvips" } });
$mongodb->get_collection('jobs')->update_many({ agent: "vige" },{ $set: { agent: "opencast" } });
$mongodb->get_collection('jobs')->update_many({ agent: "3d" },{ $set: { agent: "obj2gltf" } });
$mongodb->get_collection('jobs')->update_many({ agent: "360viewer" },{ $set: { agent: "unzip" } });

$log->info("finished migration to v3.4.0-1");

__END__


