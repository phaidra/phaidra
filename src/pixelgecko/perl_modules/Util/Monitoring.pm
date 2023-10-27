#!/usr/bin/perl
#
# $Id: Monitoring.pm,v 1.7 2016/12/23 12:04:58 gonter Exp $

package Util::Monitoring;

use strict;

use Data::Dumper;
use DateTime;

use Util::JSON;
use Util::MongoDB;
use Util::Filesystems;

__PACKAGE__->main() unless caller();

my $ref_inodes= [ 'pct_inodes', 'INODE_LEVEL_WARN' => 90.0, 'INODE_LEVEL_CRIT' => 95.0 ];
my $ref_kbytes= [ 'pct_kbytes', 'KBYTE_LEVEL_WARN' => 90.0, 'KBYTE_LEVEL_CRIT' => 95.0 ];

my @nagios_status= qw(OK UNKNOWN WARNING CRITICAL);
my %no_inodes= map { $_ => 1 } qw(cifs);

sub main
{
  print join (' ', __FILE__, __LINE__, 'main: caller=['. caller(). ']'), "\n";
}

sub new
{
  my $class= shift;

  my $obj= {};
  bless $obj, $class;

  $obj->set (@_);

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

sub get_array
{
  my $obj= shift;
  my @par= @_;

  my @res;
  foreach my $par (@par)
  {
    push (@res, $obj->{$par});
  }

  (wantarray) ? @res : \@res;
}

sub get_hash
{
  my $obj= shift;
  my @par= @_;

  my %res;
  foreach my $par (@par)
  {
    $res{$par}= $obj->{$par};
  }

  (wantarray) ? %res : \%res;
}

*get= *get_array;

sub update_config
{
  my $obj= shift;
  my $cfg_fnm= shift;

  my $do_update= 0;

  if (defined ($cfg_fnm))
  {
    my @st= stat ($cfg_fnm);
    if ($cfg_fnm ne $obj->{'cfg_fnm'}
        # TODO: or file was updated etc. || $
       )
    {
      $do_update= 1;
      $obj->{'cfg_fnm'};
    }
  }

  if ($do_update)
  {
    $obj->read_config($cfg_fnm);
    $obj->setup_ref();
  }

  $do_update;
}

sub read_config
{
  my $obj= shift;
  my $cfg_fnm= shift;

  print "cfg_fnm=[$cfg_fnm]\n";
  my $mon_cfg= Util::JSON::read_json_file($cfg_fnm);
  # print "mon_cfg: ", Dumper ($mon_cfg);

  $obj->{mon_cfg}= $mon_cfg;
  $obj->{cfg_fnm}= $cfg_fnm;
  # TODO: add mtime for update to work...

    # BEGIN connect to MongoDB collection
    my $paf= $mon_cfg->{'AgentDB'};

    my $n_mon=    setup_default_collection ($paf, 'monitoring');
    my $n_events= setup_default_collection ($paf, 'events');
    my $n_msg=    setup_default_collection ($paf, 'messages');

    # print "paf: ", Dumper ($paf);
    # print "n_mon=[$n_mon] n_events=[$n_events]\n";

    my ($mdb, $c_moni)= Util::MongoDB::connect ($paf, $n_mon);
    my $c_events= $mdb->get_collection($n_events);
    my $c_msg=    $mdb->get_collection($n_msg);
    # print "mdb: ", Dumper ($mdb);
    # print "c_moni: ", Dumper ($c_moni);
    # print "c_events: ", Dumper ($c_events);

    $obj->{'_mdb'}= $mdb;
    $obj->{'_moni'}= $c_moni;
    $obj->{'_events'}= $c_events;
    $obj->{'_messages'}= $c_msg;
    # END connect to MongoDB collection

  my $machine= $mon_cfg->{machine};
  unless (defined ($machine))
  {
    my @uname= split (' ', `uname -a`);
    $machine= $uname[1];
  }
  $obj->{_machine}= $machine;

  1;
}

sub get_collection
{
  my $self= shift;
  my $name= shift;

  my $col_handle= '_'. $name;
  return $self->{$col_handle} if (exists($self->{$col_handle}));

  my $mon_cfg= $self->{mon_cfg};
  my $paf= $mon_cfg->{'AgentDB'};
  my $col_name= setup_default_collection ($paf, $name);

  my $mdb= $self->{_mdb};
  my $col= $mdb->get_collection($col_name);
  $self->{$col_handle}= $col;
  $col;
}

sub get_config
{
  my $obj= shift;
  my $what= shift;

  my $res= $obj->{mon_cfg}->{$what};
  $res;
}

=head2 setup_ref

BEGIN access special settings

=cut

sub setup_ref
{
  my $obj= shift;

  # 2018-12-21: hmm... why is _ref not always initialized as a fresh empty hash ref?
  my $ref= $obj->{'_ref'};
  $ref= $obj->{'_ref'}= {} unless (defined ($ref));

  my @ai;
  $obj->{'_auto_increment'}= \@ai;

  my $fs_list= $obj->{'mon_cfg'}->{'filesystems'};

  foreach my $fs (@$fs_list)
  {
    my $mp= $fs->{'mount_point'};
    $ref->{$mp}= $fs;

    push (@ai, $fs) if (exists ($fs->{auto_increment}));
  }

  # print __LINE__, " ref: ", Dumper ($ref);
  $ref;
}

=head1 PAF methods

=head2 $mon->event({...})

register an event

=cut

sub event
{
  my $mon= shift;
  my $ev= shift;

  my $events= $mon->{_events};

  my $event_id= $events->insert($ev);
}

=head2 $mon->message({...})

send a message

=cut

sub send_message
{
  my $mon= shift;
  my $message= shift;
  my $priority= shift || 'low';

  my $msg_cnt= 0;
  my $c_msg= $mon->{_messages};
  my $notify= $mon->{mon_cfg}->{notify};

  if (defined ($c_msg) && defined ($notify))
  {
    my @notify= (ref ($notify) eq 'ARRAY') ? @$notify : $notify;
    my $now= time();
    foreach my $to (@notify)
    {
      $c_msg->insert({ message => $message, to => $to, priority => $priority, state => 'new', 'e' => $now, 'ts' => DateTime->from_epoch('epoch' => $now),});
      $msg_cnt;
    }
  }

  $mon->{_events}->insert({ event => 'messages', message => $message, priority => $priority, count => $msg_cnt });
}

=head1 FILE SYSTEM METHODS

=cut

sub mon_fs
{
  my $mon= shift;

  my ($moni, $events, $ref)= map { $mon->{$_} } qw(_moni _events _ref);

  my $filesystems= new Util::Filesystems ('init' => 1);
  $filesystems->df('k');
  $filesystems->df('i');
  # $filesystems->df('h');
  # print "filesystems: ", Dumper ($filesystems);

  my $worst_status_code= -1;
  my $worst_msg= 'unknown';

  my $now= time ();
  my $fs_hash= $filesystems->{'fs'};
  my %ro_fs;
  # print __LINE__, " checking fs_hash: ", main::Dumper($fs_hash);
  foreach my $fs (keys %$fs_hash)
  {
    # print __LINE__, " fs=[$fs]\n";
    my $x_fs= $fs_hash->{$fs};
    # print "x_fs($fs): ", Dumper ($x_fs);

    # TODO:
    # * calculate a proper nagios status code
    # * update $worst_status_code accordingly

    my @cmp= ();

    my $pct_k= get_fs_level($x_fs->{'k'});
    my $res_k= check_level($fs, $pct_k, $ref->{$fs}->{'ref_kbytes'} || $ref_kbytes);
    push (@cmp, $res_k);

    # TODO: find out if inodes are actually of relevance for this (type of) filesystem
    my $check_inodes= 1;
    $check_inodes= 0 if (exists ($no_inodes{$x_fs->{'type'}}));
    $check_inodes= 0 if ($ref->{$fs}->{'no_inodes'});
    # print "check_inodes=[$check_inodes]\n";
    if ($check_inodes)
    {
      my $pct_i= get_fs_level($x_fs->{'i'});
      my $res_i= check_level($fs, $pct_i, $ref->{$fs}->{'ref_inodes'} || $ref_inodes);
      push (@cmp, $res_i);
    }

    my ($nagios_status_code, $nagios_msg)= compare_levels(@cmp);
       ($worst_status_code, $worst_msg)=   compare_levels([$worst_status_code, $worst_msg], [$nagios_status_code, $nagios_msg]);

    my $rc= $moni->update({ 'resource' => $x_fs->{'mp'} },
                  {
                    'resource' => $x_fs->{'mp'},
                    'e' => $now, 'ts' => DateTime->from_epoch('epoch' => $now),
                    'nagios_status'      => $nagios_status[$nagios_status_code],
                    'nagios_status_code' => $nagios_status_code,
                    'nagios_msg'         => $nagios_msg,
                    'val' => $x_fs->{'k'}->{'used'},
                    'par' => $x_fs
                  },
                  { 'upsert' => 1 }
                 );
    # print __LINE__, " rc=[$rc]\n";
  }

  my $ts= DateTime->from_epoch('epoch' => $now);
  my $ev=
  {
    'event' => 'nagios_update',
    'agent' => 'mon_fs',
    'e' => $now,
    'ts' => $ts,
    'worst_status' => $nagios_status[$worst_status_code],
    'worst_msg' => $worst_msg
  };

  my $event_id= $events->insert($ev);
  # print "event_id: ", Dumper ($event_id);

  if (1)
  {
    $ev->{'_id'}= $event_id->{'value'};
    print "reporing event: ", Dumper ($ev);
    # $ev->{'ts'}= $ts;
  }

  (wantarray) ? ($ev, $fs_hash) : $ev;
}

sub get_auto_increment_filesystems
{
  my $mon= shift;
  my $ai= $mon->{_auto_increment};
  $ai= [] unless (defined ($ai));

  (wantarray) ? @$ai : $ai;
}

sub get_machine
{
  my $mon= shift;

  $mon->{_machine};
}

=head1 SETUP FUNCTIONS

=head2 $col= setup_default_collecton ($name)

Find the collection named for a specific purpose in the configuration.
If there is no collection name in the configuration, it uses the default
name $name.  E.g. setup_default_collection ('events') returns 'events',
if there is nothing configured.

=cut

sub setup_default_collection
{
  my $cfg= shift;
  my $name= shift;

# print __LINE__, " cfg: ", Dumper ($cfg);
  my $colls= $cfg->{'collections'};
  $colls= $cfg->{'collections'}= {} unless (defined ($colls));
  my $col= $colls->{$name};
  $col= $colls->{$name}= $name unless (defined ($col));

# print __LINE__, " cfg: ", Dumper ($cfg);
# print "col=[$col]\n";

  $col;
}

=head1 GENERIC STATUS FUNCTIONS

=head2 get_fs_level

return filling level of a filesystem in percent

=cut

sub get_fs_level
{
  my $x= shift;

  # these two methods return different values!
  # pct_used2 seems to be the more conservative (higher) value
  if ($x->{'total'} == 0)
  {
    print "ATTN: total==0, x: ", main::Dumper ($x);
    return 0.0;
  }
  my $pct_used1=  $x->{'used'} * 100.0 / $x->{'total'};
  my $pct_used2= 100.0 - ($x->{'avail'} * 100.0 / $x->{'total'});

  ($pct_used1 > $pct_used2) ? $pct_used1 : $pct_used2;
}

sub compare_levels
{
  my @observations= @_;

# print "compare_levels: observations=", Dumper(\@observations);
  my $highest_level= -1;
  my $highest_msg= 'unknown';
  foreach my $observation (@observations)
  {
    if ($observation->[0] > $highest_level)
    {
      $highest_level= $observation->[0];
      $highest_msg= $observation->[1];
    }
  }
  $highest_level= 1 unless ($highest_level >= 0);

  (wantarray) ? ($highest_level, $highest_msg) : [$highest_level, $highest_msg];
}

sub check_level
{
  my $resource=  shift;
  my $level=     shift;
  my $reference= shift;

  my ($label, $l_warn, $v_warn, $l_crit, $v_crit)= @$reference;

  my $fmt_level= sprintf ("%2.1f", $level); # NOTE: avoid too fine grained percentage values in message

  my ($nagios_status, $nagios_msg);
  if ($level >= $v_crit)
  {
    $nagios_status= 3;
    $nagios_msg= "resource=[$resource] $label=$fmt_level >= $l_crit=$v_crit";
  }
  elsif ($level >= $v_warn)
  {
    $nagios_status= 2;
    $nagios_msg= "resource=[$resource] $label=$fmt_level >= $l_warn=$v_warn";
  }
  elsif ($level >= 0.0)
  {
    $nagios_status= 0;
    $nagios_msg= "resource=[$resource] $label=$fmt_level";
  }
  else
  {
    $nagios_status= 1;
    $nagios_msg= "resource=[$resource] $label=$fmt_level";
  }

  (wantarray) ? ($nagios_status, $nagios_msg) : [$nagios_status, $nagios_msg];
}

1;

__END__

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 REFERENCES

=head1 AUTHOR

