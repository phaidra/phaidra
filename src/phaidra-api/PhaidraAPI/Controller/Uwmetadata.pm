package PhaidraAPI::Controller::Uwmetadata;

use strict;
use warnings;
use v5.10;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Util;
use PhaidraAPI::Model::Languages;
use PhaidraAPI::Model::Object;
use Time::HiRes qw/tv_interval gettimeofday/;

sub get {
  my $self = shift;

  my $t0 = [gettimeofday];

  my $pid    = $self->stash('pid');
  my $format = $self->param('format');
  my $mode   = $self->param('mode');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  if (defined($format) && $format eq 'xml') {
    my $object_model = PhaidraAPI::Model::Object->new;

    # return XML directly
    $object_model->proxy_datastream($self, $pid, 'UWMETADATA', undef, undef, 1);
    return;
  }

  unless (defined($mode)) {
    $mode = 'basic';
  }

  # get metadata datastructure
  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $res            = $metadata_model->get_object_metadata($self, $pid, $mode, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
    return;
  }

  my $t1 = tv_interval($t0);

  #$self->stash( msg => "backend load took $t1 s");

  if ($mode eq 'basic' || $mode eq 'resolved') {
    $self->render(json => {metadata => {uwmetadata => $res->{uwmetadata}}}, status => $res->{status});
  }
  else {

    my $lang_model = PhaidraAPI::Model::Languages->new;
    my $lres       = $lang_model->get_languages($self);
    if ($lres->{status} ne 200) {
      $self->render(json => {alerts => $lres->{alerts}}, $lres->{status});
      return;
    }

    $self->render(json => {metadata => {uwmetadata => $res->{uwmetadata}}, languages => $lres->{languages}}, status => $res->{status});    #, alerts => [{ type => 'success', msg => $self->stash->{msg}}]});
  }
}

sub json2xml {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  #my $t0 = [gettimeofday];
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

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $uwmetadataxml  = $metadata_model->json_2_uwmetadata($self, $metadata->{uwmetadata});

  #my $t1 = tv_interval($t0);
  #$self->app->log->debug("json2xml took $t1 s");

  $self->render(json => {alerts => $res->{alerts}, metadata => {uwmetadata => $uwmetadataxml}}, status => $res->{status});
}

sub compress {
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

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my @compressed     = ();
  $metadata_model->compress_json($self, $metadata->{uwmetadata}, \@compressed);

  $self->render(json => {alerts => $res->{alerts}, metadata => {uwmetadata => \@compressed}}, status => $res->{status});
}

sub decompress {
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

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $decompressed   = $metadata_model->decompress_json($self, $metadata->{uwmetadata});

  $self->render(json => {alerts => $res->{alerts}, metadata => {uwmetadata => $decompressed}}, status => $res->{status});
}

sub xml2json {
  my $self = shift;

  #my $t0 = [gettimeofday];

  my $mode = $self->param('mode');

  my $uwmetadataxml = $self->req->body;

  $uwmetadataxml = b($uwmetadataxml)->decode('UTF-8');

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;

  my $res;
  if ($mode && $mode eq 'full') {
    $res = $metadata_model->uwmetadata_2_json($self, $uwmetadataxml);
  }
  else {
    # uwmetadata_2_json_basic doesn't insert empty nodes which can break validation
    $res = $metadata_model->uwmetadata_2_json_basic($self, $uwmetadataxml);
  }

  #my $t1 = tv_interval($t0);
  #$self->app->log->debug("xml2json took $t1 s");
  #$self->app->log->debug("XXXXXXXXXXX: ".$self->app->dumper($res));
  $self->render(json => {metadata => {uwmetadata => $res->{uwmetadata}}, alerts => $res->{alerts}}, status => $res->{status});
}

sub validate {
  my $self = shift;

  my $uwmetadataxml = $self->req->body;

  my $util_model = PhaidraAPI::Model::Util->new;
  my $res        = $util_model->validate_xml($self, $uwmetadataxml, $self->app->config->{validate_uwmetadata});

  $self->render(json => $res, status => $res->{status});
}

sub json2xml_validate {
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

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;

  if ($self->param('fix') eq '1') {
    if ($self->param('pid')) {
      $metadata_model->fix_uwmetadata($self, $self->param('pid'), $metadata->{uwmetadata});
    }
    else {
      $metadata_model->fix_uwmetadata($self, 'o:0', $metadata->{uwmetadata});
    }
  }

  my $uwmetadataxml = $metadata_model->json_2_uwmetadata($self, $metadata->{uwmetadata});
  my $util_model    = PhaidraAPI::Model::Util->new;
  $res = $util_model->validate_xml($self, $uwmetadataxml, $self->app->config->{validate_uwmetadata});

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

  unless (defined($metadata->{uwmetadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No uwmetadata sent'}]}, status => 400);
    return;
  }

  my $metadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $res            = $metadata_model->save_to_object($self, $pid, $metadata->{uwmetadata}, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);

  my $t1 = tv_interval($t0);
  if ($res->{status} eq 200) {
    unshift @{$res->{alerts}}, {type => 'success', msg => "UWMETADATA for $pid saved successfully"};
  }

  $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
}

sub tree {
  my $self = shift;

  my $t0 = [gettimeofday];

  my $nocache = $self->param('nocache');

  my $metadata_model  = PhaidraAPI::Model::Uwmetadata->new;
  my $languages_model = PhaidraAPI::Model::Languages->new;

  my $lres = $languages_model->get_languages($self);
  if ($lres->{status} ne 200) {
    $self->render(json => {alerts => $lres->{alerts}}, $lres->{status});
    return;
  }

  my $res = $metadata_model->metadata_tree($self, $nocache);
  if ($res->{status} ne 200) {
    $self->render(json => {alerts => $res->{alerts}}, $res->{status});
    return;
  }

  my $t1 = tv_interval($t0);
  $self->stash(msg => "backend load took $t1 s");

  $self->render(json => {tree => $res->{metadata_tree}, languages => $lres->{languages}, alerts => $res->{alerts}}, status => $res->{status});
}

1;
