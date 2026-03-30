package PhaidraAPI::Controller::Groups;

use strict;
use warnings;
use v5.10;
use Mojo::JSON       qw(encode_json decode_json);
use Mojo::Util       qw(encode decode);
use Mojo::ByteStream qw(b);
use PhaidraAPI::Model::Directory;
use base 'Mojolicious::Controller';

sub get_group {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $currentuser = $self->stash->{basic_auth_credentials}->{username};
  if ($self->stash->{remote_user}) {
    $currentuser = $self->stash->{remote_user};
  }

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $g               = $directory_model->get_group($self, $gid, $currentuser);

  # there are only results
  $self->render(json => {alerts => [], group => $g}, status => 200);
}

sub get_users_groups {
  my $self = shift;

  my $currentuser = $self->stash->{basic_auth_credentials}->{username};
  if ($self->stash->{remote_user}) {
    $currentuser = $self->stash->{remote_user};
  }

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $g               = $directory_model->get_users_groups($self, $currentuser);

  # there are only results
  $self->render(json => {alerts => [], groups => $g}, status => 200);
}

sub add_group {
  my $self = shift;

  my $name = $self->param('name');

  my $currentuser = $self->stash->{basic_auth_credentials}->{username};
  if ($self->stash->{remote_user}) {
    $currentuser = $self->stash->{remote_user};
  }

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $g               = $directory_model->create_group($self, $name, $currentuser);

  # there are only results
  $self->render(json => {alerts => [], group => $g}, status => 200);
}

sub remove_group {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $currentuser = $self->stash->{basic_auth_credentials}->{username};
  if ($self->stash->{remote_user}) {
    $currentuser = $self->stash->{remote_user};
  }

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $g               = $directory_model->delete_group($self, $gid, $currentuser);

  # there are only results
  $self->render(json => {alerts => []}, status => 200);
}

sub add_members {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $currentuser = $self->stash->{basic_auth_credentials}->{username};
  if ($self->stash->{remote_user}) {
    $currentuser = $self->stash->{remote_user};
  }

  my $members = $self->param('members');
  $members = decode_json(b($members)->encode('UTF-8'));

  my $directory_model = PhaidraAPI::Model::Directory->new;
  for my $m (@{$members->{members}}) {
    $directory_model->add_group_member($self, $gid, $m, $currentuser);
  }

  $self->render(json => {alerts => []}, status => 200);
}

sub remove_members {
  my $self = shift;

  my $gid = $self->stash('gid');

  my $currentuser = $self->stash->{basic_auth_credentials}->{username};
  if ($self->stash->{remote_user}) {
    $currentuser = $self->stash->{remote_user};
  }

  my $members = $self->param('members');
  $members = decode_json(b($members)->encode('UTF-8'));

  my $directory_model = PhaidraAPI::Model::Directory->new;
  for my $m (@{$members->{members}}) {
    $directory_model->remove_group_member($self, $gid, $m, $currentuser);
  }

  $self->render(json => {alerts => []}, status => 200);
}

1;
