package PhaidraAPI::Controller::Mods;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Mods;
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Languages;
use PhaidraAPI::Model::Licenses;
use PhaidraAPI::Model::Object;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Time::HiRes qw/tv_interval gettimeofday/;

sub get {
  my $self = shift;

  #my $t0 = [gettimeofday];

  my $pid    = $self->stash('pid');
  my $mode   = $self->param('mode');
  my $vocs   = $self->param('vocs');
  my $format = $self->param('format');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  if ($format eq 'xml') {
    my $object_model = PhaidraAPI::Model::Object->new;

    # return XML directly
    $object_model->proxy_datastream($self, $pid, 'MODS', undef, undef, 1);
    return;
  }

  my $mods_model = PhaidraAPI::Model::Mods->new;
  my $res        = $mods_model->get_object_mods_json($self, $pid, $mode, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    if ($res->{status} eq 404) {

      # no MODS
      $self->render(json => {alerts => $res->{alerts}, mods => {}}, status => $res->{status});
    }
    $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
    return;
  }

  if ($vocs) {
    my $lang_model = PhaidraAPI::Model::Languages->new;
    my $lres       = $lang_model->get_languages($self);
    if ($lres->{status} ne 200) {
      $self->render(json => {alerts => $lres->{alerts}}, $lres->{status});
      return;
    }

    my $vres = $mods_model->metadata_tree($self);
    if ($vres->{status} ne 200) {
      $self->render(json => {alerts => $vres->{alerts}}, $vres->{status});
      return;
    }

    $self->render(json => {metadata => {mods => $res->{mods}, languages => $lres->{languages}, vocabularies => $vres->{vocabularies}, vocabularies_mapping => $vres->{vocabularies_mapping}}}, status => $res->{status});
  }
  else {
    $self->render(json => {metadata => $res}, status => $res->{status});
  }
}

sub tree {
  my $self = shift;

  my $t0 = [gettimeofday];

  my $nocache = $self->param('nocache');

  my $mods_model = PhaidraAPI::Model::Mods->new;
  my $lang_model = PhaidraAPI::Model::Languages->new;

  my $lres = $lang_model->get_languages($self);
  if ($lres->{status} ne 200) {
    $self->render(json => {alerts => $lres->{alerts}}, $lres->{status});
    return;
  }
  my $languages = $lres->{languages};

  my $res = $mods_model->metadata_tree($self, $nocache);
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, $res->{status});
    return;
  }

  my $t1 = tv_interval($t0);
  $self->stash(msg => "backend load took $t1 s");

  $self->render(json => {tree => $res->{mods}, vocabularies => $res->{vocabularies}, 'vocabularies_mapping' => $res->{vocabularies_mapping}, languages => $languages, alerts => $res->{alerts}}, status => $res->{status});
}

sub json2xml {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};

  my $metadata_model = PhaidraAPI::Model::Mods->new;
  my $modsxml        = $metadata_model->json_2_xml($self, $metadata->{mods});

  $self->render(json => {alerts => $res->{alerts}, metadata => {mods => $modsxml}}, status => $res->{status});
}

sub xml2json {
  my $self = shift;

  my $mode = $self->param('mode');
  my $xml  = $self->req->body;

  my $mods = b($xml)->decode('UTF-8');

  my $mods_model = PhaidraAPI::Model::Mods->new;
  my $res        = $mods_model->xml_2_json($self, $mods, $mode);

  $self->render(json => {metadata => {mods => $res->{mods}}, alerts => $res->{alerts}}, status => $res->{status});
}

sub validate {
  my $self = shift;

  my $modsxml = $self->req->body;

  my $util_model = PhaidraAPI::Model::Util->new;
  my $res        = $util_model->validate_xml($self, $modsxml, $self->app->config->{validate_mods});

  $self->render(json => $res, status => $res->{status});
}

sub json2xml_validate {
  my $self = shift;

  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    $self->render(json => {alerts => [{type => 'error', msg => $@}]}, status => 400);
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};

  my $mods_model = PhaidraAPI::Model::Mods->new;
  my $modsxml    = $mods_model->json_2_xml($self, $metadata->{mods});
  my $util_model = PhaidraAPI::Model::Util->new;
  my $res        = $util_model->validate_xml($self, $modsxml, $self->app->config->{validate_mods});

  $self->render(json => $res, status => $res->{status});
}

sub post {
  my $self = shift;

  my $t0 = [gettimeofday];

  my $pid = $self->stash('pid');

  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    $self->render(json => {alerts => [{type => 'error', msg => $@}]}, status => 400);
    return;
  }

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  unless (defined($metadata->{mods})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No MODS sent'}]}, status => 400);
    return;
  }

  my $metadata_model = PhaidraAPI::Model::Mods->new;
  my $res            = $metadata_model->save_to_object($self, $pid, $metadata->{mods}, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);

  my $t1 = tv_interval($t0);
  if ($res->{status} eq 200) {
    unshift @{$res->{alerts}}, {type => 'success', msg => "MODS for $pid saved successfully"};
  }

  $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
}

1;
