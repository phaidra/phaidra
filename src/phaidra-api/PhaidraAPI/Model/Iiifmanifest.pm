package PhaidraAPI::Model::Iiifmanifest;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;
use JSON;
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Object;

sub generate_simple_manifest {
  my ($self, $c, $pid) = @_;

  my $res = {manifest => {}, alerts => [], status => 200};

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

  my ($tmb_width, $tmb_height) = $self->calculate_thumbnail_dimensions($c, $width, $height, "300", "300");

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($c, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }
  my $index = $r->{index};

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

  my $manifest = {
    "\@context" => "http://iiif.io/api/presentation/3/context.json",
    "id" => "$apiBaseUrlPath/object/$pid/iiifmanifest",
    "type" => "Manifest",
    "label" => {},
    "thumbnail" => [
      {
        "id" => "$apiBaseUrlPath/imageserver?IIIF=$recto_pid.tif/full/!$tmb_width,$tmb_height/0/default.jpg",
        "type" => "Image",
        "format" => "image/jpeg",
        "height" => $tmb_height,
        "width" => $tmb_width,
        "service" => [
          {
            "id" => "$apiBaseUrlPath/imageserver?IIIF=$recto_pid.tif",
            "type" => "ImageService2",
            "profile" => "http://iiif.io/api/image/2/level1.json"
          }
        ]
      }
    ],
    "items" => []
  };

  if ($is_recto_verso && $verso_pid) {
    # Generate multi-canvas manifest for recto/verso
    my $verso_dims = $self->_get_object_dimensions($c, $verso_pid);
    if ($verso_dims->{status} eq 200) {
      # Recto canvas
      push @{$manifest->{items}}, {
        "id" => "$apiBaseUrlPath/iiif/$recto_pid/canvas/recto",
        "type" => "Canvas",
        "height" => $height,
        "width" => $width,
        "label" => {"en" => ["Recto"]},
        "items" => [{
          "id" => "$apiBaseUrlPath/iiif/$recto_pid/page/recto/1",
          "type" => "AnnotationPage",
          "items" => [{
            "id" => "$apiBaseUrlPath/iiif/$recto_pid/annotation/recto-image",
            "target" => "$apiBaseUrlPath/iiif/$recto_pid/canvas/recto",
            "type" => "Annotation",
            "motivation" => "painting",
            "body" => {
              "id" => "$apiBaseUrlPath/imageserver?IIIF=$recto_pid.tif/full/full/0/default.jpg",
              "type" => "Image",
              "format" => "image/jpeg",
              "height" => $height,
              "width" => $width,
              "service" => [{
                "id" => "$apiBaseUrlPath/imageserver?IIIF=$recto_pid.tif",
                "type" => "ImageService2",
                "profile" => "http://iiif.io/api/image/2/level1.json"
              }]
            }
          }]
        }]
      };
      
      # Verso canvas
      push @{$manifest->{items}}, {
        "id" => "$apiBaseUrlPath/iiif/$verso_pid/canvas/verso",
        "type" => "Canvas",
        "height" => $verso_dims->{height},
        "width" => $verso_dims->{width},
        "label" => {"en" => ["Verso"]},
        "items" => [{
          "id" => "$apiBaseUrlPath/iiif/$verso_pid/page/verso/1",
          "type" => "AnnotationPage",
          "items" => [{
            "id" => "$apiBaseUrlPath/iiif/$verso_pid/annotation/verso-image",
            "target" => "$apiBaseUrlPath/iiif/$verso_pid/canvas/verso",
            "type" => "Annotation",
            "motivation" => "painting",
            "body" => {
              "id" => "$apiBaseUrlPath/imageserver?IIIF=$verso_pid.tif/full/full/0/default.jpg",
              "type" => "Image",
              "format" => "image/jpeg",
              "height" => $verso_dims->{height},
              "width" => $verso_dims->{width},
              "service" => [{
                "id" => "$apiBaseUrlPath/imageserver?IIIF=$verso_pid.tif",
                "type" => "ImageService2",
                "profile" => "http://iiif.io/api/image/2/level1.json"
              }]
            }
          }]
        }]
      };
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

sub _create_single_canvas_item {
  my ($self, $apiBaseUrlPath, $pid, $width, $height) = @_;
  
  return {
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

sub calculate_thumbnail_dimensions {
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
  my $r           = $index_model->get($c, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }
  my $index = $r->{index};

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
  my $r           = $index_model->get($c, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }
  my $index = $r->{index};

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

    $res->{manifest} = $manifest;
    return $res;
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
