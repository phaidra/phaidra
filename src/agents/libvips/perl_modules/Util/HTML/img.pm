
package Util::HTML::img;

use strict;

sub new
{
  my $class= shift;
  my %obj= @_;

  my $obj= \%obj;
  bless $obj, $class;

  $obj;
}

1;

