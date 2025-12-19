package Util::JSON_Debug;

use strict;

use JSON -convert_blessed_universally;
use Util::hexdump;

sub read_json_file
{
  my $fnm= shift;

  # BEGIN load JSON data from file content
  local $/;
  # print "reading config [$fnm]\n";
  open( my $fh, '<:utf8', $fnm ) or return undef;
  my $json_text   = <$fh>;
  close ($fh);

  my $json;
  eval
  {
    $json= decode_json( $json_text );
  };
  if ($@)
  {
    my $e= $@;
    print "Error: [$e]\n";

    if ($e =~ m#malformed UTF-8 character in JSON string, at character offset (\d+)#)
    {
      my $pos= $1;
      my $start= 0x100 * int ($pos/0x100);
      my $off= $pos-$start;
      printf ("pos=%d 0x%04x start=0x%04x off=0x%04x\n", $pos, $pos, $start, $off);
      my $data= substr ($json_text, $start, 0x200);
      hexdump ($data);
    }
  }

  $json;
}


1;

__END__

=head1 AUTHOR

Gerhard Gonter <ggonter@cpan.org>

