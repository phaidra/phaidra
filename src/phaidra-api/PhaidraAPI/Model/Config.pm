package PhaidraAPI::Model::Config;

use strict;
use warnings;
use v5.10;
use utf8;
use base       qw/Mojo::Base/;
use Mojo::JSON qw(encode_json decode_json);

sub _encode_data_ot4rt_for_storage {
  my ($value) = @_;
  return $value unless defined $value;
  return encode_json($value) if ref $value eq 'HASH';
  return $value;
}

sub _decode_data_ot4rt_from_storage {
  my ($value) = @_;
  return $value unless defined $value;
  return $value if ref $value eq 'HASH';
  my $decoded = eval { decode_json($value) };
  return $@ ? undef : $decoded;
}

sub hydrate_public_config_doc {
  my ($self, $doc) = @_;
  return $doc unless ref $doc eq 'HASH' && exists $doc->{data_ot4rt};
  my $decoded = _decode_data_ot4rt_from_storage($doc->{data_ot4rt});
  $doc->{data_ot4rt} = $decoded if defined $decoded;
  return $doc;
}

sub update_public_config {
  my ($self, $c, $public_config) = @_;
  return unless ref $public_config eq 'HASH';

  for my $key (keys %{$public_config}) {
    if ($public_config->{$key}) {
      next if $key eq '_id';
      my $value = $public_config->{$key};
      $value = _encode_data_ot4rt_for_storage($value) if $key eq 'data_ot4rt';
      $c->mongo->get_collection('config')->update_one({config_type => 'public'}, {'$set' => {$key => $value}}, {upsert => 1});
    }
    else {
      $c->mongo->get_collection('config')->update_one({config_type => 'public'}, {'$unset' => {$key => ''}});
    }
  }

  $c->app->chi->remove('public_config');
}

sub get_public_config {
  my $self    = shift;
  my $c       = shift;
  my $nocache = shift;

  my $cacheval = $c->app->chi->get('public_config');
  if ($cacheval && !$nocache) {

    # $c->app->log->debug("[cache hit] public_config");
  }
  else {
    $c->app->log->debug("[cache miss] public_config");
    $cacheval = $c->mongo->get_collection('config')->find_one({config_type => 'public'});
    $c->app->chi->set('public_config', $cacheval, '1 day');
    $cacheval = $c->app->chi->get('public_config');
  }

  return $cacheval;
}

sub get_public_config_for_api {
  my $self = shift;
  my $doc  = $self->get_public_config(@_);
  return $self->hydrate_public_config_doc($doc);
}

sub get_private_config {
  my $self    = shift;
  my $c       = shift;
  my $nocache = shift;

  my $cacheval = $c->app->chi->get('private_config');
  if ($cacheval && !$nocache) {

    # $c->app->log->debug("[cache hit] private_config");
  }
  else {
    $c->app->log->debug("[cache miss] private_config");
    $cacheval = $c->mongo->get_collection('config')->find_one({config_type => 'private'});
    $c->app->chi->set('private_config', $cacheval, '1 day');
    $cacheval = $c->app->chi->get('private_config');
  }

  return $cacheval;
}

1;
__END__
