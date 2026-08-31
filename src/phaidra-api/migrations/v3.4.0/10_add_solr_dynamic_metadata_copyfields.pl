#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::UserAgent;
use MIME::Base64 qw(encode_base64);

# Add copyFields from dynamic metadata patterns to _text_ (Uwmetadata dc_*, bib_*, langs).
# Idempotent: only adds copyField rules that are not already present.
# Run on existing Solr instances after pulling container_init managed-schema changes.
# Typical order: 06_add_solr_copyfields.pl, 08_remove_keyword_suggest.pl (if applicable), then this script.
# Reindex Solr after schema changes so _text_ is rebuilt for existing documents.

# Read environment variables
my $SOLR_HOST = $ENV{SOLR_HOST} // die "SOLR_HOST is not set\n";
my $SOLR_USER = $ENV{SOLR_USER} // die "SOLR_USER is not set\n";
my $SOLR_PASS = $ENV{SOLR_PASS} // die "SOLR_PASS is not set\n";

my $SOLR_URL       = "http://$SOLR_HOST:8983/solr/phaidra/schema/copyfields";
my $SOLR_URL_PAGES = "http://$SOLR_HOST:8983/solr/phaidra_pages/schema/copyfields";

# Sources that must copy into _text_ (match dynamicField patterns in managed-schema)
my @SOURCES = qw(
  dc_*
  member_dc_*
  bib_*
  *_eng
  *_deu
  *_ita
);

sub auth_headers {
  my $token = encode_base64("$SOLR_USER:$SOLR_PASS", '');
  return {
    'Content-Type'  => 'application/json',
    'Authorization' => "Basic $token",
  };
}

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

sub add_missing {
  my ($url, $label) = @_;
  print "[$label] Ensuring dynamic metadata copyFields -> _text_ at $url...\n";

  my $cf               = list_copyfields($url);
  my %existing_to_text = map {($_->{source} // '') => 1}
    grep {($_->{dest} // '') eq '_text_' && defined $_->{source}} @$cf;

  my @missing = grep {!$existing_to_text{$_}} @SOURCES;

  print "  Already present: " . (scalar(@SOURCES) - scalar(@missing)) . "\n";
  print "  Missing to add: " . scalar(@missing) . "\n";

  if (!@missing) {
    print "  OK: All dynamic copyFields already present.\n\n";
    return;
  }

  my @adds    = map {{source => $_, dest => '_text_'}} @missing;
  my $payload = {'add-copy-field' => \@adds};

  print "  Sending add request for " . scalar(@missing) . " copyField(s)...\n";
  my $tx = $ua->post($url => auth_headers() => json => $payload);

  if ($tx->result->is_success && ($tx->result->json->{responseHeader}{status} // 1) == 0) {
    print "  OK: Added: " . join(', ', @missing) . "\n";
    print "  Note: Reindex documents so _text_ includes existing field values.\n\n";
  }
  else {
    print "  ERROR adding copyFields:\n";
    if ($tx->result->is_success) {
      print $tx->result->body . "\n";
    }
    else {
      print(($tx->error->{message} // 'Unknown error') . "\n");
      print $tx->result->body . "\n" if defined $tx->result->body;
    }
  }
}

print "10_add_solr_dynamic_metadata_copyfields.pl\n";
print "Processing phaidra core...\n";
add_missing($SOLR_URL, 'phaidra');

print "Processing phaidra_pages core...\n";
add_missing($SOLR_URL_PAGES, 'phaidra_pages');

print "Done.\n";
