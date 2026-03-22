#!/usr/bin/env perl
use strict;
use warnings;
use v5.10;

use Data::Dumper;
use FindBin qw($Bin);
use File::Spec;
use Log::Log4perl;
use HTTP::Request;
use MIME::Base64 qw(encode_base64);
use LWP::UserAgent;
use JSON;

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

$log->info("Starting Solr schema additions for series/publisher indexing fields");

# Solr configuration from env
my $solr_host   = $ENV{SOLR_HOST} || 'solr';
my $solr_port   = $ENV{SOLR_PORT} || '8983';
my $solr_user   = $ENV{SOLR_USER} || 'phaidra';
my $solr_pass   = $ENV{SOLR_PASS} || 'phaidra';
my $solr_scheme = $ENV{SOLR_SCHEME} || 'http';

my @cores = ('phaidra', 'phaidra_pages');

my @fields_to_add = (
  {
    name         => 'bib_issn',
    type         => 'strings',
    multiValued  => 'true',
    indexed      => 'true',
    stored       => 'true',
  },
  {
    name         => 'bib_seriesidentifier',
    type         => 'strings',
    multiValued  => 'true',
    indexed      => 'true',
    stored       => 'true',
  },
);

my @copyfields_to_add = (
  { source => 'bib_issn',             dest => '_text_' },
  { source => 'bib_seriesidentifier', dest => '_text_' },
);

my $ua = LWP::UserAgent->new;
$ua->timeout(30);

sub field_exists {
  my ($field_name, $core) = @_;
  my $url = "$solr_scheme://$solr_host:$solr_port/solr/$core/schema/fields/$field_name";
  my $request = HTTP::Request->new(GET => $url);
  $request->authorization_basic($solr_user, $solr_pass);

  my $response = $ua->request($request);
  if ($response->is_success) {
    return 1;
  }
  if ($response->code == 404) {
    return 0;
  }

  $log->error("Error checking field '$field_name' in core '$core': " . $response->status_line);
  return -1;
}

sub add_field {
  my ($field_config, $core) = @_;
  my $url = "$solr_scheme://$solr_host:$solr_port/solr/$core/schema/fields";

  my $request = HTTP::Request->new(POST => $url);
  $request->authorization_basic($solr_user, $solr_pass);
  $request->header('Content-Type' => 'application/json');

  my $solr_field_config = { "add-field" => $field_config };
  my $json = JSON->new->utf8->encode($solr_field_config);
  $request->content($json);

  my $response = $ua->request($request);
  if ($response->is_success) {
    $log->info("Successfully added field '$field_config->{name}' to core '$core'");
    return 1;
  }

  $log->error("Failed to add field '$field_config->{name}' to core '$core': " . $response->status_line);
  $log->error("Response body: " . $response->content);
  return 0;
}

sub add_copyfields {
  my ($core) = @_;
  my $url = "$solr_scheme://$solr_host:$solr_port/solr/$core/schema/copyfields";

  # Fetch existing copyFields to avoid duplicate add-copy-field failures
  my $list_request = HTTP::Request->new(GET => $url);
  $list_request->authorization_basic($solr_user, $solr_pass);
  my $list_response = $ua->request($list_request);
  if (!$list_response->is_success) {
    $log->error("Failed to list copyFields for core '$core': " . $list_response->status_line);
    $log->error("Response body: " . $list_response->content);
    return 0;
  }

  my $data = JSON->new->utf8->decode($list_response->content);
  my $existing_copyfields = $data->{copyFields} // [];
  my %existing = ();
  for my $cf (@$existing_copyfields) {
    next unless ref($cf) eq 'HASH';
    my $source = $cf->{source} // '';
    my $dest = $cf->{dest} // '';
    $existing{"$source=>$dest"} = 1;
  }

  my @adds = ();
  for my $cf (@copyfields_to_add) {
    my $source = $cf->{source};
    my $dest = $cf->{dest};
    if (!$existing{"$source=>$dest"}) {
      push @adds, { source => $source, dest => $dest };
    }
  }

  if (!@adds) {
    $log->info("copyFields already present for core '$core', skipping");
    return 1;
  }

  my $payload = { 'add-copy-field' => \@adds };
  my $request = HTTP::Request->new(POST => $url);
  $request->authorization_basic($solr_user, $solr_pass);
  $request->header('Content-Type' => 'application/json');

  my $json = JSON->new->utf8->encode($payload);
  $request->content($json);

  my $response = $ua->request($request);
  if ($response->is_success) {
    $log->info("Successfully ensured copyFields for core '$core'");
    return 1;
  }

  $log->error("Failed to add copyFields for core '$core': " . $response->status_line);
  $log->error("Response body: " . $response->content);
  return 0;
}

my $ok = 1;
for my $core (@cores) {
  $log->info("Processing core '$core'...");

  for my $field_config (@fields_to_add) {
    my $field_name = $field_config->{name};
    my $exists = field_exists($field_name, $core);

    if ($exists == 1) {
      $log->info("Field '$field_name' already exists in core '$core', skipping");
      next;
    }

    if ($exists == -1) {
      $log->warn("Error checking '$field_name' in core '$core', skipping");
      next;
    }

    $ok &&= add_field($field_config, $core);
  }

  $ok &&= add_copyfields($core);
}

if (!$ok) {
  $log->error("Solr schema additions failed; stopping before reindex.");
  exit 1;
}

$log->info("Solr schema additions completed. Reindexing existing instances (ArchivalGroup)...");

my $index_script = File::Spec->catfile($Bin, '..', '..', 'utils', 'indexObjects.pl');
$index_script = File::Spec->rel2abs($index_script);

if (!-f $index_script) {
  $log->error("Could not locate index script at '$index_script'");
  exit 1;
}

$log->info("Running reindex script: $index_script " . join(' ', @ARGV));

# Usage of indexObjects.pl: optional from-date-iso until-date-iso
my $cmd_ok = system('perl', $index_script, @ARGV);
if ($cmd_ok != 0) {
  $log->error("Reindex script exited with code $cmd_ok");
  exit 1;
}

$log->info("Done: schema updated and existing instances reindexed.");

__END__

