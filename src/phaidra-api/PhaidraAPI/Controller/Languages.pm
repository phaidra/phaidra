package PhaidraAPI::Controller::Languages;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Languages;
use Time::HiRes qw/tv_interval gettimeofday/;

sub get_languages {
  my $self = shift;

  my $t0 = [gettimeofday];

  my $nocache = $self->param('nocache');

  my $languages_model = PhaidraAPI::Model::Languages->new;

  my $res = $languages_model->get_languages($self, $nocache);
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, $res->{status});
    return;
  }

  my $t1 = tv_interval($t0);
  $self->stash(msg => "backend load took $t1 s");

  $self->render(json => {languages => $res->{languages}, alerts => $res->{alerts}}, status => $res->{status});
}

1;
