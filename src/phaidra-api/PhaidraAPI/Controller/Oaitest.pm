package PhaidraAPI::Controller::Oaitest;

# based on https://github.com/LibreCat/Dancer-Plugin-Catmandu-OAI

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Switch;
use Data::MessagePack;
use MIME::Base64 qw(encode_base64url decode_base64url);
use DateTime;
use DateTime::Format::ISO8601;
use DateTime::Format::Strptime;
use Clone qw(clone);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::ByteStream qw(b);
use PhaidraAPI::Model::Mappings::Openaire;
use PhaidraAPI::Model::Vocabulary;

my $DEFAULT_LIMIT = 100;

my $VERBS = {
  GetRecord => {
    valid    => {metadataPrefix => 1, identifier => 1},
    required => [qw(metadataPrefix identifier)],
  },
  Identify        => {valid => {}, required => []},
  ListIdentifiers => {
    valid => {
      metadataPrefix  => 1,
      from            => 1,
      until           => 1,
      set             => 1,
      resumptionToken => 1
    },
    required => [qw(metadataPrefix)],
  },
  ListMetadataFormats => {valid => {identifier => 1, resumptionToken => 1}, required => []},
  ListRecords         => {
    valid => {
      metadataPrefix  => 1,
      from            => 1,
      until           => 1,
      set             => 1,
      resumptionToken => 1
    },
    required => [qw(metadataPrefix)],
  },
  ListSets => {valid => {resumptionToken => 1}, required => []},
};

sub _deserialize {
  my ($self, $data) = @_;
  my $mp = Data::MessagePack->new->utf8;
  return $mp->unpack(decode_base64url($data));
}

sub _serialize {
  my ($self, $data) = @_;
  my $mp = Data::MessagePack->new->utf8;
  return encode_base64url($mp->pack($data));
}

sub _epochMsToIso {
  my ($self, $epochms) = @_;
  my $sec = $epochms / 1000;
  my ($s, $m, $h, $D, $M, $Y) = gmtime($sec);
  $M++;
  $Y += 1900;
  return sprintf("%4d-%02d-%02dT%02d:%02d:%02dZ", $Y, $M, $D, $h, $m, $s);
}

sub _get_metadata_dc {
  my ($self, $rec, $set) = @_;
  my @el          = qw/contributor coverage creator date description format identifier language publisher relation rights source subject title type/;
  my %valuesCheck = map {$_ => {}} @el;
  my @metadata;

  my $voc_model = PhaidraAPI::Model::Vocabulary->new;
  my $res = $voc_model->get_vocabulary($self, 'roles');
  my $rolesvoc = $res->{vocabulary};

  # my $isirobject = 0;
  # if (exists($rec->{isinadminset})) {
  #   if (exists($self->config->{ir})) {
  #     if (exists($self->config->{ir}->{adminset})) {
  #       for my $admset (@{$rec->{isinadminset}}) {
  #         if ($admset eq $self->config->{ir}->{adminset}) {
  #           $isirobject = 1;
  #         }
  #       }
  #     }
  #   }
  # }

  if (exists($rec->{bib_publisher})) {
    for my $v (@{$rec->{bib_publisher}}) {
      $valuesCheck{'publisher'}{$v}->{exists} = 1;
    }
    my %field;
    $field{name}   = 'publisher';
    $field{values} = $rec->{bib_publisher};
    push @metadata, \%field;
  }
  if (exists($rec->{bib_published})) {
    for my $v (@{$rec->{bib_published}}) {
      $valuesCheck{'date'}{$v}->{exists} = 1;
    }
    my %field;
    $field{name}   = 'date';
    $field{values} = $rec->{bib_published};
    push @metadata, \%field;
  }
  if (exists($rec->{dcterms_datesubmitted})) {
    for my $v (@{$rec->{dcterms_datesubmitted}}) {
      $valuesCheck{'date'}{$v}->{exists} = 1;
    }
    my %field;
    $field{name}   = 'date';
    $field{values} = $rec->{dcterms_datesubmitted};
    push @metadata, \%field;
  }
  if (exists($rec->{ispartof})) {
    my @ispartofs;
    for my $v (@{$rec->{ispartof}}) {
      my $val  = 'isPartOf:https://' . $self->config->{phaidra}->{baseurl} . '/' . $v;
      my $upid = $v =~ s/:/_/r;
      if (exists($rec->{"title_of_$upid"})) {
        $val .= "[" . $rec->{"title_of_$upid"} . "]";
      }
      push @ispartofs, $val;
    }
    my %field;
    $field{name}   = 'relation';
    $field{values} = \@ispartofs;
    push @metadata, \%field;
  }
  unless (exists($rec->{dc_type_eng})) {
    $rec->{dc_type_eng} = ['other'];
  }

  if (($set eq 'phaidra4primo')) {
    if (exists($rec->{roles_json})) {
      $self->_add_roles_with_id($rolesvoc, $rec, \@metadata);
    } else {
      if (exists($rec->{uwm_roles_json})) {
        $self->_add_uwm_roles_with_id($rolesvoc, $rec, \@metadata);
      }
    }
  }

  for my $k (keys %{$rec}) {
    if ($k =~ m/^dc_([a-z]+)_?([a-z]+)?$/) {
      for my $v (@{$rec->{$k}}) {
        if ($2) {    # there's language, and maybe there was no language before
          $valuesCheck{$1}{$v}->{lang} = $2;    # so save this information so that we can add it later
        }
      }
      my $skip = 0;
      $skip = 1 if ($1 eq 'license');                                                                                            # dc_license is not a dc field, it's in rights
      $skip = 1 if (($set eq 'phaidra4primo') && ($1 eq 'date'));                                                                # bib_published was already added, the rest is not interesting
      $skip = 1 if (($set eq 'phaidra4primo') && (($1 eq 'creator') || ($1 eq 'contributor')));    # we added those already, with IDs
      next if $skip;
      for my $v (@{$rec->{$k}}) {
        $valuesCheck{$1}{$v}->{exists} = 1;
      }
      my %field;
      $field{name} = $1;
      if ($set eq 'phaidra4primo') {
        if ($1 eq 'type') {
          $field{values} = [$self->_map_dc_type($rec, $k)];
        }
      }
      if ($1 eq 'description') {
        if (exists($rec->{isinadminset})) {
          for my $as (@{$rec->{isinadminset}}) {
            if ($as eq $self->app->config->{ir}->{adminset}) {
              $field{values} = ["The abstract is available here: https://" . $self->app->config->{ir}->{baseurl} . "/" . $rec->{pid}];
            }
          }
        }
      }
      unless (exists($field{values})) {
        $field{values} = [];
        my $localdupcheck;
        for my $v (@{$rec->{$k}}) {
          unless ($localdupcheck->{$v}) {
            $v =~ s/^\s+|\s+$//g;
            push @{$field{values}}, $v;
          }
          $localdupcheck->{$v} = 1;
        }
      }
      $field{lang} = $2 if $2;
      push @metadata, \%field;
    }
  }

  for my $f (@metadata) {
    unless ($f->{lang}) {
      for my $v (@{$f->{values}}) {
        if ($valuesCheck{$f->{name}}{$v}->{lang}) {
          $f->{lang} = $valuesCheck{$f->{name}}{$v}->{lang};
        }
      }
    }
  }

  # remove duplicates
  my @u_metadata = ();
  for my $f (@metadata) {
    unless ($self->_already_present($f, \@u_metadata)) {
      push @u_metadata, $f;
    }
  }

  return \@u_metadata;
}

sub _already_present {
  my $self = shift;
  my $fl   = shift;
  my $arr  = shift;

  for my $f (@{$arr}) {
    if ($f->{name} eq $fl->{name} and $f->{lang} eq $fl->{lang}) {
      return 1;
    }
  }
  return 0;
}

sub _get_role_label_de {
  my $self     = shift;
  my $c     = shift;
  my $rolesvoc = shift;
  my $rolecode = shift;

  if ($rolecode eq 'datasupplier') {
    return 'DatenlieferantIn';
  }

  for my $r (@{$rolesvoc}) {
    if ($r->{'@id'} eq 'role:'.$rolecode) {
      return $r->{'skos:prefLabel'}->{'deu'};
    }
  }
}

sub _add_uwm_roles_with_id {
  my $self     = shift;
  my $rolesvoc = shift;
  my $rec      = shift;
  my $metadata = shift;

  my @fields;
  my $arr     = decode_json(b($rec->{uwm_roles_json}[0])->encode('UTF-8'));
  my @contrib = sort {$a->{data_order} <=> $b->{data_order}} @{$arr};
  for my $con (@contrib) {
    my $dcrole;
    if ($PhaidraAPI::Model::Jsonld::Extraction::jsonld_creator_roles{$con->{role}}) {
      $dcrole = 'creator';
    } else {
      $dcrole = 'contributor';
    }

    if ($dcrole && $con->{entities}) {
      my %field;
      $field{name}   = $dcrole;
      $field{values} = [];
      my @entities = sort {$a->{data_order} <=> $b->{data_order}} @{$con->{entities}};
      for my $e (@entities) {
        my $name;
        my $id;
        my $affiliation;
        if ($e->{orcid}) {
          $id = 'orcid:'.$e->{orcid};
        }
        if ($e->{viaf}) {
          $id = ($id ? "$id|" : '') .'viaf:'.$e->{viaf};
        }
        if ($e->{wdq}) {
          $id = ($id ? "$id|" : ''). 'wdq:'.$e->{wdq};
        }
        if ($e->{gnd}) {
          $id = ($id ? "$id|" : ''). 'gnd:'.$e->{gnd};
        }
        if ($e->{isni}) {
          $id = ($id ? "$id|" : ''). 'isni:'.$e->{isni};
        }

        if ($e->{firstname} || $e->{lastname}) {
          $name = $e->{lastname};
          $name = $e->{firstname}.' '.$name if $e->{firstname};
          $affiliation = $e->{institution} if $e->{institution};
        }
        else {
          if ($e->{institution}) {
            $name = $e->{institution};
          }
        }

        unless ($name) {
          # the person/corp is not saved as contribute->entity but it's parts are in multiple entity
          # parts of the contribute node
          # <ns1:contribute seq="0">
          #   <ns1:role>46</ns1:role>
          #   <ns1:entity seq="0">
          #     <ns3:firstname>Firstname</ns3:firstname>
          #     <ns3:lastname>Lastname</ns3:lastname>
          #   </ns1:entity>
          #   <ns1:entity seq="1">
          #     <ns3:type>viaf</ns3:type>
          #     <ns3:viaf>123456789</ns3:viaf>
          #   </ns1:entity>
          #   <ns1:entity seq="2">
          #     <ns3:type>gnd</ns3:type>
          #     <ns3:gnd>123456789</ns3:gnd>
          #   </ns1:entity>
          #   <ns1:entity seq="3">
          #     <ns3:type>orcid</ns3:type>
          #     <ns3:orcid>0000-0000-0000-0000</ns3:orcid>
          #   </ns1:entity>
          #   <ns1:date>2015-09-18</ns1:date>
          # </ns1:contribute>
          # we'll ignore the additional nodes, user would need to fix this in metadata
          next;
        }

        my $role = $name;
        if ($affiliation) {
          $role .= ' (' . $affiliation . ')';
        }
        my $roleLabel = $self->_get_role_label_de($self, $rolesvoc, $con->{role}) || $con->{role};
        $role .= "|hide|[role:$roleLabel]";
        if ($id) {
          $role .= '[' . $id . ']';
        }

        #$self->app->log->debug('adding: ' . $self->app->dumper($role));
        push @{$field{values}}, $role;
      }
      push @fields, \%field;
    }
  }

  $self->app->log->debug('fields: ' . $self->app->dumper(@fields));

  # merge duplicate roles
  my $merging;
  for my $f (@fields) {
    unless (exists($merging->{$f->{name}})) {
      $merging->{$f->{name}} = {
        name => $f->{name},
        values => ()
      }
    }
    for my $v (@{$f->{values}}) {
      push @{$merging->{$f->{name}}->{values}}, $v;
    }
  }

  for my $name (keys %{$merging}) {
    push @{$metadata}, $merging->{$name};
  }

  $self->app->log->debug('md after merging: ' . $self->app->dumper($metadata));

}

sub _add_roles_with_id {
  my $self     = shift;
  my $rolesvoc = shift;
  my $rec      = shift;
  my $metadata = shift;

  my @roles;
  if ($rec->{roles_json}) {
    my $roles_json = decode_json(b($rec->{roles_json}[0])->encode('UTF-8'));
    for my $r (@{$roles_json}) {
      for my $pred (keys %{$r}) {
        my $dcrole;
        if ($PhaidraAPI::Model::Jsonld::Extraction::jsonld_creator_roles{substr($pred, 5)}) {
          $dcrole = 'creator';
        } else {
          $dcrole = 'contributor';
        }

        if ($dcrole) {
          my %field;
          $field{name}   = $dcrole;
          $field{values} = [];
          for my $contr (@{$r->{$pred}}) {
            my $name;
            my $affiliation;
            my $id;
            if ($contr->{'@type'} eq 'schema:Person') {
              if ($contr->{'schema:givenName'} || $contr->{'schema:familyName'}) {
                $name = $contr->{'schema:givenName'}[0]->{'@value'} . " " . $contr->{'schema:familyName'}[0]->{'@value'};
              }
              else {
                $name = $contr->{'schema:name'}[0]->{'@value'};
              }
              if ($contr->{'schema:affiliation'}) {
                for my $aff (@{$contr->{'schema:affiliation'}}) {
                  for my $affname (@{$aff->{'schema:name'}}) {
                    $affiliation = $affname->{'@value'};
                  }
                }
              }
              if ($contr->{'skos:exactMatch'}) {
                $id = $PhaidraAPI::Model::Jsonld::Extraction::jsonld_identifiers{$contr->{'skos:exactMatch'}[0]->{'@type'}} . ':' . $contr->{'skos:exactMatch'}[0]->{'@value'};
              }
            }
            elsif ($contr->{'@type'} eq 'schema:Organization') {
              $name = $contr->{'schema:name'}[0]->{'@value'};
            }

            my $role = $name;
            if ($affiliation) {
              $role .= ' (' . $affiliation . ')';
            }
            my $roleLabel = $self->_get_role_label_de($self, $rolesvoc, substr($pred, 5)) || substr($pred, 5);
            $role .= "|hide|[role:$roleLabel]";
            if ($id) {
              $role .= '[' . $id . ']';
            }

            #$self->app->log->debug('adding: ' . $self->app->dumper($role));
            push @{$field{values}}, $role;
          }
          push @{$metadata}, \%field;
        }
      }
    }
  }
}

sub _map_dc_type {
  my $self = shift;
  my $rec  = shift;
  my $key  = shift;

  my $type = $rec->{$key}[0];

  switch ($rec->{cmodel}) {
    case 'Asset' {
      switch ($rec->{owner}) {
        case 'dlbtrepo2' {
          $type = 'text_resource';
        }
        case 'phaidra1' {
          $type = 'research_dataset'
        }
        case 'sachslf6' {
          $type = 'movingimage'
        }
        case 'reposii5' {
          $type = 'text_resource'
        }
        case 'otolithf' {
          $type = 'research_dataset'
        }
        else {
          $type = 'other';
        }
      }
    }
    case 'Audio' {
      $type = 'audio';
    }
    case 'Book' {
      switch ($rec->{owner}) {
        case 'ondemae7' {    # shouldn't occur
          $type = 'book'
        }
        case 'archiv3' {
          $type = 'book';
        }
        case 'hoenigsc' {
          $type = 'image'
        }
        else {
          $type = 'text_resource';
        }
      }
    }
    case 'Collection' {
      $type = 'collection';
    }
    case 'Container' {
      switch ($rec->{owner}) {
        case 'wandtafelu36' {
          $type = 'image'
        }
        else {
          $type = 'container';
        }
      }
    }
    case 'Paper' {
      $type = 'text_resource';
    }
    case 'PDFDocument' {
      switch ($rec->{dc_type_eng}[0]) {
        case 'article' {
          $type = 'article'
        }
        case 'article in collected edition' {
          $type = 'article';
        }
        case 'baccalaureate Dissertation' {
          $type = 'dissertation';
        }
        case 'book' {
          $type = 'book';
        }
        case 'book Part' {
          $type = 'book_chapter';
        }
        case 'conference Object' {
          $type = 'conference_object';
        }
        case 'diploma Dissertation' {
          $type = 'dissertation';
        }
        case 'dissertation' {
          $type = 'dissertation';
        }
        case 'lecture' {
          $type = 'lecture';
        }
        case 'lecture series (one person)' {
          $type = 'lecture';
        }
        case 'master\'s (Austria) Dissertation' {
          $type = 'dissertation';
        }
        case 'master\'s Dissertation' {
          $type = 'dissertation';
        }
        case 'preprint' {
          $type = 'text_resource';
        }
        case 'professorial Dissertation' {
          $type = 'dissertation';
        }
        case 'report' {
          $type = 'report';
        }
        case 'research Data' {
          $type = 'text_resource';
        }
        case 'review' {
          $type = 'review';
        }
        case 'text' {
          $type = 'text_resource';
        }
        case 'theses' {
          $type = 'dissertation';
        }
        case 'working Paper' {
          $type = 'text_resource';
        }
        case 'other' {
          $type = 'text_resource';
        }
        else {
          $type = 'text_resource';
        }
      }
    }
    case 'Picture' {
      switch ($rec->{resourcetype}) {
        case 'image' {
          $type = 'image'
        }
        case 'map' {
          $type = 'map';
        }
      }
    }
    case 'Resource' {
      $type = 'web_resource';
    }
    case 'Video' {
      $type = 'movingimage';
    }
  }

  return $type;
}

sub _get_metadata {
  my $self           = shift;
  my $rec            = shift;
  my $metadataPrefix = shift;
  my $set            = shift;

  switch ($metadataPrefix) {
    case 'oai_dc' {
      return $self->_get_metadata_dc($rec, $set);
    }
    case 'oai_openaire' {
      my $oaire_model = PhaidraAPI::Model::Mappings::Openaire->new;
      return $oaire_model->get_metadata_openaire($self, $rec);
    }
  }
}

sub handler {
  my $self = shift;

  my $ns            = "oai:" . $self->config->{oai}->{oairepositoryidentifier} . ":";
  my $uri_base      = 'https://' . $self->config->{baseurl} . '/' . $self->config->{basepath} . '/oai';
  my $response_date = DateTime->now->iso8601 . 'Z';
  my $params        = $self->req->params->to_hash;
  my $errors        = [];
  my $set;
  my $sets;
  my $skip     = 0;
  my $pagesize = $self->config->{oai}->{pagesize};
  my $verb     = $params->{'verb'};
  $self->stash(
    uri_base              => $uri_base,
    request_uri           => $uri_base,
    response_date         => $response_date,
    errors                => $errors,
    params                => $params,
    repository_identitier => $self->config->{oai}->{oairepositoryidentifier},
    repository_name       => $self->config->{oai}->{repositoryname},
    ns                    => $ns,
    adminemail            => $self->config->{adminemail}
  );

  if ($verb and my $spec = $VERBS->{$verb}) {
    my $valid    = $spec->{valid};
    my $required = $spec->{required};

    if ($valid->{resumptionToken} and exists $params->{resumptionToken}) {
      if (keys(%$params) > 2) {
        push @$errors, [badArgument => "resumptionToken cannot be combined with other parameters"];
      }
    }
    else {
      for my $key (keys %$params) {
        next if $key eq 'verb';
        unless ($valid->{$key}) {
          unless (($key eq 'set') && ($params->{$key} eq 'phaidra4primo')) {
            push @$errors, [badArgument => "parameter $key is illegal"];
          }
        }
      }
      for my $key (@$required) {
        unless (exists $params->{$key}) {
          push @$errors, [badArgument => "parameter $key is missing"];
        }
      }
    }
  }
  else {
    push @$errors, [badVerb => "illegal OAI verb"];
  }

  if (@$errors) {
    $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
    return;
  }

  my $token;
  if (exists $params->{resumptionToken}) {
    if ($verb eq 'ListSets') {
      push @$errors, [badResumptionToken => "resumptionToken isn't necessary"];
    }
    else {
      eval {
        $token                    = $self->_deserialize($params->{resumptionToken});
        $params->{set}            = $token->{_s} if defined $token->{_s};
        $params->{from}           = $token->{_f} if defined $token->{_f};
        $params->{until}          = $token->{_u} if defined $token->{_u};
        $params->{metadataPrefix} = $token->{_m} if defined $token->{_m};
        $skip                     = $token->{_n} if defined $token->{_n};
        $self->stash(token => $token);
      };
      if ($@) {
        push @$errors, [badResumptionToken => "resumptionToken is not in the correct format"];
      }
    }
  }

  if (exists $params->{set} || ($verb eq 'ListSets')) {
    my $mongosets = $self->mongo->get_collection('oai_sets')->find();
    while (my $s = $mongosets->next) {
      $sets->{$s->{setSpec}} = $s;
    }
    unless ($sets) {
      push @$errors, [noSetHierarchy => "sets are not supported"];
    }
    if (exists $params->{set}) {
      unless ($set = $sets->{$params->{set}}) {
        push @$errors, [badArgument => "set does not exist"];
      }
    }
  }

  if (exists $params->{metadataPrefix}) {
    if ($params->{metadataPrefix} eq 'oai_dc' || ($params->{metadataPrefix} eq 'oai_openaire')) {
      $self->stash(metadataPrefix => $params->{metadataPrefix});
    }
    else {
      push @$errors, [cannotDisseminateFormat => "metadataPrefix $params->{metadataPrefix} is not supported"];
    }
  }

  if (@$errors) {
    $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
    return;
  }

  if ($verb eq 'GetRecord') {
    my $id = $params->{identifier};
    $id =~ s/^$ns//;

    my $rec = $self->mongo->get_collection('oai_records')->find_one({"pid" => $id});
    if (defined $rec) {
      $rec->{updated} = $self->_epochMsToIso($rec->{updated});
      $self->stash(r => $rec, metadata => $self->_get_metadata($rec, $params->{metadataPrefix}, $params->{set}));
      $self->render(template => 'oai/get_record', format => 'xml', handler => 'ep');
      return;
    }
    push @$errors, [idDoesNotExist => "identifier " . $params->{identifier} . " is unknown or illegal"];
    $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
    return;

  }
  elsif ($verb eq 'Identify') {
    my $earliestDatestampSec = 0;                                                                                   # 1970-01-01T00:00:01Z
    my $earliestDatestampStr = '1970-01-01T00:00:01Z';
    my $rec                  = $self->mongo->get_collection('oai_records')->find()->sort({"updated" => 1})->next;
    if ($rec) {
      $earliestDatestampStr = $self->_epochMsToIso($rec->{inserted});
    }
    $self->stash(earliest_datestamp => $earliestDatestampStr);
    $self->render(template => 'oai/identify', format => 'xml', handler => 'ep');
    return;

  }
  elsif ($verb eq 'ListIdentifiers' || $verb eq 'ListRecords') {
    my $from           = $params->{from};
    my $until          = $params->{until};
    my $metadataPrefix = $params->{metadataPrefix};

    for my $datestamp (($from, $until)) {
      $datestamp || next;
      if ($datestamp !~ /^\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2}Z)?$/) {
        push @$errors, [badArgument => "datestamps must have the format YYYY-MM-DD or YYYY-MM-DDThh:mm:ssZ"];
        $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
        return;
      }
    }

    if ($from && $until && length($from) != length($until)) {
      push @$errors, [badArgument => "datestamps must have the same granularity"];
      $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
      return;
    }

    if ($from && $until && $from gt $until) {
      push @$errors, [badArgument => "from is more recent than until"];
      $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
      return;
    }

    if ($from && length($from) == 10) {
      $from = "${from}T00:00:00Z";
    }
    if ($until && length($until) == 10) {
      $until = "${until}T23:59:59Z";
    }

    my %filter;

    if ($from or $until) {
      $filter{"updated"} = {};
    }

    if ($from) {
      $filter{"updated"}->{'$gte'} = DateTime::Format::ISO8601->parse_datetime($from)->epoch * 1000;
    }

    if ($until) {
      $filter{"updated"}->{'$lte'} = DateTime::Format::ISO8601->parse_datetime($until)->epoch * 1000;
    }

    if ($params->{set}) {
      $filter{"setSpec"} = $params->{set};
    }

    my $total = $self->mongo->get_collection('oai_records')->count(\%filter);
    if ($total eq 0) {
      push @$errors, [noRecordsMatch => "no records found"];
      $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
      return;
    }
    $self->stash(total => $total);

    my $cursor  = $self->mongo->get_collection('oai_records')->find(\%filter)->sort({"updated" => -1})->limit($pagesize)->skip($skip);
    my @records = ();
    while (my $rec = $cursor->next) {
      if ($verb eq 'ListIdentifiers') {
        $rec->{updated} = $self->_epochMsToIso($rec->{updated});
        push @records, {r => $rec};
      }
      else {
        $rec->{updated} = $self->_epochMsToIso($rec->{updated});
        push @records, {r => $rec, metadata => $self->_get_metadata($rec, $metadataPrefix, $params->{set})};
      }
    }
    $self->stash(records => \@records);

    if (($total > $pagesize) && (($skip + $pagesize) < $total)) {
      my $t;
      $t->{_n} = $skip + $pagesize;
      $t->{_s} = $set->{setSpec} if defined $set;
      $t->{_f} = $from           if defined $from;
      $t->{_u} = $until          if defined $until;
      $t->{_m} = $metadataPrefix if defined $metadataPrefix;
      $self->stash(resumption_token => $self->_serialize($t));
    }
    else {
      $self->stash(resumption_token => undef);
    }

    $self->app->log->debug("oai list response: verb[$verb] skip[$skip] pagesize[$pagesize] total[$total] from[$from] until[$until] set[" . $set->{setSpec} . "] restoken[" . $self->stash('resumption_token') . "]");

    if ($verb eq 'ListIdentifiers') {
      $self->render(template => 'oai/list_identifiers', format => 'xml', handler => 'ep');
    }
    else {
      $self->render(template => 'oai/list_records', format => 'xml', handler => 'ep');
    }

  }
  elsif ($verb eq 'ListMetadataFormats') {

    if (my $id = $params->{identifier}) {
      $id =~ s/^$ns//;
      my $rec = $self->mongo->get_collection('oai_records')->find_one({"pid" => $id});
      unless (defined $rec) {
        push @$errors, [idDoesNotExist => "identifier " . $params->{identifier} . " is unknown or illegal"];
        $self->render(template => 'oai/error', format => 'xml', handler => 'ep');
        return;
      }
    }
    $self->render(template => 'oai/list_metadata_formats', format => 'xml', handler => 'ep');
    return;

  }
  elsif ($verb eq 'ListSets') {
    for my $setSpec (keys %{$sets}) {
      $sets->{$setSpec}->{metadata} = $self->_get_metadata($sets->{$setSpec}->{setDescription}, 'oai_dc');
    }
    $self->stash(sets => $sets);
    $self->render(template => 'oai/list_sets', format => 'xml', handler => 'ep');
    return;
  }
}

1;
