package PhaidraAPI::Controller::Search;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Search::GSearchSAXHandler;
use Mojo::IOLoop::Delay;

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

  $self->render_later;
  my $delay = Mojo::IOLoop->delay(

    sub {
      my $delay = shift;
      if (@fields) {
        $search_model->related($self, $self->stash('pid'), $relation, $right, $from, $limit, @fields, $delay->begin);
      }
      else {
        $search_model->related($self, $self->stash('pid'), $relation, $right, $from, $limit, undef, $delay->begin);
      }
    },

    sub {
      my ($delay, $r) = @_;

      #$self->app->log->debug($self->app->dumper($r));
      $self->render(json => $r, status => $r->{status});
    }

  );
  $delay->wait unless $delay->ioloop->is_running;

}

sub search {
  my $self    = shift;
  my $from    = 1;
  my $limit   = 10;
  my $sort    = 'uw.general.title,SCORE';
  my $reverse = '0';
  my $query;
  my @fields;

  if (defined($self->param('q'))) {
    $query = $self->param('q');
  }
  unless (defined($query)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined query'}]}, status => 400);
    return;
  }

  if (defined($self->param('from'))) {
    $from = $self->param('from');
  }

  if (defined($self->param('limit'))) {
    $limit = $self->param('limit');
  }

  if (defined($self->param('sort'))) {
    $sort = $self->param('sort');
  }

  if (defined($self->param('reverse'))) {
    $reverse = $self->param('reverse');
  }

  if (defined($self->param('fields'))) {
    @fields = $self->every_param('fields');
  }

  my $search_model = PhaidraAPI::Model::Search->new;

  $query = $search_model->build_query($self, $query);

  $self->render_later;
  my $delay = Mojo::IOLoop->delay(

    sub {
      my $delay = shift;
      if (@fields) {
        $search_model->search($self, $query, $from, $limit, $sort, $reverse, @fields, $delay->begin);
      }
      else {
        $search_model->search($self, $query, $from, $limit, $sort, $reverse, undef, $delay->begin);
      }
    },

    sub {
      my ($delay, $r) = @_;

      #$self->app->log->debug($self->app->dumper($r));
      $self->render(json => $r, status => $r->{status});
    }

  );
  $delay->wait unless $delay->ioloop->is_running;

}

sub search_lucene {
  my $self    = shift;
  my $from    = 1;
  my $limit   = 10;
  my $sort    = 'uw.general.title,SCORE';
  my $reverse = '0';
  my $query;
  my @fields;

  if (defined($self->param('q'))) {
    $query = $self->param('q');
  }
  unless (defined($query)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined query'}]}, status => 400);
    return;
  }

  if (defined($self->param('from'))) {
    $from = $self->param('from');
  }

  if (defined($self->param('limit'))) {
    $limit = $self->param('limit');
  }

  if (defined($self->param('sort'))) {
    $sort = $self->param('sort');
  }

  if (defined($self->param('reverse'))) {
    $reverse = $self->param('reverse');
  }

  if (defined($self->param('fields'))) {
    @fields = $self->every_param('fields');
  }

  my $search_model = PhaidraAPI::Model::Search->new;

  $self->render_later;
  my $delay = Mojo::IOLoop->delay(

    sub {
      my ($delay, $r) = @_;

      # start async
      if (@fields) {
        $search_model->search($self, $query, $from, $limit, $sort, $reverse, @fields, $delay->begin);
      }
      else {
        $search_model->search($self, $query, $from, $limit, $sort, $reverse, undef, $delay->begin);
      }
    },

    sub {
      my ($delay, $r) = @_;

      # resturn result
      $self->render(json => $r, status => $r->{status});
    }

  );
  $delay->wait unless $delay->ioloop->is_running;

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

sub my_objects {
  my $self = shift;
  $self->stash->{'username'} = $self->stash->{basic_auth_credentials}->{username};
  $self->owner();
}

sub owner {
  my $self = shift;
  my $q;
  my $from    = 1;
  my $limit   = 10;
  my $sort    = 'fgs.lastModifiedDate,STRING';
  my $reverse = '0';
  my @fields;

  unless (defined($self->stash('username'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined username'}]}, status => 400);
    return;
  }

  my $search_model = PhaidraAPI::Model::Search->new;

  my $query = "fgs.ownerId:" . $self->stash('username') . ' AND NOT fgs.contentModel:"cmodel:Page"';
  if (defined($self->param('q'))) {
    if ($self->param('q') ne '') {
      $query .= " AND " . $search_model->build_query($self, $self->param('q'));
    }
  }

  if (defined($self->param('from'))) {
    $from = $self->param('from');
  }

  if (defined($self->param('limit'))) {
    $limit = $self->param('limit');
  }

  if (defined($self->param('sort'))) {
    $sort = $self->param('sort');
  }

  if (defined($self->param('reverse'))) {
    $reverse = $self->param('reverse');
  }

  if (defined($self->param('fields'))) {
    @fields = $self->every_param('fields');
  }

  $self->render_later;
  my $delay = Mojo::IOLoop->delay(

    sub {
      my $delay = shift;
      if (@fields) {
        $search_model->search($self, $query, $from, $limit, $sort, $reverse, @fields, $delay->begin);
      }
      else {
        $search_model->search($self, $query, $from, $limit, $sort, $reverse, undef, $delay->begin);
      }
    },

    sub {
      my ($delay, $r) = @_;

      #$self->app->log->debug($self->app->dumper($r));
      $self->render(json => $r, status => $r->{status});
    }

  );
  $delay->wait unless $delay->ioloop->is_running;

}

sub collections_owner {
  my $self  = shift;
  my $from  = 1;
  my $limit = 10;

  unless (defined($self->stash('username'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined username'}]}, status => 400);
    return;
  }

  if (defined($self->param('from'))) {
    $from = $self->param('from');
  }

  if (defined($self->param('limit'))) {
    $limit = $self->param('limit');
  }

  my $search_model = PhaidraAPI::Model::Search->new;

  my $query = "fgs.ownerId:" . $self->stash('username') . ' AND fgs.contentModel:"cmodel:Collection" AND NOT fgs.contentModel:"cmodel:Page"';

  $self->render_later;
  my $delay = Mojo::IOLoop->delay(

    sub {
      my $delay = shift;
      $search_model->search($self, $query, $from, $limit, undef, undef, undef, $delay->begin);
    },

    sub {
      my ($delay, $r) = @_;

      #$self->app->log->debug($self->app->dumper($r));
      $self->render(json => $r, status => $r->{status});
    }

  );
  $delay->wait unless $delay->ioloop->is_running;

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
