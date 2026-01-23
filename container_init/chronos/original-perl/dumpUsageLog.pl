#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use POSIX qw(strftime);

# Configuration
my $dump_dir = '/mnt/database-dumps';
my $db_name = 'phaidradb';
my $table_name = 'usage_log';

# Helper function to safely quote shell arguments
sub shell_quote {
    my ($arg) = @_;
    $arg =~ s/'/'\\''/g;
    return "'$arg'";
}

my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
my $current_year = $year + 1900;
my $current_month = $mon + 1;  # Perl months are 0-11

# Only run on the 1st of the month
if ($mday != 1) {
    print "Not the 1st of the month. Exiting.\n";
    exit 0;
}

# Calculate the month/year for the dump filename (previous month)
# On March 1st, we dump January data (usage_log_2026_01.sql.gz)
my $dump_year = $current_year;
my $dump_month = $current_month - 1;
if ($dump_month < 1) {
    $dump_month = 12;
    $dump_year--;
}

# Calculate cutoff date: 1st of current month (e.g., Feb 1st when running on March 1st)
# We dump everything created before this date
my $cutoff_date = sprintf("%04d-%02d-01", $current_year, $current_month);

# Format for dump filename: usage_log_YYYY_MM.sql.gz
my $dump_filename = sprintf("usage_log_%04d_%02d.sql", $dump_year, $dump_month);
my $dump_path = "$dump_dir/$dump_filename";
my $dump_path_gz = "$dump_path.gz";

print "Cutoff date: $cutoff_date (dumping entries created before this date)\n";
print "Dump file: $dump_path_gz\n";

# Check if dump already exists
if (-f $dump_path_gz) {
    print "WARNING: Dump file $dump_path_gz already exists. Skipping to avoid overwriting.\n";
    exit 0;
}

my $dsn = "dbi:mysql:${db_name}:".$ENV{MARIADB_PHAIDRA_HOST};
my $username = $ENV{MARIADB_PHAIDRA_USER};
my $password = $ENV{MARIADB_PHAIDRA_PASSWORD};
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, AutoCommit => 0 })
    or die $DBI::errstr;

# Count how many records will be dumped
my ($count) = $dbh->selectrow_array(
    "SELECT COUNT(*) FROM $table_name WHERE created < ?",
    undef, $cutoff_date
);
print "Found $count records to dump\n";

$dbh->disconnect();

if ($count == 0) {
    print "No records to dump. Exiting.\n";
    exit 0;
}

# Create dump directory if it doesn't exist
unless (-d $dump_dir) {
    die "Dump directory $dump_dir does not exist\n";
}

# Use mariadb-dump to create the dump
print "Dumping records using mariadb-dump...\n";

# Escape the cutoff date for the WHERE clause (already safe as it's a formatted date)
my $where_clause = "created < '$cutoff_date'";

# Build the mariadb-dump command
my $dump_cmd = 'mariadb-dump --verbose -h ' . shell_quote($ENV{MARIADB_PHAIDRA_HOST}) .
                ' -u ' . shell_quote($username) .
                ' -p' . shell_quote($password) .
                ' --where=' . shell_quote($where_clause) .
                ' ' . shell_quote($db_name) .
                ' ' . shell_quote($table_name) .
                ' | gzip > ' . shell_quote($dump_path_gz);

print "Executing: mariadb-dump ... --where=\"$where_clause\" $db_name $table_name | gzip > $dump_path_gz\n";

my $exit_code = system($dump_cmd);
if ($exit_code != 0) {
    die "mariadb-dump failed with exit code " . ($exit_code >> 8) . "\n";
}

# Verify the compressed file exists
unless (-f $dump_path_gz) {
    die "ERROR: Compressed file $dump_path_gz was not created\n";
}

# Get file size
my $file_size = -s $dump_path_gz;
my $file_size_mb = sprintf("%.2f", $file_size / (1024 * 1024));
print "Dump file size: $file_size_mb MB\n";

# Now delete the dumped records from usage_log
print "Deleting dumped records from $table_name...\n";

# Reconnect to database for deletion
$dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, AutoCommit => 0 })
    or die $DBI::errstr;

eval {
    $dbh->begin_work;
    
    my $delete_sth = $dbh->prepare("DELETE FROM $table_name WHERE created < ?");
    $delete_sth->execute($cutoff_date);
    my $deleted = $delete_sth->rows;
    
    $dbh->commit;
    print "Deleted $deleted records from $table_name\n";
} or do {
    my $err = $@ || 'unknown error';
    eval { $dbh->rollback };
    die "Failed to delete records: $err\n";
};

print "done\n";
$dbh->disconnect();

