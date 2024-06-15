package PhaidraAPI::Controller::Termsofuse;

use strict;
use warnings;
use v5.10;
use Scalar::Util qw(looks_like_number);
use PhaidraAPI::Model::Termsofuse;
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

  my $username = $self->stash->{basic_auth_credentials}->{username};

  my $termsofuse_model = PhaidraAPI::Model::Termsofuse->new;
  my $res = $termsofuse_model->agree($self, $username, $version);

  $self->render(json => $res, status => $res->{status});
}

sub getagreed {
  my $self = shift;

  my $username = $self->stash->{basic_auth_credentials}->{username};

  my $termsofuse_model = PhaidraAPI::Model::Termsofuse->new;
  my $res = $termsofuse_model->getagreed($self, $username);

  $self->render(json => $res, status => $res->{status});
}

1;
