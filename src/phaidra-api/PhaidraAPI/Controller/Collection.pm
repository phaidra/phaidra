package PhaidraAPI::Controller::Collection;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(encode decode);
use Mojo::ByteStream qw(b);
use PhaidraAPI::Model::Collection;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Membersorder;
use Time::Local;
use HTML::Entities;
use Mojo::URL;
use DateTime;
use DateTime::Format::Mail;
use DateTime::Format::ISO8601;

sub descendants {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $pid = $self->stash('pid');

  my $ua = Mojo::UserAgent->new;

  my $urlget = Mojo::URL->new;
  $urlget->scheme($self->app->config->{solr}->{scheme});
  $urlget->host($self->app->config->{solr}->{host});
  $urlget->port($self->app->config->{solr}->{port});
  if ($self->app->config->{solr}->{path}) {
    $urlget->path("/" . $self->app->config->{solr}->{path} . "/solr/" . $self->app->config->{solr}->{core} . "/select");
  }
  else {
    $urlget->path("/solr/" . $self->app->config->{solr}->{core} . "/select");
  }

  my $root;
  $urlget->query(q => "*:*", fq => "pid:\"$pid\"", rows => "1", wt => "json");
  my $getres = $ua->get($urlget)->result;
  if ($getres->is_success) {
    for my $d (@{$getres->json->{response}->{docs}}) {

      # $self->app->log->debug("[$pid] got root doc");
      $root = $d;
      last;
    }
  }
  else {
    my $err = "[$pid] error getting root doc from solr: " . $getres->code . " " . $getres->message;
    $self->app->log->error($err);
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};
    $res->{status} = $getres->code ? $getres->code : 500;
    return $res;
  }

  $self->descendants_rec($ua, $urlget, $root, $pid);

  $res->{descendants} = {root => $root};

  $self->render(json => $res, status => $res->{status});
}

sub descendants_rec {
  my ($self, $ua, $urlget, $currentNode, $path) = @_;

  # $self->app->log->debug("[$path] querying children of $currentNode->{pid}");
  $currentNode->{children} = [];

  # we're only looking for collections, so it's not necessary to query numFound first (shouldn't be too many)
  $urlget->query(q => "*:*", fq => "ispartof:\"$currentNode->{pid}\" AND cmodel:\"Collection\"", rows => "1000000", wt => "json");
  my $getres = $ua->get($urlget)->result;
  if ($getres->is_success) {
    for my $d (@{$getres->json->{response}->{docs}}) {
      push @{$currentNode->{children}}, $d;
      $self->descendants_rec($ua, $urlget, $d, $path . ' > ' . $d->{pid});
    }
  }
  else {
    $self->app->log->error("[$path] [$currentNode->{pid}] error getting children from solr: " . $getres->code . " " . $getres->message);
  }
}

sub add_collection_members {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $pid = $self->stash('pid');

  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};
  unless (defined($metadata->{members})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No members sent'}]}, status => 400);
    return;
  }
  my $members = $metadata->{members};

  my $members_size = scalar @{$members};
  if ($members_size eq 0) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No members provided'}]}, status => 400);
    return;
  }

  # add members
  my @relationships;
  foreach my $member (@{$members}) {
    push @relationships, {predicate => "info:fedora/fedora-system:def/relations-external#hasCollectionMember", object => "info:fedora/" . $member->{pid}};
  }
  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->add_relationships($self, $pid, \@relationships, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;

  $res->{status} = $r->{status};
  if ($r->{status} ne 200) {
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my $order_available = 0;
  for my $m_ord (@{$members}) {
    if (exists($m_ord->{pos})) {
      $order_available = 1;
      last;
    }
  }

  if ($order_available) {

    # this should now also contain the new members
    my $coll_model = PhaidraAPI::Model::Collection->new;
    my $res        = $coll_model->get_members($self, $pid);
    for my $m (@{$res->{members}}) {
      for my $m_ord (@{$members}) {
        if ($m->{pid} eq $m_ord->{pid}) {
          if (exists($m_ord->{pos})) {
            $m->{pos} = $m_ord->{pos};
          }
        }
      }
    }

    my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
    my $r                  = $membersorder_model->save_to_object($self, $pid, $res->{members}, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);
    push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
    $res->{status} = $r->{status};
    if ($r->{status} ne 200) {
      $self->render(json => $res, status => $res->{status});
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub remove_collection_members {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $pid      = $self->stash('pid');
  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};
  unless (defined($metadata->{members})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No members sent'}]}, status => 400);
    return;
  }
  my $members = $metadata->{members};

  my $members_size = scalar @{$members};
  if ($members_size eq 0) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No members provided'}]}, status => 400);
    return;
  }

  # remove members
  my @relationships;
  foreach my $member (@{$members}) {
    push @relationships, {predicate => "info:fedora/fedora-system:def/relations-external#hasCollectionMember", object => "info:fedora/" . $member->{pid}};
  }
  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->purge_relationships($self, $pid, \@relationships, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  # FIXME: remove from COLLECTIONORDER
  my $search_model = PhaidraAPI::Model::Search->new;
  my $r2           = $search_model->datastreams_hash($self, $pid);
  if ($r2->{status} ne 200) {
    return $r2;
  }

  if (exists($r2->{dshash}->{'COLLECTIONORDER'})) {

    # this should not contain the deleted members anymore
    my $coll_model = PhaidraAPI::Model::Collection->new;
    my $res        = $coll_model->get_members($self, $pid);

    my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
    my $r3                 = $membersorder_model->save_to_object($self, $pid, $res->{members}, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);
    push @{$res->{alerts}}, @{$r3->{alerts}} if scalar @{$r3->{alerts}} > 0;
    $res->{status} = $r3->{status};
    if ($r3->{status} ne 200) {
      $self->render(json => $res, status => $res->{status});
    }
  }

  $self->render(json => $r, status => $r->{status});

}

sub get_collection_members {

  my $self = shift;

  my $pid     = $self->stash('pid');
  my $nocache = $self->param('nocache');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $coll_model = PhaidraAPI::Model::Collection->new;
  my $res        = $coll_model->get_members($self, $pid, $nocache);

  $self->render(json => {alerts => $res->{alerts}, metadata => {members => $res->{members}}}, status => $res->{status});
}

sub create {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};
  my $members;
  unless (defined($metadata->{members})) {
    $self->app->log->debug('No members sent');
  }
  else {
    $members = $metadata->{members};
  }

  my $coll_model = PhaidraAPI::Model::Collection->new;
  my $r          = $coll_model->create($self, $metadata, $members, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  push @{$r->{alerts}}, @{$res->{alerts}} if scalar @{$res->{alerts}} > 0;

  $self->render(json => $r, status => $r->{status});
}

# Helper method to call Solr
sub call_solr {
  my ($self, $params) = @_;
  
  my $url = Mojo::URL->new;
  $url->scheme($self->app->config->{solr}->{scheme});
  $url->host($self->app->config->{solr}->{host});
  $url->port($self->app->config->{solr}->{port});
  my $core = $self->app->config->{solr}->{core};
  if ($self->app->config->{solr}->{path}) {
    $url->path("/" . $self->app->config->{solr}->{path} . "/solr/$core/select");
  }
  else {
    $url->path("/solr/$core/select");
  }

  my $tx = $self->ua->post($url => form => $params);
  if ($tx->error) {
    my $error = $tx->error;
    $self->app->log->error("Failed to get data from Solr: " . $error->{code} . ": " . $error->{message});
    return {status => 500, error => $error->{message}};
  }

  return {status => 200, data => $tx->res->json};
}

sub rss {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->app->log->error("RSS feed error: Undefined pid");
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $pid = $self->stash('pid');
  $self->app->log->debug("Generating RSS feed for collection: $pid");

  # Get collection details from Solr
  my $collection_solr_params = {
    q => "pid:$pid",
    defType => 'edismax',
    wt => 'json',
    start => 0,
    rows => 1
  };

  my $collection_solr_res = $self->call_solr($collection_solr_params);
  if ($collection_solr_res->{status} ne 200) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Failed to get collection details from Solr'}]}, status => $collection_solr_res->{status});
    return;
  }

  # Get member details from Solr
  my $members_solr_params = {
    q => '-hassuccessor:* AND -ismemberof:["" TO *]',
    defType => 'edismax',
    wt => 'json',
    fq => "owner:* AND ispartof:\"$pid\"",
    start => 0,
    rows => 1000,
    sort => "pos_in_$pid asc"
  };

  my $members_solr_res = $self->call_solr($members_solr_params);
  if ($members_solr_res->{status} ne 200) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Failed to get member details from Solr'}]}, status => $members_solr_res->{status});
    return;
  }

  # Build RSS feed
  my $feed;
  my $collection_created = $collection_solr_res->{data}->{response}->{docs}[0]->{tcreated}[0];      
  my $collection_dt = DateTime->from_epoch(epoch => DateTime::Format::ISO8601->parse_datetime($collection_created)->epoch);
  my $rfc822_date = DateTime::Format::Mail->format_datetime($collection_dt) =~ s/\+0000/GMT/r =~ s/,  /, /r;
  eval {
    my $now = time;
    # my $rfc822_date = $self->format_rfc822_date(scalar gmtime($now));
    
    $feed = qq{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>}.xml_escape($self,$collection_solr_res->{data}->{response}->{docs}[0]->{dc_title}[0]).qq{</title>
    <link>}.$self->url_for("/detail/$pid")->to_abs.qq{</link>
    <atom:link href="}.$self->url_for("/api/collection/$pid/rss")->to_abs.qq{" rel="self" type="application/rss+xml" />
    <description>}.xml_escape($self,$collection_solr_res->{data}->{response}->{docs}[0]->{dc_description}[0]).qq{</description>
    <language>en-us</language>
    <pubDate>}.$rfc822_date.qq{</pubDate>
};

    # Add items from Solr results
    foreach my $doc (@{$members_solr_res->{data}->{response}->{docs}}) {
      my $member_title = $doc->{dc_title}[0] || $doc->{pid};
      my $description = $doc->{dc_description}[0] ? "Description: " . $doc->{dc_description}[0] : "";
      my $created = $doc->{tcreated}[0];      
      my $dt = DateTime->from_epoch(epoch => DateTime::Format::ISO8601->parse_datetime($created)->epoch);
      my $rfc822_date = DateTime::Format::Mail->format_datetime($dt) =~ s/\+0000/GMT/r =~ s/,  /, /r;
      
      $feed .= qq{
    <item>
      <title>}.xml_escape($self,$member_title).qq{</title>
      <link>}.$self->url_for("/detail/".$doc->{pid})->to_abs.qq{</link>
      <guid>}.$self->url_for("/detail/".$doc->{pid})->to_abs.qq{</guid>};
      
      if ($description) {
        $feed .= qq{
      <description>}.xml_escape($self,$description).qq{</description>};
      }
      
      $feed .= qq{
      <pubDate>$rfc822_date</pubDate>
    </item>};
    }

    $feed .= qq{
  </channel>
</rss>};
  };
  
  if ($@) {
    my $error_msg = "Error generating RSS feed: $@";
    $self->app->log->error("RSS feed error for $pid: $error_msg");
    $self->render(json => {alerts => [{type => 'error', msg => $error_msg}]}, status => 500);
    return;
  }

  # Return RSS feed
  $self->res->headers->content_type('application/rss+xml');
  $self->render(text => $feed);
}

# Helper to format dates in RFC822 format required by RSS
sub format_rfc822_date {
  my ($self, $date) = @_;
  return '' unless $date;
  
  eval {
    # Convert ISO 8601 to RFC822 format
    # Example: 2024-02-20T12:34:56.178Z -> Tue, 20 Feb 2024 12:34:56 GMT
    if ($date =~ /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d+)?Z$/) {
      my ($year, $month, $day, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
     
      my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
      my @days = qw(Sun Mon Tue Wed Thu Fri Sat);
      my $time = Time::Local::timegm($sec, $min, $hour, $day, $month-1, $year);
      my ($wday) = (gmtime($time))[6];
      my $formatted = sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT", 
                    $days[$wday], $day, $months[$month-1], $year, $hour, $min, $sec);
      return $formatted;
    }
    $self->app->log->warn("Invalid date format: $date");
    return '';
  };
  
  if ($@) {
    $self->app->log->warn("Error formatting date '$date': $@");
    return '';
  }
}

# Helper to escape XML special characters
sub xml_escape {
  my ($self, $text) = @_;
  return '' unless defined $text;
  return encode_entities($text, '<>&"');
}

1;
