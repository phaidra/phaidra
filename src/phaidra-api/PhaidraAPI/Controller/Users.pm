package PhaidraAPI::Controller::Users;

use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use MIME::Lite::TT::HTML;
use Mojo::File qw(path);
use Mojo::URL;
use PhaidraAPI::Model::Config;
use PhaidraAPI::Model::Directory;
use PhaidraAPI::Model::Ratelimit;
use PhaidraAPI::Model::Users;
use Template;
use base 'Mojolicious::Controller';

sub _model {
  return PhaidraAPI::Model::Users->new;
}

sub _error {
  my ($self, $status, $message) = @_;
  return $self->render(
    json   => {status => $status, alerts => [{type => 'error', msg => $message}]},
    status => $status
  );
}

sub list {
  my $self  = shift;
  my $model = _model();
  my $users = $model->list($self, $self->param('q'));
  $model->public_user($_) for @{$users};
  return $self->render(
    json => {
      status => 200,
      users  => $users,
      roles  => $model->allowed_roles($self)
    }
  );
}

sub get {
  my $self  = shift;
  my $model = _model();
  my $user  = $model->public_user($model->get($self, $self->stash('username')));
  return _error($self, 404, 'user not found') unless $user;
  return $self->render(json => {status => 200, user => $user});
}

sub save {
  my $self              = shift;
  my $model             = _model();
  my $data              = $self->req->json || {};
  my $existing_username = $self->stash('username');
  $data->{username} //= $existing_username;
  return _error($self, 400, 'username required')
    unless $data->{username} && $data->{username} =~ /^[A-Za-z0-9_.@-]{1,128}$/;
  return _error($self, 400, 'username cannot be changed')
    if $existing_username && $data->{username} ne $existing_username;
  my $invalid_field = $model->field_too_long($data);
  return _error($self, 400, "$invalid_field exceeds maximum length") if $invalid_field;

  if (defined($data->{password}) && length($data->{password})) {
    my $password_error = $model->password_error($self, $data->{password});
    return _error($self, 400, $password_error) if $password_error;
  }
  if (defined($data->{expires_at}) && length($data->{expires_at})) {
    return _error($self, 400, 'invalid expiration date')
      unless $data->{expires_at} =~ /^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}(?::\d{2})?$/;
    $data->{expires_at} =~ s/T/ /;
    $data->{expires_at} .= ':00'
      if $data->{expires_at} =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/;
  }
  my $invalid_roles = $model->invalid_roles($self, $data->{roles});
  return _error($self, 400, 'unknown roles: ' . join(', ', @{$invalid_roles}))
    if @{$invalid_roles};
  if (ref($data->{org_units}) eq 'ARRAY') {
    my $invalid_org_units = PhaidraAPI::Model::Directory->new->invalid_org_unit_ids($self, $data->{org_units});
    return _error($self, 400, 'unknown organisation units: ' . join(', ', @{$invalid_org_units}))
      if @{$invalid_org_units};
  }

  my $user;
  eval {$user = $model->save($self, $data, $existing_username)};
  if ($@) {
    $self->app->log->error("saving user failed: $@");
    return _error($self, 500, 'saving user failed');
  }
  return _error($self, 404, 'user not found') unless $user;
  return $self->render(
    json   => {status => $existing_username ? 200 : 201, user => $model->public_user($user)},
    status => $existing_username ? 200 : 201
  );
}

sub roles {
  my $self = shift;
  return $self->render(json => {status => 200, roles => _model()->allowed_roles($self)});
}

sub delete {
  my $self    = shift;
  my $deleted = _model()->delete($self, $self->stash('username'));
  return _error($self, 404, 'user not found') unless $deleted && $deleted ne '0E0';
  return $self->render(json => {status => 200});
}

sub _template {
  my ($self, $private, $key, $filename) = @_;
  return $private->{$key} if defined($private->{$key}) && length($private->{$key});
  return path($self->app->home, 'templates', 'email', $filename)->slurp;
}

sub _render_template {
  my ($template, $variables) = @_;
  my $tt     = Template->new;
  my $output = '';
  $tt->process(\$template, $variables, \$output)
    or die 'processing password reset email template failed: ' . $tt->error;
  return $output;
}

sub _send_reset_email {
  my ($self, $identifier, $allow_passwordless) = @_;
  my ($token, $email, $username, $ttl) = _model()->create_reset($self, $identifier, $allow_passwordless);
  return 0 unless $token;

  my $confmodel = PhaidraAPI::Model::Config->new;
  my $public    = $confmodel->get_public_config($self);
  my $private   = $confmodel->get_private_config($self);

  my $private = PhaidraAPI::Model::Config->new->get_private_config($self) || {};
  die 'SMTP is not configured' unless $private->{smtpserver} && $private->{smtpport};
  my $url = Mojo::URL->new($self->app->config->{scheme} . '://' . $self->app->config->{baseurl} . '/password-reset');
  $url->query(token => $token);
  my %variables = (
    reset_url       => $url->to_string,
    username        => $username,
    expires_minutes => int($ttl / 60),
  ); 
  my $subject_template = _template($self, $private, 'passwordresetemailsubject', 'password-reset-subject.txt');
  my $text_template    = _template($self, $private, 'passwordresetemailtext',    'password-reset.txt.tt');
  my $html_template    = _template($self, $private, 'passwordresetemailhtml',    'password-reset.html.tt');
  my $subject          = _render_template($subject_template, \%variables);

  my $message = MIME::Lite::TT::HTML->new(
    To         => $email,
    From       => $public->{email},
    Subject    => $subject,
    Charset    => 'utf8',
    Encoding   => 'quoted-printable',
    Template   => {html => \$html_template, text => \$text_template},
    TmplParams => \%variables
  );
  $message->send(
    'smtp', $private->{smtpserver} . ':' . $private->{smtpport},
    AuthUser => $private->{smtpuser},
    AuthPass => $private->{smtppassword},
    SSL      => ($private->{smtpport} eq '465' || $private->{smtpport} eq '587') ? 1 : 0
  );
  return 1;
}

sub send_reset {
  my $self = shift;
  my $sent;
  eval {$sent = _send_reset_email($self, $self->stash('username'), 1)};
  if ($@) {
    $self->app->log->error("sending password reset failed: $@");
    return _error($self, 500, 'sending password reset failed');
  }
  return _error($self, 400, 'user has no active email address') unless $sent;
  return $self->render(json => {status => 200});
}

sub request_reset {
  my $self       = shift;
  my $data       = $self->req->json || {};
  my $identifier = lc($data->{identifier} // '');
  $identifier =~ s/^\s+|\s+$//g;
  my $ip        = $self->tx->remote_address // 'unknown';
  my @limits    = ('password-reset:ip:' . sha256_hex($ip), 'password-reset:account:' . sha256_hex($identifier),);
  my $ratelimit = PhaidraAPI::Model::Ratelimit->new;
  my $blocked   = grep {$ratelimit->check_rate_limit($self, $_)->{blocked}} @limits;

  unless ($blocked) {
    eval {_send_reset_email($self, $identifier)};
    $self->app->log->error("password reset request failed: $@") if $@;
    $ratelimit->record_failed_attempt($self, $_) for @limits;
  }
  return $self->render(json => {status => 200});
}

sub confirm_reset {
  my $self    = shift;
  my $data    = $self->req->json || {};
  my $password_error = _model()->password_error($self, $data->{password});
  return _error($self, 400, $password_error) if $password_error;
  my $success = _model()->confirm_reset($self, $data->{token} // '', $data->{password});
  return _error($self, 400, 'invalid or expired password reset token') unless $success;
  return $self->render(json => {status => 200});
}

1;
