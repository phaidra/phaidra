package PhaidraAPI::Model::Session::Store::Mongo;

use strict;
use warnings;
use base 'MojoX::Session::Store';
use Data::Dumper;

__PACKAGE__->attr('mongo');
__PACKAGE__->attr('log');

sub create {
  my ($self, $sid, $expires, $data) = @_;
  $self->mongo->get_collection('session')->update_one({_id => $sid}, {'$set' => {expires => $expires, data => $data}}, {upsert => 1});
  return 1;
}

sub update {
  shift->create(@_);
}

sub load {
  my ($self, $sid) = @_;

  my $res     = $self->mongo->get_collection('session')->find_one({_id => $sid});
  my $expires = $res->{expires};

  return ($expires, $res->{data});
}

sub delete {
  my ($self, $sid) = @_;

  my $res = $self->mongo->get_collection('session')->delete_one({_id => $sid});

  return 1;
}

1;

