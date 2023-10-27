package PhaidraAPI::Model::Licenses;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::File;

sub get_licenses {

  my ($self, $c, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  if ($nocache) {
    $c->app->log->debug("Reading licenses_file (nocache request)");

    # read metadata tree from file
    my $path  = Mojo::File->new($c->app->config->{licenses_file});
    my $bytes = $path->slurp;
    unless (defined($bytes)) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error reading licenses_file, no content"};
      $res->{status} = 500;
      return $res;
    }
    my $lic = decode_json($bytes);

    $res->{licenses} = $lic->{licenses};

  }
  else {

    # $c->app->log->debug("Reading licenses from cache");

    my $cachekey = 'licenses';
    my $cacheval = $c->app->chi->get($cachekey);

    my $miss = 1;

    #$c->app->log->debug("XXXXXXXXXXX licenses: ".$c->app->dumper($cacheval));
    if ($cacheval) {
      if (scalar @{$cacheval->{licenses}} > 0) {
        $miss = 0;

        #$c->app->log->debug("[cache hit] $cachekey");
      }
    }

    if ($miss) {
      $c->app->log->debug("[cache miss] $cachekey");

      # read metadata tree from file
      my $path  = Mojo::File->new($c->app->config->{licenses_file});
      my $bytes = $path->slurp;
      unless (defined($bytes)) {
        push @{$res->{alerts}}, {type => 'error', msg => "Error reading licenses_file, no content"};
        $res->{status} = 500;
        return $res;
      }
      $cacheval = decode_json($bytes);

      $c->app->chi->set($cachekey, $cacheval, '1 day');

      # save and get the value. the serialization can change integers to strings so
      # if we want to get the same structure for cache miss and cache hit we have to run it through
      # the cache serialization process even if cache miss [when we already have the structure]
      # so instead of using the structure created we will get the one just saved from cache.
      $cacheval = $c->app->chi->get($cachekey);

      #$c->app->log->debug("XXXXXXXXXXXX after save:".$c->app->dumper($cacheval));
    }

    $res->{licenses} = $cacheval->{licenses};
  }

  return $res;
}

1;
__END__
