package Phaidra::Directory::Default;

use utf8;
use Encode;
use strict;
use warnings;
use Data::Dumper;
use Storable 'dclone';
use MongoDB;
use Data::UUID;
use Net::LDAPS;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);
use YAML::Syck;
use Mojo::JSON qw(encode_json decode_json);
use base 'Phaidra::Directory';

my $config = undef;

my $orgunitsDefault = [ 
  {
    '@id' => "https://example.com/my-organization/1234",
    '@type' => "foaf:Organization",
    "skos:notation" => "X1",
    "skos:prefLabel" => {
      "deu" => "Meine Organisation",
      "eng" => "My Organization"
    },
    "subunits" => [
      {
        '@id' => "https://example.com/my-organization/5678",
        '@type' => "aiiso:Division",
        "skos:notation" => "X11",
        "skos:prefLabel" => {
          "deu" => "Management meiner Organisation",
          "eng" => "My Organization's Management"
        }
      },
      {
        '@id' => "https://example.com/my-organization/5678",
        '@type' => "aiiso:Division",
        "skos:notation" => "X12",
        "skos:prefLabel" => {
          "deu" => "Rechtsabteilung meiner Organisation",
          "eng" => "My Organization's Law Department"
        }
      }
    ]
  }
];

sub _init {

  # this is the app config
  my $self = shift;
  my $c = shift;

  $c->app->log->info(__PACKAGE__.' loaded');

  return $self;
}

sub _get_org_units {
  my ($self, $c) = @_;

  my $confcol = $self->_get_config_col($c);
  my $publicConfig = $confcol->find_one({"config_type" => "public"});
  if ($publicConfig && ($publicConfig->{data_orgunits}) && ($publicConfig->{data_orgunits} ne '')) {
    # $c->app->log->info("orgunits public config found");
    return $publicConfig->{data_orgunits};
  } else {
    $c->app->log->info("orgunits config not found in public config, using default");
    return $orgunitsDefault;
  }
}

sub _find_org_unit_rec {
  my ($self, $c, $orgunits, $id) = @_;

  my $unit;
  for my $u (@{$orgunits}) {
    if ($u->{'@id'} eq $id) {
      $unit = $u;
      last;
    } else {
      if (exists($u->{'subunits'})) {
        $unit = $self->_find_org_unit_rec($c, $u->{'subunits'}, $id);
        last if $unit;
      }
    }
  }
  return $unit;
}

sub _find_org_superunit_rec {
  my ($self, $c, $parent, $children, $id) = @_;

  my $unit;
  for my $u (@{$children}) {
    if ($u->{'@id'} eq $id) {
      $unit = $parent;
      last;
    } else {
      if (exists($u->{'subunits'})) {
        $unit = $self->_find_org_superunit_rec($c, $u, $u->{'subunits'}, $id);
        last if $unit;
      }
    }
  }
  return $unit;
}

sub _find_org_unit_rec_for_notation {
  my ($self, $c, $orgunits, $notation) = @_;

  my $unit;
  for my $u (@{$orgunits}) {
    if ($u->{'skos:notation'} eq $notation) {
      $unit = $u;
      last;
    } else {
      if (exists($u->{'subunits'})) {
        $unit = $self->_find_org_unit_rec_for_notation($c, $u->{'subunits'}, $notation);
        last if $unit;
      }
    }
  }
  return $unit;
}

sub org_get_unit {
  my ($self, $c, $id) = @_;

  my $res = {alerts => [], status => 200};

  my $orgunits = $self->_get_org_units($c);
  my $unit = $self->_find_org_unit_rec($c, $orgunits, $id);
  if ($unit) {
    for my $u (@{$unit->{subunits}}) {
      delete $u->{subunits};
    }
    $res->{unit} = $unit;
  } else {
    push @{$res->{alerts}}, {type => 'error', msg => "id[$id] not found"};
    $res->{status} = 404;
  }
  return $res;
}

sub org_get_unit_for_notation {
  my ($self, $c, $id) = @_;

  my $res = {alerts => [], status => 200};

  my $orgunits = $self->_get_org_units($c);
  my $unit = $self->_find_org_unit_rec_for_notation($c, $orgunits, $id);
  if ($unit) {
    for my $u (@{$unit->{subunits}}) {
      delete $u->{subunits};
    }
    $res->{unit} = $unit;
  } else {
    push @{$res->{alerts}}, {type => 'error', msg => "notation[$id] not found"};
    $res->{status} = 404;
  }
  return $res;
}

sub org_get_name {
  my ($self, $c, $lang) = @_;

  my $confcol = $self->_get_config_col($c);
  my $publicConfig = $confcol->find_one({"config_type" => "public"});
  my $inst;
  if ($publicConfig && ($publicConfig->{institution}) && ($publicConfig->{institution} ne '')) {
    $inst = $publicConfig->{institution};
  }
  if ($inst) {
    if (exists($publicConfig->{data_i18n})) {
      for my $l (keys %{$publicConfig->{data_i18n}}) {
        if ($l eq $lang) {
          if (exists($publicConfig->{data_i18n}->{$l}->{$inst})) {
            $inst = $publicConfig->{data_i18n}->{$l}->{$inst};
          }
        }
      }
    }
    return $inst;
  } else {
    return '';
  }
}

sub org_get_subunits {
  my ($self, $c, $id) = @_;

  my $res = {alerts => [], status => 200};

  my $orgunits = $self->_get_org_units($c);
  my $unit = $self->_find_org_unit_rec($c, $orgunits, $id);
  if ($unit) {
    for my $u (@{$unit->{subunits}}) {
      delete $u->{subunits};
    }
    $res->{subunits} = $unit->{subunits};
  } else {
    push @{$res->{alerts}}, {type => 'error', msg => "$id not found"};
    $res->{status} = 404;
  }
  return $res;
}

sub org_get_subunits_for_notation {
  my ($self, $c, $notation) = @_;

  my $res = {alerts => [], status => 200};

  my $orgunits = $self->_get_org_units($c);
  my $unit;
  if ($notation) {
    $unit = $self->_find_org_unit_rec_for_notation($c, $orgunits, $notation);
  } else {
    $unit = @{$orgunits}[0];
  }
  if ($unit) {
    for my $u (@{$unit->{subunits}}) {
      delete $u->{subunits};
    }
    $res->{subunits} = $unit->{subunits};
  } else {
    push @{$res->{alerts}}, {type => 'error', msg => "$notation not found"};
    $res->{status} = 404;
  }
  return $res;
}

sub org_get_superunits {
  my ($self, $c, $id) = @_;

  my $res = {alerts => [], status => 200};

  my $orgunits = $self->_get_org_units($c);
  my $unit = $self->_find_org_superunit_rec($c, undef, $orgunits, $id);
  if ($unit) {
    delete $unit->{subunits};
    $res->{superunits} = [ $unit ];
  } else {
    $res->{superunits} = [];
  }
 
  return $res;
}

sub org_get_units {
  my ($self, $c, $flat) = @_;

  my $res;

  my $orgunits = $self->_get_org_units($c);
  if ($flat) {
    my @orgunitsArr;
    $self->_org_get_units_rec_flat($c, $orgunits, \@orgunitsArr);
    $res = {alerts => [], units => \@orgunitsArr, status => 200};
  }
  else {
    $res = {alerts => [], units => $orgunits, status => 200};
  }

  return $res;
}

sub org_get_units_uwm {
  my ($self, $c, $parent_id, $lang) = @_;

  my $values = [];
  my $unitsres;
  if ($parent_id) {
    $unitsres = $self->org_get_subunits_for_notation($c, $parent_id);
  } else {
    $unitsres = $self->org_get_subunits_for_notation($c);
  }

  if ($unitsres->{status} == 200) {
    my $lang6393 = $PhaidraAPI::Model::Languages::iso639map{$lang};
    for my $u (@{$unitsres->{subunits}}) {
      my $name;
      for my $l (keys %{$u->{'skos:prefLabel'}}) {
        if ($l eq $lang6393) {
          $name = $u->{'skos:prefLabel'}->{$l};
        }
      }
      unless ($name) {
        $name = $u->{'skos:prefLabel'}->{'eng'};
      }
      push @{$values}, {
        value => $u->{'skos:notation'},
        name => $name
      };
    }
  }

  return { org_units => $values };
}

sub org_get_parentpath {
  my ($self, $c, $id) = @_;

  my @parentpath;
  my $orgunits = $self->_get_org_units($c);
  my $unit = $self->_find_org_unit_rec($c, $orgunits, $id);
  if ($unit) {
    delete $unit->{subunits};
    push @parentpath, $unit;
    my $superunit = $self->_find_org_superunit_rec($c, undef, $orgunits, $id);
    while ($superunit) {
      delete $superunit->{subunits};
      push @parentpath, $superunit;
      $superunit = $self->_find_org_superunit_rec($c, undef, $orgunits, $superunit->{'@id'});
    }
  }
  
  return {alerts => [], parentpath => \@parentpath, status => 200};
}

sub _org_get_units_rec {
  my ($self, $c, $units) = @_;

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
  my ($self, $c, $units, $arr) = @_;

  for my $u (@{$units}) {
    my $u_copy = dclone $u;
    delete $u_copy->{subunits};
    push @{$arr}, $u_copy;
    if (exists($u->{subunits})) {
      if (scalar(@{$u->{subunits}}) > 0) {
        $self->_org_get_units_rec_flat($c, $u->{subunits}, $arr);
      }
    }
  }
}

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
    $c->app->log->error("get_ldap error");
    $c->app->log->error($ldapMsg->error);
    unshift @{$res->{alerts}}, {type => 'error', msg => $ldapMsg->error};
    return $res;
  }

  # $c->app->log->error("get_ldap OK");
  return $ldap;
}

sub get_ldap_ext {
  my $self = shift;
  my $c    = shift;
  my $privateConfig = shift;
  
  my $res = {alerts => [], status => 500};

  my $LDAP_SERVER   = $privateConfig->{ldapexthost};
  my $LDAP_SSL_PORT = $privateConfig->{ldapextport};

  my $ldap = Net::LDAPS->new($LDAP_SERVER, port => $LDAP_SSL_PORT);
  unless (defined($ldap)) {
    unshift @{$res->{alerts}}, {type => 'error', msg => $!};
    return $res;
  }

  # bind the security principal account
  my $secDN   = $privateConfig->{ldapextprincipal};
  my $secPASS = $privateConfig->{ldapextprincipalpassword};
  my $ldapMsg = $ldap->bind($secDN, password => $secPASS);

  if ($ldapMsg->is_error) {
    $c->app->log->error("get_ldap error");
    $c->app->log->error($ldapMsg->error);
    unshift @{$res->{alerts}}, {type => 'error', msg => $ldapMsg->error};
    return $res;
  }

  # $c->app->log->error("get_ldap_ext OK");
  return $ldap;
}

sub getLDAPEntryForUser {

  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  return undef unless (defined($username));
  
  my $entry = $self->_getLDAPEntryForUser($c, $self->get_ldap($c), $c->app->config->{authentication}->{ldap}->{usersearchfilter}, $c->app->config->{authentication}->{ldap}->{usersearchbases}, $username);

  my $confcol = $self->_get_config_col($c);
  my $privateConfig = $confcol->find_one({"config_type" => "private"});
  if ($privateConfig->{ldapextenable}) {
    my $entry_ext = $self->_getLDAPEntryForUser($c, $self->get_ldap_ext($c, $privateConfig), $privateConfig->{ldapextusersearchfilter}, $privateConfig->{ldapextusersearchbases}, $username);
    if ($entry_ext) {
      if ($entry) {
        for my $att (@{$entry->{'asn'}->{'attributes'}}) {
          # Merge entry into entry_ext
          push @{$entry_ext->{'asn'}->{'attributes'}}, $att;
        }
      }
      return $entry_ext;
    }
  }

  return $entry;
}

sub _getLDAPEntryForUser {

  my $self     = shift;
  my $c        = shift;
  my $ldap = shift;
  my $filter = shift;
  my $usersearchbases = shift;
  my $username = shift;

  return undef unless (defined($username));

  $filter =~ s/\{0\}/$username/;

  my @user_search_bases = split(';', $usersearchbases);

  foreach my $user_search_base (@user_search_bases){
    $user_search_base =~ s/^\s+|\s+$//g;
    $c->app->log->info("Searching for user $username in searchbase $user_search_base.");

    my $ldapSearch = $ldap->search(base => $user_search_base, filter => $filter);

    die "There was an error during search:\n\t" . ldap_error_text($ldapSearch->code) if $ldapSearch->code;

    while (my $ldapEntry = $ldapSearch->pop_entry()) {
      foreach my $attr (@{$ldapEntry->{'asn'}->{'attributes'}}) {
        my $attrtype = $attr->{'type'};
        my @attvals  = @{$attr->{'vals'}};
        foreach my $val (@attvals) {
          if ($attrtype eq 'uid') {
            if ($val eq $username) {

              # $c->app->log->debug("getLDAPEntryForUser $username in base $user_search_base:\n".$c->app->dumper($ldapEntry));
              return $ldapEntry;
            }
          }
        }
      }
    }
  }

}

sub _getUsersLDAPGroups {
  my $self     = shift;
  my $c        = shift;
  my $ldap = shift;
  my $groupsearchbases = shift;
  my $username = shift;

  return undef unless (defined($username));

  my $filter = "(&(memberUid={0})(objectClass=posixGroup))";
  $filter =~ s/\{0\}/$username/;

  my @groups_search_bases = split(';', $groupsearchbases);

  my @groups;
  for my $groups_search_base (@groups_search_bases) {
    $groups_search_base =~ s/^\s+|\s+$//g;

    $c->app->log->info("Searching for local groups of $username in searchbase $groups_search_base.");

    my $ldapSearch = $ldap->search(base => $groups_search_base, filter => $filter);

    die "There was an error during search:\n\t" . ldap_error_text($ldapSearch->code) if $ldapSearch->code;

    while (my $ldapEntry = $ldapSearch->pop_entry()) {
      foreach my $attr (@{$ldapEntry->{'asn'}->{'attributes'}}) {
        my $attrtype = $attr->{'type'};
        my @attvals  = @{$attr->{'vals'}};
        if ($attrtype eq 'cn') {
          foreach my $val (@attvals) {
            push @groups, $val;
          }
        }
      }
    }
  }

  return \@groups;
}

sub getUsersLDAPGroups {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  my $localGroups = $self->_getUsersLDAPGroups($c, $self->get_ldap($c), $c->app->config->{authentication}->{ldap}->{groupssearchbase}, $username);

  my $confcol = $self->_get_config_col($c);
  my $privateConfig = $confcol->find_one({"config_type" => "private"});
  my $extGroups = [];
  if ($privateConfig->{ldapextenable}) {
    if ($privateConfig->{ldapextgroupssearchbases}) {
      $extGroups = $self->_getUsersLDAPGroups($c, $self->get_ldap_ext($c, $privateConfig), $privateConfig->{ldapextgroupssearchbases}, $username);
    }
  }

  return [ @$localGroups, @$extGroups ];
}

sub _authenticate() {
  my $self      = shift;
  my $c         = shift;
  my $LDAP_SERVER         = shift;
  my $LDAP_PORT         = shift;
  my $ldaps         = shift;
  my $sf  = shift;
  my $sp  = shift;
  my $sc  = shift;
  my $usersearchbases  = shift;
  my $username  = shift;
  my $password  = shift;

  $c->app->log->debug("auth: ldap login");
  my $res = {alerts => [], status => 500};

  my $ldap;
  if ($ldaps) {
    $ldap = Net::LDAPS->new($LDAP_SERVER, port => $LDAP_PORT);
  } else {
    $ldap = Net::LDAP->new($LDAP_SERVER, port => $LDAP_PORT);
  }
  unless (defined($ldap)) {
    unshift @{$res->{alerts}}, {type => 'error', msg => $!};
    $c->stash({phaidra_auth_result => $res});
    return undef;
  }

  # first we have to find the DN (i think its differs for various account types)
  $sf =~ s/\{0\}/$username/g;
  #$c->log->info("_authenticate filer $sf");
  if ($sp ne '') {
    $ldap->bind($sp, password => $sc);
  }
  my @user_search_bases = split(';', $usersearchbases);
  my $dn;
  foreach my $user_search_base (@user_search_bases) {
    $user_search_base =~ s/^\s+|\s+$//g;
    $c->log->info("_authenticate searching $sf in searchbase $user_search_base");
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

  $c->app->log->debug("Auth for user $dn [is error: " . $ldapMsg->is_error() . "]");

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

sub authenticate() {

  my $self      = shift;
  my $c         = shift;
  my $username  = shift;
  my $password  = shift;

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
  if (($username eq $c->app->config->{phaidra}->{adminusername}) && ($password eq $c->app->config->{phaidra}->{adminpassword})) {

    # this account is (should be) local to fedora so we cannot authenticate it against LDAP
    $c->app->log->debug("auth: phaidraadmin login");
    $res->{status} = 200;
    $c->stash({phaidra_auth_result => $res});
    return $username;
  }

  my $localAuthRes = $self->_authenticate(
    $c, 
    $c->app->config->{authentication}->{ldap}->{server},
    $c->app->config->{authentication}->{ldap}->{port},
    0,
    $c->app->config->{authentication}->{ldap}->{usersearchfilter},
    $c->app->config->{authentication}->{ldap}->{securityprincipal},
    $c->app->config->{authentication}->{ldap}->{securitycredentials},
    $c->app->config->{authentication}->{ldap}->{usersearchbases},
    $username, 
    $password
  );
  return $localAuthRes if $localAuthRes;
  
  my $confcol = $self->_get_config_col($c);
  my $privateConfig = $confcol->find_one({"config_type" => "private"});
  if ($privateConfig->{ldapextenable}) {
    return $self->_authenticate(
      $c, 
      $privateConfig->{ldapexthost},
      $privateConfig->{ldapextport},
      1,
      $privateConfig->{ldapextusersearchfilter},
      $privateConfig->{ldapextprincipal},
      $privateConfig->{ldapextprincipalpassword},
      $privateConfig->{ldapextusersearchbases},
      $username, 
      $password
    );
  }
}

sub get_name {
  my ($self, $c, $username) = @_;

  if ($username eq $c->app->config->{phaidra}->{adminusername}) {
    return $username;
  }

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

  if ($username eq $c->app->config->{phaidra}->{adminusername}) {
    return 'admin.phaidra@univie.ac.at';
  }

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

sub get_user_data {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  return {} unless (defined($username));
  
  if ($username eq $c->app->config->{phaidra}->{adminusername}) {
    return {username => $c->app->config->{phaidra}->{adminusername}, firstname => 'PHAIDRA', lastname => 'Admin', isadmin => 1};
  }

  my $entry = $self->getLDAPEntryForUser($c, $username);
  $c->log->debug("ldap data: ".Dumper($entry));

  my $fname;
  my $lname;
  my $email;
  my @affiliation;
  my @orgul1;
  my @orgul2;
  my $description;

  if (exists($entry->{'asn'}->{'attributes'})) {
    # if user was found in LDAP, it at least belongs to the organisation
    push @orgul1, 'A-1';
  }

  foreach my $attr (@{$entry->{'asn'}->{'attributes'}}) {
    my $attrtype = $attr->{'type'};
    my @attvals  = @{$attr->{'vals'}};
    foreach my $val (@attvals) {
      if ($attrtype eq 'givenName') {
        $fname = decode('UTF-8', $val);
      }
      if ($attrtype eq 'sn') {
        $lname = decode('UTF-8', $val);
      }
      if ($attrtype eq 'mail') {
        $email = decode('UTF-8', $val);
      }
      if ($attrtype eq 'ou') {
        push @orgul1, decode('UTF-8', $val);
      }
      if ($attrtype eq 'departmentNumber') {
        push @orgul2, decode('UTF-8', $val);
      }
      if ($attrtype eq 'description') {
        $description = decode('UTF-8', $val);
      }
    }

  }

  my $ldapgroups = $self->getUsersLDAPGroups($c, $username);

  $c->app->log->info("ldapgroups: ".$c->app->dumper($ldapgroups));

  if ($c->stash('remote_user') && $c->stash('remote_user') eq $username) {
    # in case there is no user data api, use the attrs we saved on shib login, if it's equal to the requested user param
    my $sessionData = $c->load_cred;
    unless ($fname) {
      $fname = $sessionData->{firstname};
    }
    unless ($lname) {
      $lname = $sessionData->{lastname};
    }
    unless ($email) {
      $email = $sessionData->{email};
    }
    if ($sessionData->{affiliation}) {
      @affiliation = split(';', $sessionData->{affiliation});
    }
  }

  my $groups = $self->get_member_groups($c, $username);

  my $res = {username => $username, firstname => $fname, lastname => $lname, ldapgroups => $ldapgroups, groups => $groups, email => $email, affiliation => \@affiliation, org_units_l1 => \@orgul1, org_units_l2 => \@orgul2, displayname => $description};
}

sub is_superuser {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  return 0;
}

sub is_superuser_for_user {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  return [];
}

sub search_user {
  my ($self, $c, $searchstring, $superuser) = @_;

  my @persons = $self->getLDAPEntriesForQuery($c, $searchstring);

  my $hits = scalar @persons;
  return \@persons, $hits;
}

sub getLDAPEntriesForQuery {
  my ($self, $c, $query) = @_;

  my $entry_local = $self->_getLDAPEntriesForQuery($c, $self->get_ldap($c), $c->app->config->{authentication}->{ldap}->{usersearchfilter}, $c->app->config->{authentication}->{ldap}->{usersearchbases}, $query);

  my $confcol = $self->_get_config_col($c);
  my $privateConfig = $confcol->find_one({"config_type" => "private"});
  if ($privateConfig->{ldapextenable}) {
    my $entry_ext = $self->_getLDAPEntriesForQuery($c, $self->get_ldap_ext($c, $privateConfig), $privateConfig->{ldapextusersearchbases}, $privateConfig->{ldapextusersearchfilter}, $query);
    if (defined $entry_ext) {
      foreach my $attr (keys %$entry_ext) {
        # Merge entry_ext into entry_local if entry_ext has attributes
        # not already present in entry_local
        $entry_local->{$attr} = $entry_ext->{$attr} unless exists $entry_local->{$attr};
      }
    }
  }
}

sub _getLDAPEntriesForQuery {

  my ($self, $c, $ldap, $filter, $usersearchbases, $query) = @_;

  my @user_search_bases = split(';', $usersearchbases);
  my $dn;

  $query = "*$query*";
  $filter =~ s/\{0\}/$query/;

  #$c->log->info("Search filter: $filter");

  my @persons;
  foreach my $user_search_base (@user_search_bases) {
    $user_search_base =~ s/^\s+|\s+$//g;

    $c->log->info("Searching searchbase $user_search_base.");

    my $ldapSearch = $ldap->search(base => $user_search_base, filter => $filter);

    die "There was an error during search:\n\t" . ldap_error_text($ldapSearch->code) if $ldapSearch->code;

    while (my $ldapEntry = $ldapSearch->pop_entry()) {

      #$c->log->info("entry:\n" . $c->app->dumper($ldapEntry));
      my %person;
      foreach my $attr (@{$ldapEntry->{'asn'}->{'attributes'}}) {
        my $attrtype = $attr->{'type'};
        my @attvals  = @{$attr->{'vals'}};

        foreach my $val (@attvals) {
          if ($attrtype eq 'cn') {
            $person{'username'} = $val;
          }
          if ($attrtype eq 'uid') {
            $person{'uid'} = $val;
          }
          if ($attrtype eq 'givenName') {
            $person{'firstname'} = $val;
          }
          if ($attrtype eq 'sn') {
            $person{'lastname'} = $val;
          }
          if ($attrtype eq 'fullName') {
            $person{'value'} = $val;
          }
          if ($attrtype eq 'ou') {
            $person{'type'} = $val;
          }
        }
      }
      $person{'value'} = $person{'firstname'} . ' ' . $person{'lastname'};
      push @persons, \%person if $person{'uid'};
    }
  }

  #$c->log->debug("Found persons:".Dumper(\@persons));
  return @persons;

}

sub _connect_mongodb() {
  my $self = shift;
  my $c    = shift;

  my $client = MongoDB::MongoClient->new(
    host     => $c->app->config->{mongodb}->{host},
    port     => $c->app->config->{mongodb}->{port},
    username => $c->app->config->{mongodb}->{username},
    password => $c->app->config->{mongodb}->{password},
    db_name  => $c->app->config->{mongodb}->{db_name}
  );

  return $client;
}

sub _get_config_col() {
  my $self = shift;
  my $c    = shift;

  my $client = $self->_connect_mongodb($c);
  my $db     = $client->get_database($c->app->config->{mongodb}->{database});
  return $db->get_collection('config');
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

sub get_member_groups {
  my ($self, $c, $owner) = @_;

  my $groups = $self->_get_groups_col($c);

  my $members_groups = $groups->find({"members" => $owner});
  my @grps         = ();
  if ($members_groups) {
    while (my $doc = $members_groups->next) {
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
  my $g      = $groups->delete_one({"groupid" => $gid, "owner" => $owner});

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
