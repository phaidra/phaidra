package PhaidraAPI::Controller::Threed;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(decode encode);
use Mojo::Parameters;
use Digest::SHA qw(hmac_sha1_hex);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Authorization;
use Time::HiRes qw/tv_interval gettimeofday/;

sub get_model {
  my $self = shift;
  my $pid = $self->stash('pid');
  
  $self->app->log->info("3D model request for PID: " . $pid);

  # Check authorization
  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $res = $authz_model->check_rights($self, $pid, 'r');
  unless ($res->{status} eq '200') {
    $self->app->log->error("Authorization failed for PID: " . $pid . ", status: " . $res->{status});
    $self->render(json => $res->{json}, status => $res->{status});
    return;
  }

  # Get the most recent job for this PID
  my $job = $self->paf_mongo->get_collection('jobs')->find_one(
    { pid => $pid, agent => '3d' },
    {},
    { sort => { created => -1 } }
  );

  unless ($job) {
    $self->app->log->error("No 3D job found for PID: " . $pid);
    $self->render(json => { alerts => [{ type => 'error', msg => "No 3D model found for pid[$pid]" }] }, status => 404);
    return;
  }

  $self->app->log->info("Found job: " . encode_json($job));

  unless ($job->{status} eq 'finished') {
    $self->app->log->info("Job not finished for PID: " . $pid . ", status: " . $job->{status});
    $self->res->headers->content_type('text/plain');
    $self->render(text => "3D model is currently being processed. Please check back later.");
    return;
  }

  unless ($job->{image}) {
    $self->app->log->error("No image path in job for PID: " . $pid);
    $self->render(json => { alerts => [{ type => 'error', msg => "No image path found for pid[$pid]" }] }, status => 404);
    return;
  }

  # Get the root path from config
  my $root = $self->config->{converted_3d_path} || '/mnt/converted_3d';
  $self->app->log->info("3D models root: " . $root);
  
  # If the path already includes the root, use it as is
  my $filepath = $job->{image};
  unless ($filepath =~ m/^\/?\Q$root/i) {
    # If not, construct the path using the idhash
    my $idhash = $job->{idhash};
    unless ($idhash) {
      $self->app->log->error("No idhash found in job for PID: " . $pid);
      $self->render(json => { alerts => [{ type => 'error', msg => "No idhash found for pid[$pid]" }] }, status => 404);
      return;
    }
    my $first = substr($idhash, 0, 1);
    my $second = substr($idhash, 1, 1);
    $filepath = "$root/$first/$second/$idhash.gltf";
  }

  $self->app->log->info("Resolved filepath: " . $filepath);

  # Read the file directly
  eval {
    open(my $fh, '<', $filepath) or die "Cannot open file: $!";
    binmode($fh);
    my $content = do { local $/; <$fh> };
    close($fh);

    $self->res->headers->content_type('model/gltf+json');
    $self->render(data => $content);
  };
  if ($@) {
    $self->app->log->error("Error reading file: " . $@);
    $self->render(json => { alerts => [{ type => 'error', msg => "Failed to read 3D model file" }] }, status => 500);
    return;
  }
}

1; 