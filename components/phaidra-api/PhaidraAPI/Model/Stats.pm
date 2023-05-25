package PhaidraAPI::Model::Stats;

use strict;
use warnings;
use v5.10;
use XML::LibXML;
use base qw/Mojo::Base/;

sub disciplines {
  my $self = shift;
  my $c    = shift;

  my $res = {alerts => [], status => 200};

  my $cachekey = 'stats_disciplines';
  my $cacheval = $c->app->chi->get($cachekey);
  if ($cacheval) {
    $c->app->log->debug("[cache hit] $cachekey");
    $res->{disciplines} = $cacheval;
    return $res;
  }

  $c->app->log->debug("[cache miss] $cachekey");

  my $disciplines;
  for my $path (@{$c->app->static->paths}) {
    open my $fh, "<:encoding(UTF-8)", "$path/statistics/disciplines.csv" or next;
    my $header = <$fh>;
    while (<$fh>) {
      my @arr = split(/"/, $_);
      $c->app->log->debug($c->app->dumper(\@arr));
      my $kw = $arr[1];
      my $ds = $arr[3];
      $ds =~ s/\n+|^\s+|\s+$|"+//g;
      $kw =~ s/\n+|^\s+|\s+$|"+//g;
      my @dss = split(/,/, $ds);
      for my $disc (@dss) {
        $disc =~ s/\n+|^\s+|\s+$|"+//g;
        unless (exists($disciplines->{$disc})) {
          $disciplines->{$disc} = {kws => []};
        }
        push @{$disciplines->{$disc}->{kws}}, $kw;
      }
    }
    close $fh;
  }

  unless (defined($disciplines)) {
    my $msg = "Error reading disciplines";
    $c->app->log->error($msg);
    push @{$res->{alerts}}, {type => 'error', msg => $msg};
    $res->{status} = 500;
    return $res;
  }

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

  for my $ds (keys %{$disciplines}) {
    for my $kw (@{$disciplines->{$ds}->{kws}}) {
      $c->app->log->debug("querying ds[$ds] kw[$kw]");
      $urlget->query(q => '"' . $kw . '"', rows => "0", wt => "json");
      my $get = $c->app->ua->get($urlget)->result;
      my $numFound;
      if ($get->is_success) {
        $numFound = $get->json->{response}->{numFound};
        $disciplines->{$ds}->{count} += $numFound;
      }
    }
  }

  for my $ds (keys %{$disciplines}) {
    $cacheval->{$ds} = $disciplines->{$ds}->{count};
  }

  $c->app->chi->set($cachekey, $cacheval, '1 week');
  $cacheval = $c->app->chi->get($cachekey);
  $res->{disciplines} = $cacheval;
  return $res;
}

sub aggregates {
  my $self       = shift;
  my $c          = shift;
  my $detail     = shift;
  my $time_scale = shift;

  my $res = {alerts => [], status => 200};

  my $cursor = $c->paf_mongo->get_collection('aggregates')->find({'detail' => $detail, 'time_scale' => $time_scale});
  $res->{stats} = [];
  while (my $doc = $cursor->next) {
    push @{$res->{stats}}, $doc;
  }

  return $res;
}

sub stats {
  my $self   = shift;
  my $c      = shift;
  my $pid    = shift;
  my $siteid = shift;
  my $output = shift;

  my $fr = undef;
  if (exists($c->app->config->{sites})) {
    for my $f (@{$c->app->config->{sites}}) {
      if (defined($f->{site}) && $f->{site} eq 'phaidra') {
        $fr = $f;
      }
    }
  }

  unless (defined($fr)) {

    # return 200, this is just ok
    return {alerts => [{type => 'info', msg => 'Site is not configured'}], status => 200};
  }
  unless ($fr->{site} eq 'phaidra') {

    # return 200, this is just ok
    return {alerts => [{type => 'info', msg => 'Site [' . $fr->{site} . '] is not supported'}], status => 200};
  }
  unless (defined($fr->{stats})) {

    # return 200, this is just ok
    return {alerts => [{type => 'info', msg => 'Statistics source is not configured'}], status => 200};
  }

  # only piwik now
  unless ($fr->{stats}->{type} eq 'piwik') {

    # return 200, this is just ok
    return {alerts => [{type => 'info', msg => 'Statistics source [' . $fr->{stats}->{type} . '] is not supported.'}], status => 200};
  }
  unless ($siteid) {
    unless (defined($fr->{stats}->{siteid})) {
      return {alerts => [{type => 'info', msg => 'Piwik siteid is not configured'}], status => 500};
    }
    $siteid = $fr->{stats}->{siteid};
  }

  if ($output eq 'chart') {

    my $downloads;
    my $sth = $c->app->db_stats_phaidra->dbh->prepare("SELECT DATE_FORMAT(server_time,'%Y-%m-%d'), location_country FROM downloads_$siteid WHERE pid = '$pid';")
      or $c->app->log->error("Error querying piwik database for download stats chart:" . $c->app->db_stats_phaidra->dbh->errstr);
    $sth->execute() or $c->app->log->error("Error querying piwik database for download stats chart:" . $c->app->db_stats_phaidra->dbh->errstr);
    my $date;
    my $country;
    $sth->bind_columns(undef, \$date, \$country);
    while ($sth->fetch) {
      if ($downloads->{$country}) {
        $downloads->{$country}->{$date}++;
      }
      else {
        $downloads->{$country} = {$date => 1};
      }
    }

    my $detail_page;
    $sth = $c->app->db_stats_phaidra->dbh->prepare("SELECT DATE_FORMAT(server_time,'%Y-%m-%d'), location_country FROM views_$siteid WHERE pid = '$pid';") or $c->app->log->error("Error querying piwik database for detail stats chart:" . $c->app->db_stats_phaidra->dbh->errstr);
    $sth->execute()                                                                                                                                       or $c->app->log->error("Error querying piwik database for detail stats chart:" . $c->app->db_stats_phaidra->dbh->errstr);
    $sth->bind_columns(undef, \$date, \$country);
    while ($sth->fetch) {
      if ($detail_page->{$country}) {
        $detail_page->{$country}->{$date}++;
      }
      else {
        $detail_page->{$country} = {$date => 1};
      }
    }

    if (defined($detail_page) || defined($downloads)) {
      return {downloads => $downloads, detail_page => $detail_page, alerts => [], status => 200};
    }
    else {
      my $msg = "No data has been fetched. DB msg:" . $c->app->db_stats_phaidra->dbh->errstr;
      $c->app->log->warn($msg);
      return {alerts => [{type => 'info', msg => $msg}], status => 200};
    }
  }
  else {

    my $downloads = $c->app->db_stats_phaidra->dbh->selectrow_array("SELECT count(*) FROM downloads_$siteid WHERE pid = '$pid';");
    unless (defined($downloads)) {
      $c->app->log->error("Error querying piwik database for download stats:" . $c->app->db_stats_phaidra->dbh->errstr);
    }

    my $detail_page = $c->app->db_stats_phaidra->dbh->selectrow_array("SELECT count(*) FROM views_$siteid WHERE pid = '$pid';");
    unless (defined($detail_page)) {
      $c->app->log->error("Error querying piwik database for detail stats:" . $c->app->db_stats_phaidra->dbh->errstr);
    }

    if (defined($detail_page)) {
      return {downloads => $downloads, detail_page => $detail_page, alerts => [], status => 200};
    }
    else {
      my $msg = "No data has been fetched. DB msg:" . $c->app->db_stats_phaidra->dbh->errstr;
      $c->app->log->warn($msg);
      return {alerts => [{type => 'info', msg => $msg}], status => 200};
    }
  }
}

1;
__END__
