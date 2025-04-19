package PhaidraAPI::Model::Threed;

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
use MIME::Base64;

sub get_model_path {
  my ($self, $c, $pid) = @_;
  
  # Get the app instance for logging
  my $app = $c->app;
  $app->log->info("Getting 3D model path for PID: " . $pid);

  # Get the most recent job for this PID
  my $job = $c->paf_mongo->get_collection('jobs')->find_one(
    { pid => $pid, agent => '3d' },
    {},
    { sort => { created => -1 } }
  );

  unless ($job) {
    $app->log->error("No 3D job found for PID: " . $pid);
    return undef;
  }

  unless ($job->{status} eq 'finished') {
    $app->log->info("Job not finished for PID: " . $pid . ", status: " . $job->{status});
    return 'processing';
  }

  unless ($job->{image}) {
    $app->log->error("No image path in job for PID: " . $pid);
    return undef;
  }

  # Get the root path from config
  my $root = $c->config->{converted_3d_path} || '/mnt/converted_3d';
  $app->log->info("3D models root: " . $root);
  
  # If the path already includes the root, use it as is
  my $filepath = $job->{image};
  unless ($filepath =~ m/^\/?\Q$root/i) {
    # If not, construct the path using the idhash
    my $idhash = $job->{idhash};
    unless ($idhash) {
      $app->log->error("No idhash found in job for PID: " . $pid);
      return undef;
    }
    my $first = substr($idhash, 0, 1);
    my $second = substr($idhash, 1, 1);
    $filepath = "$root/$first/$second/$idhash.gltf";
  }

  $app->log->info("Resolved filepath: " . $filepath);

  # Read the file contents
  open(my $fh, '<', $filepath) or do {
    $app->log->error("Could not open file $filepath: $!");
    return undef;
  };
  my $content = do { local $/; <$fh> };
  close($fh);

  # Encode the content as base64 and escape it for JavaScript
  $content = encode_base64($content);
  $content =~ s/\n//g;  # Remove newlines from base64
  $content =~ s/\\/\\\\/g;  # Escape backslashes
  $content =~ s/'/\\'/g;    # Escape single quotes
  
  return $content;
}

1; 