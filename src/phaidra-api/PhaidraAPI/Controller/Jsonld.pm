package PhaidraAPI::Controller::Jsonld;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Jsonld;
use PhaidraAPI::Model::Util;
use Time::HiRes qw/tv_interval gettimeofday/;
use Data::UUID;
use boolean;

sub get {
  my $self = shift;

  my $pid    = $self->stash('pid');
  my $header = ($self->stash('header') eq '1') || ($self->param('header') eq '1');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $res          = $jsonld_model->get_object_jsonld_parsed($self, $pid);
  if ($res->{status} ne 200) {
    return $res;
  }
  my $jsonld = $res->{'JSON-LD'};
  if ($header) {
    my $context;
    for my $ns (keys %{$PhaidraAPI::Model::Jsonld::namespaces}) {
      $context->{$ns} = $PhaidraAPI::Model::Jsonld::namespaces->{$ns}->{IRI};
    }
    $jsonld->{'@context'} = $context;
    $jsonld->{'@id'}      = 'https://' . $self->config->{phaidra}->{baseurl} . '/' . $pid;
    for my $pred (keys %{$jsonld}) {
      if ($pred =~ m/role:(\w+)/g) {
        $jsonld->{'@context'}->{$pred} = {'@id' => 'http://id.loc.gov/vocabulary/relators', '@container' => '@list'};
      }
    }
  }
  $self->render(json => $jsonld, status => 200);
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

  unless (defined($metadata->{'json-ld'}) || defined($metadata->{'JSON-LD'})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No JSON-LD sent'}]}, status => 400);
    return;
  }

  my $jsonld;
  if (defined($metadata->{'json-ld'})) {
    $jsonld = $metadata->{'json-ld'};
  }
  else {
    $jsonld = $metadata->{'JSON-LD'};
  }

  my $cmodel;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $res_cmodel   = $search_model->get_cmodel($self, $pid);
  if ($res_cmodel->{status} ne 200) {
    my $err = "ERROR saving json-ld for object $pid, could not get cmodel:" . $self->app->dumper($res_cmodel);
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $res          = $jsonld_model->save_to_object($self, $pid, $cmodel, $jsonld, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);

  my $t1 = tv_interval($t0);
  if ($res->{status} eq 200) {
    unshift @{$res->{alerts}}, {type => 'success', msg => "JSON-LD for $pid saved successfully ($t1 s)"};
  }

  $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
}

sub add_template {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $name = $self->param('name');
  unless (defined($name)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No name sent'}]}, status => 400);
    return;
  }

  my $form = $self->param('form');
  unless (defined($form)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No form sent'}]}, status => 400);
    return;
  }

  my $rights = $self->param('rights');

  my $tag = $self->param('tag');

  eval {
    if (ref $form eq 'Mojo::Upload') {
      $self->app->log->debug("form sent as file param");
      $form = $form->asset->slurp;
      $form = decode_json($form);
    }
    else {
      $form = decode_json(b($form)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my $ug   = Data::UUID->new;
  my $btid = $ug->create();
  my $tid  = $ug->to_string($btid);

  my $owner;
  if ($self->stash('remote_user')) {
    $owner = $self->stash('remote_user');
  } else {
    $owner = $self->stash->{basic_auth_credentials}->{username};
  }

  my $doc = {tid => $tid, owner => $owner, name => $name, form => $form, tag => $tag, created => time};
  if ($rights) {
    $doc->{rights} = decode_json(b($rights)->encode('UTF-8'))
  }
  $self->mongo->get_collection('jsonldtemplates')->insert_one($doc);

  $res->{tid} = $tid;

  $self->render(json => $res, status => $res->{status});
}

sub edit_template {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('tid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined template id'}]}, status => 400);
    return;
  }
  my $tid = $self->stash('tid');

  my $form = $self->param('form');
  unless (defined($form)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No form sent'}]}, status => 400);
    return;
  }

  my $rights = $self->param('rights');

  my $tag = $self->param('tag');

  eval {
    if (ref $form eq 'Mojo::Upload') {
      $self->app->log->debug("form sent as file param");
      $form = $form->asset->slurp;
      $form = decode_json($form);
    }
    else {
      $form = decode_json(b($form)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my $owner;
  if ($self->stash('remote_user')) {
    $owner = $self->stash('remote_user');
  } else {
    $owner = $self->stash->{basic_auth_credentials}->{username};
  }

  $self->mongo->get_collection('jsonldtemplates')->update_one({tid => $tid, owner => $owner}, { '$set' => { form => $form, updated => time}});
  if ($rights) {
    $self->mongo->get_collection('jsonldtemplates')->update_one({tid => $tid, owner => $owner}, { '$set' => { rights => decode_json(b($rights)->encode('UTF-8')), updated => time}});
  }

  $self->render(json => $res, status => $res->{status});
}

sub get_template {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('tid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined template id'}]}, status => 400);
    return;
  }
  $self->app->log->debug($self->stash('tid') . " " . $self->stash->{basic_auth_credentials}->{username});

  my $owner;
  if ($self->stash('remote_user')) {
    $owner = $self->stash('remote_user');
  } else {
    $owner = $self->stash->{basic_auth_credentials}->{username};
  }

  my $sres = $self->mongo->get_collection('config')->find_one({ config_type => 'public' });
  if ($sres->{defaulttemplateid}) {
    if ($sres->{defaulttemplateid} eq $self->stash('tid')) {
      # everybody can read the default template
      $self->app->log->debug("loading default template[".$self->stash('tid')."]");
      my $tres = $self->mongo->get_collection('jsonldtemplates')->find_one({tid => $self->stash('tid')});
      $res->{template} = $tres;
      $self->render(json => $res, status => $res->{status});
      return;
    }
  }

  my $tres = $self->mongo->get_collection('jsonldtemplates')->find_one(
    {
      tid => $self->stash('tid'), 
      '$or' => [{ owner => $owner }, { public => true }]
    }
  );

  $res->{template} = $tres;

  $self->render(json => $res, status => $res->{status});
}

sub get_users_templates {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $tag = $self->param('tag');

  my $owner;
  if ($self->stash('remote_user')) {
    $owner = $self->stash('remote_user');
  } else {
    $owner = $self->stash->{basic_auth_credentials}->{username};
  }

  my $find = {'owner' => $owner};
  if ($tag) {
    $find->{'tag'} = $tag;
  }

  my $users_templates = $self->mongo->get_collection('jsonldtemplates')->find($find)->sort({'created' => -1});
  my @tmplts          = ();
  while (my $doc = $users_templates->next) {
    push @tmplts, {tid => $doc->{tid}, name => $doc->{name}, created => $doc->{created}};
  }

  $res->{templates} = \@tmplts;

  $self->render(json => $res, status => $res->{status});
}

sub remove_template {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  unless (defined($self->stash('tid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined template id'}]}, status => 400);
    return;
  }

  my $owner;
  if ($self->stash('remote_user')) {
    $owner = $self->stash('remote_user');
  } else {
    $owner = $self->stash->{basic_auth_credentials}->{username};
  }

  $self->mongo->get_collection('jsonldtemplates')->delete_one({tid => $self->stash('tid'), owner => $owner});

  $self->render(json => $res, status => $res->{status});
}

1;
