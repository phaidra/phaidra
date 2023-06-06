
# TODO: rename the package! it is very much related to how Aleph works!

package Util::XML::File;

use strict;

# use XML::Simple;
use XML::LibXML::Simple;

my $DEBUG= 0;

sub fetch
{
  my $ua= shift;
  my $url= shift;
  my $cache_file= shift;
  my $max_age= shift;

  my ($xmlref, $xml);
  my $use_cache_file= 0;

  if (defined ($cache_file)
      && -f $cache_file
      # TODO: check age too!
     )
  {
    $use_cache_file= 1;

    if (defined ($max_age))
    {
      my @st= stat $cache_file;
      $use_cache_file= 0 if ($st[9] + $max_age <= time ());
print __FILE__, ' ', __LINE__, " cache: mtime=$st[9] max_age=$max_age use=$use_cache_file file=[$cache_file]\n";
    }
  }

  if ($use_cache_file)
  {
    open (FI, '<:utf8', $cache_file);
    while (<FI>) { $xml .= $_ };
    close (FI);

    $xmlref= XMLin($xml, ForceContent => 1, ForceArray => 1);

    # TODO: if the file is not ok, ignore the cached file and refetch
    return ($xmlref, $xml);
  }

  print __LINE__, " fetch_xml_file: url=[$url]\n";
  my $res= $ua->get ($url);

  unless ($res->is_success)
  {
    print "ERROR: Aleph-XML-Query (find) failed: ", $res->status_line, "\n";
    return undef;
  }

  $xml= $res->decoded_content;
print __LINE__, " fetch: xml=[$xml]\n" if ($DEBUG > 0);

  if (defined ($cache_file))
  {
    if (open (FO, '>:utf8', $cache_file))
    {
      print "saving to [$cache_file]\n";

      # TODO: this is specific to Aleph!
      $xml=~ s#<session-id>[\w\d]+</session-id>#<session-id>dummy-session-id</session-id>#;

      print FO $xml;
      close (FO);
     }
     # TODO: else report that we can not write to the cache as we should
  }

  $xmlref= XMLin ($xml, ForceContent => 1, ForceArray => 1, KeyAttr => [ ] );
print __LINE__, " xmlref: ", main::Dumper ($xmlref) if ($DEBUG > 0);

  return ($xmlref, $xml);
}

sub save
{
  my $fnm= shift;
  my $xml= shift;

  unless (open (XML, '>:utf8', $fnm))
  {
    print "ATTN: can't write to fnm=[$fnm]";
    return undef;
  }

  print "saving xml to $fnm\n";
  print XML $xml;
  close (XML);

  1;
}

1;


