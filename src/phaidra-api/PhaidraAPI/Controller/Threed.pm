package PhaidraAPI::Controller::Threed;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Threed;
use PhaidraAPI::Model::Authorization;
use File::Basename qw(dirname);
use File::Spec;

sub get_resource {
  my $self = shift;

  my $pid = $self->stash('pid');
  my $filename = $self->req->param('filename');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  unless (defined($filename)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined filename'}]}, status => 400);
    return;
  }

  # Check authorization
  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $authzres = $authz_model->check_rights($self, $pid, 'ro');
  if ($authzres->{status} != 200) {
    $self->render(json => $authzres, status => $authzres->{status});
    return;
  }

  # Get the 3D model info to find the directory
  my $threed_model = PhaidraAPI::Model::Threed->new;
  my $model_info = $threed_model->get_model_path($self, $pid);
  
  unless ($model_info && ref $model_info eq 'HASH') {
    $self->render(json => {alerts => [{type => 'error', msg => '3D model not found'}]}, status => 404);
    return;
  }

  # Get the root path from config
  my $root = $self->config->{converted_3d_path} || '/mnt/converted_3d';
  my $idhash = $model_info->{idhash};
  my $scheme = $self->config->{scheme};
  my $baseurl = $self->config->{baseurl};
  my $basepath = $self->config->{basepath};
  
  # Construct the file path
  my $filepath;
  if ($idhash) {
    my $first = substr($idhash, 0, 1);
    my $second = substr($idhash, 1, 1);
    if ($filename eq 'model.gltf') {
      $filepath = "$root/$first/$second/$idhash.gltf";
    } else {
      $filepath = "$root/$first/$second/$filename";
    }
  } else {
    # Fallback to the original path construction
    $filepath = File::Spec->catfile($root, $filename);
  }

  # Check if file exists
  unless (-f $filepath) {
    $self->render(json => {alerts => [{type => 'error', msg => "Resource file not found: $filename"}]}, status => 404);
    return;
  }

  # Determine MIME type based on extension
  my $mimetype = 'application/octet-stream';
  if ($filename =~ /\.gltf$/i) {
    $mimetype = 'model/gltf+json';
  } elsif ($filename =~ /\.bin$/i) {
    $mimetype = 'application/octet-stream';
  } elsif ($filename =~ /\.jpe?g$/i) {
    $mimetype = 'image/jpeg';
  } elsif ($filename =~ /\.png$/i) {
    $mimetype = 'image/png';
  } elsif ($filename =~ /\.gif$/i) {
    $mimetype = 'image/gif';
  } elsif ($filename =~ /\.webp$/i) {
    $mimetype = 'image/webp';
  }

  # Set headers
  $self->res->headers->content_type($mimetype);
  $self->res->headers->content_disposition("filename=\"$filename\"");

  # Serve all files directly from disk (streaming)
  my $asset = Mojo::Asset::File->new(path => $filepath);
  $self->res->headers->add('Content-Length' => $asset->size);
  $self->res->content->asset($asset);
  
  $self->rendered(200);
}

1;
