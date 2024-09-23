package PhaidraAPI::Model::Uwmetadata::Extraction;

use strict;
use warnings;
use v5.10;
use utf8;
use Mojo::Util qw(html_unescape);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::ByteStream qw(b);
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Terms;

our %cmodelMapping = (
  'Picture'       => 'Image',
  'Audio'         => 'Sound',
  'Collection'    => 'Collection',
  'Container'     => 'Dataset',
  'Video'         => 'MovingImage',
  'PDFDocument'   => 'Text',
  'LaTeXDocument' => 'Text',
  'Resource'      => 'InteractiveResource',
  'Asset'         => 'Unknown',
  'Book'          => 'Book',
  'Page'          => 'Page',
  'Paper'         => 'Text',
);

our %uwns = (
  'http://phaidra.univie.ac.at/XML/metadata/V1.0'                    => 'metadata',
  'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0'                => 'lom',
  'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0'           => 'extended',
  'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity'         => 'entity',
  'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement'    => 'requirement',
  'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational'    => 'educational',
  'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation'     => 'annotation',
  'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification' => 'classification',
  'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization'   => 'organization',
  'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0'           => 'histkult',
  'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0'        => 'provenience',
  'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity' => 'provenience_entity',
  'http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0'        => 'digitalbook',
  'http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0'            => 'etheses'
);

our %uwns_rev = reverse %uwns;

our %uw_vocs = (
  'hoschtyp'          => '17',
  'infoeurepoversion' => '38',
  'resource'          => '31',
  'infoeurepoaccess'  => '36'
);

our %non_contributor_role_ids = (
  'author_analog'  => '1552095',
  'author_digital' => '46',
  'editor'         => '52',
  'publisher'      => '47',
  'uploader'       => '1557146',
);

our %non_contributor_role_ids_rev = reverse %non_contributor_role_ids;

# {i}, {b}, {br}, {mailto}, {link}
sub _remove_phaidra_tags($) {
  my ($self, $c, $v) = @_;
  $v =~ s/{b}|{\/b}|{i}|{\/i}|{link}|{\/link}|{br}|{mailto}|{\/mailto}//g;
  return $v;
}

sub _get_uwm_classifications {
  my ($self, $c, $dom, $doc_uwns) = @_;

  my $uselang;
  if (exists($c->config->{terms}->{dc_subject_languages})) {
    my %uselangtmp = map {$_ => 1} @{$c->config->{terms}->{dc_subject_languages}};
    $uselang = \%uselangtmp;
  }

  my @classifications;
  for my $idnode ($dom->find($doc_uwns->{'classification'} . '\:taxonpath')->each) {

    my $cid = $idnode->find($doc_uwns->{'classification'} . '\:source')->last;
    if (defined($cid)) {
      $cid = $cid->text;
    }

    my $terms_model = PhaidraAPI::Model::Terms->new;
    my $cls_labels  = $terms_model->_get_vocab_labels($c, undef, undef, $cid);
    if ($cid eq '5' or $cid eq '6' or $cid eq '7') {
      my $tid = $idnode->find($doc_uwns->{'classification'} . '\:taxon')->last;
      if (defined($tid)) {
        $tid = $tid->text;
      }
      my $labels = $terms_model->_get_taxon_labels($c, $cid, $tid);
      for my $lang (keys %{$labels->{labels}}) {

        if (defined($uselang)) {
          next unless $uselang->{$lang};
        }
        push @classifications, {value => $cls_labels->{$lang} . ", " . $labels->{labels}->{$lang}, lang => $lang};
      }
    }
    else {
      for my $lang (keys %{$cls_labels}) {

        if (defined($uselang)) {
          next unless $uselang->{$lang};
        }
        my $path = $cls_labels->{$lang};
        for my $tid ($idnode->find($doc_uwns->{'classification'} . '\:taxon')->each) {
          $tid = $tid->text;
          my $termLabels = $terms_model->_get_taxon_labels($c, $cid, $tid);
          if ($termLabels->{labels}->{$lang}) {
            if ($cid ne '8' or $cid ne '9' or $cid ne '12') {

              # show upstream ID for BIC (request from OAPEN/Atmire, issue #22457) and other classifications too if it seems meaningful...
              $path .= " -- " . $termLabels->{labels}->{$lang} . ' (' . $termLabels->{upstream_identifier} . ')';
            }
            else {
              $path .= " -- " . $termLabels->{labels}->{$lang};
            }
          }
        }
        push @classifications, {value => $path, lang => $lang};
      }
    }

  }

  return \@classifications;
}

sub _get_uwm_relations {
  my ($self, $c, $dom, $doc_uwns) = @_;

  my $relations;
  for my $idnode ($dom->find($doc_uwns->{'histkult'} . '\:reference_number')->each) {
    my $res = $idnode->find($doc_uwns->{'histkult'} . '\:reference')->first;
    if (defined($res)) {
      $res = $res->text;
    }

    #my $reslabel;
    #if(defined($res)){
    #  $reslabel = $self->_get_value_label($c, $doc_uwns->{'extended'}, 'resource', $res->text, $uw_vocs{'reference'} $tree, $metadata_model, 'en');
    #}
    my $id = $idnode->find($doc_uwns->{'histkult'} . '\:number')->first;
    if (defined($id) && $id->text ne '') {
      my $prefix = '';
      if ($res eq '1556222') {
        push @$relations, {value => 'info:eu-repo/grantAgreement/EC/FP7/' . $id->text};
      }
      if ($res eq '1562802') {
        push @$relations, {value => 'http://d-nb.info/gnd/' . $id->text};
      }
      if ($res eq '1562603') {
        push @$relations, {value => 'isPartOf:' . $id->text};
      }
    }
  }

  return $relations;
}

sub _get_uwm_identifiers {
  my ($self, $c, $dom, $doc_uwns, $tree, $metadata_model) = @_;

  my $identifiers;
  for my $idnode ($dom->find($doc_uwns->{'extended'} . '\:identifiers')->each) {
    my $res = $idnode->find($doc_uwns->{'extended'} . '\:resource')->first;
    my $reslabel;
    if (defined($res)) {
      $res = $res->text;
      if ($res eq '1552099') {
        $reslabel = 'doi:';
      }
      elsif ($res eq '1552103') {

        # $reslabel = 'urn:'; urn already includes this
      }
      else {
        $reslabel = $self->_get_value_label($c, $uwns_rev{'extended'}, 'resource', $res, $uw_vocs{'resource'}, $tree, $metadata_model, 'en');
        if ($reslabel) {
          $reslabel = $reslabel . ": ";
        }
      }
    }

    my $id = $idnode->find($doc_uwns->{'extended'} . '\:identifier')->first;
    if (defined($id) && $id->text ne '') {
      if ($reslabel) {
        push @$identifiers, {value => "$reslabel" . $id->text};
      }
      else {
        push @$identifiers, {value => $id->text};
      }
    }
  }

  return $identifiers;
}

sub _get_sources {
  my ($self, $c, $dom, $doc_uwns, $tree, $metadata_model) = @_;

  my $srcs;
  for my $idnode ($dom->find($doc_uwns->{'extended'} . '\:identifiers')->each) {
    my $res = $idnode->find($doc_uwns->{'extended'} . '\:resource')->first;
    if (defined($res)) {
      $res = $res->text;
    }

    #my $reslabel;
    #if(defined($res)){
    #  $reslabel = $self->_get_value_label($c, $doc_uwns->{'extended'}, 'resource', $res->text, $uw_vocs{'resource'}, $tree, $metadata_model, 'en');
    #}
    my $id = $idnode->find($doc_uwns->{'extended'} . '\:identifier')->first;
    if (defined($id) && $id->text ne '') {
      my $prefix = '';
      if ($res eq '1552101') {
        push @$srcs, {value => 'ISSN:' . $id->text};
      }
      if ($res eq '1552255') {
        push @$srcs, {value => 'PrintISSN:' . $id->text};
      }
      if ($res eq '1552256') {
        push @$srcs, {value => 'eISSN:' . $id->text};
      }
    }
  }

  my $journal = $dom->find($doc_uwns->{'digitalbook'} . '\:name_magazine')->first;
  $journal = $journal->text if (defined($journal));

  my $volume = $dom->find($doc_uwns->{'digitalbook'} . '\:volume')->first;
  $volume = $volume->text if (defined($volume));

  my $booklet = $dom->find($doc_uwns->{'digitalbook'} . '\:booklet')->first;
  $booklet = $booklet->text if (defined($booklet));

  my $from = $dom->find($doc_uwns->{'digitalbook'} . '\:from_page')->first;
  $from = $from->text if (defined($from));

  my $to = $dom->find($doc_uwns->{'digitalbook'} . '\:to_page')->first;
  $to = $to->text if (defined($to));

  my $releaseyear = $dom->find($doc_uwns->{'digitalbook'} . '\:releaseyear')->first;
  $releaseyear = $releaseyear->text if (defined($releaseyear));

  my $source = $journal;
  $source .= " $volume"        if (defined($volume)      && $volume ne '');
  $source .= "($booklet)"      if (defined($booklet)     && $booklet ne '');
  $source .= ", $from"         if (defined($from)        && $from ne '');
  $source .= "-$to"            if (defined($to)          && $to ne '');
  $source .= " ($releaseyear)" if (defined($releaseyear) && $releaseyear ne '');
  if (defined($journal) && $journal ne '') {
    push @{$srcs}, {value => $source};
  }

  return $srcs;
}

sub _get_licenses {

  my ($self, $c, $dom, $doc_uwns, $tree, $metadata_model) = @_;

  my @arr;
  my $vals = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'lom'} . '\:license');

  my $licenses_model = PhaidraAPI::Model::Licenses->new;
  my $licenses       = $licenses_model->get_licenses($c);
  for my $v (@{$vals}) {
    my $lic_label = '';
    my $lic_link  = '';
    for my $lic (@{$licenses->{licenses}}) {
      if ($v->{value} eq $lic->{lid}) {
        push @arr, {value => $lic->{labels}->{en}};
        push @arr, {value => $lic->{link_uri}} unless $lic->{lid} eq 1;
      }
    }
  }

  return \@arr;
}

# NOTE: dunno if _get_licenses is used elsewhere, for DataCite, we need the URIs to be an attribute, not an additional value in the list
sub _get_licenses_datacite {

  my ($self, $c, $dom, $doc_uwns, $tree, $metadata_model) = @_;

  my @arr;
  my $vals = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'lom'} . '\:license');

  my $licenses_model = PhaidraAPI::Model::Licenses->new;
  my $licenses       = $licenses_model->get_licenses($c);
  for my $v (@{$vals}) {
    my $lic_label = '';
    my $lic_link  = '';
    for my $lic (@{$licenses->{licenses}}) {
      if ($v->{value} eq $lic->{lid}) {
        push @arr, my $obj = {value => $lic->{labels}->{en}};
        $obj->{link_uri} = $lic->{link_uri} unless $lic->{lid} eq 1;
      }
    }
  }

  return \@arr;
}

sub _get_formats {

  my ($self, $c, $pid, $cmodel, $dom, $doc_uwns) = @_;

  my $formats;
  if (($cmodel ne 'Resource') && ($cmodel ne 'Collection')) {
    $formats = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'lom'} . '\:format');
  }

  return $formats;
}

sub _get_infoeurepoaccess {

  my ($self, $c, $dom, $doc_uwns, $tree, $metadata_model, $mode) = @_;

  $mode = 'p' unless defined $mode;

  my @acc;
  my $vals = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'extended'} . '\:infoeurepoaccess');

  for my $v (@{$vals}) {

    #$c->app->log->debug("XXXXXXXX ".$v->{value});
    my $acclabel = $self->_get_value_label($c, $uwns_rev{'extended'}, 'infoeurepoaccess', $v->{value}, $uw_vocs{'infoeurepoaccess'}, $tree, $metadata_model, 'en');

    #$c->app->log->debug("XXXXXXXX ".$c->app->dumper($vals));
    if ($mode eq 'oai') {
      push @acc, {value => "info:eu-repo/semantics/$acclabel"};
    }
    else {
      push @acc, {value => $acclabel};
    }
  }

  return \@acc;
}

sub _get_value_label {
  my ($self, $c, $ns, $xmlname, $id, $vocid, $tree, $metadata_model, $lang) = @_;

  my $n = $metadata_model->get_json_node($c, $ns, $xmlname, $tree);

  #$c->app->log->debug("XXXXXXXXXXX ns[$ns] xmlname[$xmlname] id[$id] vocid[$vocid] node:".$c->app->dumper($n)."tree :".$c->app->dumper($tree));
  foreach my $term (@{$n->{vocabularies}[0]->{terms}}) {
    if ($term->{uri} eq $ns . "/voc_$vocid/$id") {
      return $term->{labels}->{$lang};
    }
  }
}

sub _get_types {
  my ($self, $c, $cmodel, $dom, $doc_uwns, $tree, $metadata_model, $mode) = @_;

  $mode = 'p' unless defined $mode;

  my $types;
  if (my $hst = $dom->find($doc_uwns->{'organization'} . '\:hoschtyp')->first) {
    my $id = $hst->text;
    my $n  = $metadata_model->get_json_node($c, $uwns_rev{'organization'}, 'hoschtyp', $tree);
    foreach my $term (@{$n->{vocabularies}[0]->{terms}}) {
      if ($term->{uri} eq $uwns_rev{'organization'} . "/voc_" . $uw_vocs{'hoschtyp'} . "/$id") {

        if ($mode eq 'oai') {

          if ($id eq '1552261' || $id eq '1552259' || $id eq '1743' || $id eq '1552258') {

            # 1) in case it's a value which is not supported by OpenAIRE, put 'Other'
            # "Lecture series (one person)", "Multimedia", "Professorial Dissertation", "Theses"
            push @{$types}, {value => "info:eu-repo/semantics/other"};
          }
          elsif ($id eq '1739' || $id eq '1740' || $id eq '1741') {

            # 2) mapping of "Diploma Dissertation", "Master's (Austria) Dissertation", "Master's Dissertation"
            push @{$types}, {value => "info:eu-repo/semantics/masterThesis"};
          }
          else {
            my $value = $term->{labels}->{en};
            $value = lcfirst($value);
            $value =~ s/\s+//g;
            push @{$types}, {value => "info:eu-repo/semantics/" . $value};
          }
        }
        elsif ($mode eq 'p') {

          # en, I think we should not need this in another language really..
          push @{$types}, {value => lcfirst($term->{labels}->{en}), lang => 'en'};
        }

      }
    }
  }

  unless (defined($types)) {
    if (defined($cmodel) && exists($cmodelMapping{$cmodel})) {
      push @{$types}, {value => $cmodelMapping{$cmodel}, lang => 'en'};
    }
  }

  return $types;

}

sub _get_entities {
  my ($self, $c, $dom, $contributions, $doc_uwns, $ns, $roletype) = @_;

  my $entity_ns = $doc_uwns->{'entity'};
  if ($ns eq 'provenience') {
    $entity_ns = $doc_uwns->{'provenience_entity'};
  }

  my $irdata = 0;
  my $vals   = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'extended'} . '\:irdata');
  for my $v (@$vals) {
    $irdata = 1 if $v->{value} eq 'yes';
  }

  my @res;
  for my $ctr (@{$contributions}) {
    my @entities;
    for my $e ($ctr->find($doc_uwns->{$ns} . '\:entity')->sort(sub {$a->attr('seq') cmp $b->attr('seq')})->each) {

      my $firstname = $e->find($entity_ns . '\:firstname')->first;
      if (defined($firstname)) {
        $firstname = $firstname->text;
      }
      my $lastname = $e->find($entity_ns . '\:lastname')->first;
      if (defined($lastname)) {
        $lastname = $lastname->text;
      }

      my $institution = $e->find($entity_ns . '\:institution')->first;
      if (defined($institution)) {
        $institution = $institution->text;
      }

      if (defined($institution) && $institution ne '') {
        if ($c->app->config->{dcaffiliationcodes} && $institution =~ m/(\d)+/) {
          if (my $inststr = $self->_get_affiliation_cached($c, $institution, 'en')) {
            $institution = $inststr;
          }
        }
      }

      my $val;
      $val .= $lastname  if $lastname;
      $val .= ', '       if $val;
      $val .= $firstname if $firstname;
      if (($roletype eq 'publishers') && $irdata) {
        $val .= $institution if $institution;
      }
      else {
        if ($firstname or $lastname) {
          $val .= " ($institution)" if $institution;
        }
        else {
          $val .= " $institution" if $institution;
        }
      }

      push @entities, {value => $val, firstname => $firstname, lastname => $lastname, institution => $institution};
    }

    # if this is an object from institutional repository
    # and there are only two entities in the contribution
    # where the first has a name but no institution
    # and the second has an institution but not a name
    # then the second institution-entity is the affiliation of the first entity
    my $entities_length = scalar @entities;
    if ( ($entities_length == 2)
      && $irdata
      && ($entities[0]->{lastname} || $entities[0]->{firstname})
      && !($entities[0]->{institution})
      && !($entities[1]->{lastname})
      && !($entities[1]->{firstname})
      && $entities[1]->{institution})
    {
      my $firstname   = $entities[0]->{firstname};
      my $lastname    = $entities[0]->{lastname};
      my $institution = $entities[1]->{institution};
      my $val;
      $val .= $lastname         if $lastname;
      $val .= ', '              if $val;
      $val .= $firstname        if $firstname;
      $val .= " ($institution)" if $institution;
      push @res, {value => $val, firstname => $firstname, lastname => $lastname, institution => $institution};
    }
    else {
      for my $e (@entities) {
        push @res, $e;
      }
    }
  }

  return @res;
}

sub _get_contributors {

  my ($self, $c, $dom, $doc_uwns) = @_;

  my @res;
  for my $ns (('lom', 'provenience')) {
    my @conts;
    my @editors;
    my $has_authors = 0;
    for my $con ($dom->find($doc_uwns->{$ns} . '\:contribute')->sort(sub {$a->attr('seq') cmp $b->attr('seq')})->each) {
      my $role = $con->find($doc_uwns->{$ns} . '\:role')->first;
      if (defined($role)) {
        $role = $role->text;

        # save editors, we need them if there *are* authors defined
        if ($role eq $non_contributor_role_ids{'editor'}) {
          push @editors, $con;
        }
        if ($role eq $non_contributor_role_ids{'author_analog'} || $role eq $non_contributor_role_ids{'author_digital'}) {
          $has_authors = 1;
        }
        if (!exists($non_contributor_role_ids_rev{$role})) {
          push @conts, $con;
        }

      }
    }

    # if there are no authors then editors are creators
    # if there are authors then editors are contributors
    if ($has_authors) {
      for my $e (@editors) {
        push @conts, $e;
      }
    }

    push @res, $self->_get_entities($c, $dom, \@conts, $doc_uwns, $ns, 'contributors');
  }

  return \@res;
}

sub _get_publishers {

  my ($self, $c, $dom, $doc_uwns) = @_;

  my @res;
  for my $ns (('lom', 'provenience')) {
    my @publishers;
    for my $con ($dom->find($doc_uwns->{$ns} . '\:contribute')->sort(sub {$a->attr('seq') cmp $b->attr('seq')})->each) {
      my $role = $con->find($doc_uwns->{$ns} . '\:role')->first;
      if (defined($role)) {
        $role = $role->text;
        if ($role eq $non_contributor_role_ids{'publisher'}) {
          push @publishers, $con;
        }
      }
    }

    push @res, $self->_get_entities($c, $dom, \@publishers, $doc_uwns, $ns, 'publishers');

    # check publisher in digitalbook only once, not for 'provenience' namespace
    if ($ns eq 'lom') {
      my $publishers = $dom->find($doc_uwns->{'digitalbook'} . '\:publisher')->first;
      push @res, {value => $publishers->text} if (defined($publishers));
    }
  }

  return \@res;
}

sub _get_releaseyear {
  my ($self, $c, $dom, $doc_uwns) = @_;

  my @res;
  my $releaseyear = $dom->find($doc_uwns->{'digitalbook'} . '\:releaseyear')->first;
  push(@res, {value => $releaseyear->text}) if (defined($releaseyear));
  \@res;
}

sub _get_upload_date {
  my ($self, $c, $dom, $doc_uwns, $type) = @_;

  my @res;

  my $vals = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'lom'} . '\:upload_date');
  for my $v (@$vals) {
    push @res, $v->{value};
  }

  \@res;
}

sub _get_creators {

  my ($self, $c, $dom, $doc_uwns) = @_;

  my @res;
  for my $ns (('lom', 'provenience')) {
    my %creators;
    for my $con ($dom->find($doc_uwns->{$ns} . '\:contribute')->sort(sub {$a->attr('seq') cmp $b->attr('seq')})->each) {
      my $role = $con->find($doc_uwns->{$ns} . '\:role')->first;
      if (defined($role)) {
        $role = $role->text;

        if ($role eq $non_contributor_role_ids{'author_analog'}) {
          push @{$creators{author_analog}}, $con;
        }
        if ($role eq $non_contributor_role_ids{'author_digital'}) {
          push @{$creators{author_digital}}, $con;
        }
        if ($role eq $non_contributor_role_ids{'editor'}) {
          push @{$creators{editor}}, $con;
        }
      }
    }

    my @creators;
    if (exists($creators{author_analog}) && scalar @{$creators{author_analog}} > 0) {
      @creators = @{$creators{author_analog}};
    }
    elsif (exists($creators{author_digital}) && scalar @{$creators{author_digital}} > 0) {
      @creators = @{$creators{author_digital}};
    }
    elsif (exists($creators{editor}) && scalar @{$creators{editor}} > 0) {
      @creators = @{$creators{editor}};
    }

    push @res, $self->_get_entities($c, $dom, \@creators, $doc_uwns, $ns, 'creators');

  }
  return \@res;
}

sub _get_affiliation_cached {
  my ($self, $c, $code, $lang) = @_;

  my $inststr;
  my $cachekey = 'affid_' . $code . '_' . $lang;
  unless ($inststr = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");
    #$inststr = $c->app->directory->get_affiliation($c, $code, $lang);
    my $u = $c->app->directory->org_get_unit_for_notation($c, $code);
    if ($u) {
      for my $l (keys %{$u->{'skos:prefLabel'}}) {
        if ($l eq $lang) {
          $inststr = $u->{'skos:prefLabel'}->{$l};
        }
      }
    }
    $c->app->chi->set($cachekey, $inststr, '1 day');
  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $inststr;
}

sub _get_titles {

  my ($self, $c, $dom, $doc_uwns) = @_;

  my $maintitles = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'lom'} . '\:title');
  my $subtitles  = $self->_get_uwm_element_values($c, $dom, $doc_uwns->{'extended'} . '\:subtitle');

  # merge titles and subtitles
  my $titles;
  for my $mt (@{$maintitles}) {
    if (exists($mt->{lang})) {    # should always
      my $found = 0;

      # find subtitle with matching language
      for my $st (@{$subtitles}) {
        if ($mt->{lang} eq $st->{lang}) {
          push @{$titles}, {value => $mt->{value} . ': ' . $st->{value}, title => $mt->{value}, subtitle => $st->{value}, lang => $mt->{lang}};
          $found = 1;
        }
      }
      if (!$found) {
        push @{$titles}, {value => $mt->{value}, title => $mt->{value}, lang => $mt->{lang}};
      }
    }
  }

  return $titles;
}

sub _get_versions {

  my ($self, $c, $dom, $doc_uwns, $tree, $metadata_model, $mode) = @_;

  $mode = 'p' unless defined $mode;

  my @vals;
  for my $e ($dom->find($doc_uwns->{'extended'} . '\:infoeurepoversion')->each) {
    my %v = (ns => $e->namespace);

    my $n = $metadata_model->get_json_node($c, $uwns_rev{'extended'}, 'infoeurepoversion', $tree);
    foreach my $term (@{$n->{vocabularies}[0]->{terms}}) {
      my $id = $e->text;
      if ($term->{uri} eq $uwns_rev{'extended'} . "/voc_" . $uw_vocs{'infoeurepoversion'} . "/$id") {
        if ($mode eq 'oai') {
          $v{value} = "info:eu-repo/semantics/" . $term->{labels}->{en};
        }
        else {
          $v{value} = $term->{labels}->{en};
        }
        push @vals, \%v;
      }
    }

  }

  return \@vals;
}

sub _get_uwm_element_values {

  my ($self, $c, $dom, $elm) = @_;

  my @vals;
  for my $e ($dom->find($elm)->each) {
    my $value = $e->content;
    $value = html_unescape $self->_remove_phaidra_tags($c, $value);
    my %v = (value => $value, ns => $e->namespace);
    if ($e->attr('language')) {
      $v{lang} = $e->attr('language');
    }
    push @vals, \%v;
  }

  return \@vals;
}

1;
__END__
