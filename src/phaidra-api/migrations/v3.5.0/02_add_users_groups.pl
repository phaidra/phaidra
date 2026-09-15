#!/usr/bin/env perl
use strict;
use warnings;
use DBIx::Connector;
use MongoDB;
use Log::Log4perl;

# This migration is deliberately additive and may be run more than once.
my $logconf = q(log4perl.category.Migration=INFO,Screen
 log4perl.appender.Screen=Log::Log4perl::Appender::Screen
 log4perl.appender.Screen.layout=Log::Log4perl::Layout::PatternLayout
 log4perl.appender.Screen.layout.ConversionPattern=%d %m%n);
Log::Log4perl::init(\$logconf);
my $log = Log::Log4perl::get_logger('Migration');
my $cntr = DBIx::Connector->new(
  'dbi:mysql:phaidradb:' . ($ENV{MARIADB_PHAIDRA_HOST} // ''),
  $ENV{MARIADB_PHAIDRA_USER}, $ENV{MARIADB_PHAIDRA_PASSWORD},
  {mysql_auto_reconnect => 1, mysql_multi_statements => 1, mysql_enable_utf8 => 1}
);
$cntr->mode('ping');
my $dbh = $cntr->dbh;

$dbh->do(q{
CREATE TABLE IF NOT EXISTS users (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 username VARCHAR(128) NOT NULL, email VARCHAR(254) NULL,
 firstname VARCHAR(128) NULL, lastname VARCHAR(128) NULL,
 displayname VARCHAR(255) NULL, password_hash VARCHAR(255) NULL,
 status ENUM('active','blocked') NOT NULL DEFAULT 'active',
 expires_at DATETIME NULL, last_login DATETIME NULL,
 created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY(id), UNIQUE KEY uq_users_username(username), KEY idx_users_email(email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
});
$dbh->do(q{
CREATE TABLE IF NOT EXISTS affiliations (
 user_id BIGINT UNSIGNED NOT NULL, affiliation VARCHAR(64) NOT NULL,
 PRIMARY KEY(user_id,affiliation), CONSTRAINT fk_aff_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
});
$dbh->do(q{
CREATE TABLE IF NOT EXISTS user_org_units (
 user_id BIGINT UNSIGNED NOT NULL, org_unit_id VARCHAR(64) NOT NULL,
 PRIMARY KEY(user_id,org_unit_id), CONSTRAINT fk_uou_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
});
$dbh->do(q{
CREATE TABLE IF NOT EXISTS user_roles (
 user_id BIGINT UNSIGNED NOT NULL, role VARCHAR(64) NOT NULL,
 PRIMARY KEY(user_id,role), CONSTRAINT fk_ur_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
});
$dbh->do(q{
CREATE TABLE IF NOT EXISTS password_reset_tokens (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, user_id BIGINT UNSIGNED NOT NULL,
 token_hash CHAR(64) NOT NULL, expires_at DATETIME NOT NULL, used_at DATETIME NULL,
 created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY(id),
 UNIQUE KEY uq_reset_hash(token_hash), KEY idx_reset_user(user_id),
 CONSTRAINT fk_reset_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
});
$dbh->do(q{
CREATE TABLE IF NOT EXISTS `groups` (
 groupid CHAR(36) NOT NULL, owner VARCHAR(128) NOT NULL, name VARCHAR(255) NOT NULL,
 created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY(groupid), KEY idx_groups_owner(owner)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
});
$dbh->do(q{
CREATE TABLE IF NOT EXISTS `group_members` (
 groupid CHAR(36) NOT NULL, username VARCHAR(128) NOT NULL,
 PRIMARY KEY(groupid,username),
 CONSTRAINT fk_gm_group FOREIGN KEY(groupid) REFERENCES `groups`(groupid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
});

# Copy legacy documents without deleting them. INSERT IGNORE makes this safe to rerun.
eval {
  my $mc = MongoDB::MongoClient->new(
    host               => 'mongodb-phaidra',
    port               => '27017',
    username           => $ENV{MONGODB_PHAIDRA_USER},
    password           => $ENV{MONGODB_PHAIDRA_PASSWORD},
    connect_timeout_ms => 300000,
    socket_timeout_ms  => 300000,
  );
  my $col = $mc->get_database('groups')->get_collection('usergroups');
  my $it = $col->find;
  $dbh->begin_work;
  my $insg = $dbh->prepare('INSERT IGNORE INTO `groups`(groupid,owner,name,created,updated) VALUES(?,?,?,?,?)');
  my $insm = $dbh->prepare('INSERT IGNORE INTO `group_members`(groupid,username) VALUES(?,?)');
  while (my $doc = $it->next) {
    my $created = $doc->{created} || time;
    my $updated = $doc->{updated} || $created;
    $insg->execute($doc->{groupid}, $doc->{owner}, $doc->{name} // '', _epoch_datetime($created), _epoch_datetime($updated));
    for my $member (@{$doc->{members} || []}) {
      $insm->execute($doc->{groupid}, $member);
    }
  }
  $dbh->commit;
  1;
} or do {
  my $error = $@ || 'unknown legacy group migration error';
  eval {$dbh->rollback};
  die "legacy group migration failed: $error";
};
$log->info('finished migration to v3.5.0 users/groups');

sub _epoch_datetime {
  my ($value) = @_;
  return $value if defined($value) && $value =~ /^\d{4}-\d\d-\d\d/;
  my @t = gmtime($value || time);
  return sprintf('%04d-%02d-%02d %02d:%02d:%02d', $t[5]+1900,$t[4]+1,$t[3],$t[2],$t[1],$t[0]);
}
