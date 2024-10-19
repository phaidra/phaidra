package PhaidraAPI::Model::Config;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;

sub get_public_config {
  my $self = shift;
  my $c = shift;

  my $cacheval = $c->app->chi->get('public_config');
  if ($cacheval) {
    # $c->app->log->debug("[cache hit] public_config");
  } else {
    $c->app->log->debug("[cache miss] public_config");
    $cacheval = $c->mongo->get_collection('config')->find_one({ config_type => 'public' });
    $c->app->chi->set('public_config', $cacheval, '1 day');
    $cacheval = $c->app->chi->get('public_config');
  }

  return $cacheval;
}

sub get_private_config {
  my $self = shift;
  my $c = shift;

  my $cacheval = $c->app->chi->get('private_config');
  if ($cacheval) {
    # $c->app->log->debug("[cache hit] private_config");
  } else {
    $c->app->log->debug("[cache miss] private_config");
    $cacheval = $c->mongo->get_collection('config')->find_one({ config_type => 'private' });
    $c->app->chi->set('private_config', $cacheval, '1 day');
    $cacheval = $c->app->chi->get('private_config');
  }

  return $cacheval;
}

1;
__END__
