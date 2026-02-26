package PhaidraAPI::Controller::Search;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Fedora;
use Encode qw(decode);
use List::Util qw(first);

sub triples {
  my $self = shift;

  my $query = $self->param('q');
  my $limit = $self->param('limit');

  my $search_model = PhaidraAPI::Model::Search->new;
  my $sr           = $search_model->triples($self, $query, $limit);

  $self->render(json => $sr, status => $sr->{status});
}

sub id {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $sr           = $search_model->triples($self, "<info:fedora/" . $self->stash('pid') . "> <http://purl.org/dc/terms/identifier> *", 0);

  $res->{alerts} = $sr->{alerts};
  $res->{status} = $sr->{status};

  my @ids;
  for my $triple (@{$sr->{result}}) {
    my $id = @$triple[2];
    $id =~ s/^\<+|\>+$//g;
    push @ids, $id;
  }

  $res->{ids} = \@ids;

  $self->render(json => $res, status => $res->{status});
}

sub related {

  my $self = shift;
  my $relation;
  my $from  = 1;
  my $limit = 10;
  my $right = 0;
  my @fields;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  if (defined($self->param('relation'))) {
    $relation = $self->param('relation');
  }
  else {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined relation'}]}, status => 400);
    return;
  }

  if (defined($self->param('from'))) {
    $from = $self->param('from');
  }

  if (defined($self->param('limit'))) {
    $limit = $self->param('limit');
  }

  if (defined($self->param('right'))) {
    $right = $self->param('right');
  }

  if (defined($self->param('fields'))) {
    @fields = $self->every_param('fields');
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $r;
  
  if (@fields) {
    $r = $search_model->related($self, $self->stash('pid'), $relation, $right, $from, $limit, @fields);
  }
  else {
    $r = $search_model->related($self, $self->stash('pid'), $relation, $right, $from, $limit, undef);
  }

  #$self->app->log->debug($self->app->dumper($r));
  $self->render(json => $r, status => $r->{status});

}

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

  my $apiBaseUrlPath = $self->app->config->{scheme} . '://' . $self->app->config->{baseurl}. ($self->app->config->{basepath} ? '/' . $self->app->config->{basepath} : '');

  my $query = $self->param('q');
  my $pid = $self->stash('pid');
  
  # Get start parameter for pagination (defaults to 0)
  my $start = $self->param('start') // 0;
  $start = int($start);
  
  # Step 1: Query phaidra core to get page PIDs from haspart field
  my $url = Mojo::URL->new;
  $url->scheme($self->app->config->{solr}->{scheme});
  $url->host($self->app->config->{solr}->{host});
  $url->port($self->app->config->{solr}->{port});
  
  my $phaidra_core = 'phaidra';
  if ($self->app->config->{solr}->{path}) {
    $url->path("/" . $self->app->config->{solr}->{path} . "/solr/$phaidra_core/select");
  }
  else {
    $url->path("/solr/$phaidra_core/select");
  }
   # log pid
   $self->app->log->debug("Searching for page PIDs for object $pid");
   # Escape the PID for Solr query - quote it to handle colons and special characters
   my $escaped_pid = "\"$pid\"";
   $url->query(q => "pid:$escaped_pid", fl => "haspart", rows => 1000, wt => "json");
   $self->app->log->debug("Query: " . $url->to_string);
  my $ua = Mojo::UserAgent->new;
  my $get = $ua->get($url)->result;
  $self->app->log->debug("Response: " . $get->body);
  if (!$get->is_success) {
    $self->render(json => {error => "Failed to get page PIDs: " . $get->message}, status => 500);
    return;
  }
  
  my $phaidra_response = $get->json;
  my @page_pids = ();
  
  # Extract page PIDs from haspart field
  if ($phaidra_response->{response} && $phaidra_response->{response}->{docs} && @{$phaidra_response->{response}->{docs}}) {
    my $haspart = $phaidra_response->{response}->{docs}->[0]->{haspart};
    if ($haspart) {
      if (ref($haspart) eq 'ARRAY') {
        @page_pids = @$haspart;
      } else {
        @page_pids = ($haspart);
      }
    }
  }
  
  if (!@page_pids) {
    $self->render(json => {error => "No pages found for object $pid"}, status => 404);
    return;
  }
  
  # Step 2: Find which pages contain matches (scalable approach)
  my $page_pids_query = join(' OR ', map { "pid:\"$_\"" } @page_pids);
  # Whole-word, case-insensitive match in Solr: use a quoted term
  # Escape embedded quotes in the query
  my $escaped_q = $query // '';
  $escaped_q =~ s/([+\-&|!(){}[\]^"~:\\\/])/\\$1/g;
  # Use wildcard query for compatibility with newer Solr versions
  # Search specifically in extracted_text (OCR text stored in phaidra_pages core)
  my $search_query = "($page_pids_query) AND extracted_text:(*$escaped_q*)";
  
  $url = Mojo::URL->new;
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
  
  # First get total count of matching pages (scalable)
  $url->query(q => $search_query, fl => "pid", rows => 0, wt => "json");
  $self->app->log->debug("Count Query: " . $url->to_string);
  
  $get = $ua->get($url)->result;
  $self->app->log->debug("Count Response: " . $get->body);
  
  my $total_matching_pages = 0;
  if ($get->is_success) {
    my $count_response = $get->json;
    $total_matching_pages = $count_response->{response}->{numFound} || 0;
  }
  
  if ($total_matching_pages == 0) {
    # No matches found - return empty result
    my $response_json = {
        '@context' => [
            'http://iiif.io/api/presentation/2/context.json',
            'http://iiif.io/api/search/1/context.json'
        ],
        '@id' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$start",
        '@type' => 'sc:AnnotationList',
        'resources' => [],
        'hits' => [],
        'within' => {
            '@type' => 'sc:Layer',
            'total' => 0,
            'first' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=0",
            'last' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=0"
        },
        'startIndex' => $start
    };
    $self->render(json => $response_json, status => 200);
    return;
  }
  
  # Step 3: Get the current page using Solr pagination (scalable)
  my $pages_per_request = 1;  # Show one page at a time
  my $current_page_index = int($start / $pages_per_request);
  my $last_page_start = ($total_matching_pages - 1) * $pages_per_request;
  
  # Validate page index
  if ($current_page_index >= $total_matching_pages) {
    $self->render(json => {error => "Page index out of range"}, status => 400);
    return;
  }
  
  # Get the current page PID using true cursor-based pagination (scalable to unlimited pages)
  # We'll use a more efficient approach that doesn't load all pages into memory
  
  # Create a mapping of page PIDs to their position in the original order
  my %page_position_map = ();
  for (my $i = 0; $i < @page_pids; $i++) {
    $page_position_map{$page_pids[$i]} = $i;
  }
  
  # Use Solr's built-in pagination with a sortable field
  # We'll sort by PID which should give us consistent ordering
  $url->query(q => $search_query, fl => "pid", start => $current_page_index, rows => 1, wt => "json", sort => "pid asc");
  $self->app->log->debug("Current Page Query: " . $url->to_string);
  
  $get = $ua->get($url)->result;
  $self->app->log->debug("Current Page Response: " . $get->body);
  
  if (!$get->is_success) {
    $self->render(json => {error => $get->message}, status => 500);
    return;
  }
  
  my $page_response = $get->json;
  if (!$page_response->{response} || !$page_response->{response}->{docs} || @{$page_response->{response}->{docs}} == 0) {
    $self->render(json => {error => "No page found for index $current_page_index"}, status => 404);
    return;
  }
  
  # Get the current page PID from Solr's paginated result
  my $current_page_pid = $page_response->{response}->{docs}->[0]->{pid};
  
  # Find the page number (1-indexed position in original book)
  my $page_number = 0;
  my $page_index = first { $page_pids[$_] eq $current_page_pid } 0..$#page_pids;
  if (defined $page_index) {
    $page_number = $page_index + 1;
  }
  
  $self->app->log->debug("Processing page $current_page_index of $total_matching_pages matching pages (PID: $current_page_pid, book page: $page_number)");
  
  # Step 4: Process the current page and get all its matches
  my $fedora_model = PhaidraAPI::Model::Fedora->new;
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
  my @annotations = ();
  my @hits = ();
  my $annotation_id = 1;
  
  my @alto_strings = $dom->find('String')->each;
  
  # Find matches and get context from surrounding String elements
  for (my $i = 0; $i < @alto_strings; $i++) {
    my $string_element = $alto_strings[$i];
    my $element_text = $string_element->attr('CONTENT') || '';
    
    # Whole-word, case-insensitive match within the token (handles trailing punctuation like "time.")
    if ($element_text =~ /\b\Q$query\E\b/i) {
      # Get coordinates for this match
      my $hpos = $string_element->attr('HPOS') || 0;
      my $vpos = $string_element->attr('VPOS') || 0;
      my $width = $string_element->attr('WIDTH') || 0;
      my $height = $string_element->attr('HEIGHT') || 0;
      
      # Build context from surrounding String elements
      my $before_text = '';
      my $after_text = '';
      
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
      $after_text =~ s/\s+/ /g;
      $before_text =~ s/^\s+|\s+$//g;
      $after_text =~ s/^\s+|\s+$//g;
      
      # Create annotation for this match (IIIF Search API 1.0 format)
      my $annotation = {
        '@id' => "$apiBaseUrlPath/iiif/$pid/canvas/$page_number/text/at/". ($hpos || 0) . "," . 
                ($vpos || 0) . "," . 
                ($width || 0) . "," . 
                ($height || 0),
        '@type' => 'oa:Annotation',
        'motivation' => 'sc:painting',
        'resource' => {
          '@type' => 'cnt:ContentAsText',
          'chars' => $element_text
        },
        'on' => "$apiBaseUrlPath/iiif/$pid/canvas/$page_number#xywh=" . 
                ($hpos || 0) . "," . 
                ($vpos || 0) . "," . 
                ($width || 0) . "," . 
                ($height || 0)
      };
      push @annotations, $annotation;
      
      # Create hit for this match
      my $hit = {
        '@type' => 'search:Hit',
        'annotations' => ["$apiBaseUrlPath/iiif/$pid/canvas/$page_number/text/at/". ($hpos || 0) . "," . 
                ($vpos || 0) . "," . 
                ($width || 0) . "," . 
                ($height || 0)],
        'before' => $before_text,
        'after' => $after_text,
        'match' => $query
      };
      push @hits, $hit;
      
      $annotation_id++;
    }
  }
  
  # Create response with page-based pagination
  my $response_json = {
      '@context' => [
          'http://iiif.io/api/presentation/2/context.json',
          'http://iiif.io/api/search/1/context.json'
      ],
      '@id' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$start",
      '@type' => 'sc:AnnotationList',
      'resources' => \@annotations,
      'hits' => \@hits,
      'within' => {
          '@type' => 'sc:Layer',
          'total' => $total_matching_pages,  # Total number of pages with matches
          'first' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=0",
          'last' => "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$last_page_start"
      },
      'startIndex' => $start
  };
  
  # Add next/prev links for page navigation
  if ($current_page_index < $total_matching_pages - 1) {
      my $next_start = $start + $pages_per_request;
      $response_json->{'next'} = "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$next_start";
  }
  
  if ($current_page_index > 0) {
      my $prev_start = $start - $pages_per_request;
      if ($prev_start < 0) { $prev_start = 0; }
      $response_json->{'prev'} = "$apiBaseUrlPath/search/$pid/ocr?q=$query&start=$prev_start";
  }
  
  $self->render(json => $response_json, status => 200);
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

  my $params = $self->req->params->to_hash;
  my $include_extracted = defined $params->{extracted_text} && $params->{extracted_text} eq 'include';
  delete $params->{extracted_text};
  if ($include_extracted) {
    if (defined $params->{qf}) {
      my @qf_parts = split /\s+/, $params->{qf};
      my @filtered = grep { $_ !~ /^(?:dc_identifier)(\^\S+)?$/ } @qf_parts;
      my $has_extracted = 0;
      my $has_text = 0;
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
      my @filtered = grep { $_ !~ /^extracted_text(\^\S+)?$/ } @qf_parts;
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

  my $default_fl = 'pid,dc_title,dc_title_eng,dc_title_deu,dc_title_ita,dc_description,dc_description_eng,dc_description_deu,dc_description_ita,created,cmodel,bib_roles_pers_aut,bib_roles_pers_edt,bib_roles_pers_cmp,bib_roles_pers_art,isrestricted,dc_rights';
  
  if (defined $params->{fl} && $params->{fl} ne '') {
    my $fl_value = $params->{fl};
    if ($fl_value =~ /\*/) {
      $params->{fl} = '*,-extracted_text,-haspart,-hasmember';
    } else {
      my @fl_parts = split /[\s,]+/, $fl_value;
      my @filtered_fl = grep { 
        $_ ne 'extracted_text' && 
        $_ ne 'haspart' && 
        $_ ne 'hasmember' &&
        $_ !~ /^extracted_text\^/ &&
        $_ !~ /^haspart\^/ &&
        $_ !~ /^hasmember\^/ &&
        $_ !~ /^-extracted_text/ &&
        $_ !~ /^-haspart/ &&
        $_ !~ /^-hasmember/
      } @fl_parts;
      if (@filtered_fl) {
        $params->{fl} = join ' ', @filtered_fl;
      } else {
        $params->{fl} = $default_fl;
      }
    }
  } else {
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

    my $facet_limit = 1000; # Limit for book pids not for pages
    my $json_facet = '{"parents":{"terms":{"field":"ispartof","limit":' . $facet_limit . '}}}';
    my $pages_query = 'extracted_text:(' . $original_q . ')';
    $pages_url->query(q => $pages_query, rows => 0, wt => 'json', 'json.facet' => $json_facet);
    $self->app->log->debug('Pages presearch URL (facet): ' . $pages_url->to_string);

    my $ua = Mojo::UserAgent->new;
    my $pages_res = $ua->get($pages_url)->result;
    if (!$pages_res->is_success) {
      $self->app->log->error('Pages presearch (facet) failed: ' . $pages_res->message);
    } else {
      my $json = $pages_res->json;
      if ($json->{facets} && $json->{facets}->{parents} && $json->{facets}->{parents}->{buckets}) {
        my $buckets = $json->{facets}->{parents}->{buckets};
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
      my $books_pid_clause = join ' OR ', map { 'pid:"' . $_ . '"' } @book_pids;
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
      my $json = $res->json;
      my $book_count = $json->{facet_counts}->{facet_queries}->{'resourcetype:book'} || 0;
      if ($book_count > 0) {
        $self->tx->res->headers->add('X-Query-Scope', 'all-books');
      }
    }
    
    $self->rendered;
  }
  else {
    my $error = $tx->error;
    $self->tx->res->headers->add('X-Remote-Status',
      $error->{code} . ': ' . $error->{message});
    $self->render(status => 500, text => 'Failed to fetch data from backend');
  }
}
1;

