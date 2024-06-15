package PhaidraAPI::Model::Termsofuse;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::File;

sub getagreed {
  my $self = shift;
  my $c    = shift;
  my $username  = shift;

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
  my $self = shift;
  my $c    = shift;
  my $username  = shift;
  my $version = shift;

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
  if ($sth->execute()) {
    $c->render(json => {alerts => [], status => 200}, status => 200);
  }
  else {
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
