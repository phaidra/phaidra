package PhaidraAPI::Model::Jsonldprivate;

use strict;
use warnings;
use v5.10;
use utf8;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Util qw(encode decode);
use base qw/Mojo::Base/;
use XML::LibXML;
use PhaidraAPI::Model::Object;

sub get_object_jsonldprivate_parsed {

  my ($self, $c, $pid, $username, $password) = @_;

  my $res = {alerts => [], status => 200};

  my $object_model = PhaidraAPI::Model::Object->new;

  # do not use admin/intcall credentials here!
  my $r = $object_model->get_datastream($c, $pid, 'JSON-LD-PRIVATE', $username, $password);

  if ($r->{status} ne 200) {
    return $r;
  }
  $res->{'JSON-LD-PRIVATE'} = decode_json($r->{'JSON-LD-PRIVATE'});
  return $res;
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

  # validate
  my $valres = $self->validate($c, $metadata);
  if ($valres->{status} != 200) {
    $res->{status} = $valres->{status};
    foreach my $a (@{$valres->{alerts}}) {
      unshift @{$res->{alerts}}, $a;
    }
    return $res;
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  my $coder        = JSON->new->utf8->pretty;
  my $json         = $coder->encode($metadata);
  return $object_model->add_or_modify_datastream($c, $pid, "JSON-LD-PRIVATE", "application/json", undef, $c->app->config->{phaidra}->{defaultlabel}, $json, "M", undef, undef, $username, $password, 0, $skiphook);
}

sub validate() {
  my $self     = shift;
  my $c        = shift;
  my $metadata = shift;

  my $res = {alerts => [], status => 200};

  return $res;
}

1;
__END__
