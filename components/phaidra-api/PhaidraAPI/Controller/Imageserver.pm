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
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid, ds => $ds}, {}, {"sort" => {"created" => -1}});
      if ($res1->{pid}) {
        $self->render(json => {alerts => [{type => 'info', msg => "Job for pid[$pid] and ds[$ds] already created"}], job => $res1}, status => 200);
        return;
      }
    }
    else {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid}, {}, {"sort" => {"created" => -1}});
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

  my $hash;
  if (defined($ds)) {
    $hash = hmac_sha1_hex($pid . "_" . $ds, $self->app->config->{imageserver}->{hash_secret});
    $self->paf_mongo->get_collection('jobs')->insert_one({pid => $pid, ds => $ds, cmodel => $cmodel, agent => "pige", status => "new", idhash => $hash, created => time});
  }
  else {
    $hash = hmac_sha1_hex($pid, $self->app->config->{imageserver}->{hash_secret});
    $self->paf_mongo->get_collection('jobs')->insert_one({pid => $pid, cmodel => $cmodel, agent => "pige", status => "new", idhash => $hash, created => time});
  }

  $res = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid}, {}, {"sort" => {"created" => -1}});

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

  my @results;
  for my $pid (@{$pids->{pids}}) {

    if ($skipexisting && ($skipexisting eq 1)) {
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid}, {}, {"sort" => {"created" => -1}});
      next if $res1->{pid};
    }

    my $search_model = PhaidraAPI::Model::Search->new;
    my $cmodelr      = $search_model->get_cmodel($self, $pid);
    if ($cmodelr->{status} ne 200) {
      $self->render(json => $cmodelr->{json}, status => $cmodelr->{status});
      return;
    }
    my $cmodel = $cmodelr->{cmodel};

    # create new job to process image
    my $hash = hmac_sha1_hex($pid, $self->app->config->{imageserver}->{hash_secret});
    $self->paf_mongo->get_collection('jobs')->insert_one({pid => $pid, cmodel => $cmodel, agent => "pige", status => "new", idhash => $hash, created => time});

    # create a temporary hash for the image to hide the real hash in case we want to forbid access to the picture
    my $tmp_hash = hmac_sha1_hex($hash, $self->app->config->{imageserver}->{tmp_hash_secret});
    $self->mongo->get_collection('imgsrv.hashmap')->insert_one({pid => $pid, idhash => $hash, tmp_hash => $tmp_hash, created => time});

    push @results, {pid => $pid, idhash => $hash, tmp_hash => $tmp_hash};
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

  $res = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid}, {}, {"sort" => {"created" => -1}});

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
    my $res = $self->mongo->get_collection('imgsrv.hashmap')->find_one({pid => $pid});
    if (!defined($res) || !exists($res->{tmp_hash})) {

      # if we could not find the temp hash, look into the jobs if the image isn't there as processed
      my $res1 = $self->paf_mongo->get_collection('jobs')->find_one({pid => $pid}, {}, {"sort" => {"created" => -1}});
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

sub get {
  my $self = shift;

  my $isrv_model = PhaidraAPI::Model::Imageserver->new;
  my $res        = $isrv_model->get_url($self, $self->req->params, 1);
  if ($res->{status} ne 200) {
    $self->render(json => $res, status => $res->{status});
    return;
  }

  if (Mojo::IOLoop->is_running) {
    $self->render_later;
    $self->ua->get(
      $res->{url},
      sub {
        my ($c, $tx) = @_;
        _proxy_tx($self, $tx);
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
