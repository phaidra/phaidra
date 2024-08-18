package PhaidraAPI::Controller::Octets;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::Util qw(url_escape);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Octets;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Util;

sub proxy {
  my $self = shift;

  my $pid = $self->stash('pid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  $object_model->proxy_datastream($self, $pid, 'OCTETS', $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
}

sub get {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');
  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  my $operation = $self->stash('operation');
  unless (defined($operation)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined operation'}]}, status => 400);
    return;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $authzres    = $authz_model->check_rights($self, $pid, 'ro');
  if ($authzres->{status} != 200) {
    $res->{status} = $authzres->{status};
    push @{$res->{alerts}}, @{$authzres->{alerts}} if scalar @{$authzres->{alerts}} > 0;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my ($filename, $mimetype, $size, $path);
  my $trywebversion = $self->param('trywebversion');

  if ($self->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $dsAttr;
    if ($trywebversion) {
      $dsAttr = $fedora_model->getDatastreamAttributes($self, $pid, 'WEBVERSION');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $filename = $dsAttr->{filename};
      $mimetype = $dsAttr->{mimetype};
      $size     = $dsAttr->{size};
      $dsAttr   = $fedora_model->getDatastreamPath($self, $pid, 'WEBVERSION');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $path = $dsAttr->{path};
    }
    unless ($path) {
      $dsAttr = $fedora_model->getDatastreamAttributes($self, $pid, 'OCTETS');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $filename = $dsAttr->{filename};
      $mimetype = $dsAttr->{mimetype};
      $size     = $dsAttr->{size};
      $dsAttr   = $fedora_model->getDatastreamPath($self, $pid, 'OCTETS');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $path = $dsAttr->{path};
    }
  }
  else {
    my $object_model = PhaidraAPI::Model::Object->new;
    my $r_oxml       = $object_model->get_foxml($self, $pid);
    if ($r_oxml->{status} ne 200) {
      $self->render(json => $r_oxml, status => $r_oxml->{status});
      return;
    }
    my $dom = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($r_oxml->{foxml});

    my $octets_model = PhaidraAPI::Model::Octets->new;

    if ($trywebversion) {
      my $parthres = $octets_model->_get_ds_path($self, $pid, 'WEBVERSION');
      if ($parthres->{status} == 200) {
        $path = $parthres->{path};
        ($filename, $mimetype, $size) = $octets_model->_get_ds_attributes($self, $pid, 'WEBVERSION', $dom);
      }
    }

    unless ($path) {
      my $parthres = $octets_model->_get_ds_path($self, $pid, 'OCTETS');
      if ($parthres->{status} != 200) {
        $res->{status} = $parthres->{status};
        push @{$res->{alerts}}, @{$parthres->{alerts}} if scalar @{$parthres->{alerts}} > 0;
        $self->render(json => $res, status => $res->{status});
        return;
      }
      else {
        $path = $parthres->{path};
      }
      ($filename, $mimetype, $size) = $octets_model->_get_ds_attributes($self, $pid, 'OCTETS', $dom);
    }

    my $docres;
    my $index_model = PhaidraAPI::Model::Index->new;
    if (!$size or $size == -1) {
      $self->app->log->debug("pid[$pid] getting size from index");
      $docres = $index_model->get_doc($self, $pid);
      if ($docres->{status} ne 200) {
        $self->app->log->error("pid[$pid] error searching for doc: " . $self->app->dumper($docres));
        $self->reply->static('images/error.png');
        return;
      }
      $size = $docres->{doc}->{size};
    }
  }

  # get filename from metadata if there is JSON-LD
  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $resjsonld          = $jsonld_model->get_object_jsonld_parsed($self, $pid);
  if ($resjsonld->{status} eq 200) {
    if (exists($resjsonld->{'JSON-LD'}->{'ebucore:filename'})) {
      for my $v (@{$resjsonld->{'JSON-LD'}->{'ebucore:filename'}}) {
        $filename = $v;
        last;
      }
    }
  }

  $self->app->log->debug("operation[$operation] trywebversion[" . ($trywebversion ? $trywebversion : 'undef') . "] pid[$pid] path[$path] mimetype[$mimetype] filename[$filename] size[$size]");

  if ($operation eq 'download') {
    $self->res->headers->content_disposition("attachment;filename=\"$filename\"");
  }
  else {
    $self->res->headers->content_disposition("filename=\"$filename\"");
  }
  $self->res->headers->content_type($mimetype);

  my $asset = Mojo::Asset::File->new(path => $path);

  # Range
  # based on Mojolicious::Plugin::RenderFile
  if (my $range = $self->req->headers->range) {
    my $start = 0;
    my $end   = $size - 1 >= 0 ? $size - 1 : 0;

    # Check range
    if ($range =~ m/^bytes=(\d+)-(\d+)?/ && $1 <= $end) {
      $start = $1;
      $end   = $2 if defined $2 && $2 <= $end;

      $res->{status} = 206;
      $self->res->headers->add('Content-Length' => $end - $start + 1);
      $self->res->headers->add('Content-Range'  => "bytes $start-$end/$size");
    }
    else {
      # Not satisfiable
      return $self->rendered(416);
    }

    # Set range for asset
    $asset->start_range($start)->end_range($end);
  }
  else {
    $self->res->headers->add('Content-Length' => $asset->size);
  }

  $self->track_download($pid, $operation);

  $self->res->content->asset($asset);
  $self->rendered($res->{status});
}

sub track_download {
  my ($self, $pid, $op) = @_;

  # track download
  my $fr = undef;
  if (exists($self->app->config->{sites})) {
    for my $f (@{$self->app->config->{sites}}) {
      if (defined($f->{site}) && $f->{site} eq 'phaidra') {
        $fr = $f;
      }
    }

    unless (defined($fr)) {
      $self->app->log->debug("pid[$pid] Not tracking download: Site is not configured");
      return;
    }
    unless ($fr->{site} eq 'phaidra') {
      $self->app->log->error("pid[$pid] Error tracking download: Site [" . $fr->{site} . "] is not supported");
      return;
    }
    unless (defined($fr->{stats})) {
      $self->app->log->error("pid[$pid] Error tracking download: Statistics source is not configured");
      return;
    }
    unless (defined($fr->{stats}->{serverbaseurl})) {
      $self->app->log->error("pid[$pid] Error tracking download: serverbaseurl is not configured");
      return;
    }
    unless (defined($fr->{stats}->{token})) {
      $self->app->log->error("pid[$pid] Error tracking download: token is not configured");
      return;
    }

    # only piwik now
    unless ($fr->{stats}->{type} eq 'piwik') {
      $self->app->log->error("pid[$pid] Error tracking download: Statistics source [" . $fr->{stats}->{type} . "] is not supported.");
      return;
    }

    unless (defined($fr->{stats}->{siteid})) {
      $self->app->log->error("pid[$pid] Error tracking download: Piwik siteid is not configured.");
      return;
    }

    my $siteid      = $fr->{stats}->{siteid};
    my $matomoapi   = "https://" . $fr->{stats}->{serverbaseurl} . "/matomo.php";
    my $matomotoken = $fr->{stats}->{token};
    my $actionname  = url_escape("download/$pid");

    my $trackurl  = "https://" . $self->app->config->{phaidra}->{baseurl} . "/" . ($op eq 'get' ? 'open' : $op) . "/$pid";
    my $url       = url_escape($trackurl);
    my $cip       = url_escape($self->tx->remote_address);
    my $tracklink = "?idsite=$siteid&rec=1&url=$url&action_name=$actionname&cip=$cip";

    my $ua = Mojo::UserAgent->new;
    $ua->request_timeout(1);

    $ua->post_p(
      "$matomoapi" => json => {
        "token_auth" => "$matomotoken",
        "requests"   => [$tracklink]
      }
    )->then(
      sub {
        my ($tx) = @_;
        if ($tx->result->is_success) {
          $self->app->log->debug("pid[$pid] tracking download successful");
        }
        else {
          $self->app->log->error("pid[$pid] tracking download failed");
        }
      }
    )->catch(
      sub {
        my $err = shift;
        $self->app->log->error("pid[$pid] tracking download failed: $err");
      }
    )->wait;
  }
  else {
    my $u_model = PhaidraAPI::Model::Util->new;
    $u_model->track_action($self, $pid, $op);
  }
}

1;
