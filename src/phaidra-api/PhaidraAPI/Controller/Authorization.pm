package PhaidraAPI::Controller::Authorization;

use strict;
use warnings;
use v5.10;
use Mojo::ByteStream qw(b);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Policy::Opa;
use PhaidraAPI::Model::Policy::Metadata;

# Actions that require a Fedora object pid and check_rights.
my %OBJECT_ACTIONS = map {$_ => 1} qw(
  read
  write
  delete
  restrict
  change_owner
  approve
);

sub authorize {
  my $self = shift;

  my $res = {alerts => [], status => 500};

  my $action_id = $self->_route_attr('action_id');
  unless (defined $action_id && $action_id ne '') {
    $self->app->log->error('Authz failed - route missing action_id');
    $res->{alerts} = [{type => 'error', msg => 'misconfigured route (action_id)'}];
    $res->{status} = 500;
    $self->render(json => $res, status => $res->{status});
    return 0;
  }

  my $pid  = $self->param('pid')  // $self->_route_attr('pid');
  my $dsid = $self->param('dsid') // $self->_route_attr('dsid') // '';

  $self->app->log->debug("Authz action_id[$action_id] pid[" . ($pid // '') . "] dsid[$dsid]");

  my $authz_model = PhaidraAPI::Model::Authorization->new;

  # Non-object actions (create, settings, admin/IR, …): OPA check_action only.
  # Admin/IR routes may include :pid in the URL but are not Fedora object ACL checks.
  unless ($OBJECT_ACTIONS{$action_id}) {
    my $resource_type = 'account';
    $resource_type = 'object' if $action_id eq 'create';
    $resource_type = 'admin'  if $action_id =~ /^(admin_|ir_admin_)/;

    my $opts = {resource_type => $resource_type};
    if ($action_id eq 'create') {
      my $meta_model = PhaidraAPI::Model::Policy::Metadata->new;
      my $normalized = $meta_model->from_request($self);
      $opts->{metadata} = $normalized if $normalized;
    }

    my $decision = $authz_model->check_action($self, $action_id, $opts);

    if ($decision->{allow}) {
      if ($action_id eq 'create') {
        $self->stash(curated_initial_state => $decision->{initial_state} // 'Inactive');
      }
      return 1;
    }

    $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
    $res->{status} = 403;
    $self->render(json => $res, status => $res->{status});
    return 0;
  }

  my $pidNamespace = $self->app->config->{fedora}->{pidnamespace};
  unless (defined $pid && $pid =~ m/^$pidNamespace:\d+$/) {
    $self->app->log->error("Authz action_id[$action_id] pid[" . ($pid // '') . "] failed - wrong pid");
    $res->{alerts} = [{type => 'error', msg => 'wrong pid'}];
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return 0;
  }

  my $opts     = {dsid => $dsid};
  my $endpoint = $self->_route_endpoint;
  $opts->{endpoint} = $endpoint if $endpoint ne '';

  if ($action_id eq 'write') {
    my $meta_model = PhaidraAPI::Model::Policy::Metadata->new;
    my $normalized = $meta_model->from_request($self);
    if ($normalized) {
      $opts->{metadata} = $normalized;
      my $existing = $meta_model->from_object($self, $pid);
      $opts->{existing_metadata} = $existing if $existing;
    }
  }

  $res = $authz_model->check_rights($self, $pid, $action_id, $opts);
  if ($res->{status} == 200) {
    return 1;
  }

  my $deny_static = $self->_route_attr('authz_deny_static');
  if ($deny_static && $res->{status} == 403) {
    $self->res->headers->add('Pragma-Directive' => 'no-cache');
    $self->res->headers->add('Cache-Directive'  => 'no-cache');
    $self->res->headers->add('Cache-Control'    => 'no-cache');
    $self->res->headers->add('Pragma'           => 'no-cache');
    $self->res->headers->add('Expires'          => 0);
    $self->reply->static($deny_static);
    return 0;
  }

  $self->render(json => $res, status => $res->{status});
  return 0;
}

# Route defaults / captures: stash first, then any match-stack frame (no fixed index).
sub _route_attr {
  my ($self, $key) = @_;

  my $from_stash = $self->stash($key);
  return $from_stash if defined $from_stash && $from_stash ne '';

  # Mojolicious timing quirk: the stash value might not be available yet, because we are in a bridge.
  my $stack = $self->match->stack // [];
  for my $i (reverse 0 .. $#$stack) {
    my $frame = $stack->[$i];
    next unless exists $frame->{$key};
    my $val = $frame->{$key};
    return $val if defined $val && $val ne '';
  }
  return;
}

# Destination controller#action for OPA (content vs public-metadata rights gating).
# During an under() bridge, stash controller/action are still the bridge
# (authorization#authorize) — read the destination frame from the match stack.
sub _route_endpoint {
  my ($self) = @_;

  my $stack = $self->match->stack // [];
  for my $i (reverse 0 .. $#$stack) {
    my $frame = $stack->[$i];
    next unless defined $frame->{action_id} && $frame->{action_id} ne '';
    my $controller = $frame->{controller} // '';
    my $action     = $frame->{action}     // '';
    next if $controller eq '' || $action eq '';
    next if $controller eq 'authorization';
    return lc("$controller#$action");
  }

  return '';
}

sub check_batch {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $payload = $self->req->json   // {};
  my $checks  = $payload->{checks} // [];

  unless (ref($checks) eq 'ARRAY') {
    $res->{status} = 400;
    $res->{alerts} = [{type => 'error', msg => 'checks must be an array'}];
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my @results     = ();

  for my $check (@{$checks}) {
    my $action_id = $check->{action} // 'read';
    if ($check->{pid}) {
      my $legacy = $authz_model->check_rights($self, $check->{pid}, $action_id, {dsid => $check->{dsid} // '',});
      push @results,
        {
        pid    => $check->{pid},
        action => $action_id,
        allow  => ($legacy->{status} == 200) ? \1 : \0,
        };
    }
    else {
      my $decision = $authz_model->check_action(
        $self,
        $action_id,
        { resource_type => $check->{resource_type} // 'submit_form',
          metadata      => $check->{metadata},
        }
      );
      push @results,
        {
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

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $decision    = $authz_model->check_action($self, 'capabilities', {});

  $res->{capabilities} = $decision->{capabilities} // [];

  my $forms_decision = $authz_model->check_action($self, 'check_forms', {});
  $res->{forms} = $forms_decision->{forms} // {};

  $self->render(json => $res, status => $res->{status});
}

1;
