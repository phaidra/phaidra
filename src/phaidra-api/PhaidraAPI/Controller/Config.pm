package PhaidraAPI::Controller::Config;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Config;

sub post_public_config {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("writing public_config");
  my $public_config = $self->param('public_config');
  unless (defined($public_config)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No public_config sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $public_config eq 'Mojo::Upload') {
      $self->app->log->debug("public_config sent as file param");
      $public_config = $public_config->asset->slurp;
      $public_config = decode_json($public_config);
    }
    else {
      $public_config = decode_json(b($public_config)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  #$self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($public_config));
  for my $key (keys %{$public_config}) {
    if ($public_config->{$key}) {
      if ($key ne '_id') {
        $self->app->log->info("public_config $key = " . $public_config->{$key});
        $self->mongo->get_collection('config')->update_one({ config_type => 'public' }, {'$set' => {$key => $public_config->{$key}}}, {upsert => 1});
      }
    }
    else {
      $self->mongo->get_collection('config')->update_one({ config_type => 'public' }, {'$unset' => {$key => ''}});
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub post_private_config {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("writing private_config");
  my $private_config = $self->param('private_config');
  unless (defined($private_config)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No private_config sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $private_config eq 'Mojo::Upload') {
      $self->app->log->debug("private_config sent as file param");
      $private_config = $private_config->asset->slurp;
      $private_config = decode_json($private_config);
    }
    else {
      $private_config = decode_json(b($private_config)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  # $self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($private_config));
  for my $key (keys %{$private_config}) {
    if ($private_config->{$key}) {
      if ($key ne '_id') {
        $self->app->log->info("private_config $key = " . $private_config->{$key});
        $self->mongo->get_collection('config')->update_one({ config_type => 'private' }, {'$set' => {$key => $private_config->{$key}}}, {upsert => 1});
      }
    }
    else {
      $self->mongo->get_collection('config')->update_one({ config_type => 'private' }, {'$unset' => {$key => ''}});
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub get_public_config {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("reading public_config");

  my $model = PhaidraAPI::Model::Config->new;
  my $modelres = $model->get_public_config($self);

  # $self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($modelres));
  $res->{public_config} = $modelres;

  $self->render(json => $res, status => $res->{status});
}

sub get_private_config {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("reading private_config");

  my $model = PhaidraAPI::Model::Config->new;
  my $modelres = $model->get_private_config($self);

  # $self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($modelres));
  $res->{private_config} = $modelres;

  $self->render(json => $res, status => $res->{status});
}

1;
