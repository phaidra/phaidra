#!/usr/bin/perl

=head1 NAME

  PAF::Events  --  Phaidra Agent Framework, Event Handling

=head1 SYNOPSIS

  my $events = new PAF::Events ($mongoDB_handle, $events_collection, $agent_name);

  $events->send (%optional_parameters);

=cut

package PAF::Events;

use strict;
# use Data::Dumper;

sub new
{
  my $class= shift;
  my $mdb= shift;
  my $coll_name= shift;
  my $agent_name= shift;

  return undef unless (defined ($mdb) && defined ($coll_name));
  my $events_collection= $mdb->get_collection ($coll_name);

  unless (defined ($agent_name))
  {
    my @info= caller();
    # print "info: ", main::Dumper(\@info);
    my @path= split ('/', $info[1]);
    $agent_name= pop(@path) || '<unknown>';
  }

  my $self=
  {
    '_mdb' => $mdb,
    '_evc' => $events_collection,
    'events_collection' => $coll_name,
    'agent_name'        => $agent_name,
  };
  bless $self, $class;

# print "events: self=", main::Dumper ($self);

  $self;
}

sub get_collection
{
  my $self= shift;
  $self->{_evc};
}

sub get_cursor
{
  my $self= shift;
  my $tailable= shift;

  my $cursor= $self->{_evc}->find();
  if ($tailable)
  {
    $cursor->tailable($tailable);
    # my $info= $cursor->info();
    # print "info: ", Dumper ($info);
  }

  $cursor;
}

sub send
{
  my $self= shift or return undef;

  my $msg;
  if (ref($_[0]) eq 'HASH')
  {
    $msg= shift;
  }
  else
  {
    my %msg= @_;
    $msg= \%msg;
  }

  $msg->{'e'}= time();
  $msg->{'procid'}= $$;
  $msg->{'agent'}= $self->{'agent_name'};

  my $id= $self->{'_evc'}->insert ( $msg );
  # print "event_id=[$id]\n";
  ($id, $msg);
}

1;

__END__

=head1 EXAMPLE

  my $events= new PAF::Events ($mdb, 'events', 'stat1_monitor');
  $events->send ( { event => 'event_loop_started' } );
  my $cursor= $events->get_cursor(1);

  my $run= 1;
  EVENT: while ($run)
  {
    unless ($events_cursor->has_next())
    {   
      sleep(1);
      next EVENT;
    }    

    my $event_data= $events_cursor->next();
    my ($agent, $event)= map { $event_data->{$_} qw(agent event);
    # do something with the event
  }

  $events->send ( { event => 'event_loop_finished' } );


=head1 BUGS

 * tell me a better name, if you have one...

=head1 AUTHOR

  Gerhard Gonter <ggonter@gmail.com>

