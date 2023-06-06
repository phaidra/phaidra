#!/usr/bin/perl

=head1 NAME

  PAF::Activity  --  Phaidra Agent Framework, Activity control

=head1 SYNOPSIS

  my $activity = new PAF::Activity ($mongoDB_handle, $activity_collection, $agent_name);

  $activity->save (%optional_parameters);

=cut

package PAF::Activity;

use strict;
use Data::Dumper;

sub new
{
  my $class= shift;
  my $mdb= shift;
  my $actc_name= shift;
  my $agent_name= shift;

  return undef unless (defined ($mdb) && defined ($actc_name) && defined ($agent_name));

  my $event_horizon;

  my $actc= $mdb->get_collection($actc_name);
  return undef unless (defined ($actc));

  my $f_actr= { 'agent' => $agent_name, 'type' => 'event_horizon' };

  my @actr= $actc->find($f_actr)->all();
  # NOTE: there should be only one such record, all but the last one should not be there
  # print "actr: ", Dumper (\@actr);
  my $actr= pop(@actr);
  if (@actr)
  {
    print "ATTN: too many activity records, these should probably be deleted: ", Dumper(\@actr);
  }

  if (defined ($actr))
  {
    # print "found activity record: ", Dumper ($actr);
    $event_horizon= $actr->{'event_horizon'};
    # print "event_horizon=[$event_horizon]\n";
  }
  else
  {
    $actr= $f_actr;

    $event_horizon= $actr->{'event_horizon'}= 0;
    # NOTE: use time() if we want to skip what happened before our first run, otherwise start at epoch=0!
  }

  my $self=
  {
    '_mdb' => $mdb,
    '_actc' => $actc,
    'activity_collection' => $actc_name,
    'agent_name' => $agent_name,

    'activity' => $actr,
  };

  bless $self, $class;

  (wantarray) ? ($self, $event_horizon) : $self;
}

sub update
{
  my $self= shift or return undef;

  my %par;
  if (ref($_[0]) eq 'HASH')
  {
    my $msg= shift;
    %par= %$msg;
  }
  else
  {
    %par= @_;
  }

# print "update: ", Dumper (\@_);
# print "update: par=", Dumper (\%par);

  # print "self: ", Dumper ($self);
  my $actr= $self->{activity};
  return undef unless (defined ($actr)); # how could this happen?
  # print "actr: ", Dumper ($actr);

  my $cnt= 0;
  foreach my $par (keys %par)
  {
    if ($actr->{$par} ne $par{$par})
    {
      $actr->{$par}= $par{$par};
      $cnt++;
    }
  }

  $actr->{'e'}= time() unless (exists ($par{'e'})); # record latest change of this record (but do not count it);
  $actr->{'procid'}= $$ unless (exists ($par{'procid'}));

  $cnt;
}

sub save
{
  my $self= shift or return undef;

  # print __LINE__, " act->save(): ", join (' ', caller ()), ' pars: [', join (' ', @_), "]\n";

  $self->update (@_) if (@_);

  my ($actc, $actr)= map { $self->{$_} } qw(_actc activity);
  return undef unless (defined ($actc)); # how could this happen?

  # print "activity->save: ", Dumper ($actr);
  if (exists ($actr->{'_id'}))
  {
    my $rc= $actc->update ( { '_id' => $actr->{'_id'} }, $actr );
    # print "activity->save: mode=update result: ", Dumper($rc);
  }
  else
  {
    my $rc= $actr->{'_id'}= $actc->insert ( $actr );
    # print "activity->save: mode=insert result=[$rc]\n";
  }
  print "activity->save(...)\n";

  1;
}

1;

__END__

=head1 BUGS

 * tell me a better name, if you have one...

=head1 AUTHOR

  Gerhard Gonter <ggonter@gmail.com>

