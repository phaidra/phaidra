package PhaidraAPI::Controller::Authorization;

use strict;
use warnings;
use v5.10;
use Mojo::ByteStream qw(b);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Policy::Opa;

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

  my $controller = $self->match->stack->[3]{controller};
  my $action     = $self->match->stack->[3]{action};
  my $pid        = $self->match->stack->[3]{pid};

  if ($action eq 'imageserverproxy') {
    $self->app->log->debug("Authz controller[$controller] action[$action] op[$op]");
    return 1;
  }
  else {
    $self->app->log->debug("Authz controller[$controller] action[$action] pid[$pid] op[$op]");
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

  my $action_id = ($op eq 'w') ? 'write' : 'read';
  if (($controller eq 'object') && ($action eq 'delete')) {
    $action_id = 'delete';
  }
  elsif (($controller eq 'object') && ($action eq 'approve')) {
    $action_id = 'approve';
  }
  elsif (($controller eq 'object') && ($action eq 'rights') && ($op eq 'w')) {
    $action_id = 'restrict';
  }

  my $opts = {
    controller      => $controller,
    endpoint_action => $action,
    action_id       => $action_id,
    dsid            => $self->param('dsid') // '',
  };

  $res = $authz_model->check_rights($self, $pid, $op, $opts);
  if ($res->{status} == 200) {
    return 1;
  }
  else {
    if ($action eq 'thumbnail' && $res->{status} == 403) {
      $self->res->headers->add('Pragma-Directive' => 'no-cache');
      $self->res->headers->add('Cache-Directive'  => 'no-cache');
      $self->res->headers->add('Cache-Control'    => 'no-cache');
      $self->res->headers->add('Pragma'           => 'no-cache');
      $self->res->headers->add('Expires'          => 0);
      $self->reply->static('images/locked.png');
      return 0;
    }
    else {
      $self->render(json => $res, status => $res->{status});
      return 0;
    }
  }
}

sub authorize_uploader {
  my $self = shift;

  my $res = {alerts => [], status => 500};

  my $space = $self->param('space') // $self->stash('space') // 'default';

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $decision = $authz_model->check_action($self, 'create', {
    operation     => 'w',
    space         => $space,
    resource_type => 'object',
  });

  if ($decision->{allow}) {
    $self->stash(curated_initial_state => $decision->{initial_state} // 'Inactive');
    return 1;
  }

  $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
  $res->{status} = 403;
  $self->render(json => $res, status => $res->{status});
  return 0;
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
  my $opts = {
    dsid      => $self->param('dsid') // '',
    action_id => $self->param('action') // undef,
    space     => $self->param('space') // 'default',
  };
  $res = $authz_model->check_rights($self, $pid, $op, $opts);

  $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});
}

sub check_batch {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $payload = $self->req->json // {};
  my $checks = $payload->{checks} // [];

  unless (ref($checks) eq 'ARRAY') {
    $res->{status} = 400;
    $res->{alerts} = [{type => 'error', msg => 'checks must be an array'}];
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my @results = ();

  for my $check (@{$checks}) {
    my $action_id = $check->{action} // 'read';
    if ($check->{pid}) {
      my $legacy = $authz_model->check_rights(
        $self,
        $check->{pid},
        $check->{operation} // 'r',
        {
          action_id => $action_id,
          dsid      => $check->{dsid} // '',
          space     => $check->{space} // 'default',
        }
      );
      push @results, {
        pid    => $check->{pid},
        action => $action_id,
        allow  => ($legacy->{status} == 200) ? \1 : \0,
      };
    }
    else {
      my $decision = $authz_model->check_action($self, $action_id, {
        operation     => $check->{operation} // 'r',
        space         => $check->{space} // 'default',
        resource_type => $check->{resource_type} // 'submit_form',
        metadata      => $check->{metadata},
      });
      push @results, {
        action => $action_id,
        form   => $check->{form},
        allow  => $decision->{allow} ? \1 : \0,
        reason => $decision->{reason},
      };
    }
  }

  $res->{results} = \@results;
  $self->render(json => $res, status => $res->{status});
}

sub capabilities {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $space = $self->param('space') // 'default';

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $decision = $authz_model->check_action($self, 'capabilities', {
    operation => 'r',
    space     => $space,
  });

  $res->{capabilities} = $decision->{capabilities} // [];

  my $forms_decision = $authz_model->check_action($self, 'check_forms', {
    operation => 'r',
    space     => $space,
  });
  $res->{forms} = $forms_decision->{forms} // {};

  $self->render(json => $res, status => $res->{status});
}

1;
