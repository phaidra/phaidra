#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Digest::SHA qw(sha256_hex);

my $pid = shift (@ARGV);

my $resourceID = "info:fedora/$pid";
my $hash       = sha256_hex($resourceID);

my $first  = substr($hash, 0, 3);
my $second = substr($hash, 3, 3);
my $third  = substr($hash, 6, 3);

print "\n$ENV{FEDORA_OCFL_ROOT}/$first/$second/$third/$hash\n";

__END__


