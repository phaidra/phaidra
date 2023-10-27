package PhaidraAPI::Controller::Groups;

use strict;
use warnings;
use v5.10;
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(encode decode);
use Mojo::ByteStream qw(b);

use base 'Mojolicious::Controller';

sub get_group {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $g = $self->app->directory->get_group($self, $gid, $self->stash->{basic_auth_credentials}->{username});

  # there are only results
  $self->render(json => {alerts => [], group => $g}, status => 200);
}

sub get_users_groups {
  my $self = shift;

  my $g = $self->app->directory->get_users_groups($self, $self->stash->{basic_auth_credentials}->{username});

  # there are only results
  $self->render(json => {alerts => [], groups => $g}, status => 200);
}

sub add_group {
  my $self = shift;

  my $name = $self->param('name');

  my $g = $self->app->directory->create_group($self, $name, $self->stash->{basic_auth_credentials}->{username});

  # there are only results
  $self->render(json => {alerts => [], group => $g}, status => 200);
}

sub remove_group {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $g = $self->app->directory->delete_group($self, $gid, $self->stash->{basic_auth_credentials}->{username});

  # there are only results
  $self->render(json => {alerts => []}, status => 200);
}

sub add_members {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $members = $self->param('members');
  $members = decode_json(b($members)->encode('UTF-8'));

  for my $m (@{$members->{members}}) {
    $self->app->directory->add_group_member($self, $gid, $m, $self->stash->{basic_auth_credentials}->{username});
  }

  $self->render(json => {alerts => []}, status => 200);
}

sub remove_members {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $members = $self->param('members');
  $members = decode_json(b($members)->encode('UTF-8'));

  for my $m (@{$members->{members}}) {
    $self->app->directory->remove_group_member($self, $gid, $m, $self->stash->{basic_auth_credentials}->{username});
  }

  $self->render(json => {alerts => []}, status => 200);
}

1;
