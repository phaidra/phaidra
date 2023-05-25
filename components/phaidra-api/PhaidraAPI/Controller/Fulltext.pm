package PhaidraAPI::Controller::Fulltext;

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
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}], status => 404}, status => 404);
    return;
  }

  if ($format ne 'txt') {
    $self->render(json => {alerts => [{type => 'error', msg => "Only txt format is supported. Please send the request with the format=txt parameter."}], status => 400}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  $object_model->proxy_datastream($self, $pid, 'FULLTEXT', $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
}

1;
