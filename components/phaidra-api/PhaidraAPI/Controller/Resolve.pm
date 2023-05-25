package PhaidraAPI::Controller::Resolve;

use strict;
use warnings;
use v5.10;
use Switch;
use base 'Mojolicious::Controller';

sub resolve {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $uri     = $self->param('uri');
  my $nocache = $self->param('nocache');

  my $cachekey = $uri;
  my $cacheval = $self->app->chi->get($cachekey);

  my $miss = 1;
  if ($cacheval) {
    $miss = 0;
    $self->app->log->debug("[cache hit] $cachekey");
  }

  if ($miss || $nocache) {
    $self->app->log->debug("[cache miss] $cachekey");

    my $res = $self->_resolve($uri);
    if ($res->{status} ne 200) {
      $self->render(json => {alerts => $res->{alerts}}, status => $res->{status});
      return;
    }

    $cacheval = $res;

    $self->app->chi->set($cachekey, $cacheval, '1 day');
    $cacheval = $self->app->chi->get($cachekey);
  }

  $self->render(json => {$uri => $cacheval, alerts => $res->{alerts}}, status => $res->{status});
}

sub _resolve {

  my $self = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  if ($uri =~ /d-nb.info\/gnd/g) {
    return $self->_resolve_gnd($uri);
  }
  elsif ($uri =~ /www.geonames.org/g) {
    return $self->_resolve_geonames($uri);
  }
  else {
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Unknown resolver'};
    $res->{status} = 500;
    return $res;
  }

}

sub _resolve_gnd {

  my $self = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};
  $uri =~ s/http/https/g;
  my $url    = Mojo::URL->new($uri);
  my $getres = $self->ua->max_redirects(5)->get($url . '/about/lds.jsonld')->result;
  if ($getres->is_success) {
    for my $h (@{$getres->json}) {
      if ($h->{'@id'} eq $uri) {
        for my $k (keys %{$h}) {
          if ($k eq 'https://d-nb.info/standards/elementset/gnd#preferredNameForTheSubjectHeading') {
            for my $vn (@{$h->{$k}}) {
              push @{$res->{'skos:prefLabel'}}, $vn;
            }
          }
          if ($k eq 'https://d-nb.info/standards/elementset/gnd#variantNameForTheSubjectHeading') {
            for my $vn (@{$h->{$k}}) {
              push @{$res->{'rdfs:label'}}, $vn;
            }
          }
        }
      }
    }
  }
  else {
    $self->app->log->error("[$uri] error resolving uri " . $res->code . ": " . $res->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => $res->code . ": " . $res->message};
    $res->{status} = $res->code ? $res->code : 500;
    return $res;
  }

  return $res;
}

sub _resolve_geonames {

  my $self = shift;
  my $uri  = shift;

  my $res = {alerts => [], status => 200};

  my $lang = $self->param('lang');

  unless ($self->config->{apis}) {
    my $err = "resolve apis are not configured";
    $self->app->log->error($err);
    return {alerts => [{type => 'error', msg => $err}], status => 500};
  }

  unless ($self->config->{apis}->{geonames}) {
    my $err = "geonames api is not configured";
    $self->app->log->error($err);
    return {alerts => [{type => 'error', msg => $err}], status => 500};
  }

  my $insecure = 0;
  if (exists($self->config->{apis}->{geonames}->{insecure})) {
    if ($self->config->{apis}->{geonames}->{insecure}) {
      $insecure = 1;
    }
  }

  my $id     = $uri =~ s/https:\/\/www\.geonames\.org\///r;
  my $params = {
    username  => $self->config->{apis}->{geonames}->{username},
    geonameId => $id
  };
  if ($lang) {
    $params->{lang} = $lang;
  }
  my $url = Mojo::URL->new($self->config->{apis}->{geonames}->{url})->query($params);
  my $get = $self->ua->insecure($insecure)->max_redirects(5)->get($url)->result;
  if ($get->is_success) {
    my $json = $get->json;
    $self->app->log->debug("geonames response: " . $self->app->dumper($json));
    push @{$res->{'skos:prefLabel'}}, {'@value' => $json->{name}};
    my $path = "";
    if ($json->{adminName5}) {
      $path .= "--" . $json->{adminName5} unless $json->{adminName5} eq $json->{toponymName};
    }
    if ($json->{adminName4}) {
      $path .= "--" . $json->{adminName4} unless $json->{adminName4} eq $json->{toponymName};
    }
    if ($json->{adminName3}) {
      $path .= "--" . $json->{adminName3} unless $json->{adminName3} eq $json->{toponymName};
    }
    if ($json->{adminName2}) {
      $path .= "--" . $json->{adminName2} unless $json->{adminName2} eq $json->{toponymName};
    }
    if ($json->{adminName1}) {
      $path .= "--" . $json->{adminName1} unless $json->{adminName1} eq $json->{toponymName};
    }
    if ($json->{countryName}) {
      $path .= "--" . $json->{countryName} unless $json->{countryName} eq $json->{toponymName};
    }
    push @{$res->{'rdfs:label'}}, {'@value' => $json->{toponymName} . $path};

    my $spatial;
    $spatial->{'schema:latitude'}   = $json->{'lat'} if $json->{'lat'};
    $spatial->{'schema:longitude'}  = $json->{'lng'} if $json->{'lng'};
    $res->{'schema:GeoCoordinates'} = $spatial;

  }
  else {
    $self->app->log->error("[$uri] error resolving uri " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  return $res;
}

1;
