package PhaidraAPI::Controller::Index;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::ByteStream qw(b);
use Mojo::Util qw(xml_escape html_unescape);
use Mojo::JSON qw(encode_json decode_json);
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Dc;

sub get {
  my ($self) = @_;

  my $pid          = $self->stash('pid');
  my $ignorestatus = $self->param('ignorestatus');

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($self, $pid, $ignorestatus);

  $self->render(json => $r, status => $r->{status});
}

sub get_relationships {
  my ($self) = @_;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get_relationships($self, $pid);

  $self->render(json => $r, status => $r->{status});
}

sub get_object_members {
  my ($self) = @_;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get_object_members($self, $pid);

  $self->render(json => $r, status => $r->{status});
}

sub get_dc {
  my ($self) = @_;

  my $pid          = $self->stash('pid');
  my $ignorestatus = $self->param('ignorestatus');

  my $index_model = PhaidraAPI::Model::Index->new;
  my $r           = $index_model->get($self, $pid, $ignorestatus);

  if ($r->{status} ne 200) {
    $self->render(json => $r, status => $r->{status});
    return;
  }

  my $dc = '<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">';
  my %have_lang_field;

  for my $field (keys %{$r->{index}}) {
    if ($field =~ m/^dc_(\w+)_(\w+)/) {
      $have_lang_field{$1} = 1;
    }
  }
  for my $field (keys %{$r->{index}}) {
    if ($field =~ m/^dc_(\w+)_(\w+)/) {
      for my $value (@{$r->{index}->{$field}}) {
        $dc .= "\n  <dc:$1 xml:lang=\"$2\">" . xml_escape(html_unescape($value)) . "</dc:$1>";
      }
    }
    elsif ($field =~ m/^dc_(\w+)/) {

      # if there is eg dc_title_deu do not add dc_title too, except for authors and contributors (where institutions have language but names do not)
      # and rights, where licences do have no language, but rights statements do
      next if ($have_lang_field{$1}) && ($field ne 'dc_creator') && ($field ne 'dc_contributor') && ($field ne 'dc_rights');

      for my $value (@{$r->{index}->{$field}}) {
        $dc .= "\n  <dc:$1>" . xml_escape(html_unescape($value)) . "</dc:$1>";
      }

    }
  }

  $dc .= "\n</oai_dc:dc>";

  $self->render(text => $dc, format => 'xml', status => 200);
}

sub update {

  my $self         = shift;
  my $pid_param    = $self->stash('pid');
  my $ignorestatus = $self->param('ignorestatus');
  my $norecursion = $self->param('norecursion');
  my $core = $self->param('core');

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

  my $index_model  = PhaidraAPI::Model::Index->new;
  my $dc_model     = PhaidraAPI::Model::Dc->new;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $object_model = PhaidraAPI::Model::Object->new;
  my @res;
  my $pidscount = scalar @pidsarr;
  my $i         = 0;
  for my $pid (@pidsarr) {

    $i++;
    $self->app->log->info("index processing $pid [$i/$pidscount]");

    eval {

      my $r = $index_model->update($self, $pid, $dc_model, $search_model, $object_model, $ignorestatus, $norecursion, $core);
      if ($r->{status} eq 200 && $pidscount > 1) {
        push @res, {pid => $pid, status => 200};
      }
      else {
        $r->{pid} = $pid;
        push @res, $r;
      }
    };

    if ($@) {
      $self->app->log->error("pid $pid Error: $@");
    }

  }

  if (scalar @res == 1) {
    $self->render(json => {result => $res[0]}, status => 200);
  }
  else {
    $self->render(json => {results => \@res}, status => 200);
  }
}

1;
