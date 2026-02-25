#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);
use MIME::Base64 qw(encode_base64);

# Migration script to remove keyword_suggest field and associated copyFields from Solr
# This field was used for suggester functionality that is no longer in use.
# Keywords are now searched via dc_subject and its language variants (dc_subject_eng, dc_subject_deu, dc_subject_ita).

# Read environment variables
my $SOLR_HOST = $ENV{SOLR_HOST} // die "SOLR_HOST is not set\n";
my $SOLR_USER = $ENV{SOLR_USER} // die "SOLR_USER is not set\n";
my $SOLR_PASS = $ENV{SOLR_PASS} // die "SOLR_PASS is not set\n";

# Cores to update
my @CORES = ('phaidra', 'phaidra_pages');

# Basic auth header
sub auth_headers {
  my $token = encode_base64("$SOLR_USER:$SOLR_PASS", '');
  return {
    'Content-Type'  => 'application/json',
    'Authorization' => "Basic $token",
  };
}

my $ua = Mojo::UserAgent->new;

for my $core (@CORES) {
  print "Processing core: $core\n";
  
  # Step 1: Delete copyField from dc_subject* to keyword_suggest
  print "  Deleting copyField dc_subject* -> keyword_suggest...\n";
  my $delete_copyfield_url = "http://$SOLR_HOST:8983/solr/$core/schema";
  my $delete_copyfield_body = encode_json({
    'delete-copy-field' => {
      source => 'dc_subject*',
      dest   => 'keyword_suggest'
    }
  });
  
  my $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_copyfield_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted copyField dc_subject* -> keyword_suggest\n";
  } else {
    my $body = $res->body;
    if ($body =~ /copyField.*doesn't exist|not found/i) {
      print "    copyField dc_subject* -> keyword_suggest does not exist (already removed or never existed)\n";
    } else {
      print "    Warning: Failed to delete copyField: " . $res->code . " - $body\n";
    }
  }
  
  # Step 2: Delete copyField from keyword_suggest to _text_
  print "  Deleting copyField keyword_suggest -> _text_...\n";
  $delete_copyfield_body = encode_json({
    'delete-copy-field' => {
      source => 'keyword_suggest',
      dest   => '_text_'
    }
  });
  
  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_copyfield_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted copyField keyword_suggest -> _text_\n";
  } else {
    my $body = $res->body;
    if ($body =~ /copyField.*doesn't exist|not found/i) {
      print "    copyField keyword_suggest -> _text_ does not exist (already removed or never existed)\n";
    } else {
      print "    Warning: Failed to delete copyField: " . $res->code . " - $body\n";
    }
  }
  
  # Step 3: Delete the keyword_suggest field
  print "  Deleting field keyword_suggest...\n";
  my $delete_field_body = encode_json({
    'delete-field' => {
      name => 'keyword_suggest'
    }
  });
  
  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_field_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted field keyword_suggest\n";
  } else {
    my $body = $res->body;
    if ($body =~ /field.*doesn't exist|not found|no such field/i) {
      print "    Field keyword_suggest does not exist (already removed or never existed)\n";
    } else {
      print "    Warning: Failed to delete field: " . $res->code . " - $body\n";
    }
  }
  
  print "  Done with core: $core\n\n";
}

print "Migration complete.\n";
print "\nNote: You may also want to manually update the managed-schema files to remove:\n";
print "  1. <field name=\"keyword_suggest\" .../>\n";
print "  2. <copyField source=\"dc_subject*\" dest=\"keyword_suggest\"/>\n";
print "  3. <copyField source=\"keyword_suggest\" dest=\"_text_\"/> (if present)\n";
