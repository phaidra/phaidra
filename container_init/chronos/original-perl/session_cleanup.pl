#!/usr/bin/perl

use strict;
use warnings;
use MongoDB;
use Time::HiRes qw(sleep);
use Env;

$| = 1;  # Disable output buffering

# MongoDB Connection
my $mongo = MongoDB::MongoClient->new(
    host               => $ENV{MONGODB_HOST},
    port               => 27017,
    username           => $ENV{MONGODB_PHAIDRA_USER},
    password           => $ENV{MONGODB_PHAIDRA_PASSWORD},
    connect_timeout_ms => 300000,
    socket_timeout_ms  => 300000,
    auth_mechanism     => "SCRAM-SHA-1"   # Explicitly define authentication method
)->get_database('mongodb');

# Confirm connection
print "Connected to MongoDB successfully!\n";

print "Checking for expired sessions...\n";
    
my $current_time = int(time());
print "Checking for expired sessions..." . $current_time . "\n";
my $delete_result = $mongo->get_collection('session')->delete_many({ expires => { '$lt' => $current_time } });

print "Deleted " . $delete_result->deleted_count . " expired sessions.\n";

__END__