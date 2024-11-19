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

  my $manifest = {
    "\@context" => "http://iiif.io/api/presentation/3/context.json",
    "\@id" => "$apiBaseUrlPath/object/$pid/iiifmanifest",
    "type" => "Manifest",
    "label" => {},
    "items" => [
      {
        "id" => "$apiBaseUrlPath/iiif/$pid/canvas/p1",
        "type" => "Canvas",
        "height" => $height,
        "width" => $width,
        "items" => [
          {
            "id" => "$apiBaseUrlPath/iiif/$pid/page/p1/1",
            "type" => "AnnotationPage",
            "target" => "$apiBaseUrlPath/iiif/$pid/canvas/p1",
            "items" => [
              {
                "id" => "$apiBaseUrlPath/iiif/$pid/annotation/p0001-image",
                "type" => "Annotation",
                "motivation" => "painting",
                "body" => {
                  "id" => "$apiBaseUrlPath/imageserver?IIIF=$pid.tif/full/full/0/default.jpg",
                  "type" => "Image",
                  "format" => "image/jpg",
                  "height" => $height,
                  "width" => $width
                }
              }
            ]
          }
        ]
      }
    ]
  };

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($c, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }
  my $index = $r->{index};

  $self->_update_manifest_metadata($c, $pid, $index, $manifest);

  $res->{manifest} = $manifest;

  return $res;
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
    push @labels, $index->{dc_title_eng};
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

  # $c->app->log->debug("XXXXXXXXXXXXXXXXXXXXXXXXXXXX" . $c->app->dumper($index));

  my $object_model = PhaidraAPI::Model::Object->new;
  $r = $object_model->get_datastream($c, $pid, 'IIIF-MANIFEST', $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password});
  if ($r->{status} ne 200) {
    return $r;
  }

  my $manifest = decode_json($r->{'IIIF-MANIFEST'});

  $self->_update_manifest_metadata($c, $pid, $index, $manifest);

  # $c->app->log->debug("XXXXXXXXXXXXXXXXXXXX " . $c->app->dumper($manifest));

  my $json = JSON->new->utf8->pretty->encode($manifest);
  return $object_model->add_or_modify_datastream($c, $pid, "IIIF-MANIFEST", "application/json", undef, $c->app->config->{phaidra}->{defaultlabel}, $json, "M", undef, undef, $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password}, 0, 0);
}

sub save_to_object {
  my ($self, $c, $pid, $manifest, $username, $password, $skiphook) = @_;

  my $json         = JSON->new->utf8->pretty->encode($manifest);
  my $object_model = PhaidraAPI::Model::Object->new;
  return $object_model->add_or_modify_datastream($c, $pid, "IIIF-MANIFEST", "application/json", undef, $c->app->config->{phaidra}->{defaultlabel}, $json, "M", undef, undef, $username, $password, 0, $skiphook);
}

1;
__END__
