package PhaidraAPI::Controller::Directory;

use strict;
use warnings;
use v5.10;
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Terms;
use PhaidraAPI::Model::Directory;
use base 'Mojolicious::Controller';

sub org_get_subunits {
  my $self            = shift;
  my $id              = $self->param('id');
  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $res             = $directory_model->org_get_subunits($self, $id);
  $self->render(json => $res, status => $res->{status});
}

sub org_get_superunits {
  my $self            = shift;
  my $id              = $self->param('id');
  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $res             = $directory_model->org_get_superunits($self, $id);
  $self->render(json => $res, status => $res->{status});
}

sub org_get_parentpath {
  my $self            = shift;
  my $id              = $self->param('id');
  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $res             = $directory_model->org_get_parentpath($self, $id);
  $self->render(json => $res, status => $res->{status});
}

sub org_get_units {
  my $self            = shift;
  my $flat            = $self->param('flat');
  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $res             = $directory_model->org_get_units($self, $flat);
  $self->render(json => $res, status => $res->{status});
}

sub get_study {
  my $self = shift;

  my $spl              = $self->param('spl');
  my $ids              = $self->every_param('ids');
  my $values_namespace = $self->param('values_namespace');

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $terms          = $metadata_model->get_study_terms($self, $spl, $ids, $values_namespace);

  $self->render(json => {status => 200, terms => $terms}, status => 200);
}

sub get_study_plans {
  my $self = shift;

  my $metadata_model = PhaidraAPI::Model::Terms->new;
  my $terms          = $metadata_model->get_study_plans($self);

  $self->render(json => {status => 200, terms => $terms->{study_plans}}, status => 200);
}

sub get_study_name {
  my $self = shift;

  my $spl = $self->param('spl');
  my $ids = $self->every_param('ids');

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $names          = $metadata_model->get_study_name($self, $spl, $ids);

  $self->render(json => {status => 200, study_name => $names}, status => 200);
}

sub get_user_name {
  my $self = shift;

  my $username        = $self->stash('username');
  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $name            = $directory_model->get_name($self, $username);

  $self->render(json => {status => 200, name => $name}, status => 200);
}

sub get_user_email {
  my $self = shift;

  my $username = $self->stash('username');

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $email           = $directory_model->get_email($self, $username);

  $self->render(json => {status => 200, email => $email}, status => 200);
}

sub get_user_data {
  my $self = shift;

  my $username = $self->stash('username');

  unless ($username) {
    if ($self->stash('remote_user')) {
      $username = $self->stash('remote_user');
    }
    else {
      $username = $self->stash->{basic_auth_credentials}->{username};
    }
  }

  $self->app->log->debug("get user data username[$username]");

  my $directory_model = PhaidraAPI::Model::Directory->new;
  my $user_data       = $directory_model->get_user_data($self, $username);
  if ($self->stash('remote_user') eq $username) {

    # in case there is no user data api, use the attrs we saved on shib login
    my $sessionData = $self->load_cred;
    unless (exists($user_data->{firstname}) && ($user_data->{firstname} ne '')) {
      $user_data->{firstname} = $sessionData->{firstname};
    }
    unless (exists($user_data->{lastname}) && ($user_data->{lastname} ne '')) {
      $user_data->{lastname} = $sessionData->{lastname};
    }
    unless (exists($user_data->{email}) && ($user_data->{email} ne '')) {
      $user_data->{email} = $sessionData->{email};
    }
    unless (exists($user_data->{affiliation}) && ($user_data->{affiliation} ne '')) {
      $user_data->{affiliation} = $sessionData->{affiliation};
    }
  }

  $self->render(json => {status => 200, user_data => $user_data}, status => 200);
}

1;
