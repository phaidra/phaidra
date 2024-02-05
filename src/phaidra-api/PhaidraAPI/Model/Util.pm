package PhaidraAPI::Model::Util;

use strict;
use warnings;
use v5.10;
use XML::LibXML;
use Net::IP qw(:PROC);
use base qw/Mojo::Base/;

sub validate_xml() {

  my $self    = shift;
  my $c       = shift;
  my $xml     = shift;
  my $xsdpath = shift;

  my $res = {alerts => [], status => 200};

  unless (-f $xsdpath) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Cannot find XSD files: $xsdpath"};
    $res->{status} = 500;
  }

  my $schema = XML::LibXML::Schema->new(location => $xsdpath);
  my $parser = XML::LibXML->new;

  eval {

    $c->app->log->debug("Validating: " . $xml . "\n\nagainst $xsdpath");

    my $document = $parser->parse_string($xml);

    #$c->app->log->debug("Validating: ".$document->toString(1));

    $schema->validate($document);
  };

  if ($@) {
    $c->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
  }
  else {
    $c->app->log->info("Validation passed.");
  }

  return $res;
}

sub get_video_key {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;
  my $map_record;

  my $res = {alerts => [], status => 200};

  if (exists($c->app->config->{paf_mongodb})) {
    my $video_coll = $c->paf_mongo->get_collection('video.map');
    if ($video_coll) {
      $map_record = $video_coll->find_one({pid => $pid}, {}, {"sort" => {"_updated" => -1}});
    }
  }
  my $video_key;
  my $errormsg;
  if (defined($map_record) && !exists($map_record->{error})) {
    if ($map_record->{state} eq 'Active') {
      if ($map_record->{acc_code} eq 'public') {
        if (exists($map_record->{video0_status})) {
          if ($map_record->{video0_status} eq 'ok') {
            if (exists($map_record->{job_action})) {
              if ($map_record->{job_action} eq 'erledigt') {
                $res->{video_key} = $map_record->{key};
              }
              elsif ($map_record->{job_action} eq 'erstellt') {
                $errormsg = 'currently processed:' . $map_record->{job_id};
                $res->{status} = 503;
              }
              elsif ($map_record->{job_action} eq 'fehlgeschlagen') {
                $errormsg = 'processing failed:' . $map_record->{job_id};
                $res->{status} = 500;
              }
              else {
                $errormsg = 'not yet available: ' . $map_record->{job_action};
                $res->{status} = 503;
              }
            }
            else {
              $res->{video_key} = $map_record->{key};
            }
          }
          elsif ($map_record->{video0_status} eq 'tbq') {
            $errormsg = 'tbq';
            $res->{status} = 503;
          }
          else {
            $errormsg = 'video not ok: ' . $map_record->{video0_status};
            $res->{status} = 500;
          }
        }
      }
      else {
        $errormsg = 'restricted';
        $res->{status} = 403;
      }
    }
    else {
      $errormsg = 'Inactive';
      $res->{status} = 400;
    }
  }
  else {
    $errormsg = 'unavailable';
    $res->{status} = 404;
  }
  if ($errormsg) {
    push @{$res->{alerts}}, {type => ($res->{status} == 500 or $res->{status} == 404) ? 'error' : 'info', msg => $errormsg};
  }
  return $res;
}

sub anonymize_ip {

  my $self      = shift;
  my $c         = shift;
  my $ipaddress = shift;

  my $ip = new Net::IP($ipaddress);

  unless ($ip) {
    $c->app->log->error(Net::IP::Error());
    return '0.0.0.0';
  }

  return ip_bintoip(substr($ip->binip(), 0, 24) . '0' x 8,  $ip->version()) if $ip->version() eq 4;
  return ip_bintoip(substr($ip->binip(), 0, 48) . '0' x 80, $ip->version()) if $ip->version() eq 6;
  return '0.0.0.0';
}

sub track_action {
  my ($self, $c, $pid, $action) = @_;

  unless (exists($c->app->config->{"sites"})) {
    my $ip  = $c->tx->remote_address;
    my $ipa = $self->anonymize_ip($c, $ip);
    $c->app->db_metadata->dbh->do("INSERT INTO usage_stats (action, pid, ip) VALUES ('$action', '$pid', '$ipa');") or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  }
}

1;
__END__
