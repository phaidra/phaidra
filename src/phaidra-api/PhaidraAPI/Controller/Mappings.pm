package PhaidraAPI::Controller::Mappings;

use strict;
use warnings;
use v5.10;
use Switch;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Jsonld;
use PhaidraAPI::Model::Mappings::Edm;
use PhaidraAPI::Model::Mappings::Lom;
use PhaidraAPI::Model::Mappings::Openaire;
use Mojo::JSON qw(encode_json decode_json);

sub get {
  my $self = shift;

  my $schema = $self->stash('schema');
  unless ($schema eq 'openaire' or $schema eq 'lom' or $schema eq 'edm') {
    $self->render(json => {alerts => [{type => 'error', msg => 'Unknown schema'}]}, status => 400);
    return;
  }

  my $pid = $self->stash('pid');
  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $res = {alerts => [], status => 200};

  my $md;
  my $urlget = Mojo::URL->new;
  $urlget->scheme($self->config->{solr}->{scheme});
  $urlget->host($self->config->{solr}->{host});
  $urlget->port($self->config->{solr}->{port});
  my $core = $self->config->{solr}->{core};
  if ($self->config->{solr}->{path}) {
    $urlget->path("/" . $self->config->{solr}->{path} . "/solr/$core/select");
  }
  else {
    $urlget->path("/solr/$core/select");
  }
  $urlget->query(q => "*:*", fq => "pid:\"$pid\"", rows => "1", wt => "json");
  my $r = $self->ua->get($urlget)->result;
  if ($r->is_success) {
    for my $d (@{$r->json->{response}->{docs}}) {
      $md = $d;
    }
  }
  else {
    my $err = "[$pid] error getting solr doc for object[$pid]: " . $r->code . " " . $r->message;
    $self->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }


  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $res          = $jsonld_model->get_object_jsonld_parsed($self, $pid);
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
    return;
  }

  $md->{jsonld} = $res->{'JSON-LD'};

  my $metadata;
  switch ($schema) {
    case 'openaire' {
      my $oaire_model = PhaidraAPI::Model::Mappings::Openaire->new;
      $metadata = $oaire_model->get_metadata($self, $md);
    }
    case 'edm' {
      my $edm_model = PhaidraAPI::Model::Mappings::Edm->new;
      $metadata = $edm_model->get_metadata($self, $md);
    }
    case 'lom' {
      my $lom_model = PhaidraAPI::Model::Mappings::Lom->new;
      $metadata = $lom_model->get_metadata($self, $md);
    }
  }

  # $self->app->log->debug($self->app->dumper($metadata));

  $self->stash(metadata => $metadata);
  $self->render(template => 'oai/metadata', format => 'xml', handler => 'ep');
  return;
}

1;
