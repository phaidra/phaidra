package PhaidraAPI::Controller::Termsofuse;

use strict;
use warnings;
use v5.10;
use Scalar::Util qw(looks_like_number);
use Mojo::ByteStream qw(b);
use base 'Mojolicious::Controller';

sub get {
  my $self = shift;

  my $lang = $self->param('lang');
  unless ($lang) {
    $lang = 'en';
  }
  unless (length($lang) == 2) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Error getting terms of use, invalid language'}]}, status => 500);
    return;
  }

  my $ss  = "SELECT terms, added, version FROM terms_of_use WHERE isocode = '$lang' ORDER BY version DESC;";
  my $sth = $self->app->db_metadata->dbh->prepare($ss) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  my ($terms, $added, $version);
  $sth->bind_columns(undef, \$terms, \$added, \$version) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  $sth->fetch();
  $sth->finish();

  unless ($terms && $added && $version) {

    # get any language
    $ss  = "SELECT terms, added, version FROM terms_of_use ORDER BY version DESC;";
    $sth = $self->app->db_metadata->dbh->prepare($ss) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
    $sth->execute() or $self->app->log->error($self->app->db_metadata->dbh->errstr);
    my ($terms, $added, $version);
    $sth->bind_columns(undef, \$terms, \$added, \$version) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
    $sth->fetch();
    $sth->finish();

    unless ($terms && $added && $version) {
      $self->render(json => {alerts => [{type => 'error', msg => 'Error getting terms of use'}]}, status => 500);
      return;
    }
  }
  $self->render(json => {alerts => [], status => 200, terms => $terms, added => $added, version => $version}, status => 200);
}

sub agree {
  my $self = shift;

  my $version = $self->stash('version');
  unless ($version) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No version provided'}]}, status => 400);
    return;
  }
  unless(looks_like_number($version)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid version provided'}]}, status => 400);
    return;
  }

  my $ss  = "SELECT version FROM terms_of_use WHERE version = '$version';";
  my $sth = $self->app->db_metadata->dbh->prepare($ss) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  my $versionexists;
  $sth->bind_columns(undef, \$versionexists) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  unless ($versionexists) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Unknown version provided'}]}, status => 400);
    return;
  }

  my $username = $self->stash->{basic_auth_credentials}->{username};

  $ss  = "SELECT agreed FROM user_terms WHERE username = '$username' AND version = '$version';";
  $sth = $self->app->db_user->dbh->prepare($ss) or $self->app->log->error($self->app->db_user->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_user->dbh->errstr);
  my $agreed;
  $sth->bind_columns(undef, \$agreed) or $self->app->log->error($self->app->db_user->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  if ($agreed) {
    $self->render(json => {alerts => [{type => 'error', msg => "Already agreeded to this version $agreed"}]}, status => 400);
    return;
  }

  my @now = localtime();
  my $now = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $now[5] + 1900, $now[4] + 1, $now[3], $now[2], $now[1], $now[0]);

  $ss  = "INSERT INTO user_terms (username, version, agreed) VALUES ('$username', '$version', '$now');";
  $sth = $self->app->db_user->dbh->prepare($ss) or $self->app->log->error($self->app->db_user->dbh->errstr);
  if ($sth->execute()) {
    $self->render(json => {alerts => [], status => 200}, status => 200);
  }
  else {
    my $msg = $self->app->db_user->dbh->errstr;
    $self->app->log->error($msg);
    $self->render(json => {alerts => [{type => 'error', msg => "Error agreeing to terms of use: $msg"}], status => 500}, status => 500);
  }
}

sub getagreed {
  my $self = shift;

  my $username = $self->stash->{basic_auth_credentials}->{username};

  my $ss  = "SELECT version FROM terms_of_use ORDER BY version DESC;";
  my $sth = $self->app->db_metadata->dbh->prepare($ss) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  my ($latestversion);
  $sth->bind_columns(undef, \$latestversion) or $self->app->log->error($self->app->db_metadata->dbh->errstr);
  $sth->fetch();
  $sth->finish();

  $ss  = "SELECT agreed FROM user_terms WHERE username = '$username' AND version = '$latestversion';";
  $sth = $self->app->db_user->dbh->prepare($ss) or $self->app->log->error($self->app->db_user->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_user->dbh->errstr);
  my $agreed;
  $sth->bind_columns(undef, \$agreed) or $self->app->log->error($self->app->db_user->dbh->errstr);
  $sth->fetch();
  $sth->finish();
  if ($agreed) {
    $self->render(json => {alerts => [], status => 200, agreed => $agreed}, status => 200);
  }
  else {
    $self->render(json => {alerts => [], status => 200, agreed => undef}, status => 200);
  }
}

1;
