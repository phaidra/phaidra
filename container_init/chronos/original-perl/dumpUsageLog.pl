#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use POSIX qw(strftime);

# Configuration
my $dsn = "dbi:mysql:phaidradb:".$ENV{MARIADB_PHAIDRA_HOST};
my $username = $ENV{MARIADB_PHAIDRA_USER};
my $password = $ENV{MARIADB_PHAIDRA_PASSWORD};
my $dump_dir = '/mnt/database-dumps';

# Connect to the database
print "connecting to database\n";
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, AutoCommit => 0 })
    or die $DBI::errstr;

my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
my $current_year = $year + 1900;
my $current_month = $mon + 1;  # Perl months are 0-11

# Only run on the 1st of the month
if ($mday != 1) {
    print "Not the 1st of the month. Exiting.\n";
    $dbh->disconnect();
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
    $dbh->disconnect();
    exit 0;
}

# Count how many records will be dumped
my ($count) = $dbh->selectrow_array(
    'SELECT COUNT(*) FROM usage_log WHERE created < ?',
    undef, $cutoff_date
);
print "Found $count records to dump\n";

if ($count == 0) {
    print "No records to dump. Exiting.\n";
    $dbh->disconnect();
    exit 0;
}

# Create dump directory if it doesn't exist
unless (-d $dump_dir) {
    die "Dump directory $dump_dir does not exist\n";
}

# Dump the records to SQL file
print "Dumping records to $dump_path...\n";

# Open output file
open(my $out_fh, '>', $dump_path) or die "Cannot open $dump_path: $!\n";

# Write SQL header
print $out_fh "-- usage_log dump for $dump_year-$dump_month\n";
print $out_fh "-- Dumped on " . strftime("%Y-%m-%d %H:%M:%S", localtime()) . "\n";
print $out_fh "-- Cutoff date: $cutoff_date\n";
print $out_fh "-- Total records: $count\n\n";
print $out_fh "SET NAMES utf8mb4;\n";
print $out_fh "SET FOREIGN_KEY_CHECKS = 0;\n\n";

# Fetch and write records
my $sth = $dbh->prepare(
    'SELECT id, action, pid_num, visitor_id, ip_version, ip_v4, ip_v6, country, created 
     FROM usage_log 
     WHERE created < ? 
     ORDER BY id'
);
$sth->execute($cutoff_date);

my $batch_size = 1000;
my $batch_count = 0;
my $total_written = 0;

print $out_fh "INSERT INTO usage_log (id, action, pid_num, visitor_id, ip_version, ip_v4, ip_v6, country, created) VALUES\n";

while (my $row = $sth->fetchrow_arrayref) {
    my ($id, $action, $pid_num, $visitor_id, $ip_version, $ip_v4, $ip_v6, $country, $created) = @$row;
    
    if ($batch_count > 0) {
        print $out_fh ",\n";
    }
    
    # Format values for SQL
    $action = $dbh->quote($action);
    $country = defined($country) ? $dbh->quote($country) : 'NULL';
    $created = $dbh->quote($created);
    
    # Handle binary data for ip_v6
    my $ip_v6_sql = 'NULL';
    if (defined($ip_v6)) {
        my $hex = unpack('H*', $ip_v6);
        $ip_v6_sql = "0x$hex";
    }
    
    my $ip_v4_sql = defined($ip_v4) ? $ip_v4 : 'NULL';
    
    print $out_fh "($id, $action, $pid_num, $visitor_id, $ip_version, $ip_v4_sql, $ip_v6_sql, $country, $created)";
    
    $batch_count++;
    $total_written++;
    
    if ($batch_count >= $batch_size) {
        print $out_fh ";\n\n";
        print $out_fh "INSERT INTO usage_log (id, action, pid_num, visitor_id, ip_version, ip_v4, ip_v6, country, created) VALUES\n";
        $batch_count = 0;
    }
}

if ($batch_count > 0) {
    print $out_fh ";\n";
}

print $out_fh "\nSET FOREIGN_KEY_CHECKS = 1;\n";

close($out_fh);

print "Dumped $total_written records to $dump_path\n";

# Compress the dump
print "Compressing dump...\n";
system("gzip", $dump_path) == 0 or die "Failed to compress $dump_path: $!\n";
print "Compressed to $dump_path_gz\n";

# Verify the compressed file exists
unless (-f $dump_path_gz) {
    die "ERROR: Compressed file $dump_path_gz was not created\n";
}

# Get file size
my $file_size = -s $dump_path_gz;
my $file_size_mb = sprintf("%.2f", $file_size / (1024 * 1024));
print "Dump file size: $file_size_mb MB\n";

# Now delete the dumped records from usage_log
print "Deleting dumped records from usage_log...\n";
eval {
    $dbh->begin_work;
    
    my $delete_sth = $dbh->prepare('DELETE FROM usage_log WHERE created < ?');
    $delete_sth->execute($cutoff_date);
    my $deleted = $delete_sth->rows;
    
    $dbh->commit;
    print "Deleted $deleted records from usage_log\n";
} or do {
    my $err = $@ || 'unknown error';
    eval { $dbh->rollback };
    die "Failed to delete records: $err\n";
};

print "done\n";
$dbh->disconnect();

