package PhaidraAPI::Controller::Relationships;

use strict;
use warnings;
use v5.10;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Index;
use base 'Mojolicious::Controller';

sub get {
  my $self = shift;

  my $pid = $self->stash('pid');
  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $res = {alerts => [], status => 200};

  $self->app->log->debug("get_rels_ext $pid: getting foxml");

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r_oxml       = $object_model->get_foxml($self, $pid);
  if ($r_oxml->{status} ne 200) {
    return $r_oxml;
  }
  $self->app->log->debug("get_rels_ext $pid: parsing foxml");
  my $dom = Mojo::DOM->new();
  $dom->xml(1);
  $dom->parse($r_oxml->{foxml});
  $self->app->log->debug("get_rels_ext $pid: foxml parsed!");

  my %datastreams;
  for my $e ($dom->find('foxml\:datastream')->each) {
    my $dsid = $e->attr('ID');
    if ($dsid eq 'RELS-EXT') {
      my $latestVersion = $e->find('foxml\:datastreamVersion')->first;
      for my $e1 ($e->find('foxml\:datastreamVersion')->each) {
        if ($e1->attr('CREATED') gt $latestVersion->attr('CREATED')) {
          $latestVersion = $e1;
        }
      }
      $datastreams{$dsid} = $latestVersion;
    }
  }

  my $index_model = PhaidraAPI::Model::Index->new;
  my $relsExt     = $datastreams{'RELS-EXT'}->find('foxml\:xmlContent')->first;

  my %rels;
  my $r_relsext = $index_model->_index_relsext($self, $datastreams{'RELS-EXT'}->find('foxml\:xmlContent')->first, \%rels);
  if ($r_relsext->{status} ne 200) {
    push @{$res->{alerts}}, {type => 'error', msg => "Error indexing RELS-EXT for $pid"};
    push @{$res->{alerts}}, @{$r_relsext->{alerts}} if scalar @{$r_relsext->{alerts}} > 0;
  }

  if (exists($rels{'cmodel'})) {
    delete $rels{'cmodel'};
  }
  if (exists($rels{'dc_identifier'})) {
    delete $rels{'dc_identifier'};
  }

  $res->{relationships} = \%rels;

  $self->render(json => $res, status => $res->{status});
}

1;
