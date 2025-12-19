#

Util::Matrix::set_border_style ('Redmine');
# $Id: Matrix.pm,v 1.12 2017/03/26 05:35:49 gonter Exp $
#

package Util::Matrix;

my $VERSION= 0.03;

# formatted matrix output
my $border_left=   my $header_left=   '| ';
my $border_inter=  my $header_inter= ' | ';
my $border_right=  my $header_right= ' |';
my $border_lx= '+';
my $border_rx= '-+';
my $border_lines= 1;
my $border_header= 1;

my $header_style= 'default';

=head2 print ($column_names, $data)

$data = ref to array of arrays

=cut

sub print
{
  my $column_names= shift;
  my $d= shift;
  my $fh= shift || *STDOUT;

  my @l= get_column_lengths ([$column_names], $d);
  my (@fmt_l, @fmt_r);
  my $fmt_x= @l-1;
  foreach my $l (@l)
  {
    push (@fmt_l, "%-${l}s");
    push (@fmt_r, "%${l}u"); # TODO: allow signed, unsigned, float
    $fmt_x += $l;
  }

  my $hl;
  # print 'd: ', Dumper ($d), "\n";
  if ($header_style ne 'none' && defined ($column_names))
  {
    $hl= $border_lx;
    foreach my $l (@l)
    {
      $hl .= '-'x($l+2). '+';
    }
    # print $border_rx;
    my $i= 0;

    print $fh $hl, "\n" if ($border_lines);

    print $fh $header_left if ($header_left);
    foreach my $n (@$column_names)
    {
      print $fh $header_inter if ($i);
      printf $fh ($fmt_l[$i], $n);
      $i++;
    }
    print $fh $header_right if ($header_right);

    print $fh "\n";
    print $fh $hl, "\n" if ($border_header);
  }

  foreach my $row (@$d)
  {
    my $i= 0;
    print $fh $border_left if ($border_left);
    foreach my $col (@$row)
    {
      print $fh $border_inter if ($i);
      # printf ((($col =~ /^-?\d+(\.\d+)?$/) ? $fmt_r[$i] : $fmt_l[$i]), $col);
      # printf ((($col =~ /^-?\d+$/) ? $fmt_r[$i] : $fmt_l[$i]), $col);
      printf $fh ($fmt_l[$i], $col);
      $i++;
    }
    print $fh $border_right if ($border_right);
    print $fh "\n";
  }

  print $fh $hl, "\n" if ($border_lines);
}

=head2 print_hash ($column_names, $data)

$data = ref to array of hashes

=cut

sub print_hash
{
  my $column_names= shift;
  my $rows= shift;
  my $fh= shift || *STDOUT;

  my @d;
  foreach my $row (@$rows)
  {
    push (@d, [ map { $row->{$_} } @$column_names ]);
  }
  # print "d: ", main::Dumper (\@d);

  Util::Matrix::print ($column_names, \@d, $fh);
}

sub set_border_none
{
  $header_left= $header_inter= $header_right=
  $border_left= $border_inter= $border_right= $border_lx= $border_rx= '';
  $border_lines= $border_header= 0;
}

sub set_border_style
{
  my $style= shift;

  if ($style eq 'none') { set_border_none(); }
  elsif ($style eq 'minimal' || $style eq '')
  {
    set_border_none();
    $border_inter= ' ';
  }
  elsif ($style eq 'Redmine')
  { # or $style eq 'default'
    $header_left=   '|_. ';
    $header_inter= ' |_. ';
    $header_right= ' |';
    $border_left=   '| ';
    $border_inter= ' | ';
    $border_right= ' |';
    $border_lx= $border_rx= '';
    $border_lines= $border_header= 0;
  }
  elsif ($style eq 'Gnome')
  { 
    $header_left=  $border_left=   '| ';
    $header_inter= $border_inter= ' | ';
    $header_right= $border_right= ' |';
    $border_lx= '|:';
    $border_rx= '-|';
    $border_lines= 0;
    $border_header= 1;
  }
  else
  { # or $style eq 'default' or 'matrix'
    $header_left=  $border_left=   '| ';
    $header_inter= $border_inter= ' | ';
    $header_right= $border_right= ' |';
    $border_lx= '+';
    $border_rx= '-+';
    $border_lines= $border_header= 1;
  }
}

sub set_header_style
{
  $header_style= shift;
}

sub set_border_inter
{
  $border_inter= shift;
}

sub get_column_lengths
{
  my @s;
  foreach my $d (@_)
  {
    foreach my $row (@$d)
    {
      my $i= 0;
      foreach my $col (@$row)
      {
        my $l= length ($col);
        $s[$i]= $l if ($l > $s[$i]);
        $i++;
      }
    }
  }

  (wantarray) ? @s : \@s;
}

=head2 save_as_csv ($column_names, $data, $fnm, $csv_sep, $col_delimiter, $eol, $UTF8)

save data in csv format, 

=cut

sub save_as_csv
{
  my $column_names= shift;
  my $d= shift;
  my $fnm= shift or return undef;
  my $csv_sep= shift || ';';
  my $col_delimiter= shift;
  my $eol= shift || "\n";
  my $utf8= shift || 0;

  my $fo_open= 0;
  if ($fnm eq '-')
  {
    *FO= *STDOUT;
  }
  else
  {
    unless (open (FO, '>', $fnm))
    {
      print STDERR "ATTN: cant save as csv [$fnm]\n";
      return undef;
    }

    $fo_open= 1;
  }

  if ($utf8)
  {
    print STDERR "ATTN: binmode :utf8 [$fnm]\n";
    binmode (FO, ':utf8');
  }

  print FO join ($csv_sep, @$column_names), $eol;
  my $lines= 0;
  foreach my $row (@$d)
  {
    print FO join ($csv_sep, map { $col_delimiter . $_ . $col_delimiter } @$row), $eol;
    $lines++;
  }
  close (FO) if ($fo_open);
  $lines;
}

=head2 save_hash_as_csv ($column_names, $data, $fnm, $csv_sep, $col_delimiter, $eol, $UTF8)

save data in csv format, 

=cut

sub save_hash_as_csv
{
  my $column_names= shift;
  my $d= shift;
  my $fnm= shift or return undef;
  my $csv_sep= shift || ';';
  my $col_delimiter= shift;
  my $eol= shift || "\n";
  my $utf8= shift || 0;

  unless (open (FO, '>', $fnm))
  {
    print "ATTN: cant save as csv [$fnm]\n";
    return undef;
  }
  binmode (FO, ':utf8') if ($utf8);

  print FO join ($csv_sep, @$column_names), $eol;
  my $lines= 0;
  foreach my $row (@$d)
  {
    print FO join ($csv_sep, map { $col_delimiter . $row->{$_} . $col_delimiter } @$column_names), $eol;
    $lines++;
  }
  close (FO);
  $lines;
}

sub hash_to_array
{
  my $column_names= shift;
  my $d= shift;

  my @data;
  foreach my $row (@$d)
  {
    my @row;
    @row= map { $row->{$_} } @$column_names;
    push (@data, \@row);
  }
  (wantarray) ? @data : \@data;
}
1;

__END__

=head1 BUGS

there should be more pod text

=head1 AUTHOR

  Gerhard Gonter <ggonter@cpan.org>

