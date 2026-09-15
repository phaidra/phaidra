package PhaidraAPI::Model::Users;

use strict;
use warnings;
use Crypt::Bcrypt qw(bcrypt_prehashed);
use Crypt::URandom qw(urandom);
use Digest::SHA qw(sha256_hex);
use Encode qw(encode_utf8);
use MIME::Base64 qw(encode_base64url);
use Mojo::JSON qw(true false);
use POSIX qw(strftime);
use base 'Mojo::Base';

sub _dbh {
  my ($self, $c) = @_;
  return $c->app->db_user->dbh;
}

sub _hash_password {
  my ($self, $password) = @_;
  return bcrypt_prehashed(encode_utf8($password), '2b', 12, urandom(16), 'sha256');
}

sub password_error {
  my ($self, $c, $password) = @_;
  my $minimum = $c->app->config->{authentication}->{password_min_length} // 12;
  $minimum = 12 if $minimum < 12;
  return "password must contain at least $minimum characters"
    if !defined($password) || length($password) < $minimum;
  my $types = 0;
  $types++ if $password =~ /[a-z]/;
  $types++ if $password =~ /[A-Z]/;
  $types++ if $password =~ /\d/;
  $types++ if $password =~ /[^A-Za-z0-9]/;
  return 'password must contain at least 3 character types (lowercase, uppercase, number, or special character)'
    if $types < 3;
  return;
}

sub _now {
  return strftime('%Y-%m-%d %H:%M:%S', localtime);
}

sub field_too_long {
  my ($self, $data) = @_;
  my %scalar_limits = (
    username => 128, email => 254, firstname => 128,
    lastname => 128, displayname => 255
  );
  for my $field (keys %scalar_limits) {
    return $field
      if defined($data->{$field}) && length($data->{$field}) > $scalar_limits{$field};
  }

  my %array_limits = (
    affiliation => 64, org_units => 64, roles => 64
  );
  for my $field (keys %array_limits) {
    next unless ref($data->{$field}) eq 'ARRAY';
    return $field
      if grep {defined && length($_) > $array_limits{$field}} @{$data->{$field}};
  }
  return;
}

sub list {
  my ($self, $c, $query) = @_;
  $query //= '';
  my $sth = $self->_dbh($c)->prepare(
    'SELECT username FROM users WHERE username LIKE ? OR email LIKE ? ORDER BY username'
  );
  my $like = '%' . $query . '%';
  $sth->execute($like, $like);
  my @users;
  while (my $row = $sth->fetchrow_hashref) {
    push @users, $self->get($c, $row->{username});
  }
  return \@users;
}

sub get {
  my ($self, $c, $username) = @_;
  my $dbh = $self->_dbh($c);
  my $sth = $dbh->prepare(q{
    SELECT id, username, email, firstname, lastname, displayname, password_hash,
           status, expires_at, last_login, created, updated
      FROM users WHERE username = ?
  });
  $sth->execute($username);
  my $user = $sth->fetchrow_hashref;
  return unless $user;

  my $roles = $dbh->prepare(
    'SELECT role FROM user_roles WHERE user_id = ? ORDER BY role'
  );
  $roles->execute($user->{id});
  $user->{roles} = [];
  while (my $row = $roles->fetchrow_hashref) {
    push @{$user->{roles}}, $row->{role};
  }

  my $affiliations = $dbh->prepare(
    'SELECT affiliation FROM affiliations WHERE user_id = ? ORDER BY affiliation'
  );
  $affiliations->execute($user->{id});
  $user->{affiliation} = [];
  while (my $row = $affiliations->fetchrow_hashref) {
    push @{$user->{affiliation}}, $row->{affiliation};
  }

  my $org_units = $dbh->prepare(q{
    SELECT org_unit_id FROM user_org_units
     WHERE user_id = ? ORDER BY org_unit_id
  });
  $org_units->execute($user->{id});
  $user->{org_units} = [];
  while (my $row = $org_units->fetchrow_hashref) {
    push @{$user->{org_units}}, $row->{org_unit_id};
  }

  return $user;
}

sub public_user {
  my ($self, $user) = @_;
  return unless $user;
  $user->{active}       = $user->{status} eq 'active' ? true : false;
  $user->{password_set} = defined($user->{password_hash}) && length($user->{password_hash}) ? true : false;
  $user->{last_login_at} = delete $user->{last_login};
  $user->{created_at}    = delete $user->{created};
  $user->{updated_at}    = delete $user->{updated};
  delete $user->{password_hash};
  delete $user->{id};
  delete $user->{status};
  return $user;
}

sub allowed_roles {
  my ($self, $c) = @_;
  my %roles = map {$_ => 1} qw(admin superuser);
  my $default = $c->app->config->{phaidra}->{default_role} // '';
  $roles{$default} = 1 if $default ne '';

  my $opa_url = $c->app->config->{opa}->{url} // 'http://opa:8181';
  my $tx = $c->app->ua->get($opa_url . '/v1/data/phaidra/config/roles');
  unless ($tx->error) {
    my $body = $tx->res->json || {};
    my $result = $body->{result};
    $roles{$_} = 1 for keys %{ref($result) eq 'HASH' ? $result : {}};
  }
  return [sort keys %roles];
}

sub invalid_roles {
  my ($self, $c, $requested) = @_;
  my %allowed = map {$_ => 1} @{$self->allowed_roles($c)};
  return [grep {!$allowed{$_}} @{$requested || []}];
}

sub _replace_directory_values {
  my ($self, $dbh, $user_id, $data) = @_;

  if (ref($data->{affiliation}) eq 'ARRAY') {
    $dbh->do('DELETE FROM affiliations WHERE user_id = ?', undef, $user_id);
    for my $affiliation (grep {defined && length} @{$data->{affiliation}}) {
      $dbh->do(
        'INSERT INTO affiliations(user_id, affiliation) VALUES(?, ?)',
        undef, $user_id, $affiliation
      );
    }
  }

  if (ref($data->{org_units}) eq 'ARRAY') {
    $dbh->do('DELETE FROM user_org_units WHERE user_id = ?', undef, $user_id);
    for my $org_unit (@{$data->{org_units}}) {
      next unless defined($org_unit) && length($org_unit);
      $dbh->do(
        'INSERT IGNORE INTO user_org_units(user_id, org_unit_id) VALUES(?, ?)',
        undef, $user_id, $org_unit
      );
    }
  }

  if (ref($data->{roles}) eq 'ARRAY') {
    $dbh->do('DELETE FROM user_roles WHERE user_id = ?', undef, $user_id);
    for my $role (grep {defined && length} @{$data->{roles}}) {
      $dbh->do(
        'INSERT IGNORE INTO user_roles(user_id, role) VALUES(?, ?)',
        undef, $user_id, $role
      );
    }
  }
}

sub save {
  my ($self, $c, $data, $existing_username) = @_;
  my $invalid_field = $self->field_too_long($data);
  die "$invalid_field exceeds maximum length" if $invalid_field;
  my $dbh = $self->_dbh($c);
  my $username = $existing_username // $data->{username};
  my $existing = $existing_username ? $self->get($c, $existing_username) : undef;
  return unless !$existing_username || $existing;

  my $status = exists($data->{active})
    ? ($data->{active} ? 'active' : 'blocked')
    : ($data->{status} // ($existing ? $existing->{status} : 'active'));
  my $displayname = $data->{displayname};
  $displayname = join(' ', grep {defined && length} @{$data}{qw(firstname lastname)})
    unless defined($displayname);
  die 'displayname exceeds maximum length' if length($displayname // '') > 255;

  $dbh->begin_work;
  eval {
    my $user_id;
    if ($existing) {
      $user_id = $existing->{id};
      my @values = (
        $data->{email}, $data->{firstname}, $data->{lastname}, $displayname,
        $status, $data->{expires_at}
      );
      my $password_sql = '';
      if (defined($data->{password}) && length($data->{password})) {
        $password_sql = ', password_hash = ?';
        push @values, $self->_hash_password($data->{password});
      }
      push @values, $existing_username;
      $dbh->do(qq{
        UPDATE users SET email = ?, firstname = ?, lastname = ?, displayname = ?,
                         status = ?, expires_at = ? $password_sql
         WHERE username = ?
      }, undef, @values);
    }
    else {
      my $password_hash = defined($data->{password}) && length($data->{password})
        ? $self->_hash_password($data->{password}) : undef;
      $dbh->do(q{
        INSERT INTO users
          (username, email, firstname, lastname, displayname, password_hash, status, expires_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      }, undef, $username, $data->{email}, $data->{firstname}, $data->{lastname},
        $displayname, $password_hash, $status, $data->{expires_at});
      $user_id = $dbh->{mysql_insertid};
    }
    $self->_replace_directory_values($dbh, $user_id, $data);
    $dbh->commit;
  };
  if ($@) {
    my $error = $@;
    eval {$dbh->rollback};
    die $error;
  }
  $c->app->chi->remove("get_user_data_$username");
  return $self->get($c, $username);
}

sub delete {
  my ($self, $c, $username) = @_;
  my $deleted = $self->_dbh($c)->do('DELETE FROM users WHERE username = ?', undef, $username);
  $c->app->chi->remove("get_user_data_$username") if $deleted && $deleted ne '0E0';
  return $deleted;
}

sub upsert_shib {
  my ($self, $c, $data) = @_;
  my $existing = $self->get($c, $data->{username});
  if ($existing) {
    return if $existing->{status} ne 'active';
    return if $existing->{expires_at} && $existing->{expires_at} lt _now();
  }

  my %save_data = (
    %{$data},
    active     => 1,
    expires_at => $existing ? $existing->{expires_at} : undef,
    # Default roles are assigned only when the remote account is provisioned.
    # Existing role assignments remain under administrator control.
    roles      => $existing ? $existing->{roles} : $data->{roles},
  );
  if ($existing) {
    for my $field (qw(email firstname lastname displayname)) {
      $save_data{$field} = $existing->{$field}
        unless exists($save_data{$field});
    }
  }
  $self->save($c, \%save_data, $existing ? $data->{username} : undef);
  $self->_dbh($c)->do(
    'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE username = ?',
    undef, $data->{username}
  );
  return $self->get($c, $data->{username});
}

sub create_reset {
  my ($self, $c, $identifier, $allow_passwordless) = @_;
  my $dbh = $self->_dbh($c);
  my $eligibility = q{
        AND status = 'active'
        AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP)
        AND (? = 1 OR password_hash IS NOT NULL)
  };
  my $sth = $dbh->prepare(qq{
    SELECT id, username, email FROM users
     WHERE username = ? $eligibility
  });
  $sth->execute($identifier, $allow_passwordless ? 1 : 0);
  my $user = $sth->fetchrow_hashref;
  unless ($user) {
    $sth = $dbh->prepare(qq{
      SELECT id, username, email FROM users
       WHERE email = ? $eligibility
       LIMIT 2
    });
    $sth->execute($identifier, $allow_passwordless ? 1 : 0);
    my $email_users = $sth->fetchall_arrayref({});
    # Silently fail reset if email is not unique, the ui message states that clearly
    return unless @$email_users == 1;
    $user = $email_users->[0];
  }
  return unless $user && $user->{email};

  my $raw = encode_base64url(urandom(32));
  my $token_hash = sha256_hex($raw);
  my $ttl = int($c->app->config->{authentication}->{reset_token_ttl} // 3600);
  $ttl = 3600 if $ttl < 1;
  $dbh->begin_work;
  eval {
    $dbh->do(q{
      UPDATE password_reset_tokens SET used_at = CURRENT_TIMESTAMP
       WHERE user_id = ? AND used_at IS NULL
    }, undef, $user->{id});
    $dbh->do(q{
      INSERT INTO password_reset_tokens(user_id, token_hash, expires_at)
      VALUES(?, ?, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL ? SECOND))
    }, undef, $user->{id}, $token_hash, $ttl);
    $dbh->commit;
  };
  if ($@) {
    my $error = $@;
    eval {$dbh->rollback};
    die $error;
  }
  return ($raw, $user->{email}, $user->{username}, $ttl);
}

sub confirm_reset {
  my ($self, $c, $raw_token, $password) = @_;
  return unless defined($raw_token) && length($raw_token);
  my $dbh = $self->_dbh($c);
  my $token_hash = sha256_hex($raw_token);
  my $success;
  $dbh->begin_work;
  eval {
    my $sth = $dbh->prepare(q{
      SELECT id, user_id FROM password_reset_tokens
       WHERE token_hash = ? AND used_at IS NULL AND expires_at > CURRENT_TIMESTAMP
       FOR UPDATE
    });
    $sth->execute($token_hash);
    my $token = $sth->fetchrow_hashref;
    if ($token) {
      $dbh->do('UPDATE users SET password_hash = ? WHERE id = ?',
        undef, $self->_hash_password($password), $token->{user_id});
      $dbh->do('UPDATE password_reset_tokens SET used_at = CURRENT_TIMESTAMP WHERE id = ?',
        undef, $token->{id});
      $success = 1;
    }
    $dbh->commit;
  };
  if ($@) {
    my $error = $@;
    eval {$dbh->rollback};
    die $error;
  }
  return $success;
}

1;
