package PhaidraAPI::Model::Policy::Opa;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::UserAgent;
use Mojo::JSON  qw(decode_json encode_json true false);
use Time::HiRes qw(gettimeofday tv_interval);

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

  my $opa_url     = $c->app->config->{opa}->{url}         // 'http://opa:8181';
  my $policy_path = $c->app->config->{opa}->{policy_path} // '/v1/data/phaidra/authz/allow';

  my $url = $opa_url . $policy_path;
  my $tx  = $c->app->ua->post($url => json => {input => $input});
  if (my $err = $tx->error) {
    my $detail = $err->{message} // 'unknown error';
    $detail .= " code[$err->{code}]" if defined $err->{code};
    $c->app->log->error("OPA request failed: $detail url[$url]");
    return $self->_handle_failure($c, $input, $t0, 'opa_error');
  }

  my $body     = $tx->res->json  // {};
  my $decision = $body->{result} // {};

  $decision->{duration_ms} = int(tv_interval($t0) * 1000);
  $decision->{source}      = 'opa';

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

  unless ($pid) {
    return $self->_legacy_action_fallback($c, $input, $t0, $reason);
  }

  require PhaidraAPI::Model::Authorization;
  my $authz_model = PhaidraAPI::Model::Authorization->new;

  my $op     = $self->_legacy_op_for_action($input->{action}->{id});
  my $legacy = $authz_model->check_rights_legacy($c, $pid, $op);

  my $decision = $self->_legacy_to_decision($legacy);
  $decision->{source}      = $reason;
  $decision->{duration_ms} = int(tv_interval($t0) * 1000);

  return $decision;
}

sub _legacy_action_fallback {
  my ($self, $c, $input, $t0, $reason) = @_;

  my $action_id = $input->{action}->{id}        // '';
  my $username  = $input->{subject}->{username} // '';

  my %account_actions = map {$_ => 1} qw(
    settings_read settings_write
    group_read group_write
    list_read list_write
    template_read template_write
    stats_myobjects directory_self
    termsofuse_read termsofuse_agree
    users_search
    ir_allowsubmit ir_submit ir_notifications
    feedback request_doi
    inactive_objects_read
  );

  my %admin_actions = map {$_ => 1} qw(
    admin_storage_usage admin_storage_avg_year admin_imageserver_storage_avg_year
    admin_send_daily_report
    admin_config_private_read admin_config_public_write admin_config_private_write
    admin_oai_blacklist admin_index admin_object_index
    admin_imageserver_process admin_tikaserver_process admin_streaming_process
    admin_objects_modify_bulk admin_objects_delete_bulk
    admin_templates_read admin_templates_write
    admin_ir_embargocheck
  );

  my %ir_admin_actions = map {$_ => 1} qw(
    ir_admin_listdata ir_admin_events ir_admin_puresearch ir_admin_pureimport_locks
    ir_admin_accept ir_admin_reject ir_admin_approve
    ir_admin_pureimport_lock ir_admin_pureimport_unlock ir_admin_pureimport_reject
  );

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
  elsif ($action_id eq 'inactive_objects_manage') {
    my $adminuser = $c->app->config->{phaidra}->{adminusername} // '';
    my @roles     = @{$input->{subject}->{roles} // []};
    $allow = ($adminuser ne '' && $username eq $adminuser) ? 1 : 0;
    $allow = 1 if grep {$_ eq 'admin' || $_ eq 'approver'} @roles;
  }
  elsif ($account_actions{$action_id}) {
    $allow = $username ? 1 : 0;
  }
  elsif ($admin_actions{$action_id}) {
    my $adminuser = $c->app->config->{phaidra}->{adminusername} // '';
    $allow = ($adminuser ne '' && $username eq $adminuser) ? 1 : 0;
  }
  elsif ($ir_admin_actions{$action_id}) {
    my @roles = @{$input->{subject}->{roles} // []};
    $allow = (grep {$_ eq 'ir_admin'} @roles) ? 1 : 0;
  }

  return {
    allow       => $allow ? true    : false,
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
  my $msg = 'Forbidden';
  if (($decision->{reason} // '') =~ /^deny_metadata_policy:/) {
    $msg = $decision->{reason};
  }
  $res->{alerts} = [{type => 'error', msg => $msg}];
  return $res;
}

sub _dual_run_compare {
  my ($self, $c, $input, $opa_decision) = @_;

  require PhaidraAPI::Model::Authorization;
  my $authz_model = PhaidraAPI::Model::Authorization->new;

  my $pid = $input->{resource}->{pid};
  return unless $pid;

  my $op              = $self->_legacy_op_for_action($input->{action}->{id});
  my $legacy          = $authz_model->check_rights_legacy($c, $pid, $op);
  my $legacy_decision = $self->_legacy_to_decision($legacy);

  my $opa_allow    = $opa_decision->{allow}    ? 1 : 0;
  my $legacy_allow = $legacy_decision->{allow} ? 1 : 0;

  if ($opa_allow != $legacy_allow) {
    $c->app->log->warn("OPA dual-run mismatch pid[$pid] op[$op] opa[$opa_allow] legacy[$legacy_allow] " . "opa_reason[$opa_decision->{reason}] legacy_reason[$legacy_decision->{reason}]");
  }
}

# Legacy Perl authz only understands r/ro/w/rw.
sub _legacy_op_for_action {
  my ($self, $action_id) = @_;

  return 'r' if ($action_id // '') eq 'read';
  return 'w';
}

1;
