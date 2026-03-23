#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::UserAgent;
use Mojo::JSON   qw(decode_json encode_json);
use MIME::Base64 qw(encode_base64);

# Migration script to remove keyword_suggest, title_suggest and title_suggest_ir fields
# and associated copyFields from Solr.
# These fields were used for suggester functionality that is no longer in use.

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
  my $delete_copyfield_url  = "http://$SOLR_HOST:8983/solr/$core/schema";
  my $delete_copyfield_body = encode_json(
    { 'delete-copy-field' => {
        source => 'dc_subject*',
        dest   => 'keyword_suggest'
      }
    }
  );

  my $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_copyfield_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted copyField dc_subject* -> keyword_suggest\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /copyField.*doesn't exist|not found/i) {
      print "    copyField dc_subject* -> keyword_suggest does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete copyField: " . $res->code . " - $body\n";
    }
  }

  # Step 2: Delete copyField from keyword_suggest to _text_
  print "  Deleting copyField keyword_suggest -> _text_...\n";
  $delete_copyfield_body = encode_json(
    { 'delete-copy-field' => {
        source => 'keyword_suggest',
        dest   => '_text_'
      }
    }
  );

  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_copyfield_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted copyField keyword_suggest -> _text_\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /copyField.*doesn't exist|not found/i) {
      print "    copyField keyword_suggest -> _text_ does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete copyField: " . $res->code . " - $body\n";
    }
  }

  # Step 3: Delete the keyword_suggest field
  print "  Deleting field keyword_suggest...\n";
  my $delete_field_body = encode_json({'delete-field' => {name => 'keyword_suggest'}});

  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_field_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted field keyword_suggest\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /field.*doesn't exist|not found|no such field/i) {
      print "    Field keyword_suggest does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete field: " . $res->code . " - $body\n";
    }
  }

  # Step 4: Delete copyField from *_dc_title to title_suggest
  print "  Deleting copyField *_dc_title -> title_suggest...\n";
  $delete_copyfield_body = encode_json(
    { 'delete-copy-field' => {
        source => '*_dc_title',
        dest   => 'title_suggest'
      }
    }
  );

  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_copyfield_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted copyField *_dc_title -> title_suggest\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /copyField.*doesn't exist|not found/i) {
      print "    copyField *_dc_title -> title_suggest does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete copyField: " . $res->code . " - $body\n";
    }
  }

  # Step 5: Delete copyField from title_suggest to _text_
  print "  Deleting copyField title_suggest -> _text_...\n";
  $delete_copyfield_body = encode_json(
    { 'delete-copy-field' => {
        source => 'title_suggest',
        dest   => '_text_'
      }
    }
  );

  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_copyfield_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted copyField title_suggest -> _text_\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /copyField.*doesn't exist|not found/i) {
      print "    copyField title_suggest -> _text_ does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete copyField: " . $res->code . " - $body\n";
    }
  }

  # Step 6: Delete the title_suggest field
  print "  Deleting field title_suggest...\n";
  $delete_field_body = encode_json({'delete-field' => {name => 'title_suggest'}});

  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_field_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted field title_suggest\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /field.*doesn't exist|not found|no such field/i) {
      print "    Field title_suggest does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete field: " . $res->code . " - $body\n";
    }
  }

  # Step 7: Delete copyField from title_suggest_ir to _text_
  print "  Deleting copyField title_suggest_ir -> _text_...\n";
  $delete_copyfield_body = encode_json(
    { 'delete-copy-field' => {
        source => 'title_suggest_ir',
        dest   => '_text_'
      }
    }
  );

  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_copyfield_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted copyField title_suggest_ir -> _text_\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /copyField.*doesn't exist|not found/i) {
      print "    copyField title_suggest_ir -> _text_ does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete copyField: " . $res->code . " - $body\n";
    }
  }

  # Step 8: Delete the title_suggest_ir field
  print "  Deleting field title_suggest_ir...\n";
  $delete_field_body = encode_json({'delete-field' => {name => 'title_suggest_ir'}});

  $res = $ua->post($delete_copyfield_url => auth_headers() => $delete_field_body)->result;
  if ($res->is_success) {
    print "    Successfully deleted field title_suggest_ir\n";
  }
  else {
    my $body = $res->body;
    if ($body =~ /field.*doesn't exist|not found|no such field/i) {
      print "    Field title_suggest_ir does not exist (already removed or never existed)\n";
    }
    else {
      print "    Warning: Failed to delete field: " . $res->code . " - $body\n";
    }
  }

  print "  Done with core: $core\n\n";
}

print "Migration complete.\n";
