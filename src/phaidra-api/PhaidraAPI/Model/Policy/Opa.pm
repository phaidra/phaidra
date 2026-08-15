package PhaidraAPI::Model::Policy::Opa;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json true false);
use Time::HiRes qw(gettimeofday tv_interval);

has 'ua' => sub { Mojo::UserAgent->new->connect_timeout(2)->request_timeout(5) };

sub enabled {
  my ($self, $c) = @_;
  return $c->app->config->{opa}->{enabled} ? 1 : 0;
}

sub evaluate {
  my ($self, $c, $input) = @_;

  my $t0 = [gettimeofday];

  unless ($self->enabled($c)) {
    return $self->_legacy_fallback($c, $input, $t0, 'opa_disabled');
  }

  my $opa_url = $c->app->config->{opa}->{url} // 'http://opa:8181';
  my $policy_path = $c->app->config->{opa}->{policy_path} // '/v1/data/phaidra/authz/allow';

  my $url = $opa_url . $policy_path;
  my $tx = $self->ua->post($url => json => {input => $input})->result;

  unless ($tx->is_success) {
    $c->app->log->error('OPA request failed: ' . ($tx->message // 'unknown error'));
    return $self->_handle_failure($c, $input, $t0, 'opa_error');
  }

  my $body = $tx->json;
  my $decision = $body->{result} // {};

  $decision->{duration_ms} = int(tv_interval($t0) * 1000);
  $decision->{source} = 'opa';

  if ($c->app->config->{opa}->{dual_run}) {
    $self->_dual_run_compare($c, $input, $decision);
  }

  return $decision;
}

sub _handle_failure {
  my ($self, $c, $input, $t0, $reason) = @_;

  my $fail_mode = $c->app->config->{opa}->{fail_mode} // 'legacy';

  if ($fail_mode eq 'closed') {
    return {
      allow       => false,
      effect      => 'deny',
      reason      => $reason,
      rights      => '',
      source      => 'opa_fail_closed',
      duration_ms => int(tv_interval($t0) * 1000),
    };
  }

  return $self->_legacy_fallback($c, $input, $t0, $reason);
}

sub _legacy_fallback {
  my ($self, $c, $input, $t0, $reason) = @_;

  my $pid = $input->{resource}->{pid} // '';
  my $op = $input->{action}->{operation};

  unless ($pid) {
    return $self->_legacy_action_fallback($c, $input, $t0, $reason);
  }

  require PhaidraAPI::Model::Authorization;
  my $authz_model = PhaidraAPI::Model::Authorization->new;

  my $pid = $input->{resource}->{pid};
  my $op = $input->{action}->{operation};

  my $legacy = $authz_model->check_rights_legacy($c, $pid, $op);

  my $decision = $self->_legacy_to_decision($legacy);
  $decision->{source} = $reason;
  $decision->{duration_ms} = int(tv_interval($t0) * 1000);

  return $decision;
}

sub _legacy_action_fallback {
  my ($self, $c, $input, $t0, $reason) = @_;

  my $action_id = $input->{action}->{id} // '';
  my $username = $input->{subject}->{username} // '';

  my $allow = 0;
  if ($action_id eq 'create') {
    $allow = $username ? 1 : 0;
  }
  elsif ($action_id eq 'capabilities' || $action_id eq 'check_forms') {
    $allow = 1;
  }
  elsif ($action_id eq 'approve') {
    $allow = 0;
  }

  return {
    allow       => $allow ? true : false,
    effect      => $allow ? 'allow' : 'deny',
    reason      => 'legacy_action',
    rights      => $allow ? 'rw' : '',
    source      => $reason,
    duration_ms => int(tv_interval($t0) * 1000),
  };
}

sub _legacy_to_decision {
  my ($self, $legacy) = @_;

  if ($legacy->{status} == 200) {
    return {
      allow  => true,
      effect => 'allow',
      reason => 'legacy',
      rights => $legacy->{rights} // 'ro',
    };
  }

  return {
    allow  => false,
    effect => 'deny',
    reason => 'legacy_deny',
    rights => '',
  };
}

sub to_legacy_response {
  my ($self, $decision) = @_;

  my $res = {alerts => [], status => 500};

  if ($decision->{allow}) {
    $res->{status} = 200;
    $res->{rights} = $decision->{rights} if $decision->{rights};
    return $res;
  }

  $res->{status} = 403;
  $res->{alerts} = [{type => 'error', msg => 'Forbidden'}];
  return $res;
}

sub _dual_run_compare {
  my ($self, $c, $input, $opa_decision) = @_;

  require PhaidraAPI::Model::Authorization;
  my $authz_model = PhaidraAPI::Model::Authorization->new;

  my $pid = $input->{resource}->{pid};
  my $op = $input->{action}->{operation};

  return unless $pid;

  my $legacy = $authz_model->check_rights_legacy($c, $pid, $op);
  my $legacy_decision = $self->_legacy_to_decision($legacy);

  my $opa_allow = $opa_decision->{allow} ? 1 : 0;
  my $legacy_allow = $legacy_decision->{allow} ? 1 : 0;

  if ($opa_allow != $legacy_allow) {
    $c->app->log->warn(
      "OPA dual-run mismatch pid[$pid] op[$op] opa[$opa_allow] legacy[$legacy_allow] "
        . "opa_reason[$opa_decision->{reason}] legacy_reason[$legacy_decision->{reason}]"
    );
  }
}

1;
