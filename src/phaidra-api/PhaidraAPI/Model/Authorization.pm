package PhaidraAPI::Model::Authorization;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Rights;
use PhaidraAPI::Model::Fedora;

sub check_rights {
  no warnings 'uninitialized';
  my ($self, $c, $pid, $op) = @_;

  my $res = {alerts => [], status => 500};

  if ($c->app->config->{fedora}->{version} >= 6) {

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

    my $userdata = $c->app->directory->get_user_data($c, $currentuser);
    unless ($userdata) {
      $c->app->log->error("Authz op[$op] pid[$pid] currentuser[$currentuser] failed");
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
    my $rightsres    = $rights_model->get_object_rights_json($c, $pid, $c->app->config->{phaidra}->{intcallusername}, $c->app->config->{phaidra}->{intcallpassword});
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

    # see PhaidraAPI::Model::Rights
    # 'username'   => 1,
    # 'department' => 1,
    # 'faculty'    => 1,
    # 'gruppe'     => 1,

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

    if (exists($rights->{'department'})) {
      $rightsAreEmpty = 0;
      for my $def (@{$rights->{'department'}}) {
        my $v;
        if (exists($def->{value})) {
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
        if (exists($def->{value})) {
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
        if (exists($def->{value})) {
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

    # these are no more supported
    # but that does not mean the object should be open
    # 'spl'        => 1,
    # 'kennzahl'   => 1,
    # 'perfunk'    => 1
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
  else {

    my $username = $c->stash->{basic_auth_credentials}->{username};
    if ($c->stash->{remote_user}) {
      $username = $c->stash->{remote_user};
    }

    my $ds;
    if ($op eq 'ro' or $op eq 'r') {
      $ds = 'READONLY';
    }
    elsif ($op eq 'rw' or $op eq 'w') {
      $ds = 'READWRITE';
    }
    else {
      $res->{alerts} = [{type => 'error', msg => 'Unknown operation to check'}];
      $res->{status} = 400;
      return $res;
    }

    my $object_model = PhaidraAPI::Model::Object->new;
    my $getres       = $object_model->get_datastream($c, $pid, $ds, $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password});

    if ($getres->{status} eq 404) {
      $c->app->log->info("Authz op[$op] pid[$pid] username[" . (defined($username) ? $username : '') . "] successful");
      $res->{status} = 200;
      return $res;
    }
    else {
      $c->app->log->info("Authz op[$op] pid[$pid] username[" . (defined($username) ? $username : '') . "] failed");
      $res->{status} = 403;
      $res->{json}   = $getres;
      push @{$res->{alerts}}, @{$getres->{alerts}} if scalar @{$getres->{alerts}} > 0;
      return $res;
    }
  }

}

1;
__END__
