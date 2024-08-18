package PhaidraAPI::Model::Mappings::Edm;

use strict;
use warnings;
use v5.10;
use utf8;
use Switch;
use Mojo::JSON qw(encode_json decode_json);
use Mojo::ByteStream qw(b);
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Languages;

sub get_metadata {
  my ($self, $c, $rec) = @_;

  my $pid = $rec->{pid};
  my $lang_model   = PhaidraAPI::Model::Languages->new;
  my %iso6393ToBCP = reverse %{$lang_model->get_iso639map()};
  my $pidUri       = 'https://' . $c->app->config->{phaidra}->{baseurl} . '/' . $pid;
  my $apiBaseUrlPath = $c->app->config->{baseurl}. ($c->app->config->{basepath} ? '/' . $c->app->config->{basepath} : '');
  my $getUrl       = "https://$apiBaseUrlPath/object/$pid/get";
  my $iiifUri      = "https://$apiBaseUrlPath/imageserver?IIIF=$pid.tif/";
  my $iiifManifestUri = "https://$apiBaseUrlPath/object/$pid/iiifmanifest";

  my @metadata;

  my $edm = {
    name       => 'rdf:RDF',
    attributes => [
      { name  => 'xmlns:edm',
        value => 'http://www.europeana.eu/schemas/edm/'
      },
      { name  => 'xmlns:dc',
        value => 'http://purl.org/dc/elements/1.1/'
      },
      { name  => 'xmlns:dcterms',
        value => 'http://purl.org/dc/terms/'
      },
      { name  => 'xmlns:skos',
        value => 'http://www.w3.org/2004/02/skos/core#'
      },
      { name  => 'xmlns:ore',
        value => 'http://www.openarchives.org/ore/terms/'
      },
      { name  => 'xmlns:svcs',
        value => 'http://rdfs.org/sioc/services#'
      },
      { name  => 'xmlns:doap',
        value => 'http://usefulinc.com/ns/doap#'
      },
      { name  => 'xmlns:rdf',
        value => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
      }
    ],
    children => []
  };

  #### ore:Aggregation ####

  my $oreAggregation = {
    name       => 'ore:Aggregation',
    attributes => [
      { name  => 'rdf:about',
        value => $pidUri.'/#Aggregation'
      }
    ],
    children => []
  };

  # edm:aggregatedCHO
  push @{$oreAggregation->{children}}, {
    name => 'edm:aggregatedCHO',
    attributes => [
      { name  => 'rdf:resource',
        value => $pidUri
      }
    ]
  };

  # edm:dataProvider
  if (exists($c->app->config->{oai}->{dataprovider})) { # should, it's mandatory
    push @{$oreAggregation->{children}}, {
      name       => 'edm:dataProvider',
      value      => $c->app->config->{oai}->{dataprovider}
    };
  }

  # edm:isShownAt
  push @{$oreAggregation->{children}}, {
    name => 'edm:isShownAt',
    attributes => [
      { name  => 'rdf:resource',
        value => $pidUri
      }
    ]
  };

  # edm:isShownBy
  push @{$oreAggregation->{children}}, {
    name => 'edm:isShownBy',
    attributes => [
      { name  => 'rdf:resource',
        value => $getUrl,
      }
    ]
  };

  # edm:rights
  my $licenseUri = $self->_get_license_uri($c, $rec);
  if ($licenseUri) {
    push @{$oreAggregation->{children}}, {
      name => 'edm:rights',
      attributes => [
        { name  => 'rdf:resource',
          value => $licenseUri
        }
      ]
    };
  }

  push @{$edm->{children}}, $oreAggregation;

  #### edm:ProvidedCHO ####

  my $edmProvidedCHO = {
    name       => 'edm:ProvidedCHO',
    attributes => [
      { name  => 'rdf:about',
        value => $pidUri
      }
    ],
    children => []
  };
  
  # dc:title
  my $titles = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'title', 'dc:title');
  push @{$edmProvidedCHO->{children}}, @{$titles};

  # dc:description
  my $descriptions = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'description', 'dc:description');
  push @{$edmProvidedCHO->{children}}, @{$descriptions};

  # dc:identifier
  push @{$edmProvidedCHO->{children}}, {
    name => 'dc:identifier',
    attributes => [
      { name  => 'rdf:resource',
        value => $getUrl,
      }
    ]
  };

  # dc:language
  for my $lang (@{$rec->{dc_language}}) {
    push @{$edmProvidedCHO->{children}}, {
      name  => 'dc:language',
      value => $self->_map_iso3_to_bcp(\%iso6393ToBCP, $lang)
    };
  }

  # edm:type
  if ($rec->{cmodel} eq 'Picture') {
    push @{$edmProvidedCHO->{children}}, {
      name  => 'edm:type',
      value => 'IMAGE'
    };
  }
  if ($rec->{cmodel} eq 'Audio') {
    push @{$edmProvidedCHO->{children}}, {
      name  => 'edm:type',
      value => 'AUDIO'
    };
  }
  if ($rec->{cmodel} eq 'Video') {
    push @{$edmProvidedCHO->{children}}, {
      name  => 'edm:type',
      value => 'VIDEO'
    };
  }
  if ($rec->{cmodel} eq 'PDFDocuemt') {
    push @{$edmProvidedCHO->{children}}, {
      name  => 'edm:type',
      value => 'TEXT'
    };
  }
  if (exists($rec->{edm_hastype_id})) {
    for my $edmt (@{$rec->{edm_hastype_id}}) {
      if ($edmt eq 'https://pid.phaidra.org/vocabulary/T6C3-46S4') {
        push @{$edmProvidedCHO->{children}}, {
          name  => 'edm:type',
          value => '3D'
        };
      }
    }
  }

  # dc:type
  if (exists($rec->{edm_hastype})) {
    for my $edmt (@{$rec->{edm_hastype}}) {
      push @{$edmProvidedCHO->{children}}, {
        name  => 'dc:type',
        value => $edmt
      };
    }
  }
  my $types = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'type', 'dc:type');
  push @{$edmProvidedCHO->{children}}, @{$types};

  # dc:subject
  my $subjects = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'subject', 'dc:subject');
  push @{$edmProvidedCHO->{children}}, @{$subjects};

  # dc:date
  if (exists($rec->{bib_published})) {
    for my $pubDate (@{$rec->{bib_published}}) {
      push @{$edmProvidedCHO->{children}}, {
        name  => 'dcterms:issued',
        value => $pubDate
      };
    }
  }
  if (exists($rec->{dcterms_created_year})) {
    for my $cDate (@{$rec->{dcterms_created_year}}) {
      push @{$edmProvidedCHO->{children}}, {
        name  => 'dcterms:created',
        value => $cDate
      };
    }
  }
  if (exists($rec->{dc_date})) {
    for my $date (@{$rec->{dc_date}}) {
      push @{$edmProvidedCHO->{children}}, {
        name  => 'dc:date',
        value => $date
      };
    }
  }

  # if there are metadata about physical object and there are roles, only add these to providedCHO
  my $hasRepresentedObjectRoles = 0;
  if (exists($rec->{jsonld})) {
    if (exists($rec->{jsonld}->{'dcterms:subject'})) {
      for my $subject (@{$rec->{jsonld}->{'dcterms:subject'}}) {
        if ($subject->{'@type'} eq 'phaidra:Subject') {
          for my $sPredicate (keys %{$subject}) {
            if ($sPredicate =~ m/role:(\w+)/g) {
              $hasRepresentedObjectRoles = 1;
            }
          }
        }
      }
    }
  }
         
  unless ($hasRepresentedObjectRoles) {
    # dc:creator
    my $creators = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'creator', 'dc:creator');
    push @{$edmProvidedCHO->{children}}, @{$creators};

    # dc:contributor
    my $contributors = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'contributor', 'dc:contributor');
    push @{$edmProvidedCHO->{children}}, @{$contributors};

    # dc:publisher
    my $publishers = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'publisher', 'dc:publisher');
    push @{$edmProvidedCHO->{children}}, @{$publishers};
  }

  # dcterms:isPartOf
  if (exists($rec->{ispartof})) {
    my @ispartofs;
    for my $v (@{$rec->{ispartof}}) {
      my $title;
      my $upid = $v =~ s/:/_/r;
      if (exists($rec->{"title_of_$upid"})) {
        $title = $rec->{"title_of_$upid"};
      }
      push @{$edmProvidedCHO->{children}}, {
        name  => 'dcterms:isPartOf',
        value => $title
      };
    }
  }

  # currently not in index, so only taken if object has json-ld
  # dcterms:temporal
  # dcterms:spatial
  # dcterms:provenance
  if (exists($rec->{jsonld})) {
    my $jsonld = $rec->{jsonld};

    # dcterms:temporal
    my $temporal;
    if (exists($jsonld->{'dcterms:temporal'})) {
      $temporal = $jsonld->{'dcterms:temporal'};
    }
    # use represented-object temporal coverage preferrably
    if (exists($jsonld->{'dcterms:subject'})) {
      for my $subject (@{$jsonld->{'dcterms:subject'}}) {
        if ($subject->{'@type'} eq 'phaidra:Subject') {
          if (exists($subject->{'dcterms:temporal'})) {
            $temporal = $subject->{'dcterms:temporal'};
          }
        }
      }
    }
    if ($temporal) {
      for my $temp (@{$temporal}) {
        my $tempNode = {
          name => 'dcterms:temporal',
          value => $temp->{'@value'}
        };
        if ($temp->{'@language'}) {
          $tempNode->{attributes} = [
            {
              name => 'xml:lang',
              value => $self->_map_iso3_to_bcp(\%iso6393ToBCP, $temp->{'@language'})
            }
          ]
        }
        push @{$edmProvidedCHO->{children}}, $tempNode;
      }
    }

    # dcterms:spatial
    my $spatial;
    if (exists($jsonld->{'dcterms:spatial'})) {
      $spatial = $jsonld->{'dcterms:spatial'};
    }
    # use represented-object spatial coverage preferrably
    if (exists($jsonld->{'dcterms:subject'})) {
      for my $subject (@{$jsonld->{'dcterms:subject'}}) {
        if ($subject->{'@type'} eq 'phaidra:Subject') {
          if (exists($subject->{'dcterms:spatial'})) {
            $spatial = $subject->{'dcterms:spatial'};
          }
        }
      }
    }
    if ($spatial) {
      for my $place (@{$spatial}) {
        my $placeid;
        if (exists($place->{'skos:exactMatch'})) {
          for my $em (@{$place->{'skos:exactMatch'}}) {
            $placeid = $em;
            last;
          }
        }
        if ($placeid) {
          my $spatialNode = {
            name => 'dcterms:spatial',
            attributes => [
              {
                name => 'rdf:resource',
                value => $placeid
              }
            ]
          };
          push @{$edmProvidedCHO->{children}}, $spatialNode;

          my $rdfsLabel;
          if (exists($place->{'rdfs:label'})) {
            for my $lab (@{$place->{'rdfs:label'}}) {
              $rdfsLabel = $lab->{'@value'};
              last;
            }
          }

          if ($rdfsLabel) {
            my $edmPlace = {
              name => 'edm:Place',
              attributes => [
                {
                  name => 'rdf:about',
                  value => $placeid
                }
              ],
              children => [
                {
                  name => 'skos:prefLabel',
                  value => $rdfsLabel
                }
              ]
            };
            # this goes one level up
            push @{$edm->{children}}, $edmPlace;
          }
        }
      }
    }

    # dcterms:provenance
    my $provenance;
    if (exists($jsonld->{'dcterms:provenance'})) {
      $provenance = $jsonld->{'dcterms:provenance'};
    }
    # use represented-object spatial coverage preferrably
    if (exists($jsonld->{'dcterms:subject'})) {
      for my $subject (@{$jsonld->{'dcterms:subject'}}) {
        if ($subject->{'@type'} eq 'phaidra:Subject') {
          if (exists($subject->{'dcterms:provenance'})) {
            $provenance = $subject->{'dcterms:provenance'};
          }
        }
      }
    }
    if ($provenance) {
      for my $prov (@{$provenance}) {
        my $prefLabel;
        if (exists($prov->{'skos:prefLabel'})) {
          for my $lab (@{$prov->{'skos:prefLabel'}}) {
            my $provenanceNode = {
              name => 'dcterms:provenance',
              value => $lab->{'@value'}
            };
            if (exists($lab->{'@language'})) {
              $provenanceNode->{attributes} = [
                {
                  name => 'xml:lang',
                  value => $self->_map_iso3_to_bcp(\%iso6393ToBCP, $lab->{'@language'})
                }
              ];
            }
            push @{$edmProvidedCHO->{children}}, $provenanceNode;
          }
        }
      }
    }
  }

  push @{$edm->{children}}, $edmProvidedCHO;

  #### edm:WebResource ####

  my $edmWebResource = {
    name       => 'edm:WebResource',
    attributes => [
      { name  => 'rdf:about',
        value => $getUrl
      }
    ],
    children => []
  };

  # dc:rights
  my $rights = $self->_get_rights_statement($c, $rec);
  if ($rights) {
    push @{$edmWebResource->{children}}, {
      name => 'dc:rights',
      value => $rights
    };
  }

  # dcterms:isReferencedBy  
  if ($self->_has_iiifmanifest($c, $rec)) {
    push @{$edmWebResource->{children}}, {
      name => 'dcterms:isReferencedBy',
      attributes => [
        { name  => 'rdf:resource',
          value => $iiifManifestUri
        }
      ]
    };
  }

  # svcs:has_service
  if ($rec->{cmodel} eq 'Picture') {
    push @{$edmWebResource->{children}}, {
      name => 'svcs:has_service',
      attributes => [
        { name  => 'rdf:resource',
          value => $iiifUri
        }
      ]
    };

    #### svcs:Service ####

    my $svcsService = {
      name       => 'svcs:Service',
      attributes => [
        { name  => 'rdf:about',
          value => $iiifUri
        }
      ],
      children => [
        {
          name => 'dcterms:conformsTo',
          attributes => [
            { name  => 'rdf:resource',
              value => 'http://iiif.io/api/image'
            }
          ]
        },
        {
          name => 'doap:implements',
          attributes => [
            { name  => 'rdf:resource',
              value => 'https://iiif.io/api/image/2/level1.json'
            }
          ]
        }
      ]
    };

    push @{$edm->{children}}, $svcsService;
  }

  push @{$edm->{children}}, $edmWebResource;
  
  #### skos:Concept ####

  if (exists($rec->{jsonld})) {
    if (exists($rec->{jsonld}->{'dcterms:subject'})) {
      for my $c_in (@{$rec->{jsonld}->{'dcterms:subject'}}) {
        if ($c_in->{'@type'} eq 'skos:Concept') {
          my $c_out = {
            name => 'skos:Concept',
            attributes => [],
            children => []
          };
          my $prefLabels = [];
          my $exactMatch;  
          for my $em (@{$c_in->{'skos:exactMatch'}}) {
            push @{$c_out->{attributes}}, { 
              name  => 'rdf:about',
              value => $em
            };
            last;
          }
          for my $l_in (@{$c_in->{'skos:prefLabel'}}) {
            my $l_out = {
              name => 'skos:prefLabel',
              attributes => [],
              value => $l_in->{'@value'}
            };
            
            if ($l_in->{'@language'}) {
              push @{$l_out->{attributes}}, { 
                name  => 'xml:lang',
                value => $self->_map_iso3_to_bcp(\%iso6393ToBCP, $l_in->{'@language'})
              };
            }
            push @{$c_out->{children}}, $l_out;
          }
          push @{$edm->{children}}, $c_out;
        }
      }
    }
  }

  # $c->app->log->debug("XXXXXXXXXXXXX EDM XXXXXXXXXXXX\n".$c->app->dumper($edm));
  
  push @metadata, $edm;

  return \@metadata;
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
            { 
              name  => 'xml:lang',
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

sub _has_iiifmanifest {
  my ($self, $c, $rec) = @_;

  for my $ds (@{$rec->{datastreams}}) {
    if ($ds eq 'IIIF-MANIFEST') {
      return 1;
    }
  }

  return 0;
}

sub _get_rights_statement {
  my ($self, $c, $rec) = @_;

  for my $key (keys %{$rec}) {
    if ($key =~ m/^dc_rights/) {
      for my $v (@{$rec->{key}}) {
        unless ($v =~ m/^http(s)?:\/\//) {
          return $v; # cardinality 0..1
        }
      }
    }
  }

}

sub _get_license_uri {
  my ($self, $c, $rec) = @_;

  my $uri;
  if (exists($rec->{dc_rights})) {
    for my $r (@{$rec->{dc_rights}}) {
      if ($r =~ m/^http(s)?:\/\//) {
        $uri = $r;
      }
      if ($r eq 'All rights reserved') {
        $uri = 'http://rightsstatements.org/vocab/InC/1.0/';
      }
    }
  }

  return $uri;
}

1;
__END__
