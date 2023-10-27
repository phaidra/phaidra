package PhaidraAPI::Controller::Rights;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Rights;
use Time::HiRes qw/tv_interval gettimeofday/;

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

  my $metadata_model = PhaidraAPI::Model::Rights->new;
  my $rightsxml      = $metadata_model->json_2_xml($self, $metadata->{rights});

  $self->render(json => {alerts => $res->{alerts}, metadata => {rights => $rightsxml}}, status => $res->{status});
}

sub xml2json {
  my $self = shift;

  my $mode = $self->param('mode');
  my $xml  = $self->req->body;

  $xml = b($xml)->decode('UTF-8');

  my $rights_model = PhaidraAPI::Model::Rights->new;
  my $res          = $rights_model->xml_2_json($self, $xml, $mode);

  $self->render(json => {metadata => {rights => $res->{rights}, alerts => $res->{alerts}}}, status => $res->{status});

}

sub validate {
  my $self = shift;

  my $rightsxml = $self->req->body;

  my $util_model = PhaidraAPI::Model::Util->new;
  my $res        = $util_model->validate_xml($self, $rightsxml, $self->app->config->{validate_rights});

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

  my $rights_model = PhaidraAPI::Model::Rights->new;
  my $rightsxml    = $rights_model->json_2_xml($self, $metadata->{rights});
  my $util_model   = PhaidraAPI::Model::Util->new;
  my $res          = $util_model->validate_xml($self, $rightsxml, $self->app->config->{validate_rights});

  $self->render(json => $res, status => $res->{status});
}

sub get {
  my $self = shift;

  my $pid = $self->stash('pid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $rights_model = PhaidraAPI::Model::Rights->new;
  my $res          = $rights_model->get_object_rights_json($self, $pid, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    if ($res->{status} eq 404) {

      # no RIGHTS
      $self->render(json => {alerts => [], metadata => {rights => {}}}, status => 200);
      return;
    }
    $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
    return;
  }

  $self->render(json => {metadata => $res}, status => $res->{status});
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
      $self->app->log->debug("parsing json file");
      $metadata = decode_json($metadata);
    }
    else {
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
      $self->app->log->debug("parsing json");
      $self->app->log->debug($metadata);
      $metadata = decode_json($metadata);
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

  unless (defined($metadata->{rights})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No RIGHTS sent'}]}, status => 400);
    return;
  }

  my $rights_model = PhaidraAPI::Model::Rights->new;
  my $res          = $rights_model->save_to_object($self, $pid, $metadata->{rights}, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);

  my $t1 = tv_interval($t0);
  if ($res->{status} eq 200) {
    unshift @{$res->{alerts}}, {type => 'success', msg => "RIGHTS for $pid saved successfully ($t1 s)"};
  }

  $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
}

1;
