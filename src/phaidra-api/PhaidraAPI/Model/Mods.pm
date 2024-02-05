package PhaidraAPI::Model::Mods;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Storable qw(dclone);
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(html_unescape);
use Mojo::File;
use POSIX qw/strftime/;
use XML::Writer;
use XML::LibXML;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Languages;
use PhaidraAPI::Model::Util;

our $modsns = "http://www.loc.gov/mods/v3";

sub metadata_tree {

  my ($self, $c, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  if ($nocache) {
    $c->app->log->debug("Reading mods tree from file (nocache request)");

    # read metadata tree from file
    my $path  = Mojo::File->new($c->app->config->{local_mods_tree});
    my $bytes = $path->slurp;
    unless (defined($bytes)) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error reading local_mods_tree, no content"};
      $res->{status} = 500;
      return $res;
    }
    my $metadata = decode_json($bytes);

    $res->{mods}                 = $metadata->{mods};
    $res->{vocabularies}         = $metadata->{vocabularies};
    $res->{vocabularies_mapping} = $metadata->{vocabularies_mapping};

  }
  else {

    $c->app->log->debug("Reading mods tree from cache");

    my $cachekey = 'mods_tree';
    my $cacheval = $c->app->chi->get($cachekey);

    my $miss = 1;

    #$c->app->log->debug($c->app->dumper($cacheval));
    if ($cacheval) {
      if (scalar @{$cacheval->{mods}} > 0) {
        $miss = 0;

        #$c->app->log->debug("[cache hit] $cachekey");
      }
    }

    if ($miss) {
      $c->app->log->debug("[cache miss] $cachekey");

      # read metadata tree from file
      my $path  = Mojo::File->new($c->app->config->{local_mods_tree});
      my $bytes = $path->slurp;
      unless (defined($bytes)) {
        push @{$res->{alerts}}, {type => 'error', msg => "Error reading local_mods_tree, no content"};
        $res->{status} = 500;
        return $res;
      }
      $cacheval = decode_json($bytes);

      $c->app->chi->set($cachekey, $cacheval, '1 day');

      # save and get the value. the serialization can change integers to strings so
      # if we want to get the same structure for cache miss and cache hit we have to run it through
      # the cache serialization process even if cache miss [when we already have the structure]
      # so instead of using the structure created we will get the one just saved from cache.
      $cacheval = $c->app->chi->get($cachekey);

      #$c->app->log->debug($c->app->dumper($cacheval));
    }
    $res->{mods}                 = $cacheval->{mods};
    $res->{vocabularies}         = $cacheval->{vocabularies};
    $res->{vocabularies_mapping} = $cacheval->{vocabularies_mapping};
  }

  return $res;
}

sub xml_2_json {
  my ($self, $c, $xml, $mode) = @_;

  my $res = {alerts => [], status => 200};

  my $dom;
  if (ref $xml eq 'Mojo::DOM') {
    $dom = $xml;
  }
  else {
    $dom = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($xml);
  }

  my %json;
  $self->xml_2_json_rec($c, \%json, $dom->children);

  #$c->app->log->debug("XXXXXXXXXXXXXXXXXXXX ".$c->app->dumper(\%json));
  my $mods;
  foreach my $ch (@{$json{children}}) {
    if ($ch->{xmlname} eq 'mods') {
      $mods = $ch->{children};
    }
  }

  if (defined($mode) && $mode eq 'full') {
    $res = $self->mods_fill_tree($c, $mods);
  }
  else {

    # add stuff as attributes, labels etc to the children
    my $r         = $self->metadata_tree($c);
    my $mods_tree = $r->{mods};
    my %mods_nodes_hash;
    $self->create_mods_nodes_hash($c, $mods_tree, \%mods_nodes_hash, '');

    foreach my $n (@{$mods}) {
      if (defined($mode) && $mode eq 'basic') {
        $self->add_properties_rec($c, '', $n, \%mods_nodes_hash, 0);
      }
      else {
        $self->add_properties_rec($c, '', $n, \%mods_nodes_hash, 1);
      }
    }

    $res->{mods} = $mods;
  }

  #$c->app->log->debug("XXXXXXXXXXXXXXXXXXXX ".$c->app->dumper($res));
  return $res;
}

sub xml_2_json_rec {

  my ($self, $c, $parent, $xml_children) = @_;

  for my $e ($xml_children->each) {

    my $type = $e->tag;

    my $ns;
    my $id;
    my $node;

    if ($type =~ m/(\w+):(\w+)/) {
      $ns = $1;
      $id = $2;
    }
    else {
      $id = $type;
    }

    #$c->app->log->debug("XXXXX type [$type] ns [$ns] id [$id]");
    $node->{xmlname} = $id;
    if (defined($e->text) && $e->text ne '') {
      $node->{ui_value} = $e->text;
    }

    if (defined($e->attr)) {
      foreach my $ak (keys %{$e->attr}) {
        my $a = {
          xmlname  => $ak,
          ui_value => $e->attr->{$ak}
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

sub json_2_xml {

  my ($self, $c, $json) = @_;

  my $prefixmap           = {$modsns => 'mods'};
  my $forced_declarations = [$modsns];

  my $xml    = '';
  my $writer = XML::Writer->new(
    OUTPUT          => \$xml,
    NAMESPACES      => 1,
    PREFIX_MAP      => $prefixmap,
    FORCED_NS_DECLS => $forced_declarations,
    DATA_MODE       => 1,
    ENCODING        => 'utf-8'
  );

  $writer->startTag([$modsns, "mods"]);
  $self->json_2_xml_rec($c, undef, $json, $writer);
  $writer->endTag([$modsns, "mods"]);

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

    if ((!defined($child->{ui_value}) || ($child->{ui_value} eq '')) && $children_size == 0 && $attributes_size == 0) {
      next;
    }

    if (defined($child->{attributes}) && (scalar @{$child->{attributes}} > 0)) {
      my %attrs;
      for my $a (@{$child->{attributes}}) {
        if (defined($a->{ui_value}) && $a->{ui_value} ne '') {
          if ($a->{xmlname} eq 'lang') {
            $attrs{['http://www.w3.org/XML/1998/namespace', 'lang']} = $a->{ui_value};
          }
          else {
            $attrs{$a->{xmlname}} = $a->{ui_value};
          }
        }
      }
      $writer->startTag([$modsns, $child->{xmlname}], %attrs);
    }
    else {
      $writer->startTag([$modsns, $child->{xmlname}]);
    }

    if ($children_size > 0) {
      $self->json_2_xml_rec($c, $child, $child->{children}, $writer);
    }
    else {
      if (!defined($child->{value}) || $child->{value} eq '') {
        $child->{value} = $child->{ui_value};
      }
      $writer->characters($child->{value});
    }
    $writer->endTag([$modsns, $child->{xmlname}]);
  }
}

sub validate_mods() {

  my $self = shift;
  my $c    = shift;
  my $mods = shift;

  my $res = {alerts => [], status => 200};

  my $xsdpath = $c->app->config->{validate_mods};

  unless (-f $xsdpath) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Cannot find XSD files: $xsdpath"};
    $res->{status} = 500;
  }

  my $schema = XML::LibXML::Schema->new(location => $xsdpath);
  my $parser = XML::LibXML->new;

  eval {
    my $document = $parser->parse_string($mods);

    $c->app->log->debug("Validating: " . $document->toString(1));

    $schema->validate($document);
  };

  if ($@) {
    $c->app->log->error("Error validating MODS: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
  }

  return $res;
}

sub handle_system_metadata() {
  my $self     = shift;
  my $c        = shift;
  my $pid      = shift;
  my $metadata = shift;

  # TODO: add upload date to record info
  my $created_date = strftime("%Y-%m-%dT%H:%M:%S.000Z", localtime);
  my $changed_date = strftime("%Y-%m-%dT%H:%M:%S.000Z", localtime);

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

  # fix
  $self->handle_system_metadata($c, $pid, $metadata);

  # compress
  $metadata = $self->mods_strip_empty_nodes($c, $metadata);

  # convert
  my $mods = $self->json_2_xml($c, $metadata);

  unless ($mods) {
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error converting MODS metadata'};
    return $res;
  }

  # validate
  if ($c->app->config->{validate_mods}) {
    my $util_model = PhaidraAPI::Model::Util->new;
    my $valres     = $util_model->validate_xml($c, $mods, $c->app->config->{validate_mods});
    if ($valres->{status} != 200) {
      $res->{status} = $valres->{status};
      foreach my $a (@{$valres->{alerts}}) {
        unshift @{$res->{alerts}}, $a;
      }
      return $res;
    }
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  return $object_model->add_or_modify_datastream($c, $pid, "MODS", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $mods, "X", undef, undef, $username, $password, 0, $skiphook);

}

sub mods_fill_tree {
  my $self = shift;
  my $c    = shift;

  # what was saved in db
  my $mods = shift;

  my $res = {alerts => [], status => 200};

  my $r = $self->metadata_tree($c);

  # what we are filling with the saved values; this is what we return to frontend
  my $tree = $r->{mods};

  my %mods_nodes_hash;
  my $tree_copy = dclone($tree);

  $self->create_mods_nodes_hash($c, $tree_copy, \%mods_nodes_hash, '');

  # remove the relatedItem node from the empty tree
  $self->remove_relatedItem_node($c, $tree);

  $self->mods_fill_tree_rec($c, $mods, $tree, \%mods_nodes_hash, '');

  $self->unset_used_node_flag($c, $tree);

  $res->{mods}                 = $tree;
  $res->{vocabularies}         = $r->{vocabularies};
  $res->{vocabularies_mapping} = $r->{vocabularies_mapping};
  my $languages_model = PhaidraAPI::Model::Languages->new;
  my $lres            = $languages_model->get_languages($c);
  if ($lres->{status} ne 200) {
    return $lres;
  }

  $res->{languages} = $lres->{languages};

  return $res;

}

sub remove_relatedItem_node {
  my $self = shift;
  my $c    = shift;
  my $tree = shift;

  my $i = 0;
  for (my $i = @{$tree}; $i--;) {
    splice @{$tree}, $i, 1 if @{$tree}[$i]->{xmlname} eq 'relatedItem';
  }
}

sub mods_fill_tree_rec {
  my $self            = shift;
  my $c               = shift;
  my $read_children   = shift;
  my $mods_tree       = shift;
  my $mods_nodes_hash = shift;
  my $path            = shift;

  my $i = 0;
  foreach my $n (@{$read_children}) {

    my $child_path = ($path eq '' ? '' : $path . '_') . $n->{xmlname};

    $i++;

    if ($n->{xmlname} eq 'relatedItem') {

      my $relitem_node = dclone($mods_nodes_hash->{'relatedItem'});

      # copy attributes
      foreach my $n_a (@{$n->{attributes}}) {
        if (defined($n_a->{ui_value}) && $n_a->{ui_value} ne '') {
          foreach my $c_a (@{$relitem_node->{attributes}}) {
            if ($n_a->{xmlname} eq $c_a->{xmlname}) {
              $c_a->{ui_value} = $n_a->{ui_value};
            }
          }
        }
      }

      # copy children
      $relitem_node->{children} = $n->{children};

      # add stuff as attributes, labels etc to the children
      foreach my $ch (@{$relitem_node->{children}}) {
        $self->add_properties_rec($c, '', $ch, $mods_nodes_hash, 1);
      }

      splice @{$mods_tree}, $i, 0, $relitem_node;

    }
    else {
      # this gives as an empty node to fill (it adds new one if needed)
      # it also keeps recursion in $mods/$children, which we read, in sync with $mods_tree, which we are writing to
      my $current_mods_tree_node = $self->mods_get_empty_tree_node($c, $child_path, $mods_tree, '', $mods_nodes_hash);

      unless ($current_mods_tree_node->{xmlname}) {
        $c->app->log->error("ERROR, no node found for path $child_path (" . $current_mods_tree_node->{xmlname} . "):" . $current_mods_tree_node->{input_type} . "\n" . $c->app->dumper($n));
      }

      if (defined($n->{ui_value}) && $n->{ui_value} ne '') {
        $current_mods_tree_node->{ui_value} = $n->{ui_value};
      }

      # copy attribute values
      foreach my $n_a (@{$n->{attributes}}) {
        if (defined($n_a->{ui_value}) && $n_a->{ui_value} ne '') {
          foreach my $c_a (@{$current_mods_tree_node->{attributes}}) {
            if ($n_a->{xmlname} eq $c_a->{xmlname}) {
              $c_a->{ui_value} = $n_a->{ui_value};
            }
          }
        }
      }

      my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
      if ($children_size > 0) {
        $self->mods_fill_tree_rec($c, $n->{children}, $mods_tree, $mods_nodes_hash, $child_path);
      }

      if ($current_mods_tree_node->{input_type} eq 'node') {
        $current_mods_tree_node->{used_node} = 1;
      }
    }

  }

}

sub add_properties_rec {
  my $self            = shift;
  my $c               = shift;
  my $path            = shift;
  my $node            = shift;
  my $mods_nodes_hash = shift;
  my $add_empty       = shift;

  my $child_path;
  if ($path eq 'relatedItem') {
    $child_path = $node->{xmlname};
  }
  else {
    $child_path = ($path eq '' ? '' : $path . '_') . $node->{xmlname};
  }

  # $c->app->log->debug("XXXXXXXXX searching p [$path] chp [$child_path]");
  return unless exists $mods_nodes_hash->{$child_path};
  my $ref_node = dclone($mods_nodes_hash->{$child_path});

  foreach my $k (keys %$ref_node) {
    if ($k ne 'attributes' && $k ne 'children' && $k ne 'ui_value') {
      $node->{$k} = $ref_node->{$k};
    }
  }

  # copy attributes	from ref_node to node
  foreach my $r_a (@{$ref_node->{attributes}}) {

    my $found = 0;
    if (exists($node->{attributes})) {
      foreach my $n_a (@{$node->{attributes}}) {
        if ($n_a->{xmlname} eq $r_a->{xmlname}) {
          foreach my $k (keys %$r_a) {
            if ($k ne 'attributes' && $k ne 'children' && $k ne 'ui_value') {
              $n_a->{$k} = $r_a->{$k};
            }
          }
          $found = 1;
        }
      }
    }

    if ($add_empty && !$found) {
      push @{$node->{attributes}}, $r_a;
    }

  }

  if (exists($node->{children})) {
    foreach my $n (@{$node->{children}}) {
      $self->add_properties_rec($c, $child_path, $n, $mods_nodes_hash, $add_empty);
    }
  }

}

sub create_mods_nodes_hash {

  my $self        = shift;
  my $c           = shift;
  my $children    = shift;
  my $h           = shift;
  my $parent_path = shift;

  foreach my $n (@{$children}) {

    my $path = ($parent_path eq '' ? '' : $parent_path . '_') . $n->{xmlname};

    $h->{$path} = $n;

    my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
    if ($children_size > 0) {
      $self->create_mods_nodes_hash($c, $n->{children}, $h, $path);
    }

  }

}

sub unset_used_node_flag {

  my $self     = shift;
  my $c        = shift;
  my $children = shift;

  foreach my $n (@{$children}) {

    delete $n->{used_node} if exists $n->{used_node};

    my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
    if ($children_size > 0) {
      $self->unset_used_node_flag($c, $n->{children});
    }
  }
}

sub mods_get_empty_tree_node {
  my ($self, $c, $search_path, $mods_tree, $mods_tree_path, $mods_nodes_hash) = @_;

  my $node;
  my $i = 0;

  foreach my $n (@{$mods_tree}) {
    my $children_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
    my $curr_path     = ($mods_tree_path eq '' ? '' : $mods_tree_path . '_') . $n->{xmlname};
    if ($curr_path eq $search_path) {

      # we have found the node we are searching for, is it empty?
      if ((defined($n->{ui_value}) && $n->{ui_value} ne '') || $n->{used_node}) {

        # it's not, add new node
        my $new_node = dclone($mods_nodes_hash->{$search_path});
        splice @{$mods_tree}, $i, 0, $new_node;

        $node = $new_node;
      }
      else {
        $node = $n;
      }

    }
    elsif ($children_size > 0) {
      $node = $self->mods_get_empty_tree_node($c, $search_path, $n->{children}, $curr_path, $mods_nodes_hash);
    }

    $i++;

    last if defined $node;
  }
  return $node;
}

sub mods_strip_empty_nodes {
  my $self     = shift;
  my $c        = shift;
  my $children = shift;

  for my $i (0 .. $#$children) {

    my $node = @{$children}[$i];

    # remove children if there are no values in the subtree
    my $children_size = defined($node->{children}) ? scalar(@{$node->{children}}) : 0;
    if ($children_size > 0) {
      $self->mods_strip_empty_nodes($c, $node->{children});
      my $children_size2 = defined($node->{children}) ? scalar(@{$node->{children}}) : 0;
      if ($children_size2 == 0) {
        delete $node->{children};
      }
    }
    else {
      if (exists($node->{children})) {
        delete $node->{children};
      }
    }

    # remove empty attributes
    my $a = $node->{attributes};
    for my $j (0 .. $#$a) {
      if (!defined(@{$a}[$j]->{ui_value}) || @{$a}[$j]->{ui_value} eq '') {
        undef @{$a}[$j];
      }
    }
    @{$a} = grep {defined} @{$a};
    if (scalar @{$a} > 0) {
      $node->{attributes} = $a;
    }
    else {
      delete $node->{attributes};
    }

    if (!exists($node->{children}) && !exists($node->{attributes}) && (!defined($node->{ui_value}) || $node->{ui_value} eq '')) {

      # delete the node itself
      undef @{$children}[$i];
    }

  }

  # remove undefined nodes
  @{$children} = grep {defined} @{$children};

  return $children;
}

sub get_object_mods_json {

  my ($self, $c, $pid, $mode, $username, $password) = @_;

  # FIXME:
  # HACK: remove the intcall auth and make it an Asset's disseminator
  my $object_model = PhaidraAPI::Model::Object->new;
  my $res          = $object_model->get_datastream($c, $pid, 'MODS', $username, $password, 1);
  if ($res->{status} ne 200) {
    return $res;
  }
  my $mods = b($res->{MODS})->decode('UTF-8');
  return $self->xml_2_json($c, $mods, $mode);
}

1;
__END__
