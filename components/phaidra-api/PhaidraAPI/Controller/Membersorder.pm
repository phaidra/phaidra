package PhaidraAPI::Controller::Membersorder;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Membersorder;
use PhaidraAPI::Model::Util;
use Time::HiRes qw/tv_interval gettimeofday/;

sub json2xml {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};

  my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
  my $membersxml         = $membersorder_model->json_2_xml($self, $metadata->{members});

  $self->render(json => {alerts => $res->{alerts}, metadata => $membersxml}, status => $res->{status});
}

sub xml2json {
  my $self = shift;

  my $mode = $self->param('mode');
  my $xml  = $self->req->body;

  my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
  my $res                = $membersorder_model->xml_2_json($self, $xml, $mode);

  $self->render(json => {metadata => {members => $res->{members}}, alerts => $res->{alerts}}, status => $res->{status});

}

sub get {
  my $self = shift;

  my $pid = $self->stash('pid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
  my $res                = $membersorder_model->get_object_collectionorder_json($self, $pid, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    if ($res->{status} eq 404) {
      $self->render(json => {alerts => $res->{alerts}, members => {}}, status => $res->{status});
    }
    $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
    return;
  }

  $self->render(json => {metadata => $res}, status => $res->{status});
}

sub post {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $pid      = $self->stash('pid');
  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->app->log->error("No metadata found");
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};
  unless (defined($metadata->{members})) {
    $self->app->log->error("No members sent");
    $self->render(json => {alerts => [{type => 'error', msg => 'No members sent'}]}, status => 400);
    return;
  }
  my $members = $metadata->{members};

  my $members_size = scalar @{$members};
  if ($members_size eq 0) {
    $self->app->log->error("Members array empty");
    $self->render(json => {alerts => [{type => 'error', msg => 'Members array empty'}]}, status => 400);
    return;
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

    # $self->app->log->debug("Saving ordered members: ".$self->app->dumper(\@ordered_members));
    my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
    my $r                  = $membersorder_model->save_to_object($self, $pid, \@ordered_members, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);
    push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
    $res->{status} = $r->{status};
    if ($r->{status} ne 200) {
      $self->render(json => $res, status => $res->{status});
      return;
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub order_object_member {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined collection pid'}]}, status => 400);
    return;
  }

  unless (defined($self->stash('itempid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined item pid'}]}, status => 400);
    return;
  }

  unless (defined($self->stash('position'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined position'}]}, status => 400);
    return;
  }

  unless ($self->stash('position') =~ m/\d+/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Position must be a numeric value'}]}, status => 400);
    return;
  }

  my $pid      = $self->stash('pid');
  my $itempid  = $self->stash('itempid');
  my $position = $self->stash('position');

  # FIXME - support container
  my $coll_model = PhaidraAPI::Model::Collection->new;
  my $r          = $coll_model->get_members($self, $pid);
  push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
  $res->{status} = $r->{status};
  if ($r->{status} ne 200) {
    $self->render(json => $res, status => $res->{status});
  }

  my @ordered_members = @{$r->{members}};

  my $i            = 0;
  my $update_index = 1;

  my @new_order;

  # insert item to new position
  $new_order[$position] = {pid => $itempid, 'pos' => $position};
  foreach my $m (@ordered_members) {

    if ($i eq $position) {

      # skip the place in new_order where we already inserted the new item
      $i++;
    }
    if ($m->{pid} eq $itempid) {

      # skip the item in ordered_members we already inserted
      next;
    }
    if ($m->{pid}) {
      $new_order[$i] = {pid => $m->{pid}, 'pos' => $i};
      $i++;
    }

  }

  my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
  $r = $membersorder_model->save_to_object($self, $pid, \@new_order, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);
  push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
  $res->{status} = $r->{status};
  if ($r->{status} ne 200) {
    $self->render(json => $res, status => $res->{status});
  }

  $self->render(json => $res, status => $res->{status});
}

1;
