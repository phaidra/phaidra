#!/usr/bin/perl
# $Id: Linux_lvm.pm,v 1.1 2014/01/02 11:25:33 gonter Exp $

=pod

=head1 NAME

chfs.pl  --  change filesystem properties

=head1 USAGE

chfs.pl -a size=+I<n>I<S> F<path>

Write the commands necessary to expand the filesystem F<path> by adding
I<n> units of I<S> (K, M, G, T) bytes (1K= 1024 bytes).

=cut

package Util::Linux_lvm;

use strict;

use Data::Dumper;
$Data::Dumper::Indent= 1;

my @paths= qw(/usr/sbin /sbin);

my @caller= caller ();
# print "caller=[",join (':', @caller),"]\n";
# __PACKAGE__->main if (!defined (@caller) || ($caller[0] eq 'main' && $caller[1] eq '-'));
__PACKAGE__->main unless (@caller);
__PACKAGE__->test if (($caller[0] eq 'main' && $caller[1] eq '-'));

sub new
{
  my $class= shift;
  bless {}, $class;
}

sub test
{
  print Dumper (\%main::);
}

sub main
{
  my @pgm= split ('/', $0);
  my $pgm= pop (@pgm);

  # print "b=[", $pgm, "]\n";

     if ($pgm eq 'chfs')    { main_fs1 ('chfs'); }
  elsif ($pgm eq 't_df')    { test_df (); }
  elsif ($pgm eq 't_mount') { test_mount (); }
  elsif ($pgm eq 't_gg1')   { test_gg1 (); }
  elsif ($pgm eq 'tunefs')  { main_tunefs (); }
  else { &usage; }
}

sub test_mount
{
  my $fs= &get_mount ();
  print 'fs=', Dumper ($fs), "\n";
}

sub test_df
{
  my $fs= &get_df ();
  print 'fs=', Dumper ($fs), "\n";
}

sub test_gg1
{
  my $fs= new Util::Linux_lvm;
  $fs->get_mount ();
  $fs->get_df ();
  print "fs=[$fs]: ", Dumper ($fs), "\n";
}

sub main_tunefs
{
  my @PARS;
  while (defined (my $arg= shift (@ARGV)))
  {
      push (@PARS, $arg);
  }

  foreach my $fs_name (@PARS)
  {
    my $x= get_tunefs ($fs_name);
print "tunefs: ", Dumper ($x);
  }
}

sub main_fs1
{
  my $pgm= shift;

  my @PARS;
  my $attr= ();
  while (defined (my $arg= shift (@ARGV)))
  {
    if ($arg =~ /^-/)
    {
      if ($arg eq '-a')
      {
        my ($an, $av)= split ('=', shift (@ARGV), '2');
        $attr->{$an}= $av;
      }
    }
    else
    {
      push (@PARS, $arg);
    }
  }

  my $fs= &get_mount ();
  ## print 'fs=', Dumper ($fs), "\n";
  ## print 'attr=', Dumper ($attr), "\n";

  my $fs_name= shift (@PARS) or &usage ('no fs name');

  my $fs_p= $fs->{$fs_name};

  if ($pgm eq 'chfs') { &chfs ($fs_p, $attr); }

  return 0;
}

sub usage
{
  my $msg= shift;
  print $msg, "\n";
  print <<EOX;
usage: $0 -a attr=value filesystem

attribs:
size=+3G

Examples:
  chfs.pl -a size=+5g /bla
EOX
  exit;
}

sub chfs
{
  my $fs_p= shift or &usage ('unknown fs');;
  my $attr= shift;

  if (exists ($attr->{'size'}))
  {
    my $sz= $attr->{'size'};
    if ($sz =~ /^\+?(\d+)[GM]$/)
    {
      my $dv= $fs_p->{'dev'};
      my $ty= $fs_p->{'type'};
      # hmm: /dev/mapper/uservg-user3lv
      my $lv_name;

      if ($dv =~ m#/dev/mapper/([\w]+)-([\w]+)$#)
      {
        my ($vg, $lv)= ($1, $2);
        $lv_name= join ('/', '/dev', $vg, $lv);
      }
      elsif ($dv =~ m#/dev/mapper/(base--os)-([\w]+)$#)
      {
        my ($vg, $lv)= ('base-os', $2); # Ubuntu :-/
        $lv_name= join ('/', '/dev', $vg, $lv);
        # TODO: is there a general rule about this name scheme?
      }
      else
      {
        print "device name '$dv' not recognized!\n";
        exit (1);
      }

      my $c1= &locate_binary ('lvextend') . " -L '$sz' '$lv_name'";
      my $c2;
      if ($ty eq 'ext3' || $ty eq 'ext4')
      {
        $c2= &locate_binary ('resize2fs') . " -p '$lv_name'";
      }
      elsif ($ty eq 'xfs')
      {
        $c2= &locate_binary ('xfs_growfs') . " '$lv_name'";
      }
      else
      {
        print "unknown filesystem type '$ty' for '$dv'\n";
        exit (3);
      }

      print "# perform these commands:\n";
      print $c1, "\n";
      print $c2, "\n";
    }
    else
    {
      &usage ("size not known '$sz'");
    }

  }
}

sub get_mount
{
  my $self= shift;
  $self= {} unless (defined ($self));

  my @mount= split (/\n/, `/bin/mount`);
  my %fs= ();
  foreach my $l (@mount)
  {
    ## print "# >>> l='$l'\n";

# /dev/mapper/uservg-user0lv on /u/user0 type ext3 (rw,_netdev,acl,usrquota,grpquota)
    if ($l =~ /^(\S+)\s+on\s+(.+)\s+type\s+(\S+)\s+\(([^)]+)\)$/)
    {
      my ($dev, $fs, $ty, $opts)= ($1, $2, $3, $4);
      my @opts= split (/,/, $opts);
      $self->{$fs}=
      {
        'dev'  => $dev,
        'fs'   => $fs,
        'type' => $ty,
        'opts' => \@opts,
      };
    }

  }

  $self;
}

sub get_df
{
  my $self= shift;
  $self= {} unless (defined ($self));

  my @df= split (/\n/, `/bin/df`);
  my @hdr= split (' ', shift (@df));

  my $key= undef;
  if ($hdr[-2] eq 'Mounted' && $hdr[-1] eq 'on') { splice (@hdr,-2,2,'fs'); $key= @hdr-1; }
  if ($hdr[0] eq 'Filesystem') { $hdr[0]= 'dev'; }

  unless (defined ($key))
  {
    print "key not defined\n";
    print "hdr: ", Dumper (\@hdr);
    return undef;
  }
  my $num_fields= @hdr;

  foreach my $l (@df)
  {
    my @f= split (' ', $l, $num_fields); # let's hope there are not too many blanks...
    my $x= $self->{$f[$key]};
    $x= $self->{$f[$key]}= {} unless (defined ($x));
    for (my $i= 0; $i < $num_fields; $i++)
    {
      $x->{$hdr[$i]}= $f[$i];
    }
  }
  
  $self;
}

sub get_tunefs
{
  my $fsdev= shift;

  my @cmd= ('/sbin/tune2fs', '-l', $fsdev);
  print "get_tunefs: ", Dumper (\@cmd);
  my @res= split ("\n", `@cmd`);
  my $res=
  {
    'version' => shift (@res),
    'pars' => my $p= {},
  };

  foreach my $l (@res)
  {
    if ($l =~ /^([\w][\w ]+):\s+(.+)/)
    {
      my ($an, $av)= ($1, $2);
      if ($an =~ m#Reserved blocks (gid|uid)#)
      {
        my $id= $1;

        if ($av =~ m#(\d+)\s+\((user|group)\s+([^)]+)\)#)
	{
          $av= { $id => $1, 'what' => $2, 'name' => $3 }; # TODO: "what" is not a good attribute name
	}
      }
      $p->{$an}= $av;
    }
    else
    {
      print "unknown line format: [$l]\n";
    }
  }

  $res;
}

sub locate_binary
{
  my $cmd= shift;

  foreach my $path (@paths)
  {
    my $bin= join ('/', $path, $cmd);
    return $bin if (-x $bin);
  }

  print "$cmd not found\n";
  exit (1);
  # return undef;
}

1;

__END__

=pod

=head1 TODO

=head2 VG names

Ubuntu uses a VG named "F<base-os>" for the volume group where it's root
filesystem resides.  In the F</dev/mappper/> directory, this becomes
"F<base--os>".  Is this generally handled this way?  If so, the matching
pattern needs to be modified.

=head2 doit

The script should possibly really perform the steps in a controlled
manner.

=head1 BUGS

This wasn't meant to be nice.

