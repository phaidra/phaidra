package PhaidraAPI::Model::Search;

use strict;
use warnings;
use v5.10;
use XML::Parser::PerlSAX;
use XML::XPath;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Fedora;
use base qw/Mojo::Base/;

sub datastream_exists {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;
  my $dsid = shift;

  my $res = {alerts => [], status => 200};

  my $exists       = 0;
  my $fedora_model = PhaidraAPI::Model::Fedora->new;
  my $propres      = $fedora_model->getObjectProperties($c, $pid);
  if ($propres->{status} ne 200) {
    return $propres;
  }
  if (exists($propres->{contains})) {
    for my $contains (@{$propres->{contains}}) {
      if ($contains eq $dsid) {
        $exists = 1;
        last;
      }
    }
  }
  $res->{'exists'} = $exists;

  return $res;
}

sub get_ownerid {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  my $fedora_model = PhaidraAPI::Model::Fedora->new;
  my $r            = $fedora_model->getObjectProperties($c, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }
  $res->{ownerid} = $r->{owner};
  return $res;
}

sub get_last_modified_date {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  my $fedora_model = PhaidraAPI::Model::Fedora->new;
  my $r            = $fedora_model->getObjectProperties($c, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }
  $res->{lastmodifieddate} = $r->{modified};
  return $res;
}

sub get_cmodel {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  my $cmodel;
  my $cachekey = 'cmodel_' . $pid;
  unless ($cmodel = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $r            = $fedora_model->getObjectProperties($c, $pid);
    if ($r->{status} ne 200) {
      return $r;
    }
    $cmodel = $r->{cmodel};
    $c->app->chi->set($cachekey, $cmodel, '1 day');
  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  $res->{cmodel} = $cmodel;
  return $res;
}

sub get_book_for_page {
  my $self    = shift;
  my $c       = shift;
  my $pagepid = shift;

  my $res = {alerts => [], status => 200};

  my $bookpid;
  my $cachekey = 'bookforpage_' . $pagepid;
  unless ($bookpid = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $urlget = Mojo::URL->new;
    $urlget->scheme($c->app->config->{solr}->{scheme});
    $urlget->host($c->app->config->{solr}->{host});
    $urlget->port($c->app->config->{solr}->{port});
    if ($c->app->config->{solr}->{path}) {
      $urlget->path("/" . $c->app->config->{solr}->{path} . "/solr/" . $c->app->config->{solr}->{core} . "/select");
    }
    else {
      $urlget->path("/solr/" . $c->app->config->{solr}->{core} . "/select");
    }
    $urlget->query(q => "*:*", fq => "haspart:\"$pagepid\"", sort => 'created desc', fl => 'pid', rows => "1", wt => "json");
    my $getres = $c->ua->get($urlget)->result;
    if ($getres->is_success) {
      for my $d (@{$getres->json->{response}->{docs}}) {
        $bookpid = $d->{pid};
        last;
      }
    }
    else {
      my $err = "[$pagepid] error getting book pid: " . $getres->code . " " . $getres->message;
      $self->app->log->error($err);
      unshift @{$res->{alerts}}, {type => 'error', msg => $err};
      $res->{status} = $getres->code ? $getres->code : 500;
      return $res;
    }

    $c->app->chi->set($cachekey, $bookpid, '1 day');
  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  $res->{bookpid} = $bookpid;
  return $res;
}

sub get_pids {
  my ($self, $c, $query) = @_;

  my @pids;
  my $res = {alerts => [], status => 200};

  my $ua = Mojo::UserAgent->new;

  my $urlget = Mojo::URL->new;
  $urlget->scheme($c->app->config->{solr}->{scheme});
  $urlget->host($c->app->config->{solr}->{host});
  $urlget->port($c->app->config->{solr}->{port});
  if ($c->app->config->{solr}->{path}) {
    $urlget->path("/" . $c->app->config->{solr}->{path} . "/solr/" . $c->app->config->{solr}->{core} . "/select");
  }
  else {
    $urlget->path("/solr/" . $c->app->config->{solr}->{core} . "/select");
  }

  # get numFound
  $urlget->query(q => $query, fl => "pid", rows => "0", wt => "json");
  my $get = $ua->get($urlget)->result;
  my $numFound;
  if ($get->is_success) {
    $numFound = $get->json->{response}->{numFound};
    $c->app->log->debug("get_pids: found $numFound");
  }
  else {
    $c->app->log->error("error getting count " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting count"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  # get results
  $urlget->query(q => $query, fl => "pid", rows => $numFound, wt => "json");

  # $urlget->query(q => $query, fl => "pid,dc_identifier", rows => $numFound, wt => "json");
  $get = $ua->get($urlget)->result;

  if ($get->is_success) {
    for my $d (@{$get->json->{response}->{docs}}) {

      #			my $ac;
      #			for my $dcid (@{$d->{dc_identifier}}){
      #				if($dcid =~ /^AC/g){
      #					$ac = $dcid;
      #				}
      #			}
      #     push @pids, $d->{pid}.';'.$ac;

      push @pids, $d->{pid};
    }
  }
  else {
    $c->app->log->error("error getting results " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting results"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  $res->{pids} = \@pids;

  return $res;
}

1;
__END__
