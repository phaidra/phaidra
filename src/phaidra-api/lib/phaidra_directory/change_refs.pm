=head1 NAME

  change_refs

=head1 DESCRIPTION

Substitutes string values that look like __WORD1_WORD2__ with the value
of environment variable "WORD1_WORD2".

=cut

package change_refs;

use strict;

sub subenv
{
  my $s= shift;
  print __LINE__, " s=[$s]\n";

  if ($s =~ m#__([\w\d_\-]+)__#)
  {
    my $env_name= $1;
    if (exists($ENV{$env_name})) { return $ENV{$env_name} }
    else
    {
      print STDERR "ATTN: no env var $env_name\n";
    }
  }

  $s;
}

sub change_refs
{
  my $r= shift;

  my $x_ref= ref($r);
  if ($x_ref eq 'ARRAY')
  {
    my $highest_index= $#$r;
    # print __LINE__, " highest index=[$highest_index] ", main::Dumper($r);
    for (my $i; $i <= $#$r; $i++)
    {
      if (ref($r->[$i]) eq '') { $r->[$i] =~ s#(__[^_]+(_[^_]+)*__)#subenv($1)#ge }
      else { change_refs($r->[$i]); }
    }
  }
  elsif ($x_ref eq '')
  {
  }
  else # e.g. HASH
  {
    foreach my $k (keys %$r)
    {
      my $x= ref($r->{$k});
      # print __LINE__, " k=[$k] x=[$x]\n";
      if ($x eq '')
      {
        $r->{$k}=~ s#(__[^_]+(_[^_]+)*__)#subenv($1)#ge;
      }
      else { change_refs($r->{$k}) }
    }
  }
}

1;

__END__

=head1 AUTHOR

  Gerhard Gonter <ggonter@gmail.com>

=head1 BUGS

Most likely, this is full of bugs.

=cut
