# $Id: MongoDB.pm,v 1.19 2017/08/02 10:05:09 gonter Exp $

package Util::MongoDB;

use strict;

use MongoDB;
use Data::Dumper;

my $patched;

sub new
{
  my $class= shift;

  my $obj= bless {}, $class;
  $obj->set (@_);
  $obj;
}

sub set
{
  my $obj= shift;
  my %par= @_;

  foreach my $par (keys %par)
  {
    $obj->{$par}= $par{$par};
  }
}

sub connect_mongodb
{
  my $self= shift;
  my $col_name= shift;

  print STDERR join (' ', caller()), " using connect_mongodb() is deprecated, uses attach() instead!\n";
  attach ($self, $col_name);
}

sub attach
{
  my $self= shift;
  my $col_name= shift;

  my $mdb= $self->{_mdb};

  my $col;
  if (defined ($mdb))
  {
    return $mdb unless (defined ($col_name));

    $col= $self->{_col}->{$col_name};
    return ($mdb, $col) if (defined ($col));
  }
  else
  {
    ($mdb, $col)= Util::MongoDB::connect ($self->{MongoDB});
  }

  unless (defined ($mdb))
  {
    print "ATTN: can not connect to MongoDB: ", Dumper ($mdb);
    return undef;
  }

  $self->{_mdb}= $mdb;

  return $mdb unless (defined ($col_name));

  $col= $mdb->get_collection ($col_name);

  if (defined ($col))
  {
    $self->{_col}->{$col_name}= $col;
  }
  else
  {
    print "ATTN: can not get collection '$col_name'\n";
  }

  ($mdb, $col);
}

sub disconnect_mongodb
{
  my $self= shift;

  if (exists ($self->{_mdb}))
  {
    delete ($self->{_mdb});
    delete ($self->{_col});
  }
}

=head2 my ($mongo_db, $mongo_col)= Util::MongoDB::connect ($config, $col_name)

Retrieve MongoDB parameters from $config and connect to it and open named collection, if specified.

$config is a hash which provides the following keys:
 * host
 * db_name: Name of the MongoDB
 * username
 * password

optionally:
 * port can currently not be specified

=cut

sub connect
{
  my $mdb= shift;
  my $col_name= shift;

  my %c;
  foreach my $k1 (['host', 'hostname'], 'port', ['username', 'user'], ['password', 'pass'],
                 ['db_name', 'db', 'database'], 'collection')
  {
    if ($k1 eq 'collection')
    {
      $col_name= $mdb->{$k1} unless (defined ($col_name));
    }
    elsif (ref($k1) eq '')
    {
      if (exists ($mdb->{$k1})) { $c{$k1}= $mdb->{$k1} }
    }
    elsif (ref($k1) eq 'ARRAY')
    {
      my @k= @$k1;
      $k1= $k[0];
      K2: foreach my $k2 (@k)
      {
        if (exists ($mdb->{$k2})) { $c{$k1}= $mdb->{$k2}; last K2; }
      }
    }
  }

  my ($m, $legacy);
  eval
  {
    $m= new MongoDB::MongoClient (%c);
  };

  if ($@)
  {
    print "ATTN: MongoDB::MongoClient not present [$@], trying MongoDB::Connection\n";
    eval
    {
      $m= new MongoDB::Connection (%c);
    };

    if ($@)
    {
      print "ATTN: MongoDB::Connect not present [$@], bailing out\n";
      return undef;
    }

    $legacy= 1;
  }

  # print "m=[$m]\n";
  unless (defined ($m))
  {
DIE:
      die "could not connect to MongoDB: ", Dumper ($mdb);
  }

=begin comment

??? not needed ???

  if ($legacy)
  {
    my $r= $m->authenticate($mdb->{'db'}, $mdb->{'user'}, $mdb->{'pass'});
    if ($r eq 'auth fails')
    {
      die "auth fails; MongoDB: ", Dumper ($mdb);
    }

    # print "authentication: r=[$r] ", Dumper ($r);
  }

=end comment
=cut

  my $db= $m->get_database ($c{'db_name'});
  goto DIE unless (defined ($db));
  # print "db=[$db] ", Dumper ($db);

  return $db unless (defined ($col_name));

  my $col= $db->get_collection ($col_name);
  # print "col=[$col] ", Dumper ($col);

  return ($db, $col);
}

=head2 my ($data, $columns)= extract ($collection, $search, $fields)

retrieve data from a given collection and returns $data as an array_ref to hash_refs
and $columns as a hash_ref with counters for each field.

$search and $fields are optional.

e.g.  ... TBD ...

=cut

sub extract
{
  my $coll= shift;
  my $search= shift || {};
  my $par_wanted_columns= shift;

  # print "wanted_columns: ", Dumper ($wanted_columns);
  my $wanted_columns;
  my $cnt_wanted_columns= 0;
  if (defined ($par_wanted_columns))
  {
    if (ref($par_wanted_columns) eq 'ARRAY')
    {
      my %wanted_columns= map { $_ => 1 + $cnt_wanted_columns++ } @$wanted_columns;
      $wanted_columns= \%wanted_columns;
    }
    elsif (ref($par_wanted_columns) eq 'HASH')
    {
      $wanted_columns= $par_wanted_columns;
      # $cnt_wanted_columns= scalar keys %$par_wanted_columns;
      $cnt_wanted_columns= 1; # do not actually count them
    }

    # print "wanted_columns: ", Dumper (\%wanted_columns);
  }

  # print "coll=[$coll]\n";
  my $cursor= $coll->find ($search);
  $cursor->fields ($wanted_columns) if ($cnt_wanted_columns);
  my @data= ();
  my %has_columns= ();
  while (my $row= $cursor->next())
  {
    # print "row: ", Dumper ($row);
    my %new_row;
    foreach my $f (keys %$row)
    {
      # print __LINE__, " f=[$f]\n";
      # next if ($f eq '_id'); TODO: flag to supress _id ?
      next if ($cnt_wanted_columns && !exists ($wanted_columns->{$f}));

      my $v= $row->{$f};
      # print __LINE__, " f=[$f] v=$v\n";
      $new_row{$f}= $v;
      $has_columns{$f}++;
    }
    # print "new_row: ", Dumper (\%new_row);
    push (@data, \%new_row);
  }

  (\@data, \%has_columns);
}

=head2 $updates= merge ($target, $source)

Merge or unify two hash references recursively: $target will be updated
with fields from $source.

This might be useful also not only in a MongoDB context.

TODO:
* maybe useful: option where target attributes are removed if not present in source;

=cut

sub merge { merge_hashes (@_); }

sub merge_hashes
{
  my $target= shift;
  my $source= shift;

  my $upd= 0;
  # print "source=[$source]\n";
  foreach my $an (keys %$source)
  {
    next if ($an eq '_id');

    if (exists ($target->{$an}))
    {
      if (ref ($target->{$an}) eq 'HASH' && ref ($source->{$an}) eq 'HASH')
      {
        $upd += merge_hashes ($target->{$an}, $source->{$an});
      }
      elsif (ref ($target->{$an}) eq 'ARRAY' && ref ($source->{$an}) eq 'ARRAY')
      {
        $upd += merge_arrays ($target->{$an}, $source->{$an});
      }
      elsif ($target->{$an} eq $source->{$an})
      {
        # print "NOTE: no change\n";
      }
      else
      { # hmm... maybe a warning is in order here?
        # we are replacing the field in target!
        print "NOTE: replacing an=[$an] [$target->{$an}] := [$source->{$an}]\n";
        $target->{$an}= $source->{$an};
        $upd++;
      }
    }
    else
    { # simply add a new field to the target structure.
      # print "NOTE: adding an=[$an] [$source-->{$an}]\n";
      $target->{$an}= $source->{$an};
      $upd++;
    }
  }

  $upd;
}

sub merge_arrays
{
  my $t= shift;
  my $s= shift;

  # print "array: target:", Dumper ($t);
  # print "array: source:", Dumper ($s);

  my $upd= 0;
  for (my $i= 0; $i <= $#$s; $i++)
  {
    my $ti= $t->[$i]; # exists?
    my $si= $s->[$i];

    # print "[$i] [$ti] := [$si]\n";

       if (ref ($ti) eq 'HASH'  && ref ($si) eq 'HASH')  { $upd += merge_hashes ($ti, $si); }
    elsif (ref ($ti) eq 'ARRAY' && ref ($si) eq 'ARRAY') { $upd += merge_arrays ($ti, $si); }
    elsif ($ti eq $si) {} # NOP
    else
    {
      print "NOTE: replacing i=[$i] [$ti] := [$si]\n";
      $t->[$i]= $si;
      $upd++;
    }
  }

  $upd;
}

sub patch
{
  return $patched if (defined ($patched));

  if (defined (&MongoDB::Collection::insert_one))
  {
    print STDERR "MongoDB::Collection::insert undefined, patching...\n";
    *MongoDB::Collection::insert= *MongoDB::Collection::insert_one;
    *MongoDB::Collection::delete= *MongoDB::Collection::delete_one;
    *MongoDB::Collection::update= *patched_update;
    $patched= 1;
  }
  else
  {
    $patched= 0;
  }

  $patched;
}

sub patched_update
{
  my ($col, $filter, $upd, $opt)= @_;

  # check, if there only update operators otherwise we get this nasty error:
  # "MongoDB::DocumentError: update document must only contain update operators"
  # see https://www.mongodb.com/docs/manual/reference/operator/update/
  my $is_update= 1;
  foreach my $op (keys %$upd)
  {
    $is_update= 0 unless ($op =~ m#^\$#);
  }

  # check, if multi is set
  my $is_multi= (exists ($opt->{multi}) && $opt->{multi}) ? 1 : 0;

  my $res;
  if ($is_update)
  {
    if ($is_multi)
    {
      $res= MongoDB::Collection::update_many($col, $filter, $upd, $opt);
    }
    else
    {
      $res= MongoDB::Collection::update_one($col, $filter, $upd, $opt);
    }
  }
  else
  {
    $res= MongoDB::Collection::replace_one($col, $filter, $upd, $opt);
  }

  $res;
}

patch();

1;

