package PhaidraAPI::Controller::Imageserver;

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
use PhaidraAPI::Model::Imageserver;
use Time::HiRes qw/tv_interval gettimeofday/;

sub process {

  my $self = shift;

  my $pid          = $self->stash('pid');
  my $ds           = $self->param('ds');
  my $skipexisting = $self->param('skipexisting');

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $res         = $authz_model->check_rights($self, $pid, 'rw');
  unless ($res->{status} eq '200') {
    $self->render(json => $res->{json}, status => $res->{status});
    return;
  }

  if ($skipexisting && ($skipexisting eq 1)) {
    if (defined($ds)) {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, ds => $ds, agent => 'pige'}, {}, {"sort" => {"created" => -1}});
      if ($res1->{pid}) {
        $self->render(json => {alerts => [{type => 'info', msg => "Job for pid[$pid] and ds[$ds] already created"}], job => $res1}, status => 200);
        return;
      }
    }
    else {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'pige'}, {}, {"sort" => {"created" => -1}});
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

  my $imgsrv_model = PhaidraAPI::Model::Imageserver->new;
  $imgsrv_model->create_imageserver_job($self, $pid, $cmodel, $ds);

  $res = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'pige'}, {}, {"sort" => {"created" => -1}});

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
  my $imgsrv_model = PhaidraAPI::Model::Imageserver->new;
  my @results;
  for my $pid (@{$pids->{pids}}) {

    if ($skipexisting && ($skipexisting eq 1)) {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'pige'}, {}, {"sort" => {"created" => -1}});
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

    my $create_res = $imgsrv_model->create_imageserver_job($self, $pid, $cmodel);

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

  $res = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'pige'}, {}, {"sort" => {"created" => -1}});

  $self->render(json => { conversion => $res->{conversion}, status => $res->{status} }, status => 200);

}

sub tmp_hash {

  my $self = shift;

  my $pid = $self->stash('pid');

  # check rights
  my $object_model = PhaidraAPI::Model::Object->new;
  my $rres         = $object_model->get_datastream($self, $pid, 'READONLY', $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($rres->{status} eq '404') {

    # it's ok
    my $res = $self->mongo->get_collection('imgsrv.hashmap')->find_one({pid => $pid, agent => 'pige'});
    if (!defined($res) || !exists($res->{tmp_hash})) {

      # if we could not find the temp hash, look into the jobs if the image isn't there as processed
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'pige'}, {}, {"sort" => {"created" => -1}});
      if (!defined($res1) || $res1->{status} ne 'finished') {

        # if it isn't then this image isn't known to imageserver
        $self->render(json => {alerts => [{type => 'info', msg => 'Not found in imageserver'}]}, status => 404);
        return;
      }
      else {
        # if it is, create the temp hash
        if ($res1->{idhash}) {
          my $tmp_hash = hmac_sha1_hex($res1->{idhash}, $self->app->config->{imageserver}->{tmp_hash_secret});
          $self->mongo->get_collection('imgsrv.hashmap')->insert_one({pid => $pid, idhash => $res1->{idhash}, tmp_hash => $tmp_hash, created => time});
          $self->render(text => $tmp_hash, status => 200);
          return;
        }
      }

    }
    else {
      $self->render(text => $res->{tmp_hash}, status => 200);
      return;
    }

  }
  else {
    $self->render(json => {}, status => 403);
    return;
  }

}

sub imageserverproxy {
  my $self = shift;

  my $isrv_model = PhaidraAPI::Model::Imageserver->new;
  my $t0 = [gettimeofday];
  my $res        = $isrv_model->get_url($self, $self->req->params, 1);
  $self->app->log->debug($self->req->params." imageserverproxy get_url took " . tv_interval($t0));
  if ($res->{status} ne 200) {
    $self->render(json => $res, status => $res->{status});
    return;
  }

  if (Mojo::IOLoop->is_running) {
    my $t1 = [gettimeofday];
    $self->render_later;
    $self->ua->get(
      $res->{url},
      sub {
        my ($c, $tx) = @_;
        _proxy_tx($self, $tx);
        $self->app->log->debug($self->req->params." imageserverproxy call_url took " . tv_interval($t1));
      }
    );
  }
  else {
    my $tx = $self->ua->get($res->{url});
    _proxy_tx($self, $tx);
  }

}

sub _proxy_tx {
  my ($c, $tx) = @_;
  if (!$tx->error) {
    my $res = $tx->res;
    $c->tx->res($res);
    $c->rendered;
  }
  else {
    my $error = $tx->error;
    $c->tx->res->headers->add('X-Remote-Status',
      $error->{code} . ': ' . $error->{message});
    $c->render(status => 500, text => 'Failed to fetch data from backend');
  }
}

1;
