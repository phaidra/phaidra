package PhaidraAPI::Model::Dc;

use strict;
use warnings;
use v5.10;
use utf8;
use Mojo::ByteStream qw(b);
use Mojo::Util qw(xml_escape html_unescape encode decode);
use base qw/Mojo::Base/;
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

sub xml_2_json {
  my ($self, $c, $xml, $output_label) = @_;

  my @nodes;
  my $res = {alerts => [], status => 200, $output_label => \@nodes};

  my $dom = Mojo::DOM->new();
  $dom->xml(1);
  $dom->parse($xml);
  my %json;
  $self->xml_2_json_rec($c, \%json, $dom->children);

  foreach my $ch (@{$json{children}}) {
    if ($ch->{xmlname} eq 'dc') {
      $res->{$output_label} = $ch->{children};
    }
  }

  return $res;
}

sub xml_2_json_rec {

  my ($self, $c, $parent, $xml_children) = @_;

  for my $e ($xml_children->each) {

    my $type = $e->tag;

    $type =~ m/(\w+):(\w+)/;
    my $ns = $1;
    my $id = $2;
    my $node;
    $node->{xmlname} = $id;
    if (defined($e->content) && $e->content ne '') {
      $node->{ui_value} = b(html_unescape $e->content)->decode('UTF-8');
    }

    if (defined($e->attr)) {
      foreach my $ak (keys %{$e->attr}) {
        my $a = {
          xmlname  => $ak,
          ui_value => b($e->attr->{$ak})->decode('UTF-8')
        };
        push @{$node->{attributes}}, $a;
      }
    }

    if ($e->children->size > 0) {
      $self->xml_2_json_rec($c, $node, $e->children);
    }

    push @{$parent->{children}}, $node;
  }

}

sub get_object_dc_json {

  my ($self, $c, $pid, $dsid, $username, $password) = @_;

  my $object_model = PhaidraAPI::Model::Object->new;
  my $res          = $object_model->get_datastream($c, $pid, $dsid, $username, $password, 1);
  if ($res->{status} ne 200) {
    return $res;
  }

  my $output_label = ($dsid eq 'DC_P') || ($dsid eq 'DC') ? 'dc' : 'oai_dc';
  return $self->xml_2_json($c, $res->{$dsid}, $output_label);

}

sub generate_dc_from_mods {

  my ($self, $c, $pid, $dscontent, $username, $password) = @_;

  my $res = {alerts => [], status => 200};

  my $object_model = PhaidraAPI::Model::Object->new;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $mods_model   = PhaidraAPI::Model::Mods->new;

  my $cmodel;

  my $res_cmodel = $search_model->get_cmodel($c, $pid);
  push @{$res->{alerts}}, @{$res_cmodel->{alerts}} if scalar @{$res_cmodel->{alerts}} > 0;
  if ($res_cmodel->{status} ne 200) {
    $res->{status} = $res_cmodel->{status};
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  my ($dc_p, $dc_oai) = $self->map_mods_2_dc($c, $pid, $cmodel, $dscontent, $mods_model);

  # Phaidra DC
  my $r1 = $object_model->add_or_modify_datastream($c, $pid, "DC_P", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $dc_p, "X", undef, undef, $username, $password, 1, 0);
  push @{$res->{alerts}}, @{$r1->{alerts}} if scalar @{$r1->{alerts}} > 0;
  if ($r1->{status} ne 200) {
    $res->{status} = $r1->{status};
  }

  # OAI DC - unqualified
  my $r2 = $object_model->add_or_modify_datastream($c, $pid, "DC_OAI", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $dc_oai, "X", undef, undef, $username, $password, 1, 0);
  push @{$res->{alerts}}, @{$r2->{alerts}} if scalar @{$r2->{alerts}} > 0;
  if ($r2->{status} ne 200) {
    $res->{status} = $r2->{status};
  }

  # we have to add this because we need that info in triplestore and old hooks won't update DC for MODS
  $r1 = $object_model->add_or_modify_datastream($c, $pid, "DC", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $dc_p, "X", undef, undef, $username, $password, 1, 0);
  push @{$res->{alerts}}, @{$r1->{alerts}} if scalar @{$r1->{alerts}} > 0;
  if ($r1->{status} ne 200) {
    $res->{status} = $r1->{status};
  }

  return $res;
}

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
  my %dc_p;
  $dc_p{title}   = $ext->_get_mods_titles($c, $dom);
  $dc_p{subject} = $ext->_get_mods_subjects($c, $dom);
  my $classifications = $ext->_get_mods_classifications($c, $dom);
  push @{$dc_p{subject}}, @$classifications;
  $dc_p{identifier} = $ext->_get_mods_element_values($c, $dom, 'mods > identifier');
  push @{$dc_p{identifier}}, {value => $c->app->config->{scheme}."://" . $c->app->config->{phaidra}->{baseurl} . "/" . $pid};

  unless ($indexing) {
    my $relids = $self->_get_relsext_identifiers($c, $pid);
    for my $relid (@$relids) {
      push @{$dc_p{identifier}}, $relid;
    }
  }
  $dc_p{relation} = $ext->_get_mods_relations($c, $dom);
  my $editions = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > edition');
  push @{$dc_p{relation}}, @$editions;
  $dc_p{language}    = $ext->_get_mods_element_values($c, $dom, 'mods > language > languageTerm');
  $dc_p{creator}     = $ext->_get_mods_creators($c, $dom, 'p');
  $dc_p{contributor} = $ext->_get_mods_contributors($c, $dom, 'p');
  $dc_p{date}        = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > dateIssued[keyDate="yes"]');
  $dc_p{description} = $ext->_get_mods_element_values($c, $dom, 'mods > note');

  # maps specific
  my $scales     = $ext->_get_mods_element_values($c, $dom, 'mods > subject > cartographics > scale');
  my @scales_arr = map {{value => "1:" . $_->{value}}} @$scales;
  push @{$dc_p{description}}, @scales_arr;

  my $extents = $ext->_get_mods_element_values($c, $dom, 'mods > physicalDescription > extent');
  push @{$dc_p{description}}, @$extents;

  $dc_p{publisher} = $ext->_get_mods_element_values($c, $dom, 'mods > originInfo > publisher');

  # place of publishing should not be dc:publisher
  #my $publisher_places = $self->_get_mods_element_values($c, $dom, 'mods > originInfo > place > placeTerm');
  #push @{$dc_p{publisher}}, @$publisher_places;

  $dc_p{rights} = $ext->_get_mods_element_values($c, $dom, 'mods > accessCondition[type="use and reproduction"]');

  unless ($indexing) {
    my $filesize = $self->_get_filesize($c, $pid, $cmodel);
    push @{$dc_p{format}} => {value => "$filesize bytes"};
  }

  # FIXME GEO datastream to DCMI BOX

  # see https://guidelines.openaire.eu/wiki/OpenAIRE_Guidelines:_For_Literature_repositories
  my %dc_oai = %dc_p;
  $dc_oai{creator}     = $ext->_get_mods_creators($c, $dom, 'oai');
  $dc_oai{contributor} = $ext->_get_mods_contributors($c, $dom, 'oai');

  return (\%dc_p, \%dc_oai);
}

sub map_mods_2_dc {

  my ($self, $c, $pid, $cmodel, $xml, $metadata_model) = @_;

  my ($dc_p, $dc_oai) = $self->map_mods_2_dc_hash($c, $pid, $cmodel, $xml, $metadata_model);

  my $dc_p_xml   = $self->_create_dc_from_hash($c, $dc_p);
  my $dc_oai_xml = $self->_create_dc_from_hash($c, $dc_oai);

  return ($dc_p_xml, $dc_oai_xml);
}

sub map_jsonld_2_dc_hash {
  my ($self, $c, $pid, $cmodel, $jsonld, $metadata_model, $indexing) = @_;

  my $ext = PhaidraAPI::Model::Jsonld::Extraction->new;

  #$c->app->log->debug("XXXXXXXXXXX mods xml:".$xml);

  my %dc_p;

  $dc_p{description} = [];
  $dc_p{coverage}    = [];
  $dc_p{subject}     = [];
  $dc_p{date}        = [];

  $dc_p{type} = $ext->_get_jsonld_objectlabels($c, $jsonld, 'dcterms:type');

  for my $v (@{$ext->_get_jsonld_objectlabels($c, $jsonld, 'edm:hasType')}) {
    push @{$dc_p{type}}, $v;
  }

  $dc_p{title} = $ext->_get_jsonld_titles($c, $jsonld);

  $dc_p{source} = $ext->_get_jsonld_sources($c, $jsonld);

  $dc_p{publisher} = $ext->_get_jsonld_publishers($c, $jsonld);

  for my $d (@{$ext->_get_jsonld_descriptions($c, $jsonld)}) {
    push @{$dc_p{description}}, $d;
  }

  my ($creators, $contributors) = $ext->_get_jsonld_roles($c, $jsonld);
  $dc_p{creator}     = $creators;
  $dc_p{contributor} = $contributors;

  for my $s (@{$ext->_get_jsonld_subjects($c, $jsonld)}) {
    push @{$dc_p{subject}}, $s;
  }

  if ($jsonld->{'dcterms:subject'}) {
    for my $o (@{$jsonld->{'dcterms:subject'}}) {
      if ($o->{'@type'} eq 'phaidra:Subject') {
        my $sub_titles = $ext->_get_jsonld_titles($c, $o);
        for my $s_t (@{$sub_titles}) {
          push @{$dc_p{title}}, $s_t;
        }

        my $sub_descriptions = $ext->_get_jsonld_descriptions($c, $o);
        for my $s_d (@{$sub_descriptions}) {
          push @{$dc_p{description}}, $s_d;
        }

        my ($sub_creators, $sub_contributors) = $ext->_get_jsonld_roles($c, $o);
        for my $s_cr (@{$sub_creators}) {
          push @{$dc_p{creator}}, $s_cr;
        }
        for my $s_co (@{$sub_contributors}) {
          push @{$dc_p{contributor}}, $s_co;
        }

        my $sub_subjects = $ext->_get_jsonld_subjects($c, $o);
        for my $s_s (@{$sub_subjects}) {
          push @{$dc_p{subject}}, $s_s;
        }

        my $s_tcs = $ext->_get_jsonld_langvalues($c, $o, 'schema:temporalCoverage');
        for my $s_tc (@{$s_tcs}) {
          push @{$dc_p{coverage}}, $s_tc;
        }
      }
    }
  }

  # $dc_p{identifier} = $ext->_get_jsonld_identifiers($c, $jsonld);
  push @{$dc_p{identifier}}, {value => $c->app->config->{scheme}."://" . $c->app->config->{phaidra}->{baseurl} . "/" . $pid};
  unless ($indexing) {
    my $relids = $self->_get_relsext_identifiers($c, $pid);
    for my $relid (@$relids) {
      push @{$dc_p{identifier}}, $relid;
    }
  }

  $dc_p{language} = $ext->_get_jsonld_values($c, $jsonld, 'dcterms:language');

  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:date')}) {
    push @{$dc_p{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:created')}) {
    push @{$dc_p{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:modified')}) {
    push @{$dc_p{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:issued')}) {
    push @{$dc_p{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateAccepted')}) {
    push @{$dc_p{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateCopyrighted')}) {
    push @{$dc_p{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'dcterms:dateSubmitted')}) {
    push @{$dc_p{date}}, $d;
  }
  for my $d (@{$ext->_get_jsonld_values($c, $jsonld, 'rdau:P60071')}) {
    push @{$dc_p{date}}, $d;
  }

  my $pds = $ext->_get_jsonld_publisheddates($c, $jsonld);
  for my $pd (@{$pds}) {
    push @{$dc_p{date}}, $pd;
  }

  my $tcs = $ext->_get_jsonld_langvalues($c, $jsonld, 'schema:temporalCoverage');
  for my $tc (@{$tcs}) {
    push @{$dc_p{coverage}}, $tc;
  }

  $dc_p{rights} = $ext->_get_jsonld_values($c, $jsonld, 'edm:rights');
  my $rights_sentences = $ext->_get_jsonld_langvalues($c, $jsonld, 'dce:rights');
  for my $rs (@$rights_sentences) {
    push @{$dc_p{rights}}, $rs;
  }
  for my $d (@{$ext->_get_jsonld_objectlabels($c, $jsonld, 'dcterms:accessRights')}) {
    push @{$dc_p{rights}}, $d;
  }

  $dc_p{format} = $ext->_get_jsonld_values($c, $jsonld, 'ebucore:hasMimeType');
  unless ($indexing) {
    my $filesize = $self->_get_filesize($c, $pid, $cmodel);
    push @{$dc_p{format}} => {value => "$filesize bytes"};
  }

  #$c->app->log->debug("XXXXXXXXXXXXXX dc_p:".$c->app->dumper(\%dc_p));
  my %dc_oai = %dc_p;

  return (\%dc_p, \%dc_oai);
}

sub generate_dc_from_uwmetadata {

  my ($self, $c, $pid, $dscontent, $username, $password) = @_;

  my $res = {alerts => [], status => 200};

  my $object_model   = PhaidraAPI::Model::Object->new;
  my $search_model   = PhaidraAPI::Model::Search->new;
  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;

  my $cmodel;

  my $res_cmodel = $search_model->get_cmodel($c, $pid);
  push @{$res->{alerts}}, @{$res_cmodel->{alerts}} if scalar @{$res_cmodel->{alerts}} > 0;
  if ($res_cmodel->{status} ne 200) {
    $res->{status} = $res_cmodel->{status};
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  my $r0 = $metadata_model->metadata_tree($c);
  if ($r0->{status} ne 200) {
    return $res;
  }

  my ($dc_p, $dc_oai) = $self->map_uwmetadata_2_dc($c, $pid, $cmodel, $dscontent, $r0->{metadata_tree}, $metadata_model);

  # Phaidra DC
  my $r1 = $object_model->add_or_modify_datastream($c, $pid, "DC_P", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $dc_p, "X", undef, undef, $username, $password, 1, 0);
  push @{$res->{alerts}}, @{$r1->{alerts}} if scalar @{$r1->{alerts}} > 0;
  if ($r1->{status} ne 200) {
    $res->{status} = $r1->{status};
  }

  # OAI DC - unqualified
  my $r2 = $object_model->add_or_modify_datastream($c, $pid, "DC_OAI", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $dc_oai, "X", undef, undef, $username, $password, 1, 0);
  push @{$res->{alerts}}, @{$r2->{alerts}} if scalar @{$r2->{alerts}} > 0;
  if ($r2->{status} ne 200) {
    $res->{status} = $r2->{status};
  }

  # Fedora's DC - for backward compatibility with frontend which only updates DC (see Hooks)

  my $r3 = $object_model->add_or_modify_datastream($c, $pid, "DC", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $dc_p, "X", undef, undef, $username, $password, 1, 0);
  push @{$res->{alerts}}, @{$r3->{alerts}} if scalar @{$r3->{alerts}} > 0;
  if ($r3->{status} ne 200) {
    $res->{status} = $r3->{status};
  }

  return $res;
}

sub map_uwmetadata_2_dc {

  my ($self, $c, $pid, $cmodel, $xml, $tree, $metadata_model) = @_;

  my ($dc_p, $dc_oai) = $self->map_uwmetadata_2_dc_hash($c, $pid, $cmodel, $xml, $tree, $metadata_model);

  my $dc_p_xml   = $self->_create_dc_from_hash($c, $dc_p);
  my $dc_oai_xml = $self->_create_dc_from_hash($c, $dc_oai);

  return ($dc_p_xml, $dc_oai_xml);
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

  my $identifiers = $ext->_get_uwm_identifiers($c, $dom, \%doc_uwns, $tree, $metadata_model);
  unless ($indexing) {
    my $relids = $self->_get_relsext_identifiers($c, $pid);
    for my $relid (@$relids) {
      push @$identifiers, $relid;
    }
  }
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
  my $types_p   = $ext->_get_types($c, $cmodel, $dom, \%doc_uwns, $tree, $metadata_model, 'p');
  my $types_oai = $ext->_get_types($c, $cmodel, $dom, \%doc_uwns, $tree, $metadata_model, 'oai');

  my $versions_p   = $ext->_get_versions($c, $dom, \%doc_uwns, $tree, $metadata_model, 'p');
  my $versions_oai = $ext->_get_versions($c, $dom, \%doc_uwns, $tree, $metadata_model, 'oai');

  my $formats = $ext->_get_formats($c, $pid, $cmodel, $dom, \%doc_uwns);

  # include filesize and mimetype of OCTETS
  unless ($indexing) {
    my $filesize = $self->_get_filesize($c, $pid, $cmodel);
    push @$formats, {value => $filesize . " bytes"} if defined($filesize);
  }

  my $srcs = $ext->_get_sources($c, $dom, \%doc_uwns, $tree, $metadata_model);

  my $publishers = $ext->_get_publishers($c, $dom, \%doc_uwns);

  my $contributors = $ext->_get_contributors($c, $dom, \%doc_uwns);

  my $relations = $ext->_get_uwm_relations($c, $dom, \%doc_uwns);

  my $coverages = $ext->_get_uwm_element_values($c, $dom, $doc_uwns{'lom'} . '\:coverage');

  my $infoeurepoaccess_p   = $ext->_get_infoeurepoaccess($c, $dom, \%doc_uwns, $tree, $metadata_model, 'p');
  my $infoeurepoaccess_oai = $ext->_get_infoeurepoaccess($c, $dom, \%doc_uwns, $tree, $metadata_model, 'oai');

  my $licenses = $ext->_get_licenses($c, $dom, \%doc_uwns, $tree, $metadata_model);

  # FIXME GEO datastream to DCMI BOX

  # get provenience versions

  push @$identifiers, {value => $c->app->config->{scheme}."://" . $c->app->config->{phaidra}->{baseurl} . "/" . $pid};

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

  my %dc_p;
  $dc_p{identifier}  = $identifiers  if (defined($identifiers));
  $dc_p{title}       = $titles       if (defined($titles));
  $dc_p{description} = $descriptions if (defined($descriptions));
  $dc_p{subject}     = \@subjects    if (@subjects);
  $dc_p{language}    = \@langs       if (@langs);
  $dc_p{creator}     = $creators     if (defined($creators));
  $dc_p{date}        = $dates        if (defined($dates));
  $dc_p{type}        = $types_p;
  $dc_p{source}      = $srcs;
  $dc_p{publisher}   = $publishers   if (defined($publishers));
  $dc_p{contributor} = $contributors if (defined($contributors));
  $dc_p{relation}    = $relations;
  $dc_p{coverage}    = $coverages;

  # copy this, not just assign reference
  # otherwise the $license will contain the $infoeurepoaccess_p values later
  if (($cmodel ne 'Resource') && ($cmodel ne 'Collection')) {
    for my $v (@$versions_p) {
      push @{$dc_p{type}}, $v;
    }
    for my $v (@{$licenses}) {
      push @{$dc_p{rights}}, $v;
    }
    for my $v (@{$infoeurepoaccess_p}) {
      push @{$dc_p{rights}}, $v;
    }
    for my $v (@{$rightsStatements}) {
      push @{$dc_p{rights}}, $v;
    }
    $dc_p{format} = $formats;
  }

  # see https://guidelines.openaire.eu/wiki/OpenAIRE_Guidelines:_For_Literature_repositories
  my $dc_oai = dclone \%dc_p;
  $dc_oai->{type} = $types_oai;
  if (($cmodel ne 'Resource') && ($cmodel ne 'Collection')) {
    $dc_oai->{rights} = ();
    for my $v (@{$licenses}) {
      push @{$dc_oai->{rights}}, $v;
    }
    for my $v (@{$infoeurepoaccess_oai}) {
      push @{$dc_oai->{rights}}, $v;
    }
    for my $v (@{$rightsStatements}) {
      push @{$dc_oai->{rights}}, $v;
    }
    for my $v (@$versions_oai) {
      push @{$dc_oai->{type}}, $v;
    }
  }

  return (\%dc_p, $dc_oai);
}

sub _get_relsext_identifiers {
  my ($self, $c, $pid) = @_;

  my @ids;
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

  return $bytesize;
}

sub _create_dc_from_hash {

  my ($self, $c, $dc) = @_;
  my $dc_xml = '<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">' . "\n";
  foreach my $k (keys %{$dc}) {
    next unless $dc->{$k};
    foreach my $n (@{$dc->{$k}}) {
      next if ($n eq '');
      next unless (defined($n->{value}));

      if (ref($n) eq 'HASH') {
        next unless (defined($n->{value}));

        $dc_xml .= '   <dc:' . $k;
        $dc_xml .= ' xml:lang="' . $PhaidraAPI::Model::Languages::iso639map{$n->{lang}} . '"' if (exists($n->{lang}));
        $dc_xml .= '>' . xml_escape(html_unescape($n->{value})) . '</dc:' . $k . ">\n";
      }
      else {
        next if ($n eq '');
        $dc_xml .= '   <dc:' . $k;
        $dc_xml .= '>' . xml_escape(html_unescape($n)) . '</dc:' . $k . ">\n";
      }

    }
  }
  $dc_xml .= "</oai_dc:dc>\n";

  return $dc_xml;
}

1;
__END__
