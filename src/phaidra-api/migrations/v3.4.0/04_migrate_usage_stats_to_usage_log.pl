#!/usr/bin/env perl
use strict;
use warnings;
use Socket qw(AF_INET6 inet_aton inet_pton);
use Digest::SHA qw(hmac_sha256);
use Time::HiRes qw(time);
use DBIx::Connector;

# perl migrate_usage_stats_to_usage_log.pl \
#   --dsn 'dbi:mysql:database=metadata;host=127.0.0.1' \
#   --user myuser --pass mypass \
#   --batch 10000 --normalize-country-2
# # optionally: --min-id 1 --max-id 20000000

my $batch = 5000;
my $min_id;
my $max_id;

my $cntr = DBIx::Connector->new("dbi:mysql:phaidradb:".$ENV{MARIADB_PHAIDRA_HOST}, $ENV{MARIADB_PHAIDRA_USER}, $ENV{MARIADB_PHAIDRA_PASSWORD}, {mysql_auto_reconnect => 1, mysql_multi_statements => 1});
$cntr->mode('ping');
my $dbh = $cntr->dbh;

my $PEPPER = $ENV{PHAIDRA_ENCRYPTION_KEY}
  or die "PHAIDRA_ENCRYPTION_KEY env var not set";

# Parse pid 'o:<num>' into pid_num INT (0 if invalid)
sub parse_pid_num {
  my ($pid) = @_;
  my ($n) = ($pid // '') =~ /^o:(\d+)$/;
  return defined $n ? int($n) : 0;
}

# Pack IP with leading version byte (0x04/0x06); undef if invalid
sub pack_ip_with_ver {
  my ($ip) = @_;
  return unless defined $ip && length $ip;
  if (my $v4 = inet_aton($ip)) {
    return pack('C', 4) . $v4;                 # 1 + 4 bytes
  }
  if (defined &Socket::inet_pton) {
    if (my $v6 = inet_pton(AF_INET6, $ip)) {
      return pack('C', 6) . $v6;               # 1 + 16 bytes
    }
  }
  return;                                      # invalid
}

# Convert IP string to storage fields (no remasking)
sub convert_ip_for_storage {
  my ($ip) = @_;
  if (my $v4 = inet_aton($ip)) {
    my $ip_v4_int = unpack('N', $v4);          # INT UNSIGNED
    return (4, $ip_v4_int, undef);
  }
  if (defined &Socket::inet_pton) {
    if (my $v6 = inet_pton(AF_INET6, $ip)) {
      return (6, undef, $v6);                  # VARBINARY(16)
    }
  }
  return (4, 0, undef);                        # fallback for invalid
}

# visitor_id (BIGINT UNSIGNED): first 8 bytes of HMAC-SHA256(version|packed_ip|YYYY-MM-DD|pepper)
sub make_visitor_id_u64 {
  my ($ip_str, $created_dt) = @_;
  my $p = pack_ip_with_ver($ip_str) or return undef;
  my $date = substr($created_dt // '', 0, 10); # 'YYYY-MM-DD'
  my $mac  = hmac_sha256($p . $date, $PEPPER); # 32 bytes
  return unpack('Q>', substr($mac, 0, 8));     # unsigned 64-bit big-endian
}

# Normalize country: return 2-letter lowercase or NULL
sub norm_country_2 {
  my ($c) = @_;
  return undef unless defined $c;
  $c =~ s/^\s+|\s+$//g;
  return undef if $c eq '' || lc($c) eq 'none' || lc($c) eq 'unk' || lc($c) eq 'xx';
  # If given as 3 letters (e.g., 'USA'), truncate or map; here we truncate to first 2.
  $c = substr($c, 0, 2) if length($c) > 2;
  return lc($c);
}

# Prepared INSERT into usage_log; copy created from source
my $ins_sql = q{
  INSERT INTO usage_log
    (action, pid_num, visitor_id, ip_version, ip_v4, ip_v6, country, created)
  VALUES
    (?, ?, ?, ?, ?, ?, ?, ?)
};
my $ins_sth = $dbh->prepare($ins_sql);

# Determine starting id
my $last_id = $min_id // 0;

my $now = strftime "%F %T", localtime time;
print "$now Starting migration usage_stats -> usage_log\n";
print "$now Batch size: $batch; keyset pagination from id > $last_id" . (defined $max_id ? " up to $max_id" : "") . "\n";

my ($total_read, $total_inserted, $total_skipped) = (0, 0, 0);
my $batch_num = 0;

BATCH: while (1) {
  $batch_num++;
  my $t0 = time();

  # Keyset pagination by id
  my $select_sql = qq{
    SELECT id, action, pid, ip, created, location_country
    FROM usage_stats
    WHERE id > ?
      } . (defined $max_id ? " AND id <= ?" : "") . qq{
    ORDER BY id
    LIMIT ?
  };

  my $sel = $dbh->prepare($select_sql);
  if (defined $max_id) {
    $sel->execute($last_id, $max_id, $batch);
  } else {
    $sel->execute($last_id, $batch);
  }

  my $rows = $sel->fetchall_arrayref({});
  my $n = @$rows;
  last BATCH if $n == 0;

  $dbh->begin_work;

  my ($inserted, $skipped) = (0, 0);

  for my $r (@$rows) {
    my ($id, $action, $pid, $ip, $created, $country) =
      @$r{qw/id action pid ip created location_country/};

    $last_id = $id;  # advance for next page
    $total_read++;

    # Validate action
    unless (defined $action && $action =~ /^(info|preview|get|download)$/) {
      $skipped++; next;
    }

    # pid_num
    my $pid_num = parse_pid_num($pid);
    unless ($pid_num) { $skipped++; next; }

    # created required
    unless (defined $created) { $skipped++; next; }

    # visitor_id (BIGINT)
    my $visitor_id = make_visitor_id_u64($ip, $created);
    unless (defined $visitor_id) { $skipped++; next; }

    # IP storage fields
    my ($ip_version, $ip_v4, $ip_v6) = convert_ip_for_storage($ip);

    # Country
    my $country_out = norm_country_2($country);

    eval {
      $ins_sth->execute(
        $action, $pid_num, $visitor_id,
        $ip_version, $ip_v4, $ip_v6,
        $country_out, $created
      );
      $inserted++;
    };
    if ($@) {
      warn "Insert failed for usage_stats id=$id: $@";
      $skipped++;
    }
  }

  $dbh->commit;

  $total_inserted += $inserted;
  $total_skipped  += $skipped;

  my $dt = time() - $t0;
  my $rate = $dt > 0 ? sprintf('%.0f r/s', $n / $dt) : 'n/a';
  $now = strftime "%F %T", localtime time;
  printf "$now [Batch %d] last_id=%d read=%d inserted=%d skipped=%d time=%.2fs rate=%s\n",
    $batch_num, $last_id, $n, $inserted, $skipped, $dt, $rate;
}

$now = strftime "%F %T", localtime time;
print "$now Done. total_read=$total_read inserted=$total_inserted skipped=$total_skipped\n";