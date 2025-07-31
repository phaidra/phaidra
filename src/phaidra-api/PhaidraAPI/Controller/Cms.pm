package PhaidraAPI::Controller::Cms;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';

use PhaidraAPI::Model::Cms;

sub get_template {
  my $self = shift;

  my $templateName = $self->stash('templateName');
  my $res = {alerts => [], status => 200};

  my $model = PhaidraAPI::Model::Cms->new;
  my $modelres = $model->get_template($self, $templateName);

  $res->{template} = $modelres;

  $self->render(json => $res, status => $res->{status});
}

1;