package PhaidraAPI::Controller::Dc;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Mappings::Export::Dublincore;

sub get {
  my ($self) = @_;

  my $pid          = $self->stash('pid');
  my $ignorestatus = $self->param('ignorestatus');

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($self, $pid, $ignorestatus);

  if ($r->{status} ne 200) {
    $self->render(json => $r, status => $r->{status});
    return;
  }

  my $dc_model = PhaidraAPI::Model::Mappings::Export::Dublincore->new;
  $self->stash(metadata => $dc_model->get_metadata($self, $r->{index}, ''));
  $self->render(template => 'oai/oai_dc', format => 'xml', handler => 'ep');
}

1;
