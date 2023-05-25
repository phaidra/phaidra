package PhaidraAPI::Controller::Datacite;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Datacite;

sub get {

  my $self = shift;

  my $pid    = $self->stash('pid');
  my $format = $self->param('format');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $model = PhaidraAPI::Model::Datacite->new;

  my $res = $model->get($self, $pid, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
    return;
  }

  if ($format eq 'xml') {
    $self->render(text => $model->json_2_xml($self, $res->{datacite}->{datacite_elements}), format => 'xml');
    return;
  }

  $self->respond_to(

    # json => { json => $res->{datacite} },
    json => {json => $res},
    xml  => {text => $model->json_2_xml($self, $res->{datacite}->{datacite_elements})},

    # any => { json => { metadata => { datacite => $res->{datacite}}}}
    any => {json => $res},
  );

}

1;
