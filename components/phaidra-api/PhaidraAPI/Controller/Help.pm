package PhaidraAPI::Controller::Help;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';

sub tooltip {
  my $self = shift;

  my $id = $self->param('id');

  $self->render(json => {content => $self->l($id)});
}

1;
