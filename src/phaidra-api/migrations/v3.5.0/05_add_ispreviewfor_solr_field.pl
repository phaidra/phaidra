#!/usr/bin/env perl

use strict;
use warnings;
use HTTP::Request;
use JSON;
use LWP::UserAgent;
use Log::Log4perl;

my $logconf = q(
  log4perl.category.MyLogger         = INFO, Screen

  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init(\$logconf);
my $log = Log::Log4perl::get_logger('MyLogger');

my $solr_host   = $ENV{SOLR_HOST}   || 'solr';
my $solr_port   = $ENV{SOLR_PORT}   || '8983';
my $solr_user   = $ENV{SOLR_USER}   || 'phaidra';
my $solr_pass   = $ENV{SOLR_PASS}   || 'phaidra';
my $solr_scheme = $ENV{SOLR_SCHEME} || 'http';
my @cores       = ('phaidra', 'phaidra_pages');
my $field       = {
  name        => 'ispreviewfor',
  type        => 'strings',
  multiValued => 'true',
  indexed     => 'true',
  stored      => 'false',
};

my $ua = LWP::UserAgent->new(timeout => 30);

sub request {
  my ($method, $url, $content) = @_;
  my $request = HTTP::Request->new($method => $url);
  $request->authorization_basic($solr_user, $solr_pass);
  if (defined $content) {
    $request->header('Content-Type' => 'application/json');
    $request->content($content);
  }
  return $ua->request($request);
}

my $success = 1;
for my $core (@cores) {
  my $base_url = "$solr_scheme://$solr_host:$solr_port/solr/$core/schema";
  my $existing = request(GET => "$base_url/fields/$field->{name}");

  if ($existing->is_success) {
    $log->info("Field '$field->{name}' already exists in core '$core', skipping");
    next;
  }
  if ($existing->code != 404) {
    $log->error("Could not check field '$field->{name}' in core '$core': " . $existing->status_line);
    $success = 0;
    next;
  }

  my $payload  = JSON->new->utf8->encode({'add-field' => $field});
  my $response = request(POST => "$base_url/fields" => $payload);
  if ($response->is_success) {
    $log->info("Added field '$field->{name}' to core '$core'");
  }
  else {
    $log->error("Could not add field '$field->{name}' to core '$core': " . $response->status_line);
    $log->error('Response: ' . $response->content);
    $success = 0;
  }
}

exit($success ? 0 : 1);
