package PhaidraAPI::Model::Datacite;

use strict;
use warnings;
use v5.10;
use utf8;

use Mojo::ByteStream qw(b);
use Mojo::Util qw(xml_escape encode decode);
use base qw/Mojo::Base/;
use XML::LibXML;
use Storable qw(dclone);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Uwmetadata::Extraction;
use PhaidraAPI::Model::Mods::Extraction;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Languages;

use Data::Dumper;
$Data::Dumper::Indent = 1;

our $datacite_ns = "http://datacite.org/schema/kernel-4";

our %cmodelMapping = (
  'Picture'       => 'Image',
  'Audio'         => 'Sound',
  'Collection'    => 'Collection',
  'Container'     => 'Dataset',
  'Video'         => 'Audiovisual',
  'PDFDocument'   => 'Text',
  'LaTeXDocument' => 'Text',
  'Resource'      => 'InteractiveResource',
  'Asset'         => 'Other',
  'Book'          => 'Other',
  'Page'          => 'Other',
  'Paper'         => 'Text'
);

sub get {

  my ($self, $c, $pid, $username, $password) = @_;

  my $res = {alerts => [], status => 200};

  my $search_model = PhaidraAPI::Model::Search->new;
  my $object_model = PhaidraAPI::Model::Object->new;

  my $cmodel;
  my $res_cmodel = $search_model->get_cmodel($c, $pid);
  push @{$res->{alerts}}, @{$res_cmodel->{alerts}} if scalar @{$res_cmodel->{alerts}} > 0;
  if ($res_cmodel->{status} ne 200) {
    $res->{status} = $res_cmodel->{status};
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  my $r = $search_model->datastreams_hash($c, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }

  if ($r->{dshash}->{'MODS'}) {

    my $r1 = $object_model->get_datastream($c, $pid, 'MODS', $username, $password, 1);
    if ($r1->{status} ne 200) {
      return $r1;
    }
    $r1->{MODS} = b($r1->{MODS})->decode('UTF-8');
    my $datacite = $self->map_mods_2_datacite($c, $pid, $cmodel, $r1->{MODS});

    $res->{datacite} = $datacite;
  }

  if ($r->{dshash}->{'UWMETADATA'}) {

    my $r1 = $object_model->get_datastream($c, $pid, 'UWMETADATA', $username, $password, 1);
    if ($r1->{status} ne 200) {
      return $r1;
    }
    $r1->{UWMETADATA} = b($r1->{UWMETADATA})->decode('UTF-8');
    my $datacite = $self->map_uwmetadata_2_datacite($c, $pid, $cmodel, $r1->{UWMETADATA});

    $res->{datacite} = $datacite;
  }

  if ($r->{dshash}->{'JSON-LD'}) {

    my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
    my $r_jsonld     = $jsonld_model->get_object_jsonld_parsed($c, $pid, $c->app->config->{phaidra}->{intcallusername}, $c->app->config->{phaidra}->{intcallpassword});
    if ($r_jsonld->{status} ne 200) {
      return $r_jsonld;
    }
    else {
      my $jsonld   = $r_jsonld->{'JSON-LD'};
      my $datacite = $self->map_jsonld_2_datacite($c, $pid, $cmodel, $jsonld);
      $res->{datacite} = $datacite;
    }
  }

  return $res;
}

sub map_uwmetadata_2_datacite {

  my ($self, $c, $pid, $cmodel, $xml) = @_;

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($c, $pid);
  my $index       = $r->{index};

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;

  my $r0 = $metadata_model->metadata_tree($c);
  if ($r0->{status} ne 200) {
    return $r0;
  }
  my $tree = $r0->{metadata_tree};

  my $dom = Mojo::DOM->new();
  $dom->xml(1);
  $dom->parse($xml);

  my $ext = PhaidraAPI::Model::Uwmetadata::Extraction->new;

  # $c->app->log->debug("112 UWM ext=".Dumper($ext));

  my %doc_uwns = {};

  # FIXME GEO datastream to DCMI BOX

  # fill $doc_ns, namespace mapping for this document
  my $nss = $dom->find('uwmetadata')->first->attr;
  for my $nsa_key (keys %{$nss}) {
    $nsa_key =~ /(\w+):(\w+)/;
    $doc_uwns{$PhaidraAPI::Model::Uwmetadata::Extraction::uwns{$nss->{$nsa_key}}} = $2;
  }

  my %data;
  my $relids  = $self->_get_relsext_identifiers($c, $pid);
  my $relids2 = $ext->_get_uwm_identifiers($c, $dom, \%doc_uwns, $tree, $metadata_model);
  for my $ri (@{$relids2}) {
    push @$relids, $ri;
  }
  for my $relid (@$relids) {
    if ($relid->{value} =~ /hdl/i) {
      $relid->{type} = 'Handle';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /doi/i) {
      $relid->{type} = 'DOI';
      $relid->{value} =~ s/^doi://;
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /urn/i) {
      $relid->{type} = 'URN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /issn/i) {
      $relid->{type} = 'ISSN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /isbn/i) {
      $relid->{type} = 'ISBN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /eissn/i) {
      $relid->{type} = 'EISSN';
      push @{$data{identifiers}}, $relid;
    }
  }
  push @{$data{identifiers}}, {value => "http://" . $c->app->config->{phaidra}->{baseurl} . "/" . $pid, type => "URL"};
  $data{titles}          = $ext->_get_titles($c, $dom, \%doc_uwns);
  $data{descriptions}    = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:description');
  $data{creators}        = $ext->_get_creators($c, $dom, \%doc_uwns);
  $data{pubyears}        = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'digitalbook'} . '\:releaseyear');      # does not work!
  $data{uploaddates}     = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:upload_date');
  $data{embargodates}    = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'extended'} . '\:infoeurepoembargo');
  $data{formats}         = $ext->_get_formats($c, $pid, $cmodel, $dom, \%doc_uwns);
  push @{$data{filesizes}}, {value => $index->{size}};
  $data{publishers}      = $ext->_get_publishers($c, $dom, \%doc_uwns);
  $data{publicationYear} = $ext->_get_releaseyear($c, $dom, \%doc_uwns);
  $data{contributors}    = $ext->_get_contributors($c, $dom, \%doc_uwns);
  $data{licenses}        = $ext->_get_licenses_datacite($c, $dom, \%doc_uwns, $tree, $metadata_model);
  $data{upload_date}     = $ext->_get_upload_date($c, $dom, \%doc_uwns, $tree, $metadata_model);

  my $keywords        = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:keyword');
  my $classifications = $ext->_get_uwm_classifications($c, $dom, \%doc_uwns);
  for my $k (@{$keywords}) {
    push @{$data{subjects}}, $k;
  }
  for my $c (@{$classifications}) {
    push @{$data{subjects}}, $c;
  }
  my $languages = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:language');
  for my $l (@{$languages}) {
    unless ($l->{value} eq 'xx') {
      push @{$data{langs}}, {value => $l->{value}};
    }
  }

  return $self->data_2_datacite($c, $cmodel, \%data);
}

sub map_mods_2_datacite {

  my ($self, $c, $pid, $cmodel, $xml) = @_;


  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($c, $pid);
  my $index       = $r->{index};

  my $dom = Mojo::DOM->new();
  $dom->xml(1);
  $dom->parse($xml);

  my $ext = PhaidraAPI::Model::Mods::Extraction->new;

  #$c->app->log->debug("XXXXXXXXXXX mods xml:".$xml);

  # keep using 'mods' as the first node in selectors to avoid running into relatedItem
  my %data;
  $data{titles}   = $ext->_get_mods_titles($c, $dom);
  $data{subjects} = $ext->_get_mods_subjects($c, $dom);
  my $classifications = $ext->_get_mods_classifications($c, $dom);
  push @{$data{subjects}}, @$classifications;
  my $relids  = $self->_get_relsext_identifiers($c, $pid);
  my $relids2 = $ext->_get_mods_element_values($c, $dom, 'mods > identifier');

  for my $ri (@{$relids2}) {
    push @$relids, $ri;
  }
  for my $relid (@$relids) {
    my $rrr = $relid->{value} =~ /doi/i;
    if ($relid->{value} =~ /hdl/i) {
      $relid->{type} = 'Handle';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /doi/i) {
      $relid->{type} = 'DOI';
      $relid->{value} =~ s/^doi://;
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /urn/i) {
      $relid->{type} = 'URN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /issn/i) {
      $relid->{type} = 'ISSN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /isbn/i) {
      $relid->{type} = 'ISBN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /eissn/i) {
      $relid->{type} = 'EISSN';
      push @{$data{identifiers}}, $relid;
    }
  }
  push @{$data{identifiers}}, {value => "http://" . $c->app->config->{phaidra}->{baseurl} . "/" . $pid, type => "URL"};
  $data{relations} = $ext->_get_mods_relations($c, $dom);
  my $editions = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > edition');
  push @{$data{relations}}, @$editions;
  $data{languages}    = $ext->_get_mods_element_values($c, $dom, 'mods > language > languageTerm');
  $data{creators}     = $ext->_get_mods_creators($c, $dom, 'p');
  $data{contributors} = $ext->_get_mods_contributors($c, $dom, 'p');
  my $issueddates = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > dateIssued[keyDate="yes"]');

  for my $id (@{$issueddates}) {
    push @{$data{dates}}, {value => $id, type => 'issued'};
  }
  $data{descriptions} = $ext->_get_mods_element_values($c, $dom, 'mods > note');
  $data{publishers}   = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > publisher');
  $data{rights}       = $ext->_get_mods_element_values($c, $dom, 'mods > accessCondition[type="use and reproduction"]');
  push @{$data{filesizes}}, {value => $index->{size}};

  return $self->data_2_datacite($c, $cmodel, \%data);
}

sub map_jsonld_2_datacite {

  my ($self, $c, $pid, $cmodel, $jsonld) = @_;

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($c, $pid);
  my $index       = $r->{index};
  my $ext         = PhaidraAPI::Model::Jsonld::Extraction->new;

  my $titles     = $ext->_get_jsonld_titles_subtitles($c, $jsonld);
  my $source     = $ext->_get_jsonld_sources($c, $jsonld);
  my $publishers = $ext->_get_jsonld_publishers($c, $jsonld);
  my $languages  = $ext->_get_jsonld_values($c, $jsonld, 'dcterms:language');
  my $licenses   = $ext->_get_jsonld_values($c, $jsonld, 'edm:rights');
  my $formats    = $ext->_get_jsonld_values($c, $jsonld, 'ebucore:hasMimeType');
  my ($creators, $contributors) = $ext->_get_jsonld_roles($c, $jsonld);

  my $descriptions = [];
  for my $d (@{$ext->_get_jsonld_descriptions($c, $jsonld)}) {
    push @{$descriptions}, $d;
  }

  my $subjects = [];
  for my $s (@{$ext->_get_jsonld_subjects($c, $jsonld)}) {
    push @{$subjects}, $s;
  }

  if ($jsonld->{'dcterms:subject'}) {
    for my $o (@{$jsonld->{'dcterms:subject'}}) {
      if ($o->{'@type'} eq 'phaidra:Subject') {
        my $sub_titles = $ext->_get_jsonld_titles_subtitles($c, $o);
        for my $s_t (@{$sub_titles}) {
          push @{$titles}, $s_t;
        }

        my $sub_descriptions = $ext->_get_jsonld_descriptions($c, $o);
        for my $s_d (@{$sub_descriptions}) {
          push @{$descriptions}, $s_d;
        }

        my ($sub_creators, $sub_contributors) = $ext->_get_jsonld_roles($c, $o);
        for my $s_cr (@{$sub_creators}) {
          push @{$creators}, $s_cr;
        }
        for my $s_co (@{$sub_contributors}) {
          push @{$contributors}, $s_co;
        }

        my $sub_subjects = $ext->_get_jsonld_subjects($c, $o);
        for my $s_s (@{$sub_subjects}) {
          push @{$subjects}, $s_s;
        }
      }
    }
  }

  my %data;
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:created')}) {
    push @{$data{dates}}, {value => $d->{value}, type => 'Created'};
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:modified')}) {
    push @{$data{dates}}, {value => $d->{value}, type => 'Modified'};
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:issued')}) {
    push @{$data{dates}}, {value => $d->{value}, type => 'Issued'};
    if ($d->{value}) {
      push @{$data{publicationYear}}, {value => substr($d->{value}, 0, 4)};
    }
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateAccepted')}) {
    push @{$data{dates}}, {value => $d->{value}, type => 'Accepted'};
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateCopyrighted')}) {
    push @{$data{dates}}, {value => $d->{value}, type => 'Copyrighted'};
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateSubmitted')}) {
    push @{$data{dates}}, {value => $d->{value}, type => 'Submitted'};
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'rdau:P60071')}) {
    push @{$data{dates}}, {value => $d->{value}, type => 'Created'};
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:available')}) {
    push @{$data{embargodates}}, $d;
  }

  my $relids = $self->_get_relsext_identifiers($c, $pid);
  for my $relid (@$relids) {
    if ($relid->{value} =~ /hdl/i) {
      $relid->{type} = 'Handle';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /doi/i) {
      $relid->{type} = 'DOI';
      $relid->{value} =~ s/^doi://;
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /urn/i) {
      $relid->{type} = 'URN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /issn/i) {
      $relid->{type} = 'ISSN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /isbn/i) {
      $relid->{type} = 'ISBN';
      push @{$data{identifiers}}, $relid;
    }
    elsif ($relid->{value} =~ /eissn/i) {
      $relid->{type} = 'EISSN';
      push @{$data{identifiers}}, $relid;
    }
  }
  my $ids = $ext->_get_jsonld_identifiers($c, $jsonld);
  for my $id (@{$ids}) {
    if ($id->{'@type'} eq 'ids:hdl') {
      push @{$data{identifiers}}, {type => 'Handle', value => $id->{'@value'}};
    }
    elsif ($id->{'@type'} eq 'ids:doi') {
      push @{$data{identifiers}}, {type => 'DOI', value => $id->{'@value'}};
    }
    elsif ($id->{'@type'} eq 'ids:urn') {
      push @{$data{identifiers}}, {type => 'URN', value => $id->{'@value'}};
    }
    elsif ($id->{'@type'} eq 'ids:isbn') {
      push @{$data{identifiers}}, {type => 'ISBN', value => $id->{'@value'}};
    }
  }
  push @{$data{identifiers}}, {value => "http://" . $c->app->config->{phaidra}->{baseurl} . "/" . $pid, type => "URL"};

  $data{titles}       = $titles;
  $data{descriptions} = $descriptions;
  $data{creators}     = $creators;
  $data{subjects}     = $subjects;
  $data{formats}      = $formats;
  push @{$data{filesizes}}, {value => $index->{size}};
  $data{publishers}   = $publishers;
  $data{contributors} = $contributors;
  push @{$data{uploaddates}}, {value => $index->{created}};

  for my $l (@{$languages}) {
    unless ($l->{value} eq 'zxx') {
      push @{$data{langs}}, {value => $l->{value}};
    }
  }
  for my $lic (@{$licenses}) {
    push @{$data{licenses}}, {value => $lic->{value}, link_uri => $lic->{value}};
  }

  #$c->app->log->debug("XXXXXXXXXXXXXX datacite data:" . $c->app->dumper(\%data));

  return $self->data_2_datacite($c, $cmodel, \%data);
}

sub data_2_datacite {

  my ($self, $c, $cmodel, $data) = @_;

  my @datacite;
  my @errors;
  my $res = {
    'status'            => 'OK',
    'datacite_elements' => \@datacite,
    'errors'            => \@errors,
    'data'              => $data,
  };

=begin comment

... does not apply, we need a DataCite DOI, no just any DOI

  if(exists($data->{identifiers})){
    #<identifier identifierType="DOI">10.5072/example-full</identifier>
    for my $i (@{$data->{identifiers}}){
      if($i->{type} eq "DOI"){
        push @datacite, {
          xmlname => "identifier",
          value => $i->{value},
          attributes => [
            {
              xmlname => "identifierType",
              value => $i->{type}
            }
          ]
        };
      }
    }

=end comment
=cut

=begin comment

DataCite is unhappy about this (or the ordering)

    #
    #<alternateIdentifiers>
    #  <alternateIdentifier alternateIdentifierType="URL">
    #    http://schema.datacite.org/schema/meta/kernel-3.1/example/datacite-example-full-v3.1.xml
    #  </alternateIdentifier>
    #</alternateIdentifiers>
    for my $i (@{$data->{identifiers}}){
      my @alt_identifiers_children;
      if($i->{type} ne "DOI"){
        push @alt_identifiers_children, {
          xmlname => "alternateIdentifier",
          value => $i->{value},
          attributes => [
            {
              xmlname => "alternateIdentifierType",
              value => $i->{type}
            }
          ]
        };
      }
      if(scalar @alt_identifiers_children > 0){
        push @datacite, {
          xmlname => "alternateIdentifiers",
          children => \@alt_identifiers_children
        };
      }
    }
  }

=end comment
=cut

  if (exists($data->{creators})) {
    #
    #<creators>
    # <creator>
    #  <creatorName>Miller, Elizabeth</creatorName>
    #  <givenName>Elizabeth</givenName>
    #  <familyName>Miller</familyName>
    #  <nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">0000-0001-5000-0007</nameIdentifier>
    #  <affiliation>DataCite</affiliation>
    # </creator>
    #</creators>

    unless (@{$data->{creators}}) {    # NOTE: one creator is required
      if (@{$data->{contributors}}) {    # "steal" one contributor and promote her/him to "creator"
        push(@{$data->{creators}}, shift @{$data->{contributors}});
        $c->app->log->debug(join(' ', __FILE__, __LINE__, 'creator stolen from contributors'));
      }
      else {
        push(@{$data->{creators}}, {value => 'Unknown'});
        $c->app->log->debug(join(' ', __FILE__, __LINE__, 'creator Unknown'));
      }
    }

    my @creators_children;
    for my $cr (@{$data->{creators}}) {
      my $ch = {
        xmlname  => "creator",
        children => []
      };
      my $creatorName = {xmlname => "creatorName", value => $cr->{value}};
      if ($cr->{type}) {
        if ($cr->{type} eq 'personal') {
          $creatorName->{attributes} = [
            { xmlname => 'nameType',
              value   => 'Personal'
            }
          ];
        }
        if ($cr->{type} eq 'corporate') {
          $creatorName->{attributes} = [
            { xmlname => 'nameType',
              value   => 'Organizational'
            }
          ];
        }
      }
      push @{$ch->{children}}, $creatorName;
      if ($cr->{firstname}) {
        push @{$ch->{children}}, {xmlname => "givenName", value => $cr->{firstname}};
      }
      if ($cr->{lastname}) {
        push @{$ch->{children}}, {xmlname => "familyName", value => $cr->{lastname}};
      }
      push @creators_children, $ch;
    }
    push @datacite,
      {
      xmlname  => "creators",
      children => \@creators_children
      };

  }

  if (exists($data->{contributors})) {

    #<contributors>
    #  <contributor contributorType="ProjectLeader">
    #    <contributorName>Starr, Joan</contributorName>
    #    <nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">0000-0002-7285-027X</nameIdentifier>
    #    <affiliation>California Digital Library</affiliation>
    #  </contributor>
    #</contributors>
    my @contributors_children;
    for my $cr (@{$data->{contributors}}) {
      my $ch = {
        xmlname    => "contributor",
        children   => [],
        attributes => [
          { xmlname => "contributorType",
            value   => "Other",             # TODO: https://schema.test.datacite.org/meta/kernel-4.1/include/datacite-contributorType-v4.xsd
          },
        ]
      };
      push @{$ch->{children}}, {xmlname => "contributorName", value => $cr->{value}};
      if ($cr->{firstname}) {
        push @{$ch->{children}}, {xmlname => "givenName", value => $cr->{firstname}};
      }
      if ($cr->{lastname}) {
        push @{$ch->{children}}, {xmlname => "familyName", value => $cr->{lastname}};
      }
      push @contributors_children, $ch;
    }

    if (@contributors_children) {
      push @datacite,
        {
        xmlname  => "contributors",
        children => \@contributors_children
        };
    }
  }

  if (exists($data->{titles})) {

    #<titles>
    #  <title xml:lang="en-us">Full DataCite XML Example</title>
    #  <title xml:lang="en-us" titleType="Subtitle">Demonstration of DataCite Properties.</title>
    #</titles>
    my @titles_children;
    for my $t (@{$data->{titles}}) {
      push @titles_children, {
        xmlname => "title",
        value   => $t->{title},

        # ATTN: register_doi POST metadata returned code1=[400] res1=[[xml] xml error: cvc-complex-type.3.2.2: Attribute 'lang' is not allowed to appear in element 'title'.]
        # attributes => [
        #   {
        #     xmlname => "lang",
        #     value => $t->{lang}
        #   }
        # ]

      };
      if (defined($t->{subtitle})) {
        push @titles_children, {
          xmlname    => "title",
          value      => $t->{subtitle},
          attributes => [
            { xmlname => "titleType",
              value   => "Subtitle"
            },

            # cvc-complex-type.3.2.2: Attribute 'lang' is not allowed to appear in element 'title'.
            # {
            #   xmlname => "lang",
            #   value => $t->{lang}
            # }
          ]
        };
      }
    }
    push @datacite,
      {
      xmlname  => "titles",
      children => \@titles_children
      };
  }

  $c->app->log->debug(join(' ', __FILE__, __LINE__, 'publisher'));
  my @publishers;
  if (exists($data->{publishers})) {

    #<publisher>DataCite</publisher>
    for my $p (@{$data->{publishers}}) {
      push(@publishers, $p->{value}) if ($p->{value});
    }
  }

  if (@publishers) {
    push(@datacite, {xmlname => "publisher", value => $publishers[0]});    # there is only one publisher element?
    $c->app->log->debug("added default publisher: p=" . join(' ', @publishers));
  }
  else {
    push(@errors, 'publisher missing');
    $res->{status} = 'INCOMPLETE';
  }

  # see also PhaidraAPI/Model/Uwmetadata/Extraction.pm

  $c->app->log->debug(join(' ', __FILE__, __LINE__, 'publicationYear'));
  my @publication_year;

  #<publicationYear>2014</publicationYear>
  # Year when the data is made publicly available. If an embargo period has been in effect, use the date when the embargo period ends.
  my @pub_year_sources = qw(embargodates publicationYear pubyear);
  foreach my $an (@pub_year_sources) {
    if (exists($data->{$an}) && defined($data->{$an})) {
      for my $av (@{$data->{$an}}) {
        push @publication_year, $av->{value} if $av->{value};
      }
    }
  }
  if (@publication_year) {

    # @publication_year= sort { $a <=> $b } @publication_year; # no sorting, data is priorized

    push @datacite, {xmlname => "publicationYear", value => $publication_year[0]};
  }
  else {
    push(@errors, 'publicationYear missing');
    $res->{status} = 'INCOMPLETE';
  }

  if (exists($data->{descriptions})) {
    #
    #<descriptions>
    # <description xml:lang="en-us" descriptionType="Abstract">
    #   XML example of all DataCite Metadata Schema v4.0 properties.
    # </description>
    #</descriptions>
    my @descriptions_children;
    for my $de (@{$data->{descriptions}}) {
      my $ch = {
        xmlname => "description",
        value   => $de->{value},

        attributes => [
          {
            # cvc-complex-type.4: Attribute 'descriptionType' must appear on element 'description'.
            # https://schema.test.datacite.org/meta/kernel-4.1/include/datacite-descriptionType-v4.xsd
            # values: Abstract Methods SeriesInformation TableOfContents TechnicalInfo Other

            xmlname => "descriptionType",
            value   => "Other"              # we don't have description type; TODO: add heuristics to select one of the allowed values
          },

          # ATTN: register_doi POST metadata returned code1=[400] res1=[[xml] xml error: cvc-complex-type.3.2.2: Attribute 'lang' is not allowed to appear in element 'description'.]
          #          {
          #            xmlname => "lang",
          #            value => $de->{lang}
          #          }
        ]
      };
      push @descriptions_children, $ch;
    }
    push @datacite,
      {
      xmlname  => "descriptions",
      children => \@descriptions_children
      };
  }

  # <resourceType resourceTypeGeneral="Software">XML</resourceType>
  push @datacite,
    {
    xmlname    => "resourceType",
    value      => $cmodel,
    attributes => [
      { xmlname => "resourceTypeGeneral",
        value   => $cmodelMapping{$cmodel}
      }
    ]
    };

  if (exists($data->{langs})) {

    #<language>en-us</language>
    for my $l (@{$data->{langs}}) {
      push @datacite,
        {
        xmlname => "language",
        value   => $l->{value}
        };
    }
  }

  my @dates_children;
  if (exists($data->{uploaddates})) {

    #<dates>
    #  <date dateType="Updated">2014-10-17</date>
    #</dates>

    for my $d (@{$data->{uploaddates}}) {
      my $ch = {
        xmlname    => "date",
        value      => $d->{value},
        attributes => [
          { xmlname => "dateType",
            value   => "Created"
          }
        ]
      };
      push @dates_children, $ch;
    }
  }
  if (exists($data->{dates})) {

    #<dates>
    #  <date dateType="Updated">2014-10-17</date>
    #</dates>
    for my $d (@{$data->{dates}}) {
      if ($d->{value}) {
        my $ch = {
          xmlname    => "date",
          value      => $d->{value},
          attributes => [
            { xmlname => "dateType",
              value   => $d->{type}
            }
          ]
        };
        push @dates_children, $ch;
      }
    }
  }
  if (scalar @dates_children > 0) {
    push @datacite,
      {
      xmlname  => "dates",
      children => \@dates_children
      };
  }

  if (exists($data->{subjects})) {

    #<subjects>
    # <subject xml:lang="en-us" schemeURI="http://dewey.info/" subjectScheme="dewey">000 computer science</subject>
    #</subjects>
    # the scheme and URI are optional
    my @subject_children;
    my %subject_children;
    for my $s (@{$data->{subjects}}) {
      my $subject = $s->{value};
      unless (exists($subject_children{$subject})) {
        my $ch = {
          xmlname => "subject",
          value   => $subject,

          # ATTN: register_doi POST metadata returned code1=[400] res1=[[xml] xml error: cvc-complex-type.3.2.2: Attribute 'lang' is not allowed to appear in element 'subject'.]
          #        attributes => [
          #          {
          #            xmlname => "lang",
          #            value => $s->{lang}
          #          }
          #        ]
        };
        push @subject_children, $ch;
        $subject_children{$subject}++;
      }
    }
    push @datacite,
      {
      xmlname  => "subjects",
      children => \@subject_children
      };
  }

  if (exists($data->{filesizes})) {

    #<sizes>
    #  <size>3KB</size>
    #</sizes>
    for my $fs (@{$data->{filesizes}}) {
      if ($fs->{value}) {
        push @datacite,
          {
          xmlname  => "sizes",
          children => [
            { xmlname => "size",
              value   => $fs->{value} . ' b'
            }
          ]
          };
      }
    }
  }

  if (exists($data->{formats})) {

    #<formats>
    #  <format>application/xml</format>
    #</formats>
    for my $f (@{$data->{formats}}) {
      push @datacite,
        {
        xmlname  => "formats",
        children => [
          { xmlname => "format",
            value   => $f->{value}
          }
        ]
        };
    }
  }

  my @rights_list;
  if (($cmodel ne 'Resource') && ($cmodel ne 'Collection')) {

    #<rightsList>
    # <rights rightsURI="http://creativecommons.org/publicdomain/zero/1.0/">CC0 1.0 Universal</rights>
    #</rightsList>
    # rightsURI is optional
    if (exists($data->{licenses})) {
      for my $v (@{$data->{licenses}}) {

        #$c->app->log->debug("rights: ". Dumper($v));

        my $rights = {xmlname => "rights", value => $v->{value}};
        $rights->{attributes} = [{xmlname => 'rightsURI', value => $v->{link_uri}}] if (exists($v->{link_uri}));
        push(@rights_list, $rights);
      }
    }
  }

  push(@datacite, {xmlname => "rightsList", children => \@rights_list}) if (@rights_list);

  return $res;
}

sub _get_relsext_identifiers {
  my ($self, $c, $pid) = @_;

  my @ids;
  if ($c->app->config->{fedora}->{version} >= 6) {

    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $fres         = $fedora_model->getObjectProperties($c, $pid);
    if ($fres->{status} ne 200) {
      $c->app->log->debug("STATUS NOT 200");
      return $fres;
    }

    if (exists $fres->{identifier} && ref $fres->{identifier} eq 'ARRAY') {
        @ids = @{$fres->{identifier}};
    }
    $c->app->log->debug("Identifiers: " . Dumper(\@ids));
    return \@ids;
  }
  my $search_model = PhaidraAPI::Model::Search->new;

  my $query = "<info:fedora/$pid> <http://purl.org/dc/terms/identifier> *";
  my $sr    = $search_model->triples($c, $query, 0);
  unless ($sr->{status} eq 200) {
    $c->app->log->error("Could not query triplestore for identifiers.");
    return \@ids;
  }

  for my $triple (@{$sr->{result}}) {
    my $id = @$triple[2];
    $id =~ s/^\<+|\>+$//g;
    push @ids, {value => $id};
  }

  return \@ids;
}

sub _get_filesize {

  my ($self, $c, $pid, $cmodel) = @_;

  my $bytesize;
  if (exists($c->app->config->{paf_mongodb})) {
    my $inv_coll = $c->paf_mongo->get_collection('foxml.ds');
    if ($inv_coll) {
      my $ds_doc = $inv_coll->find_one({pid => $pid}, {}, {"sort" => {"updated_at" => -1}});
      $bytesize = $ds_doc->{ds_sizes}->{OCTETS};
    }
  }
  unless ($bytesize) {
    my $octets_model = PhaidraAPI::Model::Octets->new;
    my $parthres     = $octets_model->_get_ds_path($c, $pid, 'OCTETS');
    if ($parthres->{status} == 200) {
      $bytesize = -s $parthres->{path};
    }
  }

  my @sizes;
  push @sizes, {value => $bytesize};
  return \@sizes;
}

sub json_2_xml {

  my ($self, $c, $json) = @_;

  my $prefixmap           = {$datacite_ns => 'datacite'};
  my $forced_declarations = [$datacite_ns];

  my $xml    = '';
  my $writer = XML::Writer->new(
    OUTPUT          => \$xml,
    NAMESPACES      => 1,
    PREFIX_MAP      => $prefixmap,
    FORCED_NS_DECLS => $forced_declarations,
    DATA_MODE       => 1,
    ENCODING        => 'utf-8'                 # NOTE: apparently, this leads to double UTF-8 encoding
  );

  $writer->startTag("resource");
  $self->json_2_xml_rec($c, undef, $json, $writer);
  $writer->endTag("resource");

  $writer->end();

  return $xml;
}

sub json_2_xml_rec() {

  my $self     = shift;
  my $c        = shift;
  my $parent   = shift;
  my $children = shift;
  my $writer   = shift;

  foreach my $child (@{$children}) {

    my $children_size   = defined($child->{children})   ? scalar(@{$child->{children}})   : 0;
    my $attributes_size = defined($child->{attributes}) ? scalar(@{$child->{attributes}}) : 0;

    if ((!defined($child->{value}) || ($child->{value} eq '')) && $children_size == 0 && $attributes_size == 0) {
      next;
    }

    if (defined($child->{attributes}) && (scalar @{$child->{attributes}} > 0)) {
      my @attrs;
      foreach my $a (@{$child->{attributes}}) {
        if (defined($a->{value}) && $a->{value} ne '') {
          if ($a->{xmlname} eq 'lang') {
            push @attrs, ['http://www.w3.org/XML/1998/namespace', 'lang'] => $a->{value};
          }
          else {
            push @attrs, $a->{xmlname} => $a->{value};
          }
        }
      }

      $writer->startTag($child->{xmlname}, @attrs);
    }
    else {
      $writer->startTag($child->{xmlname});
    }

    if ($children_size > 0) {
      $self->json_2_xml_rec($c, $child, $child->{children}, $writer);
    }
    else {
      $writer->characters($child->{value});
    }

    $writer->endTag($child->{xmlname});
  }
}

1;
__END__
