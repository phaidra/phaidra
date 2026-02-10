#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::UserAgent;
use Mojo::URL;

my $admin_user = $ENV{PHAIDRA_ADMIN_USER};
my $admin_pass = $ENV{PHAIDRA_ADMIN_PASSWORD};

unless ($admin_user && $admin_pass) {
  print "ERROR: PHAIDRA_ADMIN_USER or PHAIDRA_ADMIN_PASSWORD not set\n";
  exit 1;
}

my $ua = Mojo::UserAgent->new;
$ua->request_timeout(300);

# Connect directly to API container via Docker internal network
my $api_url = "http://api:3000";
my $url = Mojo::URL->new("$api_url/utils/send_daily_report")->userinfo("$admin_user:$admin_pass");

my $res = $ua->post($url)->result;

if ($res->is_success) {
  print "Daily report sent successfully\n";
  print "Response: " . $res->body . "\n";
  exit 0;
} else {
  print "ERROR: Failed to send daily report\n";
  print "Status: " . $res->code . " " . $res->message . "\n";
  print "Response: " . $res->body . "\n";
  exit 1;
}

__END__
