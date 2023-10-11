#!/usr/bin/env perl

use strict;
use warnings;
use YAML::Syck;
use Data::Dumper;
use Log::Log4perl;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(decode_json encode_json);
use FindBin '$Bin';
use Template;
$Data::Dumper::Indent= 1;

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $logconf = q(
  log4perl.category.MyLogger         = INFO, Logfile, Screen

  log4perl.appender.Logfile                          = Log::Dispatch::FileRotate
  log4perl.appender.Logfile.Threshold                = DEBUG
  log4perl.appender.Logfile.filename                 = /var/log/phaidra/sitemap.log
  log4perl.appender.Logfile.max                      = 30
  log4perl.appender.Logfile.DatePattern              = yyyy-MM-dd
  log4perl.appender.Logfile.TZ                       = CET
  log4perl.appender.Logfile.layout                   = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Logfile.layout.ConversionPattern = [%d] [%p] [%P] %m%n
  log4perl.appender.Logfile.mode                     = append
  log4perl.appender.Logfile.binmode                  = :encoding(UTF-8)
  log4perl.appender.Logfile.utf8                     = 1

  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init( \$logconf );
my $log = Log::Log4perl::get_logger("MyLogger");

my $config;
eval { $config = YAML::Syck::LoadFile('/etc/phaidra.yml'); };
if($@)
{
  $log->error("ERR: $@\n");
  exit(1);
}

$log->info("started");

my $directory = $config->{phaidrapath}."/root";
if (exists($config->{phaidraui})) {
  if ($config->{phaidraui}->{enabled} eq '1') {
    if (exists($config->{phaidraui}->{static})) {
      $directory = $config->{phaidraui}->{static};
    }
  }
}

my $tt = Template->new({INCLUDE_PATH => $Bin.'/templates/',});

my $ua = Mojo::UserAgent->new;

my $urlsolr = Mojo::URL->new;
$urlsolr->scheme($config->{solr}->{scheme});
$urlsolr->host($config->{solr}->{host});
$urlsolr->port($config->{solr}->{port});
if($config->{solr}->{path}){
  $urlsolr->path("/".$config->{solr}->{path}."/solr/".$config->{solr}->{core}."/select");
}else{
  $urlsolr->path("/solr/".$config->{solr}->{core}."/select");
}
$urlsolr->query(q => "*:*", fq => "-hassuccessor:* AND -ismemberof:[\"\" TO *] AND -isinadminset:*", fl => "pid", rows => 1, wt => "json");
my $solrres = $ua->get($urlsolr)->result;
unless ($solrres->is_success) {
  $log->error("error querying solr: ".$solrres->code." ".$solrres->message);
  exit(1);
}
my $total = $solrres->json->{response}->{numFound};

my $start = 0;
my $rows = 10000;
my @indexfiles;
my $indexfiles_cnt = 1;
while ($start < $total) {
  $urlsolr->query(q => "*:*", fq => "-hassuccessor:* AND -ismemberof:[\"\" TO *] AND -isinadminset:*", fl => "pid,modified", start => $start, rows => $rows, sort => "modified desc", wt => "json");
  $solrres = $ua->get($urlsolr)->result;
  unless ($solrres->is_success) {
    $log->error("error querying solr: ".$solrres->code." ".$solrres->message);
    exit(1);
  }
  my @urls;
  my $indexfilelastmod = '2000-01-01T00:00:00.000Z';
  my $docs = $solrres->json->{response}->{docs};
  my $nrDocs = scalar @{$docs};
  if ($nrDocs > 0) {
    $indexfilelastmod = @{$docs}[0]->{modified}; # ordered by modified
  }
  for my $o (@{$docs}){
    push @urls, { loc => 'https://'.$config->{phaidrabaseurl}.'/detail/'.$o->{pid}, lastmod => $o->{modified} };
  }

  
  push @indexfiles, { loc => 'https://'.$config->{phaidrabaseurl}."/sitemap$indexfiles_cnt.xml", lastmod => $indexfilelastmod };
  my $FIELDS = { urls => \@urls };
  $log->info("Generating sitemap nr $indexfiles_cnt...");
  unless($tt->process('sitemap.xml.tt', $FIELDS, $directory."/sitemap$indexfiles_cnt.xml")) {
    $log->error("Template processing failed... ".$tt->error());
    exit(1);
  }

  $indexfiles_cnt++;
  $start += $rows;
}

$log->info("Generated sitemap files: ".Dumper(\@indexfiles));
$log->info("Generating sitemap index file...");

my $FIELDS = { sitemaps => \@indexfiles };		
unless ($tt->process('sitemap_index.xml.tt', $FIELDS, $directory."/sitemap_index.xml")) {
  $log->error("Template processing failed... ".$tt->error());
  exit(1);
}

$log->info("done");

__END__
