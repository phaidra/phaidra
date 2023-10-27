package PhaidraAPI::Controller::Inventory;

use strict;
use warnings;
use v5.10;
use Data::UUID;
use Mojo::JSON qw(encode_json decode_json);
use Mojo::ByteStream qw(b);
use PhaidraAPI::Model::Authorization;
use base 'Mojolicious::Controller';

sub get_md5 {
  my $self = shift;

  my $pid  = $self->stash('pid');
  my $pido = $pid =~ s/\:/_/r;

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $res         = $authz_model->check_rights($self, $pid, 'ro');
  unless ($res->{status} eq '200') {
    $self->render(json => $res->{json}, status => $res->{status});
    return;
  }
  my $cursor = $self->paf_mongo->get_collection('octets.catalog')->find({'path' => qr/$pido\+/}, {path => 1, md5 => 1});
  my @md5;
  while (my $doc = $cursor->next) {
    push @md5, $doc;
  }

  $self->render(json => {alerts => [], md5 => \@md5}, status => 200);
}

1;
