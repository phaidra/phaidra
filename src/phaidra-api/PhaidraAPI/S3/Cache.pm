package PhaidraAPI::S3::Cache;

use strict;
use warnings;

use FileHandle;

use File::Basename;
use File::Find;
use File::Path;
use File::Spec;

use Net::Amazon::S3;
use Net::Amazon::S3::Vendor::Generic;
use Net::Amazon::S3::Authorization::Basic;

autoflush STDOUT 1;

sub new {
  my $class = shift;
  my %pars = @_;
  my $self = {};
  foreach my $attribute_name (keys %pars) {
    $self->{$attribute_name} = $pars{$attribute_name};
  }
  bless ($self, $class);
}

sub get_bucket_connection{
  my $self = shift;
  my $s3 = Net::Amazon::S3-> new(
    authorization_context => Net::Amazon::S3::Authorization::Basic-> new (
      aws_access_key_id => $self->{aws_access_key_id},
      aws_secret_access_key => $self->{aws_secret_access_key},
    ),
    vendor => Net::Amazon::S3::Vendor::Generic->new(
      host => $self->{s3_endpoint} =~ s/^https?:\/\///r,
      use_virtual_host => 0,
      use_https => !($self->{s3_endpoint} =~ qr/^http:\/\/.*/),
      default_region => "eu-central-1",
    ),
    retry => 1,
   );
  $s3->bucket($self->{bucketname});
}

sub get_content_length{
  my $self = shift;
  my $FileToBeCached = shift;
  my $bucket_connection = $self->get_bucket_connection();
  my $s3_key = $bucket_connection->get_key($FileToBeCached);
  my $filesize;
  my $return_code = "OK";
  if (! defined $s3_key) {
    $return_code = "S3 key $FileToBeCached not available in remote object store.";
  } else {
    $filesize = $s3_key->{'content_length'}+0;
  }
  return ($filesize, $return_code);
}

sub get_upstream_timestamp{
  my $self = shift;
  my $FileToBeCached = shift;
  my $bucket_connection = $self->get_bucket_connection();
  my $s3_key = $bucket_connection->get_key($FileToBeCached);
  my $return_code = "OK";
  my $upstream_mtime_string;
  my $upstream_mtime_unix;
  if (! defined $s3_key) {
    $return_code = "S3 key $FileToBeCached not available in remote object store.";
  } else {
    $upstream_mtime_string = $s3_key->{'last-modified'};
    $upstream_mtime_unix = `date -d "$upstream_mtime_string" +%s`;
  }
  return ($upstream_mtime_unix, $return_code);
}


sub download_object_to_cache{
  my $self = shift;
  my $FileToBeCached = shift;
  my $bucket_connection = $self->get_bucket_connection();
  my $s3_cache_topdir = $self->{s3_cache_topdir};
  my ($file, $basepath, $suffix) = fileparse($FileToBeCached);
  my $return_code = "OK";
  # stub for catpath on UNIX
  my $volume;
  my $s3_cache_path = File::Spec->catpath($volume,$s3_cache_topdir,$basepath);
  my $s3_cache_file = File::Spec->catpath($volume,$s3_cache_topdir,$FileToBeCached);
  if (! -d $s3_cache_path) {
    File::Path::make_path($s3_cache_path);
  }
  my $response = $bucket_connection->get_key_filename( $FileToBeCached, 'GET', $s3_cache_file );
  if (! -f $s3_cache_file) {
    $return_code = $response . $bucket_connection->err . ": " . $bucket_connection->errstr;
    print $return_code,"\n";
  } else {
    print "Object downloaded to $s3_cache_file\n";
  }
  return $return_code;
}

sub get_current_cachesize{
  my $self = shift;
  my $bucket_connection = $self->get_bucket_connection();
  my $cache_coll = $self->{paf_mongodb}->get_collection('s3_cache');
  my $cache_document_count = $cache_coll->estimated_document_count();
  my $current_cache;
  if ( $cache_document_count > 0 ) {
    my @sum_aggregate = ( { '$group' => {_id => 'null', total => { '$sum' => '$size' }}} );
    my $sum_query = $cache_coll->aggregate( \@sum_aggregate );
    my @sum_result = $sum_query->all;
    $current_cache = $sum_result[0]->{'total'};
  }
  # avoid uninitialized warning in logs if query does not return anything.
  if (defined $current_cache) {
    return $current_cache;
  } else {
    return 0;
  }
}

sub check_cleanup_size{
  my $self = shift;
  my $FileToBeCached = shift;
  my $currently_used = $self->get_current_cachesize();
  print "current cache usage: $currently_used B.\n";
  my ($filesize, $err) = $self->get_content_length($FileToBeCached);
  my $cachesize = $self->{'s3_cachesize'};
  my $free_space_needed = $filesize*1.2+$currently_used-$cachesize;
  return $free_space_needed;
}

sub get_items_to_be_cleared{
  my $self = shift;
  my $FileToBeCached = shift;
  my $space_needed = $self->check_cleanup_size($FileToBeCached);
  my @items_to_be_deleted;
  if ($space_needed > 0) {
    my $cache_coll = $self->{paf_mongodb}->get_collection('s3_cache');
    my $space_to_be_cleared = 0;
    my $arraycounter = 0;
    my @sort_pipeline = (
      { '$sort' => Tie::IxHash->new( viewcounter => 1, lastview => -1) }
     );
    my $result = $cache_coll->aggregate( \@sort_pipeline );
    my @sorted_items = $result->all;
    while ( ($space_to_be_cleared < $space_needed) && ($arraycounter <= $#sorted_items) ) {
      push(@items_to_be_deleted, $sorted_items[$arraycounter]->{'pid'});
      $space_to_be_cleared += $sorted_items[$arraycounter]->{'size'};
      $arraycounter++;
    }
  }
  return @items_to_be_deleted;
}

sub clear_items{
  my $self = shift;
  my $FileToBeCached = shift;
  my $s3_cache_topdir = $self->{s3_cache_topdir};
  my @items_to_be_cleared = $self->get_items_to_be_cleared($FileToBeCached);
  if (scalar @items_to_be_cleared > 0) {
    my $cache_coll = $self->{paf_mongodb}->get_collection('s3_cache');
    foreach (@items_to_be_cleared) {
      my $item = $cache_coll->find_one({pid => $_})->{'file'};
      if (-f $item) {
        unlink $item;
      }
      $cache_coll->delete_one({pid => $_});
    }
  }
  # cleanup s3 cache directory tree
  finddepth(sub{rmdir}, $s3_cache_topdir);
}

sub update_cache_db{
  my $self = shift;
  my $pid = shift;
  my $FileToBeCached = shift;
  my $s3_cache_topdir = $self->{s3_cache_topdir};
  # stub for catpath on UNIX
  my $volume;
  my $s3_cache_file = File::Spec->catpath($volume,$s3_cache_topdir,$FileToBeCached);
  my $cache_coll = $self->{paf_mongodb}->get_collection('s3_cache');
  my ($filesize, $err) = $self->get_content_length($FileToBeCached);
  $cache_coll->update_one({pid => $pid},
                          { '$set' => {size => $filesize,
                                       file => $s3_cache_file,
                                       lastview => time}, '$inc' => { viewcounter => 1 } },
                          { upsert => 1} );
}

sub cache_file{
  my $self = shift;
  my $pid = shift;
  my $FileToBeCached = shift;
  my $s3_cache_topdir = $self->{s3_cache_topdir};
  my $cachesize = $self->{'s3_cachesize'};
  # stub for catpath on UNIX
  my $volume;
  my $s3_cache_file = File::Spec->catpath($volume,$s3_cache_topdir,$FileToBeCached);
  my ($filesize, $err) = $self->get_content_length($FileToBeCached);
  return $err unless ( $err eq "OK" );
  if ( $filesize > $cachesize ) {
    return "File too big for cache. Filesize: $filesize B, Cachesize: $cachesize B. Pid: $pid."
  }
  my $return_code = "OK";
  if (! -f $s3_cache_file) {
    $self->clear_items($FileToBeCached);
    $return_code = $self->download_object_to_cache($FileToBeCached);
  } else {
    # take care of side-triggered fileupdates via api.
    my ($upstream_mtime,$err) = $self->get_upstream_timestamp($FileToBeCached);
    my $cachefile_mtime = `date -r $s3_cache_file +%s`;
    if ( $upstream_mtime > $cachefile_mtime ) {
      print "detected upstream file updates for $pid, downloading anew.\n";
      $return_code = $self->download_object_to_cache($FileToBeCached);
    } else {
      print "file $FileToBeCached ($pid) already in cache, doing nothing\n"
    }
  }
  $self->update_cache_db($pid, $FileToBeCached);
  return $return_code;
}

1;
