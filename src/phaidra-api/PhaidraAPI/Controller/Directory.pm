package PhaidraAPI::Controller::Directory;

use strict;
use warnings;
use v5.10;
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Terms;
use base 'Mojolicious::Controller';

# [begin] new methods
sub org_get_subunits {
  my $self = shift;
  my $id   = $self->param('id');
  my $res  = $self->app->directory->org_get_subunits($self, $id);
  $self->render(json => $res, status => $res->{status});
}

sub org_get_superunits {
  my $self = shift;
  my $id   = $self->param('id');
  my $res  = $self->app->directory->org_get_superunits($self, $id);
  $self->render(json => $res, status => $res->{status});
}

sub org_get_parentpath {
  my $self = shift;
  my $id   = $self->param('id');
  my $res  = $self->app->directory->org_get_parentpath($self, $id);
  $self->render(json => $res, status => $res->{status});
}

sub org_get_units {
  my $self = shift;
  my $flat = $self->param('flat');
  my $res  = $self->app->directory->org_get_units($self, $flat);
  $self->render(json => $res, status => $res->{status});
}

# [end] new methods

sub get_org_units {
  my $self = shift;

  my $parent_id        = $self->param('parent_id');
  my $values_namespace = $self->param('values_namespace');

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $terms          = $metadata_model->get_org_units_terms($self, $parent_id, $values_namespace);

  # there are only results
  $self->render(json => {status => 200, terms => $terms}, status => 200);
}

sub get_parent_org_unit_id {
  my $self      = shift;
  my $child_id  = $self->param('child_id');
  my $parent_id = $self->app->directory->get_parent_org_unit_id($self, $child_id);
  $self->render(json => {status => 200, parent_id => $parent_id}, status => 200);
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

  my $username = $self->stash('username');

  my $name = $self->app->directory->get_name($self, $username);

  $self->render(json => {status => 200, name => $name}, status => 200);
}

sub get_user_email {
  my $self = shift;

  my $username = $self->stash('username');

  my $email = $self->app->directory->get_email($self, $username);

  $self->render(json => {status => 200, email => $email}, status => 200);
}

sub get_user_data {
  my $self = shift;

  my $username = $self->stash('username');

  unless ($username) {
    if ($self->stash('remote_user')) {
      $username = $self->stash('remote_user')
    } else {
      $username = $self->stash->{basic_auth_credentials}->{username};
    }
  }

  $self->app->log->debug("get user data username[$username]");

  my $user_data = $self->app->directory->get_user_data($self, $username);

  $self->render(json => {status => 200, user_data => $user_data}, status => 200);
}

sub search_user {
  my $self = shift;

  my $q = $self->param('q');
  my $exact = $self->param('exact');

  my ($r, $hits) = $self->app->directory->search_user($self, $q, $exact);

  $self->render(json => {status => 200, accounts => $r, hits => $hits}, status => 200);
}

1;
