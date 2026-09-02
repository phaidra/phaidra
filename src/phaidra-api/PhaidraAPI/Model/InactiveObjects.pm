package PhaidraAPI::Model::InactiveObjects;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Fedora;
use PhaidraAPI::Model::Jsonld;

sub list {
  my ($self, $c, $opts) = @_;
  $opts //= {};

  my $res = {alerts => [], status => 200, objects => [], total => 0};

  my $page = int($opts->{page} // 1);
  $page = 1 if $page < 1;

  my $limit = int($opts->{limit} // 10);
  $limit = 10  if $limit < 1;
  $limit = 100 if $limit > 100;

  my $offset = ($page - 1) * $limit;

  my %sortable = map {$_ => 1} qw(pid title owner cmodel source status created updated);
  my $sort     = $opts->{sort} // 'created';
  $sort = 'created' unless $sortable{$sort};
  my $order = lc($opts->{order} // 'desc');
  $order = 'desc' unless $order eq 'asc';

  my @where;
  my @bind;

  if (defined $opts->{owner} && $opts->{owner} ne '') {
    push @where, 'owner = ?';
    push @bind,  $opts->{owner};
  }
  if (defined $opts->{owner_or_approval} && $opts->{owner_or_approval} ne '') {
    push @where, '(status = ? OR owner = ?)';
    push @bind,  'approval', $opts->{owner_or_approval};
  }
  if (defined $opts->{status} && $opts->{status} ne '') {
    push @where, 'status = ?';
    push @bind,  $opts->{status};
  }

  my $q = $opts->{q} // '';
  $q =~ s/^\s+|\s+$//g;
  if ($q ne '') {
    $q =~ s/[%_]//g;
    if ($q ne '') {
      my $like = '%' . $q . '%';
      push @where, '(pid LIKE ? OR IFNULL(title, \'\') LIKE ? OR owner LIKE ? OR IFNULL(cmodel, \'\') LIKE ? OR source LIKE ? OR status LIKE ?)';
      push @bind, ($like) x 6;
    }
  }

  my $where_sql = @where ? ('WHERE ' . join(' AND ', @where)) : '';
  my $dbh       = $c->app->db_metadata->dbh;

  my $count_sth = $dbh->prepare("SELECT COUNT(*) FROM inactive_objects $where_sql");
  unless ($count_sth) {
    $c->app->log->error($dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  unless ($count_sth->execute(@bind)) {
    $c->app->log->error($dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  ($res->{total}) = $count_sth->fetchrow_array;
  $res->{total} //= 0;
  $count_sth->finish();

  my $ss = qq{
    SELECT pid, owner, title, cmodel, source, status, created, updated
    FROM inactive_objects
    $where_sql
    ORDER BY $sort $order
    LIMIT ? OFFSET ?
  };
  my $sth = $dbh->prepare($ss);
  unless ($sth) {
    $c->app->log->error($dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  unless ($sth->execute(@bind, $limit, $offset)) {
    $c->app->log->error($dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }

  while (my $row = $sth->fetchrow_hashref) {
    push @{$res->{objects}}, $row;
  }
  $sth->finish();

  $res->{page}  = $page;
  $res->{limit} = $limit;
  return $res;
}

sub get_by_pid {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  unless ($pid && $pid =~ m/^o:\d+$/) {
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Invalid pid'};
    $res->{status} = 400;
    return $res;
  }

  my $ss  = q{SELECT pid, owner, title, cmodel, source, status, created, updated FROM inactive_objects WHERE pid = ?};
  my $sth = $c->app->db_metadata->dbh->prepare($ss);
  unless ($sth) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  unless ($sth->execute($pid)) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  my $row = $sth->fetchrow_hashref;
  $sth->finish();

  unless ($row) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Inactive object pid[$pid] not found"};
    $res->{status} = 404;
    return $res;
  }

  $res->{object} = $row;
  return $res;
}

sub register_from_pid {
  my ($self, $c, $pid, $source, $status) = @_;

  my $res = {alerts => [], status => 200};

  unless ($pid) {
    unshift @{$res->{alerts}}, {type => 'error', msg => 'No PID provided'};
    $res->{status} = 400;
    return $res;
  }
  unless ($pid =~ m/^o:\d+$/) {
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Invalid pid'};
    $res->{status} = 400;
    return $res;
  }

  $source = 'manual'   unless defined $source && $source ne '';
  $status = 'inactive' unless defined $status && $status ne '';

  my $fedora_model = PhaidraAPI::Model::Fedora->new;
  my $props        = $fedora_model->getObjectProperties($c, $pid);
  if ($props->{status} ne 200) {
    return $props;
  }

  my $owner  = $props->{owner};
  my $cmodel = $props->{cmodel};
  my $state  = $props->{state} // '';

  unless ($owner) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Could not determine owner for pid[$pid]"};
    $res->{status} = 400;
    return $res;
  }

  if ($state ne '' && $state ne 'Inactive' && $state ne 'I') {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Object pid[$pid] is not Inactive (state=$state)"};
    $res->{status} = 400;
    return $res;
  }

  my $title = $self->_title_from_jsonld($c, $pid);

  my $created_iso = $props->{created};
  my $created_sql = $self->_iso_to_mysql_datetime($created_iso);

  my $ss = q{
    INSERT INTO inactive_objects (pid, owner, title, cmodel, source, status, created)
    VALUES (?, ?, ?, ?, ?, ?, COALESCE(?, CURRENT_TIMESTAMP))
    ON DUPLICATE KEY UPDATE
      owner  = VALUES(owner),
      title  = VALUES(title),
      cmodel = VALUES(cmodel),
      source = VALUES(source),
      status = VALUES(status),
      updated = CURRENT_TIMESTAMP
  };
  my $sth = $c->app->db_metadata->dbh->prepare($ss);
  unless ($sth) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  unless ($sth->execute($pid, $owner, $title, $cmodel, $source, $status, $created_sql)) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  $sth->finish();

  $res->{object} = {
    pid    => $pid,
    owner  => $owner,
    title  => $title,
    cmodel => $cmodel,
    source => $source,
    status => $status,
  };
  $c->app->log->info("Registered inactive object pid[$pid] owner[$owner] source[$source]");

  return $res;
}

sub remove {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  unless ($pid) {
    unshift @{$res->{alerts}}, {type => 'error', msg => 'No PID provided'};
    $res->{status} = 400;
    return $res;
  }
  unless ($pid =~ m/^o:\d+$/) {
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Invalid pid'};
    $res->{status} = 400;
    return $res;
  }

  my $ss  = q{DELETE FROM inactive_objects WHERE pid = ?};
  my $sth = $c->app->db_metadata->dbh->prepare($ss);
  unless ($sth) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  unless ($sth->execute($pid)) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Database error'};
    $res->{status} = 500;
    return $res;
  }
  $sth->finish();

  return $res;
}

# Refresh cached title after metadata edit (row may not exist — no-op).
sub refresh_title {
  my ($self, $c, $pid) = @_;

  return unless $pid && $pid =~ m/^o:\d+$/;

  my $exists = $self->get_by_pid($c, $pid);
  return unless $exists->{status} eq 200;

  my $title = $self->_title_from_jsonld($c, $pid);
  my $ss    = q{UPDATE inactive_objects SET title = ?, updated = CURRENT_TIMESTAMP WHERE pid = ?};
  my $sth   = $c->app->db_metadata->dbh->prepare($ss);
  unless ($sth) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    return;
  }
  unless ($sth->execute($title, $pid)) {
    $c->app->log->error($c->app->db_metadata->dbh->errstr);
    return;
  }
  $sth->finish();
  return;
}

sub _title_from_jsonld {
  my ($self, $c, $pid) = @_;

  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $r            = $jsonld_model->get_object_jsonld_parsed($c, $pid);
  if ($r->{status} ne 200) {
    $c->app->log->debug("inactive_objects: no JSON-LD for pid[$pid]: status=" . $r->{status});
    return undef;
  }

  my $jsonld = $r->{'JSON-LD'};
  return undef unless $jsonld && ref($jsonld) eq 'HASH';

  my $titles = $jsonld->{'dce:title'};
  return undef unless $titles && ref($titles) eq 'ARRAY';

  my $fallback;
  for my $o (@{$titles}) {
    next unless ref($o) eq 'HASH';
    my $type = $o->{'@type'} // '';
    next unless $o->{'bf:mainTitle'} && ref($o->{'bf:mainTitle'}) eq 'ARRAY';
    for my $mt (@{$o->{'bf:mainTitle'}}) {
      next unless ref($mt) eq 'HASH' && defined $mt->{'@value'} && $mt->{'@value'} ne '';
      if ($type eq 'bf:Title') {
        return $mt->{'@value'};
      }
      $fallback //= $mt->{'@value'};
    }
  }
  return $fallback;
}

sub _iso_to_mysql_datetime {
  my ($self, $iso) = @_;
  return undef unless defined $iso && $iso ne '';

  # e.g. 2024-01-15T12:34:56.789Z or 2024-01-15T12:34:56+00:00
  if ($iso =~ /^(\d{4}-\d{2}-\d{2})[T ](\d{2}:\d{2}:\d{2})/) {
    return "$1 $2";
  }
  return undef;
}

1;
__END__
