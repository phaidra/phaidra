package PhaidraAPI::S3::Cache;

use strict;
use warnings;

use File::Path;
use File::Basename;
use FileHandle;

use Net::Amazon::S3;
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
  if (! defined $s3_key) {
    print "S3 key not available.\n";
  } else {
    $filesize = $s3_key->{'content_length'}+0;
  }
  return $filesize;
}

sub download_object_to_cache{
  my $self = shift;
  my $FileToBeCached = shift;
  my $bucket_connection = $self->get_bucket_connection();
  my ($file, $basepath, $suffix) = fileparse($FileToBeCached);
  if (! -d $basepath) {
    File::Path::make_path($basepath);
  }
  $bucket_connection->get_key_filename( $FileToBeCached, 'GET', $FileToBeCached );
  if (! -f $FileToBeCached) {
    print "Something went wrong fetching S3 object.\n";
  } else {
    print "Object downloaded to $FileToBeCached\n";
  }
  return 0;
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
  return $current_cache;
}

sub check_cleanup_size{
  my $self = shift;
  my $FileToBeCached = shift;
  my $currently_used = $self->get_current_cachesize();
  my $filesize = $self->get_content_length($FileToBeCached);
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
}


sub update_cache_db{
  my $self = shift;
  my $pid = shift;
  my $FileToBeCached = shift;
  my $cache_coll = $self->{paf_mongodb}->get_collection('s3_cache');
  my $filesize = $self->get_content_length($FileToBeCached);
  $cache_coll->update_one({pid => $pid},
                          { '$set' => {size => $filesize,
                                       file => $FileToBeCached,
                                       lastview => time}, '$inc' => { viewcounter => 1 } },
                          { upsert => 1} );
}

sub cache_file{
  my $self = shift;
  my $pid = shift;
  my $FileToBeCached = shift;
  if (! -f $FileToBeCached) {
    $self->clear_items($FileToBeCached);
    $self->download_object_to_cache($FileToBeCached);
  } else {
    print "file $FileToBeCached already in cache, doing nothing\n"
  }
  $self->update_cache_db($pid, $FileToBeCached);
}

1;
