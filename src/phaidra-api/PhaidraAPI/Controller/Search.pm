package PhaidraAPI::Controller::Search;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Fedora;
use PhaidraAPI::Model::Iiifmanifest;
use Encode     qw(decode);
use List::Util qw(first);

sub get_pids {
  my $self = shift;

  unless (defined($self->param('q'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined query'}]}, status => 400);
    return;
  }

  my $query = $self->param('q');

  my $search_model = PhaidraAPI::Model::Search->new;
  my $sr           = $search_model->get_pids($self, $query);
  if ($sr->{status} ne 200) {
    $self->render(json => $sr, status => $sr->{status});
  }

  $self->render(json => {pids => $sr->{pids}}, status => $sr->{status});
}

sub search_ocr {
  my $self = shift;

  my $apiBaseUrlPath = $self->app->config->{scheme} . '://' . $self->app->config->{baseurl} . ($self->app->config->{basepath} ? '/' . $self->app->config->{basepath} : '');

  my $query = $self->param('q');
  my $pid   = $self->stash('pid');

  # Get start parameter for pagination (defaults to 0)
  my $start = $self->param('start') // 0;
  $start = int($start);

  # Step 1: Get the ordered page PIDs from the IIIF manifest
  my $iiifm_model = PhaidraAPI::Model::Iiifmanifest->new;
  my $mr          = $iiifm_model->get_updated_manifest($self, $pid);
  if ($mr->{status} ne 200) {
    $self->render(json => {error => "Failed to load IIIF manifest: " . ($mr->{alerts}->[0]->{msg} // 'unknown error')}, status => 500);
    return;
  }

  my @page_pids = $self->_extract_page_pids_from_manifest($mr->{manifest});
  if (!@page_pids) {
    $self->render(json => {error => "No pages found for object $pid"}, status => 404);
    return;
  }

  # Step 2: Find which pages contain matches in the book's pages

  # Whole-word, case-insensitive match in Solr: use a quoted term
  # Escape embedded quotes in the query
  my $escaped_q = $query // '';
  $escaped_q =~ s{([+\-!(){}\[\]^"~*?:\\\/])}{\\$1}g;

  # Search specifically in extracted_text (OCR text stored in phaidra_pages core)
  # Use exact query, since we currently do exact search in ALTO as well. Otherwise we'll
  # have pages for which we have no ALTO matches and the navigation in Mirador will be broken
  my $search_query = "extracted_text:($escaped_q)";

  my $url = Mojo::URL->new;
  $url->scheme($self->app->config->{solr}->{scheme});
  $url->host($self->app->config->{solr}->{host});
  $url->port($self->app->config->{solr}->{port});

  my $pages_core = 'phaidra_pages';
  if ($self->app->config->{solr}->{path}) {
    $url->path("/" . $self->app->config->{solr}->{path} . "/solr/$pages_core/select");
  }
  else {
    $url->path("/solr/$pages_core/select");
  }

  # First get total count of matching pages in this book
  my %count_query_params = (
    q    => $search_query,
    fq   => "ispartof:\"$pid\"",
    fl   => "pid",
    rows => 0,
    wt   => "json",
  );
  my $ua = Mojo::UserAgent->new;
  $self->app->log->debug("POST Count Query URL: " . $url->to_string . " params: " . $self->app->dumper(\%count_query_params));

  my $get = $ua->post($url => form => \%count_query_params)->result;
  $self->app->log->debug("Count Response: " . $get->body);

  my $total_matching_pages = 0;
  if ($get->is_success) {
    my $count_response = $get->json;
    $total_matching_pages = $count_response->{response}->{numFound} || 0;
  }

  if ($total_matching_pages == 0) {

    # No matches found - return empty result
    my $response_json = {
      '@context'  => ['http://iiif.io/api/presentation/2/context.json', 'http://iiif.io/api/search/1/context.json'],
      '@id'       => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$start",
      '@type'     => 'sc:AnnotationList',
      'resources' => [],
      'hits'      => [],
      'within'    => {
        '@type' => 'sc:Layer',
        'total' => 0,
        'first' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=0",
        'last'  => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=0"
      },
      'startIndex' => $start
    };
    $self->render(json => $response_json, status => 200);
    return;
  }

  # Load all matching page pids and order them by the IIIF manifest sequence
  my %page_position_map = ();
  for (my $i = 0; $i < @page_pids; $i++) {
    $page_position_map{$page_pids[$i]} = $i;
  }

  my %page_query_params = (
    q    => $search_query,
    fq   => "ispartof:\"$pid\"",
    fl   => "pid",
    rows => $total_matching_pages,
    wt   => "json",
    sort => "created asc",
  );
  $self->app->log->debug("POST Matching Pages Query URL: " . $url->to_string . " params: " . $self->app->dumper(\%page_query_params));

  $get = $ua->post($url => form => \%page_query_params)->result;
  $self->app->log->debug("Matching Pages Response: " . $get->body);

  if (!$get->is_success) {
    $self->render(json => {error => $get->message}, status => 500);
    return;
  }

  my $page_response = $get->json;
  if (!$page_response->{response} || !$page_response->{response}->{docs} || @{$page_response->{response}->{docs}} == 0) {
    $self->render(json => {error => "No page found for index $start"}, status => 404);
    return;
  }

  my @matching_page_pids = map {$_->{pid}} @{$page_response->{response}->{docs}};
  @matching_page_pids   = sort {$page_position_map{$a} <=> $page_position_map{$b}} grep {exists $page_position_map{$_}} @matching_page_pids;
  $total_matching_pages = scalar @matching_page_pids;

  my $current_page_index = $start;
  my $last_page_start    = $total_matching_pages - 1;

  # Validate page index
  if ($current_page_index >= $total_matching_pages) {
    $self->render(json => {error => "Page index out of range"}, status => 400);
    return;
  }

  my $current_page_pid = $matching_page_pids[$current_page_index];
  my $page_number      = exists $page_position_map{$current_page_pid} ? $page_position_map{$current_page_pid} + 1 : 0;

  $self->app->log->debug("Processing page $current_page_index of $total_matching_pages matching pages (PID: $current_page_pid, book page: $page_number)");

  # Step 4: Process the current page and get all its matches
  my $fedora_model  = PhaidraAPI::Model::Fedora->new;
  my $ocr_datasteam = $fedora_model->getDatastream($self, $current_page_pid, 'ALTO');
  if ($ocr_datasteam->{status} != 200) {
    $self->render(json => {error => $ocr_datasteam->{alerts}->[0]->{msg}}, status => 500);
    return;
  }

  # Parse ALTO XML to extract text and coordinates
  my $dom = Mojo::DOM->new();
  $dom->xml(1);
  $dom->parse(decode('UTF-8', $ocr_datasteam->{ALTO}));

  # Find all matches on this page
  my @annotations   = ();
  my @hits          = ();
  my $annotation_id = 1;

  my @alto_strings = $dom->find('String')->each;

  # Find matches and get context from surrounding String elements
  for (my $i = 0; $i < @alto_strings; $i++) {
    my $string_element = $alto_strings[$i];
    my $element_text   = $string_element->attr('CONTENT') || '';

    # Whole-word, case-insensitive match within the token (handles trailing punctuation like "time.")
    if ($element_text =~ /\b\Q$query\E\b/i) {

      # Get coordinates for this match
      my $hpos   = $string_element->attr('HPOS')   || 0;
      my $vpos   = $string_element->attr('VPOS')   || 0;
      my $width  = $string_element->attr('WIDTH')  || 0;
      my $height = $string_element->attr('HEIGHT') || 0;

      # Build context from surrounding String elements
      my $before_text = '';
      my $after_text  = '';

      # Get 3 String elements before (if available)
      for (my $j = $i - 3; $j < $i && $j >= 0; $j++) {
        my $before_element = $alto_strings[$j];
        my $before_content = $before_element->attr('CONTENT') || '';
        $before_text .= $before_content . ' ';
      }

      # Get 3 String elements after (if available)
      for (my $j = $i + 1; $j <= $i + 3 && $j < @alto_strings; $j++) {
        my $after_element = $alto_strings[$j];
        my $after_content = $after_element->attr('CONTENT') || '';
        $after_text .= $after_content . ' ';
      }

      # Clean up whitespace
      $before_text =~ s/\s+/ /g;
      $after_text  =~ s/\s+/ /g;
      $before_text =~ s/^\s+|\s+$//g;
      $after_text  =~ s/^\s+|\s+$//g;

      # Create annotation for this match (IIIF Search API 1.0 format)
      my $annotation = {
        '@id'        => "$apiBaseUrlPath/iiif/$pid/canvas/$page_number/text/at/" . ($hpos || 0) . "," . ($vpos || 0) . "," . ($width || 0) . "," . ($height || 0),
        '@type'      => 'oa:Annotation',
        'motivation' => 'sc:painting',
        'resource'   => {
          '@type' => 'cnt:ContentAsText',
          'chars' => $element_text
        },
        'on' => "$apiBaseUrlPath/iiif/$pid/canvas/$page_number#xywh=" . ($hpos || 0) . "," . ($vpos || 0) . "," . ($width || 0) . "," . ($height || 0)
      };
      push @annotations, $annotation;

      # Create hit for this match
      my $hit = {
        '@type'       => 'search:Hit',
        'annotations' => ["$apiBaseUrlPath/iiif/$pid/canvas/$page_number/text/at/" . ($hpos || 0) . "," . ($vpos || 0) . "," . ($width || 0) . "," . ($height || 0)],
        'before'      => $before_text,
        'after'       => $after_text,
        'match'       => $query
      };
      push @hits, $hit;

      $annotation_id++;
    }
  }

  # Create response with page-based pagination
  my $response_json = {
    '@context'  => ['http://iiif.io/api/presentation/2/context.json', 'http://iiif.io/api/search/1/context.json'],
    '@id'       => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$start",
    '@type'     => 'sc:AnnotationList',
    'resources' => \@annotations,
    'hits'      => \@hits,
    'within'    => {
      '@type' => 'sc:Layer',
      'total' => $total_matching_pages,                                              # Total number of pages with matches
      'first' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=0",
      'last'  => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$last_page_start"
    },
    'startIndex' => $start
  };

  # Add next/prev links for page navigation
  if ($current_page_index < $total_matching_pages - 1) {
    my $next_start = $start + 1;
    $response_json->{'next'} = "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$next_start";
  }

  if ($current_page_index > 0) {
    my $prev_start = $start - 1;
    if ($prev_start < 0) {$prev_start = 0;}
    $response_json->{'prev'} = "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$prev_start";
  }

  $self->render(json => $response_json, status => 200);
}

sub _extract_page_pids_from_manifest {
  my ($self, $manifest) = @_;
  return () unless $manifest && ref $manifest eq 'HASH' && $manifest->{items} && ref $manifest->{items} eq 'ARRAY';

  my @pids;
  for my $canvas (@{$manifest->{items}}) {
    next unless ref $canvas eq 'HASH';
    if (my $pid = $self->_page_pid_from_manifest_canvas($canvas)) {
      push @pids, $pid;
    }
  }
  return @pids;
}

sub _page_pid_from_manifest_canvas {
  my ($self, $canvas) = @_;
  return unless $canvas && ref $canvas eq 'HASH';

  if (my $items = $canvas->{items}) {
    if (ref $items eq 'ARRAY' && @$items) {
      my $annotation_page = $items->[0];
      if (ref $annotation_page eq 'HASH' && $annotation_page->{items} && ref $annotation_page->{items} eq 'ARRAY' && @{$annotation_page->{items}}) {
        my $annotation = $annotation_page->{items}->[0];
        if (ref $annotation eq 'HASH' && $annotation->{body} && ref $annotation->{body} eq 'HASH' && $annotation->{body}->{id}) {
          return $self->_page_pid_from_image_id($annotation->{body}->{id});
        }
      }
    }
  }

  if (my $label = $canvas->{label}) {
    if (ref $label eq 'HASH' && $label->{en} && ref $label->{en} eq 'ARRAY' && @{$label->{en}}) {
      for my $txt (@{$label->{en}}) {
        if ($txt =~ /(o:\d+)/) {
          return $1;
        }
      }
    }
    elsif (!ref $label && $label =~ /(o:\d+)/) {
      return $1;
    }
  }

  return;
}

sub _page_pid_from_image_id {
  my ($self, $image_id) = @_;
  return unless defined $image_id;
  if ($image_id =~ m{[?&]IIIF=([^/]+)\.tif}) {
    return $1;
  }
  return;
}

sub search_solr {
  my $self = shift;

  my $url = Mojo::URL->new;

  $url->scheme($self->app->config->{solr}->{scheme});
  $url->host($self->app->config->{solr}->{host});
  $url->port($self->app->config->{solr}->{port});
  my $core = $self->app->config->{solr}->{core};
  if (defined($self->param('core'))) {
    $core = $self->param('core');
  }
  if ($self->app->config->{solr}->{path}) {
    $url->path("/" . $self->app->config->{solr}->{path} . "/solr/$core/select");
  }
  else {
    $url->path("/solr/$core/select");
  }

  #$self->app->log->info("proxying solr request");
  #$self->app->log->info($url);
  #$self->app->log->info($self->app->dumper($self->req->params->to_hash));

  my $params            = $self->req->params->to_hash;
  my $include_extracted = defined $params->{extracted_text} && $params->{extracted_text} eq 'include';
  delete $params->{extracted_text};
  if ($include_extracted) {
    if (defined $params->{qf}) {
      my @qf_parts      = split /\s+/, $params->{qf};
      my @filtered      = grep {$_ !~ /^(?:dc_identifier)(\^\S+)?$/} @qf_parts;
      my $has_extracted = 0;
      my $has_text      = 0;
      for (my $i = 0; $i < @filtered; $i++) {
        if ($filtered[$i] =~ /^extracted_text(\^|$)/) {
          $has_extracted = 1;
        }
        if ($filtered[$i] =~ /^_text_(\^|$)/) {
          $has_text = 1;
        }
      }
      if (!$has_extracted) {
        push @filtered, 'extracted_text';
      }
      if (!$has_text) {
        push @filtered, '_text_^0.5';
      }
      if (@filtered) {
        $params->{qf} = join ' ', @filtered;
      }
      else {
        $params->{qf} = 'extracted_text _text_^0.5';
      }
    }
    else {
      $params->{qf} = 'extracted_text _text_^0.5';
    }
  }
  else {
    if (defined $params->{qf}) {
      my @qf_parts = split /\s+/, $params->{qf};

      # Remove extracted_text field only
      my @filtered = grep {$_ !~ /^extracted_text(\^\S+)?$/} @qf_parts;
      my $has_text = 0;
      for (my $i = 0; $i < @filtered; $i++) {
        if ($filtered[$i] =~ /^_text_(\^|$)/) {
          $filtered[$i] = '_text_^0.5';
          $has_text = 1;
          last;
        }
      }
      if (!$has_text) {
        push @filtered, '_text_^0.5';
      }
      if (@filtered) {
        $params->{qf} = join ' ', @filtered;
      }
      else {
        $params->{qf} = '_text_';
      }
    }
    if (defined $params->{df} && $params->{df} eq 'extracted_text') {
      delete $params->{df};
    }
  }

  # Set default fl if not provided - only return fields needed by frontend
  my $default_fl
    = 'pid,owner,dc_title,dc_title_eng,dc_title_deu,dc_title_ita,dc_description,dc_description_eng,dc_description_deu,dc_description_ita,created,cmodel,bib_roles_pers_aut,bib_roles_pers_edt,bib_roles_pers_cmp,bib_roles_pers_art,bib_roles_corp_aut,isrestricted,dc_rights,systemtag,bf_shelfmark,dc_subject';

  unless (defined $params->{fl}) {
    $params->{fl} = $default_fl;
  }

  my @book_pids;
  my %book_seen;
  my $hit_facet_limit = 0;
  if ($include_extracted) {
    my $original_q = $params->{q} // '';

    my $pages_url = Mojo::URL->new;
    $pages_url->scheme($self->app->config->{solr}->{scheme});
    $pages_url->host($self->app->config->{solr}->{host});
    $pages_url->port($self->app->config->{solr}->{port});
    my $pages_core = 'phaidra_pages';
    if ($self->app->config->{solr}->{path}) {
      $pages_url->path("/" . $self->app->config->{solr}->{path} . "/solr/$pages_core/select");
    }
    else {
      $pages_url->path("/solr/$pages_core/select");
    }

    my $facet_limit = 1000;                                                                        # Limit for book pids not for pages
    my $json_facet  = '{"parents":{"terms":{"field":"ispartof","limit":' . $facet_limit . '}}}';
    my $pages_query = 'extracted_text:(' . $original_q . ')';
    $pages_url->query(q => $pages_query, rows => 0, wt => 'json', 'json.facet' => $json_facet);
    $self->app->log->debug('Pages presearch URL (facet): ' . $pages_url->to_string);

    my $ua        = Mojo::UserAgent->new;
    my $pages_res = $ua->get($pages_url)->result;
    if (!$pages_res->is_success) {
      $self->app->log->error('Pages presearch (facet) failed: ' . $pages_res->message);
    }
    else {
      my $json = $pages_res->json;
      if ($json->{facets} && $json->{facets}->{parents} && $json->{facets}->{parents}->{buckets}) {
        my $buckets      = $json->{facets}->{parents}->{buckets};
        my $bucket_count = scalar @$buckets;

        # Check if we hit the facet limit
        if ($bucket_count == $facet_limit) {
          $hit_facet_limit = 1;
          $self->app->log->debug("Hit facet limit of $facet_limit, indicating all books queried");
        }
        for my $b (@$buckets) {
          my $bp = $b->{val};
          next unless defined $bp;
          next if $book_seen{$bp}++;
          push @book_pids, $bp;
        }
      }
    }

    my @query_parts;

    if (@book_pids) {
      my $books_pid_clause = join ' OR ', map {'pid:"' . $_ . '"'} @book_pids;
      push @query_parts, '(' . $books_pid_clause . ')';
    }

    my $pdf_clause = 'extracted_text:(' . $original_q . ')';
    push @query_parts, '(' . $pdf_clause . ')';

    my $metadata_clause = '_text_:(' . $original_q . ')';
    push @query_parts, '(' . $metadata_clause . ')';

    my $combined_q = join ' OR ', @query_parts;
    $params->{q} = $combined_q;
    $self->app->log->info('Combined query (books OR PDFs OR metadata): ' . $combined_q);
    $self->app->log->info('Book PIDs found: ' . scalar(@book_pids));

    unless (defined $params->{sort} && $params->{sort} ne '') {
      $params->{sort} = 'created desc';
      $self->app->log->info('Setting default sort: created desc');
    }
  }

  if (Mojo::IOLoop->is_running) {
    $self->render_later;
    $self->ua->post(
      $url => form => $params,
      sub {
        my ($c, $tx) = @_;
        _proxy_tx($self, $tx, $hit_facet_limit);
      }
    );
  }
  else {
    my $tx = $self->ua->post($url => form => $params);
    _proxy_tx($self, $tx, $hit_facet_limit);
  }

}

sub _proxy_tx {
  my ($self, $tx, $hit_facet_limit) = @_;
  if (!$tx->error) {
    my $res = $tx->res;
    $self->tx->res($res);

    # Show warning only if we hit the limit AND there are books in the filtered results
    if ($hit_facet_limit) {
      my $json       = $res->json;
      my $book_count = $json->{facet_counts}->{facet_queries}->{'resourcetype:book'} || 0;
      if ($book_count > 0) {
        $self->tx->res->headers->add('X-Query-Scope', 'all-books');
      }
    }

    $self->rendered;
  }
  else {
    my $error = $tx->error;
    $self->tx->res->headers->add('X-Remote-Status', $error->{code} . ': ' . $error->{message});
    $self->render(status => 500, text => 'Failed to fetch data from backend');
  }
}
1;

