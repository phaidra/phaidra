package PhaidraAPI::Controller::Authorization;

use strict;
use warnings;
use v5.10;
use Mojo::ByteStream qw(b);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Authorization;

our %createActions = (
  'picture/create'        => 1,
  'document/create'       => 1,
  'video/create'          => 1,
  'audio/create'          => 1,
  'unknown/create'        => 1,
  'resource/create'       => 1,
  'page/create'           => 1,
  'container/create'      => 1,
  'collection/create'     => 1,
  'ir/submit'             => 1,
  'object/create'         => 1,
  'object/create/:cmodel' => 1
);

sub authorize {
  my $self = shift;

  my $res = {alerts => [], status => 500};

  my $op = $self->stash('op');
  unless ($op eq 'r' or $op eq 'w') {
    $self->app->log->error("Authz op[$op] failed - unknown op");
    $res->{status} = 500;
    return $res;
  }

  my $pid          = $self->stash('pid') ? $self->stash('pid') : "";
  my $pidNamespace = $self->app->config->{fedora}->{pidnamespace};
  unless ($pid =~ m/^$pidNamespace:\d+$/) {
    if ($createActions{$self->stash('action')}) {
      if ($op eq 'w') {

        # authn already happened
        $res->{status} = 200;
        return $res;
      }
      else {
        # nonsense
        $self->app->log->error("Authz op[$op] pid[$pid] failed - non-write create");
        $res->{status} = 500;
        return $res;
      }
    }
    else {
      $self->app->log->error("Authz op[$op] pid[$pid] failed - wrong pid");
      $res->{status} = 500;
      return $res;
    }
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  $res         = $authz_model->check_rights($self, $pid, $op);

  $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});

}

sub check_rights {

  my $self = shift;

  my $res = {alerts => [], status => 500};

  my $pid          = $self->stash('pid');
  my $pidNamespace = $self->app->config->{fedora}->{pidnamespace};
  unless ($pid =~ m/^$pidNamespace:\d+$/) {
    $self->app->log->error("Authz pid[$pid] failed - wrong pid");
    $res->{status} = 500;
    return $res;
  }
  my $op = $self->stash('op');
  unless ($op eq 'r' or $op eq 'ro' or $op eq 'w' or $op eq 'rw') {
    $self->app->log->error("Authz op[$op] pid[$pid] failed - unknown op");
    $res->{status} = 500;
    return $res;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  $res         = $authz_model->check_rights($self, $pid, $op);

  $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});
}

1;
