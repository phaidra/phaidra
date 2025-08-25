package PhaidraAPI::Model::RateLimit;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Time::HiRes qw(time);

sub new {
  my $class = shift;
  my $self = bless {}, $class;
  return $self;
}

sub check_rate_limit {
  my $self = shift;
  my $c = shift;
  my $identifier = shift;  # username:IP combination

  my $res = {alerts => [], status => 200, blocked => 0, remaining_attempts => 5};

  # Get current timestamp
  my $now = time();
  
  # Clean up old entries first (older than 5 minutes)
  $self->_cleanup_old_entries($c, $now);

  # Check if currently blocked
  my $blocked_until = $self->_get_block_until($c, $identifier);
  if ($blocked_until && $now < $blocked_until) {
    my $remaining_block_time = int($blocked_until - $now);
    $res->{blocked} = 1;
    $res->{status} = 429;  # Too Many Requests
    $res->{remaining_block_time} = $remaining_block_time;
    push @{$res->{alerts}}, {
      type => 'error', 
      msg => "Too many failed attempts. Try again in $remaining_block_time seconds."
    };
    return $res;
  }

  # Count recent failed attempts (last 5 minutes)
  my $attempt_count = $self->_count_recent_attempts($c, $identifier, $now);
  $res->{remaining_attempts} = 5 - $attempt_count;

  if ($attempt_count >= 5) {
    # Block the identifier for 15 minutes
    $self->_set_block($c, $identifier, $now, 900);
    $res->{blocked} = 1;
    $res->{status} = 429;  # Too Many Requests
    $res->{remaining_attempts} = 0;
    push @{$res->{alerts}}, {
      type => 'error', 
      msg => "Too many failed attempts. Try again in 15 minutes."
    };
    return $res;
  }

  return $res;
}

sub record_failed_attempt {
  my $self = shift;
  my $c = shift;
  my $identifier = shift;

  my $now = time();
  
  # Insert failed attempt record
  my $attempt_doc = {
    identifier => $identifier,
    timestamp => $now
  };
  
  eval {
    $c->mongo->get_collection('rate_limit_attempts')->insert_one($attempt_doc);
  };
  
  if ($@) {
    $c->app->log->error("Failed to record failed attempt: $@");
  }
}

sub record_successful_attempt {
  my $self = shift;
  my $c = shift;
  my $identifier = shift;

  # Clear any existing blocks for this identifier
  $self->_clear_block($c, $identifier);
}

sub _cleanup_old_entries {
  my $self = shift;
  my $c = shift;
  my $now = shift;

  my $cutoff_time = $now - 300;  # 5 minutes
  
  # Clean up old attempts
  eval {
    $c->mongo->get_collection('rate_limit_attempts')->delete_many({
      timestamp => {'$lt' => $cutoff_time}
    });
  };
  
  if ($@) {
    $c->app->log->error("Failed to cleanup old attempts: $@");
  }
  
  # Clean up expired blocks
  eval {
    $c->mongo->get_collection('rate_limit_blocks')->delete_many({
      block_until => {'$lt' => $now}
    });
  };
  
  if ($@) {
    $c->app->log->error("Failed to cleanup expired blocks: $@");
  }
}

sub _count_recent_attempts {
  my $self = shift;
  my $c = shift;
  my $identifier = shift;
  my $now = shift;

  my $cutoff_time = $now - 300;  # 5 minutes
  
  my $count = 0;
  eval {
    $count = $c->mongo->get_collection('rate_limit_attempts')->count_documents({
      identifier => $identifier,
      timestamp => {'$gt' => $cutoff_time}
    });
  };
  
  if ($@) {
    $c->app->log->error("Failed to count recent attempts: $@");
    return 0;
  }
  
  return $count || 0;
}

sub _get_block_until {
  my $self = shift;
  my $c = shift;
  my $identifier = shift;

  my $block_doc;
  eval {
    $block_doc = $c->mongo->get_collection('rate_limit_blocks')->find_one({
      identifier => $identifier
    });
  };
  
  if ($@) {
    $c->app->log->error("Failed to get block until: $@");
    return undef;
  }
  
  return $block_doc ? $block_doc->{block_until} : undef;
}

sub _set_block {
  my $self = shift;
  my $c = shift;
  my $identifier = shift;
  my $now = shift;
  my $block_duration = shift;

  my $block_until = $now + $block_duration;
  
  my $block_doc = {
    identifier => $identifier,
    block_until => $block_until,
    created_at => $now
  };
  
  eval {
    $c->mongo->get_collection('rate_limit_blocks')->replace_one(
      {identifier => $identifier},
      $block_doc,
      {upsert => 1}
    );
  };
  
  if ($@) {
    $c->app->log->error("Failed to set block: $@");
  }
}

sub _clear_block {
  my $self = shift;
  my $c = shift;
  my $identifier = shift;

  eval {
    $c->mongo->get_collection('rate_limit_blocks')->delete_one({
      identifier => $identifier
    });
  };
  
  if ($@) {
    $c->app->log->error("Failed to clear block: $@");
  }
}

1;
__END__
