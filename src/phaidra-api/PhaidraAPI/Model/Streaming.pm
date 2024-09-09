package PhaidraAPI::Model::Streaming;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;
use Mojo::Util qw(decode encode url_escape url_unescape);
use Digest::SHA qw(hmac_sha1_hex);
use PhaidraAPI::Model::Object;

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

sub create_streaming_job {
  my ($self, $c, $pid, $cmodel) = @_;

  my $res = {alerts => [], status => 200};
  if ($c->app->config->{streaming} ||
      defined $c->app->config
      ->{external_services}->{opencast}->{mode} &&
      $c->app->config->{external_services}->{opencast}->{mode}
      eq "ACTIVATED") {
    $c->app->log->info("Creating streaming job pid[$pid] cm[$cmodel]");
    my $path;
    if ($c->app->config->{fedora}->{version} >= 6) {
      my $fedora_model = PhaidraAPI::Model::Fedora->new;
      my $dsAttr       = $fedora_model->getDatastreamPath($c, $pid, 'OCTETS');
      if ($dsAttr->{status} eq 200) {
        $c->app->log->error("streaming job pid[$pid] cm[$cmodel]: could not get path");
        $path = $dsAttr->{path};
      }
    } else {
      my $octets_model = PhaidraAPI::Model::Octets->new;
      my $parthres     = $octets_model->_get_ds_path($c, $pid, 'OCTETS');
      if ($parthres->{status} != 200) {
        $res->{status} = $parthres->{status};
        push @{$res->{alerts}}, @{$parthres->{alerts}} if scalar @{$parthres->{alerts}} > 0;
        return $res;
      }
      else {
        $path = $parthres->{path};
      }
    }
    my $job = {pid => $pid, cmodel => $cmodel, agent => "vige", status => "new", created => time};
    $job->{path} = $path if $path;
    $c->paf_mongo->get_collection('jobs')->insert_one($job);
  }
  return $res;
}

sub get_job {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};
  if ($c->app->config->{streaming} ||
      defined $c->app->config
      ->{external_services}->{opencast}->{mode} &&
      $c->app->config->{external_services}->{opencast}->{mode}
      eq "ACTIVATED") {
    $c->app->log->info("Searching for streaming job pid[$pid]");
    my $resjob = $c->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'vige'}, {}, {"sort" => {"created" => -1}});
    if ($resjob->{pid}) {
      $res->{job} = $resjob;
      $c->app->log->info("job pid[$pid]:\n".$c->app->dumper($resjob));
      return $res;
    } else {
      unshift @{$res->{alerts}}, {type => 'error', msg => "Could not find job for pid[$pid]"};
      $res->{status} = 404;
      return $res
    }
  } else {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Streaming is not configured"};
    $res->{status} = 400;
    return $res;
  }
}

1;
__END__
