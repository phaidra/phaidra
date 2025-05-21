package PhaidraAPI::Controller::Feedback;

use strict;
use warnings;
use v5.10;
use MIME::Lite;
use MIME::Lite::TT::HTML;
use base 'Mojolicious::Controller';

sub feedback {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $context   = $self->param('context');
  my $firstname = $self->param('firstname');
  my $lastname  = $self->param('lastname');
  my $email     = $self->param('email');
  my $message   = $self->param('message');

  my $user = $self->app->directory->get_user_data($self, $self->stash->{basic_auth_credentials}->{username});
  my $confmodel = PhaidraAPI::Model::Config->new;
  my $pubconfig = $confmodel->get_public_config($self);
  my $privconfig = $confmodel->get_private_config($self);

  my %emaildata;
  $emaildata{context}   = $context;
  $emaildata{firstname} = $firstname;
  $emaildata{lastname}  = $lastname;
  $emaildata{email}     = $email;
  $emaildata{message}   = $message;
  $emaildata{user}      = $user;

  my %options;
  $options{INCLUDE_PATH} = $self->config->{home} . '/templates/feedback';
  eval {
    my $msg = MIME::Lite::TT::HTML->new(
      From        => $pubconfig->{email},
      To          => $pubconfig->{email},
      Subject     => 'Phaidra feedback',
      Charset     => 'iso-8859-15',
      Encoding    => 'quoted-printable',
      Template    => {html => 'email.html.tt', text => 'email.txt.tt'},
      TmplParams  => \%emaildata,
      TmplOptions => \%options
    );
    $msg->send('smtp', $privconfig->{smtpserver}.':'.$privconfig->{smtpport}, AuthUser => $privconfig->{smtpuser}, AuthPass => $privconfig->{smtppassword}, SSL => ($privconfig->{smtpport} eq '465' || $privconfig->{smtpport} eq '587') ? 1 : 0);
  };
  if ($@) {
    my $err = "Error sending feedback email: " . $@;
    $self->app->log->error($err);
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};
    $self->render(json => $res, status => $res->{status});
    return;
  }

  $self->render(json => $res, status => $res->{status});
}

1;
