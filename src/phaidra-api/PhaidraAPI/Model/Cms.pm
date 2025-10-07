package PhaidraAPI::Model::Cms;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;

sub get_template {

  my $self = shift;
  my $c = shift;
  my $templateName = shift;

  my $template = $c->mongo->get_collection('cmstemplates')->find_one({ templateName => $templateName });
  return $template;
}

sub get_all_templates {
  my $self = shift;
  my $c = shift;
  my $cursor = $c->mongo->get_collection('cmstemplates')->find();
  my @templates = $cursor->all;
  return \@templates;
}

1;
__END__