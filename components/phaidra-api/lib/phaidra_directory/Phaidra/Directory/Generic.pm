package Phaidra::Directory::Generic;

use strict;
use warnings;
use Data::Dumper;
use utf8;
use MongoDB;
use Data::UUID;
use YAML::Syck;
use base 'Phaidra::Directory';

my $config = undef;

sub _init {
  my $self = shift;
  my $mojo = shift;
  my $conf = shift;

  $config = YAML::Syck::LoadFile('/etc/phaidra.yml');

  return $self;
}

sub authenticate($$$$) {
  my $self      = shift;
  my $c         = shift;
  my $username  = shift;
  my $password  = shift;
  my $extradata = shift;

  my $res = {alerts => [], status => 500};

  $c->app->log->error("Authenticating user $username");

  for my $u (@{$config->{users}}) {
    if (($u->{username} eq $username) && ($u->{password} eq $password)) {
      $res->{status} = 200;
      $c->stash({phaidra_auth_result => $res});
      return $username;
    }
  }

  unshift @{$res->{alerts}}, {type => 'error', msg => "User not found"};
  $res->{status} = 401;
  $c->stash({phaidra_auth_result => $res});
  return undef;
}

#get the email adress for a specific user
sub get_email {
  my ($self, $c, $username) = @_;

  die("PHAIDRA ORGANIZATIONAL ERROR: undefined username") unless (defined($username));

  for my $user (@{$config->{users}}) {
    if ($user->{username} eq $username) {
      return $user->{email};
    }
  }
}

#get the name to a specific user id
sub get_name {
  my ($self, $c, $username) = @_;

  die("PHAIDRA ORGANIZATIONAL ERROR:undefined username") unless (defined($username));

  for my $user (@{$config->{users}}) {
    if ($user->{username} eq $username) {
      return $user->{firstname} . ' ' . $user->{lastname};
    }
  }
}

#get all departments of a faculty
sub get_org_units {
  my ($self, $c, $parentid, $lang) = @_;

  $parentid =~ s/A//g;
  my $values;
  if ($parentid) {
    if ($parentid ne '-1')    #fakcode A-1 == whole university => has no departments
    {
      for my $f (@{$config->{faculties}}) {
        if ($f->{fakcode} eq $parentid) {
          for my $d (@{$f->{departments}}) {
            push @$values, {value => $d->{inum}, name => $d->{name}};
          }
        }
      }
    }
  }
  else {
    for my $f (@{$config->{faculties}}) {
      push @$values, {value => $f->{fakcode}, name => $f->{name}};
    }
  }

  my $res = {alerts => [], status => 200};
  $res->{org_units} = $values;
  return $res;
}

#get the id of a faculty
sub get_parent_org_unit_id {
  my ($self, $c, $inum) = @_;

  die("Internal error: undefined inum") unless (defined($inum));

  for my $f (@{$config->{faculties}}) {
    for my $d (@{$f->{departments}}) {
      if ($d->{inum} eq $inum) {
        return $f->{fakcode};
      }
    }
  }
}

#get the name of a faculty
sub get_org_unit_name {
  my ($self, $c, $id, $lang) = @_;

  die("PHAIDRA get_org_unit_name ERROR: undefined id") unless (defined($id));
  my $name;
  for my $f (@{$config->{faculties}}) {
    if ($f->{fakcode} eq $id) {
      return $f->{name};
    }
    for my $d (@{$f->{departments}}) {
      if ($d->{inum} eq $id) {
        return $d->{name};
      }
    }
  }
  return $name;
}

#get the full name of the author's affiliation
sub get_affiliation {
  my ($self, $c, $inum, $lang) = @_;
  return $self->get_org_unit_name($c, $inum);
}

sub get_org_name {
  my $self = shift;
  my $c    = shift;
  my $lang = shift;
  return $config->{institutionName};
}

#get all branch of studies
sub get_study_plans {
  my ($self, $c, $lang) = @_;

  my @values = ();

  push @values, {value => 1, name => 'Study 1'};
  push @values, {value => 2, name => 'Study 2'};

  my $res = {alerts => [], status => 200};
  $res->{study_plans} = \@values;
  return $res;
}

#get studies
sub get_study {
  my $self  = shift;
  my $c     = shift;
  my $id    = shift;
  my $index = shift;
  my $lang  = shift;

  my @values = ();

  my $taxonnr = undef;
  $taxonnr = @$index if (defined($index));

  if (!defined($index->[0]) && defined($id)) {
    push @values, {value => '001', name => '001'} if ($id eq '1');
    push @values, {value => '002', name => '002'} if ($id eq '1');
    push @values, {value => '003', name => '003'} if ($id eq '2');
  }
  elsif ($taxonnr eq '1') {
    if ($index->[0] eq '001') {
      push @values, {value => '0011', name => '0011'};
      push @values, {value => '0012', name => '0012'};
      push @values, {value => '0013', name => '0013'};
    }
    elsif ($index->[0] eq '002') {
      push @values, {value => '0021', name => '0021'};
      push @values, {value => '0022', name => '0022'};
      push @values, {value => '0023', name => '0023'};
    }
  }

  my $res = {alerts => [], status => 200};
  $res->{study} = \@values;
  return $res;
}

#get the name of a study
sub get_study_name {
  my $self  = shift;
  my $c     = shift;
  my $id    = shift;
  my $index = shift;
  my $lang  = shift;

  my $taxonnr = @$index;
  my $name    = '';
  if ($taxonnr eq '1') {
    $name = "Study 3" if ($index->[0] eq '003');
  }
  elsif ($taxonnr eq '2') {
  CASE:
    {
      $index->[1] eq '0011' && do {$name = 'Study 1-1'; last CASE;};
      $index->[1] eq '0012' && do {$name = 'Study 1-2'; last CASE;};
      $index->[1] eq '0013' && do {$name = 'Study 1-3'; last CASE;};
      $index->[1] eq '0021' && do {$name = 'Study 2-1'; last CASE;};
      $index->[1] eq '0022' && do {$name = 'Study 2-2'; last CASE;};
      $index->[1] eq '0023' && do {$name = 'Study 2-3'; last CASE;};
    }
  }
  return $name;
}

#all staff positions at the university
sub get_pers_funktions {
  my ($self, $c, $lang) = @_;

  my $functions;
  push @$functions, {code => 'func1', name => 'func1'};
  push @$functions, {code => 'func2', name => 'func2'};
  push @$functions, {code => 'func3', name => 'func3'};

  return $functions;
}

#get the name of a staff position
sub get_pers_funktion_name {
  my ($self, $c, $code, $lang) = @_;

  die("undefined code for perfsunk") unless (defined($code));

  return 'func1' if ($code eq 'func1');
  return 'func2' if ($code eq 'func2');
  return 'func3' if ($code eq 'func3');
}

#get user data at the login
sub get_user_data {
  my ($self, $c, $username) = @_;

  my ($fname, $lname, $email);
  my @inums    = ();
  my @fakcodes = ();

  for my $user (@{$config->{users}}) {

    if ($user->{username} eq $username) {
      $fname = $user->{firstname};
      $lname = $user->{lastname};
      $email = $user->{email};
      push @fakcodes, $user->{fakcode};
      push @inums,    $user->{inum};
      last;
    }
  }

  my $res = {username => $username, firstname => $fname, lastname => $lname, email => $email, org_units_l2 => \@inums, org_units_l1 => \@fakcodes};

  return $res;

}

sub is_superuser {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  $c->app->log->error("This method is not implemented");
}

sub is_superuser_for_user {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  # \@users
  $c->app->log->error("This method is not implemented");
}

=head2 searchUser

search a user

TODO: remove old example users

=cut

sub search_user {
  my ($self, $c, $searchstring) = @_;

  my @persons = ();
  for my $user (@{$config->{users}}) {
    push @persons,
      {
      uid   => $user->{username},
      type  => '',
      value => $user->{firstname} . ' ' . $user->{lastname},
      };
  }
  my $hits = @persons;
  return \@persons, $hits;
}

sub _connect_mongodb_group_manager() {
  my $self = shift;
  my $c    = shift;

  my $client = MongoDB::MongoClient->new(
    host     => $c->app->config->{mongodb_group_manager}->{host},
    port     => $c->app->config->{mongodb_group_manager}->{port},
    username => $c->app->config->{mongodb_group_manager}->{username},
    password => $c->app->config->{mongodb_group_manager}->{password},
    db_name  => $c->app->config->{mongodb_group_manager}->{db_name}
  );

  return $client;
}

sub _get_groups_col() {
  my $self = shift;
  my $c    = shift;

  my $client = $self->_connect_mongodb_group_manager($c);
  my $db     = $client->get_database($c->app->config->{mongodb_group_manager}->{database});
  return $db->get_collection($c->app->config->{mongodb_group_manager}->{collection});
}

sub get_users_groups {
  my ($self, $c, $owner) = @_;

  my $groups = $self->_get_groups_col($c);

  my $users_groups = $groups->find({"owner" => $owner});
  my @grps         = ();
  if ($users_groups) {
    while (my $doc = $users_groups->next) {
      push @grps, {groupid => $doc->{groupid}, name => $doc->{name}, created => $doc->{created}, updated => $doc->{updated}};
    }
  }

  return \@grps;
}

sub get_group {
  my ($self, $c, $gid, $owner) = @_;

  my $groups = $self->_get_groups_col($c);

  my $g = $groups->find_one({"groupid" => $gid, "owner" => $owner});

  my @members = ();
  for my $m (@{$g->{members}}) {
    push(@members, {username => $m, name => $self->_get_group_member_name($c, $m)});
  }

  $g->{members} = \@members;

  return $g;
}

sub _get_group_member_name {
  my ($self, $c, $username) = @_;

  return $self->get_name($c, $username);
}

sub create_group {
  my ($self, $c, $groupname, $owner) = @_;

  my $groups = $self->_get_groups_col($c);

  my $ug      = Data::UUID->new;
  my $bgid    = $ug->create();
  my $gid     = $ug->to_string($bgid);
  my @members = ();
  $groups->insert_one(
    { "groupid" => $gid,
      "owner"   => $owner,
      "name"    => $groupname,
      "members" => \@members,
      "created" => time,
      "updated" => time
    }
  );

  return $gid;
}

sub delete_group {
  my ($self, $c, $gid, $owner) = @_;

  my $groups = $self->_get_groups_col($c);
  my $g      = $groups->remove_one({"groupid" => $gid, "owner" => $owner});

  return;
}

sub remove_group_member {
  my ($self, $c, $gid, $uid, $owner) = @_;

  my $groups = $self->_get_groups_col($c);
  $groups->update_one({"groupid" => $gid, "owner" => $owner}, {'$pull' => {'members' => $uid}, '$set' => {"updated" => time}});

  return;
}

sub add_group_member {
  my ($self, $c, $gid, $uid, $owner) = @_;

  my $groups = $self->_get_groups_col($c);

  # check if not already there
  my $g = $groups->find_one({"groupid" => $gid, "owner" => $owner});

  my @members = ();
  for my $m (@{$g->{members}}) {
    return if $m eq $uid;
  }

  $groups->update_one({"groupid" => $gid, "owner" => $owner}, {'$push' => {'members' => $uid}, '$set' => {"updated" => time}});

  return;
}

1;
__END__
