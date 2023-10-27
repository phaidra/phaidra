package PhaidraAPI::Model::Octets;

use strict;
use warnings;
use v5.10;
use XML::LibXML;
use base qw/Mojo::Base/;

sub _get_ds_path() {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;
  my $ds   = shift;

  my $res = {alerts => [], status => 200};

  my $ss  = "SELECT token, path FROM datastreamPaths WHERE token like '$pid+$ds%';";
  my $sth = $c->app->db_fedora->dbh->prepare($ss);
  unless ($sth) {
    my $msg = $c->app->db_fedora->dbh->errstr;
    $c->app->log->error($msg);
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => $msg};
    return $res;
  }
  my $ex = $sth->execute();
  unless ($ex) {
    my $msg = $c->app->db_fedora->dbh->errstr;
    $c->app->log->error($msg);
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => $msg};
    return $res;
  }

  my $token;    # o:9+OCTETS+OCTETS.0
  my $path;     # /usr/local/fedora/data/datastreams/2018/0201/15/07/o_9+OCTETS+OCTETS.0
  my $latestVersion = -1;
  my $latestPath;
  $sth->bind_columns(undef, \$token, \$path);
  while ($sth->fetch) {
    $token =~ /$ds\.(\d+)/;
    if ($1 gt $latestVersion) {
      $latestVersion = $1;
      $latestPath    = $path;
    }
  }

  if ($latestPath) {
    $res->{path} = $latestPath;
  }
  else {
    $res->{status} = 404;
    unshift @{$res->{alerts}}, {type => 'error', msg => $ds . ' datastream path not found'};
  }

  return $res;
}

sub _get_ds_attributes {
  my $self     = shift;
  my $c        = shift;
  my $pid      = shift;
  my $ds       = shift;
  my $foxmldom = shift;

  my $res = {alerts => [], status => 200};

  for my $e ($foxmldom->find('foxml\:datastream[ID="' . $ds . '"]')->each) {
    my $latestVersion = $e->find('foxml\:datastreamVersion')->first;
    for my $e1 ($e->find('foxml\:datastreamVersion')->each) {
      if ($e1->attr('CREATED') gt $latestVersion->attr('CREATED')) {
        $latestVersion = $e1;
      }
    }
    return ($latestVersion->attr('LABEL'), $latestVersion->attr('MIMETYPE'), $latestVersion->attr('SIZE'));
  }

  $c->app->log->error("pid[$pid] could not determine filename, mimetype and size of $ds");
  return ($pid, 'application/octet-stream', undef);
}

1;
__END__
