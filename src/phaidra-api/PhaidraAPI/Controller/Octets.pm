package PhaidraAPI::Controller::Octets;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::Util qw(url_escape encode);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Util;

sub proxy {
  my $self = shift;

  my $pid = $self->stash('pid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  $object_model->proxy_datastream($self, $pid, 'OCTETS', $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
}

sub get {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');
  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  my $operation = $self->stash('operation');
  unless (defined($operation)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined operation'}]}, status => 400);
    return;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $authzres    = $authz_model->check_rights($self, $pid, 'ro');
  if ($authzres->{status} != 200) {
    $res->{status} = $authzres->{status};
    push @{$res->{alerts}}, @{$authzres->{alerts}} if scalar @{$authzres->{alerts}} > 0;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my ($filename, $mimetype, $size, $path);
  my $trywebversion = $self->param('trywebversion');

  my $fedora_model = PhaidraAPI::Model::Fedora->new;
  my $dsAttr;
  if (defined $ENV{S3_ENABLED} and $ENV{S3_ENABLED} eq "true") {
    return $self->proxy();
  }
  else {
    if ($trywebversion) {
      $dsAttr = $fedora_model->getDatastreamAttributes($self, $pid, 'WEBVERSION');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $filename = $dsAttr->{filename};
      $mimetype = $dsAttr->{mimetype};
      $size     = $dsAttr->{size};
      $dsAttr   = $fedora_model->getDatastreamPath($self, $pid, 'WEBVERSION');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $path = $dsAttr->{path};
    }
    unless ($path) {
      $dsAttr = $fedora_model->getDatastreamAttributes($self, $pid, 'OCTETS');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $filename = $dsAttr->{filename};
      $mimetype = $dsAttr->{mimetype};
      $size     = $dsAttr->{size};
      $dsAttr   = $fedora_model->getDatastreamPath($self, $pid, 'OCTETS');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $path = $dsAttr->{path};
    }
  }

  # get filename from metadata if there is JSON-LD
  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $resjsonld    = $jsonld_model->get_object_jsonld_parsed($self, $pid);
  if ($resjsonld->{status} eq 200) {
    if (exists($resjsonld->{'JSON-LD'}->{'ebucore:filename'})) {
      for my $v (@{$resjsonld->{'JSON-LD'}->{'ebucore:filename'}}) {
        $filename = $v;
        last;
      }
    }
  }

  $filename = utf8::is_utf8($filename) ? encode('UTF-8', $filename) : $filename;

  $self->app->log->debug("operation[$operation] trywebversion[" . ($trywebversion ? $trywebversion : 'undef') . "] pid[$pid] path[$path] mimetype[$mimetype] filename[$filename] size[$size]");

  if ($operation eq 'download') {
    $self->res->headers->content_disposition("attachment;filename=\"$filename\"");
  }
  else {
    $self->res->headers->content_disposition("filename=\"$filename\"");
  }
  $self->res->headers->content_type($mimetype);

  my $asset = Mojo::Asset::File->new(path => $path);

  # Range
  # based on Mojolicious::Plugin::RenderFile
  if (my $range = $self->req->headers->range) {
    my $start = 0;
    my $end   = $size - 1 >= 0 ? $size - 1 : 0;

    # Check range
    if ($range =~ m/^bytes=(\d+)-(\d+)?/ && $1 <= $end) {
      $start = $1;
      $end   = $2 if defined $2 && $2 <= $end;

      $res->{status} = 206;
      $self->res->headers->add('Content-Length' => $end - $start + 1);
      $self->res->headers->add('Content-Range'  => "bytes $start-$end/$size");
    }
    else {
      # Not satisfiable
      return $self->rendered(416);
    }

    # Set range for asset
    $asset->start_range($start)->end_range($end);
  }
  else {
    $self->res->headers->add('Content-Length' => $asset->size);
  }

  my $u_model = PhaidraAPI::Model::Util->new;
  $u_model->track_action($self, $pid, $operation);

  $self->res->content->asset($asset);
  $self->rendered($res->{status});
}

1;
