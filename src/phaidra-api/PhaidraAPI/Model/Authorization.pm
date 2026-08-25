package PhaidraAPI::Model::Authorization;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Rights;
use PhaidraAPI::Model::Fedora;
use PhaidraAPI::Model::Directory;
use PhaidraAPI::Model::Policy::Context;
use PhaidraAPI::Model::Policy::Opa;
use PhaidraAPI::Model::Policy::Audit;

sub check_rights {
  my ($self, $c, $pid, $action_id, $opts) = @_;
  $opts //= {};

  $action_id = $self->_normalize_action_id($action_id, $opts);

  my $cache_key = $self->_decision_cache_key('object', $pid, $action_id, $opts);
  if (my $cached = $self->_stash_cache_get($c, $cache_key)) {
    $c->app->log->debug("Authz cache hit action_id[$action_id] pid[$pid]");
    return $cached;
  }

  my $context_model = PhaidraAPI::Model::Policy::Context->new;
  my $input         = $context_model->build_object($c, $pid, $action_id, $opts);

  my $opa_model = PhaidraAPI::Model::Policy::Opa->new;
  my $decision  = $opa_model->evaluate($c, $input);

  my $audit_model = PhaidraAPI::Model::Policy::Audit->new;
  $audit_model->log($c, $input, $decision);

  my $legacy = $opa_model->to_legacy_response($decision);
  $self->_stash_cache_set($c, $cache_key, $legacy);
  return $legacy;
}

# Map legacy r/ro/w/rw (and optional opts.action_id) to canonical action ids.
sub _normalize_action_id {
  my ($self, $action_id, $opts) = @_;

  if ($opts->{action_id}) {
    return $opts->{action_id};
  }

  my %legacy = (
    r  => 'read',
    ro => 'read',
    w  => 'write',
    rw => 'write',
  );

  return $legacy{$action_id} if exists $legacy{$action_id // ''};
  return $action_id // 'read';
}

sub check_action {
  my ($self, $c, $action_id, $opts) = @_;
  $opts //= {};

  my $cache_key = $self->_decision_cache_key('action', '', $action_id, $opts);
  if (my $cached = $self->_stash_cache_get($c, $cache_key)) {
    $c->app->log->debug("Authz cache hit action_id[$action_id]");
    return $cached;
  }

  my $context_model = PhaidraAPI::Model::Policy::Context->new;
  my $input         = $context_model->build_action_only($c, $action_id, $opts);

  my $opa_model = PhaidraAPI::Model::Policy::Opa->new;
  my $decision  = $opa_model->evaluate($c, $input);

  my $audit_model = PhaidraAPI::Model::Policy::Audit->new;
  $audit_model->log($c, $input, $decision);

  $self->_stash_cache_set($c, $cache_key, $decision);
  return $decision;
}

# Request-scoped: bridge + controller often check the same pid/action twice.
sub _decision_cache_key {
  my ($self, $kind, $pid, $action_id, $opts) = @_;
  $opts //= {};
  my $dsid     = $opts->{dsid}     // '';
  my $endpoint = $opts->{endpoint} // '';
  my $meta     = ($opts->{metadata} || $opts->{existing_metadata}) ? 'meta' : '';
  return join('|', "authz_$kind", $pid // '', $action_id // '', $dsid, $endpoint, $meta);
}

sub _stash_cache_get {
  my ($self, $c, $key) = @_;
  my $cache = $c->stash->{authz_decision_cache} // {};
  return $cache->{$key};
}

sub _stash_cache_set {
  my ($self, $c, $key, $value) = @_;
  $c->stash->{authz_decision_cache} //= {};
  $c->stash->{authz_decision_cache}->{$key} = $value;
  return $value;
}

sub check_rights_legacy {
  no warnings 'uninitialized';
  my ($self, $c, $pid, $op) = @_;

  my $res = {alerts => [], status => 500};

  my $currentuser = $c->stash->{basic_auth_credentials}->{username};
  if ($c->stash->{remote_user}) {
    $currentuser = $c->stash->{remote_user};
  }

  unless ($currentuser) {
    unless ($op eq 'r' or $op eq 'ro') {
      $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] DENIED: no user");
      $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
      $res->{status} = 403;
      return $res;
    }
  }

  # admin can do anything
  if ($currentuser eq $c->app->{config}->{phaidra}->{adminusername}) {
    $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] GRANTED: admin");
    $res->{rights} = 'rw';
    $res->{status} = 200;
    return $res;
  }

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $userdata        = $directory_model->get_user_data($c, $currentuser);
  unless ($userdata) {
    $c->app->log->error("Authz op[$op] pid[$pid] currentuser[$currentuser] get_user_data failed");
    $res->{status} = 500;
    return $res;
  }

  # superuserforallusers can do anything on any object
  if ($userdata->{superuserforallusers}) {
    $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] GRANTED: superuserforallusers");
    $res->{rights} = 'rw';
    $res->{status} = 200;
    return $res;
  }

  # superuserforallusers = phaidradmins
  if ($userdata->{ldapgroups}) {
    for my $ldapgroup (@{$userdata->{ldapgroups}}) {
      if ($ldapgroup eq 'phaidradmins') {
        $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] GRANTED: ldapgroup phaidradmins");
        $res->{rights} = 'rw';
        $res->{status} = 200;
        return $res;
      }
    }
  }

  # if defined, users with this affiliation are superuserforallusers
  if (exists($ENV{"SHIB_SUPERUSER_AFFILIATION"})) {
    for my $aff (@{$userdata->{affiliation}}) {
      if ($aff eq $ENV{"SHIB_SUPERUSER_AFFILIATION"}) {
        $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] GRANTED: SHIB_SUPERUSER_AFFILIATION: $aff");
        $res->{rights} = 'rw';
        $res->{status} = 200;
        return $res;
      }
    }
  }

  my $fedora_model = PhaidraAPI::Model::Fedora->new;
  my $fres         = $fedora_model->getObjectProperties($c, $pid);
  if ($fres->{status} ne 200) {
    $c->app->log->error("Authz op[$op] pid[$pid] currentuser[$currentuser] failed");
    $c->app->log->error($c->app->dumper($fres->{alerts}));
    push @{$res->{alerts}}, @{$fres->{alerts}} if scalar @{$fres->{alerts}} > 0;
    $res->{status} = 500;
    return $res;
  }

  my $owner = $fres->{owner};
  my $state = $fres->{state};

  # user can do anything on owned object
  if ($currentuser eq $owner) {
    $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] GRANTED: owner");
    $res->{rights} = 'rw';
    $res->{status} = 200;
    return $res;
  }

  #######################################
  # no write rights pass this point
  if ($op eq 'rw' or $op eq 'w') {
    $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] DENIED: no write permission");
    $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
    $res->{status} = 403;
    return $res;
  }
  #######################################

  # for non-writers only consider Active objects
  if ($state ne 'Active') {
    $c->app->log->info("Authz op[$op] pid[$pid] state[$state] currentuser[$currentuser] DENIED: object is not Active");
    $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
    $res->{status} = 403;
    return $res;
  }

  # if the object has non-empty RIGHTS, it's restricted.
  # Only users/groups/orgunits in the list are allowed to READ
  my $rights_model = PhaidraAPI::Model::Rights->new;
  my $rightsres    = $rights_model->get_object_rights_json($c, $pid, $c->app->config->{fedora}->{adminuser}, $c->app->config->{fedora}->{adminpass});
  if ($rightsres->{status} ne 200) {
    if ($rightsres->{status} eq 404) {
      $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] GRANTED: no rights datastream");
      $res->{rights} = 'ro';
      $res->{status} = 200;
      return $res;
    }
    $c->app->log->error("Authz op[$op] pid[$pid] currentuser[$currentuser] failed");
    $c->app->log->error("RIGHTS:\n" . $c->app->dumper($rightsres->{alerts}));
    push @{$res->{alerts}}, @{$rightsres->{alerts}} if scalar @{$rightsres->{alerts}} > 0;
    $res->{status} = 500;
    return $res;
  }
  my $rights = $rightsres->{rights};

  my $rightsAreEmpty = 1;

  if (exists($rights->{'username'})) {
    $rightsAreEmpty = 0;
    for my $def (@{$rights->{'username'}}) {
      my $v;
      if (ref($def) eq 'HASH') {
        $v = $def->{value};
      }
      else {
        $v = $def;
      }
      if ($currentuser eq $v) {
        $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] GRANTED: rule username[$currentuser]");
        $res->{rights} = 'ro';
        $res->{status} = 200;
        return $res;
      }
    }
  }

  if (exists($rights->{'affiliation'})) {
    $rightsAreEmpty = 0;
    for my $def (@{$rights->{'affiliation'}}) {
      my $v;
      if (ref($def) eq 'HASH') {
        $v = $def->{value};
      }
      else {
        $v = $def;
      }
      for my $aff (@{$userdata->{affiliation}}) {
        if ($aff eq $v) {
          $c->app->log->info("Authz op[$op] pid[$pid] username[$currentuser] GRANTED: rule affiliation[$aff]");
          $res->{rights} = 'ro';
          $res->{status} = 200;
          return $res;
        }
      }
    }
  }

  if (exists($rights->{'department'})) {
    $rightsAreEmpty = 0;
    for my $def (@{$rights->{'department'}}) {
      my $v;
      if (ref($def) eq 'HASH') {
        $v = $def->{value};
      }
      else {
        $v = $def;
      }
      for my $orgul2 (@{$userdata->{org_units_l2}}) {
        if ($orgul2 eq $v) {
          $c->app->log->info("Authz op[$op] pid[$pid] username[$currentuser] GRANTED: rule orgul2[$orgul2]");
          $res->{rights} = 'ro';
          $res->{status} = 200;
          return $res;
        }
      }
    }
  }

  if (exists($rights->{'faculty'})) {
    $rightsAreEmpty = 0;
    for my $def (@{$rights->{'faculty'}}) {
      my $v;
      if (ref($def) eq 'HASH') {
        $v = $def->{value};
      }
      else {
        $v = $def;
      }
      for my $orgul1 (@{$userdata->{org_units_l1}}) {
        if ($orgul1 eq $v) {
          $c->app->log->info("Authz op[$op] pid[$pid] username[$currentuser] GRANTED: rule orgul1[$orgul1]");
          $res->{rights} = 'ro';
          $res->{status} = 200;
          return $res;
        }
      }
    }
  }

  if (exists($rights->{'gruppe'})) {
    $rightsAreEmpty = 0;
    for my $def (@{$rights->{'gruppe'}}) {
      my $v;
      if (ref($def) eq 'HASH') {
        $v = $def->{value};
      }
      else {
        $v = $def;
      }
      for my $g (@{$userdata->{groups}}) {
        if ($g->{groupid} eq $v) {
          $c->app->log->info("Authz op[$op] pid[$pid] username[$currentuser] GRANTED: rule group[" . $g->{groupid} . "]");
          $res->{rights} = 'ro';
          $res->{status} = 200;
          return $res;
        }
      }
    }
  }

  if (exists($rights->{'spl'}) or exists($rights->{'kennzahl'}) or exists($rights->{'perfunk'})) {
    $rightsAreEmpty = 0;
    $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] DENIED: deprecated definition");
    $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
    $res->{status} = 403;
    return $res;
  }

  if ($rightsAreEmpty) {
    $c->app->log->info("Authz op[$op] pid[$pid] username[$currentuser] GRANTED: no rules defined");
    $res->{rights} = 'ro';
    $res->{status} = 200;
    return $res;
  }
  else {
    $c->app->log->info("Authz op[$op] pid[$pid] currentuser[$currentuser] DENIED: no matching rule");
    $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
    $res->{status} = 403;
    return $res;
  }

}

1;
__END__
