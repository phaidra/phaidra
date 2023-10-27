
use strict;

package Util::Mail::Processor;

my $verbose= 0;

# ----------------------------------------------------------------------
# these hosts are considered local when analyzing received lines
my %IP_HOP_OK=
(
  '127.0.0.1' => 'localhost',
);

my $mon= 0;
my %MON= map { $_ => $mon++ } qw(jan feb mar apr may jun jul aug sep oct nov dec);

# ----------------------------------------------------------------------
my %IMAGE_EXT= map { $_ => 1 } qw(jpg jpeg pjpeg gif tif tiff bmp NONE);
my %AUDIO_EXT= map { $_ => 1 } qw(mp3);
my %VIDEO_EXT= map { $_ => 1 } qw(mpeg mpg avi);

# ----------------------------------------------------------------------
my %ANTIVIR_FNM= map { $_ => 1 }
qw(antivir.vdf ave32.exe avfile.hlp avgctrl.exe avgctrl.hlp avguard.log
   avrep32.exe avrep32.gid avrep32.hlp avrep32.ini avsched32.dat
   avsched32.exe avsched32.gid avsched32.hlp avsched32.ini avwin.act
   avwin.log avwin95.exe avwin95.fts avwin95.gid avwin95.hlp avwin95.ini
   avwin9xp.exe display.spw display.win faqpe_de.htm ftpdlvdf.$$$
   hbedv.key inetupd.alg inetupd.exe inetupd.ini inetupd.log liesmich.wri
   lizenz.wri savedvdf.$$$ service.ini suppcoll.exe uninst.isu uninst.txt
   virinfo.gid virinfo.hlp
  );

my %VIRUSES= map { $_ => 1 }
qw(CFGWIZ32.EXE ARP.EXE IDLE31.EXE IDLE32.EXE DISCOVER.EXE SYSOCMGR.EXE
   DPLAYSVR.EXE SUCATREG.EXE MAKECFG.EXE MSOOBE.EXE SULFNBJ.EXE AOLTRAY.EXE
   DPLAYSVQ.EXE TASKMAN.EXE RG2CATDB.EXE ADDREG.EXE DLLHOST.EXE LGPHACLG.EXE
   SULFNBK.EXE DELPRT32.EXE START.EXE OEMRUN.EXE OCTKSTAT.EXE CCJDPHCC.EXE
   CMMON32.EXE ACTMOVIE.EXE DSSSIG.EXE
   CB31.EXE WTC.EXE NUMBER.COM
   SPALTE.EXE CONTROLFIDS.PIF AUTOMATION.BAT INFORMATIONEN.BAT UNTERNEHMEN.EXE
   VORGESCHLAGEN.COM HYPERLINK.BAT KARIN.COM LAUNCHER.COM IHRER.COM
   Q216309.EXE
  );
my %BADTRANS_part1= map { $_ => 1 }
qw(PICS IMAGES README NEW_NAPSTER_SITE NEWS_DOC HAMSTER YOU_ARE_FAT!
   SEARCHURL SETUP CARD ME_NUDE SORRY_ABOUT_YESTERDAY S3MSONG DOCS HUMOR
   FUN
);
my %BADTRANS_part2= map { $_ => 1 } qw(doc mp3 zip);
my %BADTRANS_part3= map { $_ => 1 } qw(pif scr);

# ----------------------------------------------------------------------
sub new
{
  my $class= shift;
  my $HDR=
  {
    'seq' => [],
    'name' => {},
    'parts' => [],    # list of MIME parts; these are again headers
  };
  bless $HDR, $class;
}

# ----------------------------------------------------------------------
# analyze regular mail hader as found in any mbox format mail file
sub analyze_header
{
  my $class= shift;
  my $mail= shift;   # array of mail lines

  my $HDR= new ($class);
  # print "analyze_header: class=$class mail='$mail' HDR='$HDR'\n";

  map {$HDR->{$_}= undef} qw(sender);
  $HDR->{recipients}= [];

  my $hdr_obj= undef;
  my $l;
  my $in_hdr= 1;
  my @body;
  foreach $l (@$mail)
  {
    $l=~ s/[\r\n]//g;

    unless ($in_hdr)
    {
      push (@body, $l);
      next;
    }

    if ($l =~ /^\s*$/)
    {
      $in_hdr= 0;
      $HDR->{'body'}= \@body;
      next;
    }

    # print "|o|", $l, "\n";
    if ($l =~ m#^([\w\-]+):\s*(.*)#
        || $l =~ m#^([Xx]-[\w\-\.]+):\s*(.*)#          # private headers, some contain dots
       )
    {
      my ($header_tag, $header_line)= ($1, $2);
      $header_tag =~ tr/A-Z/a-z/;
      $hdr_obj=
      {
        'tag' => $header_tag,
        'line' => $header_line,
      };
      push (@{$HDR->{seq}}, $hdr_obj);
      $HDR->{name}->{$header_tag}= $hdr_obj;

      if ($header_tag eq 'return-path')
      {
        $HDR->{sender}= ($header_line =~ /<(.+)>/) ? $1 : $header_line;
      }
    }
    elsif ($l =~ /^\s+(.+)/)
    {
      $hdr_obj->{line} .= ' '. $1;
      # print " LINE='", $hdr_obj->{line},"]\n";
    }
    else
    {
      print "ATTN: header line not parsed! [$l]\n";
    }
  }

  $HDR;
}

# ----------------------------------------------------------------------
# formerly qf_to_HDR in mqsort.pl or mqsort
sub parse_qf
{
  my ($class, $qdir, $fnm)= @_;

  my $HDR= new ($class);
  local *FI;
  open (FI, "$qdir/$fnm") || return undef;

  print "QF: $qdir/$fnm\n" if ($verbose);
  my ($sender, $last_hop_name, $last_hop_ip, $last_hop_user);
  my @recipients;
  my $lines;
  my ($header_tag, $header_line);

  my $hdr_obj;  # last header object processed;

  while (<FI>)
  {
    chop;
    $lines++;
    my $x= $_;
    $x=~ tr/A-Z/a-z/;

    if ($x =~ /^s(.*)/)
    {
      $sender= $1;
      $sender= $1 if ($sender =~ /^<(.+)>$/);
    }
    elsif ($x =~ /^t(\d+)/)
    {
      $HDR->{'TSTAMP'}= $1;
    }
    elsif ($x =~ /^r[pfd]*:(.*)/)
    {
      my $recipient= $1;
      $recipient= $1 if ($recipient =~ /^<(.+)>$/);
      push (@recipients, $recipient);
    }
    elsif ($x =~ /^\$_(.*)/)
    {
      my $last_hop= $1;
      ($last_hop_name, $last_hop_ip)= split (/\[/, $last_hop);
      ($last_hop_user, $last_hop_name)= ($1, $2) if ($last_hop_name =~ /(.+)\@(.*)/);
      $last_hop_name=~ s/\s*$//;
      $last_hop_ip=~ s/\].*$//;

      $HDR->{'last_hop_ip'}= $last_hop_ip;
      $HDR->{'last_hop_name'}= $last_hop_name;
      $HDR->{'last_hop_user'}= $last_hop_user;
    }
    elsif ($_ =~ m#^H([^:]+):\s*(.*)#)
    {
      ($header_tag, $header_line)= ($1, $2);
      $header_tag =~ tr/A-Z/a-z/;
      $hdr_obj=
      {
        'tag' => $header_tag,
        'line' => $header_line,
      };
      push (@{$HDR->{seq}}, $hdr_obj);
      $HDR->{name}->{$header_tag}= $hdr_obj;
    }
    elsif ($_ =~ /^\s+(.+)/)
    {
      $hdr_obj->{line} .= ' '. $1;
    }
  }
  close (FI);

  return undef if ($lines <= 10);

  $HDR->{'sender'}= $sender;
  $HDR->{'recipients'}= \@recipients;

  $HDR;
}

# ----------------------------------------------------------------------
sub get_field
{
  my $obj= shift;
  my $field_name= shift;

  return undef unless (exists ($obj->{'name'}->{$field_name}));
  my $m= $obj->{'name'}->{$field_name};
  return $m->{'line'};
}

# ----------------------------------------------------------------------
# returns last hop's address (see perldoc section below)
sub get_received
{
  my $obj= shift;
  my $upd= shift;

  return @{$obj->{'_first_received_'}} if (exists ($obj->{'_first_received_'}));

  my @res= qw(? ? ? ? ? ?);

  foreach my $m (@{$obj->{seq}})
  {
    if ($m->{'tag'} eq 'received')
    {
      my $rec= $m->{'line'};

      print ">>>>>>> rec='$rec'\n" if ($verbose);

#\s*\(\[([\d\.]+)\]\) by ([\w\d\.\-]+)/)
if ($rec =~ /from (\S+)\s+\(HELO ([^)]*)\)\s*\(\[([\d\.]+)\]\) \(envelope-sender ([^)]+)\) by ([\w\d\.\-]+)/)
{
  my ($rdns, $c2b, $ip, $env, $h)= ($1, $2, $3, $4);
  print ">>>>>>> MATCH! rdns='$rdns' c2b='$c2b' ip='$ip' env='$env' h='$h'\n" if ($verbose);
}

      if ($rec =~ /from (\S+)\s+\((.*)\s*\[([\d\.]+)\]\) \(authenticated bits=0\) by ([\w\d\.\-]+)/)
      {
        my ($c2b, $rdns, $ip, $h)= ($1, $2, $3, $4);

        if ($h =~ /\.wu-wien\.ac\.at$/)
        {
          my ($gate, $trid);
          if ($rec =~ /by\s+(\S+)\s+.*with E?SMTP id (\w+)/)
          {
            ($gate, $trid)= ($1, $2);
          }
          $obj->{'_SMTP_AUTH_'}= $h;

print __LINE__, " SMTP AUTH via $gate\n";
          @res= ($ip, $rdns, $c2b, $gate, $trid);
          last;
        }
      }

      if ($rec =~ /from (\S+)\s+\((.*)\s*\[([\d\.]+)\]\) by ([\w\d\.\-]+)/
          || $rec =~ /from (\S+)\s+\((.*)\s*\[([\d\.]+)\] \(may be forged\)\) by ([\w\d\.\-]+)/
         )
      {
        my ($c2b, $rdns, $ip, $h)= ($1, $2, $3, $4);
        # TODO: check for well known hosts and skip them
	      next if (exists ($IP_HOP_OK{$ip}));

        $rdns=~ s/.*\@//;
        $rdns=~ s/\s+//;
        print ">>> c2b='$c2b' rdns='$rdns' ip='$ip' h='$h'\n" if ($verbose);

        if ($rec =~ /with HTTP/ && $rdns eq '')
        { # webmail system (is it IMP ?) does not record rdns!
          $rdns= `host $ip`;
          $rdns= ($rdns =~ /(.*) is [\d\.]+/) ? $1 : '';
        }

        my ($gate, $trid);
        if ($rec =~ /by\s+(\S+)\s+.*with E?SMTP id (\w+)/)
        {
          ($gate, $trid)= ($1, $2);
        }

        my $date= '?';
        if ($rec =~ /((Mon|Tue|Wed|Thu|Fri|Sat|Sun),[^\)]+\))/)
        {
          $date= $1;
        }
# print ">>> rec='$rec'\n>>>> date='$date'\n";

        @res= ($ip, $rdns, $c2b, $gate, $trid, $date);
        last;
      }
    }
  }

  $obj->{'_first_received_'}= \@res;
  if ($upd)
  {
    $obj->{'last_hop_ip'}= $res[0];
    $obj->{'last_hop_name'}= $res[2];
  }

  return @res;
}

# ----------------------------------------------------------------------
sub is_virus_fnm
{
  my $fnm= shift;

  $fnm=~ tr/a-z/A-Z/;
  print ">> virus-fnm check: fnm='$fnm'\n";
  return 'virus' if (exists ($VIRUSES{$fnm}));

  my @fnm= split (/\./, $fnm);
  return 'virus' if (exists ($BADTRANS_part1{$fnm[0]})
                     && exists ($BADTRANS_part2{$fnm[1]})
                     && exists ($BADTRANS_part3{$fnm[2]}));

  return undef;
}

# ----------------------------------------------------------------------
sub is_virus
{
  my $obj= shift;

  my $ctdis= $obj->get_field ('content-disposition');
  my ($ext, $fnm)= &extract_file_extension ($ctdis);

  if ($ext eq 'NONE')
  {
    my $ctty= $obj->get_field ('content-type');
    ($ext, $fnm)= &extract_file_extension ($ctty);
  }

  return ('virus', $ext, $fnm) if (&is_virus_fnm ($fnm));
  return ('ok', $ext, $fnm);
}

# ----------------------------------------------------------------------
sub is_virus_boundary
{
  my $b= shift;

  return 1
    if ($b eq '==i3.9.0oisdboibsd\(\(kncd'
        || $b =~ /^--VE[A-Z\d]{33}$/  # hahaha@sexyfun.net
        || $b =~ /^--VE[A-Z\d]+$/  # Variante davon
        || $b =~ /^-+[\dA-F]+_Outlook_Express_message_boundary$/ # W32.sircam Virus
        || $b =~ /====_ABC1234567890DEF_====/   # nimda Virus/Worm
       );

  return undef;
}

# ----------------------------------------------------------------------
# this operates on header-descriptor only
sub identify_mime_part
{
  my $obj= shift;

  my $ctty= $obj->get_field ('content-type');
  return ('empty', 'empty') unless ($ctty);

  print "CTTY: ", $ctty, "\n";

  if ($ctty =~ m#multipart/#i)
  {
    if ($ctty =~ m#boundary="([^"]+)"#i
        || $ctty =~ m#boundary=([^\s]+)#i
       )
    {
      my $boundary= $1;

print ">>> boundary='$boundary'\n";
      return 'virus-check' if (&is_virus_boundary ($boundary));
      return ('multipart', $boundary);
    }
    return 'mime-error';
  }
  elsif ($ctty =~ m#application/([^;\s]+)#)
  {
    my $app_type= $1;

    my ($vx, $ext, $fnm)= &is_virus ($obj);
    return ('virus', $fnm) if ($vx eq 'virus');

    # translate some app_types
    if ($app_type eq 'octet-stream' || $app_type eq 'octetstream'
        || $app_type eq 'x-msdownload'   # ?????? T2D
       )
    {
      # Grrr!
print ">>> app_type='$app_type' ext='$ext'\n";
      return ('video', 'x-avi') if ($ext eq 'avi');
      return ('application', 'pgp-signature') if ($ext eq 'pgp');
      return ('image', 'gif') if ($ext eq 'gif');
      return ('image', 'jpeg') if ($ext eq 'jpg');
      return ('text', 'html') if ($ext eq 'htm');

      $app_type= 'x-zip-compressed' if ($ext eq 'zip');
      $app_type= 'x-pdf' if ($ext eq 'pdf');
      $fnm=~ tr/A-Z/a-z/;
      $app_type= 'x-antivir' if (exists ($ANTIVIR_FNM{$fnm})); # T2D
    }
    elsif ($app_type eq 'msword')
    {
      $app_type= 'x-rtf' if ($ext eq 'rtf');
    }

    return ('application', $app_type);
  }
  elsif ($ctty =~ m#image/([^;\s]+)#)
  { # should be ok.
    my $type= $1;

    # CHECK if filename is not compatible!
    my ($vx, $ext, $fnm)= &is_virus ($obj);
    return ('virus', $fnm) if ($vx eq 'virus');

    unless (exists ($IMAGE_EXT{$ext}))
    {
      return ('mime-fake', $fnm);
    }
    return ('image', $type);
  }
  elsif ($ctty =~ m#(audio|video)/([^;\s]+)#)
  { # should be ok.
    my ($m1, $type)= ($1, $2);
    $m1=~ tr/A-Z/a-z/;
    $type=~ tr/A-Z/a-z/;

    # CHECK if filename is not compatible!
    my ($vx, $ext, $fnm)= &is_virus ($obj);
    return ('virus', $fnm) if ($vx eq 'virus');

    return ('mime-fake', $fnm)
      unless (($m1 eq 'audio' && exists ($AUDIO_EXT{$ext}))
              || ($m1 eq 'video' && exists ($VIDEO_EXT{$ext}))
             );

    return ($m1, $type);
  }
  elsif ($ctty =~ m#(text|message)/([^;\s]+)#i)
  {
    my ($m1, $type)= ($1, $2);
    $m1=~ tr/A-Z/a-z/;
    $type=~ tr/A-Z/a-z/;
    return ($m1, $type);
  }

  return ('mime-unknown', $ctty);
}

# ----------------------------------------------------------------------
sub mime_test
{
  my $obj= shift;

  my $m= $obj->{name}->{'X-WU-MIME'};
  print ">>>>> HDR.pm(L266): m=$m\n";
  if ($m)
  {
    # my $check= $obj->{name}->{'X-WU-MIME'}->{line};
    my $check= $m->{line};
    if ($check)
    {
      print ">>>>>> check=$check\n";
      my ($res, $res2)= split (' ', $check);
      return $res2 if ($res2 eq 'mime-fake');
      return $res unless ($res eq 'ok');
    }
  }

  my $l= $obj->{parts};
  my $x;
  foreach $x (@$l)
  {
    my $res= $x->mime_test;
    return $res unless ($res eq 'ok');
  }

  return 'ok';
}

# ----------------------------------------------------------------------
sub show_structure
{
  my $obj= shift;
  my $indent= shift;

  # print "showing structure $indent $obj\n";

  my $x;
  my $l= $obj->{seq};
  foreach $x (@$l)
  {
    next if ($x->{tag} eq 'received');
    print ' 'x$indent, $x->{tag}, ': ', $x->{line}, "\n";
  }

  my $l= $obj->{parts};
  my $parts= 0;
  foreach $x (@$l)
  {
    print ' 'x$indent, "part nr.: ", ++$parts, "\n";
    $x->show_structure ($indent+2);
    print "\n";
  }
  print "\n";
}

# ----------------------------------------------------------------------
sub extract_file_extension
{
  my $disposition= shift; # Disposition header
  if ($disposition =~ /name="([^"]+)"/
      || $disposition =~ /name=([^\s]+)/
     )
  {
    my $fnm= $1;
    if ($fnm =~ /^=\?iso-8859-\d\?Q\?(.+)\?=$/)
    {
      $fnm= $1;
      $fnm=~ s/=([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
print ">>>>> translated: fnm='$fnm'\n";
    }

    my @fnm= split (/\./, $fnm);
    my $ext= pop (@fnm);
    $ext =~ tr/A-Z/a-z/;
    return ($ext, $fnm);
  }
  return ('NONE', 'NONE');
}

sub rfc822_date_localtime
{
  my $str= shift;

  if ($str =~ m#^(\w+), +(\d+) (\w+) (\d+) +(\d+):(\d+):(\d+) (\S+)$#)
  {
    my ($wday, $mday, $mon_s, $year, $hr, $min, $sec, $tz_str)= ($1, $2, $3, $4, $5, $6, $7, $8);
    $mon_s =~ tr/A-Z/a-z/;

    my $mon= $MON{$mon_s}; # TODO: don't be case sensitive!
    return ($sec, $min, $hr, $mday, $mon, $year-1900, $wday);
  }
  else
  {
    print "unknown date string: [$str]\n";
  }

  return undef;
}

1;
__END__

=head1 NAME

  Util::Mail::Processor.pm  -- mail (header) processing

=head1 SYNOPSIS

=head2 new

  my $hdr= new Util::Mail::Processor ();

  creates empty object

=head2 analyze_header

  my $hdr= analyze_header Util::Mail::Processor (\@mail);

  analyzes a mails header and isolates fields of interest

=head2 parse_qf

  my $hdr= parse_qf Util::Mail::Processor ($filename);

  parses a sendmail qf file

=head2 get_received

  my @lhop= $hdr->get_received ($upd);

  Analyzes received headers to determine the last hop of a given
  mail.  The last hop should be the mail server that handed the
  mail to the first server in our realm which may be comprised of
  several domains.

  A true value of $upd indicates, that last hop address attributes
  in the HDR object should be updated.  These fields are only
  set by the parse_qf method.

=head3 return values

  [0] last hop IP address
  [1] last hop IP host name
  [2] HELO string used by sending server
  [3] first host in our realm
  [4] transaction ID

  A return value of qw(? ? ?) is used for mails that were generated
  within our realm.

=head1 BUGS

  Poor documentation and lazy author :-/

=head1 PLANS

  There are many site specific elements that need to be restructured and refactored into
  a plug-in style module.

=head1 AUTHOR

  Gerhard Gonter <ggonter@cpan.org>

