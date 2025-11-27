package PhaidraAPI::Model::Viewer360;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use File::Spec;

sub get_viewer_config {
  my ($self, $c, $pid) = @_;
  
  my $job = $c->paf_mongo->get_collection('jobs')->find_one(
    { pid => $pid, agent => '360viewer' },
    {},
    { sort => { created => -1 } }
  );

  return { status => 'not_found' } unless $job;
  return { status => $job->{status} } unless $job->{status} eq 'finished';
  return { status => 'error' } unless ($job->{totalFrames} && $job->{frames});

  return {
    status => 'finished',
    totalFrames => $job->{totalFrames},
    imagePattern => $job->{imagePattern} || 'frame-xx.png',
    frames => $job->{frames},
    idhash => $job->{idhash}
  };
}

sub get_frame_path {
  my ($self, $c, $pid, $frame_number) = @_;
  
  my $job = $c->paf_mongo->get_collection('jobs')->find_one(
    { pid => $pid, agent => '360viewer' },
    {},
    { sort => { created => -1 } }
  );

  return undef unless ($job && $job->{status} eq 'finished' && $job->{frames});

  my $total_frames = scalar @{$job->{frames}};
  return undef if ($frame_number < 1 || $frame_number > $total_frames);

  my $filename = $job->{frames}->[$frame_number - 1];
  my $idhash = $job->{idhash};
  
  my $filepath = File::Spec->catfile(
    '/mnt/converted_360',
    substr($idhash, 0, 1),
    substr($idhash, 1, 1),
    $idhash,
    $filename
  );
  
  return { path => $filepath, filename => $filename };
}

1;
