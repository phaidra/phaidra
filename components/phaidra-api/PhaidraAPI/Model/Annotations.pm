package PhaidraAPI::Model::Annotations;

use strict;
use warnings;
use v5.10;
use utf8;
use Mojo::ByteStream qw(b);
use Mojo::Util qw(encode decode);
use base qw/Mojo::Base/;
use XML::LibXML;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Util;

# https://github.com/ruven/iipmooviewer#annotations

sub json_2_xml {

  my ($self, $c, $annotations) = @_;

  my $xml = '<ph:annotations xmlns:ph="http://phaidra.org/XML/V1.0/annotations">';
  for my $id (keys %{$annotations}) {

    $xml .= "<ph:annotation ph:id=\"" . $id . "\">";
    my $a = $annotations->{$id};
    $xml .= "<ph:x>" . $a->{x} . "</ph:x>"                      if $a->{x};
    $xml .= "<ph:y>" . $a->{y} . "</ph:y>"                      if $a->{y};
    $xml .= "<ph:w>" . $a->{w} . "</ph:w>"                      if $a->{w};
    $xml .= "<ph:h>" . $a->{h} . "</ph:h>"                      if $a->{h};
    $xml .= "<ph:title>" . $a->{title} . "</ph:title>"          if $a->{title};
    $xml .= "<ph:category>" . $a->{category} . "</ph:category>" if $a->{category};
    $xml .= "<ph:text>" . $a->{text} . "</ph:text>"             if $a->{text};

    $xml .= "</ph:annotation>";
  }

  $xml .= '</ph:annotations>';
  return $xml;
}

sub xml_2_json {
  my ($self, $c, $xml) = @_;

  my $res = {alerts => [], status => 200};

  my $dom;
  if (ref $xml eq 'Mojo::DOM') {
    $dom = $xml;
  }
  else {
    $dom = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($xml);
  }

  my %annotations;
  for my $a ($dom->find('annotation')->each) {

    my $annotation = ();

    my $x        = $a->find('x')->first;
    my $y        = $a->find('y')->first;
    my $w        = $a->find('w')->first;
    my $h        = $a->find('h')->first;
    my $title    = $a->find('title')->first;
    my $category = $a->find('category')->first;
    my $text     = $a->find('text')->first;
    if ($x) {
      $annotation->{x} = $x->text;
    }
    if ($y) {
      $annotation->{y} = $y->text;
    }
    if ($w) {
      $annotation->{w} = $w->text;
    }
    if ($h) {
      $annotation->{h} = $h->text;
    }
    if ($title) {
      $annotation->{title} = $title->text;
    }
    if ($category) {
      $annotation->{category} = $category->text;
    }
    if ($text) {
      $annotation->{text} = $text->text;
    }

    $annotations{$a->attr('ph:id')} = $annotation;

  }

  $res->{annotations} = \%annotations;

  return $res;
}

sub get_object_annotations_json {

  my ($self, $c, $pid, $username, $password) = @_;

  my $object_model = PhaidraAPI::Model::Object->new;
  my $res          = $object_model->get_datastream($c, $pid, 'ANNOTATIONS', $username, $password, 1);
  if ($res->{status} ne 200) {
    return $res;
  }

  return $self->xml_2_json($c, $res->{ANNOTATIONS});

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
  my $annotations = $self->json_2_xml($c, $metadata);
  unless ($annotations) {
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error converting ANNOTATIONS metadata'};
    return $res;
  }

  # validate
  if ($c->app->config->{validate_annotations}) {
    my $util_model = PhaidraAPI::Model::Util->new;
    my $valres     = $util_model->validate_xml($c, $annotations, $c->app->config->{validate_annotations});
    if ($valres->{status} != 200) {
      $res->{status} = $valres->{status};
      foreach my $a (@{$valres->{alerts}}) {
        unshift @{$res->{alerts}}, $a;
      }
      return $res;
    }
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  return $object_model->add_or_modify_datastream($c, $pid, "ANNOTATIONS", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $annotations, "X", undef, undef, $username, $password, 0, $skiphook);
}

1;
__END__
