package PhaidraAPI::Controller::Utils;

use strict;
use warnings;
use v5.10;
use Mojo::File;
use Mojo::JSON qw(decode_json);
use base 'Mojolicious::Controller';
use Scalar::Util qw(looks_like_number);
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Util;
use MIME::Lite::TT::HTML;

sub get_all_pids {

  my $self = shift;

  my $search_model = PhaidraAPI::Model::Search->new;
  my $sr           = $search_model->triples($self, "* <http://purl.org/dc/elements/1.1/identifier> *");
  if ($sr->{status} ne 200) {
    return $sr;
  }

  my @pids;
  foreach my $statement (@{$sr->{result}}) {

    # get only o:N pids (there are also bdef etc..)
    next unless (@{$statement}[0] =~ m/(o:\d+)/);

    # skip handles
    next if (@{$statement}[2] =~ m/hdl/);

    @{$statement}[2] =~ m/^\<info:fedora\/([a-zA-Z\-]+:[0-9]+)\>$/g;
    my $pid = $1;
    $pid =~ m/^[a-zA-Z\-]+:([0-9]+)$/g;
    my $pidnum = $1;
    push @pids, {pid => $pid, pos => $pidnum};
  }

  @pids = sort {$a->{pos} <=> $b->{pos}} @pids;
  my @resarr;
  for my $p (@pids) {
    push @resarr, $p->{pid};
  }

  $self->render(json => {pids => \@resarr}, status => 200);

}

sub state {
  my $self = shift;
  $self->render(text => "remote_address:" . $self->tx->remote_address, status => 200);
}

sub testerror {
  my $self = shift;

  $self->app->log->error("test error");
  $self->render(json => {error => 'test error'}, status => 500);
}

sub openapi {
  my $self = shift;
  $self->stash(scheme   => $self->config->{scheme});
  $self->stash(baseurl  => $self->config->{baseurl});
  $self->stash(basepath => $self->config->{basepath});
}

sub openapi_json {
  my $self = shift;
  my $file = Mojo::File->new('/usr/local/phaidra/phaidra-api/public/docs/openapi.json');
  my $json = decode_json($file->slurp);
  $json->{servers} = [
    { "description" => "API endpoint",
      "url"         => $self->config->{scheme} . '://' . $self->config->{baseurl} . '/' . $self->config->{basepath}
    }
  ];
  $self->render(json => $json, status => 200);
}

sub request_doi {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  my $pid = $self->stash('pid');
  unless ($pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}]}, status => 400);
    return;
  }

  $self->app->log->debug("DOI request received pid[$pid]");

  my $settings = $self->mongo->get_collection('config')->find_one({ config_type => 'public' });

  my $to = $settings->{instanceConfig}->{requestdoiemail};
  unless ($to) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Request DOI email is not configured'}]}, status => 500);
    return;
  }

  my $currentuser = $self->stash->{basic_auth_credentials}->{username};
  if ($self->stash->{remote_user}) {
    $currentuser = $self->stash->{remote_user};
  }

  my $userdata = $self->app->directory->get_user_data($self, $currentuser);
  unless ($userdata) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Could not fetch user data'}]}, status => 500);
    return;
  }

  my %emaildata;
  $emaildata{name}    = $userdata->{firstname}." ".$userdata->{lastname};
  $emaildata{pid}     = $pid;
  $emaildata{email}   = $userdata->{email};
  $emaildata{baseurl} = $self->config->{baseurl};
  $self->app->log->debug("Sending DOI request email pid[$pid] currentuser[$currentuser] name[".$userdata->{firstname}." ".$userdata->{lastname}."] from[".$userdata->{email}."] to[$to]");
  my %options;
  for my $p (@{$self->app->renderer->paths}) {
    $options{INCLUDE_PATH} = $p;
  }
  eval {
    my $msg = MIME::Lite::TT::HTML->new(
      From        => $userdata->{email},
      To          => $to,
      Subject     => 'Subsequent DOI allocation',
      Charset     => 'utf8',
      Encoding    => 'quoted-printable',
      Template    => {html => 'email/doirequest.html.tt', text => 'email/doirequest.txt.tt'},
      TmplParams  => \%emaildata,
      TmplOptions => \%options
    );
    $msg->send;
  };
  if ($@) {
    my $err = "[$pid] sending DOI request email failed: " . $@;
    $self->app->log->error($err);

    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};
    $self->render(json => $res, status => $res->{status});
    return;
  }

  $self->render(json => $res, status => $res->{status});
}

sub geonames_search {
  my $self = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my $q = $self->req->param('q');
  my $lang = $self->req->param('lang');

  unless ($q) {
    my $err = "missing q param";
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }

  unless ($self->config->{apis}) {
    my $err = "apis are not configured";
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }

  unless ($self->config->{apis}->{geonames}) {
    my $err = "geonames api is not configured";
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }

  my $insecure = 0;
  if (exists($self->config->{apis}->{geonames}->{insecure})) {
    if ($self->config->{apis}->{geonames}->{insecure}) {
      $insecure = 1;
    }
  }

  my $params = { q => $q, lang => $lang };
  $params->{maxRows} = $self->config->{apis}->{geonames}->{maxRows} || 50;
  $params->{username} = $self->config->{apis}->{geonames}->{username} || 'phaidra';

  my $url = Mojo::URL->new($self->config->{apis}->{geonames}->{search})->query($params);
  my $get = $self->ua->insecure($insecure)->max_redirects(5)->get($url)->result;
  if ($get->is_success) {
    my $json = $get->json;
    $self->render(json => $json, status => $get->code);
    return;
  }
  else {
    $self->app->log->error("[$url] error searching geonames " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    $self->render(json => $res, status => $res->{status});
    return;
  }

}

sub gnd_search {
  my $self = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my $q = $self->req->param('q');
  my $from = $self->req->param('from');
  my $size = $self->req->param('size');

  unless ($q) {
    my $err = "missing q param";
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }

  unless(looks_like_number($from)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid from param provided'}]}, status => 400);
    return;
  }

  unless(looks_like_number($size)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid size param provided'}]}, status => 400);
    return;
  }

  unless ($self->config->{apis}) {
    my $err = "apis are not configured";
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }

  unless ($self->config->{apis}->{lobid}) {
    my $err = "lobid api is not configured";
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }

  my $params = { q => $q, from => $from, size => $size, format => 'json' };

  my $url = Mojo::URL->new('https://'.$self->config->{apis}->{lobid}->{baseurl}.'/gnd/search')->query($params);
  my $get = $self->ua->max_redirects(5)->get($url)->result;
  if ($get->is_success) {
    my $json = $get->json;
    $self->render(json => $json, status => $get->code);
    return;
  }
  else {
    $self->app->log->error("[$url] error searching lobid " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    $self->render(json => $res, status => $res->{status});
    return;
  }

}

1;
