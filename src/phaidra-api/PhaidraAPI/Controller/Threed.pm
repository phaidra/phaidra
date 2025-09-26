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
use Cwd qw(abs_path);

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

  # Sanitize and validate filename to prevent path traversal
  $filename =~ s/^\s+|\s+$//g;
  # Disallow any path separators or traversal
  if ($filename =~ m{[\\/]} || $filename =~ /\.\./) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid filename'}]}, status => 400);
    return;
  }
  # Allow only safe characters in filename (any extension permitted)
  unless ($filename =~ /\A[A-Za-z0-9_.+\-]+\z/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid filename characters'}]}, status => 400);
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
  
  # Construct the base directory for this object's resources
  my ($first, $second) = (substr($idhash, 0, 1), substr($idhash, 1, 1));
  my $base_dir = "$root/$first/$second";
  my $target_name = ($filename eq 'model.gltf') ? "$idhash.gltf" : $filename;

  # Optional: enforce files belong to this idhash when not gltf
  if ($target_name ne "$idhash.gltf" && $target_name !~ /^\Q$idhash\E(?:_|\.)/i) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Filename not allowed for this object'}]}, status => 400);
    return;
  }

  # Build and canonicalize path; ensure it stays under base_dir
  my $unsafe_path = File::Spec->catfile($base_dir, $target_name);
  my $canon_base  = abs_path($base_dir);
  my $canon_path  = abs_path($unsafe_path);
  unless ($canon_base && $canon_path && index($canon_path, $canon_base) == 0) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid resource path'}]}, status => 400);
    return;
  }
  my $filepath = $canon_path;

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
