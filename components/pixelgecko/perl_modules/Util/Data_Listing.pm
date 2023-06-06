
package Util::Data_Listing;

use strict;

sub new
{
  my $class= shift;
  bless [], $class;
}

sub read
{
  my $self= shift;
  my $fnm= shift;

  open (FI, '<:utf8', $fnm) or die "can't read [$fnm]";
  my $rec= undef;
  my $lnr= 0;
  while(<FI>)
  {
    chop;
    $lnr++;
    # print __LINE__, " $lnr=[$_]\n";
    if (m#^\*+ (\d+)\. row \*+$#              # MySQL \G
        || m#^-+\[ RECORD (\d+) \][\-\+]+$#   # PostgreSQL \x
       )
    {
      my $num= $1;
      push(@$self, $rec) if (defined($rec));
      $rec= { _record => $num, _file => $fnm };
    }
    elsif (m#^$#) {} # ignore empty lines
    elsif (defined ($rec))
    {
      if (m#^\s*([^:]+): (.*)#          # MySQL \G
          || m#^([^ ]+) *\| (.*)#       # PostgreSQL \x
         )
      {
        $rec->{$1}= $2;
      }
      else
      {
        die "invalid format";
      }
    }
    else
    {
      die "no record defined";
    }
  }
  push(@$self, $rec) if (defined($rec));
  close(FI);
}

1;

