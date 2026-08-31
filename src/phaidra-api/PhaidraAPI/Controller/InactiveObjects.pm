package PhaidraAPI::Controller::InactiveObjects;

use strict;
use warnings;
use v5.10;
use Mojo::JSON qw(true false);
use PhaidraAPI::Model::InactiveObjects;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Object;
use base 'Mojolicious::Controller';

# Single capabilities check: can_manage (admin/approver) and is_admin.
sub _staff_flags {
  my $self = shift;

  if (my $cached = $self->stash->{inactive_objects_staff_flags}) {
    return @{$cached};
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $decision    = $authz_model->check_action($self, 'capabilities', {});
  my $caps        = $decision->{capabilities} // [];
  my %cap         = map {$_ => 1} @{$caps};

  my $username  = $self->stash->{basic_auth_credentials}->{username} // '';
  my $adminuser = $self->app->config->{phaidra}->{adminusername}     // '';
  my $is_admin  = ($cap{admin} || ($adminuser ne '' && $username eq $adminuser)) ? 1 : 0;

  # inactive_objects_manage / approve both come from upload.can_approve in OPA.
  my $can_manage = ($cap{inactive_objects_manage} || $cap{approve} || $is_admin) ? 1 : 0;

  $self->stash->{inactive_objects_staff_flags} = [$can_manage, $is_admin];
  return ($can_manage, $is_admin);
}

sub _can_manage {
  my $self = shift;
  my ($can_manage) = $self->_staff_flags;
  return $can_manage;
}

sub _is_admin {
  my $self = shift;
  my (undef, $is_admin) = $self->_staff_flags;
  return $is_admin;
}

# Curators may only act on status=approval rows; admins on any.
sub _assert_staff_row {
  my ($self, $row, $can_manage, $is_admin) = @_;

  unless ($can_manage) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Forbidden'}], status => 403}, status => 403);
    return 0;
  }
  my $row_status = $row->{status} // '';
  unless ($is_admin || $row_status eq 'approval') {
    $self->render(json => {alerts => [{type => 'error', msg => 'Forbidden'}], status => 403}, status => 403);
    return 0;
  }
  return 1;
}

sub list {
  my $self = shift;

  my $owner = $self->stash->{basic_auth_credentials}->{username};
  my ($can_manage, $is_admin) = $self->_staff_flags;
  my $model = PhaidraAPI::Model::InactiveObjects->new;

  my $opts = {
    page  => $self->param('page'),
    limit => $self->param('limit'),
    q     => $self->param('q'),
    sort  => $self->param('sort'),
    order => $self->param('order'),
  };
  if (!$is_admin && $can_manage) {
    $opts->{status} = 'approval';
  }
  elsif (!$is_admin) {
    $opts->{owner} = $owner;
  }

  my $res = $model->list($self, $opts);
  $res->{can_manage} = $can_manage ? true : false;
  $res->{is_admin}   = $is_admin   ? true : false;

  $self->render(json => $res, status => $res->{status});
}

sub register {
  my $self = shift;

  my $pid = $self->stash('pid');
  unless ($pid) {
    $pid = $self->param('pid');
  }
  unless ($pid) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No PID provided'}], status => 400}, status => 400);
    return;
  }
  unless ($pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}], status => 400}, status => 400);
    return;
  }

  my $source   = $self->param('source');
  my $status   = $self->param('status');
  my $is_admin = $self->_is_admin;
  unless ($is_admin) {
    $status = 'approval';
  }

  my $model = PhaidraAPI::Model::InactiveObjects->new;
  my $res   = $model->register_from_pid($self, $pid, $source, $status);

  $self->render(json => $res, status => $res->{status});
}

sub activate {
  my $self = shift;

  my $pid = $self->stash('pid');
  unless ($pid && $pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}], status => 400}, status => 400);
    return;
  }

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};
  my ($can_manage, $is_admin) = $self->_staff_flags;

  my $model = PhaidraAPI::Model::InactiveObjects->new;
  my $row   = $model->get_by_pid($self, $pid);
  if ($row->{status} ne 200) {
    $self->render(json => $row, status => $row->{status});
    return;
  }
  return unless $self->_assert_staff_row($row->{object}, $can_manage, $is_admin);

  my $object_model = PhaidraAPI::Model::Object->new;
  my $mod          = $object_model->approve($self, $pid, $username, $password);
  if ($mod->{status} ne 200) {
    $self->render(json => $mod, status => $mod->{status});
    return;
  }

  my $rm = $model->remove($self, $pid);
  if ($rm->{status} ne 200) {
    $self->render(json => $rm, status => $rm->{status});
    return;
  }

  $self->render(json => {alerts => [], status => 200, pid => $pid}, status => 200);
}

sub remove {
  my $self = shift;

  my $pid = $self->stash('pid');
  unless ($pid && $pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}], status => 400}, status => 400);
    return;
  }

  my ($can_manage, $is_admin) = $self->_staff_flags;

  my $model = PhaidraAPI::Model::InactiveObjects->new;
  my $row   = $model->get_by_pid($self, $pid);
  if ($row->{status} ne 200) {
    $self->render(json => $row, status => $row->{status});
    return;
  }
  return unless $self->_assert_staff_row($row->{object}, $can_manage, $is_admin);

  my $res = $model->remove($self, $pid);
  $self->render(json => $res, status => $res->{status});
}

sub delete {
  my $self = shift;

  my $pid = $self->stash('pid');
  unless ($pid && $pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}], status => 400}, status => 400);
    return;
  }

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};
  my ($can_manage, $is_admin) = $self->_staff_flags;

  my $model = PhaidraAPI::Model::InactiveObjects->new;
  my $row   = $model->get_by_pid($self, $pid);
  if ($row->{status} ne 200) {
    $self->render(json => $row, status => $row->{status});
    return;
  }
  return unless $self->_assert_staff_row($row->{object}, $can_manage, $is_admin);

  my $object_model = PhaidraAPI::Model::Object->new;
  my $del          = $object_model->delete($self, $pid, $username, $password);
  if ($del->{status} ne 200) {
    $self->render(json => $del, status => $del->{status});
    return;
  }

  my $rm = $model->remove($self, $pid);
  if ($rm->{status} ne 200) {
    $self->render(json => $rm, status => $rm->{status});
    return;
  }

  $self->render(json => {alerts => [], status => 200, pid => $pid}, status => 200);
}

1;
