# $Id: hexdump.pm,v 1.3 2016/01/03 16:13:16 gonter Exp $

use strict;

package Util::hexdump;

use vars qw(@ISA @EXPORT);
require Exporter;

@ISA= qw(Exporter);
@EXPORT= qw(hexdump);

# ----------------------------------------------------------------------------
sub hexdump
{
  my $data= shift;
  local *FX= shift || *STDOUT;

  my $off= 0;
  my ($i, $c, $v);

  my $run= 1;
  my $dl= length ($data);
  DATA: while ($run)
  {
    my $char= '';
    my $hex= '';
    my $offx= sprintf ('%08X', $off);

    BYTE: for ($i= 0; $i < 16; $i++)
    {
      $hex .= ' ' if ($i == 8);

      if ($off+$i < $dl)
      {
        $c= substr ($data, $off+$i, 1);

        if (defined ($c) && $c ne '')
        {
          $v= unpack ('C', $c);
          $c= '.' if ($v < 0x20 || $v >= 0x7F);

          $char .= $c;
          $hex .= sprintf (' %02X', $v);
          next BYTE;
        }
      }

      $char .= ' ';
      $hex  .= '   ';
      $run= 0;
    }

    print FX "$offx $hex  |$char|\n";

    $off += 0x10;
  }
}

1;

