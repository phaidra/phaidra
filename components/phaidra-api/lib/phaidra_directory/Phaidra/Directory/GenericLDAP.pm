package Phaidra::Directory::GenericLDAP;

use strict;
use warnings;
use Data::Dumper;
use utf8;
use MongoDB;
use Data::UUID;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);
use YAML::Syck;
use Mojo::JSON qw(encode_json decode_json);
use base 'Phaidra::Directory';

my $config = undef;

my $orgunits = {
  root => {
    subunits => []
  }
};

sub _init {
  # this is the app config
  my $self = shift;
  my $mojo = shift;
  $config = YAML::Syck::LoadFile('/etc/phaidra.yml');
  my $orgjsonfilepath = 'lib/phaidra_directory/Phaidra/Directory/organizational_units.json';
  if (-r $orgjsonfilepath) {

    my $json_text = do {
      open(my $json_fh, "<:encoding(UTF-8)", $orgjsonfilepath)
      or $mojo->log->error("Can't open file[".$orgjsonfilepath."]: $!\n");
      local $/;
      <$json_fh>
    };

    my @orgunitsarr = @{decode_json($json_text)};
    for my $u (@orgunitsarr) {
      $orgunits->{$u->{id}} = {
	subunits => [],
	superunits => [],
	oracle_id => $u->{oracle_id},
	parent_oracle_id => $u->{parent_oracle_id},
	rdf => {
	  '@type' => $u->{type},
	  'skos:prefLabel' => {
	    'deu' => $u->{de},
	    'eng' => $u->{en}
	  },
	  'skos:notation' => $u->{oracle_id},
	  '@id' => $u->{id}
	}
      }
    }
    for my $unitid (keys %{$orgunits}) {
      if (exists($orgunits->{$unitid}->{parent_oracle_id}) && ($orgunits->{$unitid}->{parent_oracle_id} eq -1)) {
	push @{$orgunits->{root}->{subunits}}, $orgunits->{$unitid}
      }
      for my $unitid2 (keys %{$orgunits}) {
	if (exists($orgunits->{$unitid2}->{parent_oracle_id}) && exists($orgunits->{$unitid}->{oracle_id}) && ($orgunits->{$unitid2}->{parent_oracle_id} eq $orgunits->{$unitid}->{oracle_id})) {
	  push @{$orgunits->{$unitid}->{subunits}}, $orgunits->{$unitid2};
	}
	if (exists($orgunits->{$unitid2}->{oracle_id}) && exists($orgunits->{$unitid}->{parent_oracle_id}) && ($orgunits->{$unitid2}->{oracle_id} eq $orgunits->{$unitid}->{parent_oracle_id})) {
	  push @{$orgunits->{$unitid}->{superunits}}, $orgunits->{$unitid2};
	}
      }
    }
  } else {
    $mojo->log->error("univie.json [$orgjsonfilepath] not found");
  }

  return $self;
}

# [begin] new org methods
sub org_get_subunits {
  my ($self, $c, $id)= @_;

  my $res = { alerts => [], status => 200 };

  $id = 'root' if $id == 'A-1';

  if (exists($orgunits->{$id})) {
    if (exists($orgunits->{$id}->{subunits})) {
      my @subunits;
      for my $u (@{$orgunits->{$id}->{subunits}}){
	push @subunits, $u->{rdf};
      }
      $res->{subunits} = \@subunits;
    } else {
      push @{$res->{alerts}}, { type => 'error', msg => "Internal error when requesting subunits of $id" };
      $res->{status} = 500;
    }
  } else {
    push @{$res->{alerts}}, { type => 'error', msg => "$id not found" };
    $res->{status} = 404;
  }
  return $res;
}

sub org_get_superunits {
  my ($self, $c, $id)= @_;

  my $res = { alerts => [], status => 200 };

  if ($id) {
    if (exists($orgunits->{$id})) {
      if (exists($orgunits->{$id}->{superunits})) {
	my @superunits;
	for my $u (@{$orgunits->{$id}->{superunits}}){
	  push @superunits, $u->{rdf};
	}
	$res->{superunits} = \@superunits;
      } else {
	push @{$res->{alerts}}, { type => 'error', msg => "Internal error when requesting superunits of $id" };
	$res->{status} = 500;
      }
    } else {
      push @{$res->{alerts}}, { type => 'error', msg => "$id not found" };
      $res->{status} = 404;
    }

  } else {
    push @{$res->{alerts}}, { type => 'error', msg => "No id provided when requesting superunits" };
    $res->{status} = 400;
  }
  return $res;
}

sub org_get_units {
  my ($self, $c, $flat)= @_;

  my $res;

  if ($flat) {
    my @orgunits;
    $self->_org_get_units_rec_flat($c, $orgunits->{root}->{subunits}, \@orgunits);
    $res = { alerts => [], units => \@orgunits, status => 200 };
  } else {
    $res = { alerts => [], units => $self->_org_get_units_rec($c, $orgunits->{root}->{subunits}), status => 200 };
  }

  return $res;
}

sub org_get_parentpath {
  my ($self, $c, $id)= @_;

  my @parentpath;
  push @parentpath, $orgunits->{$id}->{rdf};
  $self->_org_get_parentpath_rec_flat($c, $orgunits->{$id}->{superunits}, \@parentpath);

  return { alerts => [], parentpath => \@parentpath, status => 200 };
}

sub _org_get_units_rec {
  my ($self, $c, $units)= @_;

  my @newarr;

  for my $u (@{$units}) {

    my $new_u = $u->{rdf};

    if (exists($u->{subunits})) {
      if (scalar(@{$u->{subunits}}) > 0) {
	$new_u->{subunits} = $self->_org_get_units_rec($c, $u->{subunits});
      }
    }

    push @newarr, $new_u;
  }

  return \@newarr;
}

sub _org_get_units_rec_flat {
  my ($self, $c, $units, $arr)= @_;

  for my $u (@{$units}) {
    push @{$arr}, $u->{rdf};
    if (exists($u->{subunits})) {
      if (scalar(@{$u->{subunits}}) > 0) {
	$self->_org_get_units_rec_flat($c, $u->{subunits}, $arr);
      }
    }
  }
}

sub _org_get_parentpath_rec_flat {
  my ($self, $c, $units, $arr)= @_;

  for my $u (@{$units}) {
    push @{$arr}, $u->{rdf};
    if (exists($u->{superunits})) {
      if (scalar(@{$u->{superunits}}) > 0) {
	$self->_org_get_parentpath_rec_flat($c, $u->{superunits}, $arr);
      }
    }
    last;
  }
}
# [end] new org methods

sub get_ldap {
  my $self = shift;
  my $c    = shift;

  my $res = {alerts => [], status => 500};

  my $LDAP_SERVER   = $c->app->config->{authentication}->{ldap}->{server};
  my $LDAP_SSL_PORT = $c->app->config->{authentication}->{ldap}->{port};

  my $ldap = Net::LDAP->new($LDAP_SERVER, port => $LDAP_SSL_PORT);
  unless (defined($ldap)) {
    unshift @{$res->{alerts}}, {type => 'error', msg => $!};
    return $res;
  }

  # bind the security principal account
  my $secDN   = $c->app->config->{authentication}->{ldap}->{securityprincipal};
  my $secPASS = $c->app->config->{authentication}->{ldap}->{securitycredentials};
  my $ldapMsg = $ldap->bind($secDN, password => $secPASS);

  if ($ldapMsg->is_error) {
    unshift @{$res->{alerts}}, {type => 'error', msg => $ldapMsg->error};
    return $res;
  }

  return $ldap;
}

sub getLDAPEntryForUser {

  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  my $ldap = $self->get_ldap($c);

  my $filter = $c->app->config->{authentication}->{ldap}->{usersearchfilter};
  $filter =~ s/\{0\}/$username/;

  my @user_search_base = @{$c->app->config->{authentication}->{ldap}->{usersearchbase}};

  $c->app->log->info("Searching for user $username in searchbase @user_search_base.");

  my $ldapSearch = $ldap->search(base => @user_search_base, filter => $filter);

  die "There was an error during search:\n\t" . ldap_error_text($ldapSearch->code) if $ldapSearch->code;

  while (my $ldapEntry = $ldapSearch->pop_entry()) {
    foreach my $attr (@{$ldapEntry->{'asn'}->{'attributes'}}) {
      my $attrtype = $attr->{'type'};
      my @attvals  = @{$attr->{'vals'}};
      foreach my $val (@attvals) {
	if ($attrtype eq 'uid') {
	  if ($val eq $username) {
	    return $ldapEntry;
	  }
	}
      }
    }
  }

}

sub authenticate() {

  my $self      = shift;
  my $c         = shift;
  my $username  = shift;
  my $password  = shift;
  my $extradata = shift;    #not used

  my $res = {alerts => [], status => 500};
  for my $u (@{$c->app->config->{fedora}->{fedoraadmins}}) {
    if (($u->{username} eq $username) && ($u->{password} eq $password)) {
      $c->app->log->debug("auth: admin login");
      $res->{status} = 200;
      $c->stash({phaidra_auth_result => $res});
      return $username;
    }
  }
  for my $u (@{$c->app->config->{phaidra}->{users}}) {
    if (($u->{username} eq $username) && ($u->{password} eq $password)) {
      $c->app->log->debug("auth: yaml login");
      $res->{status} = 200;
      $c->stash({phaidra_auth_result => $res});
      return $username;
    }
  }
  if (($username eq $c->config->{phaidra}->{adminusername}) && ($password eq $c->config->{phaidra}->{adminpassword})) {

    # this account is (should be) local to fedora so we cannot authenticate it against LDAP
    $c->app->log->debug("auth: phaidraadmin login");
    $res->{status} = 200;
    $c->stash({phaidra_auth_result => $res});
    return $username;
  }

  $c->app->log->debug("auth: ldap login");
  my $LDAP_SERVER   = $c->app->config->{authentication}->{ldap}->{server};
  my $LDAP_SSL_PORT = $c->app->config->{authentication}->{ldap}->{port};

  my $ldap = Net::LDAP->new($LDAP_SERVER, port => $LDAP_SSL_PORT);
  unless (defined($ldap)) {
    unshift @{$res->{alerts}}, {type => 'error', msg => $!};
    $c->stash({phaidra_auth_result => $res});
    return undef;
  }

  # first we have to find the DN (i think its differs for various account types)
  my $sf = $c->app->config->{authentication}->{ldap}->{usersearchfilter};
  my $sp = $c->app->config->{authentication}->{ldap}->{securityprincipal};
  my $sc = $c->app->config->{authentication}->{ldap}->{securitycredentials};
  $sf =~ s/\{0\}/$username/g;
  if ($sp ne '') {
    $ldap->bind($sp, password => $sc);
  }
  my @user_search_bases = @{$c->app->config->{authentication}->{ldap}->{usersearchbase}};
  my $dn;
  foreach my $user_search_base (@user_search_bases) {
    my $searchresult = $ldap->search(
      base   => $user_search_base,
      filter => $sf,
      attrs  => ['dn']
    );
    foreach my $entry ($searchresult->entries) {
      $dn = $entry->dn;
    }
    last if $dn;
  }

  unless ($dn) {
    $c->app->log->debug("auth: dn not found");
    unshift @{$res->{alerts}}, {type => 'error', msg => 'user not found'};
    $res->{status} = 401;
    $c->stash({phaidra_auth_result => $res});
    return undef;
  }

  # bind the user
  my $ldapMsg = $ldap->bind($dn, password => $password);

  $c->app->log->debug("Auth for user $dn:\n" . $c->app->dumper($ldapMsg) . "\nis error:" . $ldapMsg->is_error());

  if ($ldapMsg->is_error) {
    unshift @{$res->{alerts}}, {type => 'error', msg => $ldapMsg->error};
    $res->{status} = 401;
    $c->stash({phaidra_auth_result => $res});
    return undef;
  }
  else {
    $res->{status} = 200;
    $c->stash({phaidra_auth_result => $res});
    return $username;
  }
}

sub get_name {
  my ($self, $c, $username) = @_;

  my $entry = $self->getLDAPEntryForUser($c, $username);

  my $fname;
  my $lname;

  #$c->app->log->debug("XXXXXXXXXXXX ".Dumper($entry));

  foreach my $attr (@{$entry->{'asn'}->{'attributes'}}) {
    my $attrtype = $attr->{'type'};
    my @attvals  = @{$attr->{'vals'}};
    foreach my $val (@attvals) {
      if ($attrtype eq 'givenName') {
	$fname = $val;
      }
      if ($attrtype eq 'sn') {
	$lname = $val;
      }
    }

    last if ($fname && $lname);
  }

  return $fname . ' ' . $lname;
}

sub get_email {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  my $entry = $self->getLDAPEntryForUser($c, $username);

  foreach my $attr (@{$entry->{'asn'}->{'attributes'}}) {
    my $attrtype = $attr->{'type'};
    my @attvals  = @{$attr->{'vals'}};
    foreach my $val (@attvals) {
      if ($attrtype eq 'mail') {
	return $val;
      }
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

sub get_user_data {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  my $entry = $self->getLDAPEntryForUser($c, $username);

  my $fname;
  my $lname;

  foreach my $attr (@{$entry->{'asn'}->{'attributes'}}) {
    my $attrtype = $attr->{'type'};
    my @attvals  = @{$attr->{'vals'}};
    foreach my $val (@attvals) {
      if ($attrtype eq 'givenName') {
	$fname = $val;
      }
      if ($attrtype eq 'sn') {
	$lname = $val;
      }
    }

    last if ($fname && $lname);
  }

  my $res = {username => $username, firstname => $fname, lastname => $lname};
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
