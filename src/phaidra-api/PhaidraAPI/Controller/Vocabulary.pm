package PhaidraAPI::Controller::Vocabulary;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Vocabulary;
use Time::HiRes qw/tv_interval gettimeofday/;

sub get_vocabulary {
  my $self = shift;

  my $t0 = [gettimeofday];

  my $uri     = $self->param('uri');
  my $nocache = $self->param('nocache');

  my $vocabulary_model = PhaidraAPI::Model::Vocabulary->new;

  my $res = $vocabulary_model->get_vocabulary($self, $uri, $nocache);
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, $res->{status});
    return;
  }

  my $t1 = tv_interval($t0);
  $self->stash(msg => "backend load took $t1 s");

  $self->render(json => {vocabulary => $res->{vocabulary}, alerts => $res->{alerts}}, status => $res->{status});
}

1;
