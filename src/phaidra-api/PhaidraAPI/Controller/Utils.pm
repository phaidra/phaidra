package PhaidraAPI::Controller::Utils;

use strict;
use warnings;
use v5.10;
use Mojo::File;
use Mojo::JSON qw(decode_json);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Util;

sub streamingplayer {
  my $self = shift;
  my $pid  = $self->stash('pid');
  if ($self->config->{streaming}) {
    my $u_model = PhaidraAPI::Model::Util->new;
    my $r       = $u_model->get_video_key($self, $pid);
    if ($r->{status} eq 200) {
      $self->stash(video_key   => $r->{video_key});
      $self->stash(errormsg    => $r->{errormsq});
      $self->stash(server      => $self->config->{streaming}->{server});
      $self->stash(server_rtmp => $self->config->{streaming}->{server_rtmp});
      $self->stash(server_cd   => $self->config->{streaming}->{server_cd});
      $self->stash(basepath    => $self->config->{streaming}->{basepath});

      $self->stash(baseurl           => $self->config->{baseurl});
      $self->stash(streamingbasepath => $self->config->{streaming}->{basepath});
      $self->stash(trackpid          => "");
      $self->stash(tracklabel        => "");
      $self->stash(tracklanguage     => "");

    }
    else {
      $self->app->log->error("Video key not available: " . $self->app->dumper($r));
      $self->render(text => $self->app->dumper($r), status => $r->{status});
    }
  }
  else {
    $self->render(text => "Streaming not configured", status => 503);
  }
}

sub streamingplayer_key {
  my $self = shift;
  my $pid  = $self->stash('pid');
  if ($self->config->{streaming}) {
    my $u_model = PhaidraAPI::Model::Util->new;
    my $r       = $u_model->get_video_key($self, $pid);
    if ($r->{status} eq 200) {
      $self->render(text => $r->{video_key}, status => 200);
    }
    else {
      $self->app->log->error("Video key not available: " . $self->app->dumper($r));
      $self->render(text => $self->app->dumper($r), status => $r->{status});
    }
  }
  else {
    $self->render(text => "Streaming not configured", status => 503);
  }
}

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

1;
