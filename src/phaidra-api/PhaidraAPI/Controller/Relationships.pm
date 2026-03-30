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

  $res->{relationships} = \%rels;

  $self->render(json => $res, status => $res->{status});
}

1;
