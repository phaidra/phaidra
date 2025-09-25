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
use File::Basename qw(dirname);
use File::Spec;
use File::Glob qw(bsd_glob);

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
  my $idhash;
  unless ($filepath =~ m/^\/?\Q$root/i) {
    # If not, construct the path using the idhash
    $idhash = $job->{idhash};
    unless ($idhash) {
      $app->log->error("No idhash found in job for PID: " . $pid);
      return undef;
    }
    my $first = substr($idhash, 0, 1);
    my $second = substr($idhash, 1, 1);
    $filepath = "$root/$first/$second/$idhash.gltf";
  } else {
    $idhash = $job->{idhash};
  }

  $app->log->info("Resolved filepath: " . $filepath);

  # Read the file contents
  open(my $fh, '<', $filepath) or do {
    $app->log->error("Could not open file $filepath: $!");
    return undef;
  };
  my $content = do { local $/; <$fh> };
  close($fh);

  # Build resource map of sibling files (e.g., <idhash>_data.bin, <idhash>_imgX.jpg)
  my %resources;
  my $base_dir = dirname($filepath);
  if (-d $base_dir) {
    my @files = bsd_glob(File::Spec->catfile($base_dir, '*'));
    foreach my $f (@files) {
      next unless -f $f;
      my ($name) = $f =~ m{([^/]+)$};
      next if $name =~ /\.gltf$/i; # skip the gltf itself
      # If idhash known, prefer only related files
      if (defined $idhash && length $idhash) {
        next unless ($name =~ /^\Q$idhash\E[_\.]/i);
      }
      open(my $rfh, '<', $f) or next;
      binmode($rfh);
      my $rdata = do { local $/; <$rfh> };
      close($rfh);
      my $b64 = encode_base64($rdata, '');
      $resources{$name} = $b64;
    }
  }

  # Encode model content to base64 (no newlines)
  my $model_b64 = encode_base64($content, '');

  # Encode resource map as JSON, then base64 for safe embedding
  my $resources_json = encode_json(\%resources);
  my $resource_map_b64 = encode_base64($resources_json, '');

  return {
    model_b64 => $model_b64,
    resource_map_b64 => $resource_map_b64,
    idhash => $idhash
  };
}

1; 