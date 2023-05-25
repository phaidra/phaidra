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
    push @{$res->{alerts}}, {type => 'warning', msg => 'No members sent'};
  }
  else {
    $members = $metadata->{members};
  }

  my $coll_model = PhaidraAPI::Model::Collection->new;
  my $r          = $coll_model->create($self, $metadata, $members, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  push @{$r->{alerts}}, $res->{alerts} if scalar @{$res->{alerts}} > 0;

  $self->render(json => $r, status => $r->{status});
}

1;
