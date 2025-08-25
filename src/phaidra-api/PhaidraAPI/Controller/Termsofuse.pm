package PhaidraAPI::Controller::Termsofuse;

use strict;
use warnings;
use v5.10;
use Scalar::Util qw(looks_like_number);
use PhaidraAPI::Model::Termsofuse;
use PhaidraAPI::Model::RateLimit;
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
  
  # Get client IP address for rate limiting
  my $client_ip = $self->tx->remote_address;
  if ($client_ip eq '127.0.0.1' || $client_ip eq '::1') {
    # For local connections, try to get real IP from headers
    $client_ip = $self->req->headers->header('X-Forwarded-For') || 
                 $self->req->headers->header('X-Real-IP') || 
                 $client_ip;
  }
  
  # Create rate limiting identifier (combine username and IP for better security)
  my $identifier = $username . ':' . $client_ip;
  
  # Initialize rate limiting
  my $rate_limit_model = PhaidraAPI::Model::RateLimit->new;
  
  # Check rate limit before processing request
  my $rate_limit_check = $rate_limit_model->check_rate_limit($self, $identifier);
  
  if ($rate_limit_check->{blocked}) {
    $self->app->log->warn("Rate limit exceeded for user: $username, IP: $client_ip");
    $self->render(json => $rate_limit_check, status => $rate_limit_check->{status});
    return;
  }

  my $termsofuse_model = PhaidraAPI::Model::Termsofuse->new;
  my $res = $termsofuse_model->getagreed($self, $username);
  if($res->{status} == 200) {
    $rate_limit_model->record_successful_attempt($self, $identifier);
  } else {
    $rate_limit_model->record_failed_attempt($self, $identifier);
  }

  $self->render(json => $res, status => $res->{status});
}

1;
