package PhaidraAPI::Controller::Techinfo;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Object;

sub get {
  my $self = shift;

  my $pid    = $self->stash('pid');
  my $format = $self->param('format');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  if ($format ne 'xml') {
    $self->render(json => {alerts => [{type => 'error', msg => "Only xml format is supported. Please send the request with the format=xml parameter."}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  $object_model->proxy_datastream($self, $pid, 'TECHINFO', undef, undef, 1);
}

1;
