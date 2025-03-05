#!/usr/bin/perl

use strict;
use warnings;
use MongoDB;
use Env;
use File::Path qw(remove_tree);
use Try::Tiny;

$| = 1;  # Disable output buffering

# MongoDB Connection
my $mongo = MongoDB::MongoClient->new(
    host               => $ENV{MONGODB_HOST},
    port               => 27017,
    username           => $ENV{MONGODB_PHAIDRA_USER},
    password           => $ENV{MONGODB_PHAIDRA_PASSWORD},
    connect_timeout_ms => 300000,
    socket_timeout_ms  => 300000,
    auth_mechanism     => "SCRAM-SHA-1"
)->get_database('paf_mongodb');

my $collection = $mongo->get_collection('jobs');

print "Searching for jobs with status 'TO_DELETE'...\n";

my $cursor = $collection->find({ status => "TO_DELETE" });

while (my $doc = $cursor->next) {
    my $image_path = $doc->{image};

    if ($image_path) {
        print "Deleting image: $image_path\n";

        try {
            remove_tree($image_path);
            print "Image deleted: $image_path\n";
        }
        catch {
            warn "Error deleting image: $image_path - $_\n";
        };
    
    try {
        $collection->delete_one({ _id => $doc->{_id} });
        print "Deleted document from MongoDB: $doc->{_id}\n";
    }
    catch {
        warn "Error deleting document: $_\n";
    };
}

print "Cleanup complete!\n";
