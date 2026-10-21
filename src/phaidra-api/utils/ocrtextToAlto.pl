#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Mojo::DOM;
use Mojo::URL;
use Mojo::UserAgent;
use Log::Log4perl;

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

Log::Log4perl::init(
  \q(
  log4perl.category.MyLogger        = INFO, Screen
  log4perl.appender.Screen          = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr   = 0
  log4perl.appender.Screen.layout   = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8     = 1
)
);
my $log = Log::Log4perl::get_logger('MyLogger');

my $list = shift @ARGV;
unless ($list && -f $list) {
  $log->error('Usage: ocrtextToAlto.pl /path/to/page-pids.txt');
  exit 1;
}

open my $fh, '<', $list or die "Cannot read $list: $!";
chomp(my @pids = grep {/^o:\d+$/} map {s/^\s+|\s+$//r} <$fh>);
close $fh;
unless (@pids) {
  $log->error("No page PIDs in $list");
  exit 1;
}

my $ua  = Mojo::UserAgent->new;
my $api = Mojo::URL->new->scheme('http')->host($ENV{PHAIDRA_API_HOST})->port(3000)->userinfo($ENV{PHAIDRA_ADMIN_USER} . ':' . $ENV{PHAIDRA_ADMIN_PASSWORD});

my $failed = 0;
for my $pid (@pids) {
  my $ocr = get_ds($pid, 'OCRTEXT');
  unless ($ocr) {
    $log->error("pid[$pid] no OCRTEXT");
    $failed++;
    next;
  }
  my $alto = ocrtext_to_alto($ocr);
  unless ($alto) {
    $log->error("pid[$pid] OCRTEXT has no ocrword");
    $failed++;
    next;
  }
  my $res = $ua->post(
    $api->clone->path("/object/$pid/datastream/ALTO") => form => {
      mimetype  => 'application/xml',
      dscontent => {content => $alto, filename => 'alto.xml'},
    }
  )->result;
  if ($res->code != 200) {
    my $msg = $res->json && $res->json->{alerts} ? $res->json->{alerts}[0]{msg} : $res->message;
    $log->error("pid[$pid] save ALTO failed HTTP " . $res->code . " $msg");
    $failed++;
    next;
  }
  $log->info("pid[$pid] ALTO saved");
}
exit($failed ? 1 : 0);

sub get_ds {
  my ($pid, $dsid) = @_;
  my $res = $ua->get($api->clone->path("/object/$pid/datastream/$dsid"))->result;
  return undef unless $res->code == 200 && $res->body =~ /\S/;
  return $res->body;
}

sub ocrtext_to_alto {
  my ($xml) = @_;
  my $dom = Mojo::DOM->new;
  $dom->xml(1);
  $dom->parse($xml);

  my $strings = '';
  my ($i, $page_w, $page_h) = (0, 1, 1);
  for my $word ($dom->find('ocrword')->each) {
    my $text = $word->attr('word');
    next unless defined $text && $text =~ /\S/;
    my ($x1, $x2, $y1, $y2) = map {coord_num($_)} ($word->attr('x1'), $word->attr('x2'), $word->attr('y1'), $word->attr('y2'));
    next unless defined $x1 && defined $x2 && defined $y1 && defined $y2;
    my ($hpos, $vpos) = ($x1 < $x2 ? $x1 : $x2, $y1 < $y2 ? $y1 : $y2);
    my ($width, $height) = (abs($x2 - $x1) || 1, abs($y2 - $y1) || 1);
    $page_w = $hpos + $width  if $hpos + $width > $page_w;
    $page_h = $vpos + $height if $vpos + $height > $page_h;
    $text =~ s/([&<>"])/$1 eq '&' ? '&amp;' : $1 eq '<' ? '&lt;' : $1 eq '>' ? '&gt;' : '&quot;'/ge;
    $i++;
    $strings .= sprintf qq{          <String ID="w_%d" CONTENT="%s" HPOS="%d" VPOS="%d" WIDTH="%d" HEIGHT="%d"/>\n}, $i, $text, $hpos, $vpos, $width, $height;
  }
  return undef unless $i;

  return <<"ALTO";
<?xml version="1.0" encoding="UTF-8"?>
<alto xmlns="http://www.loc.gov/standards/alto/ns-v3#">
  <Layout>
    <Page WIDTH="$page_w" HEIGHT="$page_h">
      <PrintSpace>
        <TextBlock ID="block_1">
          <TextLine ID="line_1">
$strings          </TextLine>
        </TextBlock>
      </PrintSpace>
    </Page>
  </Layout>
</alto>
ALTO
}

sub coord_num {
  my ($v) = @_;
  return undef unless defined $v && $v =~ /^-?\d+(?:\.\d+)?$/;
  return $v + 0;
}
