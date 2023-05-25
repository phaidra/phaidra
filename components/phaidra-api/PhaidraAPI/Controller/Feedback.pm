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
      From        => $self->config->{phaidra}->{supportemail},
      To          => $self->config->{phaidra}->{supportemail},
      Subject     => 'Phaidra feedback',
      Charset     => 'iso-8859-15',
      Encoding    => 'quoted-printable',
      Template    => {html => 'email.html.tt', text => 'email.txt.tt'},
      TmplParams  => \%emaildata,
      TmplOptions => \%options
    );
    $msg->send;
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
