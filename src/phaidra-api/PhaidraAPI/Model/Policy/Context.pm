package PhaidraAPI::Model::Policy::Context;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Directory;
use PhaidraAPI::Model::Fedora;
use PhaidraAPI::Model::Rights;
use Mojo::JSON qw(true false);
use POSIX      qw(strftime);

sub build_object {
  my ($self, $c, $pid, $action_id, $opts) = @_;
  $opts //= {};

  my $remote_address = $self->_remote_address($c);
  my $subject        = $self->_build_subject($c, $remote_address);
  my $resource       = $self->_build_resource($c, $pid, $opts);
  my $action         = $self->_build_action($c, $action_id, $opts);
  my $config         = $self->_build_config($c);

  return {
    subject     => $subject,
    resource    => $resource,
    action      => $action,
    environment => {
      timestamp      => strftime('%Y-%m-%dT%H:%M:%SZ', gmtime()),
      institution    => $c->app->config->{opa}->{institution} // 'default',
      remote_address => $remote_address,
    },
    config => $config,
  };
}

sub build_action_only {
  my ($self, $c, $action_id, $opts) = @_;
  $opts //= {};

  my $remote_address = $self->_remote_address($c);
  my $subject        = $self->_build_subject($c, $remote_address);
  my $action         = $self->_build_action($c, $action_id, $opts);

  my $resource = {type => $opts->{resource_type} // 'object',};

  if ($opts->{metadata}) {
    $resource->{metadata} = $opts->{metadata};
  }

  return {
    subject     => $subject,
    resource    => $resource,
    action      => $action,
    environment => {
      timestamp      => strftime('%Y-%m-%dT%H:%M:%SZ', gmtime()),
      institution    => $c->app->config->{opa}->{institution} // 'default',
      remote_address => $remote_address,
    },
    config => $self->_build_config($c),
  };
}

sub _remote_address {
  my ($self, $c) = @_;

  return $c->tx->remote_address // '';
}

sub _current_username {
  my ($self, $c) = @_;

  my $username = $c->stash->{basic_auth_credentials}->{username};
  if ($c->stash->{remote_user}) {
    $username = $c->stash->{remote_user};
  }

  return $username;
}

sub _build_subject {
  my ($self, $c, $remote_address) = @_;

  my $username        = $self->_current_username($c);
  my $directory_model = PhaidraAPI::Model::Directory->new;

  my $userdata = {};
  if ($username) {
    $userdata = $directory_model->get_user_data($c, $username) // {};
  }

  my @roles = $self->_compute_roles($c, $username, $userdata);

  my @project_groups = ();
  if ($userdata->{groups}) {
    for my $g (@{$userdata->{groups}}) {
      push @project_groups, $g->{groupid} if $g->{groupid};
    }
  }

  my $auth_method = 'anonymous';
  if ($username) {
    if ($c->stash->{remote_user}) {
      $auth_method = 'shib';
    }
    elsif ($c->stash->{mojox_session}) {
      $auth_method = 'token';
    }
    else {
      $auth_method = 'basic';
    }
  }

  return {
    username       => $username // '',
    authenticated  => $username ? true : false,
    auth_method    => $auth_method,
    roles          => \@roles,
    affiliations   => $userdata->{affiliation}  // [],
    org_units_l1   => $userdata->{org_units_l1} // [],
    org_units_l2   => $userdata->{org_units_l2} // [],
    ldap_groups    => $userdata->{ldapgroups}   // [],
    project_groups => \@project_groups,
    remote_address => $remote_address // '',
    ip             => $remote_address // '',
  };
}

sub _compute_roles {
  my ($self, $c, $username, $userdata) = @_;
  my @roles = ();

  return @roles unless $username;

  if ($username eq ($c->app->config->{phaidra}->{adminusername} // '')) {
    push @roles, 'admin';
  }

  # Fedora admin gets elevated privileges for repository service operations
  if ($username eq ($c->app->config->{fedora}->{adminuser} // '')) {
    push @roles, 'admin' unless grep {$_ eq 'admin'} @roles;
  }

  if ($userdata->{isadmin}) {
    push @roles, 'admin' unless grep {$_ eq 'admin'} @roles;
  }

  if ($userdata->{superuserforallusers}) {
    push @roles, 'superuser';
  }

  if ($userdata->{ldapgroups}) {
    for my $ldapgroup (@{$userdata->{ldapgroups}}) {
      if ($ldapgroup eq 'phaidradmins') {
        push @roles, 'superuser' unless grep {$_ eq 'superuser'} @roles;
      }
    }
  }

  if (exists($ENV{'SHIB_SUPERUSER_AFFILIATION'}) && $userdata->{affiliation}) {
    for my $aff (@{$userdata->{affiliation}}) {
      if ($aff eq $ENV{'SHIB_SUPERUSER_AFFILIATION'}) {
        push @roles, 'superuser' unless grep {$_ eq 'superuser'} @roles;
      }
    }
  }
  
  # Uncurated submit: Directory/env default_role (later also per-user assignments).
  # Read from live config, not cached userdata, so clearing default_role takes effect immediately.
  my $default_role = $c->app->config->{phaidra}->{default_role} // '';
  if ($default_role ne '') {
    push @roles, $default_role unless grep {$_ eq $default_role} @roles;
  }

  # Institutional repository admin account (public config iraccount)
  eval {
    require PhaidraAPI::Model::Config;
    my $confmodel = PhaidraAPI::Model::Config->new;
    my $pubconfig = $confmodel->get_public_config($c);
    if ($pubconfig->{iraccount} && $username eq $pubconfig->{iraccount}) {
      push @roles, 'ir_admin';
    }
  };

  return @roles;
}

sub _build_resource {
  my ($self, $c, $pid, $opts) = @_;

  my $resource = {
    type   => $opts->{resource_type} // 'object',
    pid    => $pid                   // '',
    dsid   => $opts->{dsid}          // '',
    rights => {},
  };

  if ($pid) {
    unless ($c->stash->{policy_object_cache}) {
      $c->stash->{policy_object_cache} = {};
    }

    unless ($c->stash->{policy_object_cache}->{$pid}) {
      my $fedora_model = PhaidraAPI::Model::Fedora->new;
      my $fres         = $fedora_model->getObjectProperties($c, $pid);
      my $cache        = {fedora => $fres, rights => {}};

      if ($fres->{status} eq 200) {
        my $rights_model = PhaidraAPI::Model::Rights->new;
        my $rightsres    = $rights_model->get_object_rights_json($c, $pid, $c->app->config->{fedora}->{adminuser}, $c->app->config->{fedora}->{adminpass});
        if ($rightsres->{status} eq 200) {
          $cache->{rights} = $rightsres->{rights};
        }
      }

      $c->stash->{policy_object_cache}->{$pid} = $cache;
    }

    my $cached = $c->stash->{policy_object_cache}->{$pid};
    if ($cached->{fedora}->{status} eq 200) {
      $resource->{owner} = $cached->{fedora}->{owner} // '';
      $resource->{state} = $cached->{fedora}->{state} // '';
    }
    $resource->{rights} = $cached->{rights} // {};
  }

  if ($opts->{metadata}) {
    $resource->{metadata} = $opts->{metadata};
  }
  if ($opts->{existing_metadata}) {
    $resource->{existing_metadata} = $opts->{existing_metadata};
  }

  return $resource;
}

sub _build_action {
  my ($self, $c, $action_id, $opts) = @_;

  my $controller      = $opts->{controller};
  my $endpoint_action = $opts->{endpoint_action};
  my $endpoint        = $opts->{endpoint} // '';
  if (!$endpoint && $controller && $endpoint_action) {
    $endpoint = "$controller#$endpoint_action";
  }

  return {
    id       => $action_id,
    endpoint => $endpoint,
  };
}

sub _build_config {
  my ($self, $c) = @_;

  my $confmodel  = PhaidraAPI::Model::Config->new;
  my $privconfig = $confmodel->get_private_config($c) // {};

  my @canmodifyownerid = ();
  if ($c->app->config->{authorization} && $c->app->config->{authorization}->{canmodifyownerid}) {
    @canmodifyownerid = @{$c->app->config->{authorization}->{canmodifyownerid}};
  }

  return {
    admin_username   => $c->app->config->{phaidra}->{adminusername} // '',
    enabledelete     => $privconfig->{enabledelete} ? true : false,
    canmodifyownerid => \@canmodifyownerid,
    readonly         => ($c->app->config->{readonly} // 0) ? true : false,
  };
}

1;
