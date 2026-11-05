#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::JSON qw(encode_json);

# Usage: docker exec -it phaidra-api-1 perl /usr/local/phaidra/phaidra-api/utils/changeOwner.pl <old_username> <new_username>

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my ($old_username, $new_username) = @ARGV;
if (!defined($old_username) || !defined($new_username) || @ARGV != 2) {
  die "Usage: $0 <old_username> <new_username>\n";
}
if ($old_username eq $new_username) {
  die "Old and new usernames must differ\n";
}

my $api = Mojo::URL->new;
$api->scheme('http');
$api->host($ENV{PHAIDRA_API_HOST});
$api->port(3000);
$api->userinfo($ENV{PHAIDRA_ADMIN_USER} . ':' . $ENV{PHAIDRA_ADMIN_PASSWORD});

my $ua = Mojo::UserAgent->new;
my $page_size = 1000;
my $migrated = 0;
my $failed = 0;
my @pids;

sub solr_escape_phrase {
  my ($value) = @_;
  $value =~ s/([+\-!(){}\[\]^"~*?:\\\/])/\\$1/g;
  return $value;
}

sub request_failed {
  my ($response, $context) = @_;
  my $message = $response->message // 'Unknown error';
  if (my $json = $response->json) {
    if (my $alerts = $json->{alerts}) {
      $message = join('; ', map { $_->{msg} // 'Unknown error' } @$alerts);
    }
  }
  warn "$context: HTTP " . ($response->code // 0) . " $message\n";
}

for (my $start = 0;; $start += $page_size) {
  my $search_url = $api->clone->path('search/select')->query({
    q     => '*:*',
    fq    => 'owner:"' . solr_escape_phrase($old_username) . '"',
    fl    => 'pid',
    rows  => $page_size,
    start => $start,
  });
  my $search_response = $ua->post($search_url)->result;
  if (!$search_response->is_success) {
    request_failed($search_response, 'Searching objects');
    exit 1;
  }

  my $search_result = $search_response->json;
  my $docs = ref($search_result) eq 'HASH' && ref($search_result->{response}) eq 'HASH'
    ? $search_result->{response}->{docs}
    : undef;
  if (ref($docs) ne 'ARRAY') {
    warn "Searching objects: response does not contain result documents\n";
    exit 1;
  }
  push @pids, map { $_->{pid} } grep { defined $_->{pid} } @$docs;
  last if scalar(@$docs) < $page_size;
}

while (@pids) {
  my @batch = splice @pids, 0, $page_size;
  my @objects = map { {pid => $_, ownerid => $new_username} } @batch;
  my $modify_url = $api->clone->path('/objects/' . $old_username . '/modify');
  my $modify_response = $ua->post($modify_url => form => {
    objects => encode_json({objects => \@objects}),
  })->result;

  request_failed($modify_response, 'Changing object owners') if !$modify_response->is_success;

  my $modify_result = $modify_response->json;
  my $results = ref($modify_result) eq 'HASH' ? $modify_result->{results} : undef;
  if (ref($results) ne 'ARRAY') {
    warn "Changing object owners: response does not contain results\n";
    $failed += scalar @objects;
    next;
  }

  for my $result (@$results) {
    if (($result->{status} // 500) == 200) {
      $migrated++;
    }
    else {
      $failed++;
      my $message = join('; ', map { $_->{msg} // 'Unknown error' } @{$result->{alerts} // []});
      warn "Changing owner failed: $message\n";
    }
  }
}

print "Migrated $migrated objects from $old_username to $new_username";
print "; $failed failed" if $failed;
print "\n";
exit($failed ? 1 : 0);
