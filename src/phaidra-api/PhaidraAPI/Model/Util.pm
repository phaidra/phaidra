package PhaidraAPI::Model::Util;

use strict;
use warnings;
use v5.10;
use XML::LibXML;
use Digest::SHA qw(hmac_sha256);
use POSIX qw(strftime);
use Socket qw(AF_INET6 inet_aton inet_pton);
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

sub xml_to_hash {
  my $self = shift;
  my $c = shift;
  my $node = shift;

  return $self->_xml_to_hash($c, $node);
}

sub _xml_to_hash {
  my ($self, $c, $node) = @_;
    my %hash;

    # Handle attributes if present
    if ($node->hasAttributes) {
        foreach my $attr ($node->attributes) {
            $hash{'@' . $attr->nodeName} = $attr->value;
        }
    }

    # Handle child nodes
    foreach my $child ($node->childNodes) {
        my $name = $child->nodeName;
        
        # Skip processing instructions and comments
        next if $child->nodeType == XML::LibXML::XML_PI_NODE 
             || $child->nodeType == XML::LibXML::XML_COMMENT_NODE;

        # Handle text content
        if ($child->nodeType == XML::LibXML::XML_TEXT_NODE) {
            my $content = $child->textContent;
            $content =~ s/^\s+|\s+$//g;  # trim whitespace
            if ($content ne '') {
                $hash{'#text'} = $content;
            }
            next;
        }

        my $value;
        if ($child->hasChildNodes) {
            # Recursive call for nested elements
            $value = $self->_xml_to_hash($c, $child);
        } else {
            $value = $child->textContent;
        }

        # Handle multiple elements with same name
        if (exists $hash{$name}) {
            if (ref($hash{$name}) eq 'ARRAY') {
                push @{$hash{$name}}, $value;
            } else {
                $hash{$name} = [$hash{$name}, $value];
            }
        } else {
            $hash{$name} = $value;
        }
    }

    return \%hash;
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

# Parse pid 'o:<num>' into pid_num INT
sub parse_pid_num {
  my ($pid) = @_;
  my ($n) = ($pid // '') =~ /^o:(\d+)$/;
  return defined $n ? int($n) : 0;
}

# Return packed 4 or 16 byte IP; undef if invalid
sub pack_ip_canonical {
  my ($ip) = @_;
  return unless defined $ip && length $ip;
  my $v4 = inet_aton($ip);
  return $v4 if $v4;                           # 4 bytes
  # inet_pton may be unavailable on very old Perls; check and fall back to undef
  if (defined &Socket::inet_pton) {
    my $v6 = inet_pton(AF_INET6, $ip);
    return $v6 if $v6;                         # 16 bytes
  }
  return;                                      # invalid
}

# Make per-day visitor_id from IP + YYYY-MM-DD using HMAC-SHA256 (with secret pepper)
# Variant A: 64-bit BIGINT
sub make_visitor_id_u64 {
  my ($ip_str) = @_;
  my $packed = pack_ip_canonical($ip_str) or return undef;
  my $pepper = $ENV{PHAIDRA_ENCRYPTION_KEY} // die "PHAIDRA_ENCRYPTION_KEY not set";
  my $day = strftime('%Y-%m-%d', localtime);
  my $mac    = hmac_sha256($packed . $day, $pepper); # 32 bytes
  my $first8 = substr($mac, 0, 8);
  return unpack('Q>', $first8);                # unsigned 64-bit, big-endian
}

# Anonymize IP with Socket only and return storage-ready fields:
# ip_version (4|6), ip_v4 (INT UNSIGNED, masked /24) or ip_v6 (VARBINARY(16), masked /64)
sub anonymize_ip_for_storage {
  my ($ipaddress) = @_;

  # Try IPv4
  if (my $v4 = inet_aton($ipaddress)) {
    # Zero last octet => /24
    my ($a, $b, $c, $d) = unpack('C4', $v4);
    my $masked_v4 = pack('C4', $a, $b, $c, 0);
    my $ip_v4_int = unpack('N', $masked_v4); # INT UNSIGNED in network order
    return (4, $ip_v4_int, undef);
  }

  # Try IPv6 (if inet_pton is available)
  if (defined &Socket::inet_pton) {
    if (my $v6 = inet_pton(AF_INET6, $ipaddress)) {
      # Zero last 8 bytes => /64
      my $masked_v6 = substr($v6, 0, 8) . ("\0" x 8);
      return (6, undef, $masked_v6);          # VARBINARY(16)
    }
  }

  # Fallback: invalid IP -> 0.0.0.0
  return (4, 0, undef);
}

sub track_action {
  my ($self, $c, $pid, $action) = @_;

  return if $c->{isbot};

  eval {

    # Normalize pid -> pid_num (INT)
    my $pid_num = parse_pid_num($pid);

    # Resolve client IP (prefer first X-Forwarded-For value if present)
    my $ip = $c->tx->remote_address;
    if (my $xff = $c->req->headers->header('X-Forwarded-For')) {
      ($ip) = $xff =~ /^([^,]+)/; # first in list
    }

    # Use current timestamp; visitor_id needs only the date part
    my $visitor_id = make_visitor_id_u64($ip);

    my ($ip_version, $ip_v4, $ip_v6) = anonymize_ip_for_storage($ip);

    my $dbh = $c->app->db_metadata->dbh;

    # Prepared insert into usage_log; country filled later by nightly job
    my $sql = qq{
      INSERT INTO usage_log
        (action, pid_num, visitor_id, ip_version, ip_v4, ip_v6, country)
      VALUES
        (?, ?, ?, ?, ?, ?, NULL)
    };
    my $sth = $dbh->prepare($sql);
    $sth->execute($action, $pid_num, $visitor_id, $ip_version, $ip_v4, $ip_v6)
      or $c->app->log->error($dbh->errstr);
  };

  if ($@) {
    $c->app->log->error("Error tracking action pid[$pid] action[$action]: $@");
  }
}

1;
__END__
