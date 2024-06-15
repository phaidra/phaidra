package PhaidraAPI::Model::Imageserver;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;
use Mojo::Util qw(decode encode url_escape url_unescape);
use Digest::SHA qw(hmac_sha1_hex);
use PhaidraAPI::Model::Object;

sub get_url {

  my ($self, $c, $params_arg, $rightscheck) = @_;

  my $res = {alerts => [], status => 200};

  my $url = Mojo::URL->new;

  $url->scheme($c->app->config->{imageserver}->{scheme});
  $url->host($c->app->config->{imageserver}->{host});
  $url->path($c->app->config->{imageserver}->{path});

  my $isr = $c->app->config->{imageserver}->{image_server_root};

  my $p;
  my $p_name;
  my $params = $params_arg->to_hash;
  for my $param_name ('FIF', 'IIIF', 'Zoomify', 'DeepZoom') {
    if (exists($params->{$param_name})) {
      $p      = $params->{$param_name};
      $p_name = $param_name;
      last;
    }
  }

  unless ($p) {
    my $msg = 'Cannot find IIIF, Zoomify or DeepZoom parameter';
    $c->app->log->error($msg);
    unshift @{$res->{alerts}}, {type => 'error', msg => $msg};
    $res->{status} = 400;
    return $res;
  }

  my $root = $c->app->config->{imageserver}->{image_server_root};
  # if this is a request using the image path
  if($p =~ m/^\/?\Q$root/i) {
    if ($rightscheck) {
      # find the corresponding pid and check rights
      if($p =~ m/.+\/([0-9A-F]{40})\.tif(.+)?$/i) {
        my $idhash = $1;
        my $cachekey = "idhash2pid_" . $idhash;
        my $pid = $c->app->chi->get($cachekey);
        unless ($pid) {
          $c->app->log->debug("[cache miss] $cachekey");

          my $res = $c->paf_mongo->get_collection('jobs')->find_one({idhash => $idhash}, {}, {"sort" => {"created" => -1}});
          if ($res->{pid}) {
            $pid = $res->{pid};
            $c->app->chi->set($cachekey, $pid, '1 day');
          }
        }
        else {
          $c->app->log->debug("[cache hit] $cachekey");
        }

        if ($pid) {
          my $check_pid_rights = $self->check_pid_rights($c, $pid);
          unless ($check_pid_rights eq 200) {
            $c->app->log->info("imageserver::get_url username[" . (defined($c->stash->{basic_auth_credentials}->{username}) ? $c->stash->{basic_auth_credentials}->{username} : '' ) . "] idhash[$idhash] pid[$pid] forbidden");
            unshift @{$res->{alerts}}, {type => 'error', msg => 'Forbidden'};
            $res->{status} = 403;
            return $res;
          }
        } else {
          $self->render(json => {alerts => [{type => 'info', msg => "Could not find PID for idhash[$idhash]"}]}, status => 400);
          return;
        }
      } else {
        $self->render(json => {alerts => [{type => 'info', msg => "Seems like a request using image path but can't match the idhash"}]}, status => 400);
        return;
      }
    }
  } else {

    # if this is a request using the pid
    $p =~ m/([a-z]+:[0-9]+)_?([A-Z]+)?\.tif/;
    my $pid = $1;
    my $ds  = $2;

    if ($rightscheck) {
      my $check_pid_rights = $self->check_pid_rights($c, $pid);
      unless ($check_pid_rights eq 200) {
        $c->app->log->info("imageserver::get_url username[" . (defined($c->stash->{basic_auth_credentials}->{username}) ? $c->stash->{basic_auth_credentials}->{username} : '' ) . "] pid[$pid] forbidden");
        unshift @{$res->{alerts}}, {type => 'error', msg => 'Forbidden'};
        $res->{status} = 403;
        return $res;
      }
    }

    # infer hash
    my $hash;
    if (defined($ds)) {
      $hash = hmac_sha1_hex($pid . "_" . $ds, $c->app->config->{imageserver}->{hash_secret});
    }
    else {
      $hash = hmac_sha1_hex($pid, $c->app->config->{imageserver}->{hash_secret});
    }
    
    my $first   = substr($hash, 0, 1);
    my $second  = substr($hash, 1, 1);
    my $imgpath = "$root/$first/$second/$hash.tif";

    # add leading slash if missing
    $p =~ s/^\/*/\//;

    # replace pid with hash
    $p =~ s/([a-z]+:[0-9]+)(_[A-Z]+)?\.tif/$imgpath/;
  }

  # we have to put the imagepath param first, imageserver needs this order
  my $new_params = Mojo::Parameters->new;
  $new_params->append($p_name => $p);

  # have to go through pairs because ->params->names changes the order and the order is
  # significant for FIF
  # "Note that the FIF command must always be the first parameter and the JTL or CVT command must always be the last."
  # (from http://iipimage.sourceforge.net/documentation/protocol/)
  for (my $i = 0; $i < @{$params_arg->pairs}; $i += 2) {
    my ($name, $value) = @{$params_arg->pairs}[$i, $i + 1];
    next if $name eq $p_name;
    $new_params->append($name => $params_arg->every_param($name));
  }
  $res->{url} = $url->to_string . "?" . $self->param_to_string($c, $new_params->pairs);
  return $res;
}

sub check_pid_rights {
  my ($self, $c, $pid) = @_;

  my $usrnm           = $c->stash->{basic_auth_credentials}->{username} ? $c->stash->{basic_auth_credentials}->{username} : '';
  my $cachekey        = "img_rights_" . $usrnm . "_$pid";
  my $status_cacheval = $c->app->chi->get($cachekey);
  unless ($status_cacheval) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $authz = PhaidraAPI::Model::Authorization->new;
    my $rres  = $authz->check_rights($c, $pid, 'r');
    $status_cacheval = $rres->{status};

    $c->app->chi->set($cachekey, $status_cacheval, '1 day');
  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $status_cacheval;
}

# we cannot let mojo url-escape the values, imageserver won't take it
sub param_to_string {
  my $self  = shift;
  my $c     = shift;
  my $pairs = shift;

  # Build pairs (HTML Living Standard)
  return '' unless @$pairs;
  my @pairs;
  for (my $i = 0; $i < @$pairs; $i += 2) {
    my ($name, $value) = @{$pairs}[$i, $i + 1];

    # Escape and replace whitespace with "+"
    $name  = encode 'UTF-8', $name;
    $name  = url_escape $name, '^*\-.0-9A-Z_a-z';
    $value = encode 'UTF-8', $value;

    #$value = url_escape $value, '^*\-.0-9A-Z_a-z';
    s/\%20/\+/g for $name, $value;

    push @pairs, "$name=$value";
  }

  return join '&', @pairs;
}

sub create_imageserver_job {
  my ($self, $c, $pid, $cmodel, $ds) = @_;

  my $res = {alerts => [], status => 200};

  $c->app->log->info("Creating imageserver job pid[$pid] cm[$cmodel] ds[".(defined($ds) ? $ds : '')."]");
  my $hash;
  if (defined($ds)) {
    $hash = hmac_sha1_hex($pid . "_" . $ds, $self->app->config->{imageserver}->{hash_secret});
  } else {
    $hash = hmac_sha1_hex($pid, $c->app->config->{imageserver}->{hash_secret});
  }
  $res->{hash} = $hash;
  my $path;
  if ($c->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $dsAttr       = $fedora_model->getDatastreamPath($c, $pid, 'OCTETS');
    if ($dsAttr->{status} eq 200) {
      $path = $dsAttr->{path};
    } else {
      $c->app->log->error("imageserver job pid[$pid] cm[$cmodel]: could not get path");
    }
  }
  my $job = {pid => $pid, cmodel => $cmodel, agent => "pige", status => "new", idhash => $hash, created => time};
  $job->{path} = $path if $path;
  $job->{ds} = $ds if $ds;
  $c->paf_mongo->get_collection('jobs')->insert_one($job);
  
  return $res;
}

1;
__END__
