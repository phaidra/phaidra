#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use MongoDB 1.8.3;
use DateTime;
use DateTime::Format::ISO8601;
use Time::HiRes qw/tv_interval gettimeofday/;

my $folders = {
  'ocflroot' => {
    'path' => $ENV{FEDORA_OCFL_ROOT},
    'size' => undef
  },
  'imageserver' => {
    'path' => $ENV{IMAGESERVER_ROOT_PATH},
    'size' => undef
  }
};

my $mongo = MongoDB::MongoClient->new(
  host               => $ENV{MONGODB_HOST},
  port               => 27017,
  username           => $ENV{MONGODB_PHAIDRA_USER},
  password           => $ENV{MONGODB_PHAIDRA_PASSWORD},
  connect_timeout_ms => 300000,
  socket_timeout_ms  => 300000,
)->get_database('mongodb');

for my $f (keys %{$folders}) {
  my $p = $folders->{$f}->{'path'};
  if ($p) {
    if (-d $p) {
      my $t0 = [gettimeofday];
      my $command = "du -s ".$folders->{$f}->{'path'}." | cut -f1";
      my $size = `$command`;
      my $t1 = tv_interval($t0);
      $size =~ s/^\s+|\s+$//g;
      print "du of $p took $t1 s, size=$size\n";
      $folders->{$f}->{size} = $size;
    }
  }
}

my $insert = { 
  timestamp => time, 
  timestamp_iso => DateTime->now->iso8601 . 'Z'
};
for my $f (keys %{$folders}) {
  $insert->{$f} = $folders->{$f}->{size};
}

$mongo->get_collection('storage_stats')->insert_one($insert);

__END__
