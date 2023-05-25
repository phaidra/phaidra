package PhaidraAPI::Model::Membersorder;

use strict;
use warnings;
use v5.10;
use utf8;
use Mojo::ByteStream qw(b);
use Mojo::Util qw(encode decode);
use base qw/Mojo::Base/;
use XML::LibXML;
use PhaidraAPI::Model::Object;

sub json_2_xml {

  my ($self, $c, $members) = @_;

  my $xml = "<co:collection_order xmlns:co=\"http://phaidra.univie.ac.at/XML/collection_order/V1.0\">";
  foreach my $m (@{$members}) {
    $xml .= "<co:member pos=\"" . $m->{'pos'} . "\">" . $m->{pid} . "</co:member>";
  }
  $xml .= "</co:collection_order>";
  return $xml;
}

sub xml_2_json {
  my ($self, $c, $xml) = @_;

  my $res = {alerts => [], status => 200};

  my @members;

  my $dom;
  if (ref $xml eq 'Mojo::DOM') {
    $dom = $xml;
  }
  else {
    $dom = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($xml);
  }

  $dom->find('member[pos]')->each(
    sub {
      my $m = shift;
      push @members, {"pid" => $m->text, "pos" => $m->{'pos'}};
    }
  );

  $res->{members} = \@members;

  return $res;
}

sub get_object_collectionorder_json {

  my ($self, $c, $pid, $username, $password) = @_;

  my $object_model = PhaidraAPI::Model::Object->new;
  my $res          = $object_model->get_datastream($c, $pid, 'COLLECTIONORDER', $username, $password, 1);
  if ($res->{status} ne 200) {
    return $res;
  }

  return $self->xml_2_json($c, $res->{COLLECTIONORDER});
}

sub save_to_object() {
  my $self     = shift;
  my $c        = shift;
  my $pid      = shift;
  my $members  = shift;
  my $username = shift;
  my $password = shift;

  my $res = {alerts => [], status => 200};

  # FIXME: check existence

  my $xml = "<co:collection_order xmlns:co=\"http://phaidra.univie.ac.at/XML/collection_order/V1.0\">";
  foreach my $m (@{$members}) {
    $xml .= "<co:member pos=\"" . $m->{'pos'} . "\">" . $m->{pid} . "</co:member>";
  }
  $xml .= "</co:collection_order>";

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->add_or_modify_datastream($c, $pid, "COLLECTIONORDER", "text/xml", undef, undef, $xml, 'X', undef, undef, $username, $password, 0, 0);
  push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;

  return $res;
}

1;
__END__
