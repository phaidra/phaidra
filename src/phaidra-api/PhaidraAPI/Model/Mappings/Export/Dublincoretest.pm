package PhaidraAPI::Model::Mappings::Export::Dublincoretest;

use strict;
use warnings;
use v5.10;
use utf8;
use Switch;
use Mojo::JSON qw(encode_json decode_json);
use Mojo::ByteStream qw(b);
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Languages;
use PhaidraAPI::Model::Vocabulary;

sub get_metadata {
  my ($self, $c, $rec, $set) = @_;
  my @el          = qw/contributor coverage creator date description format identifier language publisher relation rights source subject title type/;
  my %valuesCheck = map {$_ => {}} @el;
  my @metadata;

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
      my $val  = 'isPartOf:'.$c->app->config->{scheme}.'://' . $c->app->config->{phaidra}->{baseurl} . '/' . $v;
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
    my $voc_model = PhaidraAPI::Model::Vocabulary->new;
    my $res = $voc_model->get_vocabulary($c, 'roles');
    my $rolesvoc = $res->{vocabulary};

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
            if ($as eq $c->app->config->{ir}->{adminset}) {
              $field{values} = ["The abstract is available here: https://" . $c->app->config->{ir}->{baseurl} . "/" . $rec->{pid}];
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
    unless ($f->{name} eq 'creator' or $f->{name} eq 'contributor') {
      if ($f->{name} eq $fl->{name} and $f->{lang} eq $fl->{lang}) {
        return 1;
      }
    }
  }
  return 0;
}

sub _get_role_label_de {
  my ($self, $c, $rolesvoc, $rolecode) = @_;

  if ($rolecode eq 'datasupplier') {
    return 'Datenlieferant*in';
  }

  for my $r (@{$rolesvoc}) {
    if ($r->{'@id'} eq 'role:'.$rolecode) {
      return $r->{'skos:prefLabel'}->{'deu'};
    }
  }
  return $rolecode; # Default to role code if no label found
}

sub _add_roles_with_id {
  my ($self, $rolesvoc, $rec, $metadata) = @_;
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
                $name = $contr->{'schema:familyName'}[0]->{'@value'} if $contr->{'schema:familyName'}[0]->{'@value'};
                $name = $name.', ' if $contr->{'schema:givenName'}[0]->{'@value'} && $name;
                $name = $name.$contr->{'schema:givenName'}[0]->{'@value'} if $contr->{'schema:givenName'}[0]->{'@value'};
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
                my $idv = $contr->{'skos:exactMatch'}[0]->{'@value'};
                $idv =~ s{^(?:https?://)?orcid\.org/}{};
                $idv =~ s/\s+//g;
                $id = $PhaidraAPI::Model::Jsonld::Extraction::jsonld_identifiers{$contr->{'skos:exactMatch'}[0]->{'@type'}} . ':' . $idv;
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

            push @{$field{values}}, $role;
          }
          push @{$metadata}, \%field;
        }
      }
    }
  }
}

sub _add_uwm_roles_with_id {
  my ($self, $rolesvoc, $rec, $metadata) = @_;

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
          $e->{orcid} =~ s{^(?:https?://)?orcid\.org/}{};
          $e->{orcid} =~ s/\s+//g;
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
          $name = $name . ', ' . $e->{firstname} if $e->{firstname};
          $affiliation = $e->{institution} if $e->{institution};
        }
        else {
          if ($e->{institution}) {
            $name = $e->{institution};
          }
        }

        unless ($name) {
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

        push @{$field{values}}, $role;
      }
      push @fields, \%field;
    }
  }

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

1;
__END__
