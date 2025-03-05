package PhaidraAPI::Model::Alma;

use strict;
use warnings;
use v5.10;
use utf8;
use Switch;
use base qw/Mojo::Base/;
use XML::LibXML;
use Scalar::Util qw/looks_like_number/;
use PhaidraAPI::Model::Config;
use PhaidraAPI::Model::Util;

sub alma_get_record_json {
  my $self = shift;
  my $c = shift;
  my $ac  = shift;

  my $res = {alerts => [], status => 200};

  my $model = PhaidraAPI::Model::Config->new;
  my $pubconfig = $model->get_private_config($c);

  unless (exists($pubconfig->{almasruurl})) {
    my $err = "alma api is not configured";
    $c->app->log->error($err);
    push @{$res->{alerts}}, {type => 'error', msg => $err};
    $res->{status} = 500;
    return $res;
  }

  my $params = { 
    query => 'local_control_field_009=' . $ac, 
    version => '1.2', 
    maximumRecords => 1, 
    startRecord => 1, 
    operation => 'searchRetrieve', 
    recordSchema => 'marcxml'
  };

  my $url = Mojo::URL->new($pubconfig->{almasruurl})->query($params);
  my $get = $c->ua->max_redirects(5)->get($url)->result;
  if ($get->is_success) {
    my $xml = $get->body;
    my $parser = XML::LibXML->new;
    my $dom = $parser->load_xml(string => $xml);
    my $xpc = XML::LibXML::XPathContext->new($dom);
    $xpc->registerNs('srw', 'http://www.loc.gov/zing/srw/');
    $xpc->registerNs('marc', 'http://www.loc.gov/MARC21/slim');
    for my $recordData ( $xpc->findnodes('//srw:recordData/marc:record')) {
        my $utils_model = PhaidraAPI::Model::Util->new;
        my $marcjson = $utils_model->xml_to_hash($c, $recordData);
        $res->{json} = $marcjson;
        last;
    }    
  }
  else {
    $c->app->log->error("[$url] error searching alma " . $get->message);
    push @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
  }

  return $res;
}

sub alma_search {
  my $self = shift;
  my $c = shift;
  my $query = shift;
  my $version = shift;
  my $operation = shift;
  my $recordSchema = shift;
  my $maximumRecords = shift;
  my $startRecord = shift;

  my $res = {alerts => [], status => 200};

  unless ($query) {
    my $err = "missing query param";
    $c->app->log->error($err);
    push @{$res->{alerts}}, {type => 'error', msg => $err};
    $res->{status} = 500;
    return $res;
  }

  if ($version) {
    unless(looks_like_number($version)) {
      push @{$res->{alerts}}, {type => 'error', msg => 'Invalid version param provided'};
      $res->{status} = 400;
      return $res;
    }
  } else {
    $version = '1.2';
  }

  if ($maximumRecords) {
    unless(looks_like_number($maximumRecords)) {
      push @{$res->{alerts}}, {type => 'error', msg => 'Invalid maximumRecords param provided'};
      $res->{status} = 400;
      return $res;
    }
  } else {
    $maximumRecords = '10';
  }

  if ($startRecord) {
    unless(looks_like_number($startRecord)) {
      push @{$res->{alerts}}, {type => 'error', msg => 'Invalid startRecord param provided'};
      $res->{status} = 400;
      return $res;
    }
  } else {
    $startRecord = '1';
  }

  unless ($operation) {
    $operation = 'searchRetrieve';
  }

  unless ($recordSchema) {
    $recordSchema = 'mods';
  }

  my $model = PhaidraAPI::Model::Config->new;
  my $pubconfig = $model->get_private_config($c);

  unless (exists($pubconfig->{almasruurl})) {
    my $err = "alma api is not configured";
    $c->app->log->error($err);
    push @{$res->{alerts}}, {type => 'error', msg => $err};
    $res->{status} = 500;
    return $res;
  }

  my $params = { query => $query, version => $version, maximumRecords => $maximumRecords, startRecord => $startRecord, operation => $operation, recordSchema => $recordSchema };

  my $url = Mojo::URL->new($pubconfig->{almasruurl})->query($params);
  my $get = $c->ua->max_redirects(5)->get($url)->result;
  if ($get->is_success) {
    $res->{resultxml} = $get->body;
    $res->{status} = $get->code;    
    return $res;
  }
  else {
    $c->app->log->error("[$url] error searching alma " . $get->message);
    push @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

}

1;
__END__
