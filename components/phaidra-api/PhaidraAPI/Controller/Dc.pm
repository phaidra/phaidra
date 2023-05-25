package PhaidraAPI::Controller::Dc;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Dc;

sub get {

  my $self = shift;
  my $dsid = $self->stash('dsid');

  my $pid    = $self->stash('pid');
  my $format = $self->param('format');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}], status => 404}, status => 404);
    return;
  }

  if ($format eq 'xml') {
    my $object_model = PhaidraAPI::Model::Object->new;
    $object_model->proxy_datastream($self, $pid, $dsid, undef, undef, 1);
    return;
  }

  my $dc_model = PhaidraAPI::Model::Dc->new;

  my $res = $dc_model->get_object_dc_json($self, $pid, $dsid, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    if ($res->{status} eq 404) {
      my $dclab = $dsid eq 'DC_P' ? 'dc' : 'oai_dc';
      $self->render(json => {alerts => $res->{alerts}, $dclab => {}, status => $res->{status}}, status => $res->{status});
      return;
    }
    $self->render(json => $res, status => $res->{status});
    return;
  }

  if ($format eq 'index') {
    my %dc_index;
    for my $f (@{$res->{dc}}) {
      if (exists($f->{attributes})) {
        for my $a (@{$f->{attributes}}) {
          if ($a->{xmlname} eq 'xml:lang') {
            push @{$dc_index{$f->{xmlname} . "_" . $a->{ui_value}}}, $f->{ui_value};
          }
        }
      }
      push @{$dc_index{$f->{xmlname}}}, $f->{ui_value};
    }
    $self->render(json => {metadata => {dc_index => \%dc_index}, status => $res->{status}}, status => $res->{status});
    return;
  }

  $self->render(json => {metadata => $res, status => $res->{status}}, status => $res->{status});
}

sub uwmetadata_2_dc_index {
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

  my $r0 = $metadata_model->metadata_tree($self);
  if ($r0->{status} ne 200) {
    return $res;
  }

  my $dc_model = PhaidraAPI::Model::Dc->new;
  my ($dc_p, $dc_oai) = $dc_model->map_uwmetadata_2_dc_hash($self, 'o:0', undef, $uwmetadataxml, $r0->{metadata_tree}, $metadata_model);

  my %dc_index;
  for my $fname (keys %{$dc_p}) {
    if (defined($dc_p->{$fname}) && $dc_p->{$fname} ne '') {
      for my $f (@{$dc_p->{$fname}}) {
        push @{$dc_index{$fname}}, $f->{value};
        if (exists($f->{lang})) {
          push @{$dc_index{$fname . "_" . $f->{lang}}}, $f->{value};
        }
      }
    }
  }
  $self->render(json => {metadata => {dc_index => \%dc_index}}, status => $res->{status});

}

sub xml2json {
  my $self = shift;

  my $xml = $self->req->body;

  my $dc_model = PhaidraAPI::Model::Dc->new;
  my $res      = $dc_model->xml_2_json($self, $xml, 'dc');

  $self->render(json => {metadata => {dc => $res->{dc}}, alerts => $res->{alerts}}, status => $res->{status});
}

sub update {

  my $self      = shift;
  my $pid_param = $self->stash('pid');

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  my @pidsarr;
  if (defined($pid_param)) {

    push @pidsarr, $pid_param;
  }
  else {

    my $pids = $self->param('pids');

    unless (defined($pids)) {
      $self->render(json => {alerts => [{type => 'error', msg => 'No pids sent'}]}, status => 400);
      return;
    }

    eval {
      if (ref $pids eq 'Mojo::Upload') {
        $self->app->log->debug("Pids sent as file param");
        $pids = $pids->asset->slurp;
        $self->app->log->debug("parsing json");
        $pids = decode_json($pids);
      }
      else {
        $self->app->log->debug("parsing json");
        $pids = decode_json(b($pids)->encode('UTF-8'));
      }
    };

    if ($@) {
      $self->app->log->error("Error: $@");
      $self->render(json => {alerts => [{type => 'error', msg => $@}]}, status => 400);
      return;
    }

    unless (defined($pids->{pids})) {
      $self->render(json => {alerts => [{type => 'error', msg => 'No pids found'}]}, status => 400);
      return;
    }

    @pidsarr = @{$pids->{pids}};
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  my $dc_model     = PhaidraAPI::Model::Dc->new;
  my $search_model = PhaidraAPI::Model::Search->new;
  my @res;
  my $pidscount = scalar @pidsarr;
  my $i         = 0;
  for my $pid (@pidsarr) {
    $i++;
    $self->app->log->info("Processing $pid [$i/$pidscount]");

    # check if it's active
    my $r = $search_model->get_state($self, $pid);
    if ($r->{status} ne 200) {
      push @res, {pid => $pid, res => $r};
      next;
    }
    unless ($r->{state} eq 'Active') {
      $self->app->log->warn("[update DC] Object $pid is " . $r->{state} . ", skipping");
      next;
    }

    eval {
      my $r_dsh = $search_model->datastreams_hash($self, $pid);
      if ($r_dsh->{status} ne 200) {
        push @res, {pid => $pid, res => $r_dsh};
        next;
      }

      if ($r_dsh->{dshash}->{'UWMETADATA'}) {
        my $rs = $object_model->get_datastream($self, $pid, 'UWMETADATA', $username, $password);
        if ($rs->{status} ne 200) {
          $rs->{pid} = $pid;
          push @res, $rs;
          next;
        }
        $rs->{UWMETADATA} = b($rs->{UWMETADATA})->decode('UTF-8');
        my $gr = $dc_model->generate_dc_from_uwmetadata($self, $pid, $rs->{UWMETADATA}, $username, $password);
        if ($gr->{status} ne 200) {
          $gr->{pid} = $pid;
          push @res, $gr;
          next;
        }
      }
      if ($r_dsh->{dshash}->{'MODS'}) {
        my $rs = $object_model->get_datastream($self, $pid, 'MODS', $username, $password);
        if ($rs->{status} ne 200) {
          $rs->{pid} = $pid;
          push @res, $rs;
          next;
        }
        $rs->{MODS} = b($rs->{MODS})->decode('UTF-8');
        my $gr = $dc_model->generate_dc_from_mods($self, $pid, $rs->{MODS}, $username, $password);
        if ($gr->{status} ne 200) {
          $gr->{pid} = $pid;
          push @res, $gr;
          next;
        }
      }
    };

    if ($@) {
      $self->app->log->error("pid $pid Error: $@");
    }
    else {
      push @res, {pid => $pid, status => 200};
    }

  }

  $self->render(json => {results => \@res}, status => 200);
}

1;
