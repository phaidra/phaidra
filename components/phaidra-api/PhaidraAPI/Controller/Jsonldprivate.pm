package PhaidraAPI::Controller::Jsonldprivate;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Jsonld;
use PhaidraAPI::Model::Util;
use Time::HiRes qw/tv_interval gettimeofday/;
use Data::UUID;

sub get {
  my $self = shift;

  my $pid = $self->stash('pid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;

  # do not use admin/intcall credentials here!
  $object_model->proxy_datastream($self, $pid, 'JSON-LD-PRIVATE', $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  return;
}

sub post {
  my $self = shift;

  my $t0 = [gettimeofday];

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
    $self->render(json => {alerts => [{type => 'error', msg => $@}]}, status => 400);
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  unless (defined($metadata->{'json-ld-private'}) || $metadata->{'JSON-LD-PRIVATE'}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No JSON-LD-PRIVATE sent'}]}, status => 400);
    return;
  }

  my $jsonld;
  if (defined($metadata->{'json-ld-private'})) {
    $jsonld = $metadata->{'json-ld-private'};
  }
  else {
    $jsonld = $metadata->{'JSON-LD-PRIVATE'};
  }

  my $jsonldprivate_model = PhaidraAPI::Model::Jsonldprivate->new;
  my $res                 = $jsonldprivate_model->save_to_object($self, $pid, $jsonld, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);

  my $t1 = tv_interval($t0);
  if ($res->{status} eq 200) {
    unshift @{$res->{alerts}}, {type => 'success', msg => "JSON-LD-PRIVATE for $pid saved successfully ($t1 s)"};
  }

  $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
}

1;
