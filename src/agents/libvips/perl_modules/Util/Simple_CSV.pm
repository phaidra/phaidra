#
# $Id: Simple_CSV.pm,v 1.54 2017/11/27 12:39:09 gonter Exp $
#

use strict;
package Util::Simple_CSV;

use Data::Dumper;
$Data::Dumper::Indent= 1;

use Util::hexdump;

=head1 NAME

Util::Simple_CSV  --  simple CSV file and content handling

=head1 SYNOPSIS

=head2 my $csv= new Util::Simple_CSV (paramters);

parameters:
  load => filename
  separator => csv_separator, default: ;
  ...

=cut

my $VERSION= 0.07;

my $CSV_SEPARATOR= ';';
my $CSV_LINE_END= "\n";
my $border_inter= ' | ';
my $DEBUG= 0;

sub new
{
  my $class= shift;

  my $obj=
  {
    'separator' => $CSV_SEPARATOR,
    'line_end' => $CSV_LINE_END,
    'updates'  => 0,
    'verbose'  => 0,
    'no_hash'  => 0,
    'no_array' => 0,
    'filename' => undef,  # name of file read
    'merged'   => undef,  # array with names of merged files

    'columns'  => undef,  # list of column names
    'index'    => undef,  # hash of column names
    'column_count' => 0,  # number of columns defined

    'rows' => undef,      # data as list of array references
    'data' => undef,      # data as list of hash references
    'row_count' => 0,     # number of rows encountered
    'UTF8' => 0,          # 1 if encoding is UTF8
  };
  bless $obj, $class;

  $obj->set (@_);

  if (exists ($obj->{'DEBUG'}))
  {
    $DEBUG= $obj->{'DEBUG'};
    delete ($obj->{'DEBUG'});
  }

  if (exists ($obj->{'load'}))
  {
    $obj->load_csv_file ($obj->{'load'});
    delete ($obj->{'load'});
  }

  $obj;
}

sub clone
{
  my $class= shift;
  my $obj1= shift;

  my $obj= {};
  bless $obj, $class;

  foreach my $k (qw(separator line_end no_hash no_array UTF8))
  {
    $obj->{$k}= $obj1->{$k};
  }

  $obj;
}

sub set
{
  my $obj= shift;
  my %par= @_;

  my %res;
  foreach my $par (keys %par)
  {
    $res{$par}= $obj->{$par};
    $obj->{$par}= $par{$par};
  }

  (wantarray) ? %res : \%res;
}

=head2 $csv->rename ($new_filename)

set a new filename for this csv

=cut

sub rename
{
  my $obj= shift;
  my $new_fnm= shift;

  $obj->set ('filename' => $new_fnm);
}

=head2 $csv->get_csv_file ($filename)

Read contents of $filename into already existing CSV object.  The data
is stored into an array and into an hash.  Options no_array and no_hash
suppress array or hash storage.  Calls load_csv_file.

=cut

sub get_csv_file
{
  my $obj= shift;
  my $fnm= shift;
  my $x_no_array= shift;
  my $x_no_hash= shift;

  if (defined ($x_no_hash) || defined ($x_no_array))
  {
    warn "use set function for no_hash and no_array";

    $obj->{'no_hash'}=  $x_no_hash  if (defined ($x_no_hash));
    $obj->{'no_array'}= $x_no_array if (defined ($x_no_array));
  }

  $obj->load_csv_file ($fnm);
}

=head2 $csv->load_csv_file ($filename)

Read contents of $filename into already existing CSV Object.  The data
is stored into an array and into an hash.

=cut

sub load_csv_file
{
  my $obj= shift;
  my $fnm= shift;

  print "reading $fnm\n" if ($obj->{'verbose'});

  local *FI;
  my $fi_open;
  (*FI, $fi_open)= $obj->open_csv_file ($fnm);

  return undef unless (defined ($fi_open));

  $obj->load_csv_file_headings (*FI) unless ($obj->{'no_headings'});

  if (@{$obj->{columns}}  # NOTE: columns might have been defined using $obj->define_columns(...)
      && exists ($obj->{fidef})
     )
  {
    my ($fidef)= map { $obj->{$_} } qw(fidef);
    if (defined ($fidef))
    {
      my $filter= &$fidef ($obj); # EXPERIMENTAL: callback defines filter callback!
      $obj->set ('filter' => $filter);
    }
  }

  my $row_count= $obj->load_csv_file_body (*FI) unless ($obj->{'no_body'});

  close (FI) if ($fi_open);

  $row_count;
}

sub open_csv_file
{
  my $obj= shift;
  my $fnm= shift;

  $obj->{'filename'}= $fnm;

  local *FI;
  my $fi_open= 0;
  if ($fnm eq '-')
  {
    *FI= *STDIN;
  }
  else
  {
    if (open (FI, $fnm))
    {
      if ($obj->{'UTF8'} || $obj->{'UTF-8'})
      {
        binmode (FI, ':encoding(UTF-8)');
        # print "binmode :encoding(UTF-8)\n";
      }
      elsif ($obj->{'utf8'})
      {
        binmode (FI, ':utf8');
        # print "binmode :utf8\n";
      }
    }
    else
    {
      print STDERR "ATTN: ", ($obj->{'ERROR'}= "can't read $fnm"), "\n";
      return undef;
    }
    $fi_open= 1;
  }

  (*FI, $fi_open);
}

=head2 $csv->load_csv_file_headings (*FILE_HANDLE)

=cut

sub load_csv_file_headings
{
  my $obj= shift;
  local *FI= shift;

    # TODO: make column header reading optional
    my $columns= <FI>;
    unless ($columns)
    {
      $obj->{'ERROR'}= "no column header";
      return undef;
    }

    if ($obj->{'UTF8'})
    {
      my $c1= substr ($columns, 0, 1);
      my $o1= ord ($c1);
      # print "c1=[$c1] o1=[$o1]\n"; hexdump ($c1);
      if ($o1 eq 0xFEFF)
      {
        $columns= substr ($columns, 1);
        # print "BOM removed\n"; hexdump ($columns);
      }
    }

    chomp ($columns);
    $columns=~ s/\r$//;
    my @columns;

    my ($sep, $strip)= map { $obj->{$_} } qw(separator strip_quotes);

    if ($sep eq 'wiki')
    {
      @columns= split_wiki_header ($columns);
    }
    elsif ($sep eq 'awk')
    {
      @columns= split (' ', $columns);
    }
    else
    {
      @columns= split (/$sep/, $columns);
      my $incomplete;
      ($incomplete, @columns)= &strip_row ($sep, 0, @columns) if ($strip);
      # TODO: if incomplete is true, there is an unclosed quote in the header line
      if ($incomplete)
      {
        print STDERR "check for quotes in header!\n";
      }
    }

print __LINE__, " columns: ", join (', ', @columns), "\n" if ($DEBUG > 1);
  $obj->define_columns (@columns);

  (wantarray) ? @columns : \@columns;
}

=head2 $csv->load_csv_file_body (*FILE_HANDLE)

=cut

sub load_csv_file_body
{
  my $obj= shift;
  local *FI= shift;

  my ($no_hash, $no_array, $sep, $columns, $strip, $filter, $max_items)=
      map { $obj->{$_} } qw(no_hash no_array separator columns strip_quotes filter max_items);

  my @rows= ();
  my @data= ();
  my $row_count= 0;
  ROW: while (<FI>)
  {
    chomp;
    s/\r$//;

    my @row;
    if ($sep eq 'wiki')
    {
      @row= split_wiki_data ($_);
    }
    elsif ($sep eq 'awk')
    {
      @row= split (' ', $_);
    }
    else
    {
      my $continue= 0;
      while (1)
      {
        my @yrow= split (/$sep/, $_);
        my $incomplete;
        ($incomplete, @yrow)= &strip_row ($sep, $incomplete, @yrow) if ($strip);
        # print "yrow: ", Dumper(\@yrow);

        if ($continue)
        {
          $row[$#row] .= "\n" # TODO: allow alternate line separator here
                      . shift (@yrow);
        }

        push (@row, @yrow);

        last unless ($incomplete);
        $continue= 1;

        $_= <FI>;
        chomp;
        s/\r$//;
      }

      # print "row: ", Dumper(\@row);
    }
print __LINE__, " row: ", join (', ', @row), "\n" if ($DEBUG > 1);

    if (defined ($filter))
    {
      my $take_it= &$filter (\@row);
      next ROW unless ($take_it);
    }

    push (@rows, \@row) unless ($no_array);

    unless ($no_hash)
    {
      my %data;
      for (my $i= 0; $i <= $#row; $i++)
      {
        $data{$columns->[$i]}= $row[$i];
      }
      push (@data, \%data);
    }
    $row_count++;

    last ROW if (defined ($max_items) && $row_count >= $max_items);
  }

  $obj->{'rows'}= \@rows unless ($no_array);
  $obj->{'data'}= \@data unless ($no_hash);

  $obj->{'row_count'}= $row_count;

  $row_count;
}

sub load_csv_data
{
  my $obj= shift;
  my $rows= shift;

  unless (defined ($rows) && ref($rows) eq 'ARRAY')
  {
    print STDERR "need an array reference\n";
    return undef;
  }

  my ($no_hash, $no_array, $sep, $columns, $strip, $filter, $max_items)=
      map { $obj->{$_} } qw(no_hash no_array separator columns strip_quotes filter max_items);

  my $mk_columns= 0;
  my @columns;
  my %columns;
  if (defined ($columns))
  {
    @columns= @$columns;
  }
  else
  {
    print STDERR "NOTE: columns undefined; creating them\n";
    $mk_columns= 1;
  }

  # NOTE: the code in load_csv_file_body() assumes that $row is an array reference!
  # so we need to determine the columns first

  if ($mk_columns)
  {
    PASS1: foreach my $row (@$rows)
    {
      foreach my $column (keys %$row)
      {
        $columns{$column}++;
      }
    }

    @columns= sort keys %columns; # yeah, we do not know any better way...
    $obj->{columns}= \@columns;
  }

  my $idx= 0;
  %columns= map { $_ => $idx++ } @columns;

  print __LINE__, " columns list: ", join (' ', @columns), "\n";
  print __LINE__, " columns indexes: ", join (' ', %columns), "\n";

  my @rows= ();
  my @data= ();
  my $row_count= 0;

  PASS2: foreach my $row (@$rows)
  {
    my (@row, %row);
    foreach my $column (keys %$row)
    {
      if (exists ($columns{$column}))
      {
        $row[$columns{$column}]= $row->{$column};
        $row{$column}= $row->{$column};
      }
    }
    print "row: ", Dumper (\%row);

    if (defined ($filter))
    {
      my $take_it= &$filter ($row);
      next PASS2 unless ($take_it);
    }

    push (@rows, \@row) unless ($no_array);
    push (@data, \%row) unless ($no_hash);
    $row_count++;

    last ROW if (defined ($max_items) && $row_count >= $max_items);
  }

  $obj->{rows}= \@rows unless ($no_array);
  $obj->{data}= \@data unless ($no_hash);
  $obj->{row_count}= $row_count;

  $row_count;
}

sub strip_row
{
  my $sep= shift;
  my $incomplete= shift;
  my @xrow= ();

  my $quote_open= 0;
  
  if ($incomplete)
  {
    $quote_open= 1;
    $incomplete= 0;
    unshift (@_, @_[0]); # THIS IS MESS and it is also not working good!
  }

  ELEMENT: while (my $r= shift (@_))
  {
	  if ($quote_open)
	  {
	  QUOTE_OPEN:
	    my $stripped= 0;
            SUB_ELEMENT: while (my $r2= shift (@_))
	    {
	      if ($r2 =~ /(.+)"$/)
	      {
	        $r .= $sep . $1;
	        $quote_open= 0;
	        $stripped= 1;
		last SUB_ELEMENT;
	      }
	      else
	      {
	        $r .= $sep . $r2;
	      }
	    }
	    $incomplete= 1 unless ($stripped);
	  }
	  elsif ($r =~ m/^"(.*)"$/) { $r= $1; }
	  elsif ($r =~ m/^"(.*)/) # field begins with quote but no end sofar, so we need to inspect upcoming fields
	  {
	    $r= $1;
	    $quote_open= 1;
	    goto QUOTE_OPEN;
	  }

	  # else: no quotes, no need to strip anything

	  push (@xrow, $r);
  }

  ($incomplete, @xrow);
}

=head2 $csv->define_columns (@column_names)

defines the list of columns of the current csv file

=cut

sub define_columns
{
  my $obj= shift;
  my @columns= @_;

  my $idx= 0;
  my %columns= map { $_ => $idx++ } @columns;

  $obj->{'columns'}= \@columns;
  $obj->{'index'}= \%columns;
  $obj->{'column_count'}= scalar @columns;
}

=head2 my $data= $csv->data ()

=cut

sub data
{
  my $obj= shift;

  return undef unless (exists ($obj->{data}));

  (wantarray) ? @{$obj->{data}} : $obj->{data};
}

=head2 $csv->add_row (@data)

add another data line to csv object

=cut

sub add_row
{
  my $obj= shift;
  my @row= @_;

  push (@{$obj->{'rows'}}, \@row) unless ($obj->{'no_array'});

  unless ($obj->{'no_hash'})
  {
    my $columns= $obj->{'columns'};
    my %data;
    for (my $i= 0; $i <= $#row; $i++)
    {
      $data{$columns->[$i]}= $row[$i];
    }
    push (@{$obj->{'data'}}, \%data);
  }

  $obj->{'row_count'}++;
}

=head2 ($dropped_rows, $dropped_data)= $csv->filter ($check_function);

$check_function is a code reference to a function that expects
one CSV line as array reference as well as hash reference.  If the check
function returns 1, that CSV line is kept, otherwise it is dropped.

The filter method returns references to dropped CSV lines as
references to array which contain CSV lines as array reference
and hash references respectively, e.g.:

  sub check
  {
    my ($array_ref, $hash_ref)= @_;
    ... do whatever there is to check
    return ($keep_row) ? 1 : 0;
  }

=cut

sub filter
{
  my $obj= shift;
  my $check= shift;

  # print "where: ", Dumper($where), "\n";

  my $no_array= $obj->{'no_array'};
  my @old_rows= @{$obj->{'rows'}} if (defined ($obj->{'rows'}));
  my @new_rows= ();
  my @dropped_rows= ();

  my $no_hash= $obj->{'no_hash'};
  my @old_data= @{$obj->{'data'}} if (defined ($obj->{'data'}));
  my @new_data= ();
  my @dropped_data= ();

  while (@old_rows || @old_data)
  {
    my ($row, $data);

    $row=  shift (@old_rows) unless ($no_array);
    $data= shift (@old_data) unless ($no_hash);

    my $res= &$check ($row, $data);
    # print "row: res='$res' ", join (' ', @$row), "\n";

    if ($res == 1)
    {
      push (@new_rows, $row)  unless ($no_array);
      push (@new_data, $data) unless ($no_hash);
    }
    else
    {
      push (@dropped_rows, $row)  unless ($no_array);
      push (@dropped_data, $data) unless ($no_hash);
    }
  }

  $obj->{'rows'}= ($no_array) ? undef : \@new_rows;
  $obj->{'data'}= ($no_hash)  ? undef : \@new_data;

  (\@dropped_rows, \@dropped_data);
}

=head2 $csv->find (field_name, patterns);

search for items where values from field_name match given patterns

=cut

sub find
{
  my $csv= shift;
  my $an= shift;
  my @patterns= @_;

  my $data= $csv->{'data'};
  # print "csv: ", Dumper ($csv);
  my @res= ();
  foreach my $item (@$data)
  {
    my $av= $item->{$an};
    foreach my $pattern (@patterns)
    {
# print "csv find: an=[$an] av=[$av] pattern=[$pattern]\n";
      if ($av =~ m#$pattern#i)
      {
        ## print 'item: ', Dumper ($item), "\n";
        push (@res, $item);
      }
    }
  }

  @res;
}

=head2 $csv->get_columns (names)

retrieve all elements of named columns as an list of array references

=cut

sub get_columns
{
  my $obj= shift;
  my @names= @_;

  @names= @{$names[0]} if (ref ($names[0]) eq 'ARRAY');

  my $index= $obj->{'index'};
  my @index= map { $index->{$_} } @names;
  ## print join (':', __FILE__, __LINE__, " index ", @index), "\n";
  my @res= ();
  foreach my $row (@{$obj->{'rows'}})
  {
    my @row= ();
    foreach my $i (@index)
    {
      push (@row, defined ($i) ? $row->[$i] : undef);
    }
    push (@res, \@row);
  }

  (wantarray) ? @res : \@res;
}

=head2 $csv->get_column (name)

retrieve all elements of named column

=cut

sub get_column
{
  my $obj= shift;
  my $name= shift;

  my $idx= $obj->{'index'}->{$name};
  ## print join (':', __FILE__, __LINE__, " idx ", $idx), "\n";
  return undef unless (defined ($idx));

  my @res= ();
  foreach my $row (@{$obj->{'rows'}})
  {
    push (@res, $row->[$idx]);
  }

  (wantarray) ? @res : \@res;
}

=head2 $csv->merge_csv_file ($filename)

Merge contents of $filename into already existing CSV Object.  If
$obj doese not contain anything yet, get_csv_file is called.

=cut

sub merge_csv_file
{
  my $obj= shift;
  my $fnm= shift;
  my $no_array= shift;
  my $no_hash= shift;

# TODO: no_array and no_hash should be handled like above

  print "merging $fnm\n" if ($obj->{'verbose'});

  if (defined ($obj->{'filename'}))
  {
    my $o2= clone Util::Simple_CSV ($obj);

    $o2->get_csv_file ($fnm, $no_array, $no_hash);
    $obj->merge ($o2, $no_array, $no_hash);

    push (@{$obj->{'merged'}}, $fnm);
  }
  else
  {
    $obj->get_csv_file ($fnm, $no_array, $no_hash);
  }
}

=head2 $csv->merge ($other_obj)

append contents of $other_object to $obj

=cut

sub merge
{
  my $o1= shift;
  my $o2= shift;
  my $no_array= shift;
  my $no_hash= shift;

  my $updates= 0;
## print_refs (*STDOUT, 'o1', $o1);
## print_refs (*STDOUT, 'o2', $o2);

  unless ($no_array)
  {
    # step one: create a mapping table for columns in each csv object
    my $c1= $o1->{'columns'};
    my $c2= $o2->{'columns'};

## print_refs (*STDOUT, 'c1', $c1);
## print_refs (*STDOUT, 'c2', $c2);

    my $i1= $o1->{'index'};
    ## my $i2= $o2->{'index'};

## print_refs (*STDOUT, 'i1', $i1);
## print_refs (*STDOUT, 'i2', $i2);

    my $c_num= 0;
    my @map= ();
    foreach my $c_name (@$c2)
    {
      my $i1_num;

      if (defined ($i1_num= $i1->{$c_name}))
      {
        $map[$c_num]= $i1_num;
      }
      else
      {
        push (@$c1, $c_name); # additional colum
        my $c1_num= $#$c1;       # new column number is highest index
        $i1->{$c_name}= $map[$c_num]= $c1_num;
      }

      $c_num++;
    }

## print_refs (*STDOUT, 'c1', $c1);
## print_refs (*STDOUT, 'map', \@map);

    # step two: actually merge that stuff
    my $o1_rows= $o1->{'rows'};
    unless (defined ($o1_rows))
    {
      $o1_rows= $o1->{'rows'}= []; # in case there were no data rows yet!
    }

    my $o2_columns= $#$c2;
    foreach my $row (@{$o2->{'rows'}})
    {
      # prepare a new data row with columns populated via mapping table
      my @row= ();
      for (my $column= 0; $column <= $o2_columns; $column++)
      {
        $row[$map[$column]]= $row->[$column];
      }

      # add new row to existing csv row
      push (@$o1_rows, \@row);
      $updates++;
    }
## print_refs (*STDOUT, 'o1_rows', $o1_rows);
  }

  unless ($no_hash)
  {
    my $x;
    $x= $o2->{'data'}= [] unless (defined ($x= $o2->{'data'}));
    push (@{$o1->{'data'}}, @$x); # hash entries can simply be appended;
    $updates++; # XXX or += scalar @$x;
  }

  $o1->{'updates'}++ if ($updates);  # XXX or += $updates
}

=head2 $csv->save_csv_file ((attrib => value)*)

save data to CSV file

optional attributes:
  filename   .. save csv under a new filename
  separator  .. use this field separator
  lin_end    .. use this line end

=cut

sub save_csv_file
{
  my $obj= shift;
  my %par= @_;
# print __LINE__, "par: ", main::Dumper (\%par);

  my $fnm= $par{'filename'};
  my $clear_update= 0;
  unless ($fnm)
  {
    $fnm= $obj->{'filename'};
    $clear_update= 1;
  }

  if (open (FO, '>', $fnm))
  {
    if ($obj->{'UTF8'} || $obj->{'UTF-8'})
    {
      binmode (FO, ':encoding(UTF-8)');
      # print "binmode :encoding(UTF-8)\n";
    }
    elsif ($obj->{'utf8'})
    {
      binmode (FO, ':utf8');
      # print "binmode :utf8\n";
    }
  }
  else
  {
    $obj->{'ERROR'}= "cant write to file '$fnm'\n";
    return undef;
  }

  my $rows= $obj->{'rows'}; # XXX no_array flag not checked
  my $data= $obj->{'data'}; # XXX no_array flag not checked
  my $sep= $par{'separator'} || $obj->{'separator'} || $CSV_SEPARATOR;
  my $eol= $par{'line_end'} || $obj->{'line_end'} || $CSV_LINE_END;
# print __LINE__, "sep=[$sep]\n";

  my @columns= @{$obj->{'columns'}};
  my $cc= $#columns;
  print FO join ($sep, @columns), $eol;

  my $records= 0;
  if (defined ($rows))
  {
    foreach my $row (@$rows)
    {
      print FO join ($sep, @{$row}[0..$cc]), $eol; # empty cells at the end of the row must not be suppressed
      $records++;
    }
  }
  elsif (defined ($data))
  {
    foreach my $d (@$data)
    {
      print FO join ($sep, map { $d->{$_} } @columns), $eol; # empty cells at the end of the row must not be suppressed
    }
  }
  else
  {
    print "ATTN: neither rows nor data defined\n";
  }

  close (FO);

  $obj->{'updates'}= 0 if ($clear_update);

  $records;
}

=head2 $csv->index ($field, $to_lower)

index rows by given field name.  Use lowercase, if to_lower is true.

BUG:
* only works with data records.
* if the value of the index field is not defined, the record is
  implicityly indexed under ''; (a warning might been emmitted)
  TODO: maybe a different default value should be used.
  NOTE: the application owner should evaluate, why a field
        with undefined values is indexed in the first place.

=cut

sub index
{
  my $csv= shift;
  my $field= shift;
  my $lower= shift;

  my %IDX= ();
  my $cnt= 0;
  foreach my $row (@{$csv->{'data'}})
  {
    my $av= $row->{$field}; # || '';
    # DO NOT drop this row if $av is undefined!
    # instead 
    $av=~ tr/A-Z/a-z/ if ($lower);
    push (@{$IDX{$av}}, $row);
    $cnt++;
  }
  $csv->{'idx'}->{$field}= \%IDX;
  ($cnt, \%IDX);
}

sub index_array
{
  my $csv= shift;
  my $field= shift;
  my $lower= shift;

  # print "csv: ", main::Dumper ($csv);
  # print "columns: ", join (' ', @{$csv->{'columns'}}), "\n";
  my $idx_field= $csv->{'index'}->{$field};
  $idx_field= 0 unless (defined ($idx_field));
  print "idx_field=[$idx_field]\n";

  my %IDX= ();
  my $cnt= 0;
  foreach my $row (@{$csv->{'rows'}})
  {
    my $av= $row->[$idx_field];
    $av=~ tr/A-Z/a-z/ if ($lower);
    push (@{$IDX{$av}}, $row);
    $cnt++;
  }
  $csv->{'idx_2'}->{$field}= \%IDX;
  ($cnt, \%IDX);
}

=head2 $csv->sort ($field, $lower, $numeric)

Sort the CSV data according to $field which might be converted to lower
case or treated as numeric value.

=cut

sub sort
{
  my $csv= shift;
  my $field= shift;
  my $lower= shift;
  my $numeric= shift;

  my $res1= $csv->sort_hash  ($field, $lower, $numeric);
  my $res2= $csv->sort_array ($field, $lower, $numeric);

  ($res1, $res2);
}

sub sort_array
{
  my $csv= shift;
  my $field= shift;
  my $lower= shift;
  my $numeric= shift;

  return undef if ($csv->{'no_array'});
  print "sorting (array) by field=[$field]\n" if ($csv->{'verbose'});

  my ($cnt, $idx)= $csv->index_array ($field, $lower);

print "cnt=[$cnt]\n";
  return undef unless ($cnt);
print "doing the sort ...\n";

  my @new_rows= ();
  if ($numeric)
  {
    foreach my $k (sort { $a <=> $b } keys %$idx) { push (@new_rows, @{$idx->{$k}}); }
  }
  else
  {
    foreach my $k (sort { $a cmp $b } keys %$idx) { push (@new_rows, @{$idx->{$k}}); }
  }
  my $d= $csv->{'rows'};
  # print "new_rows: ", main::Dumper (\@new_rows);
  $csv->{'rows'}= \@new_rows;
  $d;
}

sub sort_hash
{
  my $csv= shift;
  my $field= shift;
  my $lower= shift;
  my $numeric= shift;

  print "sorting (hash) by field=[$field]\n" if ($csv->{'verbose'});
  return undef if ($csv->{'no_hash'});

  my ($cnt, $idx)= $csv->index ($field, $lower);
# print "cnt=[$cnt]\n";
  return undef unless ($cnt);
# print "doing the sort ...\n";
  # print "idx: ", main::Dumper ($idx);

  my @new_data= ();
  if ($numeric)
  {
    foreach my $k (sort { $a <=> $b } keys %$idx) { push (@new_data, @{$idx->{$k}}); }
  }
  else
  {
    foreach my $k (sort { $a cmp $b } keys %$idx) { push (@new_data, @{$idx->{$k}}); }
  }
  my $d= $csv->{'data'};
  # print "new_rows: ", main::Dumper (\@new_data);
  $csv->{'data'}= \@new_data;
  $d;
}

sub split_wiki_header
{
  my $s= shift;

  $s=~ s/^\s*\|\|?\s*//;
  $s=~ s/\s*\|\|?\s*$//;
  split (/\s*\|\|?\s*/, $s);
}

sub split_wiki_data
{
  my $s= shift;

  $s=~ s/^\s*\|\s*//;
  $s=~ s/\s*\|\s*$//;
  split (/\s*\|\s*/, $s);
}

=begin comment

# replace all print_refs by Dumper calls
sub print_refs
{
  local *F= shift;
  my $label= shift;
  my $var= shift;

  print F $label, '=', Dumper ($var), "\n";
}

=end comment
=cut

=head2 $csv->show_header

display list of column names

=cut

sub show_header
{
  my $obj= shift;
  local *F= shift;

  my $columns= $obj->{'columns'};
  ## print 'columns: ', Dumper ($columns), "\n";
  my $i= 0;
  print "columns:\n";
  foreach my $column (@$columns)
  {
    printf F ("  %3d %s\n", $i++, $column);
  }

}

=head2 $csv->matrix_view ($columns)

show records in "matrix" format (tabular)

=cut

sub matrix_view
{
  my $csv= shift;
  my $columns= shift;
  
  my $d= $csv->get_columns ($columns);

  Util::Matrix::print ($columns, $d);
}

=head2 $csv->extended_view ($columns)

show records in "extended" format, similar to psql

=cut

sub extended_view
{
  my $csv= shift;
  my $columns= shift;
  my $all= shift;

  my $x= $csv->get_extended_view ($columns, $all);
  &_show_extended_view ($x);
}

sub _show_extended_view
{
  my $x= shift;

  return undef unless (defined ($x));

  my @used_columns= @{$x->{'columns'}};
  my $lng= 0;
  foreach my $c (@used_columns)
  {
    $lng= length ($c) if (length($c) > $lng);
  }
  my $fmt= sprintf ("%%-%ds%s%%s\n", $lng, $border_inter);

  # print "lng='$lng' fmt=[$fmt]\n";
  # print 'x=', Dumper ($x), "\n";
  my $num= 0;
  foreach my $d (@{$x->{'data'}})
  {
    printf ("-[ RECORD %d ]----------------------\n", ++$num);
    # TODO: psql uses a slightly different format for the record separator

    foreach my $c (@used_columns)
    {
      if (exists ($d->{$c})) # TODO: flag to print even empty fields
      {
        printf ($fmt, $c, $d->{$c});
      }
    }
  }

}

sub _sprintf_extended_view
{
  my $x= shift;

  return undef unless (defined ($x));

  my @used_columns= @{$x->{'columns'}};
  my $lng= 0;
  foreach my $c (@used_columns)
  {
    $lng= length ($c) if (length($c) > $lng);
  }
  my $fmt= sprintf ("%%-%ds%s%%s\n", $lng, $border_inter);

  # print "lng='$lng' fmt=[$fmt]\n";
  # print 'x=', Dumper ($x), "\n";
  my $num= 0;
  my $res= '';
  foreach my $d (@{$x->{'data'}})
  {
    $res .= sprintf ("-[ RECORD %d ]----------------------\n", ++$num);
    # TODO: psql uses a slightly different format for the record separator

    foreach my $c (@used_columns)
    {
      if (exists ($d->{$c})) # TODO: flag to print even empty fields
      {
        $res .= sprintf ($fmt, $c, $d->{$c});
      }
    }
  }

  $res;
}

sub get_extended_view
{
  my $csv= shift;
  my $columns= shift;
  my $all= shift;

  # get a hash of column names to look for, if nothing defined, take all columns
  $columns= $csv->{'columns'} unless (@$columns);
  my %counts= map { $_ => 0 } @$columns;

  my @res= ();
  my $data= $csv->{'data'};
  foreach my $d (@$data)
  {
    my $item;
    foreach my $c (keys %$d)
    {
      if ($c && exists ($counts{$c}))
      {
        my $v= $d->{$c};
	if (length ($v) || $all)
        { # we are looking for a colmun named c and if it has a defined content => take it!
          $item->{$c}= $v;
	  $counts{$c}++;
        }
      }
    }
    push (@res, $item) if (defined ($item)); # collect item, if there is anything of interest
  }

  my @columns;
  foreach my $c (@$columns)
  {
    push (@columns, $c) if ($counts{$c}); # use only those columns where we actually have values
  }

  # prepare the result
  my $res=
  {
    'columns' => \@columns, # list of column names with values, ordered by specified column list
    'counts' => \%counts,
    'data' => \@res,
  };

  $res;
}

1;
__END__

=head1 TODO

=head2 Flags "no_hash" and "no_array"

should not be passed as parameters.

=head2 data manipulation

=head3 $csv->update_row ($num, @rows);

$num .. first line where data needs to be written;
$num == undef: append at the end;
$num < 0: count from the end of the table;

=head2 design considerations

attribute UTF8 is either true or false, maybe we should have a field
called encoding and utf8 is it's value?

=head2 sorting options

this may be incomplete and results may be unexpected.

=head1 BUGS

 * Multiline elements are not processed correctly, this should be redesigned completely

=head1 Copyright

Copyright (c) 2006..2014 Gerhard Gonter.  All rights reserved.  This
is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

Gerhard Gonter <ggonter@cpan.org>

=head1 SEE ALSO

For more information, see http://aix-pm.sourceforge.net/

=cut

