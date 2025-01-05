package PhaidraAPI::Model::Hooks;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;
use Digest::SHA qw(hmac_sha1_hex);
use IO::Scalar;
use Mojo::ByteStream qw(b);
use PhaidraAPI::Model::Dc;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Fedora;
use PhaidraAPI::Model::Iiifmanifest;
use PhaidraAPI::Model::Imageserver;
use PhaidraAPI::Model::Streaming;

sub add_or_modify_datastream_hooks {

  my ($self, $c, $pid, $dsid, $dscontent, $exists, $username, $password) = @_;

  my $res = {alerts => [], status => 200};

  my $search_model = PhaidraAPI::Model::Search->new;

  if (exists($c->app->config->{hooks})) {
    if (exists($c->app->config->{hooks}->{updatedc}) && $c->app->config->{hooks}->{updatedc}) {
      if ($dsid eq "UWMETADATA") {
        my $dc_model = PhaidraAPI::Model::Dc->new;
        $res = $dc_model->generate_dc_from_uwmetadata($c, $pid, $dscontent, $username, $password);
      }
      elsif ($dsid eq "MODS") {
        my $dc_model = PhaidraAPI::Model::Dc->new;
        $res = $dc_model->generate_dc_from_mods($c, $pid, $dscontent, $username, $password);
      }
    }

    if (exists($c->app->config->{hooks}->{updateindex}) && $c->app->config->{hooks}->{updateindex}) {
      my $dc_model     = PhaidraAPI::Model::Dc->new;
      my $index_model  = PhaidraAPI::Model::Index->new;
      my $object_model = PhaidraAPI::Model::Object->new;
      my $r            = $index_model->update($c, $pid, $dc_model, $search_model, $object_model);
      if ($r->{status} ne 200) {

        # just log but don't change status, this isn't fatal
        push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      }
    }

    if (exists($c->app->config->{hooks}->{iiifmanifest}) && $c->app->config->{hooks}->{iiifmanifest}) {
      if ($dsid eq "UWMETADATA" or $dsid eq "MODS" or $dsid eq "JSON-LD") {
        $c->app->log->debug("add_or_modify_datastream_hooks pid[$pid] Updating IIIF-MANIFEST from $dsid");
        
        my $rdshash      = $search_model->datastreams_hash($c, $pid);
        if ($rdshash->{status} ne 200) {

          # just log but don't change status, this isn't fatal
          push @{$res->{alerts}}, {type => 'error', msg => "add_or_modify_datastream_hooks pid[$pid] Error getting datastreams_hash when updating IIIF-MANIFEST metadata"};
          push @{$res->{alerts}}, @{$rdshash->{alerts}} if scalar @{$rdshash->{alerts}} > 0;
          return $res;
        }

        if (exists($rdshash->{dshash}->{'IIIF-MANIFEST'})) {
          my $iiifm_model = PhaidraAPI::Model::Iiifmanifest->new;
          my $r           = $iiifm_model->update_manifest_metadata($c, $pid);
          if ($r->{status} ne 200) {

            # just log but don't change status, this isn't fatal
            push @{$res->{alerts}}, {type => 'error', msg => "add_or_modify_datastream_hooks pid[$pid] Error updating IIIF-MANIFEST metadata"};
            push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
          }
        }
      }
    }

    if ($dsid eq "OCTETS") {
      if ($exists) {

        # $object_model->add_octets will re-index, so keep inventory cleanup above it to avoid indexing old data
        # delete inventory info
        $c->app->paf_mongo->get_collection('foxml.ds')->delete_one({'pid' => $pid});

        # delete imagemanipulator record
        $c->app->db_imagemanipulator->dbh->do('DELETE FROM image WHERE url = "' . $pid . '";') or $c->app->log->error("Error deleting from imagemanipulator db:" . $c->app->db_imagemanipulator->dbh->errstr);

        my $res_cmodel = $search_model->get_cmodel($c, $pid);
        if ($res_cmodel->{status} eq 200) {
          if ($res_cmodel->{cmodel} eq 'Picture' or $res_cmodel->{cmodel} eq 'PDFDocument') {
            my $imsr = $self->_create_imageserver_job_if_not_exists($c, $pid, $res_cmodel->{cmodel});
            push @{$res->{alerts}}, @{$imsr->{alerts}} if scalar @{$imsr->{alerts}} > 0;
          }
          if ($res_cmodel->{cmodel} eq 'Video') {
            my $vsr = $self->_create_streaming_job_if_not_exists($c, $pid, $res_cmodel->{cmodel});
            push @{$res->{alerts}}, @{$vsr->{alerts}} if scalar @{$vsr->{alerts}} > 0;
          }
        } else {
          $c->app->log->error("add_or_modify_datastream_hooks pid[$pid] Could not get cmodel, not creating imageserver/streaming job");
        }

      }
    }

    if ($dsid eq "RIGHTS") {
      my $res_cmodel = $search_model->get_cmodel($c, $pid);
      if ($res_cmodel->{status} ne 200) {
        push @{$res->{alerts}}, {type => 'error', msg => "add_or_modify_datastream_hooks pid[$pid] Error getting cmodel in add_or_modify_datastream_hooks"};
        $res->{status} = 500;
        return $res;
      }
      # currently only for videos, so we check the cmodel first
      if ($res_cmodel->{cmodel} eq 'Video') {
        my $rights_model = PhaidraAPI::Model::Rights->new;
        my $res_rights = $rights_model->xml_2_json($c, $dscontent);
        if ($res_rights->{status} eq 200) {
          my $rights = $res_rights->{rights};
          my $nrKeys = keys %{$rights};
          if ($nrKeys != 0) {
            my $find = $c->paf_mongo->get_collection('jobs')->find_one({pid => $pid});
            if ($find->{pid}) {
              $c->app->log->info("add_or_modify_datastream_hooks pid[$pid] Access restrictions have been added or modified: Current streaming job status[".$find->{status}."]");
              if ($find->{status} eq "TO_DELETE" or $find->{status} eq "DEL_REQUESTED") {
                $c->app->log->info("add_or_modify_datastream_hooks pid[$pid] Delete already requested. Noop.");
              } else {
                if ($find->{status} =~ m/^OC_DELETED_/) {
                  $c->app->log->info("add_or_modify_datastream_hooks pid[$pid] Already deleted. Noop.");
                } else {
                  $c->app->log->info("add_or_modify_datastream_hooks pid[$pid] Marking stream for delete.");
                  $c->paf_mongo->get_collection('jobs')->update_one(
                    { 'pid' => $pid, 'agent' => 'vige' },
                    { '$set'     => { 'status' => 'TO_DELETE' }},
                    { 'upsert'   => 0 }
                  );
                }
              }
            } else {
              $c->app->log->info("add_or_modify_datastream_hooks pid[$pid] Access restrictions have been added or modified, but streaming job wasn't found. Noop.");
            }
          } else {
            $c->app->log->info("add_or_modify_datastream_hooks pid[$pid] Access restrictions have been removed. Consider updating streaming jobs (manually).");
          }
        } else {
          push @{$res->{alerts}}, {type => 'error', msg => 'Error reading RIGHTS'};
          $res->{status} = 500;
          return $res;
        }
      }
    }
  }

  return $res;
}

sub add_or_modify_relationships_hooks {

  my ($self, $c, $pid, $username, $password) = @_;

  my $res = {alerts => [], status => 200};

  my $dc_model     = PhaidraAPI::Model::Dc->new;
  my $search_model = PhaidraAPI::Model::Search->new;

  my $object_model = PhaidraAPI::Model::Object->new;

  if (exists($c->app->config->{hooks})) {
    if (exists($c->app->config->{hooks}->{updatedc}) && $c->app->config->{hooks}->{updatedc}) {

      my $r = $search_model->datastreams_hash($c, $pid);
      if ($r->{status} ne 200) {
        return $r;
      }

      if (exists($r->{dshash}->{'UWMETADATA'})) {
        $res = $object_model->get_datastream($c, $pid, 'UWMETADATA', $username, $password);
        if ($res->{status} ne 200) {
          return $res;
        }
        $res->{UWMETADATA} = b($res->{UWMETADATA})->decode('UTF-8');
        return $dc_model->generate_dc_from_uwmetadata($c, $pid, $res->{UWMETADATA}, $username, $password);
      }

      if (exists($r->{dshash}->{'MODS'})) {
        $res = $object_model->get_datastream($c, $pid, 'MODS', $username, $password);
        if ($res->{status} ne 200) {
          return $res;
        }
        $res->{MODS} = b($res->{MODS})->decode('UTF-8');
        return $dc_model->generate_dc_from_mods($c, $pid, $res->{MODS}, $username, $password);
      }
    }
  }

  if (exists($c->app->config->{hooks})) {
    if (exists($c->app->config->{hooks}->{updateindex}) && $c->app->config->{hooks}->{updateindex}) {
      my $index_model = PhaidraAPI::Model::Index->new;
      my $r           = $index_model->update($c, $pid, $dc_model, $search_model, $object_model);
      if ($r->{status} ne 200) {

        # just log but don't change status, this isn't fatal
        push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      }
    }
  }

  return $res;
}

sub add_octets_hook {
  my ($self, $c, $pid, $exists) = @_;

  my $res = {alerts => [], status => 200};
  my $search_model = PhaidraAPI::Model::Search->new;

  unless (defined($exists)) {
    
    my $sr = $search_model->datastream_exists($c, $pid, 'OCTETS');
    if ($sr->{status} ne 200) {
      unshift @{$res->{alerts}}, @{$sr->{alerts}};
      $res->{status} = $sr->{status};
      return $res;
    }
    $exists = $sr->{'exists'};
  }

  if ($exists) {

    # $object_model->add_octets will re-index, so keep inventory cleanup above it to avoid indexing old data
    # delete inventory info
    $c->app->paf_mongo->get_collection('foxml.ds')->delete_one({'pid' => $pid});

    # delete imagemanipulator record
    if ($c->app->config->{imagemanipulator_db}) {
      $c->app->db_imagemanipulator->dbh->do('DELETE FROM image WHERE url = "' . $pid . '";') or $c->app->log->error("Error deleting from imagemanipulator db:" . $c->app->db_imagemanipulator->dbh->errstr);
    }

    my $res_cmodel = $search_model->get_cmodel($c, $pid);
    if ($res_cmodel->{status} eq 200) {
      if ($res_cmodel->{cmodel} eq 'Picture' or $res_cmodel->{cmodel} eq 'PDFDocument') {
        my $imsr = $self->_create_imageserver_job_if_not_exists($c, $pid, $res_cmodel->{cmodel});
        push @{$res->{alerts}}, @{$imsr->{alerts}} if scalar @{$imsr->{alerts}} > 0;
      }
      if ($res_cmodel->{cmodel} eq 'Video') {
        my $vsr = $self->_create_streaming_job_if_not_exists($c, $pid, $res_cmodel->{cmodel});
        push @{$res->{alerts}}, @{$vsr->{alerts}} if scalar @{$vsr->{alerts}} > 0;
      }
    } else {
      $c->app->log->error("Hooks: could not get cmodel, not creating imageserver/streaming job");
    }
    
  }

  return $res;
}

sub modify_hook {
  my ($self, $c, $pid, $state) = @_;

  my $res = {alerts => [], status => 200};
  my $idxres = $self->_index($c, $pid);
  push @{$res->{alerts}}, @{$idxres->{alerts}} if scalar @{$idxres->{alerts}} > 0;

  my $search_model = PhaidraAPI::Model::Search->new;
  my $res_cmodel   = $search_model->get_cmodel($c, $pid);
  if ($res_cmodel->{status} ne 200) {
    $c->app->log->error("modify_hook: could not get cmodel");
    return $res_cmodel;
  }
  else {
    if ($state eq 'A') {
      if (exists($c->app->config->{handle})) {
        if ($c->app->config->{handle}->{create_handle_job} eq '1') {
          unless (($c->app->config->{handle}->{ignore_pages} eq '1') && ($res_cmodel->{cmodel} eq 'Page')) {
            $self->_create_handle($c, $pid);
          }
        }
      }
      if ($res_cmodel->{cmodel} eq 'Picture' or $res_cmodel->{cmodel} eq 'PDFDocument') {
        my $imgsrv_model = PhaidraAPI::Model::Imageserver->new;
        my $imsr = $imgsrv_model->create_imageserver_job($c, $pid, $res_cmodel->{cmodel});
        push @{$res->{alerts}}, @{$imsr->{alerts}} if scalar @{$imsr->{alerts}} > 0;
      }
      if ($res_cmodel->{cmodel} eq 'Video') {
        my $strm_model = PhaidraAPI::Model::Streaming->new;
        my $vsr = $strm_model->create_streaming_job($c, $pid, $res_cmodel->{cmodel});
        push @{$res->{alerts}}, @{$vsr->{alerts}} if scalar @{$vsr->{alerts}} > 0;
      }
    }
  }

  return $res;
}

sub _create_imageserver_job_if_not_exists {
  my ($self, $c, $pid, $cmodel) = @_;

  my $res = {alerts => [], status => 200};

  my $imgsrv_model = PhaidraAPI::Model::Imageserver->new;
  my $find = $c->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'pige'});
  unless ($find->{pid}) {    
    return $imgsrv_model->create_imageserver_job($c, $pid, $cmodel);
  }

  return $res;
}

sub _create_streaming_job_if_not_exists {
  my ($self, $c, $pid, $cmodel) = @_;

  my $res = {alerts => [], status => 200};

  my $strm_model = PhaidraAPI::Model::Streaming->new;
  my $find = $c->paf_mongo->get_collection('jobs')->find_one({pid => $pid, agent => 'vige'});
  unless ($find->{pid}) {    
    return $strm_model->create_streaming_job($c, $pid, $cmodel);
  }

  return $res;
}

sub _create_handle {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my ($pidnoprefix) = $pid =~ /o:(\d+)/;
  my @ts            = localtime(time());
  my $ts_iso        = sprintf("%04d%02d%02dT%02d%02d%02d", $ts[5] + 1900, $ts[4] + 1, $ts[3], $ts[2], $ts[1], $ts[0]);
  my $hdl           = $c->app->config->{handle}->{hdl_prefix} . "/" . $c->app->config->{handle}->{instance_hdl_prefix} . "." . $pidnoprefix;
  my $url           = $c->app->config->{handle}->{instance_url_prefix} . $pid;

  my $find = $c->irma_mongo->get_collection('irma.map')->find_one({hdl => $hdl});
  unless ($find->{hdl}) {
    $c->app->log->info("_create_handle: creating handle job hdl[$hdl] url[$url]");
    $c->irma_mongo->get_collection('irma.map')->insert_one(
      { ts_iso   => $ts_iso,
        _created => time,
        _updated => time,
        hdl      => $hdl,
        url      => $url
      }
    );

    my $object_model = PhaidraAPI::Model::Object->new;
    my $idres        = $object_model->add_relationship($c, $pid, 'http://purl.org/dc/terms/identifier', "hdl:$hdl", $c->app->config->{phaidra}->{intcallusername}, $c->app->config->{phaidra}->{intcallpassword});
    if ($idres->{status} eq 200) {
      $c->app->log->info("_create_handle: added handle relationship hdl[$hdl]");
    }
    else {
      $c->app->log->error("_create_handle: failed to add hdl[$hdl] to relationships");
      return $idres;
    }
  }
  else {
    $c->app->log->info("_create_handle: handle already exists hdl[$hdl]");
  }

  return $res;
}

sub _index {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  if (exists($c->app->config->{hooks})) {
    if (exists($c->app->config->{hooks}->{updateindex}) && $c->app->config->{hooks}->{updateindex}) {
      my $dc_model     = PhaidraAPI::Model::Dc->new;
      my $search_model = PhaidraAPI::Model::Search->new;
      my $index_model  = PhaidraAPI::Model::Index->new;
      my $object_model = PhaidraAPI::Model::Object->new;
      my $r            = $index_model->update($c, $pid, $dc_model, $search_model, $object_model);
      if ($r->{status} ne 200) {

        # just log but don't change status, this isn't fatal
        push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      }
    }
  }

  return $res;

}

1;
__END__
