# vim:ai

=pod

=head1 NAME

  package Util::gg1  --  simple utility functions

=cut

package Util::gg1;

use strict;

use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);
use Exporter;

$VERSION= '0.10';
@ISA= qw(Exporter);
@EXPORT_OK= qw(attach sec2hms ts_iso ts1 fisher_yates_shuffle);
%EXPORT_TAGS= ('MAIL' => [qw(attach)], 'TS' => [qw(sec2hms ts_iso ts1)], 'FYS' => [qw(fisher_yates_shuffle)]);

use POSIX qw(strftime);

=pod

=head2 attach (*F, $boundary, $filename, $heading)

print contents of $filename to filehandle *F as an attachment, using
$boundary to delimit that attachment.  $heading is used in error messages.

=cut

sub attach
{
  local *FO= shift;
  my $boundary= shift;
  my $fnm= shift;
  my $heading= shift;

  print FO "\n";
  local *FI;
  ## print " >>> attaching [$fnm]\n";
  if (open (FI, $fnm))
  { # don't write the full path name of the file in the disposition header
    my @fnm= split ('/', $fnm);
    my $f_nm= pop (@fnm);

    print FO <<EO_ATTACH;

--$boundary
Content-Type: text/plain; charset='iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="$f_nm"

EO_ATTACH

    # print FO "$heading file '$fnm':\n";
    while (<FI>) { print FO $_; }
    close (FI);
  }
  else
  {
    print FO "can't read $heading file '$fnm'!\n";
  }
  print FO "\n";

}

=pod

=head2 ($h, $m, $s)= &sec2hms ($sec);

convert time in seconds to hour, minute, seconds format

=cut

sub sec2hms
{
  my $zeit_sec= shift;

  my $sec= $zeit_sec % 60;
  $zeit_sec = ($zeit_sec - $sec) / 60;
  my $min= $zeit_sec % 60;
  my $hour= ($zeit_sec - $min) / 60;

  (wantarray) ? ($hour, $min, $sec) : sprintf ("%02d:%02d:%02d", $hour, $min, $sec);
}

=pod

=head2 ts_iso([$time])

return time in ISO format.  If no time argument is passed, time() is used.

=cut

sub ts_iso
{
  my $t= shift;
  $t= time () unless (defined ($t));
  my @t= localtime ($t);

  sprintf("%04d-%02d-%02dT%02d%02d%02d",
          $t[5]+1900, $t[4]+1, $t[3],
          $t[2], $t[1], $t[0]);
}

=pod

=head2 ts1([$time])

return time in nice format.  If no time argument is passed, time() is used.

=cut

sub ts1
{
  my $t= shift;
  $t= time () unless (defined ($t));
  return strftime("%Y-%m-%d %H:%M:%S", localtime($t));
}

# -----------------------------------------------------------------------------
# =head1 Found in /usr/libdata/perl/5.00503/pod/perlfaq4.pod
# =head2 How do I shuffle an array randomly?

# fisher_yates_shuffle( \@array ) :
# generate a random permutation of @array in place
sub fisher_yates_shuffle
{
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

1;

