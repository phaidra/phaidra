package PhaidraAPI::Model::Rights;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use XML::LibXML;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Util;

=cut example
<uwr:rights xmlns:uwr="http://phaidra.univie.ac.at/XML/V1.0/rights">
	<uwr:allow>
		<uwr:username expires="2017-04-06T09:11:51Z">hudakr4</uwr:username>
		<uwr:faculty>A0</uwr:faculty>
		<uwr:gruppe>3111</uwr:gruppe>
		<uwr:spl>21</uwr:spl>
		<uwr:perfunk>8129</uwr:perfunk>
		<uwr:gruppe>3112</uwr:gruppe>
    <uwr:edupersonaffiliation>staff</uwr:edupersonaffiliation>
	</uwr:allow>
</uwr:rights>
=cut

our %allowed_tags = (
  'username'   => 1,
  'department' => 1,
  'faculty'    => 1,
  'gruppe'     => 1,
  'spl'        => 1,
  'kennzahl'   => 1,
  'perfunk'    => 1,
  'edupersonaffiliation'    => 1
);

sub json_2_xml {

  my ($self, $c, $rights) = @_;

  my $xml = '<uwr:rights xmlns:uwr="http://phaidra.univie.ac.at/XML/V1.0/rights"><uwr:allow>';
  while (my ($k, $v) = each %{$rights}) {
    if ($allowed_tags{$k}) {
      if (ref($v) eq 'ARRAY') {
        foreach my $it (@{$v}) {
          if (ref($it) eq 'HASH') {
            $xml .= "<uwr:$k" . (exists($it->{expires}) ? " expires=\"" . $it->{expires} . "\" " : "") . ">" . $it->{value} . "</uwr:$k>";
          }
          else {
            $xml .= "<uwr:$k>$it</uwr:$k>";
          }
        }
      }
      else {
        if (ref($v) eq 'HASH') {
          $xml .= "<uwr:$k" . (exists($v->{expires}) ? " expires=\"" . $v->{expires} . "\" " : "") . ">" . $v->{value} . "</uwr:$k>";
        }
        else {
          $xml .= "<uwr:$k>$v</uwr:$k>";
        }
      }
    }
  }

  $xml .= '</uwr:allow></uwr:rights>';

  return $xml;

}

sub xml_2_json {
  my ($self, $c, $xml) = @_;

  my $res = {alerts => [], status => 200};

  my $dom = Mojo::DOM->new();
  $dom->xml(1);
  $dom->parse($xml);
  my %json;

  foreach my $e ($dom->find('allow')->first->children->each) {
    my $type = $e->tag;
    $type =~ m/(\w+):(\w+)/;
    my $ns = $1;
    my $id = $2;
    my $expires;
    if (defined($e->attr)) {
      foreach my $ak (keys %{$e->attr}) {
        if ($ak eq 'expires') {
          $expires = $e->attr->{$ak};
        }
      }
    }

    if (defined($expires)) {
      push @{$json{$id}}, {value => $e->text, expires => $expires};
    }
    else {
      push @{$json{$id}}, $e->text;
    }

    #$c->app->log->debug($c->app->dumper($e));
  }

  $res->{rights} = \%json;

  return $res;
}

sub get_object_rights_json {

  my ($self, $c, $pid, $username, $password) = @_;

  my $object_model = PhaidraAPI::Model::Object->new;
  my $res          = $object_model->get_datastream($c, $pid, 'RIGHTS', $username, $password);
  if ($res->{status} ne 200) {
    return $res;
  }

  return $self->xml_2_json($c, $res->{RIGHTS});

}

sub save_to_object() {

  my $self     = shift;
  my $c        = shift;
  my $pid      = shift;
  my $metadata = shift;
  my $username = shift;
  my $password = shift;
  my $skiphook = shift;

  my $res = {alerts => [], status => 200};

  # convert
  my $rights = $self->json_2_xml($c, $metadata);
  unless ($rights) {
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error converting RIGHTS metadata'};
    return $res;
  }

  # validate
  if ($c->app->config->{validate_rights}) {
    my $util_model = PhaidraAPI::Model::Util->new;
    my $valres     = $util_model->validate_xml($c, $rights, $c->app->config->{validate_rights});
    if ($valres->{status} != 200) {
      $res->{status} = $valres->{status};
      foreach my $a (@{$valres->{alerts}}) {
        unshift @{$res->{alerts}}, $a;
      }
      return $res;
    }
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  return $object_model->add_or_modify_datastream($c, $pid, "RIGHTS", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $rights, "X", undef, undef, $username, $password, 0, $skiphook);
}

1;
__END__
