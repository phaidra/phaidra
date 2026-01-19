package PhaidraAPI::Controller::Viewer360;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Asset::File;
use PhaidraAPI::Model::Viewer360;
use PhaidraAPI::Model::Authorization;
use File::Spec;
use Cwd qw(abs_path);

sub get_frame {
  my $self = shift;

  my $pid = $self->stash('pid');
  my $frame = $self->req->param('frame');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  unless (defined($frame)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined frame number'}]}, status => 400);
    return;
  }

  # Validate frame number
  unless ($frame =~ /^\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid frame number'}]}, status => 400);
    return;
  }

  # Check authorization
  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $authzres = $authz_model->check_rights($self, $pid, 'ro');
  if ($authzres->{status} != 200) {
    $self->render(json => $authzres, status => $authzres->{status});
    return;
  }

  # Get the frame path
  my $viewer360_model = PhaidraAPI::Model::Viewer360->new;
  my $frame_info = $viewer360_model->get_frame_path($self, $pid, $frame);
  
  unless ($frame_info && $frame_info->{path}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Frame not found'}]}, status => 404);
    return;
  }

  my $filepath = $frame_info->{path};
  my $filename = $frame_info->{filename};

  # Check if file exists
  unless (-f $filepath) {
    $self->app->log->error("Frame file not found: $filepath");
    $self->render(json => {alerts => [{type => 'error', msg => 'Frame file not found'}]}, status => 404);
    return;
  }

  # Determine MIME type based on extension
  my $mimetype = 'application/octet-stream';
  if ($filename =~ /\.jpe?g$/i) {
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
  $self->res->headers->content_disposition("inline; filename=\"$filename\"");
  $self->res->headers->cache_control('public, max-age=86400'); # Cache for 1 day

  # Serve file from disk (streaming)
  my $asset = Mojo::Asset::File->new(path => $filepath);
  $self->res->headers->add('Content-Length' => $asset->size);
  $self->res->content->asset($asset);
  
  $self->rendered(200);
}

sub get_frame_by_name {
  my $self = shift;

  my $pid = $self->stash('pid');
  my $filename = $self->stash('filename');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  unless (defined($filename)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined filename'}]}, status => 400);
    return;
  }

  # Security: prevent directory traversal
  if ($filename =~ /\.\./ || $filename =~ /[\/\\]/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid filename'}]}, status => 400);
    return;
  }

  # Check authorization
  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $authzres = $authz_model->check_rights($self, $pid, 'ro');
  if ($authzres->{status} != 200) {
    $self->render(json => $authzres, status => $authzres->{status});
    return;
  }

  my $viewer360_model = PhaidraAPI::Model::Viewer360->new;
  my $config = $viewer360_model->get_viewer_config($self, $pid);
  
  unless ($config && $config->{status} eq 'finished') {
    $self->render(json => {alerts => [{type => 'error', msg => 'Viewer not ready'}]}, status => 404);
    return;
  }

  my $idhash = $config->{idhash};
  my $base_dir = File::Spec->catfile('/mnt/derivates-expanded', substr($idhash, 0, 1), substr($idhash, 1, 1), $idhash);
  my $filepath = File::Spec->catfile($base_dir, $filename);

  # Check if file exists first
  unless (-f $filepath) {
    $self->app->log->error("Frame file not found: $filepath (base_dir: $base_dir)");
    $self->render(json => {alerts => [{type => 'error', msg => 'Frame file not found'}]}, status => 404);
    return;
  }

  # Sanitize and validate path to prevent traversal (after we know file exists)
  my $canon_base  = abs_path($base_dir);
  my $canon_path  = abs_path($filepath);
  unless ($canon_base && $canon_path && index($canon_path, $canon_base) == 0) {
    $self->app->log->error("Invalid frame path: $filepath (canon_base: $canon_base, canon_path: $canon_path)");
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid frame path'}]}, status => 400);
    return;
  }

  # Determine MIME type based on extension
  my $mimetype = 'application/octet-stream';
  if ($filename =~ /\.jpe?g$/i) {
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
  $self->res->headers->content_disposition("inline; filename=\"$filename\"");
  $self->res->headers->cache_control('public, max-age=86400'); # Cache for 1 day
  $self->res->headers->header('Access-Control-Allow-Origin' => '*'); # Allow CORS for viewer

  # Serve file from disk (streaming)
  my $asset = Mojo::Asset::File->new(path => $filepath);
  $self->res->headers->add('Content-Length' => $asset->size);
  $self->res->content->asset($asset);
  
  $self->rendered(200);
}

1;

