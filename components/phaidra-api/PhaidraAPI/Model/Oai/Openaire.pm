package PhaidraAPI::Model::Oai::Openaire;

use strict;
use warnings;
use v5.10;
use utf8;
use Switch;
use Mojo::JSON qw(encode_json decode_json);
use Mojo::ByteStream qw(b);
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Languages;

my $resourceTypesToDownload = {
  'http://purl.org/coar/resource_type/c_18cc' => 1,    # sound
  'http://purl.org/coar/resource_type/c_18cf' => 1,    # text
  'http://purl.org/coar/resource_type/c_6501' => 1,    # journal article
  'http://purl.org/coar/resource_type/c_c513' => 1,    # image
  'http://purl.org/coar/resource_type/c_12ce' => 1     # video
};

my $relations = {
  'references'             => 'References',
  'isbacksideof'           => 'Continues',
  'hassuccessor'           => 'IsPreviousVersionOf',
  'isalternativeformatof'  => 'IsVariantFormOf',
  'isalternativeversionof' => 'IsVersionOf',
  'ispartof'               => 'IsPartOf'
};

my $openaireContributorType = {

  # ContactPerson
  # DataCollector
  # DataCurator
  dtm => "DataManager",
  dst => "Distributor",
  edt => "Editor",
  his => "HostingInstitution",
  pro => "Producer",
  pdr => "ProjectLeader",

  # Project director
  # ProjectManager
  # ProjectMember
  # RegistrationAgency
  # RegistrationAuthority
  # RelatedPerson
  res => "Researcher",

  # ResearchGroup
  # RightsHolder
  spn => "Sponsor"

    # Supervisor
    # WorkPackageLeader
    # Other < all unmapped contributor roles
};

sub _get_roles_uwm {
  my ($self, $c, $str) = @_;

  my @roles;

  my $arr     = decode_json(b($str)->encode('UTF-8'));
  my @contrib = sort {$a->{data_order} <=> $b->{data_order}} @{$arr};
  for my $con (@contrib) {
    if ($con->{entities}) {
      my @entities = sort {$a->{data_order} <=> $b->{data_order}} @{$con->{entities}};
      for my $e (@entities) {
        my %role;
        my @ids;
        my @affiliations;
        my $roleCode = $con->{role};
        next if $roleCode eq 'uploader';
        switch ($roleCode) {
          case 'aut' {
            $role{dcRole} = 'creator';
          }
          case 'pbl' {
            $role{dcRole} = 'publisher';
          }
          else {
            $role{dcRole}          = 'contributor';
            $role{contributorType} = exists($openaireContributorType->{$roleCode}) ? $openaireContributorType->{$roleCode} : 'Other';
          }
        }

        if ($e->{orcid}) {
          push @ids,
            {
            nameIdentifier       => $e->{orcid},
            nameIdentifierScheme => 'ORCID',
            schemeURI            => 'https://orcid.org/'
            };
        }
        if ($e->{gnd}) {
          push @ids,
            {
            nameIdentifier       => $e->{gnd},
            nameIdentifierScheme => 'GND',
            schemeURI            => 'https://d-nb.info/gnd/'
            };
        }
        if ($e->{isni}) {
          push @ids,
            {
            nameIdentifier       => $e->{isni},
            nameIdentifierScheme => 'ISNI',
            schemeURI            => 'http://isni.org/isni/'
            };
        }
        if ($e->{viaf}) {
          push @ids,
            {
            nameIdentifier       => $e->{viaf},
            nameIdentifierScheme => 'VIAF',
            schemeURI            => 'https://viaf.org/viaf/'
            };
        }
        if ($e->{wdq}) {
          push @ids,
            {
            nameIdentifier       => $e->{wdq},
            nameIdentifierScheme => 'Wikidata',
            schemeURI            => 'https://www.wikidata.org/wiki/'
            };
        }
        if ($e->{lcnaf}) {
          push @ids,
            {
            nameIdentifier       => $e->{lcnaf},
            nameIdentifierScheme => 'LCNAF',
            schemeURI            => 'https://id.loc.gov/authorities/names/'
            };
        }

        if ($e->{firstname} || $e->{lastname}) {
          $role{nameType} = 'Personal';
          $role{name}     = $e->{lastname};
          $role{name} .= ($e->{lastname} ? ', ' : '') . $e->{firstname} if $e->{firstname};
          $role{givenName}  = $e->{firstname};
          $role{familyName} = $e->{lastname};
          push @affiliations, $e->{institution} if $e->{institution};
          $role{affiliations} = \@affiliations if (scalar @affiliations > 0);
        }
        else {
          if ($e->{institution}) {
            $role{nameType} = 'Organizational';
            $role{name}     = $e->{institution};
          }
        }
        $role{nameIdentifiers} = \@ids;
        push @roles, \%role;
      }
    }
  }

  return \@roles;
}

sub _get_roles {
  my ($self, $c, $str) = @_;

  my @roles;

  my $arr = decode_json(b($str)->encode('UTF-8'));

  # $c->app->log->debug("XXXXXXXXXXX arr:\n".$c->app->dumper($arr));
  for my $hash (@{$arr}) {
    for my $rolePredicate (keys %{$hash}) {
      for my $e (@{$hash->{$rolePredicate}}) {
        my %role;
        my $firstname;
        my $lastname;
        my @affiliations;
        my $name;
        my @ids;
        my $roleCode = $rolePredicate;
        $roleCode =~ s/^role://g;
        next if $roleCode eq 'uploader';
        switch ($roleCode) {
          case 'aut' {
            $role{dcRole} = 'creator';
          }
          case 'pbl' {
            $role{dcRole} = 'publisher';
          }
          else {
            $role{dcRole}          = 'contributor';
            $role{contributorType} = exists($openaireContributorType->{$roleCode}) ? $openaireContributorType->{$roleCode} : 'Other';
          }
        }
        for my $prop (keys %{$e}) {
          if ($prop eq '@type') {
            if ($e->{$prop} eq 'schema:Person') {
              $role{nameType} = 'Personal';
            }
            if ($e->{$prop} eq 'schema:Organization') {
              $role{nameType} = 'Organizational';
            }
          }
          if ($prop eq 'schema:givenName') {
            for my $v (@{$e->{$prop}}) {
              $firstname = $v->{'@value'};
            }
          }
          if ($prop eq 'schema:familyName') {
            for my $v (@{$e->{$prop}}) {
              $lastname = $v->{'@value'};
            }
          }
          if ($prop eq 'schema:name') {
            for my $v (@{$e->{$prop}}) {
              $name = $v->{'@value'};
            }
          }
          if ($prop eq 'skos:exactMatch') {
            for my $id (@{$e->{$prop}}) {
              if (ref($id) eq 'HASH') {
                if ($id->{'@type'} eq 'ids:orcid') {
                  push @ids,
                    {
                    nameIdentifier       => $id->{'@value'},
                    nameIdentifierScheme => 'ORCID',
                    schemeURI            => 'https://orcid.org/'
                    };
                }
                if ($id->{'@type'} eq 'ids:gnd') {
                  push @ids,
                    {
                    nameIdentifier       => $id->{'@value'},
                    nameIdentifierScheme => 'GND',
                    schemeURI            => 'https://d-nb.info/gnd/'
                    };
                }
                if ($id->{'@type'} eq 'ids:isni') {
                  push @ids,
                    {
                    nameIdentifier       => $id->{'@value'},
                    nameIdentifierScheme => 'ISNI',
                    schemeURI            => 'http://isni.org/isni/'
                    };
                }
                if ($id->{'@type'} eq 'ids:viaf') {
                  push @ids,
                    {
                    nameIdentifier       => $id->{'@value'},
                    nameIdentifierScheme => 'VIAF',
                    schemeURI            => 'https://viaf.org/viaf/'
                    };
                }
                if ($id->{'@type'} eq 'ids:wikidata') {
                  push @ids,
                    {
                    nameIdentifier       => $id->{'@value'},
                    nameIdentifierScheme => 'Wikidata',
                    schemeURI            => 'https://www.wikidata.org/wiki/'
                    };
                }
                if ($id->{'@type'} eq 'ids:lcnaf') {
                  push @ids,
                    {
                    nameIdentifier       => $id->{'@value'},
                    nameIdentifierScheme => 'LCNAF',
                    schemeURI            => 'https://id.loc.gov/authorities/names/'
                    };
                }
              }
            }
          }

          if ($prop eq 'schema:affiliation') {
            my %affs;
            my $addInstitutionName = 0;
            for my $aff (@{$e->{'schema:affiliation'}}) {
              for my $affProp (keys %{$aff}) {
                if ($affProp eq 'skos:exactMatch') {
                  for my $affId (@{$aff->{'skos:exactMatch'}}) {
                    if (rindex($affId, 'https://pid.phaidra.org/', 0) == 0) {
                      $addInstitutionName = 1;
                    }
                  }
                }
                if ($affProp eq 'schema:name') {
                  for my $affName (@{$aff->{'schema:name'}}) {
                    if (exists($affName->{'@language'})) {
                      if ($affName->{'@language'} ne '') {
                        $affs{$affName->{'@language'}} = $affName->{'@value'};
                      }
                      else {
                        $affs{'nolang'} = $affName->{'@value'};
                      }
                    }
                    else {
                      $affs{'nolang'} = $affName->{'@value'};
                    }
                  }
                }
              }
            }

            # https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publisher.html
            # I think this should apply to affiliations of creators and contributors too:
            # "With university publications place the name of the faculty and/or research group or research school
            # after the name of the university. In the case of organizations where there is clearly a hierarchy present,
            # list the parts of the hierarchy from largest to smallest, separated by full stops."

            # prefer version without language
            if ($affs{'nolang'}) {
              push @affiliations, $affs{'nolang'};
            }
            else {
              # if not found, prefer english
              if ($affs{'eng'}) {
                my $affiliation = $affs{'eng'};
                if ($addInstitutionName) {
                  my $institutionName = $c->app->directory->get_org_name($c, 'eng');
                  if ($institutionName) {
                    if ((index($affiliation, $institutionName) == -1)) {
                      $affiliation = "$institutionName. $affiliation";
                    }
                  }
                }
                push @affiliations, $affiliation if $affiliation;
              }
              else {
                # if not found just pop whatever
                my $affiliation;
                for my $affLang (keys %affs) {
                  $affiliation = $affs{$affLang};
                  if ($addInstitutionName) {
                    my $institutionName = $c->app->directory->get_org_name($c, $affLang);
                    if ($institutionName) {
                      if ((index($affiliation, $institutionName) == -1)) {
                        $affiliation = "$institutionName. $affiliation";
                      }
                    }
                  }
                  last;
                }
                push @affiliations, $affiliation if $affiliation;
              }
            }
          }
        }
        if ($role{nameType} eq 'Personal') {
          if ($name) {
            $role{name} = $name;
          }
          else {
            $role{name} = $lastname;
            $role{name} .= ($lastname ? ', ' : '') . $firstname if $firstname;
          }
          $role{givenName}    = $firstname;
          $role{familyName}   = $lastname;
          $role{affiliations} = \@affiliations if (scalar @affiliations > 0);
        }
        else {
          $role{name} = $name;
        }
        $role{nameIdentifiers} = \@ids;

        push @roles, \%role;
      }
    }
  }

  #$c->app->log->debug("XXXXXXXXXXX roles:\n".$c->app->dumper(\@roles));
  return \@roles;
}

sub _get_funding_references {
  my ($self, $c, $str) = @_;

  my @fundingReferences;

  my $arr = decode_json(b($str)->encode('UTF-8'));
  for my $obj (@$arr) {
    my $funderName;
    my $awardTitle;
    my $awardNumber;
    if ($obj->{'@type'} eq 'foaf:Project') {
      if (exists($obj->{'skos:prefLabel'})) {
        for my $l (@{$obj->{'skos:prefLabel'}}) {
          $awardTitle = $l->{'@value'};
          last;
        }
      }
      if (exists($obj->{'skos:exactMatch'})) {
        for my $id (@{$obj->{'skos:exactMatch'}}) {
          $awardNumber = $id;
          last;
        }
      }
      if (exists($obj->{'frapo:hasFundingAgency'})) {
        for my $fun (@{$obj->{'frapo:hasFundingAgency'}}) {
          if (exists($fun->{'skos:prefLabel'})) {
            for my $l (@{$fun->{'skos:prefLabel'}}) {
              $funderName = $l->{'@value'};
              last;
            }
          }
        }
      }
    }
    if ($obj->{'@type'} eq 'frapo:FundingAgency') {
      if (exists($obj->{'skos:prefLabel'})) {
        for my $l (@{$obj->{'skos:prefLabel'}}) {
          $funderName = $l->{'@value'};
          last;
        }
      }
    }
    my %ref;
    $ref{funderName}  = $funderName  if $funderName;
    $ref{awardTitle}  = $awardTitle  if $awardTitle;
    $ref{awardNumber} = $awardNumber if $awardNumber;
    push @fundingReferences, \%ref;
  }
  return \@fundingReferences;
}

sub _rolesToNodes {
  my ($self, $c, $type, $roles) = @_;

  my @roleNodes;
  for my $role (@$roles) {
    my @childNodes;
    my %nameNode;
    $nameNode{name}  = $type eq 'creator' ? 'datacite:creatorName' : 'datacite:contributorName';
    $nameNode{value} = $role->{name};
    if ($role->{nameType}) {
      $nameNode{attributes} = [
        { name  => 'nameType',
          value => $role->{nameType}
        }
      ];
    }
    push @childNodes, \%nameNode;
    if ($role->{givenName}) {
      push @childNodes,
        {
        name  => 'datacite:givenName',
        value => $role->{givenName}
        };
    }
    if ($role->{familyName}) {
      push @childNodes,
        {
        name  => 'datacite:familyName',
        value => $role->{familyName}
        };
    }
    for my $id (@{$role->{nameIdentifiers}}) {
      push @childNodes,
        {
        name       => 'datacite:nameIdentifier',
        value      => $id->{nameIdentifier},
        attributes => [
          { name  => 'nameIdentifierScheme',
            value => $id->{nameIdentifierScheme}
          },
          { name  => 'schemeURI',
            value => $id->{schemeURI}
          }
        ]
        };
    }
    for my $aff (@{$role->{affiliations}}) {
      push @childNodes,
        {
        name  => 'datacite:affiliation',
        value => $aff
        };
    }
    my %roleNode;
    $roleNode{name}     = $type eq 'creator' ? 'datacite:creator' : 'datacite:contributor';
    $roleNode{children} = \@childNodes;
    if ($role->{contributorType}) {
      $roleNode{attributes} = [
        { name  => 'contributorType',
          value => $role->{contributorType}
        }
      ];
    }
    push @roleNodes, \%roleNode;
  }
  return \@roleNodes;
}

sub _map_iso3_to_bcp {
  my ($self, $iso6393ToBCP, $lang) = @_;
  return exists($iso6393ToBCP->{$lang}) ? $iso6393ToBCP->{$lang} : $lang;
}

sub _get_dc_fields {
  my ($self, $c, $iso6393ToBCP, $rec, $dcfield, $targetfield) = @_;

  my @nodes;
  my %foundValues;
  for my $k (keys %{$rec}) {
    if ($k =~ m/^dc_$dcfield\_([a-z]+)$/) {
      my $lang = $1;
      for my $v (@{$rec->{$k}}) {
        $foundValues{$v} = 1;
        my %node;
        $node{name}  = $targetfield;
        $node{value} = $v;
        unless ($lang eq 'xxx') {
          $node{attributes} = [
            { name  => 'xml:lang',
              value => $self->_map_iso3_to_bcp($iso6393ToBCP, $lang)
            }
          ];
        }
        push @nodes, \%node;
      }
    }
  }
  for my $k (keys %{$rec}) {
    if ($k =~ m/^dc_$dcfield$/) {
      for my $v (@{$rec->{$k}}) {
        unless ($foundValues{$v}) {
          push @nodes,
            {
            name  => $targetfield,
            value => $v
            };
        }
      }
    }
  }
  return \@nodes;
}

sub _bytes_string {
  my ($self, $bytes) = @_;
  return "" if (!defined($bytes));
  my @suffixes = ('B', 'kB', 'MB', 'GB', 'TB', 'EB');
  while ($bytes > 1024) {
    shift @suffixes;
    $bytes /= 1024;
  }
  return sprintf("%.2f %s", $bytes, shift @suffixes);
}

sub get_metadata_openaire {
  my ($self, $c, $rec) = @_;

  # pretend you don't see this
  my $lang_model   = PhaidraAPI::Model::Languages->new;
  my %iso6393ToBCP = reverse %{$lang_model->get_iso639map()};

  my @metadata;

  #### MANDATORY ####

  # Resource Identifier (M)
  # datacite:identifier
  push @metadata,
    {
    name       => 'datacite:identifier',
    value      => 'https://' . $c->app->config->{phaidra}->{baseurl} . '/' . $rec->{pid},
    attributes => [
      { name  => 'identifierType',
        value => 'URL'
      }
    ]
    };

  # Title (M)
  # datacite:title
  my $titles = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'title', 'datacite:title');
  push @metadata,
    {
    name     => 'datacite:titles',
    children => $titles
    };

  # Creator (M)
  # datacite:creator
  # creator = author
  #
  # Contributor (MA)
  # datacite:contributor
  # contributor = not author, not publisher, not uploader
  #
  # Publisher (MA)
  # dc:publisher
  # publisher = role publisher or bib_publisher
  my $roles;
  if (exists($rec->{roles_json})) {
    for my $roles_json_str (@{$rec->{roles_json}}) {
      $roles = $self->_get_roles($c, $roles_json_str);
      last;
    }
  }
  else {
    if (exists($rec->{uwm_roles_json})) {
      for my $uwm_roles_json_str (@{$rec->{uwm_roles_json}}) {
        $roles = $self->_get_roles_uwm($c, $uwm_roles_json_str);
        last;
      }
    }
  }
  my @creators     = ();
  my @contributors = ();
  my @publishers   = ();
  for my $role (@$roles) {
    switch ($role->{dcRole}) {
      case 'creator' {
        push @creators, $role;
      }
      case 'contributor' {
        push @contributors, $role;
      }
      case 'publisher' {
        push @publishers, $role;
      }
    }
  }

  push @metadata,
    {
    name     => 'datacite:creators',
    children => $self->_rolesToNodes($c, 'creator', \@creators)
    } if (scalar @creators > 0);
  push @metadata,
    {
    name     => 'datacite:contributors',
    children => $self->_rolesToNodes($c, 'contributor', \@contributors)
    } if (scalar @contributors > 0);

  if (scalar @publishers < 1) {

    # push bib_publisher
    if ($rec->{bib_publisher}) {
      for my $pub (@{$rec->{bib_publisher}}) {
        push @metadata,
          {
          name  => 'dc:publisher',
          value => $pub
          };
      }
    }
  }
  else {
    for my $pub (@publishers) {
      push @metadata,
        {
        name  => 'dc:publisher',
        value => $pub->{name}
        };
    }
  }

  # Publication Date (M)
  # datacite:date
  # Embargo Period Date (MA)
  # datacite:date
  my @dates;
  if (exists($rec->{bib_published})) {
    for my $pubDate (@{$rec->{bib_published}}) {
      push @dates,
        {
        name       => 'datacite:date',
        value      => $pubDate,
        attributes => [
          { name  => 'dateType',
            value => 'Issued'
          }
        ]
        };
    }
  }
  else {
    if (exists($rec->{dcterms_datesubmitted})) {
      for my $pubDate (@{$rec->{dcterms_datesubmitted}}) {
        push @dates,
          {
          name       => 'datacite:date',
          value      => $pubDate,
          attributes => [
            { name  => 'dateType',
              value => 'Issued'
            }
          ]
          };
      }
    }
    else {
      if (exists($rec->{created})) {
        push @dates,
          {
          name       => 'datacite:date',
          value      => substr($rec->{created}, 0, 4),
          attributes => [
            { name  => 'dateType',
              value => 'Issued'
            }
          ]
          };
      }
      else {
        $c->app->log->error("oai: could not find 'created' date in solr record pid[$rec->{pid}]");
      }
    }
  }
  if (exists($rec->{dcterms_available})) {
    push @dates,
      {
      name       => 'datacite:date',
      value      => $rec->{dcterms_available},
      attributes => [
        { name  => 'dateType',
          value => 'Available'
        }
      ]
      };
  }

  # Resource Type (M)
  # oaire:resourceType
  my $resourceTypeURI     = '';
  my $resourceTypeGeneral = '';
  my $downloadObjectType  = '';
  if ($rec->{resourcetype}) {
    my $resourcetype = '';
    switch ($rec->{resourcetype}) {
      case 'sound' {
        $resourceTypeGeneral = 'dataset';
        $downloadObjectType  = 'dataset';
        $resourcetype        = 'sound';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_18cc';
      }
      case 'book' {
        $resourceTypeGeneral = 'literature';
        $resourcetype        = 'book';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_2f33';
      }
      case 'collection' {    # this should likely not end up in oaiprovider at all
        $resourceTypeGeneral = 'dataset';
        $resourcetype        = 'other';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_1843';
      }
      case 'dataset' {
        $resourceTypeGeneral = 'dataset';
        $resourcetype        = 'dataset';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_ddb1';
      }
      case 'text' {
        $resourceTypeGeneral = 'literature';
        $downloadObjectType  = 'fulltext';
        $resourcetype        = 'text';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_18cf';
      }
      case 'journalarticle' {
        $resourceTypeGeneral = 'literature';
        $downloadObjectType  = 'fulltext';
        $resourcetype        = 'journal article';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_6501';
      }
      case 'image' {
        $resourceTypeGeneral = 'dataset';
        $resourcetype        = 'image';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_c513';
      }
      case 'map' {
        $resourceTypeGeneral = 'dataset';
        $resourcetype        = 'map';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_12cd';
      }
      case 'interactiveresource' {
        $resourceTypeGeneral = 'other research product';
        $resourcetype        = 'interactive resource';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_e9a0';
      }
      case 'video' {
        $resourceTypeGeneral = 'dataset';
        $downloadObjectType  = 'dataset';
        $resourcetype        = 'video';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_12ce';
      }
      else {
        $resourceTypeGeneral = 'other research product';
        $resourcetype        = 'other';
        $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_1843';
      }
    }
    if (exists($rec->{edm_hastype_id})) {
      for my $edmType (@{$rec->{edm_hastype_id}}) {
        if ($edmType eq 'https://pid.phaidra.org/vocabulary/VKA6-9XTY') {
          $resourceTypeGeneral = 'literature';
          $resourcetype        = 'journal article';
          $resourceTypeURI     = 'http://purl.org/coar/resource_type/c_6501';
        }
        last;
      }
    }
    push @metadata,
      {
      name       => 'resourceType',
      value      => $resourcetype,
      attributes => [
        { name  => 'resourceTypeGeneral',
          value => $resourceTypeGeneral
        },
        { name  => 'uri',
          value => $resourceTypeURI
        }
      ]
      };

  }

  # Access Rights (M)
  # datacite:rights
  my $rights    = '';
  my $rightsURI = '';
  for my $dcRights (@{$rec->{dc_rights}}) {

    # legacy mapping
    switch ($dcRights) {
      case 'openAccess' {
        $rights    = 'open access';
        $rightsURI = 'http://purl.org/coar/access_right/c_abf2';
      }
      case 'embargoedAccess' {
        $rights    = 'embargoed access';
        $rightsURI = 'http://purl.org/coar/access_right/c_f1cf';
      }
      case 'restrictedAccess' {
        $rights    = 'restricted access';
        $rightsURI = 'http://purl.org/coar/access_right/c_16ec';
      }
      case 'closedAccess' {
        $rights    = 'metadata only accesss';
        $rightsURI = 'http://purl.org/coar/access_right/c_14cb';
      }
    }
  }
  for my $dcRightsId (@{$rec->{dcterms_accessrights_id}}) {
    switch ($dcRightsId) {
      case 'https://pid.phaidra.org/vocabulary/QW5R-NG4J' {
        $rights    = 'open access';
        $rightsURI = 'http://purl.org/coar/access_right/c_abf2';
      }
      case 'https://pid.phaidra.org/vocabulary/AVFC-ZZSZ' {
        $rights    = 'embargoed access';
        $rightsURI = 'http://purl.org/coar/access_right/c_f1cf';
      }
      case 'https://pid.phaidra.org/vocabulary/KC3K-CCGM' {
        $rights    = 'restricted access';
        $rightsURI = 'http://purl.org/coar/access_right/c_16ec';
      }
      case 'https://pid.phaidra.org/vocabulary/QNGE-V02H' {
        $rights    = 'metadata only accesss';
        $rightsURI = 'http://purl.org/coar/access_right/c_14cb';
      }
    }
  }
  push @metadata,
    {
    name       => 'datacite:rights',
    value      => $rights,
    attributes => [
      { name  => 'rightsURI',
        value => $rightsURI
      }
    ]
    } if $rights;

  #### MANDATORY IF AVAILABLE ####

  # Funding Reference (MA)
  # oaire:fundingReference
  my @refs;
  my @refNodes;
  my $fundRefsProj;
  if (exists($rec->{frapo_isoutputof_json})) {
    for my $isoutputof (@{$rec->{frapo_isoutputof_json}}) {
      $fundRefsProj = $self->_get_funding_references($c, $isoutputof);
      last;
    }
  }
  for my $ref (@{$fundRefsProj}) {
    push @refs, $ref;
  }
  my $fundRefsFun;
  if (exists($rec->{frapo_hasfundingagency_json})) {
    for my $hasfundingagency (@{$rec->{frapo_hasfundingagency_json}}) {
      $fundRefsFun = $self->_get_funding_references($c, $hasfundingagency);
      last;
    }
  }
  for my $ref (@{$fundRefsFun}) {
    push @refs, $ref;
  }
  if (exists($rec->{uwm_funding})) {
    for my $funding (@{$rec->{uwm_funding}}) {
      my @fundarr = split(':', $funding);
      if (scalar @fundarr > 1) {
        my $num = $fundarr[1];
        $num =~ s/^\s//g;
        my $ref = {
          funderName  => $fundarr[0],
          awardNumber => $num
        };
        push @refs, $ref;
      }
      else {
        if ($fundarr[0]) {
          my $ref = {awardNumber => $fundarr[0]};
          push @refs, $ref;
        }
      }
    }
  }
  for my $ref (@refs) {
    my %refNode;
    $refNode{name} = 'fundingReference';
    my @refNodeChildren;
    if ($ref->{funderName}) {
      push @refNodeChildren,
        {
        name  => 'funderName',
        value => $ref->{funderName}
        };
    }
    if ($ref->{awardTitle}) {
      push @refNodeChildren,
        {
        name  => 'awardTitle',
        value => $ref->{awardTitle}
        };
    }
    if ($ref->{awardNumber}) {
      push @refNodeChildren,
        {
        name  => 'awardNumber',
        value => $ref->{awardNumber}
        };
    }
    $refNode{children} = \@refNodeChildren if (scalar @refNodeChildren > 0);
    push @refNodes, \%refNode;
  }
  if (scalar @refNodes > 0) {
    push @metadata,
      {
      name     => 'fundingReferences',
      children => \@refNodes
      };
  }

  # Language (MA)
  # dc:language
  for my $lang (@{$rec->{dc_language}}) {
    push @metadata,
      {
      name  => 'dc:language',
      value => $lang
      };
  }

  # Description (MA)
  # dc:description
  my $descNodes = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'description', 'dc:description');
  for my $descNode (@{$descNodes}) {
    if (exists($rec->{isinadminset})) {
      for my $as (@{$rec->{isinadminset}}) {
        if ($as eq $c->app->config->{ir}->{adminset}) {
          $descNode = {name => 'dc:description', value => "The abstract is available here: https://" . $c->app->config->{ir}->{baseurl} . "/" . $rec->{pid}};
        }
      }
    }
    push @metadata, $descNode;
  }

  # Subject (MA)
  # datacite:subject
  my $subjects = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'subject', 'datacite:subject');
  push @metadata,
    {
    name     => 'datacite:subjects',
    children => $subjects
    } if (scalar @$subjects > 0);

  # License Condition (R)
  # oaire:licenseCondition
  my $allRightReserved = 0;
  if (exists($rec->{dc_license})) {
    for my $lic (@{$rec->{dc_license}}) {
      if ($lic =~ m/^http(s)?:\/\//) {
        push @metadata,
          {
          name       => 'licenseCondition',
          value      => $lic,
          attributes => [
            { name  => 'uri',
              value => $lic
            }
          ]
          };
      }
      if ($lic eq 'All rights reserved') {
        $allRightReserved = 1;
        push @metadata,
          {
          name       => 'licenseCondition',
          value      => $lic,
          attributes => [
            { name  => 'uri',
              value => 'http://rightsstatements.org/vocab/InC/1.0/'
            }
          ]
          };
      }
    }
  }

  # File Location (MA)
  # oaire:file
  my $mime;
  my $restricted = 0;
  if (exists($rec->{datastreams})) {
    for my $ds (@{$rec->{datastreams}}) {
      if ($ds eq 'POLICY') {
        $restricted = 1;
      }
    }
  }
  unless ($allRightReserved || $restricted) {
    my @attrs;
    if ($rightsURI) {
      push @attrs,
        {
        name  => 'accessRightsURI',
        value => $rightsURI
        };
    }
    for my $format (@{$rec->{dc_format}}) {
      if ($format =~ m/(\w)+\/(\w)+/) {
        $mime = $format;
        push @attrs,
          {
          name  => 'mimeType',
          value => $mime
          };
        last;
      }
    }
    if ($downloadObjectType) {
      push @attrs,
        {
        name  => 'objectType',
        value => $downloadObjectType
        };
    }
    if ($resourceTypesToDownload->{$resourceTypeURI}) {
      my $downloadUrl;
      if ($c->app->config->{fedora}->{version} > 6) {
        $downloadUrl = 'https://' . $c->app->config->{baseurl};
        if ($c->app->config->{basepath}) {
          $downloadUrl .= '/' . $c->app->config->{basepath};
        }
        $downloadUrl .= '/objects/' . $rec->{pid} . '/download';
      }
      else {
        $downloadUrl = 'https://' . $c->app->config->{phaidra}->{fedorabaseurl} . '/fedora/objects/' . $rec->{pid} . '/methods/bdef:Content/download';
      }
      push @metadata,
        {
        name       => 'file',
        value      => $downloadUrl,
        attributes => \@attrs
        };
    }
  }

  #### RECOMMENDED ####

  # Alternate Identifier (R)
  # datacite:alternateIdentifier
  my @ids;
  if (exists($rec->{dc_identifier})) {
    for my $id (@{$rec->{dc_identifier}}) {
      if (rindex($id, 'hdl:', 0) == 0) {
        push @ids,
          {
          name       => 'datacite:alternateIdentifier',
          value      => substr($id, 4),
          attributes => [
            { name  => 'alternateIdentifierType',
              value => 'Handle'
            }
          ]
          };
      }
      if (rindex($id, 'doi:', 0) == 0) {
        push @ids,
          {
          name       => 'datacite:alternateIdentifier',
          value      => substr($id, 4),
          attributes => [
            { name  => 'alternateIdentifierType',
              value => 'DOI'
            }
          ]
          };
      }
      if (rindex($id, 'urn:', 0) == 0) {
        push @ids,
          {
          name       => 'datacite:alternateIdentifier',
          value      => substr($id, 4),
          attributes => [
            { name  => 'alternateIdentifierType',
              value => 'URN'
            }
          ]
          };
      }
      if (rindex($id, 'ISBN:', 0) == 0) {
        $id =~ s/^ISBN:\s+//g;
        push @ids,
          {
          name       => 'datacite:alternateIdentifier',
          value      => $id,
          attributes => [
            { name  => 'alternateIdentifierType',
              value => 'ISBN'
            }
          ]
          };
      }
    }
    if (scalar @ids > 0) {
      push @metadata,
        {
        name     => 'datacite:alternateIdentifiers',
        children => \@ids
        };
    }
  }

  # Related Identifier (R)
  # datacite:relatedIdentifier
  my @relatedIdsNodes;
  for my $phaidraRel (keys %{$relations}) {
    if (exists($rec->{$phaidraRel})) {
      for my $pid (@{$rec->{$phaidraRel}}) {
        push @relatedIdsNodes,
          {
          name       => 'datacite:relatedIdentifier',
          value      => 'https://' . $c->app->config->{phaidra}->{baseurl} . '/' . $pid,
          attributes => [
            { name  => 'relatedIdentifierType',
              value => 'URL'
            },
            { name  => 'relationType',
              value => $relations->{$phaidraRel}
            }
          ]
          };
      }
    }
  }
  if (scalar @relatedIdsNodes > 0) {
    push @metadata,
      {
      name     => 'datacite:relatedIdentifiers',
      children => \@relatedIdsNodes
      };
  }

  # Format (R)
  # dc:format
  if ($mime) {
    push @metadata,
      {
      name  => 'dc:format',
      value => $mime
      };
  }

  # Source (R)
  # dc:source
  my $sourceNodes = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'source', 'dc:source');
  for my $sourceNode (@{$sourceNodes}) {
    push @metadata, $sourceNode;
  }

  # Coverage (R)
  # dc:coverage
  my $coverageNodes = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'coverage', 'dc:coverage');
  for my $coverageNode (@{$coverageNodes}) {
    push @metadata, $coverageNode;
  }

  # Resource Version (R)
  # oaire:version
  my $oaireversion;
  my $oaireversionURI;
  for my $versionId (@{$rec->{dc_type}}) {

    # legacy mapping
    switch ($versionId) {
      case 'draft' {
        $oaireversion    = 'AO';
        $oaireversionURI = 'http://purl.org/coar/version/c_b1a7d7d4d402bcce';
      }
      case 'acceptedVersion' {
        $oaireversion    = 'AM';
        $oaireversionURI = 'http://purl.org/coar/version/c_ab4af688f83e57aa';
      }
      case 'updatedVersion' {    # there was only one case of CVoR in our phaidra and no EVoR
        $oaireversion    = 'CVoR';
        $oaireversionURI = 'http://purl.org/coar/version/c_e19f295774971610';
      }
      case 'submittedVersion' {
        $oaireversion    = 'SMUR';
        $oaireversionURI = 'http://purl.org/coar/version/c_71e4c1898caa6e32';
      }
      case 'publishedVersion' {
        $oaireversion    = 'VoR';
        $oaireversionURI = 'http://purl.org/coar/version/c_970fb48d4fbd8a85';
      }
    }
  }
  for my $versionId (@{$rec->{oaire_version_id}}) {
    switch ($versionId) {
      case 'https://pid.phaidra.org/vocabulary/TV31-080M' {
        $oaireversion    = 'AO';
        $oaireversionURI = 'http://purl.org/coar/version/c_b1a7d7d4d402bcce';
      }
      case 'https://pid.phaidra.org/vocabulary/JTD4-R26P' {
        $oaireversion    = 'SMUR';
        $oaireversionURI = 'http://purl.org/coar/version/c_71e4c1898caa6e32';
      }
      case 'https://pid.phaidra.org/vocabulary/PHXV-R6B3' {
        $oaireversion    = 'AM';
        $oaireversionURI = 'http://purl.org/coar/version/c_ab4af688f83e57aa';
      }
      case 'https://pid.phaidra.org/vocabulary/83ZP-CPP2' {
        $oaireversion    = 'P';
        $oaireversionURI = 'http://purl.org/coar/version/c_fa2ee174bc00049f';
      }
      case 'https://pid.phaidra.org/vocabulary/PMR8-3C8D' {
        $oaireversion    = 'VoR';
        $oaireversionURI = 'http://purl.org/coar/version/c_970fb48d4fbd8a85';
      }
      case 'https://pid.phaidra.org/vocabulary/MT1G-APSB' {
        $oaireversion    = 'CVoR';
        $oaireversionURI = 'http://purl.org/coar/version/c_e19f295774971610';
      }
      case 'https://pid.phaidra.org/vocabulary/SSQW-AP1S' {
        $oaireversion    = 'EVoR';
        $oaireversionURI = 'http://purl.org/coar/version/c_dc82b40f9837b551';
      }
      case 'https://pid.phaidra.org/vocabulary/KZB5-0F5G' {
        $oaireversion    = 'NA';
        $oaireversionURI = 'http://purl.org/coar/version/c_be7fb7dd8ff6fe43';
      }
    }
  }
  push @metadata,
    {
    name       => 'version',
    value      => $oaireversion,
    attributes => [
      { name  => 'uri',
        value => $oaireversionURI
      }
    ]
    } if $oaireversion;

  # Citation Title (R)
  # oaire:citationTitle
  if (exists($rec->{bib_journal})) {
    for my $journal (@{$rec->{bib_journal}}) {
      push @metadata,
        {
        name  => 'citationTitle',
        value => $journal
        };
      last;
    }
  }

  # Citation Volume (R)
  # oaire:citationVolume
  if (exists($rec->{bib_volume})) {
    for my $vol (@{$rec->{bib_volume}}) {
      push @metadata,
        {
        name  => 'citationVolume',
        value => $vol
        };
      last;
    }
  }

  # Citation Issue (R)
  # oaire:citationIssue
  if (exists($rec->{bib_issue})) {
    for my $iss (@{$rec->{bib_issue}}) {
      push @metadata,
        {
        name  => 'citationIssue',
        value => $iss
        };
      last;
    }
  }

  # Citation Start Page (R)
  # oaire:citationStartPage
  if (exists($rec->{schema_pagestart})) {
    for my $p (@{$rec->{schema_pagestart}}) {
      push @metadata,
        {
        name  => 'citationStartPage',
        value => $p
        };
      last;
    }
  }

  # Citation End Page (R)
  # oaire:citationEndPage
  if (exists($rec->{schema_pageend})) {
    for my $p (@{$rec->{schema_pageend}}) {
      push @metadata,
        {
        name  => 'citationEndPage',
        value => $p
        };
      last;
    }
  }

  # Citation Edition (R)
  # oaire:citationEdition
  if (exists($rec->{bib_edition})) {
    for my $ed (@{$rec->{bib_edition}}) {
      push @metadata,
        {
        name  => 'citationEdition',
        value => $ed
        };
      last;
    }
  }

  # Citation Conference Place (R)
  # oaire:citationConferencePlace

  # Citation Conference Date (R)
  # oaire:citationConferenceDate

  #### OPTIONAL ####

  # Size (O)
  # datacite:size
  my @sizes;
  if (exists($rec->{size})) {
    push @sizes,
      {
      name  => 'datacite:size',
      value => $self->_bytes_string($rec->{size})
      };
  }
  if (scalar @sizes > 0) {
    push @metadata,
      {
      name     => 'datacite:sizes',
      children => \@sizes
      };
  }

  # Geo Location (O)
  # datacite:geoLocation

  # Audience (O)
  # dcterms:audience
  if (exists($rec->{educational_context})) {
    for my $ed (@{$rec->{educational_context}}) {
      push @metadata,
        {
        name  => 'dcterms:audience',
        value => $ed
        };
      last;
    }
  }
  if (exists($rec->{educational_enduserrole})) {
    for my $ed (@{$rec->{educational_enduserrole}}) {
      push @metadata,
        {
        name  => 'dcterms:audience',
        value => $ed
        };
      last;
    }
  }

  push @metadata,
    {
    name     => 'datacite:dates',
    children => \@dates
    };

  return \@metadata;
}

1;
__END__
