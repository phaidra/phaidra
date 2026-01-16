#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json);
use MIME::Base64 qw(encode_base64);

# Read environment variables
my $SOLR_HOST = $ENV{SOLR_HOST} // die "SOLR_HOST is not set\n";
my $SOLR_USER = $ENV{SOLR_USER} // die "SOLR_USER is not set\n";
my $SOLR_PASS = $ENV{SOLR_PASS} // die "SOLR_PASS is not set\n";

# Endpoints
my $SOLR_URL        = "http://$SOLR_HOST:8983/solr/phaidra/schema/copyfields";
my $SOLR_URL_PAGES  = "http://$SOLR_HOST:8983/solr/phaidra_pages/schema/copyfields";

# Basic auth header
sub auth_headers {
  my $token = encode_base64("$SOLR_USER:$SOLR_PASS", '');
  return {
    'Content-Type'  => 'application/json',
    'Authorization' => "Basic $token",
  };
}

# Fields to copy to _text_ (excluding extracted_text)
my @FIELDS = qw(
  altformats
  altversions
  annotations
  annotations_json
  association
  association_id
  affiliation
  affiliation_id
  bbox
  bf_paralleltitle_maintitle
  bf_paralleltitle_subtitle
  bf_physicallocation
  bf_shelfmark
  bf_title_maintitle
  bf_title_subtitle
  checkafter
  cmodel
  created
  datastreams
  dc_license
  dcterms_accessrights_id
  dcterms_available
  dcterms_created_year
  dcterms_created_year_sort
  dcterms_created_edtf
  dcterms_datesubmitted
  dcterms_subject_id
  descriptions_json
  edm_hastype
  edm_hastype_id
  educational_context
  educational_enduserrole
  educational_learningresourcetype
  firstpagepid
  frapo_hasfundingagency_json
  frapo_isoutputof_json
  funder
  funder_id
  hasmember
  haspart
  hassuccessor
  hastrack
  id_bib_roles_pers_uploader
  isalternativeformatof
  isalternativeversionof
  isbacksideof
  isinadminset
  ismemberof
  ispartof
  isrestricted
  isthumbnailfor
  journal_title
  keyword_suggest
  language
  latlon
  members_metadata
  modified
  ns
  oaire_version_id
  object_type_id
  oer
  owl_sameas
  owner
  pid
  predecessor
  programme
  programme_id
  project
  project_id
  rdau_P60048
  rdau_P60048_id
  rdau_P60071_year
  rdau_P60071_year_sort
  references
  resourcetype
  roles_json
  schema_genre
  schema_genre_id
  schema_pageend
  schema_pagestart
  size
  sort_dc_title
  sort_deu_dc_title
  sort_eng_dc_title
  sort_ita_dc_title
  successor
  systemtag
  tcreated
  title_suggest
  title_suggest_ir
  tmodified
  tsize
  uwm_association_id
  uwm_funding
  uwm_roles_json
  vra_inscription
);

my $ua = Mojo::UserAgent->new;

sub list_copyfields {
  my ($url) = @_;
  my $tx = $ua->get($url => auth_headers());
  if (!$tx->result->is_success) {
    die "Failed to list copyFields at $url: " . ($tx->error->{message} // 'Unknown error') . "\n";
  }
  my $data = $tx->result->json // {};
  return $data->{copyFields} // [];
}

sub delete_wildcard {
  my ($url) = @_;
  print "Removing wildcard copyField (source=\"*\" -> dest=\"_text_\") via Schema API at $url...\n";

  my $payload = { 'delete-copy-field' => { source => '*', dest => '_text_' } };
  my $tx = $ua->post($url => auth_headers() => json => $payload);

  if ($tx->result->is_success && ($tx->result->json->{responseHeader}{status} // 1) == 0) {
    print "✓ Wildcard copyField removed\n";
  } else {
    print "⚠ Could not remove wildcard copyField (may not exist): ";
    if ($tx->result->is_success) {
      print $tx->result->body, "\n";
    } else {
      print ($tx->error->{message} // 'Unknown error'), "\n";
      print $tx->result->body, "\n" if defined $tx->result->body;
    }
  }

  print "Verifying wildcard removal...\n";
  my $cf = list_copyfields($url);
  my $has_wildcard = grep { ($_->{source} // '') eq '*' && ($_->{dest} // '') eq '_text_' } @$cf;
  if ($has_wildcard) {
    print "✗ Wildcard copyField still present\n\n";
  } else {
    print "✓ Wildcard copyField not present\n\n";
  }
}

sub add_missing_copyfields {
  my ($url) = @_;
  print "Ensuring copyFields to _text_ from managed-schema at $url...\n";

  # Fetch current copyfields
  my $cf = list_copyfields($url);

  # Build a set of sources that already copy to _text_
  my %existing_to_text = map { ($_->{source} // '') => 1 }
                         grep { ($_->{dest} // '') eq '_text_' && defined $_->{source} } @$cf;

  # Compute missing fields
  my @missing = grep { !$existing_to_text{$_} } @FIELDS;

  print "Already present (dest=_text_): " . (scalar(@FIELDS) - scalar(@missing)) . "\n";
  print "Missing to add: " . scalar(@missing) . "\n\n";

  if (!@missing) {
    print "✓ Nothing to add. All requested copyFields are already present for dest=_text_.\n";
    print "Note: Reindex only needed if you changed mappings.\n";
    return;
  }

  my @adds = map { { source => $_, dest => '_text_' } } @missing;
  my $payload = { 'add-copy-field' => \@adds };

  print "Sending add request for " . scalar(@missing) . " copyFields...\n";
  my $tx = $ua->post($url => auth_headers() => json => $payload);

  if ($tx->result->is_success && ($tx->result->json->{responseHeader}{status} // 1) == 0) {
    print "✓ Successfully added missing copyFields to _text_\n\n";
    print "Verifying...\n";
    my $cf2 = list_copyfields($url);
    my %post_existing = map { ($_->{source} // '') => 1 }
                        grep { ($_->{dest} // '') eq '_text_' && defined $_->{source} } @$cf2;
    my @still_missing = grep { !$post_existing{$_} } @missing;

    my $count_text = scalar grep { ($_->{dest} // '') eq '_text_' } @$cf2;
    print "Found $count_text copyFields copying to _text_\n";
    if (@still_missing) {
      print "⚠ Still missing after add: " . join(', ', @still_missing) . "\n";
    } else {
      print "✓ All requested fields are now present.\n";
    }
    print "\nNote: You'll need to reindex documents for _text_ to be updated.\n";
  } else {
    print "✗ Error adding copyFields:\n";
    if ($tx->result->is_success) {
      print $tx->result->body, "\n";
    } else {
      print ($tx->error->{message} // 'Unknown error'), "\n";
      print $tx->result->body, "\n" if defined $tx->result->body;
    }
  }
}

print "Processing phaidra core...\n";
delete_wildcard($SOLR_URL);
add_missing_copyfields($SOLR_URL);

print "\nProcessing phaidra_pages core...\n";
delete_wildcard($SOLR_URL_PAGES);
add_missing_copyfields($SOLR_URL_PAGES);

print "\nDone.\n";