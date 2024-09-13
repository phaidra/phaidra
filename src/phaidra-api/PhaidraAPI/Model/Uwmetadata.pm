package PhaidraAPI::Model::Uwmetadata;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;
use Storable qw(dclone);
use POSIX qw/strftime/;
use Switch;
use Data::Dumper;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(html_unescape);
use XML::Writer;
use XML::LibXML;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Terms;
use PhaidraAPI::Model::Util;
use PhaidraAPI::Model::Licenses;
use PhaidraAPI::Model::Uwmetadata::Tree;

our %input_types_map = (
  "LangString"      => "input_text",
  "DateTime"        => "input_text",
  "CharacterString" => "input_text",
  "GPS"             => "input_text",
  "Duration"        => "input_text",
  "FileSize"        => "input_text",

  "Vocabulary"           => "select",
  "License"              => "select",
  "Faculty"              => "select",
  "Department"           => "select",
  "SPL"                  => "select",
  "Curriculum"           => "select",
  "Language"             => "select",
  "Boolean"              => "select",
  "Taxon"                => "select",
  "ClassificationSource" => "select",

  "Node" => "node"
);

sub metadata_tree {

  my ($self, $c, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  $nocache = $nocache ? $nocache : '';

  # $c->app->log->debug("metadata_tree nocache[$nocache]");

  if ($nocache) {
    $c->app->log->debug("Reading uwmetadata tree from db (nocache request)");
    $res->{metadata_tree} = $self->get_metadata_tree($c);
    return $res;
  }

  if ($c->app->config->{local_uwmetadata_tree} eq 'PhaidraAPI::Model::Uwmetadata::Tree') {

    # $c->app->log->debug("Reading uwmetadata tree from " . $c->app->config->{local_uwmetadata_tree} . " class");
    $res->{metadata_tree} = $PhaidraAPI::Model::Uwmetadata::Tree::tree{tree};

    # "faculties" are different on every instance so we have to pull this from config and update the tree with it
    my $facultyNode = $self->get_json_node($c, 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization', 'faculty', $res->{metadata_tree});
    my %vocabulary;
    $vocabulary{namespace} = 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/';
    my $langs = $c->app->config->{directory}->{org_units_languages};
    foreach my $lang (@$langs) {
      my $resunits = $c->app->directory->org_get_units_uwm($c, undef, $lang);
      if (exists($resunits->{alerts})) {
        if ($resunits->{status} != 200) {
          # there are only alerts
          return {alerts => $resunits->{alerts}, status => $resunits->{status}};
        }
      }

      my $org_units = $resunits->{org_units};
      foreach my $u (@$org_units) {
        $vocabulary{'terms'}->{$u->{value}}->{uri} = $vocabulary{namespace} . $u->{value};
        $vocabulary{'terms'}->{$u->{value}}->{labels}->{$lang} = $u->{name};
      }
    }
    my @termarray;
    while (my ($key, $element) = each %{$vocabulary{'terms'}}) {
      push @termarray, $element;
    }
    $vocabulary{'terms'} = \@termarray;
    $facultyNode->{vocabularies} = [ \%vocabulary ];

    return $res;
  }

  # $c->app->log->debug("Reading uwmetadata tree from cache");

  my $cachekey = 'uwmetadata_tree';
  my $cacheval = $c->app->chi->get($cachekey);

  my $miss = 1;

  if ($cacheval) {
    if (scalar @{$cacheval} > 0) {
      $miss = 0;
      $c->app->log->debug("[cache hit] $cachekey");
    }
  }

  if ($miss) {
    $c->app->log->debug("[cache miss] $cachekey");

    if ($c->app->config->{local_uwmetadata_tree}) {
      $c->app->log->debug("Reading uwmetadata tree from file");

      unless (-e $c->app->config->{local_uwmetadata_tree}) {
        $c->app->log->error("Error reading local_uwmetadata_tree, file " . $c->app->config->{local_uwmetadata_tree} . " does not exist");
        push @{$res->{alerts}}, {type => 'error', msg => "Error reading local_uwmetadata_tree"};
        $res->{status} = 500;
        return $res;
      }

      # read metadata tree from file
      my $content;
      open my $fh, "<", $c->app->config->{local_uwmetadata_tree} or push @{$res->{alerts}}, {type => 'error', msg => "Error reading local_uwmetadata_tree, " . $!};
      local $/;
      $content = <$fh>;
      close $fh;

      unless (defined($content)) {
        my $msg = "Error reading local_uwmetadata_tree, no content";
        $c->app->log->error($msg);
        push @{$res->{alerts}}, {type => 'error', msg => $msg};
        $res->{status} = 500;
        return $res;
      }

      my $metadata = decode_json($content);

      $cacheval = $metadata->{tree};

    }
    else {

      $cacheval = $self->get_metadata_tree($c);
    }

    $c->app->chi->set($cachekey, $cacheval, '1 day');

    # save and get the value. the serialization can change integers to strings so
    # if we want to get the same structure for cache miss and cache hit we have to run it through
    # the cache serialization process
    $cacheval = $c->app->chi->get($cachekey);

    #$c->app->log->debug($c->app->dumper($res));
  }
  $res->{metadata_tree} = $cacheval;

  return $res;
}

sub get_metadata_tree {

  my ($self, $c) = @_;

  my %format;
  my @metadata_tree;
  my %id_hash;
  my %license_veid_lid_map;

  my $sth;
  my $ss;

  # create mapping of veid to licence id
  $ss  = qq/SELECT LID, name FROM licenses/;
  $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute();
  my $l_lid;
  my $l_veid;
  $sth->bind_columns(undef, \$l_lid, \$l_veid);
  while ($sth->fetch) {
    $license_veid_lid_map{$l_veid} = $l_lid;
  }

  #$c->app->log->debug($c->app->dumper(\%license_veid_lid_map));

  $ss = qq/SELECT
			m.MID, m.VEID, m.xmlname, m.xmlns, m.lomref,
			m.searchable, m.mandatory, m.autofield, m.editable, m.OID,
			m.datatype, m.valuespace, m.MID_parent, m.cardinality, m.ordered, m.fgslabel,
			m.VID, m.defaultvalue, m.sequence
			FROM metadata m
			ORDER BY m.sequence, m.MID ASC/;
  $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute();

  my $mid;             # id of the element
  my $veid;            # id of the vocabulary entry defining the label of the element (in multiple languages)
  my $xmlname;         # name of the element (name and namespace constitute URI)
  my $xmlns;           # namespace of the element (name and namespace constitute URI)
  my $lomref;          # id in LOM schema (if the element comes from LOM)
  my $searchable;      # 1 if the element is visible in advanced search
  my $mandatory;       # 1 if the element is mandatory
  my $autofield;       # ? i found no use for this one
  my $editable;        # 1 if the element is available in uwmetadataeditor
  my $oid;             # this was meant for metadata-owner feature
  my $datatype;        # Phaidra datatype (/usr/local/fedora/cronjobs/XSD/datatypes.xsd)
  my $valuespace;      # regex constraining the value
  my $mid_parent;      # introduces structure, eg firstname is under entity, etc
  my $cardinality;     # eg 1, 2, * - any
  my $ordered;         # Y if the order of elements have to be preserved (eg entity is ordered as the order of authors is important)
  my $fgslabel;        # label for the search engine (is used in index and later in search queries)
  my $vid;             # if defined then id of the controlled vocabulary which represents the possible values
  my $defaultvalue;    # currently there's only #FIRSTNAME, #LASTNAME and #TODAY or NULL
  my $field_order;     # order of the element among it's siblings

  $sth->bind_columns(undef, \$mid, \$veid, \$xmlname, \$xmlns, \$lomref, \$searchable, \$mandatory, \$autofield, \$editable, \$oid, \$datatype, \$valuespace, \$mid_parent, \$cardinality, \$ordered, \$fgslabel, \$vid, \$defaultvalue, \$field_order);

  # fill the hash with raw table data
  my $i = 0;
  while ($sth->fetch) {
    $i++;
    $format{$mid} = {
      mid     => $mid,       # needed for sort
                             # not needed #debug_id => int(rand(9999)),
      veid    => $veid,
      xmlname => $xmlname,
      xmlns   => $xmlns,

      # not needed #lomref => $lomref,
      # not needed #searchable => $searchable,
      mandatory => ($mandatory eq 'N' ? 0 : 1),

      # not needed #autofield => $autofield,
      # not needed #editable => $editable,
      # not needed #oid => $oid,
      datatype    => $datatype,
      mid_parent  => $mid_parent,
      cardinality => $cardinality,
      ordered     => ($ordered eq 'Y' ? 1 : 0),

      # not needed #fgslabel => $fgslabel,
      vid => $vid,

      # not needed #defaultvalue => $defaultvalue,
      field_order => (defined($field_order) ? $field_order : 9999),    # as defined in metadata format, value must be defined because we are going to sort by this
      data_order  => '',                                               # as defined in object's metadata (for objects which have 'ordered = 1')
      help_id     => 'helpmeta_' . $mid,                               # used ot get the help tooltip content via ajax
      value_lang  => '',                                               # language of the value if any
      ui_value    => '',                                               # what's expected on the form (eg ns/id for vocabularies)
      loaded      => 0,                                                # 1 if this element was filled with a value loaded from object's metadata
                                                                       #field_id => 'field_'.$i,
      input_type  => '',                                               # which html control to use, we will specify this later
      hidden      => 0,                                                # we will specify later which fields are to be hidden
      disabled    => 0                                                 # we will specify later which fields are to be disabled
    };

    $format{$mid}->{input_regex} = $valuespace;

    # mapping of "Phaidra Datatypes" to form input types
    #
    # possible values (with schema restrictions):
    #  Duration PT(\d{1,2}H){0,1}(\d{1,2}M){0,1}(\d{1,2}S){0,1}
    #  CharacterString (string)
    #  LangString (string)
    #  Vocabulary (int)
    #  FileSize (nonNegativeInteger)
    #  Node (string)
    #  License (nonNegativeInteger)
    #  DateTime -{0,1}\d{4}(-\d{2}){0,1}(-\d{2}){0,1} or \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z
    #  GPS \d{1,3}°\d{1,2}'\d{1,2}''[EW]{1}\|\d{1,2}°\d{1,2}'\d{1,2}''[NS]{1}
    #  Boolean 'yes' or 'no'
    #  Faculty (string)
    #  Department (string)
    #  SPL (string)
    #  Curriculum (string)
    #  Taxon (int)
    #
    # at the beginning just a basic definition, for some fields we will redefine this later
    # because eg description is just defined as LangString, the same way as eg title, but description must be textarea
    # not just a simple text input
    switch ($datatype) {

      case "LangString" {
        $format{$mid}->{input_type} = "input_text_lang";
        $format{$mid}->{value_lang} = $c->app->config->{defaults}->{metadata_field_language};
      }

      case "DateTime" {$format{$mid}->{input_type} = "input_datetime"}

      case "Vocabulary" {$format{$mid}->{input_type} = "select"}
      case "License"    {$format{$mid}->{input_type} = "select"}
      case "Faculty"    {$format{$mid}->{input_type} = "select"}
      case "Department" {$format{$mid}->{input_type} = "select"}
      case "SPL"        {$format{$mid}->{input_type} = "select"}
      case "Curriculum" {$format{$mid}->{input_type} = "select"}

      case "Language" {$format{$mid}->{input_type} = "language_select"}

      case "Boolean" {
        $format{$mid}->{input_type} = "select_yesno";
      }

      case "Node" {$format{$mid}->{input_type} = "node"}

      case "CharacterString" {$format{$mid}->{input_type} = "input_text"}
      case "GPS"             {$format{$mid}->{input_type} = "input_text"}
      case "Duration"        {$format{$mid}->{input_type} = "input_duration"}
      case "FileSize"        {$format{$mid}->{input_type} = "input_text"}
      else                   {$format{$mid}->{input_type} = "input_text"}
    }

    # special input types
    switch ($format{$mid}->{xmlname}) {
      case "description" {
        $format{$mid}->{input_type} = "input_textarea_lang";
        $format{$mid}->{value_lang} = $c->app->config->{defaults}->{metadata_field_language};
      }
      case "installremarks" {
        $format{$mid}->{input_type} = "input_textarea_lang";
        $format{$mid}->{value_lang} = $c->app->config->{defaults}->{metadata_field_language};
      }
      case "otherrequirements" {
        $format{$mid}->{input_type} = "input_textarea_lang";
        $format{$mid}->{value_lang} = $c->app->config->{defaults}->{metadata_field_language};
      }
      case "comment" {
        $format{$mid}->{input_type} = "input_textarea_lang";
        $format{$mid}->{value_lang} = $c->app->config->{defaults}->{metadata_field_language};
      }
      case "release_notes" {
        $format{$mid}->{input_type} = "input_textarea_lang";
        $format{$mid}->{value_lang} = $c->app->config->{defaults}->{metadata_field_language};
      }
      case "identifier" {

        # because there is also an 'identifier' in the http://phaidra.univie.ac.at/XML/metadata/extended/V1.0 namespace
        if ($format{$mid}->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0') {
          $format{$mid}->{input_type} = "static";
        }
      }
      case "upload_date" {
        $format{$mid}->{input_type} = "static";
      }
      case "orcomposite" {
        $format{$mid}->{input_type} = "label_only";
      }
    }

    # hidden fields
    switch ($format{$mid}->{xmlname}) {
      case "irdata"               {$format{$mid}->{hidden} = 1}    # system field
      case "metadataqualitycheck" {$format{$mid}->{hidden} = 1}    # system field
      case "classification"       {$format{$mid}->{hidden} = 1}    # i think this should be edited elsewhere
      case "annotation"           {$format{$mid}->{hidden} = 1}    # was removed from editor
      case "etheses"              {$format{$mid}->{hidden} = 1}    # should not be edited in phaidra (i guess..)
    }

    # if field is ordered, set seq to 0
    if ($format{$mid}->{ordered}) {
      $format{$mid}->{data_order} = '0';
    }

    $id_hash{$mid} = $format{$mid};                                # we will use this later for direct id -> element access
  }

  # create the hierarchy
  my @todelete;
  my %parents;
  foreach my $key (keys %format) {
    if ($format{$key}{mid_parent}) {
      $parents{$format{$key}{mid_parent}} = $format{$format{$key}{mid_parent}};
      push @todelete, $key;
      push @{$format{$format{$key}{mid_parent}}{children}}, $format{$key};
    }
  }
  delete @format{@todelete};

  # now just as children are just an array, also the top level will be only an array
  # we do this because we don't want to hardcode the mids anywhere
  # we should just work with namespace and name
  while (my ($key, $element) = each %format) {
    push @metadata_tree, $element;
  }

  # and sort it
  @metadata_tree = sort {$a->{field_order} <=> $b->{field_order} || $a->{mid} <=> $b->{mid}} @metadata_tree;

  # and sort the children
  foreach my $key (keys %parents) {
    @{$id_hash{$key}{children}} = sort {$a->{field_order} <=> $b->{field_order} || $a->{mid} <=> $b->{mid}} @{$parents{$key}{children}};
  }

  # get the element labels
  $ss  = qq/SELECT m.mid, ve.entry, ve.isocode FROM metadata AS m LEFT JOIN vocabulary_entry AS ve ON ve.veid = m.veid;/;
  $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute();

  my $entry;      # element label (name of the field, eg 'Title')
  my $isocode;    # 2 letter isocode defining language of the entry

  $sth->bind_columns(undef, \$mid, \$entry, \$isocode);
  while ($sth->fetch) {
    $id_hash{$mid}->{'labels'}->{$isocode} = $entry;
  }

  # get the vocabularies (HINT: this crap will be overwritten when we have vocabulary server)
  while (my ($key, $element) = each %id_hash) {
    if ($element->{vid}) {

      my %vocabulary;

      # get vocabulary info
      $ss  = qq/SELECT description FROM vocabulary WHERE vid = (?);/;
      $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      $sth->execute($element->{vid});

      my $desc;    # some short text describing the vocabulary (it's not multilanguage, sorry)

      $sth->bind_columns(undef, \$desc);
      $sth->fetch;

      $vocabulary{description} = $desc;

      # there's none, i'm fabricating this
      $vocabulary{namespace} = $element->{xmlns} . '/voc_' . $element->{vid} . '/';

      # get vocabulary values/codes
      $ss  = qq/SELECT veid, entry, isocode FROM vocabulary_entry WHERE vid = (?);/;
      $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      $sth->execute($element->{vid});

      my $veid;       # the code, together with namespace this creates URI, that's the current hack
      my $entry;      # value label (eg 'Wood-engraver')
      my $isocode;    # 2 letter isocode defining language of the entry

      $sth->bind_columns(undef, \$veid, \$entry, \$isocode);

      # fetching data using hash, so that we quickly find the place for the entry but later ... [x]
      while ($sth->fetch) {

        my $termkey;
        if ($element->{vid} == 21) {

          # license metadata field uses license id as value, not veid
          $termkey = $license_veid_lid_map{$veid};
        }
        else {
          $termkey = $veid;
        }

        $vocabulary{'terms'}->{$termkey}->{uri} = $vocabulary{namespace} . $termkey;                   # this gets overwritten for the same entry
        $vocabulary{'terms'}->{$termkey}->{labels}->{$isocode} = $entry;                               # this should always contain another language for the same entry
      }

      # [x] ... we remove the id hash
      # because we should work with URI - namespace and code, ignoring the current 'id' structure

      my @termarray;
      while (my ($key, $element) = each %{$vocabulary{'terms'}}) {
        push @termarray, $element;
      }
      $vocabulary{'terms'} = \@termarray;

      # maybe we want to support multiple vocabularies for one field in future
      push @{$element->{vocabularies}}, \%vocabulary;

    }

    # get organisational structure vocabularies
    # faculties and stdy plans at the moment,
    # departments depends on chosen faculty and curriculums on chosen study plan
    # so we won't load departments and curriculums (although this is a bit uni specific)
    elsif ($element->{datatype} eq "Faculty") {

      my %vocabulary;

      $vocabulary{namespace} = $element->{xmlns} . '/voc_' . $element->{xmlname} . '/';
      my $langs = $c->app->config->{directory}->{org_units_languages};
      foreach my $lang (@$langs) {

        my $res = $c->app->directory->org_get_units_uwm($c, undef, $lang);
        if (exists($res->{alerts})) {
          if ($res->{status} != 200) {

            # there are only alerts
            return {alerts => $res->{alerts}, status => $res->{status}};
          }
        }

        my $org_units = $res->{org_units};

        foreach my $u (@$org_units) {
          $vocabulary{'terms'}->{$u->{value}}->{uri} = $vocabulary{namespace} . $u->{value};
          $vocabulary{'terms'}->{$u->{value}}->{labels}->{$lang} = $u->{name};

        }
      }
      my @termarray;
      while (my ($key, $element) = each %{$vocabulary{'terms'}}) {
        push @termarray, $element;
      }
      $vocabulary{'terms'} = \@termarray;

      push @{$element->{vocabularies}}, \%vocabulary;

    }
    elsif ($element->{datatype} eq "Department") {
      my %vocabulary;
      $vocabulary{namespace} = $element->{xmlns} . '/voc_' . $element->{xmlname} . '/';
      $vocabulary{terms}     = [];
      push @{$element->{vocabularies}}, \%vocabulary;

    }
    elsif ($element->{datatype} eq "SPL") {

      my %vocabulary;
      my $terms_model = PhaidraAPI::Model::Terms->new;
      $vocabulary{namespace} = $element->{xmlns} . '/voc_' . $element->{xmlname} . '/';
      my $langs = $c->app->config->{directory}->{study_plans_languages};
      foreach my $lang (@$langs) {

        my $spls = $terms_model->get_study_plans($c, $lang);
        if (exists($spls->{alerts})) {
          if ($spls->{status} != 200) {

            # there are only alerts
            return {alerts => $spls->{alerts}, status => $spls->{status}};
          }
        }
        foreach my $sp (@{$spls->{study_plans}}) {
          $vocabulary{'terms'}->{$sp->{value}}->{uri} = $vocabulary{namespace} . $sp->{value};
          $vocabulary{'terms'}->{$sp->{value}}->{labels}->{$lang} = $sp->{name};

        }
      }
      my @termarray;
      while (my ($key, $element) = each %{$vocabulary{'terms'}}) {
        push @termarray, $element;
      }
      $vocabulary{'terms'} = \@termarray;

      push @{$element->{vocabularies}}, \%vocabulary;

    }
    elsif ($element->{datatype} eq "Curriculum") {
      my %vocabulary;
      $vocabulary{namespace} = $element->{xmlns} . '/voc_' . $element->{xmlname} . '/';
      $vocabulary{terms}     = [];
      push @{$element->{vocabularies}}, \%vocabulary;
    }

  }

  # delete ids, we don't need them
  while (my ($key, $element) = each %id_hash) {
    delete $element->{vid};
    delete $element->{veid};
    delete $element->{mid_parent};
    delete $element->{mid};
  }

  return \@metadata_tree;
}

sub get_datatype_hash {
  my ($self, $c) = @_;

  my $datatype_hash;
  my $cachekey = 'uwmetadata_datatype_hash';
  unless ($datatype_hash = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $tree_res = $self->metadata_tree($c);

    my %h;
    $self->_create_datatype_hash($c, $tree_res->{metadata_tree}, \%h);
    $datatype_hash = \%h;
    $c->app->chi->set($cachekey, $datatype_hash, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $datatype_hash;
}

sub _create_datatype_hash {

  my $self     = shift;
  my $c        = shift;
  my $children = shift;
  my $h        = shift;

  foreach my $n (@{$children}) {

    $h->{$n->{xmlns} . '/' . $n->{xmlname}} = $n->{datatype};

    my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
    if ($children_size > 0) {
      $self->_create_datatype_hash($c, $n->{children}, $h);
    }
  }

}

sub get_voc_ns_hash {
  my ($self, $c) = @_;

  my $vocns_hash;
  my $cachekey = 'uwmetadata_voc_ns_hash';
  unless ($vocns_hash = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $tree_res = $self->metadata_tree($c);
    my %h;
    $self->_create_voc_ns_hash($c, $tree_res->{metadata_tree}, \%h);
    $vocns_hash = \%h;
    $c->app->chi->set($cachekey, $vocns_hash, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $vocns_hash;
}

sub _create_voc_ns_hash {

  my $self     = shift;
  my $c        = shift;
  my $children = shift;
  my $h        = shift;

  foreach my $n (@{$children}) {

    if (($n->{datatype} eq 'Vocabulary') || ($n->{datatype} eq 'License')) {
      for my $v (@{$n->{vocabularies}}) {
        $h->{$n->{xmlns} . '/' . $n->{xmlname}} = $v->{namespace};
      }
    }

    my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
    if ($children_size > 0) {
      $self->_create_voc_ns_hash($c, $n->{children}, $h);
    }
  }

}

sub uwmetadata_2_json {

  my ($self, $c, $uwmetadata) = @_;

  # this structure contains the metadata default structure (equals to empty uwmetadataeditor) to which
  # we are going to load the data of some real object
  my $tree_res = $self->metadata_tree($c);
  if ($tree_res->{status} ne 200) {
    return $tree_res;
  }

  # clone! otherwise it fills the class
  my $metadata_tree = dclone($tree_res->{metadata_tree});

  # this is a hash where the key is 'ns/id' and value is a default representation of a node
  # -> we use this when adding nodes (eg a second title) to get a new empty node
  my %metadata_nodes_hash;
  my $metadata_tree_copy = dclone($metadata_tree);
  $self->create_md_nodes_hash($c, $metadata_tree_copy, \%metadata_nodes_hash);

  my $dom = Mojo::DOM->new();
  $dom->xml(1);
  $dom->parse($uwmetadata);

  my $nsattr = $dom->find('uwmetadata')->first->attr;
  my $nsmap  = $nsattr;

  # replace xmlns:ns0 with ns0
  foreach my $key (keys %{$nsmap}) {
    my $newkey = $key;
    $newkey =~ s/xmlns://g;
    $nsmap->{$newkey} = delete $nsmap->{$key};
  }

  $self->fill_object_metadata($c, $dom, $metadata_tree, undef, $nsmap, \%metadata_nodes_hash);

  # fix taxonpath nodes (we first needed them filled)
  $self->fix_taxonpath_nodes($c, $metadata_tree);

  return {alerts => [], uwmetadata => $metadata_tree, status => 200};
}

sub uwmetadata_2_json_basic {
  my ($self, $c, $uwmetadata_xml, $mode) = @_;

  my $terms_model = PhaidraAPI::Model::Terms->new;

  my $datatype_hash = $self->get_datatype_hash($c);
  my $vocns_hash    = $self->get_voc_ns_hash($c);

  my $uwmetadata;

  if (ref $uwmetadata_xml eq 'Mojo::DOM') {
    $uwmetadata = $uwmetadata_xml;
  }
  else {
    $uwmetadata = Mojo::DOM->new();
    $uwmetadata->xml(1);
    $uwmetadata->parse($uwmetadata_xml);
  }

  my $nsattr = $uwmetadata->find('uwmetadata')->first->attr;
  my $nsmap  = $nsattr;

  # replace xmlns:ns0 with ns0
  foreach my $key (keys %{$nsmap}) {
    my $newkey = $key;
    $newkey =~ s/xmlns://g;
    $nsmap->{$newkey} = delete $nsmap->{$key};
  }

  my $arr = $self->uwmetadata_2_json_basic_rec($c, $terms_model, $uwmetadata->find('uwmetadata')->first, $mode, $nsmap, $datatype_hash, $vocns_hash, undef);

  return {alerts => [], uwmetadata => $arr, status => 200};
}

sub uwmetadata_2_json_basic_rec {

  my ($self, $c, $terms_model, $uwmetadata, $mode, $nsmap, $datatype_hash, $vocns_hash, $contextdata) = @_;

  my @children;
  for my $e ($uwmetadata->children->each) {

    my $type = $e->tag;
    my ($ns, $id) = $self->_get_ns_id($c, $type);

    my $xmlns = $nsmap->{$ns};

    my $datatype = $datatype_hash->{$xmlns . '/' . $id};
    my $vocns    = $vocns_hash->{$xmlns . '/' . $id};

    # we're going to dumb this down
    my $input_type = $input_types_map{$datatype};

    my %node = (
      xmlname    => $id,
      xmlns      => $xmlns,
      input_type => $input_type,
      datatype   => $datatype
    );

    if ($node{xmlname} eq 'taxonpath') {

      # if this is taxon path, save classification id in context data
      # so that we have it when resolving taxons
      for my $elm ($e->children->each) {
        my $elm_type = $elm->tag;
        my ($elm_ns, $elm_id) = $self->_get_ns_id($c, $elm_type);
        if ($elm_id eq 'source') {
          $contextdata->{cls} = $elm->text;
        }
      }
    }

    if ($e->content && ($input_type ne 'node')) {

      my $value = html_unescape $e->content;

      if ($datatype eq 'Vocabulary') {
        $node{ui_value} = $vocns . $value;
      }
      elsif ($datatype eq 'License') {
        $node{ui_value} = $vocns . $value;
      }
      elsif ($datatype eq 'Faculty') {
        $node{ui_value} = $PhaidraAPI::Model::Terms::organization_ns . '/voc_faculty/' . $value;
      }
      elsif ($datatype eq 'Department') {
        $node{ui_value} = $PhaidraAPI::Model::Terms::organization_ns . '/voc_department/' . $value;
      }
      elsif ($datatype eq 'SPL') {
        $node{ui_value} = $PhaidraAPI::Model::Terms::organization_ns . '/voc_spl/' . $value;
      }
      elsif ($datatype eq 'ClassificationSource') {
        $node{ui_value} = $PhaidraAPI::Model::Terms::classification_ns . '/cls_' . $value;
      }
      elsif ($datatype eq 'Taxon') {
        $node{ui_value} = $PhaidraAPI::Model::Terms::classification_ns . "/cls_" . $contextdata->{cls} . "/" . $value;
      }
      else {
        $node{ui_value} = $value;
      }

      if ($mode eq 'resolved') {

        my $labels;
        if ($labels = $self->resolve_if_id($c, $terms_model, $datatype, $vocns, $value, $contextdata)) {
          $node{labels} = $labels;
        }

      }
    }

    if (defined($e->attr)) {
      if ($e->attr->{language}) {
        push @{$node{attributes}}, {xmlname => 'lang', input_type => 'select', ui_value => $e->attr->{language}};
      }
      if (defined($e->attr->{seq})) {
        push @{$node{attributes}}, {xmlname => 'data_order', input_type => 'input_text', ui_value => $e->attr->{seq}};
      }
    }

    if ($e->children->size > 0) {
      $node{children} = $self->uwmetadata_2_json_basic_rec($c, $terms_model, $e, $mode, $nsmap, $datatype_hash, $vocns_hash, $contextdata);
    }

    push @children, \%node;
  }
  return \@children;
}

sub _get_ns_id {

  my ($self, $c, $elm_type) = @_;

  # type looks like this: ns1:general
  # get namespace and identifier from it
  # namespace = 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'
  # identifier = 'general'
  $elm_type =~ m/(ns\d+):([0-9a-zA-Z_]+)/;
  return ($1, $2);
}

sub resolve_if_id {
  my ($self, $c, $terms_model, $datatype, $vocns, $value, $contextdata) = @_;

  if ($datatype eq 'Vocabulary') {

    my $r = $terms_model->label($c, $vocns . $value);
    return $r->{labels};

  }
  elsif ($datatype eq 'License') {

    my $r = $terms_model->license_label($c, $value);
    return $r->{labels};

  }
  elsif ($datatype eq 'Faculty') {

    my $r = $terms_model->label($c, $PhaidraAPI::Model::Terms::organization_ns . '/voc_faculty/' . $value);
    return $r->{labels};

  }
  elsif ($datatype eq 'Department') {

    my $r = $terms_model->label($c, $PhaidraAPI::Model::Terms::organization_ns . '/voc_department/' . $value);
    return $r->{labels};

  }
  elsif ($datatype eq 'SPL') {

    # || $datatype eq 'Curriculum' we'll ignore curriculum now, it's complicated, uni-specific and rarely used

    my $labels;
    my $langs = $c->app->config->{directory}->{study_plans_languages};
    foreach my $lang (@$langs) {
      my $r = $terms_model->get_study_plans($c, $lang);
      if ($r->{status} eq 200) {
        for my $spl (@{$r->{study_plans}}) {
          if ($spl->{value} eq $value) {
            $labels->{$lang} = $spl->{name};
            last;
          }
        }
      }
    }
    return $labels;

  }
  elsif ($datatype eq 'ClassificationSource') {

    # eg http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_7

    my $uri = $PhaidraAPI::Model::Terms::classification_ns . '/cls_' . $value;

    my $r = $terms_model->children($c, $PhaidraAPI::Model::Terms::classification_ns);
    if ($r->{status} eq 200) {
      for my $t (@{$r->{terms}}) {
        if ($t->{uri} eq $uri) {
          return $t->{labels};
        }
      }
    }

  }
  elsif ($datatype eq 'Taxon') {

    my $r = $terms_model->label($c, $PhaidraAPI::Model::Terms::classification_ns . "/cls_" . $contextdata->{cls} . "/" . $value);
    return $r->{labels}->{labels};

  }
  elsif ($datatype eq 'Boolean') {

    if ($value eq 'yes') {
      return {en => 'Yes', de => 'Ja', it => 'Sì'};
    }
    else {
      return {en => 'No', de => 'Nein', it => 'No'};
    }
  }

}

# for 'source' and 'taxon' nodes set the values to include namespace & classification id
# also fill in the classification name labels and taxon labels
sub fix_taxonpath_nodes {
  my ($self, $c, $metadata_tree) = @_;

  my $cls_node = $self->get_json_node($c, 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0', 'classification', $metadata_tree);

  return unless $cls_node;
  return unless $cls_node->{children};

  my $terms_model = PhaidraAPI::Model::Terms->new;

  foreach my $cls_child (@{$cls_node->{children}}) {
    if ($cls_child->{xmlname} eq 'taxonpath') {
      if ($cls_child->{children}) {

        # change value of the 'source' and remember the old value (classification id)
        my $cls_id;
        foreach my $taxpath_child (@{$cls_child->{children}}) {
          if ($taxpath_child->{xmlname} eq 'source') {

            if ($taxpath_child->{ui_value} ne '') {
              $cls_id = $taxpath_child->{ui_value};
              my $source_val = $PhaidraAPI::Model::Terms::classification_ns . "/cls_$cls_id";
              $taxpath_child->{ui_value} = $source_val;
              my $r = $terms_model->label($c, $source_val);
              if ($r->{status} eq 200) {

                #$c->app->log->debug($c->app->dumper($r));
                $taxpath_child->{value_labels} = $r->{labels};
              }
              else {
                $c->app->log->error("Could not get terms for $source_val: " . $c->app->dumper($r));
              }
            }
          }
        }

        # use the classification id to update the taxon values
        foreach my $taxpath_child (@{$cls_child->{children}}) {
          if ($taxpath_child->{xmlname} eq 'taxon') {
            if ($taxpath_child->{ui_value} ne '') {
              my $tax_id  = $taxpath_child->{ui_value};
              my $tax_val = $PhaidraAPI::Model::Terms::classification_ns . "/cls_$cls_id/$tax_id";
              $taxpath_child->{ui_value} = $tax_val;

              my $r = $terms_model->label($c, $tax_val);
              if ($r->{status} eq 200) {

                #$c->app->log->debug($c->app->dumper($r));
                $taxpath_child->{value_labels} = $r->{labels};
              }
              else {
                $c->app->log->error("Could not get terms for $tax_val: " . $c->app->dumper($r));
              }
            }
          }
        }
      }
    }
  }
}

sub get_object_metadata {

  my ($self, $c, $pid, $mode, $username, $password) = @_;

  my $object_model = PhaidraAPI::Model::Object->new;

  #my $res = $object_model->get_dissemination($c, $pid, 'bdef:Asset', 'getUWMETADATA', $username, $password);
  my $res = $object_model->get_datastream($c, $pid, 'UWMETADATA', $username, $password, 1);

  if ($res->{status} ne 200) {
    return $res;
  }

  my $uwmetadata = b($res->{UWMETADATA})->decode('UTF-8');

  if ($mode eq 'full') {

    #$res = $self->uwmetadata_2_json($c, $res->{content});
    $res = $self->uwmetadata_2_json($c, $uwmetadata);
    return {uwmetadata => $res->{uwmetadata}, alerts => $res->{alerts}, status => $res->{status}};
  }
  else {
    $res = $self->uwmetadata_2_json_basic($c, $uwmetadata, $mode);
    return {uwmetadata => $res->{uwmetadata}, alerts => $res->{alerts}, status => $res->{status}};
  }

}

sub get_org_units_terms {
  my $self            = shift;
  my $c               = shift;
  my $parent_id       = shift;
  my $value_namespace = shift;

  my %vocabulary;
  my $langs = $c->app->config->{directory}->{org_units_languages};
  foreach my $lang (@$langs) {

    my $res = $c->app->directory->org_get_units_uwm($c, $parent_id, $lang);
    my $org_units = $res->{org_units};

    foreach my $u (@$org_units) {
      $vocabulary{'terms'}->{$u->{value}}->{uri} = $value_namespace . $u->{value};
      $vocabulary{'terms'}->{$u->{value}}->{labels}->{$lang} = $u->{name};
    }
  }
  my @termarray;
  while (my ($key, $element) = each %{$vocabulary{'terms'}}) {
    push @termarray, $element;
  }

  return \@termarray;
}

sub get_study_terms {

  my $self             = shift;
  my $c                = shift;
  my $spl              = shift;
  my $ids              = shift;
  my $values_namespace = shift;

  my %vocabulary;
  my $langs = $c->app->config->{directory}->{study_plans_languages};

  foreach my $lang (@$langs) {
    my $res = $c->app->directory->get_study($c, $spl, $ids, $lang);

    my $study = $res->{'study'};

    foreach my $s (@$study) {
      $vocabulary{'terms'}->{$s->{value}}->{uri} = $values_namespace . $s->{value};
      $vocabulary{'terms'}->{$s->{value}}->{labels}->{$lang} = $s->{name};
    }
  }

  my @termarray;
  while (my ($key, $element) = each %{$vocabulary{'terms'}}) {
    push @termarray, $element;
  }

  return \@termarray;
}

sub get_study_name {

  my $self = shift;
  my $c    = shift;
  my $spl  = shift;
  my $ids  = shift;

  my $langs = $c->app->config->{directory}->{study_plans_languages};

  my %names;
  foreach my $lang (@$langs) {
    my $name = $c->app->directory->get_study_name($c, $spl, $ids, $lang);
    $names{$lang} = $name;
  }

  return \%names;
}

sub fill_object_metadata {

  my $self                 = shift;
  my $c                    = shift;
  my $uwmetadata           = shift;
  my $metadata_tree        = shift;
  my $metadata_tree_parent = shift;
  my $nsmap                = shift;
  my $metadata_nodes_hash  = shift;

  my $tidy = shift;
  $tidy .= '  ';

  unless (defined($metadata_tree_parent)) {
    my %h = ('children' => $metadata_tree);
    $metadata_tree_parent = \%h;
  }

  for my $e ($uwmetadata->children->each) {

    my $type = $e->tag;
    my ($ns, $id) = $self->_get_ns_id($c, $type);

    #$c->app->log->debug("XXXXXXX type [$type] ns [$ns] id [$id]");
    my $node;
    if ($id ne 'uwmetadata') {

      # search this node in the metadata tree
      # get one where metadata from uwmetadata were not yet loaded
      $ns   = $nsmap->{$ns};
      $node = $self->get_empty_node($c, $ns, $id, $metadata_tree_parent, $metadata_nodes_hash);

      if ($e->text) {

        # fill in values
        if (defined($node->{vocabularies})) {

          foreach my $voc (@{$node->{vocabularies}}) {
            my $node_value = $e->text;
            $node->{ui_value} = $voc->{namespace} . $node_value;
          }

          if ($node->{xmlname} eq 'department') {

            # get the selected faculty, if any, and fill the department vocabulary
            if ($e->parent) {
              my $faculty = undef;
              for my $child ($e->parent->children->each) {
                if ($child->tree eq $e->tree) {
                  if ($faculty) {
                    if ($faculty->text) {
                      foreach my $voc (@{$node->{vocabularies}}) {
                        $voc->{terms} = $self->get_org_units_terms($c, $faculty->text, "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_department/");
                      }
                    }
                  }
                  last;
                }
                $faculty = $child;
              }
            }
          }

          if ($node->{xmlname} eq 'kennzahl') {

            # get the previous sibling and study plan and fill the study plan vocabulary
            if ($e->parent) {
              my $prev        = undef;
              my $spl         = undef;
              my $current_seq = undef;
              my $ids_all;
              my $last_kennzahl = 0;
              for my $child ($e->parent->children->each) {

                if ($e->parent->children->reverse->first->tree eq $e->tree) {
                  $last_kennzahl = 1;
                }

                my $child_type = $child->tag;
                my ($ns, $id) = $self->_get_ns_id($c, $child_type);
                if ($id eq 'spl') {
                  $spl = $child->text;
                  next;
                }
                if ($id eq 'kennzahl') {
                  push @$ids_all, {text => $child->text, seq => $child->attr('seq')};
                  if ($child->tree eq $e->tree) {
                    $current_seq = $child->attr('seq');
                  }
                }
              }
              @$ids_all = sort {$a->{seq} <=> $b->{seq}} @$ids_all;

              # for the get_study method we need all the ids until the current one
              my @ids;
              for my $id (@$ids_all) {
                if ($id->{seq} eq $current_seq) {
                  last;
                }
                else {
                  push @ids, $id->{text};
                }
              }

              foreach my $voc (@{$node->{vocabularies}}) {
                $voc->{terms} = $self->get_study_terms($c, $spl, \@ids, "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_kennzahl/");
              }

              # try to get the study name
              if ($last_kennzahl) {

                my @ids;
                for my $id (@$ids_all) {
                  push @ids, $id->{text};
                }

                $metadata_tree_parent->{study_name} = $self->get_study_name($c, $spl, \@ids);

              }
            }
          }

        }
        else {
          if ($node->{input_type} ne 'node') {
            my $v = html_unescape $e->content;
            $node->{ui_value} = $v;
          }
        }

      }

      if (defined($e->attr)) {
        if ($e->attr->{language}) {
          $node->{value_lang} = $e->attr->{language};
        }
        if (defined($e->attr->{seq}) && $node->{ordered}) {
          $node->{data_order} = $e->attr->{seq};
          @{$metadata_tree_parent->{children}} = sort {sort_ordered($a) <=> sort_ordered($b)} @{$metadata_tree_parent->{children}};
        }
      }
    }
    if ($e->children->size > 0) {
      $self->fill_object_metadata($c, $e, $metadata_tree, $node, $nsmap, $metadata_nodes_hash, $tidy);
    }
  }

}

sub sort_ordered {

  my $node = shift;

  # upload_date, version, etc needs to be ordered by field_order, as well as contribute
  # but among contribute nodes, the order is defined by seq (data_order)
  # => field_order takes preference
  #
  # <ns1:lifecycle>
  # <ns1:upload_date>2013-06-12T11:02:28.665Z</ns1:upload_date>
  # <ns1:version language="de">2</ns1:version>
  # <ns1:status>44</ns1:status>
  # <ns2:peer_reviewed>no</ns2:peer_reviewed>
  # <ns1:contribute seq="1">...</ns1:contribute>
  # <ns1:contribute seq="2">...</ns1:contribute>
  # <ns1:contribute seq="3">...</ns1:contribute>
  # <ns1:contribute seq="4">...</ns1:contribute>
  # <ns1:contribute seq="0">...</ns1:contribute>
  # <ns2:infoeurepoversion>1556249</ns2:infoeurepoversion>
  # </ns1:lifecycle>

  if ($node->{data_order} eq '') {
    return int($node->{field_order});
  }
  else {
    return int($node->{field_order}) + ("0." . $node->{data_order});
  }

}

sub get_empty_node {

  my $self                = shift;
  my $c                   = shift;
  my $ns                  = shift;
  my $id                  = shift;
  my $parent              = shift;
  my $metadata_nodes_hash = shift;

  #$c->app->log->debug("searching empty node $id under ".$parent->{xmlname}.' ['.$parent->{debug_id}.']');

  my $node;
  my $i = 0;
  foreach my $n (@{$parent->{children}}) {
    my $xmlns         = $n->{xmlns};
    my $xmlname       = $n->{xmlname};
    my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;

    if (($xmlns eq $ns) && ($xmlname eq $id)) {

      #$c->app->log->debug("found ".($n->{loaded} ? "used" : "empty")." node ".$xmlname.' ['.$n->{debug_id}.']');

      # found it! is this node already used?
      if ($n->{loaded}) {

        # yes, create a new one
        my $new_node = dclone($metadata_nodes_hash->{$xmlns . '/' . $xmlname});
        if ($new_node->{ordered}) {
          $new_node->{data_order} = int($n->{data_order}) + 1;
        }

        # and add it to the structure
        splice @{$parent->{children}}, $i, 0, $new_node;
        $node = $new_node;
      }
      else {
        # no, use the found one
        $node = $n;
      }

      $node->{loaded} = 1;
    }

    elsif ($children_size > 0) {
      $node = $self->get_empty_node($c, $ns, $id, $n, $metadata_nodes_hash);
    }

    $i++;

    last if defined $node;
  }

  return $node;
}

sub create_md_nodes_hash {

  my $self     = shift;
  my $c        = shift;
  my $children = shift;
  my $h        = shift;

  foreach my $n (@{$children}) {

    $h->{$n->{xmlns} . '/' . $n->{xmlname}} = $n;

    my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
    if ($children_size > 0) {
      $self->create_md_nodes_hash($c, $n->{children}, $h);
    }

  }

}

sub set_identifier() {
  my $self     = shift;
  my $c        = shift;
  my $pid      = shift;
  my $metadata = shift;

  foreach my $n (@{$metadata}) {
    if ($n->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0' && $n->{xmlname} eq 'identifier') {
      $n->{ui_value} = $pid;
      last;
    }
    else {
      my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
      if ($children_size > 0) {
        $self->set_identifier($c, $pid, $n->{children});
      }
    }
  }
}

# this method finds node of given namespace and xmlname
#
# xxx !! DANGER !! xxx
# A node is generally not defined only with namespace and xmlname
# but also with the position in the tree.
# The only node however, where the namespace and xmlname is not enough is:
# namespace: http://phaidra.univie.ac.at/XML/metadata/lom/V1.0
# xmlname: description
# because there are two, one on 'general' tab and one on 'rights'
# xxx !! xxxxxx !! xxx
#
sub get_json_node() {
  my ($self, $c, $namespace, $xmlname, $metadata) = @_;

  my $ret;
  foreach my $n (@{$metadata}) {
    if ($n->{xmlns} eq $namespace && $n->{xmlname} eq $xmlname) {
      $ret = $n;
      last;
    }
    else {
      my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
      if ($children_size > 0) {
        $ret = $self->get_json_node($c, $namespace, $xmlname, $n->{children});
        last if ($ret);
      }
    }
  }
  return $ret;
}

sub set_json_node_value() {
  my ($self, $c, $namespace, $xmlname, $metadata, $value) = @_;
  my $n = $self->get_json_node($c, $namespace, $xmlname, $metadata);
  if ($n) {
    $n->{'value'} = $value;
  }
}

sub set_json_node_ui_value() {
  my ($self, $c, $namespace, $xmlname, $metadata, $value) = @_;
  my $n = $self->get_json_node($c, $namespace, $xmlname, $metadata);
  if ($n) {
    $n->{'ui_value'} = $value;
  }
}

# i) set identifier, or add and set if not there
# i) add and set upload_date if not there
# i) add and set status if not there (default = http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/44 [Complete])
# i) add and set cost if not there (default = 0)
# i) add and set copyright if not there (default = 1)
# i) add empty classification node if missing (validation needs it)
sub fix_uwmetadata() {
  my $self     = shift;
  my $c        = shift;
  my $pid      = shift;
  my $metadata = shift;

  #$c->app->log->debug("Uwmetadata before fix: ".$c->app->dumper($metadata));

  # set identifier, or add and set if not there
  my $n = $self->get_json_node($c, 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0', 'identifier', $metadata);
  if (defined($n)) {
    $n->{'ui_value'} = $pid;
  }
  else {
    # $metadata[0] - general
    my $ch = @{$metadata}[0]->{'children'};
    splice(
      @{$ch},
      0, 0,
      { xmlns    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0",
        xmlname  => "identifier",
        datatype => "CharacterString",
        ui_value => $pid
      }
    );
  }

  # add and set upload date if not there
  # 2014-02-23T10:08:57.831Z
  $n = $self->get_json_node($c, 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0', 'upload_date', $metadata);
  unless ($n) {

    # $metadata[1] - lifecycle
    my $ch = @{$metadata}[1]->{'children'};

    # index 0, upload_date is first
    splice(
      @{$ch},
      0, 0,
      { xmlns    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0",
        xmlname  => "upload_date",
        datatype => "DateTime",
        ui_value => strftime("%Y-%m-%dT%H:%M:%S.000Z", gmtime(time))
      }
    );
  }
  if (!defined($n->{ui_value}) || $n->{ui_value} eq '') {
    $n->{ui_value} = strftime("%Y-%m-%dT%H:%M:%S.000Z", gmtime(time));
  }

  # add and set status if not there
  $n = $self->get_json_node($c, 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0', 'status', $metadata);
  unless ($n) {

    # $metadata[1] - lifecycle
    my $ch = @{$metadata}[1]->{'children'};

    # index 1, 0 is upload_date
    splice(
      @{$ch},
      1, 0,
      { xmlns    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0",
        xmlname  => "status",
        datatype => "Vocabulary",
        ui_value => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/44"
      }
    );
  }
  if (!defined($n->{ui_value}) || $n->{ui_value} eq '') {
    $n->{ui_value} = "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/44";
  }

  # find the index of rights tab
  my $i = 0;
  my $rights_idx;
  foreach my $n (@{$metadata}) {
    if ($n->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0' && $n->{xmlname} eq 'rights') {
      $rights_idx = $i;
    }
    $i++;
  }

  # add and set cost if not there
  $n = $self->get_json_node($c, 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0', 'cost', $metadata);
  unless ($n) {
    my $ch = @{$metadata}[$rights_idx]->{'children'};

    # index 0, cost is first
    splice(
      @{$ch},
      0, 0,
      { xmlns    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0",
        xmlname  => "cost",
        datatype => "Boolean",
        ui_value => "no"
      }
    );
  }
  if (!defined($n->{ui_value}) || $n->{ui_value} eq '') {
    $n->{ui_value} = "no";
  }

  # add and set copyright if not there
  $n = $self->get_json_node($c, 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0', 'copyright', $metadata);
  unless ($n) {
    my $ch = @{$metadata}[$rights_idx]->{'children'};

    # index 1, 0 is cost
    splice(
      @{$ch},
      1, 0,
      { xmlns    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0",
        xmlname  => "copyright",
        datatype => "Boolean",
        ui_value => "yes"
      }
    );
  }
  if (!defined($n->{ui_value}) || $n->{ui_value} eq '') {
    $n->{ui_value} = "yes";
  }

  # add empty classification node if missing
  my $found = undef;
  foreach my $n (@{$metadata}) {
    if ($n->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0' && $n->{xmlname} eq 'classification') {
      $found = 1;
      last;
    }
  }

  # not found, add, after rights
  unless (defined($found)) {
    splice(
      @{$metadata},
      $rights_idx + 1,
      0,
      { xmlns    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0",
        xmlname  => "classification",
        datatype => "Node"
      }
    );
  }

  #$c->app->log->debug("Uwmetadata after fix: ".$c->app->dumper($metadata));
}

sub save_to_object() {

  my $self     = shift;
  my $c        = shift;
  my $pid      = shift;
  my $metadata = shift;
  my $username = shift;
  my $password = shift;
  my $skiphook = shift;

  my $res = {alerts => [], status => 200};

  $self->fix_uwmetadata($c, $pid, $metadata);

  my $uwmetadata = $self->json_2_uwmetadata($c, $metadata);

  unless ($uwmetadata) {
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error converting metadata'};
    return $res;
  }

  if ($c->app->config->{validate_uwmetadata}) {
    my $util_model = PhaidraAPI::Model::Util->new;
    my $valres     = $util_model->validate_xml($c, $uwmetadata, $c->app->config->{validate_uwmetadata});
    if ($valres->{status} != 200) {
      $res->{status} = $valres->{status};
      foreach my $a (@{$valres->{alerts}}) {
        unshift @{$res->{alerts}}, $a;
      }
      return $res;
    }
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  return $object_model->add_or_modify_datastream($c, $pid, "UWMETADATA", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $uwmetadata, "X", undef, undef, $username, $password, 0, $skiphook);

}

sub add_dummy_metadata() {

  my $self   = shift;
  my $c      = shift;
  my $parser = shift;
  my $doc    = shift;

  my $cfg;
  foreach my $node ($doc->findnodes('//namespace::*')) {
    $cfg->{namespace}{$node->getLocalName()} = $node->getValue();
    $cfg->{short}{$node->getValue()}         = $node->getLocalName();
  }

  my $xc = XML::LibXML::XPathContext->new($doc);
  for my $ns (keys %{$cfg->{namespace}}) {
    $xc->registerNs($ns => $cfg->{namespace}->{$ns});
  }

  my $uwmetans = $cfg->{short}->{"http://phaidra.univie.ac.at/XML/metadata/V1.0"};
  my $lomns    = $cfg->{short}->{"http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"};

  # add pid
  my $xpath   = "/$uwmetans:uwmetadata/$lomns:general";
  my $nodeset = $xc->findnodes($xpath);
  my $generalnode;
  foreach my $gnode ($nodeset->get_nodelist) {
    $generalnode = $gnode;
    last;
  }
  $xpath   = "/$uwmetans:uwmetadata/$lomns:general/$lomns:identifier";
  $nodeset = $xc->findnodes($xpath);
  my $pidnode = undef;
  foreach my $node ($nodeset->get_nodelist) {
    $pidnode = $node;
    my $pidnodenew = $parser->parse_balanced_chunk('<' . $lomns . ':identifier xmlns:' . $lomns . '="http://phaidra.univie.ac.at/XML/metadata/lom/V1.0">o:1</' . $lomns . ':identifier>');
    $generalnode->insertAfter($pidnodenew, $pidnode);
    $generalnode->removeChild($pidnode);
    last;
  }

  #add upload_date
  $xpath   = "/$uwmetans:uwmetadata/$lomns:lifecycle";
  $nodeset = $xc->findnodes($xpath);
  my $lifecyclenode;
  foreach my $lnode ($nodeset->get_nodelist) {
    $lifecyclenode = $lnode;
    last;
  }
  $xpath   = "/$uwmetans:uwmetadata/$lomns:lifecycle/$lomns:upload_date";
  $nodeset = $xc->findnodes($xpath);
  my $upload_date_node = undef;
  foreach my $node ($nodeset->get_nodelist) {
    $upload_date_node = $node;
    my $upload_date_node_new = $parser->parse_balanced_chunk('<' . $lomns . ':upload_date xmlns:' . $lomns . '="http://phaidra.univie.ac.at/XML/metadata/extended/V1.0">1970-01-01T00:00:00.000Z</' . $lomns . ':upload_date>');
    $generalnode->insertAfter($upload_date_node_new, $upload_date_node);
    $generalnode->removeChild($upload_date_node);
    last;
  }
}

sub json_2_uwmetadata() {

  my $self     = shift;
  my $c        = shift;
  my $metadata = shift;

  # 1) unfortunately in UWMETADATA, the namespace prefixes are numbered (ns0, ns1,...)
  # 2) unfortunately the namespace prefixes are numbered rather randomly
  # 3) unfortunately some scripts have the prefixes hardcoded (@xyz = $class->getChildrenByTagName("ns7:source");)
  # If this api would only edit objects, we could now sacrifice one call to get the current uwmetadata and read out
  # the prefix-namespace mapping, so that we don't change a thing.
  # But this api also creates objects, so it will impose it's prefix-namespace mapping anyway.
  # To be transparent, we should just number the namespaces as they appear in this json tree, but some
  # elements (namely all optional fields) might not even be there - and UWMETADATA files without those namespaces
  # might create problems. So to minimize the damage, we will simply statically define the mapping here,
  # in the way they usually occure in an object. Howgh.
  my $prefixmap = {
    "http://phaidra.univie.ac.at/XML/metadata/V1.0"                    => 'ns0',
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"                => 'ns1',
    "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"           => 'ns2',
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"         => 'ns3',
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement"    => 'ns4',
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"    => 'ns5',
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation"     => 'ns6',
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification" => 'ns7',
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"   => 'ns8',
    "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"           => 'ns9',
    "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"        => 'ns10',
    "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity" => 'ns11',
    "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"        => 'ns12',
    "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"            => 'ns13'
  };
  my $forced_declarations = [
    "http://phaidra.univie.ac.at/XML/metadata/V1.0",                  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0",             "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0",       "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity",
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement",  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational", "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation", "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification",
    "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization", "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0",        "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0",    "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity",
    "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0",      "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
  ];

  my $xml    = '';
  my $writer = XML::Writer->new(
    OUTPUT          => \$xml,
    NAMESPACES      => 1,
    PREFIX_MAP      => $prefixmap,
    FORCED_NS_DECLS => $forced_declarations,
    DATA_MODE       => 1,
    ENCODING        => 'utf-8'
  );

  $writer->startTag(["http://phaidra.univie.ac.at/XML/metadata/V1.0", "uwmetadata"]);
  $self->json_2_uwmetadata_rec($c, undef, $metadata, $writer);
  $writer->endTag(["http://phaidra.univie.ac.at/XML/metadata/V1.0", "uwmetadata"]);

  $writer->end();

  #$c->app->log->debug("XXXXXXXXXXXXXXXX json2uwmetadata result:\n".$xml);
  return $xml;
}

# we need that an element in the json structure contains at least
# - xmlns
# - xmlname
# - ui_value
# - ordered
# - datatype
# - data_order (if any)
# - language (if any)
sub json_2_uwmetadata_rec() {

  my $self     = shift;
  my $c        = shift;
  my $parent   = shift;
  my $children = shift;
  my $writer   = shift;

  foreach my $child (@{$children}) {

    my $children_size = defined($child->{children}) ? scalar(@{$child->{children}}) : 0;

    # some elements are not allowed to be empty, so if these are empty we cannot add them to uwmetadata
    # but some special needs to be there anyway: classification, mandatory fields like general/description, lifecycle/status, rights/cost, etc..
    my $canskip = 1;
    if ($child->{xmlname} eq 'classification'
      || (($child->{xmlname} eq 'description') && ($child->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0') && ($parent->{xmlname} ne 'rights')))
    {
      $canskip = 0;
    }
    if ($child->{mandatory}) {
      $canskip = 0;
    }

    #if(defined($parent)){
    #	if($child->{xmlname} eq 'description' && $parent->{xmlname} eq 'general'){
    #		$canskip = 0;
    #	}
    #}
    if ($canskip && (!defined($child->{ui_value}) || ($child->{ui_value} eq '')) && $children_size == 0) {
      next;
    }

    # this way we remove source and taxon from taxonpath,
    # but then the taxonpath will be empty
    if ($child->{xmlname} eq 'taxonpath') {

      # check 'source'
      if (@{$child->{children}}[0]->{ui_value} eq '') {

        # if it's empty, we skip the whole taxonpath
        next;
      }
    }

    my %attrs;

    ### attributes, old way
    if ($child->{ordered}) {
      $attrs{seq} = $child->{data_order};
    }
    if (defined($child->{value_lang}) && $child->{value_lang} ne '') {
      $attrs{language} = $child->{value_lang};
    }

    ### attributes, new way
    if (exists($child->{attributes})) {
      for my $a (@{$child->{attributes}}) {
        if ($a->{xmlname} eq 'data_order') {
          $attrs{seq} = $a->{ui_value};
        }
        if ($a->{xmlname} eq 'lang') {
          $attrs{language} = $a->{ui_value};
        }
      }
    }

    if (%attrs) {
      $writer->startTag([$child->{xmlns}, $child->{xmlname}], %attrs);
    }
    else {
      $writer->startTag([$child->{xmlns}, $child->{xmlname}]);
    }

    if ($children_size > 0) {
      $self->json_2_uwmetadata_rec($c, $child, $child->{children}, $writer);
    }
    else {

      # hack, until vocabulary server
      if ( $child->{datatype} eq 'Vocabulary'
        || $child->{datatype} eq 'License'
        || $child->{datatype} eq 'Faculty'
        || $child->{datatype} eq 'Department'
        || $child->{datatype} eq 'SPL'
        || $child->{datatype} eq 'Curriculum')
      {

        # eg http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/6
        if ($child->{ui_value} =~ m/($child->{xmlns})\/voc_(\w+)\/(\w+)/) {
          $writer->characters($3);
        }

      }
      elsif ($child->{datatype} eq 'ClassificationSource') {

        # eg http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_7
        if ($child->{ui_value} =~ m/($child->{xmlns})\/cls_(\d+)/) {
          $writer->characters($2);
        }

      }
      elsif ($child->{datatype} eq 'Taxon') {

        # http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_7/169426
        if ($child->{ui_value} =~ m/($child->{xmlns})\/cls_(\d+)\/(\w+)/) {
          $writer->characters($3);
        }

      }
      else {
        if ($child->{datatype} eq 'Boolean') {
          my $val = $child->{ui_value};
          if ($val eq '1') {
            $val = 'yes';
          }
          if ($val eq '0') {
            $val = 'no';
          }
          $writer->characters($val);
        }
        else {
          if ($child->{ui_value}) {
            $writer->characters($child->{ui_value});
          }
        }
      }
    }

    $writer->endTag([$child->{xmlns}, $child->{xmlname}]);
  }
}

# we need that an element in the json structure contains at least
# - xmlns
# - xmlname
# - ui_value
# - ordered
# - datatype
# - data_order (if any)
# - value_lang (if any)
sub compress_json {

  my $self         = shift;
  my $c            = shift;
  my $uncompressed = shift;
  my $compressed   = shift;

  foreach my $child (@{$uncompressed}) {

    my $children_size = defined($child->{children}) ? scalar(@{$child->{children}}) : 0;

    # some elements are not allowed to be empty, so if these are empty we cannot add them to uwmetadata
    # but some special needs to be there anyway: classification, mandatory fields like general/description, lifecycle/status, rights/cost, etc..
    my $canskip = 1;
    if ($child->{xmlname} eq 'classification') {
      $canskip = 0;
    }
    if ($child->{mandatory}) {
      $canskip = 0;
    }

    if (
         $canskip
      && !$self->children_not_empty_rec($c, $child->{children})
      && (!defined($child->{ui_value})
        || ($child->{ui_value} eq ''))
      )
    {
      next;
    }

    # this way we remove source and taxon from taxonpath,
    # but then the taxonpath will be empty
    if ($child->{xmlname} eq 'taxonpath') {

      # check 'source'
      if (@{$child->{children}}[0]->{ui_value} eq '') {

        # if it's empty, we skip the whole taxonpath
        next;
      }
    }

    my $compressed_child = {
      xmlns    => $child->{xmlns},
      xmlname  => $child->{xmlname},
      ordered  => $child->{ordered},
      datatype => $child->{datatype},
    };
    if (exists($child->{data_order})) {
      $compressed_child->{data_order} = $child->{data_order};
    }
    if ($child->{datatype} ne 'Node') {
      if (exists($child->{value_lang})) {
        $compressed_child->{value_lang} = $child->{value_lang};
      }
      $compressed_child->{ui_value} = $child->{ui_value};
    }

    push @$compressed, $compressed_child;

    if ($children_size > 0) {
      my @compressed_children = ();
      $compressed_child->{children} = \@compressed_children;
      $self->compress_json($c, $child->{children}, $compressed_child->{children});
    }

  }
}

sub children_not_empty_rec {
  my $self     = shift;
  my $c        = shift;
  my $children = shift;

  my $ret = 0;
  for my $child (@{$children}) {
    if ($child->{ui_value} ne '') {
      $ret = 1;
      last;
    }
    else {
      my $children_size = defined($child->{children}) ? scalar(@{$child->{children}}) : 0;
      if ($children_size > 0) {
        $ret = $self->children_not_empty_rec($c, $child->{children});
        last if $ret;
      }
    }
  }

  return $ret;
}

sub decompress_json {

  my $self       = shift;
  my $c          = shift;
  my $compressed = shift;

  my $terms_model = PhaidraAPI::Model::Terms->new;

  # this structure contains the metadata default structure (equals to empty uwmetadataeditor) to which
  # we are going to load the data of some real object
  my $tree_res = $self->metadata_tree($c);
  if ($tree_res->{status} ne 200) {
    return $tree_res;
  }

  my $metadata_tree = $tree_res->{metadata_tree};

  # this is a hash where the key is 'ns/id' and value is a default representation of a node
  # -> we use this when adding nodes (eg a second title) to get a new empty node
  my %metadata_nodes_hash;
  my $metadata_tree_copy = dclone($metadata_tree);
  $self->create_md_nodes_hash($c, $metadata_tree_copy, \%metadata_nodes_hash);

  $self->decompress_json_rec($c, $terms_model, $compressed, $metadata_tree, undef, \%metadata_nodes_hash);

  return $metadata_tree;
}

sub decompress_json_rec {

  my $self                = shift;
  my $c                   = shift;
  my $terms_model         = shift;
  my $compressed          = shift;
  my $decompressed        = shift;
  my $decompressed_parent = shift;
  my $metadata_nodes_hash = shift;

  unless (defined($decompressed_parent)) {
    my %h = ('children' => $decompressed);
    $decompressed_parent = \%h;
  }

  for my $ch (@{$compressed}) {

    my $children_size = defined($ch->{children}) ? scalar(@{$ch->{children}}) : 0;

    my $node;
    if ($ch->{xmlname} ne 'uwmetadata') {

      # search this node in the metadata tree
      # get one where metadata from uwmetadata were not yet loaded
      $node = $self->get_empty_node($c, $ch->{xmlns}, $ch->{xmlname}, $decompressed_parent, $metadata_nodes_hash);

      if ($ch->{ui_value}) {

        $node->{ui_value}   = $ch->{ui_value};
        $node->{value_lang} = $ch->{value_lang} if ($ch->{value_lang});
        $node->{data_order} = $ch->{data_order} if ($ch->{data_order});

        if ($node->{xmlname} eq 'taxon') {
          my $labels = $terms_model->label($c, $ch->{ui_value});
          if ($labels->{status} eq 200) {
            $node->{value_labels} = $labels->{labels};
          }
          else {
            $c->app->log->error("Can't get labels for taxon [" . $ch->{ui_value} . "]");
          }
        }

        if ($node->{ordered}) {
          @{$decompressed_parent->{children}} = sort {sort_ordered($a) <=> sort_ordered($b)} @{$decompressed_parent->{children}};
        }
      }

    }
    if ($children_size > 0) {
      $self->decompress_json_rec($c, $terms_model, $ch->{children}, $decompressed, $node, $metadata_nodes_hash);
    }
  }

}

1;
__END__
