package PhaidraAPI::Controller::Search;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Search;

sub triples {
  my $self = shift;

  my $query = $self->param('q');
  my $limit = $self->param('limit');

  my $search_model = PhaidraAPI::Model::Search->new;
  my $sr           = $search_model->triples($self, $query, $limit);

  $self->render(json => $sr, status => $sr->{status});
}

sub id {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $sr           = $search_model->triples($self, "<info:fedora/" . $self->stash('pid') . "> <http://purl.org/dc/terms/identifier> *", 0);

  $res->{alerts} = $sr->{alerts};
  $res->{status} = $sr->{status};

  my @ids;
  for my $triple (@{$sr->{result}}) {
    my $id = @$triple[2];
    $id =~ s/^\<+|\>+$//g;
    push @ids, $id;
  }

  $res->{ids} = \@ids;

  $self->render(json => $res, status => $res->{status});
}

sub related {

  my $self = shift;
  my $relation;
  my $from  = 1;
  my $limit = 10;
  my $right = 0;
  my @fields;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  if (defined($self->param('relation'))) {
    $relation = $self->param('relation');
  }
  else {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined relation'}]}, status => 400);
    return;
  }

  if (defined($self->param('from'))) {
    $from = $self->param('from');
  }

  if (defined($self->param('limit'))) {
    $limit = $self->param('limit');
  }

  if (defined($self->param('right'))) {
    $right = $self->param('right');
  }

  if (defined($self->param('fields'))) {
    @fields = $self->every_param('fields');
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $r;
  
  if (@fields) {
    $r = $search_model->related($self, $self->stash('pid'), $relation, $right, $from, $limit, @fields);
  }
  else {
    $r = $search_model->related($self, $self->stash('pid'), $relation, $right, $from, $limit, undef);
  }

  #$self->app->log->debug($self->app->dumper($r));
  $self->render(json => $r, status => $r->{status});

}

sub get_pids {
  my $self = shift;

  unless (defined($self->param('q'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined query'}]}, status => 400);
    return;
  }

  my $query = $self->param('q');

  my $search_model = PhaidraAPI::Model::Search->new;
  my $sr           = $search_model->get_pids($self, $query);
  if ($sr->{status} ne 200) {
    $self->render(json => $sr, status => $sr->{status});
  }

  $self->render(json => {pids => $sr->{pids}}, status => $sr->{status});
}

sub search_solr {
  my $self = shift;

  my $url = Mojo::URL->new;

  $url->scheme($self->app->config->{solr}->{scheme});
  $url->host($self->app->config->{solr}->{host});
  $url->port($self->app->config->{solr}->{port});
  my $core = $self->app->config->{solr}->{core};
  if ($self->app->config->{solr}->{path}) {
    $url->path("/" . $self->app->config->{solr}->{path} . "/solr/$core/select");
  }
  else {
    $url->path("/solr/$core/select");
  }

  $self->app->log->info("proxying solr request");
  $self->app->log->info($url);
  $self->app->log->info($self->app->dumper($self->req->params->to_hash));

  if (Mojo::IOLoop->is_running) {
    $self->render_later;
    $self->ua->post(
      $url => form => $self->req->params->to_hash,
      sub {
        my ($c, $tx) = @_;
        _proxy_tx($self, $tx);
      }
    );
  }
  else {
    my $tx = $self->ua->post($url => form => $self->req->params->to_hash);
    _proxy_tx($self, $tx);
  }

}


sub _proxy_tx {
 my ($self, $tx) = @_;
  if (!$tx->error) {
    my $res = $tx->res;
    $self->tx->res($res);
    $self->rendered;
  }
  else {
    my $error = $tx->error;
    $self->tx->res->headers->add('X-Remote-Status',
      $error->{code} . ': ' . $error->{message});
    $self->render(status => 500, text => 'Failed to fetch data from backend');
  }
}

1;
