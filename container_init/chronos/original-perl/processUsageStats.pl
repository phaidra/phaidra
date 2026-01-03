#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use DBI;

# Configuration
my $bot_threshold = 100;
my $overlap_days = 3;
my $tsv_file = '/mnt/chronos/original-perl/ip2country/ip2country-v4.tsv';
my $dsn = "dbi:mysql:phaidradb:".$ENV{MARIADB_PHAIDRA_HOST};
my $username = $ENV{MARIADB_PHAIDRA_USER};
my $password = $ENV{MARIADB_PHAIDRA_PASSWORD};

# Connect to the database
print "connecting to database\n";
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, AutoCommit => 1 })
    or die $DBI::errstr;

# Identify and delete the visitor IDs exceeding the threshold
sub delete_offender_visitors {
  my ($dbh, $overlap_days, $bot_threshold) = @_;
  die "overlap_days must be > 0" unless $overlap_days && $overlap_days > 0;
  die "bot_threshold must be > 0" unless $bot_threshold && $bot_threshold > 0;

  my $sql = q{
    DELETE e
    FROM usage_log AS e
    JOIN (
      SELECT visitor_id
      FROM usage_log
      WHERE created >= DATE_SUB(NOW(), INTERVAL ? DAY)
      GROUP BY visitor_id
      HAVING COUNT(*) > ?
    ) AS offenders
      ON offenders.visitor_id = e.visitor_id
    WHERE e.created >= DATE_SUB(NOW(), INTERVAL ? DAY)
  };

  my $sth = $dbh->prepare($sql);
  $sth->execute($overlap_days, $bot_threshold, $overlap_days);
  return $sth->rows;  # affected rows (driver reports delete count)
}

# # Assign country codes
# # Taking 3 day window to allow for some overlap... and won't repeatedly try if it does not work
# # though if everything works well, only the one from last day should be NULL anyway
# sub assign_countries_v4 {
#   my ($dbh, $overlap_days) = @_;
#   die "overlap_days must be > 0" unless $overlap_days && $overlap_days > 0;

#   my $sql = q{
#     UPDATE usage_log AS e
#     JOIN ip2location_v4 AS l
#       ON e.ip_version = 4
#      AND e.ip_v4 BETWEEN l.start_ip AND l.end_ip
#     SET e.country = CASE
#                       WHEN l.country IS NULL OR l.country = 'None' THEN 'xx'
#                       ELSE LOWER(l.country)
#                     END
#     WHERE e.country IS NULL
#       AND e.created >= DATE_SUB(NOW(), INTERVAL ? DAY)
#   };

#   my $sth = $dbh->prepare($sql);
#   $sth->execute($overlap_days);
#   return $sth->rows;  # rows updated
# }

# sub assign_countries_v6 {
#   my ($dbh, $overlap_days) = @_;
#   die "overlap_days must be > 0" unless $overlap_days && $overlap_days > 0;

#   my $sql = q{
#     UPDATE usage_log AS e
#     JOIN ip2location_v6 AS l
#       ON e.ip_version = 6
#      AND e.ip_v6 BETWEEN l.start_ip AND l.end_ip
#     SET e.country = CASE
#                       WHEN l.country IS NULL OR l.country = 'None' THEN 'xx'
#                       ELSE LOWER(l.country)
#                     END
#     WHERE e.country IS NULL
#       AND e.created >= DATE_SUB(NOW(), INTERVAL ? DAY)
#   };

#   my $sth = $dbh->prepare($sql);
#   $sth->execute($overlap_days);
#   return $sth->rows;  # rows updated
# }

# sub assign_countries {
#   my ($dbh, $overlap_days) = @_;
#   my ($v4_rows, $v6_rows) = (0, 0);
#   eval {
#     $dbh->begin_work;
#     $v4_rows = assign_countries_v4($dbh, $overlap_days);
#     $v6_rows = assign_countries_v6($dbh, $overlap_days);
#     $dbh->commit;
#     1;
#   } or do {
#     my $err = $@ || 'unknown error';
#     eval { $dbh->rollback };
#     die "assign_countries failed: $err";
#   };
#   return ($v4_rows, $v6_rows);
# }

sub aggregate_usage_log_into_usage_statistics {
  my ($dbh) = @_;

  eval {
    $dbh->begin_work;

    # 1) Snapshot current max id
    my ($max_id) = $dbh->selectrow_array(
      'SELECT COALESCE(MAX(id), 0) FROM usage_log'
    );

    # 2) Read checkpoint row and lock it (FOR UPDATE) to avoid concurrent runners
    my ($last_id) = $dbh->selectrow_array(
      'SELECT last_processed_id FROM usage_statistics_state WHERE singleton = 1 FOR UPDATE'
    );
    $last_id //= 0;

    # Nothing to do
    if ($max_id <= $last_id) {
      $dbh->commit;
      return (0, $last_id, $max_id);
    }

    # 3) Aggregate only new rows, then increment counters
    my $ins_sql = q{
      INSERT INTO usage_statistics (pid_num, `info`, `preview`, `get`, `download`)
      SELECT
        pid_num,
        SUM(action = 'info')     AS `info`,
        SUM(action = 'preview')  AS `preview`,
        SUM(action = 'get')      AS `get`,
        SUM(action = 'download') AS `download`
      FROM usage_log
      WHERE id > ? AND id <= ?
      GROUP BY pid_num
      ON DUPLICATE KEY UPDATE
        `info`     = `usage_statistics`.`info`     + VALUES(`info`),
        `preview`  = `usage_statistics`.`preview`  + VALUES(`preview`),
        `get`      = `usage_statistics`.`get`      + VALUES(`get`),
        `download` = `usage_statistics`.`download` + VALUES(`download`)
    };
    my $ins_sth = $dbh->prepare($ins_sql);
    $ins_sth->execute($last_id, $max_id);

    # Optionally check how many rows were touched:
    my $affected = $ins_sth->rows; # rows inserted + rows matched for update (driver-dependent)

    # 4) Advance checkpoint to the max_id snapshot
    my $upd = $dbh->do(
      'UPDATE usage_statistics_state SET last_processed_id = ? WHERE singleton = 1',
      undef, $max_id
    );

    $dbh->commit;
    return ($affected, $last_id, $max_id);
  } or do {
    my $err = $@ || 'unknown error';
    eval { $dbh->rollback };
    die "Aggregation failed: $err";
  };
}

my $deleted = delete_offender_visitors($dbh, $overlap_days, $bot_threshold);
printf "Deleted %d offender rows\n", $deleted;

# my ($v4u, $v6u) = assign_countries($dbh, $overlap_days);
# printf "Assigned country: v4=%d, v6=%d rows\n", $v4u, $v6u;

my ($affected, $from_id, $to_id) = aggregate_usage_log_into_usage_statistics($dbh);
printf "Aggregated window id > %d and id <= %d; affected rows: %d\n", $from_id, $to_id, $affected;

print "done\n";
$dbh->disconnect();