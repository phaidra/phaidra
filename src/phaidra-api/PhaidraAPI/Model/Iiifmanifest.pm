package PhaidraAPI::Model::Iiifmanifest;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;
use JSON;
use Mojo::URL;
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Object;

sub generate_container_manifest {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};
  my $apiBaseUrlPath = $c->app->config->{scheme} . '://' . $c->app->config->{baseurl}. ($c->app->config->{basepath} ? '/' . $c->app->config->{basepath} : '');

  my $index_model   = PhaidraAPI::Model::Index->new;
  my $urlget = $index_model->_get_solrget_url($c, 'Container');
  $urlget->query(q => "ismemberof:\"$pid\" AND cmodel:Picture", rows => "1000", wt => "json", sort => "pos_in_$pid asc");
  my $qr = $c->app->ua->get($urlget)->result;
  unless ($qr->is_success) {
    return {alerts => [{type => 'error', msg => $qr->code . " " . $qr->message}], status => 500};
  }

  my $response = $qr->json->{response};
  if ($response->{numFound} eq 0) {
    return {alerts => [{type => 'error', msg => 'No picture members'}], status => 400};
  }
  
  my $manifest;
  for my $d (@{$response->{docs}}) {
    # get picture dimensions
    my $dims = $self->_get_pic_dimensions($c, $d->{pid});
    return $res if $dims->{status} != 200;

    # create manifest using the first picture as thumbnail
    unless ($manifest) {
      my ($thumb_width, $thumb_height) = $self->_calculate_thumbnail_dimensions($c, $dims->{width}, $dims->{height}, "300", "300");
      $manifest = $self->_create_manifest_root($c, $apiBaseUrlPath, $pid, $d->{pid}, $thumb_width, $thumb_height);
    }

    # add picture to manifest
    push @{$manifest->{items}}, $self->_create_single_canvas_item($apiBaseUrlPath, $d->{pid}, $dims->{width}, $dims->{height}, @{$d->{dc_title}}[0]);
  }

  # update manifest with metadata
  my $r           = $index_model->get_doc($c, $pid);
  return $r if $r->{status} ne 200;
  my $index = $r->{doc};
  $self->_update_manifest_metadata($c, $pid, $index, $manifest);

  $res->{manifest} = $manifest;

  return $res;
}

sub generate_simple_manifest {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $apiBaseUrlPath = $c->app->config->{scheme} . '://' . $c->app->config->{baseurl}. ($c->app->config->{basepath} ? '/' . $c->app->config->{basepath} : '');

  # get dimenstions from info.json
  my $width;
  my $height;
  my $isrv_model = PhaidraAPI::Model::Imageserver->new;
  my $urlres        = $isrv_model->get_url($c, Mojo::Parameters->new("IIIF=$pid.tif/info.json"), 1);
  if ($urlres->{status} ne 200) {
    return $urlres;
  }
  my $getres = $c->app->ua->get($urlres->{url})->result;
  if ($getres->is_success) {
    if ($getres->json->{width}) {
      $width = $getres->json->{width};
    }
    if ($getres->json->{height}) {
      $height = $getres->json->{height};
    }
  } else {
    my $err = "generate_simple_manifest [$pid] error getting iiif info: " . $getres->code . " " . $getres->message;
    $c->app->log->error($err);
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};
    $res->{status} = $getres->code ? $getres->code : 500;
    return $res;
  }
  my $dims = $self->_get_pic_dimensions($c, $pid);
  return $res if $dims->{status} != 200;

  my ($tmb_width, $tmb_height) = $self->_calculate_thumbnail_dimensions($c, $dims->{width}, $dims->{height}, "300", "300");

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get_doc($c, $pid);
  return $r if $r->{status} ne 200;
  my $index = $r->{doc};

  # Check for recto/verso relationships
  my $recto_pid = $pid;
  my $verso_pid = undef;
  my $is_recto_verso = 0;

  # Only consider isbacksideof; ignore hasbackside
  if (exists($index->{isbacksideof}) && scalar(@{$index->{isbacksideof}}) > 0) {
    $is_recto_verso = 1;
    $recto_pid = $index->{isbacksideof}->[0];
    $verso_pid = $pid;
  } else {
    my $rels_res = $index_model->get_relationships($c, $pid);
    if ($rels_res->{status} eq 200 && exists($rels_res->{relationships}->{hasbackside}) && scalar(@{$rels_res->{relationships}->{hasbackside}}) > 0) {
      $is_recto_verso = 1;
      $recto_pid = $pid;
      $verso_pid = $rels_res->{relationships}->{hasbackside}->[0]->{pid};
    }
  }

  my $manifest = $self->_create_manifest_root($c, $apiBaseUrlPath, $pid, $recto_pid, $tmb_width, $tmb_height);

  if ($is_recto_verso && $verso_pid) {
    # Generate multi-canvas manifest for recto/verso
    my $verso_dims = $self->_get_object_dimensions($c, $verso_pid);
    if ($verso_dims->{status} eq 200) {
      # Recto canvas
      push @{$manifest->{items}}, $self->_create_single_canvas_item($apiBaseUrlPath, $recto_pid, $width, $height, "Recto");
      # Verso canvas
      push @{$manifest->{items}}, $self->_create_single_canvas_item($apiBaseUrlPath, $verso_pid, $width, $height, "Verso");
    } else {
      # Fallback to single canvas if verso dimensions can't be retrieved
      push @{$manifest->{items}}, $self->_create_single_canvas_item($apiBaseUrlPath, $pid, $width, $height);
    }
  } else {
    # Single canvas for regular objects
    push @{$manifest->{items}}, $self->_create_single_canvas_item($apiBaseUrlPath, $pid, $width, $height);
  }

  $self->_update_manifest_metadata($c, $pid, $index, $manifest);

  $res->{manifest} = $manifest;

  return $res;
}

sub _get_pic_dimensions {
  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $isrv_model = PhaidraAPI::Model::Imageserver->new;
  my $urlres        = $isrv_model->get_url($c, Mojo::Parameters->new("IIIF=$pid.tif/info.json"), 1);
  if ($urlres->{status} ne 200) {
    return $urlres;
  }
  my $getres = $c->app->ua->get($urlres->{url})->result;
  if ($getres->is_success) {
    $res->{width} = $getres->json->{width};
    $res->{height} = $getres->json->{height};
  } else {
    my $err = "generate_simple_manifest [$pid] error getting iiif info: " . $getres->code . " " . $getres->message;
    $c->app->log->error($err);
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};
    $res->{status} = $getres->code ? $getres->code : 500;
    return $res;
  }

  return $res;
}

sub _create_manifest_root {
  my ($self, $c, $apiBaseUrlPath, $pid, $thumb_pid, $thumb_width, $thumb_height) = @_;

  return {
    "\@context" => "http://iiif.io/api/presentation/3/context.json",
    "id" => "$apiBaseUrlPath/object/$pid/iiifmanifest",
    "type" => "Manifest",
    "label" => {},
    "thumbnail" => [
      {
        "id" => "$apiBaseUrlPath/imageserver?IIIF=$thumb_pid.tif/full/!$thumb_width,$thumb_height/0/default.jpg",
        "type" => "Image",
        "format" => "image/jpeg",
        "height" => $thumb_height,
        "width" => $thumb_width,
        "service" => [
          {
            "id" => "$apiBaseUrlPath/imageserver?IIIF=$thumb_pid.tif",
            "type" => "ImageService2",
            "profile" => "http://iiif.io/api/image/2/level1.json"
          }
        ]
      }
    ],
    "items" => []
  };
}

sub _create_single_canvas_item {
  my ($self, $apiBaseUrlPath, $pid, $width, $height, $label) = @_;

  my $item = {
    "id" => "$apiBaseUrlPath/iiif/$pid/canvas/p1",
    "type" => "Canvas",
    "height" => $height,
    "width" => $width,
    "items" => [{
      "id" => "$apiBaseUrlPath/iiif/$pid/page/p1/1",
      "type" => "AnnotationPage",
      "items" => [{
        "id" => "$apiBaseUrlPath/iiif/$pid/annotation/p0001-image",
        "target" => "$apiBaseUrlPath/iiif/$pid/canvas/p1",
        "type" => "Annotation",
        "motivation" => "painting",
        "body" => {
          "id" => "$apiBaseUrlPath/imageserver?IIIF=$pid.tif/full/full/0/default.jpg",
          "type" => "Image",
          "format" => "image/jpeg",
          "height" => $height,
          "width" => $width,
          "service" => [{
            "id" => "$apiBaseUrlPath/imageserver?IIIF=$pid.tif",
            "type" => "ImageService2",
            "profile" => "http://iiif.io/api/image/2/level1.json"
          }]
        }
      }]
    }]
  };
  
  if ($label) {
    $item->{label} = {"en" => [$label]};
  }
  return $item;
}

sub _get_object_dimensions {
  my ($self, $c, $pid) = @_;

  my $res = {width => 0, height => 0, status => 200};

  my $isrv_model = PhaidraAPI::Model::Imageserver->new;
  my $urlres = $isrv_model->get_url($c, Mojo::Parameters->new("IIIF=$pid.tif/info.json"), 1);
  if ($urlres->{status} ne 200) {
    $res->{status} = $urlres->{status};
    return $res;
  }

  my $getres = $c->app->ua->get($urlres->{url})->result;
  if ($getres->is_success) {
    if ($getres->json->{width}) {
      $res->{width} = $getres->json->{width};
    }
    if ($getres->json->{height}) {
      $res->{height} = $getres->json->{height};
    }
  } else {
    $res->{status} = $getres->code ? $getres->code : 500;
  }

  return $res;
}

sub _calculate_thumbnail_dimensions {
    my ($self, $c, $original_width, $original_height, $max_width, $max_height) = @_;

    # If the original dimensions are already smaller than the bounding box, return them
    if ($original_width <= $max_width && $original_height <= $max_height) {
        return ($original_width, $original_height);
    }

    # Calculate scaling factors for width and height
    my $width_scale  = $max_width / $original_width;
    my $height_scale = $max_height / $original_height;

    # Use the smaller scaling factor to maintain aspect ratio
    my $scale = ($width_scale < $height_scale) ? $width_scale : $height_scale;

    # Calculate the new dimensions
    my $new_width  = int($original_width * $scale);
    my $new_height = int($original_height * $scale);

    return ($new_width, $new_height);
}

sub _update_manifest_metadata {
  my ($self, $c, $pid, $index, $manifest) = @_;

  delete $manifest->{seeAlso};
  delete $manifest->{description};
  delete $manifest->{metadata};
  delete $manifest->{attribution};
  delete $manifest->{requiredStatement};
  delete $manifest->{license};
  delete $manifest->{rights};
  delete $manifest->{label};
  delete $manifest->{summary};
  $manifest->{metadata} = [];

  my @labels;
  if (exists($index->{dc_title_eng})) {
    for my $e (@{$index->{dc_title_eng}}){
      push @labels, $e;
    }
  }
  else {
    push @labels, $index->{sort_dc_title};
  }
  $manifest->{label} = {'en' => \@labels};

  $manifest->{homepage} = [
    { "id"     => 'https://' . $c->app->config->{phaidra}->{baseurl} . '/detail/' . $pid,
      "type"   => "Text",
      "label"  => {"en" => ["Detail page"]},
      "format" => "text/html"
    }
  ];

  push @{$manifest->{metadata}},
    {
    label => {"en"   => ["Identifier"]},
    value => {"none" => ['https://' . $c->app->config->{phaidra}->{baseurl} . '/' . $pid]}
    };

  if (exists($index->{bib_roles_pers_aut})) {
    my $authors = [];
    for my $a (@{$index->{bib_roles_pers_aut}}) {
      push @{$authors}, $a;
    }
    push @{$manifest->{metadata}},
      {
      label => {"en"   => ["Author"]},
      value => {"none" => $authors}
      };
  }

  if (exists($index->{dc_description})) {
    my $descs = [];
    for my $d (@{$index->{dc_description}}) {
      push @{$descs}, $d;
    }
    push @{$manifest->{metadata}},
      {
      label => {"en"   => ["Description"]},
      value => {"none" => $descs}
      };
  }

  if (exists($index->{bib_publisher})) {
    my $pubs = [];
    for my $p (@{$index->{bib_publisher}}) {
      push @{$pubs}, $p;
    }
    push @{$manifest->{metadata}},
      {
      label => {"en"   => ["Publisher"]},
      value => {"none" => $pubs}
      };
  }

  if (exists($index->{bib_published})) {
    my $dateissued = [];
    for my $di (@{$index->{bib_published}}) {
      push @{$dateissued}, $di;
    }
    push @{$manifest->{metadata}},
      {
      label => {"en"   => ["Issued"]},
      value => {"none" => $dateissued}
      };
  }

  if (exists($index->{dc_language})) {
    my $langs = [];
    for my $l (@{$index->{dc_language}}) {
      push @{$langs}, $l;
    }
    push @{$manifest->{metadata}},
      {
      label => {"en"   => ["Language"]},
      value => {"none" => $langs}
      };
  }

  my $statements = [];
  for my $k (keys %{$index}) {
    if ($k =~ m/^dc_([a-z]+)_?([a-z]+)?$/) {
      if ($1 eq 'rights') {
        for my $st (@{$index->{$k}}) {
          push @{$statements}, $st;
        }
      }
    }
  }
  if (scalar $statements > 0) {
    $manifest->{requiredStatement} = {
      label => {"en"   => ["Rights"]},
      value => {"none" => $statements}
    };
  }

}

sub update_manifest_metadata {

  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get_doc($c, $pid);
  return $r if $r->{status} ne 200;
  my $index = $r->{doc};

  # Check if this is a recto/verso relationship
  my $is_recto_verso = 0;
  if (exists($index->{isbacksideof}) && scalar(@{$index->{isbacksideof}}) > 0) {
    $is_recto_verso = 1;
  } else {
    my $rels_res = $index_model->get_relationships($c, $pid);
    if ($rels_res->{status} eq 200 && exists($rels_res->{relationships}->{hasbackside}) && scalar(@{$rels_res->{relationships}->{hasbackside}}) > 0) {
      $is_recto_verso = 1;
    }
  }
  
  if ($is_recto_verso) {
    # Regenerate the entire manifest for recto/verso objects
    my $new_manifest_res = $self->generate_simple_manifest($c, $pid);
    if ($new_manifest_res->{status} ne 200) {
      return $new_manifest_res;
    }
    
    my $object_model = PhaidraAPI::Model::Object->new;
    my $json = JSON->new->utf8->pretty->encode($new_manifest_res->{manifest});
    return $object_model->add_or_modify_datastream($c, $pid, "IIIF-MANIFEST", "application/json", undef, $c->app->config->{phaidra}->{defaultlabel}, $json, "M", undef, undef, $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password}, 0, 0);
  } else {
    # Update existing manifest metadata for single canvas objects
    my $object_model = PhaidraAPI::Model::Object->new;
    $r = $object_model->get_datastream($c, $pid, 'IIIF-MANIFEST', $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password});
    if ($r->{status} ne 200) {
      return $r;
    }

    my $manifest = decode_json($r->{'IIIF-MANIFEST'});

    $self->_update_manifest_metadata($c, $pid, $index, $manifest);

    my $json = JSON->new->utf8->pretty->encode($manifest);
    return $object_model->add_or_modify_datastream($c, $pid, "IIIF-MANIFEST", "application/json", undef, $c->app->config->{phaidra}->{defaultlabel}, $json, "M", undef, undef, $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password}, 0, 0);
  }
}

sub get_updated_manifest {

  my ($self, $c, $pid) = @_;

  my $res = {alerts => [], status => 200};

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get_doc($c, $pid);
  return $r if $r->{status} ne 200;
  my $index = $r->{doc};

  my $is_recto_verso = 0;
  if (exists($index->{isbacksideof}) && scalar(@{$index->{isbacksideof}}) > 0) {
    $is_recto_verso = 1;
  } else {
    my $rels_res = $index_model->get_relationships($c, $pid);
    if ($rels_res->{status} eq 200 && exists($rels_res->{relationships}->{hasbackside}) && scalar(@{$rels_res->{relationships}->{hasbackside}}) > 0) {
      $is_recto_verso = 1;
    }
  }

  if ($is_recto_verso) {
    my $new_manifest_res = $self->generate_simple_manifest($c, $pid);
    return $new_manifest_res;
  } else {
    my $object_model = PhaidraAPI::Model::Object->new;
    $r = $object_model->get_datastream($c, $pid, 'IIIF-MANIFEST', $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password});
    if ($r->{status} ne 200) {
      return $r;
    }

    my $manifest = decode_json($r->{'IIIF-MANIFEST'});

    $self->_update_manifest_metadata($c, $pid, $index, $manifest);

    $self->_replace_instance_urls($c, $manifest);

    $res->{manifest} = $manifest;
    return $res;
  }
}

sub _replace_instance_urls {
  my ($self, $c, $data) = @_;

  my $current_base_url = $c->app->config->{scheme} . '://' . $c->app->config->{baseurl};
  
  my @api_patterns = qw(/object/ /imageserver /iiif/ /search/);
  
  if (ref($data) eq 'HASH') {
    for my $key (keys %{$data}) {
      if (ref($data->{$key}) eq 'HASH' || ref($data->{$key}) eq 'ARRAY') {
        $self->_replace_instance_urls($c, $data->{$key});
      } elsif (ref($data->{$key}) eq '') {
        my $value = $data->{$key};
        # Skip IIIF API context and related URLs that point to iiif.io
        next if defined($value) && $value =~ m{^https?://iiif\.io/}i;

        if (defined($value) && $value =~ /^https?:\/\//) {
          for my $pattern (@api_patterns) {
            if ($value =~ /$pattern/) {
              eval {
                my $url = Mojo::URL->new($value);
                my $path_query = $url->path;
                $path_query .= '?' . $url->query->to_string if $url->query->to_string;
                $data->{$key} = $current_base_url . $path_query;
              };
              if ($@) {
                if ($value =~ /^https?:\/\/[^\/]+(\/.*)$/) {
                  my $path = $1;
                  $data->{$key} = $current_base_url . $path;
                }
              }
              last;
            }
          }
        }
      }
    }
  } elsif (ref($data) eq 'ARRAY') {
    for my $i (0 .. $#{$data}) {
      my $item = $data->[$i];
      if (ref($item) eq 'HASH' || ref($item) eq 'ARRAY') {
        $self->_replace_instance_urls($c, $item);
      } elsif (ref($item) eq '') {
        # Skip IIIF API context and related URLs that point to iiif.io
        next if defined($item) && $item =~ m{^https?://iiif\.io/}i;

        if (defined($item) && $item =~ /^https?:\/\//) {
          for my $pattern (@api_patterns) {
            if ($item =~ /$pattern/) {
              eval {
                my $url = Mojo::URL->new($item);
                my $path_query = $url->path;
                $path_query .= '?' . $url->query->to_string if $url->query->to_string;
                $data->[$i] = $current_base_url . $path_query;
              };
              if ($@) {
                if ($item =~ /^https?:\/\/[^\/]+(\/.*)$/) {
                  my $path = $1;
                  $data->[$i] = $current_base_url . $path;
                }
              }
              last;
            }
          }
        }
      }
    }
  }
}

sub save_to_object {
  my ($self, $c, $pid, $manifest, $username, $password, $skiphook) = @_;

  my $json         = JSON->new->utf8->pretty->encode($manifest);
  my $object_model = PhaidraAPI::Model::Object->new;
  return $object_model->add_or_modify_datastream($c, $pid, "IIIF-MANIFEST", "application/json", undef, $c->app->config->{phaidra}->{defaultlabel}, $json, "M", undef, undef, $username, $password, 0, $skiphook);
}

1;
__END__
