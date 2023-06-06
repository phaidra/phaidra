#
# $Id: LibXML.pm,v 1.1 2013/09/06 13:27:28 gonter Exp $
# $URL: $
#

package Util::LibXML;

use strict;

# implicitly use XML::LibXML;

=pod

=head2 extend_xml_doc ($doc, $element, $structure)

extend $element (an instance of XML::LibXML::Element(?)) in the context
of $doc (an instance of XML:LibXML::Document(?)) with XML elements
defined in $structure, such as:

$structure=
  [
    {
      'tag' => 'stuff',
      'chld' =>
      [
        { 'tag' => 'undef', 'text' => undef, }, # this will not be generated!
        { 'tag' => 'empty', 'text' => '', },    # this will be an empty element: <empty />
      ],
    },
    'bli',
    {
     'tag' => 'chapter',
     'chld' =>
      [
        { 'tag' => 'h1', 'text' => 'chapter 1', 'attr' => { 'id' => 1 },
	  'chld' =>
	[
	  { 'tag' => 'p',
	    'chld' =>
	    [
              'part 1 of chapter 1',
              'part 2 of chapter 1',
	      { 'tag' => 'h2', 'attr' => { 'id' => 2 }, 'text' => 'chapter 1.2', 'chld' => [ 'just a short text in chapter 1.2' ] },
	    ]
	  }
	]
	}
      ]
    },
    { 'tag' => 'chapter', 'chld' => [ { 'tag' => 'h1', 'text' => 'chapter 2',}, {'tag' => 'p', 'chld' => [ 'short chapter 2a text', '2b text', ] } ] },
    { 'tag' => 'chapter', 'chld' => [ { 'tag' => 'h1', 'text' => 'chapter 3' }, {'tag' => 'p', 'text' => 'short chapter 3 text' } ] },
  ];
TODO: extract this function into an utility module

=cut

sub extend_xml_doc
{
  my $doc= shift; # XML::LibXML::Document
  my $at= shift;  # XML::LibXML::Element
  my $what= shift;

  # print "extend: ", Dumper ($what);

  XML_CHILD: foreach my $c (@$what)
  {
   # print "c: ", Dumper ($c);
   if (ref ($c) eq '') # just text?
   {
     $at->addChild ($doc->createTextNode ($c));
   }
   elsif (ref ($c) eq 'HASH')
   {
    if (exists ($c->{'skip'}))
    {
     next XML_CHILD;
    }
    elsif (exists ($c->{'tag'}))
    {
      my ($has_text, $text)= (0, undef);
      if (exists ($c->{'text'}))
      {
        $has_text= 1;
        $text= $c->{'text'};
      }
      next XML_CHILD if ($has_text && !defined ($text)); # don't generate element, if text is undef!
      
      my $el= $doc->createElement ($c->{'tag'});
      # print "at=[$at] ", Dumper ($at);
      $at->addChild ($el);
      $c->{'xml'}= $el;
      
      if (exists ($c->{'attr'}))
      {
	# print "$c->{'tag'} has attributes\n";
        my $a= $c->{'attr'};
	foreach my $an (keys %$a)
	{
	  # print "an=[$an], av=[$a->{$an}]\n";
          $el->setAttribute ($an, $a->{$an});
        }
      }

      if ($has_text && $text ne '') # empty element!
      { # shorthand for one text element
        $el->addChild ($doc->createTextNode ($text));
      }

      if (exists ($c->{'chld'}))
      {
	# print "recursing on $el\n";
        &extend_xml_doc ($doc, $el, $c->{'chld'});
      }
    }
    elsif (exists ($c->{'text'}))
    { # possibly part of more than one element, this happens to be a text element
      $at->addChild ($doc->createTextNode ($c->{'text'}));
    }
   }
  }
 
  # TODO: return something meaningfull
}

1;
