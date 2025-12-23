package PhaidraAPI::Model::Stats;

use strict;
use warnings;
use v5.10;
use XML::LibXML;
use base qw/Mojo::Base/;

sub stats_general {
  my $self = shift;
  my $c    = shift;

  my $res = {alerts => [], status => 200};

  my $cachekey = 'stats_object_counts';
  my $cacheval = $c->app->chi->get($cachekey);
  if ($cacheval) {
    $c->app->log->debug("[cache hit] $cachekey");
    $res->{object_counts} = $cacheval;
    return $res;
  }

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
  $urlget->query(q => '*:*', rows => "0", fq => 'owner:* AND -hassuccessor:* AND -ismemberof:["" TO *]', wt => "json");
  my $get = $c->app->ua->get($urlget)->result;
  if ($get->is_success) {
    $res->{object_counts} = $get->json->{response}->{numFound};
  }
  else {
    $c->app->log->error("Error getting object counts from solr: " . $get->message);
    $res->{status} = 500;
  }

  $c->app->chi->set($cachekey, $res->{object_counts}, '1 day');
  $cacheval = $c->app->chi->get($cachekey);
  $res->{object_counts} = $cacheval;
  return $res;
  
}

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

sub parse_pid_num {
  my ($pid) = @_;
  my ($n) = ($pid // '') =~ /^o:(\d+)$/;
  return defined $n ? int($n) : 0;
}

sub stats {
  my $self   = shift;
  my $c      = shift;
  my $pid    = shift;
  my $siteid = shift;
  my $output = shift;

  my $fr = undef;
  my $pid_num = parse_pid_num($pid);

  my $dbh = $c->app->db_metadata->dbh;

  if ($output eq 'chart') {

    my $sql = q{
      SELECT
        DATE_FORMAT(created, '%Y-%m-%d') AS day,
        COALESCE(country, 'xx')          AS country,
        COUNT(*)                         AS cnt
      FROM usage_log
      WHERE action = 'download'
        AND pid_num = ?
      GROUP BY day, country
      ORDER BY day, country
    };

    my $sth = $dbh->prepare($sql) or $c->app->log->error($dbh->errstr);
    $sth->execute($pid_num) or $c->app->log->error($dbh->errstr);

    my $downloads = {};
    while (my $row = $sth->fetchrow_hashref) {
      my ($day, $country, $cnt) = @$row{qw/day country cnt/};
      $downloads->{$country}{$day} = $cnt;
    }

    $sql = q{
      SELECT
        DATE_FORMAT(created, '%Y-%m-%d') AS day,
        COALESCE(country, 'xx')          AS country,
        COUNT(*)                         AS cnt
      FROM usage_log
      WHERE action = 'info'
        AND pid_num = ?
      GROUP BY day, country
      ORDER BY day, country
    };

    $sth = $dbh->prepare($sql) or $c->app->log->error($dbh->errstr);
    $sth->execute($pid_num) or $c->app->log->error($dbh->errstr);

    my $detail_page = {};
    while (my $row = $sth->fetchrow_hashref) {
      my ($day, $country, $cnt) = @$row{qw/day country cnt/};
      $detail_page->{$country}{$day} = $cnt;
    }

    if (defined($detail_page) || defined($downloads)) {
      return {downloads => $downloads, detail_page => $detail_page, alerts => [], status => 200};
    }
    else {
      my $msg = "No data has been fetched. DB msg:" . $c->app->db_metadata->dbh->errstr;
      $c->app->log->warn($msg);
      return {alerts => [{type => 'info', msg => $msg}], status => 200};
    }
  }
  else {

    my ($detail_page, $download) = $dbh->selectrow_array("SELECT `info`, `download` FROM usage_statistics WHERE pid_num = $pid_num");

    if (defined($detail_page) || defined($download)) {
      return {downloads => $download, detail_page => $detail_page, alerts => [], status => 200};
    }
    else {
      my $msg = "No data has been fetched. DB msg:" . $c->app->db_metadata->dbh->errstr;
      $c->app->log->warn($msg);
      return {alerts => [{type => 'info', msg => $msg}], status => 200};
    }
  }
  
}

1;
__END__
