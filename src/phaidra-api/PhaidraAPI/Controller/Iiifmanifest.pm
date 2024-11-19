package PhaidraAPI::Controller::Iiifmanifest;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Iiifmanifest;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Search;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Time::HiRes qw/tv_interval gettimeofday/;

sub get_iiif_manifest {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}], status => 404}, status => 404);
    return;
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $rdshash = $search_model->datastreams_hash($self, $pid);
  if ($rdshash->{status} ne 200) {
    $self->render(json => {alerts => [{type => 'error', msg => "get_iiif_manifest pid[$pid] Error getting datastreams_hash"}], status => $rdshash->{status}}, status => $rdshash->{status});
    return;
  } else {
    if (exists($rdshash->{dshash}->{'IIIF-MANIFEST'})) {
      my $object_model = PhaidraAPI::Model::Object->new;
      $object_model->proxy_datastream($self, $pid, 'IIIF-MANIFEST', $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 1);
      return;
    } else {
      my $cmodelr      = $search_model->get_cmodel($self, $pid);
      if ($cmodelr->{status} ne 200) {
        $self->render(json => {alerts => [{type => 'error', msg => "get_iiif_manifest pid[$pid] Error getting cmodel"}], status => $cmodelr->{status}}, status => $cmodelr->{status});
        return;
      }
      if ($cmodelr->{cmodel} eq 'Picture') {
        my $iiifm_model = PhaidraAPI::Model::Iiifmanifest->new;
        my $r = $iiifm_model->generate_simple_manifest($self, $pid);
        $self->render(json => $r->{manifest}, status => $res->{status});
      } else {
        $self->render(json => {alerts => [{type => 'error', msg => "get_iiif_manifest pid[$pid] This object has no IIIF manifest"}], status => 400}, status => 400);
        return;
      }
    }
  }
}

sub update_manifest_metadata {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');

  my $iiifm_model = PhaidraAPI::Model::Iiifmanifest->new;
  my $r           = $iiifm_model->update_manifest_metadata($self, $pid);
  if ($r->{status} ne 200) {

    # just log but don't change status, this isn't fatal
    push @{$res->{alerts}}, {type => 'error', msg => 'Error updating IIIF-MANIFEST metadata'};
    push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
  }

  $self->render(json => $res, status => $res->{status});
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

  unless (defined($metadata->{'iiif-manifest'}) || defined($metadata->{'IIIF-MANIFEST'})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No IIIF-MANIFEST sent'}]}, status => 400);
    return;
  }

  my $manifest;
  if (defined($metadata->{'iiif-manifest'})) {
    $manifest = $metadata->{'iiif-manifest'};
  }
  else {
    $manifest = $metadata->{'IIIF-MANIFEST'};
  }

  my $iiif_model = PhaidraAPI::Model::Iiifmanifest->new;
  my $res        = $iiif_model->save_to_object($self, $pid, $manifest, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);

  my $t1 = tv_interval($t0);
  if ($res->{status} eq 200) {
    unshift @{$res->{alerts}}, {type => 'success', msg => "IIIF-MANIFEST for $pid saved successfully ($t1 s)"};
  }

  $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
}

1;
