package PhaidraAPI::Model::Termsofuse;

use strict;
use warnings;
use v5.10;
use base             qw/Mojo::Base/;
use Mojo::ByteStream qw(b);
use Mojo::JSON       qw(encode_json decode_json);
use Mojo::File;

sub list {
  my $self = shift;
  my $c    = shift;

  my $res = {alerts => [], status => 200, terms => []};

  my $ss  = "SELECT TID, version, isocode, terms, added FROM terms_of_use ORDER BY version DESC, isocode ASC;";
  my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  unless ($sth->execute()) {
    my $msg = $c->app->db_metadata->dbh->errstr;
    $c->app->log->error($msg);
    push @{$res->{alerts}}, {type => 'error', msg => $msg};
    $res->{status} = 500;
    return $res;
  }
  my ($tid, $version, $isocode, $terms, $added);
  $sth->bind_columns(undef, \$tid, \$version, \$isocode, \$terms, \$added) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  while ($sth->fetch()) {
    push @{$res->{terms}}, {tid => $tid, version => $version, isocode => $isocode, terms => $terms, added => $added};
  }
  $sth->finish();

  return $res;
}

sub create {
  my $self = shift;
  my $c    = shift;
  my $data = shift;

  my $res = {alerts => [], status => 201, terms => []};

  my @entries;
  if ($data->{entries} && ref($data->{entries}) eq 'ARRAY') {
    @entries = @{$data->{entries}};
  }
  elsif ($data->{isocode} || $data->{terms}) {
    push @entries, {isocode => $data->{isocode}, terms => $data->{terms}};
  }

  unless (scalar @entries) {
    my $errmsg = 'At least one terms entry is required';
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 400;
    return $res;
  }

  for my $entry (@entries) {
    my $isocode = $entry->{isocode};
    unless ($isocode && length($isocode) == 2) {
      my $errmsg = 'Invalid language code';
      $c->app->log->error($errmsg);
      push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
      $res->{status} = 400;
      return $res;
    }
    unless ($entry->{terms}) {
      my $errmsg = 'Terms text is required';
      $c->app->log->error($errmsg);
      push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
      $res->{status} = 400;
      return $res;
    }
  }

  my $version;
  if ($data->{version}) {
    $version = $data->{version};
    my $ss  = "SELECT version FROM terms_of_use WHERE version = '$version';";
    my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    my $versionexists;
    $sth->bind_columns(undef, \$versionexists) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->fetch();
    $sth->finish();
    unless ($versionexists) {
      my $errmsg = 'Unknown version provided';
      $c->app->log->error($errmsg);
      push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
      $res->{status} = 400;
      return $res;
    }

    for my $entry (@entries) {
      my $isocode = $entry->{isocode};
      $ss  = "SELECT isocode FROM terms_of_use WHERE version = '$version' AND isocode = '$isocode';";
      $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      my $isocodeexists;
      $sth->bind_columns(undef, \$isocodeexists) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      $sth->fetch();
      $sth->finish();
      if ($isocodeexists) {
        my $errmsg = "Language $isocode already exists for version $version";
        $c->app->log->error($errmsg);
        push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
        $res->{status} = 400;
        return $res;
      }
    }
  }
  else {
    my $ss  = "SELECT version FROM terms_of_use ORDER BY version DESC;";
    my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    my $latestversion;
    $sth->bind_columns(undef, \$latestversion) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->fetch();
    $sth->finish();
    if ($latestversion) {
      $version = $latestversion + 1;
    }
    else {
      $version = 1;
    }
  }

  my @now = localtime();
  my $now = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $now[5] + 1900, $now[4] + 1, $now[3], $now[2], $now[1], $now[0]);

  for my $entry (@entries) {
    my $isocode = $entry->{isocode};
    my $terms   = $entry->{terms};

    my $ss  = "SELECT TID FROM terms_of_use ORDER BY TID DESC;";
    my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    my $latesttid;
    $sth->bind_columns(undef, \$latesttid) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->fetch();
    $sth->finish();
    my $tid;
    if ($latesttid) {
      $tid = $latesttid + 1;
    }
    else {
      $tid = 1;
    }

    $ss  = "INSERT INTO terms_of_use (TID, added, version, terms, isocode) VALUES (?, ?, ?, ?, ?);";
    $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    unless ($sth->execute($tid, $now, $version, $terms, $isocode)) {
      my $msg = $c->app->db_metadata->dbh->errstr;
      $c->app->log->error($msg);
      push @{$res->{alerts}}, {type => 'error', msg => $msg};
      $res->{status} = 500;
      return $res;
    }

    push @{$res->{terms}}, {tid => $tid, version => $version, isocode => $isocode, terms => $terms, added => $now};
  }

  return $res;
}

sub update {
  my $self = shift;
  my $c    = shift;
  my $tid  = shift;
  my $data = shift;

  my $res = {alerts => [], status => 200};

  unless ($tid) {
    my $errmsg = 'No TID provided';
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 400;
    return $res;
  }

  my $ss  = "SELECT TID, version, isocode, terms, added FROM terms_of_use WHERE TID = '$tid';";
  my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  my ($existing_tid, $version, $isocode, $terms, $added);
  $sth->bind_columns(undef, \$existing_tid, \$version, \$isocode, \$terms, \$added) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  unless ($existing_tid) {
    my $errmsg = 'Terms of use entry not found';
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 404;
    return $res;
  }

  if (defined($data->{terms})) {
    $terms = $data->{terms};
  }
  if (defined($data->{isocode})) {
    $isocode = $data->{isocode};
  }

  unless ($terms) {
    my $errmsg = 'Terms text is required';
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 400;
    return $res;
  }
  unless ($isocode && length($isocode) == 2) {
    my $errmsg = 'Invalid language code';
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 400;
    return $res;
  }

  $ss  = "SELECT isocode FROM terms_of_use WHERE version = '$version' AND isocode = '$isocode' AND TID != '$tid';";
  $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  my $isocodeexists;
  $sth->bind_columns(undef, \$isocodeexists) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  if ($isocodeexists) {
    my $errmsg = "Language $isocode already exists for version $version";
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 400;
    return $res;
  }

  $ss  = "UPDATE terms_of_use SET terms = ?, isocode = ? WHERE TID = ?;";
  $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  unless ($sth->execute($terms, $isocode, $tid)) {
    my $msg = $c->app->db_metadata->dbh->errstr;
    $c->app->log->error($msg);
    push @{$res->{alerts}}, {type => 'error', msg => $msg};
    $res->{status} = 500;
    return $res;
  }

  $res->{term} = {tid => $tid, version => $version, isocode => $isocode, terms => $terms, added => $added};
  return $res;
}

sub getagreed {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  my $res = {alerts => [], status => 200, agreed => undef};

  my $ss  = "SELECT version FROM terms_of_use ORDER BY version DESC;";
  my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  my ($latestversion);
  $sth->bind_columns(undef, \$latestversion) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->fetch();
  $sth->finish();

  $ss  = "SELECT agreed FROM user_terms WHERE username = '$username' AND version = '$latestversion';";
  $sth = $c->app->db_user->dbh->prepare($ss) or $c->app->log->error($c->app->db_user->dbh->errstr);
  $sth->execute() or $c->app->log->error($c->app->db_user->dbh->errstr);
  my $agreed;
  $sth->bind_columns(undef, \$agreed) or $c->app->log->error($c->app->db_user->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  if ($agreed) {
    $res->{agreed} = $agreed;
  }

  return $res;
}

sub agree {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;
  my $version  = shift;

  my $res = {alerts => [], status => 200};

  my $ss  = "SELECT version FROM terms_of_use WHERE version = '$version';";
  my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute() or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  my $versionexists;
  $sth->bind_columns(undef, \$versionexists) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  unless ($versionexists) {
    my $errmsg = 'Unknown version provided';
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 400;
    return $res;
  }

  $ss  = "SELECT agreed FROM user_terms WHERE username = '$username' AND version = '$version';";
  $sth = $c->app->db_user->dbh->prepare($ss) or $c->app->log->error($c->app->db_user->dbh->errstr);
  $sth->execute() or $c->app->log->error($c->app->db_user->dbh->errstr);
  my $agreed;
  $sth->bind_columns(undef, \$agreed) or $c->app->log->error($c->app->db_user->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  if ($agreed) {
    my $errmsg = "Already agreeded to this version $agreed";
    $c->app->log->error($errmsg);
    push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
    $res->{status} = 400;
    return $res;
  }

  my @now = localtime();
  my $now = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $now[5] + 1900, $now[4] + 1, $now[3], $now[2], $now[1], $now[0]);

  $ss  = "INSERT INTO user_terms (username, version, agreed) VALUES ('$username', '$version', '$now');";
  $sth = $c->app->db_user->dbh->prepare($ss) or $c->app->log->error($c->app->db_user->dbh->errstr);
  unless ($sth->execute()) {
    my $msg = $c->app->db_user->dbh->errstr;
    $c->app->log->error($msg);
    push @{$res->{alerts}}, {type => 'error', msg => $msg};
    $res->{status} = 500;
    return $res;
  }

  return $res;
}

1;
__END__
