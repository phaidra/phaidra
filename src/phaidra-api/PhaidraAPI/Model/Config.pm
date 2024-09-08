package PhaidraAPI::Model::Config;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;

sub get_public_config {
  my $self = shift;
  my $c = shift;

  return $c->mongo->get_collection('config')->find_one({ config_type => 'public' });
}

sub get_private_config {
  my $self = shift;
  my $c = shift;

  return $c->mongo->get_collection('config')->find_one({ config_type => 'private' });
}

1;
__END__
