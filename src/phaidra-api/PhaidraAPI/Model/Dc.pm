package PhaidraAPI::Model::Dc;

use strict;
use warnings;
use v5.10;
use utf8;
use Mojo::ByteStream qw(b);
use Mojo::Util       qw(xml_escape html_unescape encode decode);
use base             qw/Mojo::Base/;
use XML::LibXML;
use Storable qw(dclone);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Uwmetadata::Extraction;
use PhaidraAPI::Model::Mods::Extraction;
use PhaidraAPI::Model::Jsonld::Extraction;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Languages;

# our %dc_elements = (
#   'contributor' => 1,
#   'coverage' => 1,
#   'creator' => 1,
#   'date' => 1,
#   'description' => 1,
#   'format' => 1,
#   'identifier' => 1,
#   'language' => 1,
#   'publisher' => 1,
#   'relation' => 1,
#   'rights' => 1,
#   'source' => 1,
#   'subject' => 1,
#   'title' => 1,
#   'type' => 1
# );

sub map_mods_2_dc_hash {

  my ($self, $c, $pid, $cmodel, $xml, $metadata_model, $indexing) = @_;

  my $dom;
  if (ref $xml eq 'Mojo::DOM') {
    $dom = $xml;
  }
  else {
    $dom = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($xml);
  }

  my $ext = PhaidraAPI::Model::Mods::Extraction->new;

  #$c->app->log->debug("XXXXXXXXXXX mods xml:".$xml);

  # keep using 'mods' as the first node in selectors to avoid running into relatedItem
  my %dc;
  $dc{title}   = $ext->_get_mods_titles($c, $dom);
  $dc{subject} = $ext->_get_mods_subjects($c, $dom);
  my $classifications = $ext->_get_mods_classifications($c, $dom);
  push @{$dc{subject}}, @$classifications;
  $dc{identifier} = $ext->_get_mods_element_values($c, $dom, 'mods > identifier');
  $dc{relation}   = $ext->_get_mods_relations($c, $dom);
  my $editions = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > edition');
  push @{$dc{relation}}, @$editions;
  $dc{language}    = $ext->_get_mods_element_values($c, $dom, 'mods > language > languageTerm');
  $dc{creator}     = $ext->_get_mods_creators($c, $dom);
  $dc{contributor} = $ext->_get_mods_contributors($c, $dom);
  $dc{date}        = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > dateIssued[keyDate="yes"]');
  $dc{description} = $ext->_get_mods_element_values($c, $dom, 'mods > note');

  # maps specific
  my $scales     = $ext->_get_mods_element_values($c, $dom, 'mods > subject > cartographics > scale');
  my @scales_arr = map {{value => "1:" . $_->{value}}} @$scales;
  push @{$dc{description}}, @scales_arr;

  my $extents = $ext->_get_mods_element_values($c, $dom, 'mods > physicalDescription > extent');
  push @{$dc{description}}, @$extents;

  $dc{publisher} = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > publisher');

  $dc{rights} = $ext->_get_mods_element_values($c, $dom, 'mods > accessCondition[type="use and reproduction"]');

  # FIXME GEO datastream to DCMI BOX

  return \%dc;
}

sub map_jsonld_2_dc_hash {
  my ($self, $c, $pid, $cmodel, $jsonld, $metadata_model, $indexing) = @_;

  my $ext = PhaidraAPI::Model::Jsonld::Extraction->new;

  #$c->app->log->debug("XXXXXXXXXXX mods xml:".$xml);

  my %dc;

  $dc{description} = [];
  $dc{coverage}    = [];
  $dc{subject}     = [];
  $dc{date}        = [];

  $dc{type} = $ext->_get_jsonld_objectlabels($c, $jsonld, 'dcterms:type');

  for my $v (@{$ext->_get_jsonld_objectlabels($c, $jsonld, 'edm:hasType')}) {
    push @{$dc{type}}, $v;
  }

  $dc{title} = $ext->_get_jsonld_titles($c, $jsonld);

  $dc{source} = $ext->_get_jsonld_sources($c, $jsonld);

  $dc{publisher} = $ext->_get_jsonld_publishers($c, $jsonld);

  for my $d (@{$ext->_get_jsonld_descriptions($c, $jsonld)}) {
    push @{$dc{description}}, $d;
  }

  my ($creators, $contributors) = $ext->_get_jsonld_roles($c, $jsonld);
  $dc{creator}     = $creators;
  $dc{contributor} = $contributors;

  for my $s (@{$ext->_get_jsonld_subjects($c, $jsonld)}) {
    push @{$dc{subject}}, $s;
  }

  if ($jsonld->{'dcterms:subject'}) {
    for my $o (@{$jsonld->{'dcterms:subject'}}) {
      if ($o->{'@type'} eq 'phaidra:Subject') {
        my $sub_titles = $ext->_get_jsonld_titles($c, $o);
        for my $s_t (@{$sub_titles}) {
          push @{$dc{title}}, $s_t;
        }

        my $sub_descriptions = $ext->_get_jsonld_descriptions($c, $o);
        for my $s_d (@{$sub_descriptions}) {
          push @{$dc{description}}, $s_d;
        }

        my ($sub_creators, $sub_contributors) = $ext->_get_jsonld_roles($c, $o);
        for my $s_cr (@{$sub_creators}) {
          push @{$dc{creator}}, $s_cr;
        }
        for my $s_co (@{$sub_contributors}) {
          push @{$dc{contributor}}, $s_co;
        }

        my $sub_subjects = $ext->_get_jsonld_subjects($c, $o);
        for my $s_s (@{$sub_subjects}) {
          push @{$dc{subject}}, $s_s;
        }

        my $s_tcs = $ext->_get_jsonld_langvalues($c, $o, 'schema:temporalCoverage');
        for my $s_tc (@{$s_tcs}) {
          push @{$dc{coverage}}, $s_tc;
        }
      }
    }
  }

  $dc{language} = $ext->_get_jsonld_values($c, $jsonld, 'dcterms:language');

  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:date')}) {
    push @{$dc{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:created')}) {
    push @{$dc{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:modified')}) {
    push @{$dc{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:issued')}) {
    push @{$dc{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateAccepted')}) {
    push @{$dc{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateCopyrighted')}) {
    push @{$dc{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateSubmitted')}) {
    push @{$dc{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'rdau:P60071')}) {
    push @{$dc{date}}, $d;
  }

  my $pds = $ext->_get_jsonld_publisheddates($c, $jsonld);
  for my $pd (@{$pds}) {
    push @{$dc{date}}, $pd;
  }

  my $tcs = $ext->_get_jsonld_langvalues($c, $jsonld, 'schema:temporalCoverage');
  for my $tc (@{$tcs}) {
    push @{$dc{coverage}}, $tc;
  }

  $dc{rights} = $ext->_get_jsonld_values($c, $jsonld, 'edm:rights');
  my $rights_sentences = $ext->_get_jsonld_langvalues($c, $jsonld, 'dce:rights');
  for my $rs (@$rights_sentences) {
    push @{$dc{rights}}, $rs;
  }
  for my $d (@{$ext->_get_jsonld_objectlabels($c, $jsonld, 'dcterms:accessRights')}) {
    push @{$dc{rights}}, $d;
  }

  $dc{format} = $ext->_get_jsonld_values($c, $jsonld, 'ebucore:hasMimeType');

  return \%dc;
}

sub map_uwmetadata_2_dc_hash {

  my ($self, $c, $pid, $cmodel, $xml, $tree, $metadata_model, $indexing) = @_;

  my $ext = PhaidraAPI::Model::Uwmetadata::Extraction->new;

  my %doc_uwns = ();

  my $dom;
  if (ref $xml eq 'Mojo::DOM') {
    $dom = $xml;

    # ns0="http://phaidra.univie.ac.at/XML/metadata/V1.0"

    # fill $doc_ns, namespace mapping for this document
    my $nss = $dom->find('uwmetadata')->first->attr;
    while (my ($k, $v) = each %{$nss}) {
      $doc_uwns{$PhaidraAPI::Model::Uwmetadata::Extraction::uwns{$v}} = $k;
    }
  }
  else {
    $dom = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($xml);

    # xmlns:ns0="http://phaidra.univie.ac.at/XML/metadata/V1.0"

    # fill $doc_ns, namespace mapping for this document
    my $nss = $dom->find('uwmetadata')->first->attr;
    for my $nsa_key (keys %{$nss}) {
      $nsa_key =~ /(\w+):(\w+)/;
      $doc_uwns{$PhaidraAPI::Model::Uwmetadata::Extraction::uwns{$nss->{$nsa_key}}} = $2;
    }
  }

  my $identifiers      = $ext->_get_uwm_identifiers($c, $dom, \%doc_uwns, $tree, $metadata_model);
  my $titles           = $ext->_get_titles($c, $dom, \%doc_uwns);
  my $descriptions     = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:general > ' . $doc_uwns{'lom'} . '\:description');
  my $rightsStatements = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:rights > ' . $doc_uwns{'lom'} . '\:description');
  my $languages        = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:language');
  my $keywords         = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:keyword');
  my $classifications  = $ext->_get_uwm_classifications($c, $dom, \%doc_uwns);
  my $creators         = $ext->_get_creators($c, $dom, \%doc_uwns);
  my $dates            = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'digitalbook'} . '\:releaseyear');

  unless (defined($dates)) {
    $dates = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:upload_date');
  }
  $dates = [] unless (defined($dates));
  my $embargodates = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'extended'} . '\:infoeurepoembargo');
  for my $em (@{$embargodates}) {
    push @$dates, {value => 'info:eu-repo/date/embargoEnd/' . $em->{value}};
  }
  my $contributedates = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:date');
  for my $cd (@{$contributedates}) {
    push @$dates, $cd;
  }
  my $types = $ext->_get_types($c, $cmodel, $dom, \%doc_uwns, $tree, $metadata_model);

  my $versions = $ext->_get_versions($c, $dom, \%doc_uwns, $tree, $metadata_model);

  my $formats = $ext->_get_formats($c, $pid, $cmodel, $dom, \%doc_uwns);

  my $srcs = $ext->_get_sources($c, $dom, \%doc_uwns, $tree, $metadata_model);

  my $publishers = $ext->_get_publishers($c, $dom, \%doc_uwns);

  my $contributors = $ext->_get_contributors($c, $dom, \%doc_uwns);

  my $relations = $ext->_get_uwm_relations($c, $dom, \%doc_uwns);

  my $coverages = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:coverage');

  my $infoeurepoaccess = $ext->_get_infoeurepoaccess($c, $dom, \%doc_uwns, $tree, $metadata_model);

  my $licenses = $ext->_get_licenses($c, $dom, \%doc_uwns, $tree, $metadata_model);

  # FIXME GEO datastream to DCMI BOX

  # get provenience versions

  push @$identifiers, {value => $c->app->config->{scheme} . "://" . $c->app->config->{phaidra}->{baseurl} . "/" . $pid};

  my @subjects;
  for my $k (@{$keywords}) {
    push @subjects, $k;
  }
  for my $c (@{$classifications}) {
    push @subjects, $c;
  }

  my @langs;
  for my $l (@{$languages}) {
    unless ($l->{value} eq 'xx') {
      push @langs, {value => $PhaidraAPI::Model::Languages::iso639map{$l->{value}}};
    }
  }

  my %dc;
  $dc{identifier}  = $identifiers  if (defined($identifiers));
  $dc{title}       = $titles       if (defined($titles));
  $dc{description} = $descriptions if (defined($descriptions));
  $dc{subject}     = \@subjects    if (@subjects);
  $dc{language}    = \@langs       if (@langs);
  $dc{creator}     = $creators     if (defined($creators));
  $dc{date}        = $dates        if (defined($dates));
  $dc{type}        = $types;
  $dc{source}      = $srcs;
  $dc{publisher}   = $publishers   if (defined($publishers));
  $dc{contributor} = $contributors if (defined($contributors));
  $dc{relation}    = $relations;
  $dc{coverage}    = $coverages;

  # copy this, not just assign reference
  # otherwise the $license will contain the $infoeurepoaccess values later
  if (($cmodel ne 'Resource') && ($cmodel ne 'Collection')) {
    for my $v (@$versions) {
      push @{$dc{type}}, $v;
    }
    for my $v (@{$licenses}) {
      push @{$dc{rights}}, $v;
    }
    for my $v (@{$infoeurepoaccess}) {
      push @{$dc{rights}}, $v;
    }
    for my $v (@{$rightsStatements}) {
      push @{$dc{rights}}, $v;
    }
    $dc{format} = $formats;
  }

  return \%dc;
}

1;
__END__
