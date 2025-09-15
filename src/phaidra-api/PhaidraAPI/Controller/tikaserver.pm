package PhaidraAPI::Controller::Tikaserver;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(decode encode url_escape url_unescape);
use Mojo::ByteStream qw(b);
use Digest::SHA qw(hmac_sha1_hex);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Fedora;
use Time::HiRes qw/tv_interval gettimeofday/;

sub process {

  my $self = shift;

  my $pid          = $self->stash('pid');
  my $ds           = $self->param('ds');
  my $skipexisting = $self->param('skipexisting');
  my $agent        = $self->param('agent');

  unless ($agent) {
    $agent = 'tika';
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $res         = $authz_model->check_rights($self, $pid, 'rw');
  unless ($res->{status} eq '200') {
    $self->render(json => $res->{json}, status => $res->{status});
    return;
  }

  if ($skipexisting && ($skipexisting eq 1)) {
    if (defined($ds)) {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, ds => $ds, agent => $agent}, {}, {"sort" => {"created" => -1}});
      if ($res1->{pid}) {
        $self->render(json => {alerts => [{type => 'info', msg => "Job for pid[$pid] and ds[$ds] already created"}], job => $res1}, status => 200);
        return;
      }
    }
    else {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => $agent}, {}, {"sort" => {"created" => -1}});
      if ($res1->{pid}) {
        $self->render(json => {alerts => [{type => 'info', msg => "Job for pid[$pid] already created"}], job => $res1}, status => 200);
        return;
      }
    }
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $cmodelr      = $search_model->get_cmodel($self, $pid);
  if ($cmodelr->{status} ne 200) {
    $self->render(json => $cmodelr->{json}, status => $cmodelr->{status});
    return;
  }
  my $cmodel = $cmodelr->{cmodel};

  # Create or update Tika extraction job (agent 'tika')
  my $find = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => $agent});
  my $hash = hmac_sha1_hex($pid, $self->app->config->{imageserver}->{hash_secret});
  my $path;
  if ($self->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $dsAttr = $fedora_model->getDatastreamPath($self, $pid, 'OCTETS');
    if ($dsAttr->{status} eq 200) {
      $path = $dsAttr->{path};
    } else {
      $self->app->log->error("tikaserver process pid[$pid] cm[$cmodel]: could not get path");
    }
  }
  unless ($find->{pid}) {
    my $job = {pid => $pid, cmodel => $cmodel, agent => $agent, status => 'new', idhash => $hash, created => time};
    $job->{path} = $path if $path;
    $self->paf_mongo->get_collection('jobs')->insert_one($job);
  } else {
    $self->paf_mongo->get_collection('jobs')->update_one(
      { 'pid' => $pid, 'agent' => $agent },
      { '$set' => { 'status' => 'new', 'idhash' => $hash, ($path ? ('path' => $path) : ()) } },
      { 'upsert' => 0 }
    );
  }

  $res = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => $agent}, {}, {"sort" => {"created" => -1}});

  $self->render(json => $res, status => 200);
}

sub process_pids {

  my $self = shift;

  my $skipexisting = $self->param('skipexisting');
  my $pids         = $self->param('pids');
  unless (defined($pids)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No pids sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $pids eq 'Mojo::Upload') {
      $self->app->log->debug("Pids sent as file param");
      $pids = $pids->asset->slurp;
      $self->app->log->debug("parsing json");
      $pids = decode_json($pids);
    }
    else {
      $self->app->log->debug("parsing json");
      $pids = decode_json(b($pids)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    $self->render(json => {alerts => [{type => 'error', msg => $@}]}, status => 400);
    return;
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my @results;
  for my $pid (@{$pids->{pids}}) {

    if ($skipexisting && ($skipexisting eq 1)) {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'tika'}, {}, {"sort" => {"created" => -1}});
      if ($res1->{pid}) {
        $self->render(json => {alerts => [{type => 'info', msg => "Job for pid[$pid] already created"}], job => $res1}, status => 200);
        next;
      }
    }

    my $cmodelr = $search_model->get_cmodel($self, $pid);
    if ($cmodelr->{status} ne 200) {
      $self->render(json => $cmodelr->{json}, status => $cmodelr->{status});
      next;
    }
    my $cmodel = $cmodelr->{cmodel};

    # Only meaningful for PDFDocument, but we still create/update the job consistently
    my $find = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'tika'});
    my $hash = hmac_sha1_hex($pid, $self->app->config->{imageserver}->{hash_secret});
    my $path;
    if ($self->app->config->{fedora}->{version} >= 6) {
      my $fedora_model = PhaidraAPI::Model::Fedora->new;
      my $dsAttr = $fedora_model->getDatastreamPath($self, $pid, 'OCTETS');
      if ($dsAttr->{status} eq 200) {
        $path = $dsAttr->{path};
      } else {
        $self->app->log->error("tikaserver process_pids pid[$pid] cm[$cmodel]: could not get path");
      }
    }
    unless ($find->{pid}) {
      my $job = {pid => $pid, cmodel => $cmodel, agent => 'tika', status => 'new', idhash => $hash, created => time};
      $job->{path} = $path if $path;
      $self->paf_mongo->get_collection('jobs')->insert_one($job);
    } else {
      $self->paf_mongo->get_collection('jobs')->update_one(
        { 'pid' => $pid, 'agent' => 'tika' },
        { '$set' => { 'status' => 'new', 'idhash' => $hash, ($path ? ('path' => $path) : ()) } },
        { 'upsert' => 0 }
      );
    }

    push @results, {pid => $pid, idhash => $hash};
  }

  $self->render(json => \@results, status => 200);

}


1;
