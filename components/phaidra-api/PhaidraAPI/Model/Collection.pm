package PhaidraAPI::Model::Collection;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Membersorder;

sub create {

  my $self     = shift;
  my $c        = shift;
  my $metadata = shift;
  my $members  = shift;
  my $username = shift;
  my $password = shift;

  #my $cb = shift;

  my $res = {alerts => [], status => 200};

  # create object
  my $pid;
  my $object_model = PhaidraAPI::Model::Object->new;
  my $res_create   = $object_model->create($c, 'cmodel:Collection', $username, $password);
  if ($res_create->{status} ne 200) {
    return $res_create;
  }
  $pid = $res_create->{pid};

  my $res_md = $object_model->save_metadata($c, $pid, 'cmodel:Collection', $metadata, $username, $password, 0, 1);
  if ($res_md->{status} ne 200) {
    return $res_md;
  }

  $c->app->log->debug("Activating object");

  # activate
  my $res_act = $object_model->modify($c, $pid, 'A', undef, undef, undef, undef, $username, $password);
  if ($res_act->{status} eq 200) {
    $c->app->log->info("Object successfully created pid[$pid] cmodel[cmodel:Collection]");
  }

  $c->app->log->debug("Adding members");

  # add members
  if ($members) {
    my $members_size = scalar @{$members};
    if ($members_size > 0) {
      my @relationships;
      foreach my $member (@{$members}) {
        push @relationships, {predicate => "info:fedora/fedora-system:def/relations-external#hasCollectionMember", object => "info:fedora/" . $member->{pid}};
      }
      my $r = $object_model->add_relationships($c, $pid, \@relationships, $username, $password);
      push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      $res->{status} = $r->{status};
      if ($r->{status} ne 200) {
        return $res;
      }
    }

    # order members, if any positions are defined
    my @ordered_members;
    foreach my $member (@{$members}) {
      if (exists($member->{'pos'})) {
        push @ordered_members, $member;
      }
    }
    my $ordered_members_size = scalar @ordered_members;
    if ($ordered_members_size > 0) {
      my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
      $c->app->log->debug("Saving collectionorder: " . $c->app->dumper(\@ordered_members));
      my $r = $membersorder_model->save_to_object($c, $pid, \@ordered_members, $username, $password, 0);
      push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      $res->{status} = $r->{status};
      if ($r->{status} ne 200) {
        return $res;
      }
    }
  }

  if (exists($metadata->{'ownerid'})) {
    $c->app->log->debug("Changing ownerid to " . $metadata->{'ownerid'});
    my $authorized = 0;
    if ( ($username eq $c->app->config->{phaidra}->{intcallusername})
      || ($username eq $c->app->config->{phaidra}->{adminusername}))
    {
      $authorized = 1;
    }
    else {
      if ($c->app->config->{authorization}) {
        if ($c->app->config->{authorization}->{canmodifyownerid}) {
          for my $user (@{$c->app->config->{authorization}->{canmodifyownerid}}) {
            if ($user eq $username) {
              $authorized = 1;
              last;
            }
          }
        }
      }
    }
    if ($authorized) {
      my $r = $object_model->modify($c, $pid, undef, undef, $metadata->{'ownerid'}, undef, undef, $username, $password, 1);
      if ($r->{status} ne 200) {
        $res->{status} = $r->{status};
        foreach my $a (@{$r->{alerts}}) {
          unshift @{$res->{alerts}}, $a;
        }
        unshift @{$res->{alerts}}, {type => 'error', msg => 'Error modifying ownership'};
      }
    }
  }

  $res->{pid} = $pid;

  return $res;
}

sub get_members {

  my $self    = shift;
  my $c       = shift;
  my $pid     = shift;
  my $nocache = shift;

  my $res = {members => [], alerts => [], status => 200};

  my $search_model = PhaidraAPI::Model::Search->new;

  my $cmodel;
  my $res_cmodel = $search_model->get_cmodel($c, $pid);
  if ($res_cmodel->{status} ne 200) {
    $self->app->log->error("Collection->get_members: pid[$pid] could not get cmodel");
    return $res_cmodel;
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  unless ($cmodel) {
    $c->app->log->error("Collection->get_members: pid[$pid] Undefined cmodel");
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Object content model is undefined'};
    $res->{status} = 400;
    return $res;
  }

  if ($cmodel ne 'Collection') {
    $c->app->log->error("Collection->get_members: pid[$pid] cmodel[$cmodel] is not Collection");
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Object content model is not Collection'};
    $res->{status} = 400;
    return $res;
  }

  # get lastModifiedDate and check if the members are cached
  my $cachekey;
  my $cached_members;
  my $r = $search_model->get_last_modified_date($c, $pid);
  if ($r->{status} eq 200) {
    $cachekey = 'members_' . $pid . '_' . $r->{lastmodifieddate};
  }
  else {
    $c->app->log->error("Collection->get_members: Cannot get lastModifiedDate!");
    return $r;
  }

  $cached_members = $c->app->chi->get($cachekey);

  $nocache = $nocache ? $nocache : 0;
  if ($cached_members && ($nocache != 1)) {
    $c->app->log->debug("[cache hit] $cachekey");
  }
  else {
    $c->app->log->debug("[cache miss] $cachekey");

    # get members
    my $sr = $search_model->triples($c, "<info:fedora/$pid> <info:fedora/fedora-system:def/relations-external#hasCollectionMember> *");
    push @{$res->{alerts}}, @{$sr->{alerts}} if scalar @{$sr->{alerts}} > 0;
    $res->{status} = $sr->{status};
    if ($sr->{status} ne 200) {
      return $sr;
    }

    my %members;
    foreach my $statement (@{$sr->{result}}) {
      @{$statement}[2] =~ m/^\<info:fedora\/([a-zA-Z\-]+:[0-9]+)\>$/g;
      $members{$1} = {'pos' => undef};
    }

    # check order definition
    my $sr2 = $search_model->datastream_exists($c, $pid, 'COLLECTIONORDER');
    if ($sr2->{status} ne 200) {
      $c->app->log->error("Cannot find out if COLLECTIONORDER exists for pid: $pid and username: " . $c->stash->{basic_auth_credentials}->{username});
    }
    else {
      if ($sr2->{'exists'}) {

        # FIXME user membersorder model

        my $object_model = PhaidraAPI::Model::Object->new;
        my $ores         = $object_model->get_datastream($c, $pid, 'COLLECTIONORDER', undef, undef, 1);
        if ($ores->{status} ne 200) {
          $c->app->log->error("Cannot get COLLECTIONORDER for pid: $pid and username: " . $c->stash->{basic_auth_credentials}->{username});
        }
        else {
          push @{$res->{alerts}}, @{$ores->{alerts}} if scalar @{$ores->{alerts}} > 0;
          $res->{status} = $ores->{status};

          my $xml = Mojo::DOM->new();
          $xml->xml(1);
          $xml->parse($ores->{COLLECTIONORDER});
          $xml->find('member[pos]')->each(
            sub {
              my $m   = shift;
              my $pid = $m->text;
              $members{$pid}->{'pos'} = $m->{'pos'} if exists $members{$pid};
            }
          );

          foreach my $p (keys %members) {
            push @$cached_members, {pid => $p, 'pos' => $members{$p}->{'pos'}};
          }
          no warnings;

          sub undef_sort {
                $a->{pos} eq "" && $b->{pos} eq "" ? 0
              : $a->{pos} eq ""                    ? +1
              : $b->{pos} eq ""                    ? -1
              :                                      $a->{pos} cmp $b->{pos};
          }
          @$cached_members = sort undef_sort @$cached_members;

        }
      }
    }

    # return non-ordered members
    unless ($cached_members) {
      foreach my $p (keys %members) {
        push @$cached_members, {pid => $p, 'pos' => undef};
      }
    }

    $c->app->chi->set($cachekey, $cached_members, '1 day');
  }

  # we have to return an empty array if there is nothing
  unless (defined($cached_members)) {
    my @arr = ();
    $res->{members} = \@arr;
  }
  else {
    $res->{members} = $cached_members;
  }
  return $res;

}

1;
__END__
