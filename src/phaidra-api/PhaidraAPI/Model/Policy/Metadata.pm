package PhaidraAPI::Model::Policy::Metadata;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::JSON qw(decode_json);
use Mojo::ByteStream qw(b);

# Flatten request JSON-LD into fields Rego can match (object_type, license).
sub from_request {
  my ($self, $c) = @_;

  my $envelope = $self->_request_envelope($c);
  return unless $envelope;

  my $jsonld = $self->_extract_jsonld($envelope);
  return unless $jsonld && ref($jsonld) eq 'HASH';

  return $self->normalize_jsonld($jsonld);
}

sub from_object {
  my ($self, $c, $pid) = @_;
  return unless $pid;

  require PhaidraAPI::Model::Jsonld;
  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $r = $jsonld_model->get_object_jsonld_parsed($c, $pid);
  return unless $r && ($r->{status} // 0) eq 200;

  return $self->normalize_jsonld($r->{'JSON-LD'});
}

sub normalize_jsonld {
  my ($self, $jsonld) = @_;
  $jsonld //= {};

  return {
    object_type => $self->_concept_ids($jsonld->{'edm:hasType'}),
    license     => $self->_literals($jsonld->{'edm:rights'}),
  };
}

sub _request_envelope {
  my ($self, $c) = @_;

  my $metadata = $c->param('metadata');
  if (defined $metadata) {
    if (ref $metadata eq 'Mojo::Upload') {
      $metadata = $metadata->asset->slurp;
    }
    if (!ref $metadata) {
      eval { $metadata = decode_json(b($metadata)->encode('UTF-8')) };
      return if $@;
    }
    return $metadata if ref $metadata eq 'HASH';
  }

  my $json = eval { $c->req->json };
  return $json if ref $json eq 'HASH';
  return;
}

sub _extract_jsonld {
  my ($self, $envelope) = @_;

  return $envelope->{'json-ld'}  if ref $envelope->{'json-ld'} eq 'HASH';
  return $envelope->{'JSON-LD'}  if ref $envelope->{'JSON-LD'} eq 'HASH';

  my $inner = $envelope->{metadata};
  if (ref $inner eq 'HASH') {
    return $inner->{'json-ld'} if ref $inner->{'json-ld'} eq 'HASH';
    return $inner->{'JSON-LD'} if ref $inner->{'JSON-LD'} eq 'HASH';
  }

  return $envelope if exists $envelope->{'edm:hasType'} || exists $envelope->{'edm:rights'};
  return;
}

sub _concept_ids {
  my ($self, $nodes) = @_;
  my @ids;
  for my $node ($self->_as_list($nodes)) {
    if (!ref $node) {
      push @ids, $node if defined $node && $node ne '';
      next;
    }
    next unless ref $node eq 'HASH';
    push @ids, $self->_as_list($node->{'skos:exactMatch'});
    push @ids, $node->{'@id'} if $node->{'@id'};
  }
  return [ grep { defined && $_ ne '' } @ids ];
}

sub _literals {
  my ($self, $nodes) = @_;
  my @vals;
  for my $node ($self->_as_list($nodes)) {
    if (!ref $node) {
      push @vals, $node if defined $node && $node ne '';
      next;
    }
    next unless ref $node eq 'HASH';
    push @vals, $node->{'@value'} if $node->{'@value'};
    push @vals, $node->{'@id'}    if $node->{'@id'};
    push @vals, $self->_as_list($node->{'skos:exactMatch'});
  }
  return [ grep { defined && $_ ne '' } @vals ];
}

sub _as_list {
  my ($self, $val) = @_;
  return () unless defined $val;
  return @{$val} if ref $val eq 'ARRAY';
  return ($val);
}

1;
