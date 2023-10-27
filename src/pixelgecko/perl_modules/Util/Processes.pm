=head1 NAME

  Util::Processes

=head1 DESCRIPTION

Deal with Unix processes

=cut

package Util::Processes;

sub psauxww
{
  my @cmd= qw(ps auxww);

  open (PS, '-|', @cmd) or die;
  my $columns= <PS>;
  chop($columns);
  my @columns= split(' ', $columns);
  my $column_count= 0;
  my %columns= map { $_ => $column_count++ } @columns;
  # print __LINE__, " columns: ", main::Dumper(\@columns);
  # print __LINE__, " column_count=[$column_count]\n";
  my @processes;
  while (<PS>)
  {
    chop;
    # print __LINE__, " _=[$_]\n";
    my @f= split(' ', $_, $column_count);
    my %f= map { $_ => shift (@f) } @columns;
    # print __LINE__, " proc: ", main::Dumper(\%f);
    push (@processes, \%f);
  }
  close (PS);

  my $proc=
  {
    columns   => \@columns,
    processes => \@processes,
  };

  $proc;
}

1;

