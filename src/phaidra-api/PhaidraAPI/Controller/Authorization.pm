package PhaidraAPI::Controller::Authorization;

use strict;
use warnings;
use v5.10;
use Mojo::ByteStream qw(b);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Config;

sub authorize {
  my $self = shift;

  my $res = {alerts => [], status => 500};

  my $op = $self->stash('op');
  unless ($op eq 'r' or $op eq 'w') {
    $self->app->log->error("Authz op[$op] failed - unknown op");
    $res->{alerts} = [{type => 'error', msg => 'unknown op'}];
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return 0;
  }

  my $controller;
  my $action;
  my $pid;

  if ($op eq 'w') {
    # extract_credentials -> authorize -> action
    $controller = $self->match->stack->[3]{controller};
    $action = $self->match->stack->[3]{action};
    $pid = $self->match->stack->[3]{pid};
  } else {
    # extract_credentials -> action
    $controller = $self->match->stack->[2]{controller};
    $action = $self->match->stack->[2]{action};
    $pid = $self->match->stack->[2]{pid};
  }

  # imageserverproxy is an exception
  # -> the PID is in the query string
  # -> pass this, we'll check rights in imageserver model where we parse the query
  if ($action eq 'imageserverproxy') {
    $self->app->log->debug("Authz controller[$controller] action[$action] op[$op]");
    return 1;
  } else {
    $self->app->log->debug("Authz controller[$controller] action[$action] pid[$pid] op[$op]");
  }

  if (($controller eq 'object') && ($action eq 'delete')) {
    my $confmodel = PhaidraAPI::Model::Config->new;
    my $privconfig = $confmodel->get_private_config($self);
    my $currentuser = $self->stash->{basic_auth_credentials}->{username};
    if ($self->stash->{remote_user}) {
      $currentuser = $self->stash->{remote_user};
    }
    unless ($privconfig->{enabledelete} || ($currentuser eq $self->app->{config}->{phaidra}->{adminusername})) {
      $self->app->log->error("Authz controller[$controller] action[$action] pid[$pid] op[$op] failed - delete is not enabled");
      $res->{alerts} = [{type => 'error', msg => 'delete is not enabled'}];
      $res->{status} = 403;
      $self->render(json => $res, status => $res->{status});
      return 0;
    }
  }

  my $pidNamespace = $self->app->config->{fedora}->{pidnamespace};
  unless ($pid =~ m/^$pidNamespace:\d+$/) {
    $self->app->log->error("Authz controller[$controller] action[$action] pid[$pid] op[$op] failed - wrong pid");
    $res->{alerts} = [{type => 'error', msg => 'wrong pid'}];
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return 0;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  $res         = $authz_model->check_rights($self, $pid, $op);
  if ($res->{status} == 200) {
    return 1;
  } else {
    if ($action eq 'thumbnail' && $res->{status} == 403) {
      $self->res->headers->add('Pragma-Directive' => 'no-cache');
      $self->res->headers->add('Cache-Directive'  => 'no-cache');
      $self->res->headers->add('Cache-Control'    => 'no-cache');
      $self->res->headers->add('Pragma'           => 'no-cache');
      $self->res->headers->add('Expires'          => 0);
      $self->reply->static('images/locked.png');
      return 0;
    } else {
      $self->render(json => $res, status => $res->{status});
      return 0;
    }
  }
}

sub check_rights {

  my $self = shift;

  my $res = {alerts => [], status => 500};

  my $pid          = $self->stash('pid');
  my $pidNamespace = $self->app->config->{fedora}->{pidnamespace};
  unless ($pid =~ m/^$pidNamespace:\d+$/) {
    $self->app->log->error("Authz pid[$pid] failed - wrong pid");
    $res->{status} = 500;
    return $res;
  }
  my $op = $self->stash('op');
  unless ($op eq 'r' or $op eq 'ro' or $op eq 'w' or $op eq 'rw') {
    $self->app->log->error("Authz op[$op] pid[$pid] failed - unknown op");
    $res->{status} = 500;
    return $res;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  $res         = $authz_model->check_rights($self, $pid, $op);

  $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});
}

1;
