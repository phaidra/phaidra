package PhaidraAPI::Controller::Streaming;

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
use PhaidraAPI::Model::Streaming;

sub key {
  my $self = shift;
  
  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  my $pid = $self->stash('pid');
  unless ($pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}]}, status => 400);
    return;
  }

  if (defined $self->config->{external_services}->{opencast}->{mode} && $self->config->{external_services}->{opencast}->{mode} eq "ACTIVATED") {
    my $object_job_info = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'vige'});
    if (defined $object_job_info) {
      $self->render(text => $object_job_info->{oc_mpid}, status => 200);
      return;
    } else {
      $self->render(json => {alerts => [{type => 'error', msg => 'Not found'}]}, status => 404);
      return;
    }
  } else {
   $self->render(json => {alerts => [{type => 'error', msg => 'Streaming is not configured'}]}, status => 400);
   return;
  }
}

sub process {
  my $self = shift;

  my $pid          = $self->stash('pid');
  my $skipexisting = $self->param('skipexisting');

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $res         = $authz_model->check_rights($self, $pid, 'rw');
  unless ($res->{status} eq '200') {
    $self->render(json => $res->{json}, status => $res->{status});
    return;
  }

  if ($skipexisting && ($skipexisting eq 1)) {
    my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'vige'}, {}, {"sort" => {"created" => -1}});
    if ($res1->{pid}) {
      $self->render(json => {alerts => [{type => 'info', msg => "Job for pid[$pid] already created"}], job => $res1}, status => 200);
      return;
    }
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $cmodelr      = $search_model->get_cmodel($self, $pid);
  if ($cmodelr->{status} ne 200) {
    $self->render(json => $cmodelr->{json}, status => $cmodelr->{status});
    return;
  }
  my $cmodel = $cmodelr->{cmodel};

  my $imgsrv_model = PhaidraAPI::Model::Streaming->new;
  $imgsrv_model->create_streaming_job($self, $pid, $cmodel);

  $res = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'vige'}, {}, {"sort" => {"created" => -1}});

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
  my $imgsrv_model = PhaidraAPI::Model::Streaming->new;
  my @results;
  for my $pid (@{$pids->{pids}}) {

    if ($skipexisting && ($skipexisting eq 1)) {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'vige'}, {}, {"sort" => {"created" => -1}});
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

    my $create_res = $imgsrv_model->create_streaming_job($self, $pid, $cmodel);

    push @results, {pid => $pid, idhash => $create_res->{hash}};
  }

  $self->render(json => \@results, status => 200);

}

sub status {

  my $self = shift;

  my $pid = $self->stash('pid');

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $res         = $authz_model->check_rights($self, $pid, 'ro');
  unless ($res->{status} eq '200') {
    $self->render(json => $res->{json}, status => $res->{status});
    return;
  }

  $res = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'vige'}, {}, {"sort" => {"created" => -1}});

  $self->render(json => { status => $res->{status} }, status => 200);

}

1;
