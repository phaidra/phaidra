package PhaidraAPI::Model::Event;

use strict;
use warnings;
use v5.10;
use base  qw/Mojo::Base/;
use POSIX qw(strftime);

sub add {
  my ($self, $c, $eventtype, $pids, $username) = @_;

  my $time = strftime "%Y-%m-%dT%H:%M:%SZ", (gmtime);
  foreach my $pid (@{$pids}) {
    if ($eventtype eq 'submit') {
      my $check_ss  = qq/SELECT 1 FROM event WHERE user_id = ? AND event_type = 'submit' AND pid = ? LIMIT 1/;
      my $check_sth = $c->app->db_ir->dbh->prepare($check_ss) or $c->app->log->error($c->app->db_ir->dbh->errstr);
      $check_sth->execute($username, $pid) or $c->app->log->error($c->app->db_ir->dbh->errstr);
      if ($check_sth->rows) {
        $c->app->log->info("Skipping duplicate submit event for username[$username] pid[$pid]");
        next;
      }
    }

    $c->app->log->info("Adding event type[$eventtype] username[$username] pid[$pid]");
    my $ss  = qq/INSERT INTO event (event_type, pid, user_id, gmtimestamp) VALUES (?,?,?,?)/;
    my $sth = $c->app->db_ir->dbh->prepare($ss) or $c->app->log->error($c->app->db_ir->dbh->errstr);
    $sth->execute($eventtype, $pid, $username, $time) or $c->app->log->error($c->app->db_ir->dbh->errstr);
  }
}

sub list {
  my ($self, $c, $pid) = @_;

  my @events;
  my $ss  = qq/SELECT event_type, user_id, gmtimestamp FROM event WHERE pid = ? ORDER BY gmtimestamp DESC, id DESC/;
  my $sth = $c->app->db_ir->dbh->prepare($ss) or $c->app->log->error($c->app->db_ir->dbh->errstr);
  $sth->execute($pid) or $c->app->log->error($c->app->db_ir->dbh->errstr);
  my ($event, $username, $ts);
  $sth->bind_columns(\$event, \$username, \$ts) or $c->app->log->error($c->app->db_ir->dbh->errstr);
  while ($sth->fetch()) {
    push @events, {event => $event, username => $username, ts => $ts};
  }
  return \@events;
}

1;
