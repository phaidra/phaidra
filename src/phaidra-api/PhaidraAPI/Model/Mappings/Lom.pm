package PhaidraAPI::Model::Mappings::Lom;

use strict;
use warnings;
use v5.10;
use utf8;
use Switch;
use Mojo::JSON qw(encode_json decode_json);
use Mojo::ByteStream qw(b);
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Languages;

my $kimHcrtVocab = {
  'https://w3id.org/kim/hcrt/application' => { 'eng' => 'Software Application', 'deu' => 'Softwareanwendung' },
  'https://w3id.org/kim/hcrt/assessment' => { 'eng' => 'Assessment', 'deu' => 'Lernkontrolle' },
  'https://w3id.org/kim/hcrt/audio' => { 'eng' => 'Audio Recording', 'deu' => 'Audio' },
  'https://w3id.org/kim/hcrt/case_study' => { 'eng' => 'Case Study', 'deu' => 'Fallstudie' },
  'https://w3id.org/kim/hcrt/course' => { 'eng' => 'Course', 'deu' => 'Kurs' },
  'https://w3id.org/kim/hcrt/data' => { 'eng' => 'Data', 'deu' => 'Daten' },
  'https://w3id.org/kim/hcrt/diagram' => { 'eng' => 'Diagram', 'deu' => 'Grafik' },
  'https://w3id.org/kim/hcrt/drill_and_practice' => { 'eng' => 'Drill and Practice', 'deu' => 'Übung' },
  'https://w3id.org/kim/hcrt/educational_game' => { 'eng' => 'Game', 'deu' => 'Lernspiel' },
  'https://w3id.org/kim/hcrt/experiment' => { 'eng' => 'Experiment', 'deu' => 'Experiment' },
  'https://w3id.org/kim/hcrt/image' => { 'eng' => 'Image', 'deu' => 'Abbildung' },
  'https://w3id.org/kim/hcrt/index' => { 'eng' => 'Reference Work', 'deu' => 'Nachschlagewerk' },
  'https://w3id.org/kim/hcrt/lesson_plan' => { 'eng' => 'Lesson Plan', 'deu' => 'Unterrichtsplanung' },
  'https://w3id.org/kim/hcrt/map' => { 'eng' => 'Map', 'deu' => 'Karte' },
  'https://w3id.org/kim/hcrt/portal' => { 'eng' => 'Web Portal', 'deu' => 'Portal' },
  'https://w3id.org/kim/hcrt/questionnaire' => { 'eng' => 'Questionnaire', 'deu' => 'Fragebogen' },
  'https://w3id.org/kim/hcrt/script' => { 'eng' => 'Script', 'deu' => 'Skript' },
  'https://w3id.org/kim/hcrt/sheet_music' => { 'eng' => 'Sheet Music', 'deu' => 'Musiknoten' },
  'https://w3id.org/kim/hcrt/simulation' => { 'eng' => 'Simulation', 'deu' => 'Simulation' },
  'https://w3id.org/kim/hcrt/slide' => { 'eng' => 'Presentation', 'deu' => 'Präsentation' },
  'https://w3id.org/kim/hcrt/text' => { 'eng' => 'Text', 'deu' => 'Textdokument' },
  'https://w3id.org/kim/hcrt/textbook' => { 'eng' => 'Textbook', 'deu' => 'Lehrbuch' },
  'https://w3id.org/kim/hcrt/video' => { 'eng' => 'Video', 'deu' => 'Video' },
  'https://w3id.org/kim/hcrt/web_page' => { 'eng' => 'Web Page', 'deu' => 'Webseite' },
  'https://w3id.org/kim/hcrt/worksheet' => { 'eng' => 'Worksheet', 'deu' => 'Arbeitsmaterial' },
  'https://w3id.org/kim/hcrt/other' => { 'eng' => 'Other', 'deu' => 'Sonstiges' }
};

sub get_metadata {
  my ($self, $c, $rec) = @_;

  my $pid = $rec->{pid};
  my $lang_model   = PhaidraAPI::Model::Languages->new;
  my %iso6393ToBCP = reverse %{$lang_model->get_iso639map()};
  my $phaidraBaseurl = $c->app->config->{phaidra}->{baseurl};
  my $pidUri       = "https://$phaidraBaseurl/$pid";
  my $apiBaseUrlPath = $c->app->config->{baseurl}. ($c->app->config->{basepath} ? '/' . $c->app->config->{basepath} : '');
  my $thumbnailUrl = "https://$apiBaseUrlPath/object/$pid/thumbnail";

  my @metadata;

  my $lom = {
    name       => 'lom:lom',
    attributes => [
      { name  => 'xmlns:lom',
        value => 'https://oer-repo.uibk.ac.at/lom'
      },
      { name  => 'xmlns:xsi',
        value => 'http://www.w3.org/2001/XMLSchema-instance'
      },
      { name  => 'xsi:schemaLocation',
        value => 'https://oer-repo.uibk.ac.at/lom/latest https://w3id.org/oerbase/profiles/lomuibk/latest/schemas/lom-uibk.xsd'
      }
    ],
    children => []
  };

  #### general ####

  my $general = {
    name       => 'lom:general',
    children => []
  };

  # identifier
  push @{$general->{children}}, {
    name => 'lom:identifier',
    children => [
      { 
        name  => 'lom:catalog',
        value =>  $phaidraBaseurl
      },
      { 
        name  => 'lom:entry',
        children => [
          { 
            name => 'lom:langstring',
            value =>  $pidUri,
            attributes => [
              { 
                name  => 'xml:lang',
                value => 'x-none'
              }
            ]
          }
        ]
      }
    ]
  };
  if (exists($rec->{dc_identifier})) {
    for my $id (@{$rec->{dc_identifier}}) {
      if (rindex($id, 'hdl:', 0) == 0) {
        push @{$general->{children}}, {
          name => 'lom:identifier',
          children => [
            { 
              name  => 'lom:catalog',
              value =>  'HDL'
            },
            { 
              name  => 'lom:entry',
              children => [
                { 
                  name => 'lom:langstring',
                  value =>  substr($id, 4),
                  attributes => [
                    { 
                      name  => 'xml:lang',
                      value => 'x-none'
                    }
                  ]
                }
              ]
            }
          ]
        };
      }
      if (rindex($id, 'doi:', 0) == 0) {
        push @{$general->{children}}, {
          name => 'lom:identifier',
          children => [
            { 
              name  => 'lom:catalog',
              value =>  'DOI'
            },
            { 
              name  => 'lom:entry',
              children => [
                { 
                  name => 'lom:langstring',
                  value =>  substr($id, 4),
                  attributes => [
                    { 
                      name  => 'xml:lang',
                      value => 'x-none'
                    }
                  ]
                }
              ]
            }
          ]
        };
      }
      if (rindex($id, 'urn:', 0) == 0) {
        push @{$general->{children}}, {
          name => 'lom:identifier',
          children => [
            { 
              name  => 'lom:catalog',
              value =>  'URN'
            },
            { 
              name  => 'lom:entry',
              children => [
                { 
                  name => 'lom:langstring',
                  value =>  substr($id, 4),
                  attributes => [
                    { 
                      name  => 'xml:lang',
                      value => 'x-none'
                    }
                  ]
                }
              ]
            }
          ]
        };
      }
      if (rindex($id, 'ISBN:', 0) == 0) {
        $id =~ s/^ISBN:\s+//g;
        push @{$general->{children}}, {
          name => 'lom:identifier',
          children => [
            { 
              name  => 'lom:catalog',
              value =>  'ISBN'
            },
            { 
              name  => 'lom:entry',
              children => [
                { 
                  name => 'lom:langstring',
                  value =>  $id,
                  attributes => [
                    { 
                      name  => 'xml:lang',
                      value => 'x-none'
                    }
                  ]
                }
              ]
            }
          ]
        };
      }
    }
  }

  # title
  my $titles = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'title', 'lom:title');
  push @{$general->{children}}, @{$titles};

  # description
  my $descriptions = $self->_get_dc_fields($c, \%iso6393ToBCP, $rec, 'description', 'lom:description');
  push @{$general->{children}}, @{$descriptions};

  # language
  if (exists($rec->{dc_language})) {
    for my $l (@{$rec->{dc_language}}) {
      push @{$general->{children}}, {
        name => 'lom:language',
        value => $l
      };
    }
  }

  #### lifecycle ####

  my $lifecycle = {
    name => 'lom:lifecycle',
    children => []
  };

  if (exists($rec->{modified})) {
    push @{$lifecycle->{children}}, {
      name => 'lom:datetime',
      value => $rec->{modified}
    };
  } else {
    if (exists($rec->{created})) {
      push @{$lifecycle->{children}}, {
        name => 'lom:datetime',
        value => $rec->{created}
      };
    }
  }

  # contribute
  if (exists($rec->{roles_json})) {
    $self->_add_contribute($c, $lifecycle, $rec, 'roles_json');
  } else {
    if (exists($rec->{uwm_roles_json})) {
      $self->_add_contribute($c, $lifecycle, $rec, 'uwm_roles_json');
    }
  }

  #### technical ####

  my $technical = {
    name => 'lom:technical',
    children => []
  };

  # format
  for my $format (@{$rec->{dc_format}}) {
    if ($format =~ m/(\w)+\/(\w)+/) {
      push @{$technical->{children}}, {
        name => 'lom:format',
        value => $format
      };
      last;
    }
  }

  # size
  if (exists($rec->{size})) {
    push @{$technical->{children}}, {
      name => 'lom:size',
      value => $rec->{size}
    };
  }

  # location
  push @{$technical->{children}}, {
    name => 'lom:location',
    value => $pidUri
  };

  # thumbnail
  push @{$technical->{children}}, {
    name => 'lom:thumbnail',
    children => [
      {
        name => 'lom:url',
        value => $thumbnailUrl
      }
    ]
  };

  #### educational ####

  # ignoring object_type_id - there is nothing in UWM type that we could map...
  my $kimHcrtType;
  if (exists($rec->{edm_hastype_id})) {
    for my $type (@{$rec->{edm_hastype_id}}) {
      if (rindex($type, 'https://w3id.org/kim/hcrt/', 0) == 0) {
        $kimHcrtType = $type;
      }
    }
  }
  unless ($kimHcrtType) {
    switch ($rec->{cmodel}) {
      case 'Audio' {
        $kimHcrtType = 'https://w3id.org/kim/hcrt/audio';
      }
      case 'Video' {
        $kimHcrtType = 'https://w3id.org/kim/hcrt/video';
      }
      case 'Picture' {
        $kimHcrtType = 'https://w3id.org/kim/hcrt/image';
      }
      case 'PDFDocument' {
        $kimHcrtType = 'https://w3id.org/kim/hcrt/text';
      }
      else {
        $kimHcrtType = 'https://w3id.org/kim/hcrt/other';
      }
    }
  }

  my $educational = {
    name => 'lom:educational',
    children => [
      {
        name => 'lom:learningresourcetype',
        children => [
          {
            name => 'lom:source',
            children => [
              {
                name => 'lom:langstring',
                value => 'https://w3id.org/kim/hcrt/scheme',
                attributes => [
                  { 
                    name  => 'xml:lang',
                    value => 'x-none'
                  }
                ]
              }
            ]
          },
          {
            name => 'lom:id',
            value => $kimHcrtType
          },
          {
            name => 'lom:entry',
            children => [
              {
                name => 'lom:langstring',
                value => $kimHcrtVocab->{$kimHcrtType}->{deu},
                attributes => [
                  {
                    name => 'xml:lang',
                    value => 'de'
                  }
                ]
              },
              {
                name => 'lom:langstring',
                value => $kimHcrtVocab->{$kimHcrtType}->{eng},
                attributes => [
                  {
                    name => 'xml:lang',
                    value => 'en'
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  };

  #### rights ####

  my $rights = {
    name => 'lom:rights',
    children => [
      {
        name => 'lom:copyrightandotherrestrictions',
        children => [
          {
            name => 'lom:source',
            children => [
              {
                name => 'lom:langstring',
                value => 'LOMv1.0',
                attributes => [
                  { 
                    name  => 'xml:lang',
                    value => 'x-none'
                  }
                ]
              }
            ]
          },
          {
            name => 'lom:value',
            children => [
              {
                name => 'lom:langstring',
                value => 'yes',
                attributes => [
                  { 
                    name  => 'xml:lang',
                    value => 'x-none'
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  };

  my $lic = $self->_get_license_uri($c, $rec);
  my $licLangStr = {
    name => 'lom:langstring',
    value => $lic
  };
  if ($lic =~ m/^https?\:\/\/creativecommons.org\/licenses\//) {
    $licLangStr->{attributes} = [
      {
        name => 'xml:lang',
        value => 'x-t-cc-url'
      }
    ]
  };
  my $licNode = {
    name => 'lom:description',
    children => [ 
      $licLangStr
    ]
  };

  push @{$rights->{children}}, $licNode;

  #### classification ####

  my $classification = {
    name       => 'lom:classification',
    children => [
      {
        name => 'lom:purpose',
        children => [
          {
            name => 'lom:source',
            children => [
              {
                name => 'lom:langstring',
                value => 'LOMv1.0',
                attributes => [
                  { 
                    name  => 'xml:lang',
                    value => 'x-none'
                  }
                ]
              }
            ]
          },
          {
            name => 'lom:value',
            children => [
              {
                name => 'lom:langstring',
                value => 'discipline',
                attributes => [
                  { 
                    name  => 'xml:lang',
                    value => 'x-none'
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  };

  $self->_add_oefos_and_keywords($c, \%iso6393ToBCP, $general, $classification, $rec);

  push @{$lom->{children}}, $general;
  push @{$lom->{children}}, $lifecycle;
  push @{$lom->{children}}, $educational;
  push @{$lom->{children}}, $rights;
  push @{$lom->{children}}, $technical;
  push @{$lom->{children}}, $classification;

  # $c->app->log->debug("XXXXXXXXXXXX LOM XXXXXXXXXXXXX\n".$c->app->dumper($lom));
  
  push @metadata, $lom;

  return \@metadata;
}

sub _add_oefos_and_keywords {
  my ($self, $c, $iso6393ToBCP, $general, $classification, $rec) = @_;

  # turning
  # ÖFOS 2012 -- SOZIALWISSENSCHAFTEN (5) -- Erziehungswissenschaften (503) -- Erziehungswissenschaften (5030) -- E-Learning (503008)
  # ÖFOS 2012 -- SOCIAL SCIENCES (5) -- Educational Sciences (503) -- Educational Sciences (5030) -- E-learning (503008)
  # to
  # <lom:taxon>
  #   <lom:id>https://w3id.org/oerbase/vocabs/oefos2012/5</lom:id>
  #   <lom:entry>
  #     <lom:langstring xml:lang="de">SOZIALWISSENSCHAFTEN</lom:langstring>
  #     <lom:langstring xml:lang="en">SOCIAL SCIENCES</lom:langstring>
  #   </lom:entry>
  # </lom:taxon>
  # <lom:taxon>
  #   <lom:id>https://w3id.org/oerbase/vocabs/oefos2012/503</lom:id>
  #   <lom:entry>
  #     <lom:langstring xml:lang="de">Educational Sciences</lom:langstring>
  #     <lom:langstring xml:lang="en">Erziehungswissenschaften</lom:langstring>
  #   </lom:entry>
  # </lom:taxon>
  # etc...

  # it's ÖFOS so it's just eng and deu

  my $taxonPaths;
  my @lastTaxonLabels;

  if (exists($rec->{dc_subject_eng})) {
    for my $sub (@{$rec->{dc_subject_eng}}) {
      if (rindex($sub, 'ÖFOS', 0) == 0) {

        my @path = split(/ -- /, $sub);

        # first, find last taxon, we'll use it to identify this classification
        my $lastTaxon;
        my $lastTaxonLabel;
        for my $entry (@path) {
          if (rindex($entry , 'ÖFOS', 0) == 0) {
            next;
          }
          $entry =~ m/(.+)\s\((\d+)\)$/;
          $lastTaxonLabel = $1;
          $lastTaxon = $2;
        }

        $taxonPaths->{$lastTaxon} = [];
        push @lastTaxonLabels, $lastTaxonLabel;

        # now add the full path for that taxon
        for my $entry (@path) {
          if (rindex($entry , 'ÖFOS', 0) == 0) {
            next;
          }
          $entry =~ m/(.+)\s\((\d+)\)$/;
          push @{$taxonPaths->{$lastTaxon}}, {
            'notation' => $2,
            'eng' => $1
          }
        }
      }
    }
  }

  # update with deu labels
  if (exists($rec->{dc_subject_deu})) {
    for my $sub (@{$rec->{dc_subject_deu}}) {
      if (rindex($sub, 'ÖFOS', 0) == 0) {

        my @path = split(/ -- /, $sub);

        # first, find last taxon, we'll use it to identify this classification
        my $lastTaxon;
        my $lastTaxonLabel;
        for my $entry (@path) {
          if (rindex($entry , 'ÖFOS', 0) == 0) {
            next;
          }
          $entry =~ m/(.+)\s\((\d+)\)$/;
          $lastTaxonLabel = $1;
          $lastTaxon = $2;
        }

        push @lastTaxonLabels, $lastTaxonLabel;

        for my $entry (@path) {
          if (rindex($entry , 'ÖFOS', 0) == 0) {
            next;
          }
          $entry =~ m/(.+)\s\((\d+)\)$/;

          for my $entry (@{$taxonPaths->{$lastTaxon}}) {
            if ($entry->{notation} eq $2) {
              $entry->{deu} = $1;
            }
          }
        }
      }
    }
  }
  
  for my $lastTaxon (keys %{$taxonPaths}) {

    my @taxonChildren;
    
    push @taxonChildren, {
      name => 'lom:source',
      children => [
        {
          name => 'lom:langstring',
          value => 'https://w3id.org/oerbase/vocabs/oefos2012',
          attributes => [
            { 
              name  => 'xml:lang',
              value => 'x-none'
            }
          ]
        }
      ]
    };
    
    for my $entry (@{$taxonPaths->{$lastTaxon}}) {
      push @taxonChildren, {
        name => 'lom:taxon',
        children => [
          {
            name => 'lom:id',
            value => 'https://w3id.org/oerbase/vocabs/oefos2012/'.$entry->{notation}
          },
          {
            name => 'lom:entry',
            children => [
              {
                name => 'lom:langstring',
                value => $entry->{eng},
                attributes => [
                  {
                    name => 'xml:lang',
                    value => 'en'
                  }
                ]
              }
            ]
          },
          {
            name => 'lom:entry',
            children => [
              {
                name => 'lom:langstring',
                value => $entry->{deu},
                attributes => [
                  {
                    name => 'xml:lang',
                    value => 'de'
                  }
                ]
              }
            ]
          }
        ]
      };
    }

    push @{$classification->{children}}, {
      name => 'lom:taxonpath',
      children => \@taxonChildren
    };
  }

  my $keywords = $self->_get_dc_fields($c, $iso6393ToBCP, $rec, 'subject', 'lom:keyword');
  for my $kw (@{$keywords}) {
    for my $kwLangString (@{$kw->{children}}) {
      # when indexing, this
      # ÖFOS 2012 -- SOZIALWISSENSCHAFTEN (5) -- Erziehungswissenschaften (503) -- Erziehungswissenschaften (5030) -- E-Learning (503008)
      # and this
      # E-Learning
      # was added to dc_subject along with keywords
      # we want to skip those, since those were just added as classification
      my $kwval = $kwLangString->{value};
      my $isOefosTaxon = 0;
      for my $lt (@lastTaxonLabels) {
        if ($kwval eq $lt) {
          $isOefosTaxon = 1;
          last;
        }
      }
      if ((rindex($kwval, 'ÖFOS', 0) != 0) && !$isOefosTaxon) {
        push @{$general->{children}}, $kw;
      }
    }
  }
}

sub _add_contribute {
  my ($self, $c, $lifecycle, $rec, $solrfield) = @_;

  for my $roles_json_str (@{$rec->{$solrfield}}) {

    my $json = decode_json(b($roles_json_str)->encode('UTF-8'));

    my $roles;
    if ($solrfield eq 'roles_json') {
      $roles = $self->_get_jsonld_roles($c, $json);
    } else {
      $roles = $self->_get_uwm_roles($c, $json);
    }

    for my $role (keys %{$roles}) {
      my $entityCnt = scalar @{$roles->{$role}};
      if ($entityCnt > 0) {
        my $contribute = {
          name => 'lom:contribute',
          children => [
            {
              name => 'lom:role',
              children => [
                {
                  name => 'lom:source',
                  children => [
                    {
                      name => 'lom:langstring',
                      value => 'LOMv1.0'
                    }
                  ],
                  attributes => [
                    { 
                      name  => 'xml:lang',
                      value => 'x-none'
                    }
                  ]
                },
                {
                  name => 'lom:value',
                  children => [
                    {
                      name => 'lom:langstring',
                      value => $role
                    }
                  ],
                  attributes => [
                    { 
                      name  => 'xml:lang',
                      value => 'x-none'
                    }
                  ]
                }
              ]
            }
          ]
        };

        for my $entity (@{$roles->{$role}}) {

          my $n;
          my $fn;
          my $orcid;
          if ($entity->{name}) {
            $fn = $entity->{name};
          }
          else {
            $fn = $entity->{lastname};
            $fn = $entity->{firstname}.' '.$entity->{lastname} if $entity->{firstname};

            $n = $entity->{lastname}.';;';
            $n = $entity->{lastname}.';'.$entity->{firstname}.';' if $entity->{firstname};
          }
          
          my $vcard = "BEGIN:VCARD\nVERSION:3.0\n";

          if ($n) {
            $vcard .= "N:$n\n";
          }

          $vcard .= "FN:$fn\n";

          if ($entity->{orcid}) {
            $vcard .= "X-ORCID:https\://orcid.org/".$entity->{orcid}."\n";
          }

          $vcard .= "END:VCARD";

          push @{$contribute->{children}}, {
            name => 'lom:centity',
            children => [
              {
                name => 'lom:vcard',
                value => $vcard
              }
            ]
          };
        }

        push @{$lifecycle->{children}}, $contribute;
      }
    }
  }
}

sub _get_jsonld_roles {
  my ($self, $c, $json) = @_;

  my $roles = {
    Author => [],
    Publisher => [],
    Editor => []
  };
  for my $hash (@{$json}) {
    for my $rolePredicate (keys %{$hash}) {
      for my $e (@{$hash->{$rolePredicate}}) {
        my $entity = {};
        my $roleCode = $rolePredicate;
        $roleCode =~ s/^role://g;
        switch ($roleCode) {
          case 'aut' {
            push @{$roles->{Author}}, $entity;
          }
          case 'pbl' {
            push @{$roles->{Publisher}}, $entity;
          }
          case 'edt' {
            push @{$roles->{Editor}}, $entity;
          }
          default {
            next;
          }
        }
        for my $prop (keys %{$e}) {
          if ($prop eq 'schema:givenName') {
            for my $v (@{$e->{$prop}}) {
              $entity->{firstname} = $v->{'@value'};
            }
          }
          if ($prop eq 'schema:familyName') {
            for my $v (@{$e->{$prop}}) {
              $entity->{lastname} = $v->{'@value'};
            }
          }
          if ($prop eq 'schema:name') {
            for my $v (@{$e->{$prop}}) {
              $entity->{name} = $v->{'@value'};
            }
          }
          if ($prop eq 'skos:exactMatch') {
            for my $id (@{$e->{$prop}}) {
              if (ref($id) eq 'HASH') {
                if ($id->{'@type'} eq 'ids:orcid') {
                  $entity->{orcid} = $id->{'@value'};
                }
              }
            }
          }
        }
      }
    }
  }

  return $roles;
}

sub _get_uwm_roles {
  my ($self, $c, $json) = @_;

  my $roles = {
    Author => [],
    Publisher => [],
    Editor => []
  };

  my @contrib = sort {$a->{data_order} <=> $b->{data_order}} @{$json};
  for my $con (@contrib) {
    if ($con->{entities}) {
      my @entities = sort {$a->{data_order} <=> $b->{data_order}} @{$con->{entities}};
      for my $e (@entities) {
        my $entity;
        my $roleCode = $con->{role};
        switch ($roleCode) {
          case 'aut' {
            push @{$roles->{Author}}, $entity;
          }
          case 'pbl' {
            push @{$roles->{Publisher}}, $entity;
          }
          case 'edt' {
            push @{$roles->{Editor}}, $entity;
          }
          default {
            next;
          }
        }
        if ($e->{orcid}) {
          $entity->{orcid} = $e->{orcid};
        }
        if ($e->{firstname} || $e->{lastname}) {
          $entity->{firstname} = $e->{firstname};
          $entity->{lastname} = $e->{lastname};
        } else {
          if ($e->{institution}) {
            $entity->{name} = $e->{institution};
          }
        }
      }
    }
  }

  return $roles;
}


sub _map_iso3_to_bcp {
  my ($self, $iso6393ToBCP, $lang) = @_;
  return exists($iso6393ToBCP->{$lang}) ? $iso6393ToBCP->{$lang} : 'x-none';
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
        push @nodes, {
          name => $targetfield,
          children => [
            { 
              name => 'lom:langstring',
              value => $v,
              attributes => [
                {
                  name  => 'xml:lang',
                  value => $self->_map_iso3_to_bcp($iso6393ToBCP, $lang)
                }
              ]
            }
          ]
        };
      }
    }
  }
  for my $k (keys %{$rec}) {
    if ($k =~ m/^dc_$dcfield$/) {
      for my $v (@{$rec->{$k}}) {
        unless ($foundValues{$v}) {
          push @nodes, {
            name => $targetfield,
            children => [
              { 
                name => 'lom:langstring',
                value => $v
              }
            ]
          };
        }
      }
    }
  }
  return \@nodes;
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

  $uri =~ s/\/$//;

  return $uri;
}

1;
__END__
