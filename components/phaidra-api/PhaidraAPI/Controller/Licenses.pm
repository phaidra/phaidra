package PhaidraAPI::Controller::Licenses;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Licenses;
use Time::HiRes qw/tv_interval gettimeofday/;

sub get_licenses {
  my $self = shift;

  my $t0 = [gettimeofday];

  my $nocache = $self->param('nocache');

  my $licenses_model = PhaidraAPI::Model::Licenses->new;

  my $res = $licenses_model->get_licenses($self, $nocache);
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, $res->{status});
    return;
  }

  my $t1 = tv_interval($t0);
  $self->stash(msg => "backend load took $t1 s");

  $self->render(json => {licenses => $res->{licenses}, alerts => $res->{alerts}}, status => $res->{status});
}

1;
