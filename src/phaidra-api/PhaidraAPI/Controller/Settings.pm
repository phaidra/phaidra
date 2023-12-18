package PhaidraAPI::Controller::Settings;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);

sub get_settings {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("reading settings of " . $self->stash->{basic_auth_credentials}->{username});
  my $sres = $self->mongo->get_collection('user_settings')->find_one({owner => $self->stash->{basic_auth_credentials}->{username}});

  # $self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($sres));
  $res->{settings} = $sres;

  $self->render(json => $res, status => $res->{status});
}

sub post_settings {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("writing settings of " . $self->stash->{basic_auth_credentials}->{username});
  my $settings = $self->param('settings');
  unless (defined($settings)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No settings sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $settings eq 'Mojo::Upload') {
      $self->app->log->debug("settings sent as file param");
      $settings = $settings->asset->slurp;
      $settings = decode_json($settings);
    }
    else {
      $settings = decode_json(b($settings)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  # $self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($settings));
  for my $key (keys %{$settings}) {
    unless ($settings->{$key} eq 'owner') {
      if ($settings->{$key}) {
        $self->app->log->info("Setting $key = " . $settings->{$key});
        $self->mongo->get_collection('user_settings')->update_one({owner => $self->stash->{basic_auth_credentials}->{username}}, {'$set' => {$key => $settings->{$key}}}, {upsert => 1});
      }
      else {
        $self->mongo->get_collection('user_settings')->update_one({owner => $self->stash->{basic_auth_credentials}->{username}}, {'$unset' => {$key => ''}});
      }
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub post_app_settings {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("writing app settings");
  my $settings = $self->param('settings');
  unless (defined($settings)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No app settings sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $settings eq 'Mojo::Upload') {
      $self->app->log->debug("settings app sent as file param");
      $settings = $settings->asset->slurp;
      $settings = decode_json($settings);
    }
    else {
      $settings = decode_json(b($settings)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  # $self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($settings));
  for my $key (keys %{$settings}) {
    if ($settings->{$key}) {
      $self->app->log->info("Setting $key = " . $settings->{$key});
      $self->mongo->get_collection('app_settings')->update_one({}, {'$set' => {$key => $settings->{$key}}}, {upsert => 1});
    }
    else {
      $self->mongo->get_collection('app_settings')->update_one({}, {'$unset' => {$key => ''}});
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub get_app_settings {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("reading app settings");
  my $sres = $self->mongo->get_collection('app_settings')->find_one({});

  # $self->app->log->debug("XXXXXXXXXXXXXXX " . $self->app->dumper($sres));
  $res->{settings} = $sres;

  $self->render(json => $res, status => $res->{status});
}

1;
