#!/usr/bin/env perl
use strict;
use warnings;
use DBIx::Connector;
use Log::Log4perl;

# This migration is deliberately additive and may be run more than once.
my $logconf = q(log4perl.category.Migration=INFO,Screen
 log4perl.appender.Screen=Log::Log4perl::Appender::Screen
 log4perl.appender.Screen.layout=Log::Log4perl::Layout::PatternLayout
 log4perl.appender.Screen.layout.ConversionPattern=%d %m%n);
Log::Log4perl::init(\$logconf);
my $log = Log::Log4perl::get_logger('Migration');
$log->info('started migration to v3.5.0 user terms users');

my $cntr = DBIx::Connector->new('dbi:mysql:phaidradb:' . ($ENV{MARIADB_PHAIDRA_HOST} // ''), $ENV{MARIADB_PHAIDRA_USER}, $ENV{MARIADB_PHAIDRA_PASSWORD}, {mysql_auto_reconnect => 1, mysql_multi_statements => 1, mysql_enable_utf8 => 1});
$cntr->mode('ping');
my $dbh = $cntr->dbh;

$dbh->begin_work;
eval {
  # Retain the candidate list so existing accounts do not receive a new role.
  $dbh->do(
    q{
    CREATE TEMPORARY TABLE migration_user_terms_users AS
    SELECT DISTINCT ut.username
      FROM user_terms ut
      LEFT JOIN users ON users.username = ut.username
     WHERE ut.username IS NOT NULL
       AND ut.username <> ''
       AND users.id IS NULL
  }
  );

  $dbh->do(
    q{
    INSERT IGNORE INTO users (username, status)
    SELECT username, 'active'
      FROM migration_user_terms_users
  }
  );
  my $created = $dbh->rows;

  $dbh->do(
    q{
    INSERT IGNORE INTO user_roles (user_id, role)
    SELECT users.id, 'uploader'
      FROM users
      JOIN migration_user_terms_users ON migration_user_terms_users.username = users.username
  }
  );
  my $roles = $dbh->rows;

  $dbh->do('DROP TEMPORARY TABLE migration_user_terms_users');
  $dbh->commit;
  $log->info("created $created user accounts and assigned $roles uploader roles");
  1;
} or do {
  my $error = $@ || 'unknown user terms migration error';
  eval {$dbh->rollback};
  die "user terms migration failed: $error";
};

$log->info('finished migration to v3.5.0 user terms users');
