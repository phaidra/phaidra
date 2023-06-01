package PhaidraAPI::Controller::Relationships;

use strict;
use warnings;
use v5.10;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Fedora;
use base 'Mojolicious::Controller';

sub get {
  my $self = shift;

  my $pid = $self->stash('pid');
  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $res = {alerts => [], status => 200};

  my %rels;

  if ($self->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $fres         = $fedora_model->getObjectProperties($self, $pid);
    if ($fres->{status} ne 200) {
      return $fres;
    }

    if ($fres->{references}) {
      for my $v (@{$fres->{references}}) {
        push @{$rels{references}}, $v;
      }
    }
    if ($fres->{isbacksideof}) {
      for my $v (@{$fres->{isbacksideof}}) {
        push @{$rels{isbacksideof}}, $v;
      }
    }
    if ($fres->{isthumbnailfor}) {
      for my $v (@{$fres->{isthumbnailfor}}) {
        push @{$rels{isthumbnailfor}}, $v;
      }
    }
    if ($fres->{hassuccessor}) {
      for my $v (@{$fres->{hassuccessor}}) {
        push @{$rels{hassuccessor}}, $v;
      }
    }
    if ($fres->{isalternativeformatof}) {
      for my $v (@{$fres->{isalternativeformatof}}) {
        push @{$rels{isalternativeformatof}}, $v;
      }
    }
    if ($fres->{isalternativeversionof}) {
      for my $v (@{$fres->{isalternativeversionof}}) {
        push @{$rels{isalternativeversionof}}, $v;
      }
    }
    if ($fres->{isinadminset}) {
      for my $v (@{$fres->{isinadminset}}) {
        push @{$rels{isinadminset}}, $v;
      }
    }
    if ($fres->{haspart}) {
      for my $v (@{$fres->{haspart}}) {
        push @{$rels{haspart}}, $v;
      }
    }
    if ($fres->{hasmember}) {
      for my $v (@{$fres->{hasmember}}) {
        push @{$rels{hasmember}}, $v;
      }
    }
    if ($fres->{hastrack}) {
      for my $v (@{$fres->{hastrack}}) {
        push @{$rels{hastrack}}, $v;
      }
    }
    if ($fres->{sameAs}) {
      for my $v (@{$fres->{sameAs}}) {
        push @{$rels{owl_sameas}}, $v;
      }
    }
  } else {

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

    my $relsExt     = $datastreams{'RELS-EXT'}->find('foxml\:xmlContent')->first;

    my $index_model = PhaidraAPI::Model::Index->new;
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
  }

  $res->{relationships} = \%rels;

  $self->render(json => $res, status => $res->{status});
}

1;
