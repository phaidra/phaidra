
package Util::JSON;

use strict;

BEGIN {
  eval {
    require File::Slurper;

    *read_text=  *File::Slurper::read_text;
    *write_text= *File::Slurper::write_text;
  };

  if ($@)
  {
    print STDERR "defining read_text ourselves\n";
    *read_text=  *x_read_text;
    *write_text= *x_write_text;
  }
}

use JSON -convert_blessed_universally;

sub read_json_file
{
  my $fnm= shift;

  # BEGIN load JSON data from file content
  # print "reading config [$fnm]\n";

  # decode_json( $json_text ); # for some reason, decode_json() barfs when otherwise cleanly read wide characters are present

  my $json_text;
  eval
  {
    $json_text= read_text($fnm);
  };

  if ($@ || !defined ($json_text))
  {
    return undef;
  }

  from_json($json_text);
}

sub write_json_file
{
  my $json_fnm= shift;
  my $x= shift;

  print "json_fnm=[$json_fnm]\n";
  # print "x: ", main::Dumper ($x);

  my $json= new JSON;
  my $json_str= $json->allow_blessed->convert_blessed->encode($x);

=begin comment

  open (J, '>:utf8', $json_fnm) or die ("can not write to [$json_fnm]; caller:", join (' ', caller()));
  syswrite (J, $json_str);
  close (J);

=end comment
=cut

  write_text($json_fnm, $json_str);

  1;
}

=head2 my $cfg_item= get_config_item ($cfg, $item)



=cut

sub get_config_item
{
  my $cfg= shift;
}

sub x_read_text
{
  my $fnm= shift;

  open( my $fh, '<:utf8', $fnm ) or return undef;
  local $/;
  my $json_text   = <$fh>;
  close ($fh);

  $json_text;
}

sub x_write_text
{
  my $json_fnm= shift;
  my $json_str= shift;

  open (J, '>:utf8', $json_fnm) or die ("can not write to [$json_fnm]");
  syswrite (J, $json_str);
  close (J);
}


1;

__END__

=head1 DEPENDENCIES

=head2 Ubuntu

sudo apt-get install libjson-perl libjson-xs-perl libfile-slurper-perl

=head1 AUTHOR

Gerhard Gonter <ggonter@cpan.org>

