#
# $Id: event_log.pm,v 1.1 2010/06/10 05:41:05 gonter Exp $
#

package Util::event_log;

use strict;
use LWP::Simple;

sub new
{
  my $cl= shift;
  my %par= @_;

  my $obj= { };
  bless $obj, $cl;

  foreach my $par (keys %par)
  {
    $obj->{$par}= $par{$par};
  }
  $obj;
}

sub report
{
  my $obj= shift;
  my %par= @_;

  my ($url, $comments, $status)= map { $par{$_} || $obj->{$_} } qw(url comments status);
  # $comments=~ s/ /+/g;

  my @par= map { $_ .'='. ($par{$_} || $obj->{$_})  } qw(who where what status);
  push (@par, 'comments=' . $comments);
  $url .= '?' . join ('&',  @par);
  # print ">>> URL='$url'\n";

  use LWP::Simple;
  my $content = get($url);
  print STDERR "Couldn't get '$url'!", "\n" unless defined $content;
  ## print $content, "\n";
  1;
}

1;
