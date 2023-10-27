
package Util::HTML::toc;

use strict;

sub new
{
  my $class= shift;
  my %obj= @_;

  my $obj= \%obj;
  bless $obj, $class;
  $obj->{'columns'}= 5 unless (exists ($obj{'columns'}));

  $obj;
}


sub print_grid
{
  my $obj= shift;
  my $fnm= shift;

  open (FO, '>:utf8', $fnm) or die "can't write to [$fnm]";
  print "writing grid to '$fnm'\n";

  print FO <<EO_HTML;
<html>
<body>
<table>
EO_HTML

  my $cols= $obj->{'columns'};
  my $col= 0;
  my $tr_open= 0;
  foreach my $pic (@{$obj->{'pics'}})
  {
    if ($col == 0)
    {
      print FO <<EO_HTML;
<tr>
EO_HTML
      $tr_open= 1;
    }

    my ($dst, $tn, $num)= map { $pic->{$_} } qw(img tn num);
    print FO <<EO_HTML;
  <td>
     <a href="$dst"><img src="$tn" /><br />$num</a>
  </td>
EO_HTML

    $col++;
    if ($col >= $cols)
    {
      print FO <<EO_HTML;
</tr>
EO_HTML
      $col= 0;
      $tr_open= 0;
    }
  }

    if ($tr_open)
    {
      print FO <<EO_HTML;
</tr>
EO_HTML
      $col= 0;
      $tr_open= 0;
    }

  print FO <<EO_HTML;
</table>
</body>
</html>
EO_HTML
  close (FO);

}

1;

