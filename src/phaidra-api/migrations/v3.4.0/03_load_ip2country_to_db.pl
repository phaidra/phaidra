#!/usr/bin/env perl
use strict;
use warnings;
use DBIx::Connector;
use Socket qw(inet_aton AF_INET6 inet_pton);

# Fallback to Net::IP for IPv6 if inet_pton is unavailable (older Perl)
my $HAVE_INET_PTON = defined &Socket::inet_pton;

my $batch = 10_000;

my $cntr = DBIx::Connector->new("dbi:mysql:phaidradb:".$ENV{MARIADB_PHAIDRA_HOST}, $ENV{MARIADB_PHAIDRA_USER}, $ENV{MARIADB_PHAIDRA_PASSWORD}, {mysql_auto_reconnect => 1, mysql_multi_statements => 1});
$cntr->mode('ping');
my $dbh = $cntr->dbh;

# Optional truncate
$dbh->do('TRUNCATE TABLE ip2location_v4');
$dbh->do('TRUNCATE TABLE ip2location_v6');

# Prepare insert statements
my $ins_v4 = $dbh->prepare('INSERT INTO ip2location_v4 (start_ip, end_ip, country) VALUES (?, ?, ?)');
my $ins_v6 = $dbh->prepare('INSERT INTO ip2location_v6 (start_ip, end_ip, country) VALUES (?, ?, ?)');

sub norm_country {
  my ($c) = @_;
  $c = '' unless defined $c;
  $c =~ s/^\s+|\s+$//g;
  $c = lc $c;
  return ($c && $c ne 'none' && $c ne 'unknown') ? $c : 'xx';
}

sub ipv4_to_uint {
  my ($ip) = @_;
  my $packed = inet_aton($ip) or return;
  return unpack('N', $packed);
}

sub ipv6_to_bin {
  my ($ip) = @_;
  if ($HAVE_INET_PTON) {
    my $bin = inet_pton(AF_INET6, $ip);
    return $bin; # undef if invalid
  } else {
    # Fallback using Net::IP if inet_pton is not available
    eval {
      require Net::IP;
      my $obj = Net::IP->new($ip) or return;
      return unless $obj->version == 6;
      my $bits = $obj->binip;              # 128-bit string of '0'/'1'
      return pack('B128', $bits);
    } // return;
  }
}

sub load_v4 {
  my ($file) = @_;
  open my $fh, '<', $file or die "Cannot open $file: $!";
  my $count = 0;
  my $ok = 0;
  my $bad = 0;

  $dbh->begin_work;
  while (my $line = <$fh>) {
    next if $line =~ /^\s*$/;
    chomp $line;
    my ($start, $end, $country) = split /\t/, $line;
    unless (defined $start && defined $end && defined $country) {
      # try split on any whitespace if not true TSV
      ($start, $end, $country) = split /\s+/, $line;
    }
    my $c = norm_country($country);
    my $s = ipv4_to_uint($start);
    my $e = ipv4_to_uint($end);
    if (defined $s && defined $e && $s <= $e) {
      $ins_v4->execute($s, $e, $c);
      $ok++;
    } else {
      warn "Skipping bad IPv4 line: $line\n";
      $bad++;
    }

    $count++;
    if ($count % $batch == 0) {
      $dbh->commit;
      $dbh->begin_work;
    }
  }
  $dbh->commit;
  close $fh;
  print "IPv4: inserted=$ok, skipped=$bad\n";
}

sub load_v6 {
  my ($file) = @_;
  open my $fh, '<', $file or die "Cannot open $file: $!";
  my $count = 0;
  my $ok = 0;
  my $bad = 0;

  $dbh->begin_work;
  while (my $line = <$fh>) {
    next if $line =~ /^\s*$/;
    chomp $line;
    my ($start, $end, $country) = split /\t/, $line;
    unless (defined $start && defined $end && defined $country) {
      ($start, $end, $country) = split /\s+/, $line;
    }
    my $c = norm_country($country);
    my $s = ipv6_to_bin($start);
    my $e = ipv6_to_bin($end);
    if (defined $s && defined $e) {
      # Ensure start <= end in lexicographic byte order (same as numeric compare for fixed 16-byte big-endian)
      if ($s le $e) {
        $ins_v6->execute($s, $e, $c);
        $ok++;
      } else {
        warn "Skipping IPv6 line with start>end: $line\n";
        $bad++;
      }
    } else {
      warn "Skipping bad IPv6 line: $line\n";
      $bad++;
    }

    $count++;
    if ($count % $batch == 0) {
      $dbh->commit;
      $dbh->begin_work;
    }
  }
  $dbh->commit;
  close $fh;
  print "IPv6: inserted=$ok, skipped=$bad\n";
}

load_v4('public/ip2country/ip2country-v4.tsv');
load_v6('public/ip2country/ip2country-v6.tsv');

print "Done.\n";