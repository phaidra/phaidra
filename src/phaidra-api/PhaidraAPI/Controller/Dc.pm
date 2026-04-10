package PhaidraAPI::Controller::Dc;

use strict;
use warnings;
use v5.10;
use Mojo::Util qw(xml_escape html_unescape encode decode);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Index;

sub get {
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

  if ($r->{index}->{pid}) {
    my $pid_identifier = $self->app->config->{scheme} . '://' . $self->app->config->{phaidra}->{baseurl} . '/' . $r->{index}->{pid};

    my $already_present = 0;
    if (exists($r->{index}->{dc_identifier}) && ref($r->{index}->{dc_identifier}) eq 'ARRAY') {
      for my $value (@{$r->{index}->{dc_identifier}}) {
        if ($value eq $pid_identifier) {
          $already_present = 1;
          last;
        }
      }
    }

    unless ($already_present) {
      $dc .= "\n  <dc:identifier>" . xml_escape(html_unescape($pid_identifier)) . "</dc:identifier>";
    }
  }

  $dc .= "\n</oai_dc:dc>";

  $self->render(text => $dc, format => 'xml', status => 200);
}

1;
