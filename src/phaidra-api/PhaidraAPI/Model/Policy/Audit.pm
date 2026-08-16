package PhaidraAPI::Model::Policy::Audit;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::JSON qw(encode_json true false);
use Data::UUID;

sub log {
  my ($self, $c, $input, $decision) = @_;

  my $audit_cfg = $c->app->config->{opa}->{audit} // {};
  unless ($audit_cfg->{enabled} // 1) {
    return;
  }

  my $obligations = $decision->{obligations} // {};
  # Rego can set obligations.audit=false to skip PEP audit for selected paths
  if (ref($obligations) eq 'HASH' && exists($obligations->{audit}) && !$obligations->{audit}) {
    $c->app->log->debug(
      'authz=1 skipped (obligations.audit=false) action['
        . ($input->{action}->{id} // '')
        . '] pid['
        . ($input->{resource}->{pid} // '')
        . ']'
    );
    return;
  }

  my $decision_id = eval {
    my $ug = Data::UUID->new;
    lc($ug->create_str());
  };
  $decision_id = sprintf('%d-%d', time, int(rand(1_000_000))) if $@ || !$decision_id;

  my $entry = {
    event          => 'authz_decision',
    decision_id    => $decision_id,
    allow          => $decision->{allow} ? true : false,
    reason         => $decision->{reason} // '',
    subject        => $input->{subject}->{username} // '',
    remote_address => $input->{subject}->{remote_address} // $input->{environment}->{remote_address} // '',
    resource       => $input->{resource}->{pid} // '',
    dsid           => $input->{resource}->{dsid} // '',
    action         => $input->{action}->{id} // '',
    source         => $decision->{source} // 'opa',
    policy_version => $c->app->config->{opa}->{policy_version} // '',
    duration_ms    => $decision->{duration_ms} // 0,
  };

  if (exists $decision->{capabilities}) {
    $entry->{capabilities} = $decision->{capabilities};
  }
  if (exists $decision->{forms}) {
    $entry->{forms} = $decision->{forms};
  }

  # Structured JSON in phaidra-api logs (grep authz=1)
  $c->app->log->info('authz=1 ' . encode_json($entry));

  return $decision_id;
}

1;
