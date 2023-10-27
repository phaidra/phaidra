package PhaidraAPI::Model::Geo;

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

sub json_2_xml {

  my ($self, $c, $geo) = @_;

  my $xml = '<kml:kml xmlns:kml="http://www.opengis.net/kml/2.2"><kml:Document>';
  foreach my $pm (@{$geo->{kml}->{document}->{placemark}}) {

    $xml .= "<kml:Placemark>";

    $xml .= "<kml:name>" . $pm->{name} . "</kml:name>"                      if $pm->{name};
    $xml .= "<kml:description>" . $pm->{description} . "</kml:description>" if $pm->{description};

    if ($pm->{point}) {
      if ($pm->{point}->{coordinates}) {
        $xml .= "<kml:Point><kml:coordinates>";
        if ($pm->{point}->{coordinates}->{longitude} && $pm->{point}->{coordinates}->{latitude}) {
          $xml .= $pm->{point}->{coordinates}->{longitude} . "," . $pm->{point}->{coordinates}->{latitude} . ",0";
        }
        $xml .= "</kml:coordinates></kml:Point>";
      }
    }

    if ($pm->{polygon}) {
      if ($pm->{polygon}->{outerboundaryis}) {
        if ($pm->{polygon}->{outerboundaryis}->{linearring}) {
          if ($pm->{polygon}->{outerboundaryis}->{linearring}->{coordinates}) {
            $xml .= "<kml:Polygon><kml:outerBoundaryIs><kml:LinearRing><kml:coordinates>";
            my $i = 0;
            foreach $c (@{$pm->{polygon}->{outerboundaryis}->{linearring}->{coordinates}}) {
              $i++;
              $xml .= " " if ($i > 1);
              if ($c->{longitude} && $c->{latitude}) {
                $xml .= $c->{longitude} . "," . $c->{latitude} . ",0";
              }
            }
            $xml .= "</kml:coordinates></kml:LinearRing></kml:outerBoundaryIs></kml:Polygon>";
          }
        }
      }
    }

    $xml .= "</kml:Placemark>";
  }

  $xml .= '</kml:Document></kml:kml>';
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

  my @placemarks;
  for my $pm ($dom->find('Placemark')->each) {

    my $placemark = ();

    my $name = $pm->find('name')->first;
    if ($name) {
      $placemark->{name} = b($name->text)->decode('UTF-8');
    }
    my $description = $pm->find('description')->first;
    if ($description) {
      $placemark->{description} = b($description->text)->decode('UTF-8');
    }

    for my $po ($pm->find('Point')->each) {
      my $coo = $pm->find('coordinates')->first;
      if ($coo) {
        $coo->text =~ m/([+\-0-9.]+),([+\-0-9.]+),([+\-0-9.]+)/;
        my $long = $1;
        my $lat  = $2;
        $placemark->{point} = {
          coordinates => {
            longitude => $long,
            latitude  => $lat
          }
        };
      }
    }

    for my $po ($pm->find('Polygon')->each) {
      my $coo = $pm->find('outerBoundaryIs LinearRing coordinates')->first;
      if ($coo) {
        $coo = $coo->text;
        my @crds_str = split(' ', $coo);
        my @crds_arr;
        foreach my $c (@crds_str) {
          $c =~ m/([+\-0-9.]+),([+\-0-9.]+),([+\-0-9.]+)/;
          my $long = $1;
          my $lat  = $2;
          push @crds_arr, {longitude => $long, latitude => $lat};
        }
        $placemark->{polygon} = {outerboundaryis => {linearring => {coordinates => \@crds_arr}}};
      }
    }

    push @placemarks, $placemark;

  }

  # all we support now is placemark's name, description, point and polygon
  $res->{geo} = {"kml" => {"document" => {"placemark" => \@placemarks}}};

  return $res;
}

sub get_object_geo_json {

  my ($self, $c, $pid, $username, $password) = @_;

  my $object_model = PhaidraAPI::Model::Object->new;
  my $res          = $object_model->get_datastream($c, $pid, 'GEO', $username, $password, 1);
  if ($res->{status} ne 200) {
    return $res;
  }

  return $self->xml_2_json($c, $res->{GEO});

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
  my $geo = $self->json_2_xml($c, $metadata);
  unless ($geo) {
    $res->{status} = 500;
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error converting GEO metadata'};
    return $res;
  }

  # validate
  if ($c->app->config->{validate_geo}) {
    my $util_model = PhaidraAPI::Model::Util->new;
    my $valres     = $util_model->validate_xml($c, $geo, $c->app->config->{validate_geo});
    if ($valres->{status} != 200) {
      $res->{status} = $valres->{status};
      foreach my $a (@{$valres->{alerts}}) {
        unshift @{$res->{alerts}}, $a;
      }
      return $res;
    }
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  return $object_model->add_or_modify_datastream($c, $pid, "GEO", "text/xml", undef, $c->app->config->{phaidra}->{defaultlabel}, $geo, "X", undef, undef, $username, $password, 0, $skiphook);
}

1;
__END__
