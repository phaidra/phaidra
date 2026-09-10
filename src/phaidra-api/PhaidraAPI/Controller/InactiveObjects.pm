package PhaidraAPI::Controller::InactiveObjects;

use strict;
use warnings;
use v5.10;
use MIME::Lite::TT::HTML;
use Mojo::JSON qw(true false);
use PhaidraAPI::Model::InactiveObjects;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Directory;
use PhaidraAPI::Model::Config;
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

# Curators may only act on curated_submit rows; admins on any.
sub _assert_staff_row {
  my ($self, $row, $can_manage, $is_admin) = @_;

  unless ($can_manage) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Forbidden'}], status => 403}, status => 403);
    return 0;
  }
  my $row_source = $row->{source} // '';
  unless ($is_admin || $row_source eq 'curated_submit') {
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

    # Curators see the approval queue, plus their own inactive deferred-upload rows.
    $opts->{owner_or_approval} = $owner;
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
    $source = 'curated_submit' unless defined $source && $source ne '';
    $status = 'Pending approval';
  }

  my $model = PhaidraAPI::Model::InactiveObjects->new;
  my $res   = $model->register_from_pid($self, $pid, $source, $status);

  $self->render(json => $res, status => $res->{status});
}

sub set_status {
  my $self = shift;

  my $pid = $self->stash('pid');
  unless ($pid && $pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}], status => 400}, status => 400);
    return;
  }

  my $status = $self->param('status');
  unless (defined $status && $status ne '') {
    my $payload = $self->req->json;
    if ($payload && ref($payload) eq 'HASH' && defined $payload->{status}) {
      $status = $payload->{status};
    }
  }
  unless (defined $status && $status ne '') {
    $self->render(json => {alerts => [{type => 'error', msg => 'No status provided'}], status => 400}, status => 400);
    return;
  }

  my ($can_manage, $is_admin) = $self->_staff_flags;
  my $model = PhaidraAPI::Model::InactiveObjects->new;
  my $row   = $model->get_by_pid($self, $pid);
  if ($row->{status} ne 200) {
    $self->render(json => $row, status => $row->{status});
    return;
  }

  unless ($can_manage || $is_admin) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Forbidden'}], status => 403}, status => 403);
    return;
  }

  my $res = $model->update_status($self, $pid, $status);
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
  my $notify = $self->param('notify');
  $notify = 1 if defined $notify && ($notify eq '1' || lc($notify) eq 'true' || lc($notify) eq 'yes');

  my $model = PhaidraAPI::Model::InactiveObjects->new;
  my $row   = $model->get_by_pid($self, $pid);
  if ($row->{status} ne 200) {
    $self->render(json => $row, status => $row->{status});
    return;
  }
  return unless $self->_assert_staff_row($row->{object}, $can_manage, $is_admin);

  my $owner  = $row->{object}->{owner};
  my $title  = $row->{object}->{title};
  my $source = $row->{object}->{source} // '';

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

  my $res = {alerts => [], status => 200, pid => $pid};
  if ($notify) {
    my $nr = $self->_notify_owner_activated($pid, $owner, $title, $source);
    if ($nr->{status} ne 200) {
      push @{$res->{alerts}}, @{$nr->{alerts}} if @{$nr->{alerts}};
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub _notify_owner_activated {
  my ($self, $pid, $owner, $title, $source) = @_;

  my $res = {alerts => [], status => 200};

  unless ($owner) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Cannot notify: no owner for pid[$pid]"};
    $res->{status} = 400;
    return $res;
  }

  my $confmodel  = PhaidraAPI::Model::Config->new;
  my $pubconfig  = $confmodel->get_public_config($self);
  my $privconfig = $confmodel->get_private_config($self);

  unless ($privconfig->{smtpserver} && $privconfig->{smtpport}) {
    $self->app->log->warn("inactive activate notify pid[$pid]: SMTP not configured, skipping email");
    unshift @{$res->{alerts}}, {type => 'info', msg => 'SMTP not configured, notification skipped'};
    return $res;
  }

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $email           = $directory_model->get_email($self, $owner);
  unless ($email) {
    $self->app->log->warn("inactive activate notify pid[$pid]: no email for owner[$owner]");
    unshift @{$res->{alerts}}, {type => 'warning', msg => "No email for owner[$owner]"};
    return $res;
  }

  my $baseurl = $pubconfig->{baseurl} // $self->app->config->{phaidra}->{baseurl} // '';
  my $detail  = $baseurl ? "https://$baseurl/detail/$pid" : $pid;
  $title = $title // $pid;

  my $from = $pubconfig->{email} // $privconfig->{reportingemail} // '';
  $from = substr($from, 0, index($from, ',')) if $from && index($from, ',') != -1;
  unless ($from) {
    $self->app->log->warn("inactive activate notify pid[$pid]: no from address configured");
    unshift @{$res->{alerts}}, {type => 'info', msg => 'No from address configured, notification skipped'};
    return $res;
  }

  my %emaildata = (
    pid        => $pid,
    title      => $title,
    detail_url => $detail,
    owner      => $owner,
    source     => $source,
  );

  my %options;
  for my $p (@{$self->app->renderer->paths}) {
    $options{INCLUDE_PATH} = $p;
  }

  my $subject = "PHAIDRA archive ready / Archivierung abgeschlossen ($pid)";

  eval {
    my $msg = MIME::Lite::TT::HTML->new(
      From        => $from,
      To          => $email,
      Subject     => $subject,
      Charset     => 'utf8',
      Encoding    => 'quoted-printable',
      Template    => {html => 'email/inactive_activated.html.tt', text => 'email/inactive_activated.txt.tt'},
      TmplParams  => \%emaildata,
      TmplOptions => \%options
    );
    $msg->send(
      'smtp',
      $privconfig->{smtpserver} . ':' . $privconfig->{smtpport},
      AuthUser => $privconfig->{smtpuser},
      AuthPass => $privconfig->{smtppassword},
      SSL      => ($privconfig->{smtpport} eq '465' || $privconfig->{smtpport} eq '587') ? 1 : 0
    );
  };
  if ($@) {
    my $err = "pid[$pid] owner notification failed: $@";
    $self->app->log->error($err);
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};

    # Keep status 200 — activation already succeeded.
    return $res;
  }

  $self->app->log->info("pid[$pid] notified owner[$owner] source[$source] at $email");
  return $res;
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
