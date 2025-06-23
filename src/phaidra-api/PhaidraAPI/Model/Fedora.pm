package PhaidraAPI::Model::Fedora;

use strict;
use warnings;
use v5.10;
use utf8;
use JSON;
use Mojo::File;
use Mojo::Util qw(encode);
use Digest::SHA qw(sha256_hex);
use base qw/Mojo::Base/;
use Net::Amazon::S3;
use Net::Amazon::S3::Vendor::Generic;
use Net::Amazon::S3::Authorization::Basic;

# S3 credentials and bucketname
my $aws_access_key_id = $ENV{S3_ACCESS_KEY};
my $aws_secret_access_key = $ENV{S3_SECRET_KEY};
my $s3_endpoint = $ENV{S3_ENDPOINT};
my $bucketname = $ENV{S3_BUCKETNAME};

my %prefix2ns = (

  # hasModel, state, ownerId
  "info:fedora/fedora-system:def/model#" => "fedora3",

  # hasCollectionMember
  "info:fedora/fedora-system:def/relations-external#" => "fedora3rel",

  # hasMember
  "http://pcdm.org/models#" => "pcdm",

  # references, identifier
  "http://purl.org/dc/terms/" => "dcterms",

  # isBackSideOf, isAlternativeFormatOf, isAlternativeVersionOf, isThumbnailFor
  "http://phaidra.org/XML/V1.0/relations#" => "porgrels",

  # hasSuccessor
  "http://phaidra.univie.ac.at/XML/V1.0/relations#" => "prels",

  # isInAdminSet
  "http://phaidra.org/ontology/" => "pont",

  # hasTrack
  "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#" => "ebucore"
);

sub getFedoraUrlPrefix {
  my ($self, $c) = @_;
  if ($c->app->fedoraurl->{port}) {
    return $c->app->fedoraurl->{scheme}.'://'.$c->app->fedoraurl->{host}.':'.$c->app->fedoraurl->{port}.'/'.$c->app->fedoraurl->{path};
  } else {
    return $c->app->fedoraurl->{scheme}.'://'.$c->app->fedoraurl->{host}.'/'.$c->app->fedoraurl->{path};
  }
}

sub getFirstJsonldValue {
  my ($self, $c, $jsonld, $p) = @_;

  for my $ob (@{$jsonld}) {
    if (exists($ob->{$p})) {
      for my $ob1 (@{$ob->{$p}}) {
        if (exists($ob1->{'@value'})) {
          return $ob1->{'@value'};
        }
        if (exists($ob1->{'@id'})) {
          my $fp = $self->getFedoraUrlPrefix($c);
          $ob1->{'@id'} =~ s/$fp//g;
          return $ob1->{'@id'};
        }
      }
    }
  }
}

sub getJsonldValue {
  my ($self, $c, $jsonld, $p) = @_;

  my @a;
  for my $ob (@{$jsonld}) {
    if (exists($ob->{$p})) {
      for my $ob1 (@{$ob->{$p}}) {
        if (exists($ob1->{'@value'})) {
          push @a, $ob1->{'@value'};
        } else {
          if (exists($ob1->{'@id'})) {
            my $fp = $self->getFedoraUrlPrefix($c);
            # $c->app->log->debug("XXXXXXXXXXX prefix $fp");
            $ob1->{'@id'} =~ s/$fp//g;
            push @a, $ob1->{'@id'};
          }
        }
      }
      last;
    }
  }
  return \@a;
}

sub _getObjectProperties {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $url = $c->app->fedoraurl->path($pid);
  $c->app->log->debug("GET $url");
  my $getres = $c->ua->get($url => $self->wrapAtomic($c, {'Accept' => 'application/ld+json'}))->result;

  if ($getres->is_success) {
    $res->{props} = $getres->json;
  }
  else {
    if ($getres->{code} == 410) {
      $res->{tombstone} = $getres->body;
    }
    unshift @{$res->{alerts}}, {type => 'error', msg => $getres->message};
    $res->{status} = $getres->{code};
    return $res;
  }
  return $res;
}

sub getObjectProperties {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $propres = $self->_getObjectProperties($c, $pid);
  if ($propres->{status} != 200) {
    return $propres;
  }

  my $props = $propres->{props};
  # $c->app->log->debug("XXXXXXXXXXXXXXX getObjectProperties propres:\n" . $c->app->dumper($props));

  # cmodel
  my $cmodel = $self->getFirstJsonldValue($c, $props, 'info:fedora/fedora-system:def/model#hasModel');
  $cmodel =~ m/(\w+):(\w+)/g;
  if ($1 eq 'cmodel' && defined($2) && ($2 ne '')) {
    $res->{cmodel} = $2;
  }

  $res->{state}    = $self->getFirstJsonldValue($c, $props, 'info:fedora/fedora-system:def/model#state');
  $res->{label}    = $self->getFirstJsonldValue($c, $props, 'info:fedora/fedora-system:def/model#label');
  $res->{created}  = $self->getFirstJsonldValue($c, $props, 'http://fedora.info/definitions/v4/repository#created');
  $res->{modified} = $self->getFirstJsonldValue($c, $props, 'http://fedora.info/definitions/v4/repository#lastModified');

  # $res->{owner}                  = $self->getJsonldValue($c, $props, 'http://fedora.info/definitions/v4/repository#createdBy');
  $res->{owner}                  = $self->getFirstJsonldValue($c, $props, 'info:fedora/fedora-system:def/model#ownerId');
  $res->{identifier}             = $self->getJsonldValue($c, $props, 'http://purl.org/dc/terms/identifier');
  $res->{references}             = $self->getJsonldValue($c, $props, 'http://purl.org/dc/terms/references');
  $res->{isbacksideof}           = $self->getJsonldValue($c, $props, 'http://phaidra.org/XML/V1.0/relations#isBackSideOf');
  $res->{isthumbnailfor}         = $self->getJsonldValue($c, $props, 'http://phaidra.org/XML/V1.0/relations#isThumbnailFor');
  $res->{hassuccessor}           = $self->getJsonldValue($c, $props, 'http://phaidra.univie.ac.at/XML/V1.0/relations#hasSuccessor');
  $res->{isalternativeformatof}  = $self->getJsonldValue($c, $props, 'http://phaidra.org/XML/V1.0/relations#isAlternativeFormatOf');
  $res->{isalternativeversionof} = $self->getJsonldValue($c, $props, 'http://phaidra.org/XML/V1.0/relations#isAlternativeVersionOf');
  $res->{isinadminset}           = $self->getJsonldValue($c, $props, 'http://phaidra.org/ontology/isInAdminSet');
  $res->{haspart}                = $self->getJsonldValue($c, $props, 'info:fedora/fedora-system:def/relations-external#hasCollectionMember');
  $res->{hasmember}              = $self->getJsonldValue($c, $props, 'http://pcdm.org/models#hasMember');
  $res->{hastrack}               = $self->getJsonldValue($c, $props, 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasTrack');
  $res->{sameas}                 = $self->getJsonldValue($c, $props, 'http://www.w3.org/2002/07/owl#sameAs');

  $res->{contains} = [];
  for my $ob (@{$props}) {
    if (exists($ob->{'http://www.w3.org/ns/ldp#contains'})) {
      for my $ob1 (@{$ob->{'http://www.w3.org/ns/ldp#contains'}}) {
        if (exists($ob1->{'@id'})) {
          push @{$res->{contains}}, (split '\/', $ob1->{'@id'})[-1];
        }
      }
    }
  }

  # $c->app->log->debug("XXXXXXXXXXXXXXX getObjectProperties:\n" . $c->app->dumper($res));
  return $res;
}

sub addRelationship {
  my ($self, $c, $pid, $predicate, $object, $skiphook) = @_;

  return $self->addRelationships($c, $pid, [{predicate => $predicate, object => $object}], $skiphook);
}

sub addRelationships {
  my ($self, $c, $pid, $relationships, $skiphook) = @_;

  return $self->insertTriples($c, $pid, $relationships);
}

sub removeRelationship {
  my ($self, $c, $pid, $predicate, $object, $skiphook) = @_;

  return $self->removeRelationships($c, $pid, [{predicate => $predicate, object => $object}], $skiphook);
}

sub removeRelationships {
  my ($self, $c, $pid, $relationships, $skiphook) = @_;

  return $self->deleteTriples($c, $pid, $relationships);
}

sub _getPrefProp {
  my ($self, $c, $predicate) = @_;

  for my $prefix (keys %prefix2ns) {
    if (rindex($predicate, $prefix, 0) == 0) {
      $predicate =~ s/$prefix//;
      return ($prefix, $predicate);
    }
  }
}

sub deleteTriples {
  my ($self, $c, $pid, $properties) = @_;

  return $self->_deleteOrInsertTriples($c, $pid, $properties, 'DELETE');
}

sub insertTriples {
  my ($self, $c, $pid, $properties) = @_;

  return $self->_deleteOrInsertTriples($c, $pid, $properties, 'INSERT');
}

sub _deleteOrInsertTriples {
  my ($self, $c, $pid, $properties, $action) = @_;

  my $prefixes = "";
  my $values   = "";
  for my $p (@{$properties}) {
    my ($pref, $prop) = $self->_getPrefProp($c, $p->{predicate});
    my $ns  = $prefix2ns{$pref};
    my $val = $p->{object};
    if ($val =~ m/info\:fedora/) {
      $val = '<'.$val.'>';
    } else {
      $val = '"'.$val.'"';
    }

    $prefixes .= "PREFIX " . $ns . ": <" . $pref . ">\n";
    $values   .= "<> $ns:$prop $val.\n";
  }
  my $body = qq|
    $prefixes
    $action {
      $values
    }
    WHERE { }
  |;

  return $self->_sparqlPatch($c, $pid, $body);
}

sub editTriples {
  my ($self, $c, $pid, $properties) = @_;

  my $res = {alerts => [], status => 200};

  my $propres = $self->_getObjectProperties($c, $pid);
  if ($propres->{status} != 200) {
    return $propres;
  }

  my $currentValues = $propres->{props};

  my $prefixes  = "";
  my $oldValues = "";
  my $newValues = "";
  for my $p (@{$properties}) {

    if ($p->{predicate} eq 'info:fedora/fedora-system:def/model#state') {
      $p->{object} = 'Active'   if $p->{object} eq 'A';
      $p->{object} = 'Inactive' if $p->{object} eq 'I';
      $p->{object} = 'Deleted'  if $p->{object} eq 'D';
    }

    # if eg
    # $p->{predicate} = info:fedora/fedora-system:def/model#state
    # $p->{object} = "A"
    # and current value is "Inactive"
    # we want
    #
    # PREFIX fedora3: <info:fedora/fedora-system:def/model#>
    # DELETE {
    #   <> fedora3:state "Inactive"
    # }
    # INSERT {
    #   <> fedora3:state "Active"
    # }
    # WHERE { }
    my ($pref, $prop) = $self->_getPrefProp($c, $p->{predicate});
    my $ns     = $prefix2ns{$pref};
    my $curVal = $self->getFirstJsonldValue($c, $currentValues, $p->{predicate});
    my $newVal = $p->{object};

    $prefixes  .= "PREFIX " . $ns . ": <" . $pref . ">\n";
    $oldValues .= "<> $ns:$prop \"$curVal\"\n";

    if ($newVal =~ m/info\:fedora/) {
      $newValues .= "<> $ns:$prop <$newVal>\n";
    } else {
      $newValues .= "<> $ns:$prop \"$newVal\"\n";
    }
  }
  my $body = qq|
    $prefixes
    DELETE {
      $oldValues .
    }
    INSERT {
      $newValues .
    }
    WHERE { }
  |;

  my $patchRes = $self->_sparqlPatch($c, $pid, $body);
}

sub _sparqlPatch {
  my ($self, $c, $pid, $body) = @_;

  my $res = {alerts => [], status => 200};

  my $url = $c->app->fedoraurl->path($pid);
  $c->app->log->debug("PATCH $url\n$body");

  my $patchres = $c->ua->patch($url => $self->wrapAtomic($c, {'Content-Type' => 'application/sparql-update'}) => $body)->result;
  unless ($patchres->is_success) {
    $c->app->log->error("Cannot update triples for pid[$pid]: code:" . $patchres->{code} . " message:" . $patchres->{message});
    unshift @{$res->{alerts}}, {type => 'error', msg => $patchres->{message}};
    $res->{status} = $patchres->{code} ? $patchres->{code} : 500;
    return $res;
  }

  return $res;
}

sub getDatastreamsHash {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $propres = $self->getObjectProperties($c, $pid);
  if ($propres->{status} != 200) {
    return $propres;
  }

  my %dsh;
  if (exists($propres->{contains})) {
    for my $contains (@{$propres->{contains}}) {
      $dsh{$contains} = 1;
    }
  }

  $res->{dshash} = \%dsh;

  $c->app->log->debug("getDatastreamsHash\n" . $c->app->dumper(\%dsh));

  return $res;
}

sub getDatastream {
  my ($self, $c, $pid, $dsid) = @_;

  my $res = {alerts => [], status => 200};

  $c->app->log->debug("getDatastream pid[$pid] dsid[$dsid]");

  if ($dsid eq "OCTETS") {
    unshift @{$res->{alerts}}, {type => 'error', msg => "getDatastream is not meant for OCTETS"};
    $res->{status} = 400;
    return $res;
  }

  my $url = $c->app->fedoraurl->path("$pid/$dsid");
  $c->app->log->debug("GET $url");
  my $getres = $c->ua->get($url)->result;

  if(($getres->{code} == 307) && ($dsid eq 'LINK') && $getres->headers->location) {
    # if this was a LINK in fedora 3.x it was migrated as external content redirect
    $res->{'LINK'} = $getres->headers->location;
  } else {
    if ($getres->is_success) {
      $res->{$dsid} = $getres->body;
    }
    else {
      unshift @{$res->{alerts}}, {type => 'error', msg => $getres->message};
      $res->{status} = $getres->{code};
      return $res;
    }
  }

  return $res;
}

sub getDatastreamAttributes {
  my ($self, $c, $pid, $dsid) = @_;

  my $res = {alerts => [], status => 200};

  $c->app->log->debug("getDatastreamSize pid[$pid] dsid[$dsid]");

  my $url = $c->app->fedoraurl->path("$pid/$dsid/fcr:metadata");
  $c->app->log->debug("GET $url");
  my $getres = $c->ua->get($url => {'Accept' => 'application/ld+json'})->result;

  if ($getres->is_success) {
    $res->{size}     = $self->getFirstJsonldValue($c, $getres->json, 'http://www.loc.gov/premis/rdf/v1#hasSize');
    $res->{mimetype} = $self->getFirstJsonldValue($c, $getres->json, 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasMimeType');
    $res->{filename} = $self->getFirstJsonldValue($c, $getres->json, 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#filename');
    $res->{modified} = $self->getFirstJsonldValue($c, $getres->json, 'http://fedora.info/definitions/v4/repository#lastModified');
    $res->{created}  = $self->getFirstJsonldValue($c, $getres->json, 'http://fedora.info/definitions/v4/repository#created');
  }
  else {
    unshift @{$res->{alerts}}, {type => 'error', msg => $getres->message};
    $res->{status} = $getres->{code};
    return $res;
  }

  return $res;
}

sub getDatastreamPath {
  my ($self, $c, $pid, $dsid) = @_;

  my $res = {alerts => [], status => 200};

  my $resourceID = "info:fedora/$pid";
  my $hash       = sha256_hex($resourceID);

  my $first  = substr($hash, 0, 3);
  my $second = substr($hash, 3, 3);
  my $third  = substr($hash, 6, 3);

  my $ocflroot    = $c->app->config->{fedora}->{ocflroot};
  my $objRootPath = "$ocflroot/$first/$second/$third/$hash";
  my $inventoryFile;
  my $inventoryFileFromS3;

  if ( defined $ENV{S3_ENABLED} and $ENV{S3_ENABLED} eq "true" ) {
    my $s3 = Net::Amazon::S3-> new(
      authorization_context => Net::Amazon::S3::Authorization::Basic-> new (
        aws_access_key_id => $aws_access_key_id,
        aws_secret_access_key => $aws_secret_access_key,
      ),
      retry => 1,
      vendor => Net::Amazon::S3::Vendor::Generic->new(
        host => $s3_endpoint =~ s/^https?:\/\///r,
        use_virtual_host => 0,
        use_https => !($s3_endpoint =~ qr/^http:\/\/.*/),
        default_region => "eu-central-1",
      ),
     );
    my $bucket = $s3->bucket($bucketname);
    $inventoryFileFromS3 = '/tmp/' . $pid . '_inventory.json';
    my $bucket_prefix = "fedora";
    my $response = $bucket->get_key_filename( "$bucket_prefix/$first/$second/$third/$hash/inventory.json", 'GET', $inventoryFileFromS3 )
      or die $s3->err . ": " . $s3->errstr;
    $inventoryFile = $inventoryFileFromS3;
  } else {
    $inventoryFile = "$objRootPath/inventory.json";
  }

  my $bytes         = Mojo::File->new($inventoryFile)->slurp;
  my $inventory     = decode_json($bytes);

  # # clean up inventoryfile if downloaded from S3
  # if (defined $inventoryFileFromS3) {
  #   unlink $inventoryFileFromS3;
  # }

  # sanity check
  unless ($inventory->{id} eq $resourceID) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Reading wrong inventory file resourceID[$resourceID] file[$inventoryFile]"};
    $res->{status} = 500;
    return $res;
  }

  my $head  = $inventory->{head};
  my $state = $inventory->{versions}->{$head}->{state};
  my $dsLatestKey;
  for my $key (keys %{$state}) {
    if (@{$state->{$key}}[0] eq $dsid) {
      $dsLatestKey = $key;
      last;
    }
  }
  my $pathArr = $inventory->{manifest}->{$dsLatestKey};

  my $path = @{$pathArr}[0];
  $res->{path} = "$objRootPath/$path";

  $c->app->log->debug("pid[$pid] head[$head] dsid[$dsid] dspath[$path]");

  return $res;
}

sub addOrModifyDatastream {
  my ($self, $c, $pid, $dsid, $location, $dscontent, $upload, $mimetype, $checksumtype, $checksum) = @_;

  my $res = {alerts => [], status => 200};

  if ($location) {
    # we're not going to create 'external content' in fcrepo because the resource cmodel is not supposed
    # to be pointing to binary data (normally it's just a link where user should be redirected)
    # my $url = $c->app->fedoraurl->path("$pid/LINK");
    # $c->app->log->debug("PUT $url Link $location");
    # my $putres = $c->ua->put($url => {'Link' => "<$location>; rel=\"http://fedora.info/definitions/fcrepo#ExternalContent\"; handling=\"redirect\"; type=\"text/plain\""})->result;
    # unless ($putres->is_success) {
    #   $c->app->log->error("pid[$pid] PUT Link $location error code:" . $putres->{code} . " message:" . $putres->{message});
    #   unshift @{$res->{alerts}}, {type => 'error', msg => $putres->{message}};
    #   $res->{status} = $putres->{code} ? $putres->{code} : 500;
    #   return $res;
    # }

    my $headers;
    $headers->{'Content-Type'} = $mimetype;
    my $url = $c->app->fedoraurl->path("$pid/$dsid");
    $c->app->log->debug("PUT $url");
    my $putres = $c->ua->put($url => $self->wrapAtomic($c, $headers) => $location)->result;
    unless ($putres->is_success) {
      $c->app->log->error("pid[$pid] dsid[$dsid] PUT error code:" . $putres->{code} . " message:" . $putres->{message});
      unshift @{$res->{alerts}}, {type => 'error', msg => $putres->{message}};
      $res->{status} = $putres->{code} ? $putres->{code} : 500;
      return $res;
    }

  }

  if ($dscontent) {
    my $headers;
    $headers->{'Content-Type'} = $mimetype;
    if ($checksumtype) {
      $headers->{digest} = "$checksumtype=$checksum";
    }
    my $url = $c->app->fedoraurl->path("$pid/$dsid");
    $c->app->log->debug("PUT $url");
    my $putres = $c->ua->put($url => $self->wrapAtomic($c, $headers) => $dscontent)->result;
    unless ($putres->is_success) {
      $c->app->log->error("pid[$pid] dsid[$dsid] PUT error code:" . $putres->{code} . " message:" . $putres->{message});
      unshift @{$res->{alerts}}, {type => 'error', msg => $putres->{message}};
      $res->{status} = $putres->{code} ? $putres->{code} : 500;
      return $res;
    }
  }

  if ($upload) {
    my $headers;
    $headers->{'Content-Type'}        = $mimetype;
    my $filename = utf8::is_utf8($upload->filename) ? encode('UTF-8', $upload->filename) : $upload->filename;
    $headers->{'Content-Disposition'} = 'attachment; filename="' . $filename . '"';
    if ($checksumtype) {
      $headers->{digest} = "$checksumtype=$checksum";
    }
    my $url = $c->app->fedoraurl->path("$pid/$dsid");
    $c->app->log->debug("PUT $url filename[" . $filename . "] mimetype[$mimetype]");
    my $tx = $c->ua->build_tx(PUT => $url => $self->wrapAtomic($c, $headers));
    $tx->req->content->asset($upload->asset);
    my $putres = $c->ua->start($tx)->result;

    # my $putres = $c->ua->put($url => $headers => $upload->asset)->result;
    unless ($putres->is_success) {
      $c->app->log->error("Cannot create fedora object pid[$pid]: code:" . $putres->{code} . " message:" . $putres->{message});
      unshift @{$res->{alerts}}, {type => 'error', msg => $putres->{message}};
      $res->{status} = $putres->{code} ? $putres->{code} : 500;
      return $res;
    }
  }

  return $res;
}

sub useTransaction {
  my ($self, $c) = @_;

  my $res = {alerts => [], status => 200};
  # return the transaction if available
  if ($c->stash->{transaction_url}) {
    $res->{transaction_id} = $c->stash->{transaction_url};
    return $res;
  }
  my $url = $c->app->fedoraurl->path("fcr:tx");
  my $postres = $c->ua->post($url)->result;
  unless ($postres->is_success) {
    $c->app->log->error("Cannot create transaction: code:" . $postres->{code} . " message:" . $postres->{message});
    unshift @{$res->{alerts}}, {type => 'error', msg => $postres->{message}};
    $res->{status} = $postres->{code} ? $postres->{code} : 500;
    return $res;
  }

  $res->{transaction_id} = $postres->headers->location;
  $c->app->log->debug("Created transaction: ".$res->{transaction_id});

  return $res;
}

sub commitTransaction {
  my ($self, $c) = @_;

  my $res = {alerts => [], status => 200};
  my $atomic_id;
  if ($c->stash->{transaction_url}) {
    $atomic_id = $c->stash->{transaction_url};
    $c->app->log->debug("Save transaction: ".$atomic_id);
    my $putres = $c->ua->put($atomic_id)->result;
    $c->app->log->debug($c->app->dumper($putres));
    unless ($putres->is_success) {
      $c->app->log->error("Cannot save transaction: code:" . $putres->{code} . " message:" . $putres->{message});
      unshift @{$res->{alerts}}, {type => 'error', msg => $putres->{message}};
      $res->{status} = $putres->{code} ? $putres->{code} : 500;
     return $res;
    }
    else {
      # delete the transaction for the hook/update flow
      delete $c->stash->{transaction_url};
    }
  }

  
  return $res;
}


sub wrapAtomic {
  my ($self, $c, $wheaders) = @_;
  my $atomic_id;
  if ($c->stash->{transaction_url}) {
    $atomic_id = $c->stash->{transaction_url};
    $wheaders->{'Atomic-ID'} = $atomic_id;
  }

  return $wheaders;
  }

sub createEmpty {
  my ($self, $c, $username) = @_;

  my $res = {alerts => [], status => 200};

  my $mint = $self->mintPid($c);
  if ($mint->{status} != 200) {
    return $mint;
  }
  my $pid = $mint->{pid};

  my $body = qq|
    \@prefix fedora3: <info:fedora/fedora-system:def/model#>.
    <>
    fedora3:state \"Inactive";
    fedora3:ownerId \"$username\".
  |;

  my $url = $c->app->fedoraurl->path($pid);
  $c->app->log->debug("PUT $url\n$body");
  my $ceheaders = $self->wrapAtomic($c, {'Content-Type' => 'text/turtle', 'Link' => '<http://fedora.info/definitions/v4/repository#ArchivalGroup>;rel="type"'});
  # $c->app->log->debug($c->app->dumper($ceheaders));
  my $putres = $c->ua->put($url => $ceheaders => $body)->result;
  # $c->app->log->debug("Atomic:" . $c->app->dumper($putres));
  unless ($putres->is_success) {
    $c->app->log->error("Cannot create fedora object pid[$pid]: code:" . $putres->{code} . " message:" . $putres->{message});
    unshift @{$res->{alerts}}, {type => 'error', msg => $putres->{message}};
    $res->{status} = $putres->{code} ? $putres->{code} : 500;
    return $res;
  }

  $res->{pid} = $pid;

  return $res;
}

sub delete {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $url = $c->app->fedoraurl->path($pid);
  $c->app->log->debug("DELETE $url");
  my $putres = $c->ua->delete($url)->result;
  unless ($putres->is_success) {
    $c->app->log->error("Cannot delete fedora object pid[$pid]: code:" . $putres->{code} . " message:" . $putres->{message});
    unshift @{$res->{alerts}}, {type => 'error', msg => $putres->{message}};
    $res->{status} = $putres->{code} ? $putres->{code} : 500;
    return $res;
  }
  return $res;
}

sub isDeleted {
  my ($self, $c, $pid) = @_;

  my $url = $c->app->fedoraurl->path($pid);
  $c->app->log->debug("GET $url");
  my $getres = $c->ua->get($url)->result;
  return $getres->{code} == 410;
}

sub mintPid {
  my ($self, $c) = @_;

  my $res = {alerts => [], status => 200};
  my $dbh = $c->app->db_metadata->dbh;
  my $ns  = $c->app->config->{fedora}->{pidnamespace};
  $dbh->do("UPDATE pidGen SET highestID = LAST_INSERT_ID(highestID) + 1 WHERE namespace = '$ns';");
  my $highestID = $dbh->last_insert_id(undef, undef, 'pidGen', 'highestID');
  if (my $msg = $dbh->errstr) {
    $c->app->log->error($msg);
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => $msg};
    return $res;
  }
  $highestID++;
  $res->{pid} = "$ns:$highestID";
  return $res;
}

1;
__END__
