#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use DBI;

# Configuration
my $botTreshold = 100;
my $tsv_file = '/usr/local/phaidra/phaidra-api/public/ip2country/ip2country-v4.tsv';
my $dsn = "dbi:mysql:phaidradb:".$ENV{MARIADB_PHAIDRA_HOST};
my $username = $ENV{MARIADB_PHAIDRA_USER};
my $password = $ENV{MARIADB_PHAIDRA_PASSWORD};
my @ip_ranges;
my @visitor_ids;

# Read IP ranges into a data structure
print "loading IP ranges\n";
open my $fh, '<', $tsv_file or die "Cannot open $tsv_file: $!";
while (<$fh>) {
    chomp;
    my ($start_ip, $end_ip, $country_code) = split /\t/;
    push @ip_ranges, {
        start_ip     => unpack('N', pack('C4', split(/\./, $start_ip))),
        end_ip       => unpack('N', pack('C4', split(/\./, $end_ip))),
        country_code => $country_code,
    };
}
close $fh;

# Connect to the database
print "connecting to database\n";
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, AutoCommit => 1 })
    or die $DBI::errstr;

my $sth;

# Identify the visitor IDs exceeding the threshold:
$sth = $dbh->prepare("
    SELECT `visitor_id`, `ip`, COUNT(*)
    FROM `usage_stats`
    WHERE `created` >= NOW() - INTERVAL 3 DAY
    GROUP BY `visitor_id`
    HAVING COUNT(*) > $botTreshold
");
$sth->execute();

# Delete the records for those visitor IDs
my $delete_sth = $dbh->prepare("DELETE FROM `usage_stats` WHERE `visitor_id` = ?");
my $i = 0;
while (my ($visitor_id, $ip, $count) = $sth->fetchrow_array) {
    $i++;
    print "$i deleting $ip $count\n";
    $delete_sth->execute($visitor_id);
}

# Select all distinct IPs from usage_stats for processing
# Taking 3 day window to allow for some overlap... and won't repeatedly try if it does not work
# though if everything works well, only the one from last day should be NULL anyway
$sth = $dbh->prepare("
    SELECT DISTINCT `ip` 
    FROM `usage_stats` 
    WHERE `location_country` IS NULL 
    AND `created` >= NOW() - INTERVAL 3 DAY
");
$sth->execute();

while (my $row = $sth->fetchrow_hashref()) {
    my $ip_address = $row->{ip};
    my $numeric_ip = unpack('N', pack('C4', split(/\./, $ip_address)));
    my $country_code = 'XX';
    print "checking $ip_address\n";
    # Find country code matching the IP
    foreach my $range (@ip_ranges) {
        if ($numeric_ip >= $range->{start_ip} && $numeric_ip <= $range->{end_ip}) {
            $country_code = lc($range->{country_code});
            $country_code = 'xx' if $range->{country_code} eq 'None';
            print "found country code $country_code\n";
            last;
        }
    }
    
    # Update the usage_stats table with the resolved country code
    my $update_sth = $dbh->prepare("UPDATE `usage_stats` SET `location_country` = ? WHERE `ip` = ? AND `created` >= NOW() - INTERVAL 4 DAY");
    $update_sth->execute($country_code, $ip_address);
}

print "done\n";
$sth->finish();
$dbh->disconnect();