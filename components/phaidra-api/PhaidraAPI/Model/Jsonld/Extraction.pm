package PhaidraAPI::Model::Jsonld::Extraction;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Terms;

our %jsonld_contributor_roles = ('ctb' => 1);

our %jsonld_creator_roles = (
  'aut' => 1,
  'prt' => 1,
  'edt' => 1,
  'ill' => 1,
  'dte' => 1,
  'drm' => 1,
  'ctg' => 1,
  'ltg' => 1,
  'egr' => 1
);

our %jsonld_identifiers = (
  'schema:url'   => 'url',
  'ids:urn'      => 'urn',
  'ids:hdl'      => 'hdl',
  'ids:doi'      => 'doi',
  'ids:isbn'     => 'isbn',
  'ids:issn'     => 'issn',
  'ids:local'    => 'local',
  'ids:orcid'    => 'orcid',
  'ids:viaf'     => 'viaf',
  'ids:gnd'      => 'gnd',
  'ids:wikidata' => 'wikidata',
  'ids:lcnaf'    => 'lcnaf',
  'ids:isni'     => 'isni',
  'ids:uri'      => 'uri'
);

sub _get_jsonld_titles {

  my ($self, $c, $jsonld) = @_;

  my @dctitles;

  my $titles = $jsonld->{'dce:title'};

  for my $o (@{$titles}) {
    my $new = {value => $o->{'bf:mainTitle'}[0]->{'@value'}};
    if (exists($o->{'bf:subtitle'}) && exists($o->{'bf:subtitle'}[0]->{'@value'}) && ($o->{'bf:subtitle'}[0]->{'@value'} ne '')) {
      $new->{value} = $new->{value} . " : " . $o->{'bf:subtitle'}[0]->{'@value'};
    }
    if (exists($o->{'bf:mainTitle'}[0]->{'@language'}) && ($o->{'bf:mainTitle'}[0]->{'@language'} ne '')) {
      $new->{lang} = $o->{'bf:mainTitle'}[0]->{'@language'};
    }
    push @dctitles, $new;
  }

  return \@dctitles;
}

sub _get_jsonld_titles_subtitles {

  my ($self, $c, $jsonld) = @_;

  my @dctitles;

  my $titles = $jsonld->{'dce:title'};

  for my $o (@{$titles}) {
    my $new = {title => $o->{'bf:mainTitle'}[0]->{'@value'}};
    if (exists($o->{'bf:subtitle'}) && exists($o->{'bf:subtitle'}[0]->{'@value'}) && ($o->{'bf:subtitle'}[0]->{'@value'} ne '')) {
      $new->{subtitle} = $o->{'bf:subtitle'}[0]->{'@value'};
    }
    if (exists($o->{'bf:mainTitle'}[0]->{'@language'}) && ($o->{'bf:mainTitle'}[0]->{'@language'} ne '')) {
      $new->{lang} = $o->{'bf:mainTitle'}[0]->{'@language'};
    }
    push @dctitles, $new;
  }

  return \@dctitles;
}

sub _get_jsonld_sources {

  my ($self, $c, $jsonld) = @_;

  my @dcsources;

  if (exists($jsonld->{'rdau:P60193'})) {
    my $sources = $jsonld->{'rdau:P60193'};

    for my $o (@{$sources}) {
      my $new = {value => $o->{'dce:title'}[0]->{'bf:mainTitle'}[0]->{'@value'}};
      if (exists($o->{'dce:title'}[0]->{'bf:mainTitle'}[0]->{'@language'}) && ($o->{'dce:title'}[0]->{'bf:mainTitle'}[0]->{'@language'} ne '')) {
        $new->{lang} = $o->{'dce:title'}[0]->{'bf:mainTitle'}[0]->{'@language'};
      }
      push @dcsources, $new;
      if (exists($o->{'ids:issn'}) && $o->{'ids:issn'} ne '') {
        push @dcsources, {value => 'issn:' . $o->{'ids:issn'}[0]};
      }
    }
  }

  return \@dcsources;
}

sub _get_jsonld_descriptions {

  my ($self, $c, $jsonld) = @_;

  my @dcdescriptions;

  #$c->app->log->debug("XXXXXXXXXXXX:\n".$c->app->dumper($jsonld->{'bf:note'}));
  for my $o (@{$jsonld->{'bf:note'}}) {
    for my $l (@{$o->{'skos:prefLabel'}}) {
      my $new = {value => $l->{'@value'}};
      if (exists($l->{'@language'}) && ($l->{'@language'} ne '')) {
        $new->{lang} = $l->{'@language'};
      }
      push @dcdescriptions, $new;
    }
  }

  return \@dcdescriptions;
}

sub _get_jsonld_identifiers {

  my ($self, $c, $jsonld) = @_;

  my @ids;
  if ($jsonld->{'rdam:P30004'}) {
    for my $id (@{$jsonld->{'rdam:P30004'}}) {
      push @ids, $id;
    }
  }
  return \@ids;
}

sub _get_jsonld_objectlabels {

  my ($self, $c, $jsonld, $predicate) = @_;

  my @labels;

  my $objects = $jsonld->{$predicate};
  if (ref($objects) ne 'ARRAY') {
    $objects = [$jsonld->{$predicate}];
  }
  for my $o (@{$objects}) {
    my $labels = $o->{'skos:prefLabel'};
    if (ref($labels) ne 'ARRAY') {
      $labels = [$o->{'skos:prefLabel'}];
    }
    for my $l (@{$labels}) {
      my $new = {value => $l->{'@value'}};
      if (exists($l->{'@language'}) && ($l->{'@language'} ne '')) {
        $new->{lang} = $l->{'@language'};
      }
      push @labels, $new;
    }
  }

  return \@labels;
}

sub _get_jsonld_subjects {

  my ($self, $c, $jsonld) = @_;

  my @dcsubjects;
  my $subs = $jsonld->{'dcterms:subject'};

  if ($jsonld->{'dce:subject'}) {
    for my $s (@{$jsonld->{'dce:subject'}}) {
      push @{$subs}, $s;
    }
  }

  for my $o (@{$subs}) {

    next if ($o->{'@type'} eq 'phaidra:Subject');

    for my $s (@{$o->{'skos:prefLabel'}}) {
      my $new = {value => $s->{'@value'}};
      if (exists($s->{'@language'}) && ($s->{'@language'} ne '')) {
        $new->{lang} = $s->{'@language'};
      }

      push @dcsubjects, $new;
    }

    for my $s (@{$o->{'rdfs:label'}}) {
      my $new = {value => $s->{'@value'}};
      if (exists($s->{'@language'}) && ($s->{'@language'} ne '')) {
        $new->{lang} = $s->{'@language'};
      }

      push @dcsubjects, $new;
    }

  }

  return \@dcsubjects;
}

sub _get_jsonld_roles {

  my ($self, $c, $jsonld) = @_;

  my @creators;
  my @contributors;
  for my $pred (keys %{$jsonld}) {
    if ($pred =~ m/role:(\w+)/g) {
      my $role = $1;
      for my $contr (@{$jsonld->{$pred}}) {
        my $name;
        my $givenName;
        my $familyName;
        my $type;
        if ($contr->{'@type'} eq 'schema:Person') {
          if ($contr->{'schema:givenName'} || $contr->{'schema:familyName'}) {
            $name       = $contr->{'schema:givenName'}[0]->{'@value'} . " " . $contr->{'schema:familyName'}[0]->{'@value'};
            $givenName  = $contr->{'schema:givenName'}[0]->{'@value'};
            $familyName = $contr->{'schema:familyName'}[0]->{'@value'};
          }
          else {
            $name = $contr->{'schema:name'}[0]->{'@value'};
          }
          $type = 'personal';
        }
        elsif ($contr->{'@type'} eq 'schema:Organization') {
          $name = $contr->{'schema:name'}[0]->{'@value'};
          $type = 'corporate';
        }
        else {
          $c->app->log->error("_get_jsonld_roles: Unknown contributor type in jsonld");
        }
        if ($contr->{'schema:affiliation'}) {
          for my $aff (@{$contr->{'schema:affiliation'}}) {
            if ($aff->{'skos:exactMatch'}) {
              for my $id (@{$aff->{'skos:exactMatch'}}) {
                my $pp = $c->app->directory->org_get_parentpath($c, $id);
                if ($pp->{status} eq 200) {
                  my @parentpathlabels;
                  for my $parent (@{$pp->{parentpath}}) {
                    if ($parent->{'@id'} ne 'https://pid.phaidra.org/univie-org/1DVY-S9TG') {
                      if (exists($parent->{'skos:prefLabel'})) {
                        if (exists($parent->{'skos:prefLabel'}->{'eng'})) {
                          push @parentpathlabels, $parent->{'skos:prefLabel'}->{'eng'};
                        }
                      }
                    }
                  }
                  if (scalar @parentpathlabels > 0) {
                    $name .= ' (' . join(', ', @parentpathlabels) . ')';
                  }
                }
              }
            }
            elsif (exists($aff->{'schema:name'})) {
              for my $affname (@{$aff->{'schema:name'}}) {
                $name .= ' (' . $affname->{'@value'} . ')';
              }
            }
          }
        }
        if ($jsonld_creator_roles{$role}) {
          push @creators, {value => $name, firstname => $givenName, lastname => $familyName, type => $type};
        }
        else {
          if ($role ne 'uploader') {
            push @contributors, {value => $name, firstname => $givenName, lastname => $familyName, type => $type};
          }
        }
      }
    }
  }

  return (\@creators, \@contributors);
}

sub _get_jsonld_publisheddates {
  my ($self, $c, $jsonld) = @_;

  my @arr;
  if (exists($jsonld->{'bf:provisionActivity'})) {
    for my $pa (@{$jsonld->{'bf:provisionActivity'}}) {
      if (exists($pa->{'bf:date'})) {
        for my $date (@{$pa->{'bf:date'}}) {
          push @arr, {value => $date};
        }
      }
    }
  }
  if (exists($jsonld->{'rdau:P60101'})) {
    for my $ci (@{$jsonld->{'rdau:P60101'}}) {
      if (exists($ci->{'bf:provisionActivity'})) {
        for my $pa (@{$ci->{'bf:provisionActivity'}}) {
          if (exists($pa->{'bf:date'})) {
            for my $date (@{$pa->{'bf:date'}}) {
              push @arr, {value => $date};
            }
          }
        }
      }
    }
  }
  return \@arr;
}

sub _get_jsonld_publishers {
  my ($self, $c, $jsonld) = @_;

  my @arr;
  my $provisionActivity;
  if (exists($jsonld->{'rdau:P60101'})) {
    for my $ci (@{$jsonld->{'rdau:P60101'}}) {
      if (exists($ci->{'bf:provisionActivity'})) {
        $provisionActivity = $ci->{'bf:provisionActivity'};
      }
    }
  }
  if (exists($jsonld->{'bf:provisionActivity'})) {
    $provisionActivity = $jsonld->{'bf:provisionActivity'};
  }
  if ($provisionActivity) {
    for my $pa (@{$provisionActivity}) {
      if (exists($pa->{'bf:agent'})) {
        for my $ag (@{$pa->{'bf:agent'}}) {
          if (exists($ag->{'schema:name'})) {
            my %publisherNames;
            for my $pn (@{$ag->{'schema:name'}}) {
              if (exists($pn->{'@language'}) && ($pn->{'@language'} ne 'xxx')) {
                $publisherNames{$pn->{'@language'}} = $pn->{'@value'};
              }
              else {
                $publisherNames{'nolang'} = $pn->{'@value'};
              }
            }
            my $publisher;
            my $addInstitutionName = 0;
            if (exists($ag->{'skos:exactMatch'})) {
              for my $pubId (@{$ag->{'skos:exactMatch'}}) {
                if (rindex($pubId, 'https://pid.phaidra.org/', 0) == 0) {
                  $addInstitutionName = 1;
                  last;
                }
              }
            }
            if (exists($publisherNames{'nolang'})) {
              $publisher = $publisherNames{'nolang'} if $publisherNames{'nolang'} ne '';
            }
            else {
              if (exists($publisherNames{'eng'})) {
                $publisher = $publisherNames{'eng'} if $publisherNames{'eng'} ne '';
              }
              else {
                for my $pubNameLang (keys %publisherNames) {
                  $publisher = $publisherNames{$pubNameLang} if $publisherNames{$pubNameLang} ne '';
                  last;
                }
              }
            }
            if ($addInstitutionName) {
              my $institutionName = $c->app->directory->get_org_name($c, 'eng');
              if ($institutionName) {
                if ((index($publisher, $institutionName) == -1)) {
                  $publisher = "$institutionName. $publisher";
                }
              }
            }
            push @arr, {value => $publisher};
          }
        }
      }
    }
  }
  return \@arr;
}

sub _get_jsonld_langvalues {

  my ($self, $c, $jsonld, $predicate) = @_;

  my @arr;
  for my $l (@{$jsonld->{$predicate}}) {
    my $new = {value => $l->{'@value'}};
    if (exists($l->{'@language'}) && ($l->{'@language'} ne '')) {
      $new->{lang} = $l->{'@language'};
    }
    push @arr, $new;
  }
  return \@arr;
}

sub _get_jsonld_values {

  my ($self, $c, $jsonld, $predicate) = @_;

  my $p = $jsonld->{$predicate};
  my @arr;
  if (ref($p) eq 'ARRAY') {
    for my $l (@{$p}) {
      unless (ref $l eq ref {}) {
        push @arr, {value => $l};
      }
    }
  }
  else {
    push @arr, {value => $p};
  }
  return \@arr;
}

1;
__END__
