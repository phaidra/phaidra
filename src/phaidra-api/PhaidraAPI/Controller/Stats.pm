package PhaidraAPI::Controller::Stats;

use strict;
use warnings;
use v5.10;
use PhaidraAPI::Model::Stats;
use base 'Mojolicious::Controller';

sub disciplines {
  my $self = shift;

  my $stats_model = PhaidraAPI::Model::Stats->new;
  my $res         = $stats_model->disciplines($self);

  $self->render(json => $res, status => $res->{status});
}

sub aggregates {
  my $self = shift;

  my $detail     = $self->param('detail');
  my $time_scale = $self->param('time_scale');

  $detail     = 'cm'   unless defined($detail);
  $time_scale = 'year' unless defined($time_scale);

  unless ($detail =~ m/^[a-z]+$/g) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Invalid detail'}]}, status => 400);
    return;
  }
  unless ($time_scale =~ m/^[a-z]+$/g) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Invalid time_scale'}]}, status => 400);
    return;
  }

  my $stats_model = PhaidraAPI::Model::Stats->new;
  my $res         = $stats_model->aggregates($self, $detail, $time_scale);

  $self->render(json => $res, status => $res->{status});
}

sub stats {
  my $self = shift;

  my $pid    = $self->stash('pid');
  my $siteid = $self->param('siteid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  unless ($pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Invalid pid'}]}, status => 400);
    return;
  }
  if (defined($siteid)) {
    unless ($siteid =~ m/^\d+$/) {
      $self->render(json => {alerts => [{type => 'info', msg => 'Invalid siteid'}]}, status => 400);
      return;
    }
  }

  my $key = $self->stash('stats_param_key');

  my $stats_model = PhaidraAPI::Model::Stats->new;
  my $res         = $stats_model->stats($self, $pid, $siteid, 'stats');

  if (defined($key)) {
    $self->render(text => $res->{$key}, status => $res->{status});
  }
  else {
    $self->render(json => {stats => {detail_page => $res->{detail_page}, downloads => $res->{downloads}}, alerts => $res->{alerts}, status => $res->{status}}, status => $res->{status});
  }
}

sub chart {
  my $self = shift;

  my $pid    = $self->stash('pid');
  my $siteid = $self->param('siteid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  unless ($pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Invalid pid'}]}, status => 400);
    return;
  }
  if (defined($siteid)) {
    unless ($siteid =~ m/^\d+$/) {
      $self->render(json => {alerts => [{type => 'info', msg => 'Invalid siteid'}]}, status => 400);
      return;
    }
  }

  my $key = $self->stash('stats_param_key');

  my $stats_model = PhaidraAPI::Model::Stats->new;
  my $res         = $stats_model->stats($self, $pid, $siteid, 'chart');

  if (defined($key)) {
    $self->render(text => $res->{$key}, status => $res->{status});
  }
  else {
    $self->render(json => {stats => {detail_page => $res->{detail_page}, downloads => $res->{downloads}}, alerts => $res->{alerts}, status => $res->{status}}, status => $res->{status});
  }
}

1;
