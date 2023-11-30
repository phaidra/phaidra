
=head1 NOTE

This used to be package Phaidra::Stage::JobQueue but that used the
module MongoDB with "new MongoDB::Connection" which is now deprecated.
The new way to use that is "new MongoDB::MongoClient" which behaves
slightly different and uses different parameters, so this is the chance
to deprecate "Phaidra::Stage::JobQueue" and use "PAF::JobQueue" instead.

=cut

package PAF::JobQueue;

use strict;

use Util::MongoDB;
use MongoDB::OID;
use MongoDB::MongoClient;
use Util::ts;

# my $self_ref= 'agent_name';
my $self_ref= 'agent';

sub new
{
  my $class= shift;

  my $jq=
  {
    'check_states' => [qw(retry new check_members)],
    'in_progress' => { 'status' => 'in_progress' },
  };
  bless $jq, $class;

  $jq->set(@_);

  $jq;
}

sub set
{
  my $self= shift;
  my %par= @_;

  my %old= ();
  foreach my $par (keys %par)
  {
    $old{$par}= $self->{$par} if (exists ($self->{$par}));
    $self->{$par}= $par{$par};
  }
  \%old;
}

sub get
{
  my $self= shift;
  my @par= @_;

  my @val= ();
  foreach my $par (@par)
  {
    push (@val, $self->{$par});
  }

  (wantarray) ? @val : shift (@val);
}

sub connect
{
  my $jq= shift;

  my $col;

  return $col if (defined ($col= $jq->{'_col'}));

  my ($mdb_con, $mdb)= map { $jq->{$_} } qw(_connection mongodb);

  unless (defined ($mdb_con))
  { # connect to MongoDB

    # DEPRECTATED: $mdb_con= MongoDB::Connection->new(host => $mdb->{'host'});
    # print "connecting to: ", main::Dumper ($mdb);
    $mdb_con= new MongoDB::MongoClient ( %$mdb );
    # $mdb_con= MongoDB->connect(host => $mdb->{'host'});
    # print __FILE__, ' ', __LINE__, " mdb_con=[$mdb_con] ", main::Dumper ($mdb_con);

    unless (defined ($mdb_con))
    {
# DIE:
      die "could not connect to MongoDB: ", main::Dumper ($mdb);
    }

    # goto DIE if ($r eq 'auth fails');
    # print "authentication: r=[$r] ", main::Dumper ($r);
    $jq->{'_connection'}= $mdb_con;
  }
  # if there is a 'database' in config, it's the database we want to connect to
  # ie db_name is only used for auth
  print "connecting to database: ".exists($mdb->{'database'}) ? $mdb->{'database'} : $mdb->{'db_name'}."\n";
  $jq->{'_mdb'}= my $db= $mdb_con->get_database (exists($mdb->{'database'}) ? $mdb->{'database'} : $mdb->{'db_name'});
  # print "db=[$db] ", main::Dumper ($db);
  $col= $db->get_collection ($mdb->{'col'});
  # print "col=[$col] ", main::Dumper ($col);

  return $jq->{'_col'}= $col;
}

sub get_database
{
  my $self= shift;

  $self->connect() unless (defined ($self->{'_mdb'}));
  my $mdb= $self->{'_mdb'};
  $mdb;
}

=head2 $jq->get_collection ($collection_name)

get handle for named collection in the same database where the job queue resides

=cut

sub get_collection
{
  my $self= shift;
  my $col_name= shift or return undef;

  $self->connect() unless (defined ($self->{'_mdb'}));
  my $mdb= $self->{'_mdb'};

  return undef unless (defined ($mdb));
  my $col= $mdb->get_collection ($col_name);

  $col;
}

sub insert_new_job
{
  my $jq= shift;
  my $job= shift;

  $job->{'ts_iso'}= ts_ISO();
  print __FILE__, ' ', __LINE__, " insert_new_job()\n";
# print "* jq: ",   main::Dumper ($jq);
print "* job: ",  main::Dumper ($job);

  my $c= $jq->connect ();
# print "* c: ",  main::Dumper ($c);

  my $id= $c->insert ($job);
print "* id=[$id]\n";
  $job->{'_id'}= $id;

  $id;
}

sub find_job
{
  my $jq= shift;
  my $crit= shift;

  print __FILE__, ' ', __LINE__, " find_job()\n";
# print "* jq: ",   main::Dumper ($jq);
print "* crit: ", main::Dumper ($crit);

  my $c= $jq->connect ();
# print "* c: ",  main::Dumper ($c);

  my $job= $c->find_one ( $crit );
print "* job: ",  main::Dumper ($job);
  $job;
}

sub insert_job
{
  my $jq= shift;
  my $crit= shift;
  my $job= shift;

  $job->{'ts_iso'}= ts_ISO();
  print __FILE__, ' ', __LINE__, " insert_job()\n";
# print "* jq: ",   main::Dumper ($jq);
print "* crit: ", main::Dumper ($crit);
print "* job: ",  main::Dumper ($job);

  my $c= $jq->connect ();
# print "* c: ",  main::Dumper ($c);

  my $res= $c->update ( $crit, $job, { 'upsert' => 1 } );
print "* res: ",  main::Dumper ($res);

  $res;
}

sub update_job
{
  my $jq= shift;
  my $job= shift;

  $job->{'ts_iso'}= ts_ISO();
  my $c= $jq->connect ();
  # print "updating job: ", main::Dumper ($job);
  $c->update ( { '_id' => $job->{'_id'} }, $job );
}

=head $jq->get_job ($agent_name)

get a job which is either in_progress (possibly interrupted) or new.

=cut

sub get_job
{
  my $jq= shift;
  my $agent_name= shift;

  my $c= $jq->connect ();
  # print __FILE__, ' ', __LINE__, " c: ", main::Dumper ($c);
  my %crit= %{$jq->{'in_progress'}};
  $crit{$self_ref}= $agent_name;
  my $job= $c->find_one ( \%crit );
  # print "searching in_progress job: crit: ", main::Dumper (\%crit);
  return $job if (defined ($job));

  foreach my $st (@{$jq->{'check_states'}})
  {
    $crit{'status'}= $st;
    # print "searching $st job ('$self_ref' => '$agent_name'): crit: ", main::Dumper (\%crit);
    my $rc= $c->update ( \%crit, { '$set' => { 'status' => 'in_progress', $self_ref => $agent_name } } );
    # print "rc=[$rc]\n";
    $job= $c->find_one ( { 'status' => 'in_progress', $self_ref => $agent_name });
    # print "job: ", main::Dumper ($job);

    return $job if (defined ($job));
  }

  # print "no job found\n";

  undef;
}

sub get_job_by_id
{
  my $jq= shift;
  my $id= shift;

  my $c= $jq->connect ();

  my %crit= ( _id => MongoDB::OID->new(value => $id) );
  # print "crit: ", main::Dumper (\%crit);
  my $job= $c->find_one ( \%crit );

  $job;
}

1;

