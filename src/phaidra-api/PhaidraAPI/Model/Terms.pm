package PhaidraAPI::Model::Terms;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use PhaidraAPI::Model::Languages;

our $classification_ns = "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification";
our $organization_ns   = "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization";

# FIXME get this from database
our %voc_ids = (
  "http://phaidra.univie.ac.at/XML/metadata/V1.0"                    => undef,
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"                => ['2',  '3',  '6',  '21'],
  "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"           => ['31', '36', '38', '40'],
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"         => undef,
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement"    => ['4',  '5'],
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"    => ['10', '11', '12', '14', '15', '16'],
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation"     => undef,
  $classification_ns                                                 => ['9', '18', '20', '26', '27', '28', '29', '30', '33', '34', '35', '39', '41', '42', '43', '44'],
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"   => ['17'],
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"           => ['22', '23', '24', '25'],
  "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"        => ['3',  '24'],
  "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity" => undef,
  "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"        => ['32'],
  "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"            => undef
);

# FIXME get this from database
our @cls_ids = ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16');

sub _get_taxon_labels {
  my $self = shift;
  my $c    = shift;
  my $cid  = shift;
  my $tid  = shift;

  my ($entry, $isocode, $preferred, $upstream_identifier, $term_id);
  my $taxon;
  my $cachekey = 'taxon_labels_' . $cid . '_' . $tid;
  unless ($taxon = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $ss  = "SELECT t.upstream_identifier, tv.term_id, ve.entry, ve.isocode, tv.preferred FROM taxon t LEFT JOIN taxon_vocentry tv ON tv.tid = t.tid LEFT JOIN vocabulary_entry ve ON tv.veid = ve.veid WHERE t.cid = (?) and t.tid = (?)";
    my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->execute($cid, $tid);
    $sth->bind_columns(undef, \$upstream_identifier, \$term_id, \$entry, \$isocode, \$preferred);

    my %isocodes;
    while ($sth->fetch) {

      $taxon->{upstream_identifier} = $upstream_identifier;

      if ($preferred) {
        $taxon->{labels}{$isocode} = $entry;
        $taxon->{term_id} = $term_id;
      }
      else {
        $taxon->{nonpreferred}{$term_id}{$isocode} = $entry;
      }

      $isocodes{$isocode} = 1;
    }
    $sth->finish;
    undef $sth;

    # make nonpreferred an array
    my @nonpreferred;
    foreach my $termid (keys %{$taxon->{nonpreferred}}) {
      my %t;
      $t{term_id} = $termid;
      foreach my $iso (keys %{$taxon->{nonpreferred}{$termid}}) {
        $t{labels}{$iso} = $taxon->{nonpreferred}{$termid}{$iso};
      }
      push @nonpreferred, \%t;
    }
    $taxon->{nonpreferred} = \@nonpreferred;

    $c->app->chi->set($cachekey, $taxon, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $taxon;
}

sub _get_vocab_labels {
  my $self = shift;
  my $c    = shift;
  my $vid  = shift;
  my $veid = shift;
  my $cid  = shift;

  my $labels;
  $cid = $cid ? $cid : '';
  my $cachekey = 'vocab_labels_' . $vid . '_' . $veid . '_' . $cid;
  unless ($labels = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    # cid provided but tid not, this means we want to resolve the name of the classification
    # so get the vid & veid of the classification name and continue as for vocabulary entries
    if ($cid) {
      my $ss  = qq/SELECT vid, veid FROM classification_db WHERE cid = (?);/;
      my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      $sth->execute($cid);
      $sth->bind_columns(undef, \$vid, \$veid);
      $sth->fetch;
    }

    my $ss  = qq/SELECT entry, isocode FROM vocabulary_entry WHERE vid = (?) AND veid = (?);/;
    my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->execute($vid, $veid);

    my $entry;      # value label (eg 'Wood-engraver')
    my $isocode;    # 2 letter isocode defining language of the entry

    $sth->bind_columns(undef, \$entry, \$isocode);

    while ($sth->fetch) {
      $labels->{$isocode} = $entry;    # this should always contain another language for the same entry
    }
    $sth->finish;
    undef $sth;

    $c->app->chi->set($cachekey, $labels, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");

  }

  return $labels;
}

sub get_study_plans {
  my ($self, $c, $lang) = @_;

  my $res;
  my $cachekey = 'study_plans';
  unless ($res = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $dirres = $c->app->directory->get_study_plans($c, $lang);

    if (exists($dirres->{alerts})) {
      if ($dirres->{status} != 200) {

        # there are only alerts
        return {alerts => $dirres->{alerts}, status => $dirres->{status}};
      }
    }
    else {
      $dirres->{status} = 200;
      $res = $dirres;
    }

    $c->app->chi->set($cachekey, $dirres, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $res;
}

sub license_label {
  my $self = shift;
  my $c    = shift;
  my $lid  = shift;

  my $res = {alerts => [], status => 200};

  my $labels;
  my $cachekey = 'license_' . $lid . '_labels';
  unless ($labels = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $lic_model = PhaidraAPI::Model::Licenses->new;
    my $r         = $lic_model->get_licenses($c);
    if ($r->{status} ne 200) {
      return $r;
    }
    for my $l (@{$r->{licenses}}) {
      if ($l->{lid} eq $lid) {
        $labels = $l->{labels};
      }
    }
    $c->app->chi->set($cachekey, $labels, '1 day');
  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  $res->{labels} = $labels;
  return $res;
}

sub label {
  my $self = shift;
  my $c    = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my $labels;
  my $cachekey = 'labels_' . $uri;
  unless ($labels = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    # stuff like "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A150"
    # or "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_department/A767"
    my $orgns = "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization";
    if ($uri =~ m/$orgns\/voc_(faculty|department)\/(\w+)\/?$/) {
      my $fac_or_dep = $1;
      my $unit_id    = $2;

      # for my $lang (@{$c->app->config->{directory}->{org_units_languages}}) {
      #   my $name = $c->app->directory->get_org_unit_name($c, $unit_id, $lang);
      #   $labels->{$lang} = $name;
      # }

      my $unitres = $c->app->directory->org_get_unit_for_notation($c, $unit_id);
      if ($unitres->{status} == 200) {
        my $unit = $unitres->{unit};
        my $lang_model   = PhaidraAPI::Model::Languages->new;
        my %iso6393ToBCP = reverse %{$lang_model->get_iso639map()};
        for my $lang (keys %{$unit->{'skos:prefLabel'}}) {
          my $alpha2lang = exists($iso6393ToBCP{$lang}) ? $iso6393ToBCP{$lang} : $lang;
          $labels->{$alpha2lang} = $unit->{'skos:prefLabel'}->{$lang};
        }
      } else {
        return $unitres;
      }

    }
    else {

      # other stuff, like "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552253"
      # or "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_1/347"
      my $r = $self->_parse_uri($c, $uri);
      if ($r->{status} != 200) {
        return $r;
      }

      if ($r->{tid}) {
        $labels = $self->_get_taxon_labels($c, $r->{cid}, $r->{tid});
      }
      else {
        $labels = $self->_get_vocab_labels($c, $r->{vid}, $r->{veid}, $r->{cid});
      }

    }

    $c->app->chi->set($cachekey, $labels, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  $res->{labels} = $labels;
  return $res;
}

sub _parse_uri {
  no warnings;
  my $self = shift;
  my $c    = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my $xmlns = '';
  my $vid;
  my $cid;
  my $id;

  #$c->app->log->debug("uri=$uri");
  foreach my $ns (keys %voc_ids) {

    #$c->app->log->debug("xmlns=$ns");

    # keep $ at the end otherwise eg ns
    # http://phaidra.univie.ac.at/XML/metadata/lom/V1.0
    # will be matched even if the sent namespace is
    # http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification
    $uri =~ m/($ns)\/(voc|cls)_(\d+)\/(\w+)\/?$|($ns)\/(voc|cls)_(\d+)\/?$|($ns)\/?$/;

    #$c->app->log->debug("1=$1 2=$2 3=$3 4=$4 5=$5 6=$6 7=$7 8=$8");

    if ($4) {
      $xmlns = $1;
      if ($2 eq 'voc') {
        $vid = $3;
      }
      elsif ($2 eq 'cls') {
        $cid = $3;
      }
      $id = $4;
    }

    if ($7) {
      $xmlns = $5;
      if ($6 eq 'voc') {
        $vid = $7;
      }
      elsif ($6 eq 'cls') {
        $cid = $7;
      }
    }

    if ($8) {
      $xmlns = $8;
    }

    last if $xmlns eq $ns;
  }

  unless ($xmlns) {
    push @{$res->{alerts}}, {type => 'error', msg => 'Cannot parse URI'};
    $res->{status} = 400;
    return $res;
  }

  if ($vid) {
    unless ($vid ~~ $voc_ids{$xmlns}) {
      push @{$res->{alerts}}, {type => 'error', msg => "The specified vocabulary ($vid) is unknown or is not allowed in the specified namespace ($xmlns)"};
      $res->{status} = 400;
      return $res;
    }
  }

  if ($cid) {
    unless ($cid ~~ @cls_ids) {
      push @{$res->{alerts}}, {type => 'error', msg => "Unknown classification ($cid)"};
      $res->{status} = 400;
      return $res;
    }
  }

  if ($cid) {

    # id is vocabulary entry id in case of vocabularies and taxon id in case of classifications
    $res->{cid} = $cid;
    $res->{tid} = $id;
  }
  elsif ($vid) {
    $res->{vid}  = $vid;
    $res->{veid} = $id;
  }

  $res->{xmlns} = $xmlns;

  # $c->app->log->debug("Parsing uri: " . $c->app->dumper($res));

  return $res;
}

sub children {
  my $self = shift;
  my $c    = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my %children;
  my @children;

  my $cachekey = 'children_' . $uri;
  unless ($res = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    $res = {alerts => [], status => 200};

    my $r = $self->_parse_uri($c, $uri);
    if ($r->{status} != 200) {
      return $r;
    }

    if ($r->{xmlns} ne $classification_ns) {
      push @{$res->{alerts}}, {type => 'error', msg => 'Children can only be obtained for a classification.'};
      $res->{status} = 400;
      return $res;
    }

    unless ($r->{cid}) {

      # no classification id specified, return all the classification ids
      my ($cid, $entry, $isocode);
      my $ss  = "SELECT c.cid, ve.entry, ve.isocode FROM classification_db c LEFT JOIN vocabulary_entry ve on c.veid = ve.veid;";
      my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      $sth->execute();
      $sth->bind_columns(undef, \$cid, \$entry, \$isocode);
      my %classes;
      my %isocodes;

      while ($sth->fetch) {
        $classes{$cid}{$isocode} = $entry;
        $isocodes{$isocode} = 1;
      }
      $sth->finish;
      undef $sth;

      # create an array (just as in the metadata tree)
      my @classes;
      foreach my $cid (keys %classes) {
        my %class;
        $class{uri} = "$classification_ns/cls_$cid";
        foreach my $iso (keys %isocodes) {
          $class{labels}{$iso} = $classes{$cid}{$iso};
        }
        push @classes, \%class;
      }

      @classes = sort {$a->{labels}->{en} cmp $b->{labels}->{en}} @classes;
      $res->{terms} = \@classes;

    }
    else {

      # get children
      my ($child_tid, $entry, $isocode, $preferred, $upstream_identifier, $term_id);
      my %isocodes;
      my $ss = "SELECT t.tid, t.upstream_identifier, tv.term_id, ve.entry, ve.isocode, tv.preferred FROM taxon t LEFT JOIN taxon_vocentry tv ON tv.tid = t.tid LEFT JOIN vocabulary_entry ve ON tv.veid = ve.veid WHERE t.cid = (?)";
      if ($r->{tid}) {
        $ss .= "AND t.tid_parent = (?);";
      }
      else {
        $ss .= "AND t.tid_parent IS NULL;";
      }
      my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
      if ($r->{tid}) {
        $sth->execute($r->{cid}, $r->{tid});
      }
      else {
        $sth->execute($r->{cid});
      }
      $sth->bind_columns(undef, \$child_tid, \$upstream_identifier, \$term_id, \$entry, \$isocode, \$preferred);
      while ($sth->fetch) {

        $children{$child_tid}{upstream_identifier} = $upstream_identifier;

        if ($preferred) {
          $children{$child_tid}{preferred}{$isocode} = $entry;
          $children{$child_tid}{preferred}{term_id} = $term_id;
        }
        else {
          $children{$child_tid}{nonpreferred}{$term_id}{$isocode} = $entry;
        }

        $isocodes{$isocode} = 1;
      }
      $sth->finish;
      undef $sth;

      #$c->app->log->debug("ch: ".$c->app->dumper(\%children));

      # create an array (just as in the metadata tree)
      foreach my $tid (keys %children) {
        my %child;
        $child{uri}                 = $r->{xmlns} . '/cls_' . $r->{cid} . '/' . $tid;
        $child{upstream_identifier} = $children{$tid}{upstream_identifier};
        foreach my $iso (keys %isocodes) {
          if ($children{$tid}{preferred}{$iso}) {
            $child{labels}{$iso} = $children{$tid}{preferred}{$iso};
            $child{term_id} = $children{$tid}{preferred}{term_id};
          }
        }
        if ($children{$tid}{nonpreferred}) {
          foreach my $termid (keys %{$children{$tid}{nonpreferred}}) {
            my %ch;
            $ch{term_id} = $termid;
            foreach my $iso (keys %{$children{$tid}{nonpreferred}{$termid}}) {
              $ch{labels}{$iso} = $children{$tid}{nonpreferred}{$termid}{$iso};
            }
            push @{$child{nonpreferred}}, \%ch;
          }
          @{$child{nonpreferred}} = sort {$a->{labels}->{en} cmp $b->{labels}->{en}} @{$child{nonpreferred}};
        }
        push @children, \%child;
      }

      @children = sort {$a->{labels}->{en} cmp $b->{labels}->{en}} @children;

      $res->{terms} = \@children;
    }

    $c->app->chi->set($cachekey, $res, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $res;
}

sub taxonpath_upstreamid {
  my $self       = shift;
  my $c          = shift;
  my $cid        = shift;
  my $upstreamid = shift;

  my $res = {alerts => [], status => 200};

  my $tid;
  my $ss  = qq/SELECT tid FROM taxon WHERE cid = (?) AND upstream_identifier = (?);/;
  my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute($cid, $upstreamid);
  $sth->bind_columns(undef, \$tid);
  $sth->fetch;

  $c->app->log->debug("taxonpath_upstreamid cid[$cid] upstreamid[$upstreamid] tid[$tid]");

  unless ($tid) {
    push @{$res->{alerts}}, {type => 'error', msg => "Cannot find taxonid cid[$cid] upstreamid[$upstreamid] tid[$tid]"};
    $res->{status} = 400;
    return $res;
  }

  my $uri = "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification/cls_$cid/$tid";

  return $self->taxonpath($c, $uri);
}

sub taxonpath {
  my $self = shift;
  my $c    = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my @taxonpath;

  my $cachekey = 'taxonpath_' . $uri;
  unless ($res = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $r = $self->_parse_uri($c, $uri);
    if ($r->{status} != 200) {
      return $r;
    }

    if ($r->{xmlns} ne $classification_ns) {
      push @{$res->{alerts}}, {type => 'error', msg => 'Taxon path can only be obtained for a classification'};
      $res->{status} = 400;
      return $res;
    }

    unless ($r->{cid}) {
      push @{$res->{alerts}}, {type => 'error', msg => 'To get taxon path the uri must specify the classification id'};
      $res->{status} = 400;
      return $res;
    }

    unless ($r->{tid}) {
      push @{$res->{alerts}}, {type => 'error', msg => 'To get taxon path the uri must specify the taxon id'};
      $res->{status} = 400;
      return $res;
    }

    my $labels = $self->_get_taxon_labels($c, $r->{cid}, $r->{tid});
    $labels->{uri} = $uri;
    unshift @taxonpath, $labels;

    my $ptid = $r->{tid};
    my $cnt  = 0;
    while ($ptid) {

      if ($cnt > 50) {

        # nah..
        push @{$res->{alerts}}, {type => 'error', msg => 'Too many cycles'};
        $res->{status} = 500;
        return $res;
      }
      $cnt++;
      $ptid = $self->_get_parent_tid($c, $r->{cid}, $ptid);

      #$c->app->log->debug("ptid: $ptid");
      if ($ptid) {
        my $puri    = $r->{xmlns} . '/cls_' . $r->{cid} . '/' . $ptid;
        my $plabels = $self->_get_taxon_labels($c, $r->{cid}, $ptid);
        $plabels->{uri} = $puri;
        unshift @taxonpath, $plabels;
      }
      else {
        # first time there is no tid it means we reached the root - classification
        # we need to get the data for the 'source' element
        my $curi    = $r->{xmlns} . '/cls_' . $r->{cid};
        my $clabels = $self->_get_vocab_labels($c, undef, undef, $r->{cid});
        unshift @taxonpath, {uri => $curi, labels => $clabels};
      }
    }

    $res->{taxonpath} = \@taxonpath;

    $c->app->chi->set($cachekey, $res, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $res;
}

sub _get_parent_tid {
  my $self = shift;
  my $c    = shift;
  my $cid  = shift;
  my $tid  = shift;

  my $ptid;
  my $ss  = "SELECT TID_parent FROM taxon WHERE cid = (?) AND tid = (?);";
  my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute($cid, $tid);
  $sth->bind_columns(undef, \$ptid);
  $sth->fetch;
  $sth->finish;

  #$c->app->log->debug("parent of $tid is $ptid");
  return $ptid;
}

sub parent {
  my $self = shift;
  my $c    = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my %parent;

  my $cachekey = 'parent_' . $uri;
  unless ($res = $c->app->chi->get($cachekey)) {

    $c->app->log->debug("[cache miss] $cachekey");

    my $r = $self->_parse_uri($c, $uri);
    if ($r->{status} != 200) {
      return $r;
    }

    if ($r->{xmlns} ne $classification_ns) {
      push @{$res->{alerts}}, {type => 'error', msg => 'Parent can only be obtained for a classification.'};
      $res->{status} = 400;
      return $res;
    }

    unless ($r->{cid}) {
      push @{$res->{alerts}}, {type => 'error', msg => 'To get the parent the uri must specify the classification id'};
      $res->{status} = 400;
      return $res;
    }

    unless ($r->{tid}) {
      push @{$res->{alerts}}, {type => 'error', msg => 'To get the parent the uri must specify the taxon id'};
      $res->{status} = 400;
      return $res;
    }

    my $ptid = $self->_get_parent_tid($c, $r->{cid}, $r->{tid});

    $res->{parent} = $r->{xmlns} . '/cls_' . $r->{cid};
    if ($ptid) {
      $res->{parent} .= '/' . $ptid;
    }

    $c->app->chi->set($cachekey, $res, '1 day');

  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  return $res;
}

sub search {

  my $self = shift;
  my $c    = shift;
  my $q    = shift;

  my $res = {alerts => [], status => 200};

  # get a list of all classifications
  my ($cid, $vid, $entry, $isocode);
  my $ss  = "SELECT c.cid, c.vid, ve.entry, ve.isocode FROM classification_db c LEFT JOIN vocabulary_entry ve on c.veid = ve.veid;";
  my $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
  $sth->execute();
  $sth->bind_columns(undef, \$cid, \$vid, \$entry, \$isocode);
  my %classes;
  my %isocodes;

  while ($sth->fetch) {
    $classes{$cid}{$isocode} = $entry;
    $classes{$cid}{vid}      = $vid;
    $isocodes{$isocode}      = 1;
  }
  $sth->finish;

  my @classes;
  foreach my $cid (keys %classes) {

    my %class;
    $class{uri} = "$classification_ns/cls_$cid";
    foreach my $iso (keys %isocodes) {
      $class{labels}{$iso} = $classes{$cid}{$iso};
    }

    # get search results for each classification
    my $limit = $c->app->{config}->{terms}->{search_results_limit};
    my ($veid, $isocode, $entry, $vid, $tid, $upstream_identifier, $term_id, $preferred);

    # we search for vocabulary entries where the query equals the upstream_identifier first, then where it matches the vocabulary entry
    $ss
      = "SELECT ve.veid, ve.isocode, ve.entry, ve.vid, t.tid, t.upstream_identifier, tv.term_id, tv.preferred FROM taxon t LEFT JOIN taxon_vocentry tv ON t.tid = tv.tid LEFT JOIN vocabulary_entry ve on tv.veid = ve.veid WHERE t.upstream_identifier = (?) AND tv.TID IS NOT NULL AND t.cid = (?) UNION SELECT ve.veid, ve.isocode, ve.entry, ve.vid, t.tid, t.upstream_identifier, tv.term_id, tv.preferred FROM vocabulary_entry ve LEFT JOIN taxon_vocentry tv ON ve.veid = tv.veid LEFT JOIN taxon t on tv.tid = t.tid  WHERE MATCH (entry) AGAINST(?) AND tv.TID IS NOT NULL AND t.cid = (?) LIMIT $limit;";
    $sth = $c->app->db_metadata->dbh->prepare($ss) or $c->app->log->error($c->app->db_metadata->dbh->errstr);
    $sth->execute($q, $cid, $q, $cid);
    $sth->bind_columns(undef, \$veid, \$isocode, \$entry, \$vid, \$tid, \$upstream_identifier, \$term_id, \$preferred);
    my %terms;
    my $hits = 0;
    while ($sth->fetch) {
      $hits++;

      #$c->app->log->debug("veid=$veid iso=$isocode entry=$entry vid=$vid tid=$tid upid=$upstream_identifier term=$term_id pref=$preferred");

      $terms{$tid . $term_id}{upstream_identifier} = $upstream_identifier;
      $terms{$tid . $term_id}{preferred}           = $preferred;
      $terms{$tid . $term_id}{term_id}             = $term_id;
      $terms{$tid . $term_id}{labels}{$isocode}    = $entry;
      $terms{$tid . $term_id}{uri}                 = "$classification_ns/cls_$cid/$tid";
      $isocodes{$isocode}                          = 1;
    }

    # make array
    my @terms;
    foreach my $id (keys %terms) {
      push @terms, $terms{$id};
    }

    $class{hits}  = $hits;
    $class{terms} = \@terms;

    push @classes, \%class;
  }
  $sth->finish;
  undef $sth;

  $res->{terms} = \@classes;

  return $res;
}

1;
__END__
