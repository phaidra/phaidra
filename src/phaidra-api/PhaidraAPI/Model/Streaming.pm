package PhaidraAPI::Model::Streaming;

use strict;
use warnings;
use v5.10;
use utf8;
use base        qw/Mojo::Base/;
use Mojo::Util  qw(decode encode url_escape url_unescape);
use Digest::SHA qw(hmac_sha1_hex);
use PhaidraAPI::Model::Object;

sub create_streaming_job {
  my ($self, $c, $pid, $cmodel) = @_;

  my $res = {alerts => [], status => 200};
  if ($c->app->config->{streaming}
    || defined $c->app->config->{external_services}->{opencast}->{mode} && $c->app->config->{external_services}->{opencast}->{mode} eq "ACTIVATED")
  {
    $c->app->log->info("Creating streaming job pid[$pid] cm[$cmodel]");
    my $path;
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $dsAttr       = $fedora_model->getDatastreamPath($c, $pid, 'OCTETS');
    if ($dsAttr->{status} eq 200) {
      $c->app->log->error("streaming job pid[$pid] cm[$cmodel]: could not get path");
      $path = $dsAttr->{path};
    }

    my $job = {pid => $pid, cmodel => $cmodel, agent => "opencast", status => "new", created => time};
    $job->{path} = $path if $path;
    $c->paf_mongo->get_collection('jobs')->insert_one($job);
  }
  return $res;
}

sub create_agent_job {
  my ($self, $c, $pid, $cmodel, $job) = @_;

  my $res = {alerts => [], status => 200};
  return $res unless $job && $job->{agent};
  return $res unless $job->{agent} =~ /\A[A-Za-z][A-Za-z0-9_-]*\z/;

  my $doc = {
    pid     => $pid,
    cmodel  => $cmodel,
    agent   => $job->{agent},
    status  => 'new',
    created => time,
  };
  for my $key (keys %{$job}) {
    next if $key eq 'agent';
    next unless $key =~ /\A[A-Za-z][A-Za-z0-9_]*\z/;
    my $val = $job->{$key};
    next unless defined $val;
    if (!ref($val)) {
      $val =~ s/<[^>]*>//g;
      $val =~ s/\0//g;
      $val =~ s/javascript://gi;
    }
    $doc->{$key} = $val;
  }

  $c->app->log->info("Creating agent job pid[$pid] cm[$cmodel] agent[$doc->{agent}]");
  $c->paf_mongo->get_collection('jobs')->insert_one($doc);
  return $res;
}

sub create_opencast_upload_job {
  my ($self, $c, $pid, $cmodel, $oc_mpid) = @_;

  return $self->create_agent_job($c, $pid, $cmodel, {
    agent   => 'opencast_upload',
    oc_mpid => $oc_mpid,
  });
}

sub get_job {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};
  if ($c->app->config->{streaming}
    || defined $c->app->config->{external_services}->{opencast}->{mode} && $c->app->config->{external_services}->{opencast}->{mode} eq "ACTIVATED")
  {
    $c->app->log->info("Searching for streaming job pid[$pid]");
    my $resjob = $c->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'opencast'}, {}, {"sort" => {"created" => -1}});
    if ($resjob->{pid}) {
      $res->{job} = $resjob;
      $c->app->log->info("job pid[$pid]:\n" . $c->app->dumper($resjob));
      return $res;
    }
    else {
      unshift @{$res->{alerts}}, {type => 'error', msg => "Could not find job for pid[$pid]"};
      $res->{status} = 404;
      return $res;
    }
  }
  else {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Streaming is not configured"};
    $res->{status} = 400;
    return $res;
  }
}

1;
__END__
