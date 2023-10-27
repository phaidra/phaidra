# $Id: ts.pm,v 1.5 2014/12/31 03:35:34 gonter Exp $

use strict;

package Util::ts;

use vars qw(@ISA @EXPORT);
require Exporter;

@ISA= qw(Exporter);
@EXPORT= qw(ts ts_date ts_ISO ts_ISO_gmt ts_ISO2_gmt ts_pg);

sub ts
{
  my $time= shift || time ();
  my @ts= localtime ($time);
  sprintf ("%4d-%02d-%02d %02d:%02d:%02d",
           $ts[5]+1900, $ts[4]+1, $ts[3], $ts[2], $ts[1], $ts[0]);
}

sub ts_date
{
  my $time= shift || time ();
  my @ts= localtime ($time);
  sprintf ("%4d-%02d-%02d", $ts[5]+1900, $ts[4]+1, $ts[3]);
}

sub ts_gmdate
{
  my $time= shift || time ();
  my @ts= gmtime ($time);
  sprintf ("%4d-%02d-%02d", $ts[5]+1900, $ts[4]+1, $ts[3]);
}

sub ts_ISO
{
  my $time= shift || time ();
  my @ts= localtime ($time);
  sprintf ("%04d%02d%02dT%02d%02d%02d",
           $ts[5]+1900, $ts[4]+1, $ts[3], $ts[2], $ts[1], $ts[0]);
}

sub ts_ISO2_gmt
{
  my $time= shift || time ();
  my @ts= gmtime ($time);
  sprintf ("%04d-%02d-%02dT%02d:%02d:%02d.000Z",
           $ts[5]+1900, $ts[4]+1, $ts[3], $ts[2], $ts[1], $ts[0]);
}

sub ts_ISO3_gmt
{
  my $time= shift || time ();
  my @ts= gmtime ($time);
  sprintf ("%04d-%02d-%02dT%02d:%02d:%02dZ",
           $ts[5]+1900, $ts[4]+1, $ts[3], $ts[2], $ts[1], $ts[0]);
}

sub ts_ISO_gmt
{
  my $time= shift || time ();
  my @ts= gmtime ($time);
  sprintf ("%04d-%02d-%02dT%02d%02d%02d",
           $ts[5]+1900, $ts[4]+1, $ts[3], $ts[2], $ts[1], $ts[0]);
}

sub ts_pg
{
  my $time= shift || time ();
  my $tzo= shift || 1;

  my @ts= localtime ($time);
  sprintf ("%4d-%02d-%02d %02d:%02d:%02d+%02d",
           $ts[5]+1900, $ts[4]+1, $ts[3], $ts[2], $ts[1], $ts[0],
           $tzo + (($ts[8]) ? 1 : 0));
}

1;

