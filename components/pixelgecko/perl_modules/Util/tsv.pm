package Util::tsv;

use strict;

sub new
{
  my $class= shift;
  my $label= shift;
  my $columns= shift;
  my @par= @_;

  my $obj= { label => $label, cols => $columns, rows => [] };
  bless ($obj, $class);
  $obj->set(@par);

  $obj;
}

sub set
{
  my $self= shift;
  my %par= @_;

  foreach my $par (keys %par)
  {
    $self->{$par}= $par{$par};
  }
}

sub add_items
{
  my $self= shift;
  my $list= shift;

  my @tsv_cols= @{$self->{cols}};
  my ($rows, $label)= map { $self->{$_} } qw(rows label);

=begin comment

  print <<"EOX";

h2. $label

EOX
    print "|_. ", join (" |_. ", @tsv_cols), "|\n";

=end comment
=cut

    foreach my $rec (@$list)
    {
      my %rec= map { $_ => $rec->{$_} } @tsv_cols;
      # print "| ", join (" | ", map { $rec{$_} } @tsv_cols), "|\n";
      push (@$rows, \%rec);
    }

    print "$label count: ", scalar (@$list), "\n";
    # print "$label: ", main::Dumper ($list);
}

sub save_tsv
{
  my $tsv_data= shift;
  my $tsv_name= shift;

    # print "tsv_data: ", main::Dumper ($tsv_data);
    if (open (TSV, '>:utf8', $tsv_name)) # TODO: otherwise complain
    {
      my @cols= @{$tsv_data->{cols}};
      print TSV join ("\t", @cols), "\n";
      foreach my $row (@{$tsv_data->{rows}})
      {
        print TSV join ("\t", map { $row->{$_} } @cols), "\n";
      }
      close (TSV);
    }
}

1;


