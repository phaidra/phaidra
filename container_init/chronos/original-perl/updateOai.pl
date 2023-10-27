#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);
use Data::Dumper;
use Log::Log4perl;
use MongoDB;
use DateTime::Format::ISO8601;

$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $inserted = 0;
my $removed = 0;
my $updated = 0;
my $created = 0;
my $deleted = 0;
my $blacklisted_pre = 0;
my $blacklisted_post = 0;

my $logconf = q(
  log4perl.category.MyLogger         = INFO, Logfile, Screen
 
  log4perl.appender.Logfile                          = Log::Dispatch::FileRotate
  log4perl.appender.Logfile.Threshold                = DEBUG
  log4perl.appender.Logfile.filename                 = /mnt/oai-logs/updateOai.log
  log4perl.appender.Logfile.max                      = 30
  log4perl.appender.Logfile.DatePattern              = yyyy-MM-dd
  log4perl.appender.Logfile.SetDate                  = CET
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

sub _getRecordUpdate {
  my ($ua, $urlsolr, $urlapi, $pid, $doc) = @_;
  
  my $recUpdate;
  if ($doc) {
    $recUpdate = $doc;

    if (exists($doc->{ispartof})) {
      my @newIspartof;
      for my $colpid (@{$doc->{ispartof}}) {
        my $coldoc = getSolrDoc($ua, $urlsolr, $colpid);
        if ($coldoc) {
          my $ucolpid = $colpid =~ s/:/_/r;
          # this is used in primo set
          $recUpdate->{"title_of_$ucolpid"} = $coldoc->{sort_dc_title};
          push @newIspartof, $colpid;
        } else {
          $log->error("pid[$pid] could not get collection[$colpid] doc to get col title");
          # if we can't get col title, it's probably inactive -> remove from ispartof
        }
      }
      $doc->{ispartof} = \@newIspartof;
    }
  } else {
    $log->info("doc pid[$pid] not found in solr, checking phaidra-api");
    my $apires = $ua->get($urlapi."/object/".$pid."/state?foxml=1")->result;
    if ($apires->code == 404) {
      if (exists($apires->json->{alerts})) {
        for my $a (@{$apires->json->{alerts}}) {
          if ($a->{msg} eq 'Not Found') {
            $log->info("pid[$pid] get state result code[".$apires->code."], fedora msg eq 'Not Found', object seems purged, flagging as deleted");
            $recUpdate->{deleted} = 1;
            $deleted++;
          }
        }
      }
    } else {
      if ($apires->code == 301) {
        if (exists($apires->json->{state})) {
          if ($apires->json->{state} eq 'Deleted') {
            $log->info("pid[$pid] get state result code[".$apires->code."] and state eq 'Deleted', flagging as deleted");
            $recUpdate->{deleted} = 1;
            $deleted++;
          }
        }
      }
    }
    unless ($recUpdate->{deleted}) {
      if (exists($apires->json->{alerts})) {
        $log->info("pid[$pid] NOT flagging as deleted, get state result code[".$apires->code."] alerts:\n".Dumper($apires->json->{alerts}));
      } else {
        $log->info("pid[$pid] NOT flagging as deleted, get state result code[".$apires->code."]");
      }
    }
  }

  $recUpdate->{update} = 0;
  $recUpdate->{updated} = time * 1000;

  return $recUpdate;
}

sub getSolrDoc {
  my ($ua, $urlsolr, $pid) = @_;

  my $doc;
  $urlsolr->query(q => "pid:\"$pid\"", rows => "1", wt => "json");
  my $solrres = $ua->get($urlsolr)->result;
  if ($solrres->is_success) {
    for my $d (@{$solrres->json->{response}->{docs}}){
      $doc = $d;
      last;
    }
  }else{
    $log->error("error getting doc pid[$pid] from solr: ".$solrres->code." ".$solrres->message);
    return;
  }

    return $doc;
}

sub getRecordUpdate {
  my ($ua, $urlsolr, $urlapi, $pid) = @_;

  my $doc = getSolrDoc($ua, $urlsolr, $pid);
  return unless $doc;

  return _getRecordUpdate($ua, $urlsolr, $urlapi, $pid, $doc);
}

sub updateRecords {
  my ($ua, $urlsolr, $urlapi, $recordsColl) = @_;

  # get mongo batch (->all documents of that batch, no ->batch or any other open cursor) sorted on pid 
  # get a solr batch where pid in mongo batch
  # check mongo batch 'updated' against solr batch 'modified' -> update record where necessary (we're not inside cursor)
  # continue with next mongo batch

  my $skip = 0;
  my $limit = 100;
  my $total;
  eval {
    $total = $recordsColl->count_documents({'deleted' => 0});
  };
  if ($@) {
    $total = $recordsColl->count({'deleted' => 0});
  }
  $log->info("checking [$total] mongo records");
  my @records;
  while ($skip < $total) {
    $log->debug("checking records [$skip - ".($skip+$limit)."]/$total");
    my @batchRecords = $recordsColl->find({'deleted' => 0}, { 'pid' => 1, 'updated' => 1 })->sort({ "pid" => 1 })->limit($limit)->skip($skip)->all;
    my %batchRecords = map { $_->{pid} => $_ } @batchRecords;
    $skip += $limit;

    my @batchPids = map ($_->{pid}, @batchRecords);
    my $q = "pid:(\"".join('" OR "', @batchPids)."\")";
    
    $urlsolr->query(q => $q, rows => $limit, wt => "json");
    my $solrres = $ua->get($urlsolr)->result;
    if ($solrres->is_success) {
      # $log->debug("solr q[$q] batch\n".Dumper($solrres->json->{response}));
      for my $d (@{$solrres->json->{response}->{docs}}){
        my $docpid = $d->{pid};
        # $log->debug("checking if solr doc $docpid in mongobatch");
        if (exists($batchRecords{$docpid})) {
          $batchRecords{$docpid}->{found} = 1;
          # $log->debug("found in mongobatch");
          if (exists($d->{modified})) {
            if ($batchRecords{$docpid}->{updated} lt (DateTime::Format::ISO8601->parse_datetime($d->{modified})->epoch * 1000)) {
              $log->info("doc pid[$docpid] needs update");
              my $recUpdate = _getRecordUpdate($ua, $urlsolr, $urlapi, $docpid, $d);
              if ($recUpdate) {
                my $mdbres = $recordsColl->update_one({ pid => $docpid }, { '$set' => $recUpdate });
                $log->debug("update result pid[$docpid] matched[".$mdbres->matched_count."]");
                $updated++;
              }
            } else {
              $log->debug("doc pid[$docpid] is up to date");
            }
          } else {
            $log->error("doc pid[$docpid] has no 'modified' field");
          }
        } else {
          $log->error("heh? pid[$docpid] not found in mongo batch");
          return undef;
        }
      }
    }else{
      $log->error("error getting solr batch for query q[$q]: ".$solrres->code." ".$solrres->message);
      return undef;
    }

    for my $r (@batchRecords) {
      unless ($r->{found}) {
        # these records are in mongobatch, but were not found in solr
        # -> possibly deleted
        $log->debug("doc pid[$r->{pid}] not found in solr batch, deleted?");
        my $recUpdate = _getRecordUpdate($ua, $urlsolr, $urlapi, $r->{pid}, undef);
        if ($recUpdate) {
          my $mdbres = $recordsColl->update_one({ pid => $r->{pid} }, { '$set' => $recUpdate });
          $log->debug("updated pid[$r->{pid}] matched[".$mdbres->matched_count."]");
          $updated++;
        }
      }
    }
  }

  return 1;
}

sub batchRemove {
  my ($recordsColl, $toremove, $setSpec) = @_;

  my @batch;
  my $ri = 0;
  for my $rem (@{$toremove}) {
    $ri++;
    push @batch, $rem;
    if ($ri >= 100) {
      my $remCount = scalar @batch;
      my $mdbres = $recordsColl->update_many({ pid => { '$in' => \@batch } }, { '$pull' => { setSpec => $setSpec }});
      $log->debug("removed [$remCount] pids from oai set[$setSpec] matched[".$mdbres->matched_count."]");
      @batch = ();
      $ri = 0;
    }
  }
  my $remCount = scalar @batch;
  if ($remCount > 0) {
    my $mdbres = $recordsColl->update_many({ pid => { '$in' => \@batch } }, { '$pull' => { setSpec => $setSpec }});
    $log->debug("removed [$remCount] pids from oai set[$setSpec] matched[".$mdbres->matched_count."]");
  }
}

sub batchAdd {
  my ($recordsColl, $docs, $setSpec) = @_;

  my @batch;
  my $ri = 0;
  for my $pid (keys %{$docs}) {
    if ($docs->{$pid}->{add}) {
      $ri++;
      push @batch, $pid;
      if ($ri >= 100) {
        my $addCount = scalar @batch;
        my $mdbres = $recordsColl->update_many({ pid => { '$in' => \@batch } }, { '$push' => { setSpec => $setSpec } });
        $log->debug("added [$addCount] pids to oai set[$setSpec] matched[".$mdbres->matched_count."]");
        @batch = ();
        $ri = 0;
      }
    }
  }
  my $addCount = scalar @batch;
  if ($addCount > 0) {
    my $mdbres = $recordsColl->update_many({ pid => { '$in' => \@batch } }, { '$push' => { setSpec => $setSpec } });
    $log->debug("added [$addCount] pids to oai set[$setSpec] matched[".$mdbres->matched_count."]");
  }
}

sub isBlacklisted {
  my ($pid, $set, $recordsBlacklistColl) = @_;

  my $blackListEntry = $recordsBlacklistColl->find_one({'pid' => $pid});
  if ($blackListEntry) {
    # if there are no sets in this blacklist entry, it's blacklisted from all sets
    unless (exists($blackListEntry->{sets})) {
      return 1
    }
    if (scalar @{$blackListEntry->{sets}} < 1) {
      return 1
    }

    # if there are sets in this blacklist entry, the blacklisting only applies to those sets
    my $skip = 0;
    for my $blacklistSet (@{$blackListEntry->{sets}}) {
      if ($blacklistSet eq $set) {
        return 1
      }
    }
  }
  return 0;
}

sub updateSetMembership {
  my ($ua, $urlsolr, $urlapi, $recordsColl, $recordsBlacklistColl, $set) = @_;

  # iterate query results
  my %members;
  $urlsolr->query(q => $set->{query}, fl => 'pid', rows => 1, start => 0, wt => 'json');
  my $solrres = $ua->get($urlsolr)->result;
  unless ($solrres->is_success) {
    $log->error("error getting docs query[$set->{query}] from solr: ".$solrres->code." ".$solrres->message);
    return;
  }
  unless ($solrres->json->{response}) {
    $log->error("error getting response query[$set->{query}] from solr");
    return;
  }
  unless (exists($solrres->json->{response}->{numFound})) {
    $log->error("error getting numFound query[$set->{query}] from solr");
    return;
  }
  my %docs = ();
  if ($solrres->json->{response}->{numFound} == 0) {
    $log->info("this set seems empty: query[$set->{query}]");
    return;
  } else {
    # we'll assume the 'query' is a reasonably sized set so that the pids fit into memory
    $urlsolr->query(q => $set->{query}, fl => 'pid', rows => $solrres->json->{response}->{numFound}, start => 0, wt => 'json');
    $solrres = $ua->get($urlsolr)->result;
    unless ($solrres->json->{response}->{docs}) {
      $log->error("error getting docs query[$set->{query}] from solr");
      return;
    }
    my @docs = @{$solrres->json->{response}->{docs}};
    %docs = map { $_->{pid} => { found => 0, add => 0 } } @docs;
  }
  my $setRecords = $recordsColl->find({'setSpec' => $set->{setSpec}}, { 'pid' => 1, 'deleted' => 1 });
  my @toremove;
  while (my $r = $setRecords->next) {
    if (exists($docs{$r->{pid}})) {
      # this record should stay in the set
      $docs{$r->{pid}}->{found} = 1;
    } else {
      # this record should be removed from this set
      # don't remove deleted records so that harvesters get the information
      unless ($r->{deleted}) {
        # do later, to not mess up the cursor
        push @toremove, $r->{pid};
        $removed++;
      }
    }
  }
  batchRemove($recordsColl, \@toremove, $set->{setSpec}) if scalar @toremove > 0;

  for my $pid (keys %docs) {

    unless($docs{$pid}->{found}) {

      # check blacklist
      # we'd do some update operation at this point anyway, so checking should not influence performance so much
      if (isBlacklisted($pid, $set->{setSpec}, $recordsBlacklistColl)) {
        $blacklisted_pre++;
        next;
      }

      # this pid's record should be added to this set
      my $rec = $recordsColl->find_one({'pid' => $pid});
      if ($rec) {
        # record already exists
        # shall be added to set
        # we're not iterating through a mongo cursor so we could do it now
        # but let's leave it to batchAdd for performance reasons
        $docs{$pid}->{add} = 1;
        $inserted++;
        $log->debug("inserted pid[$pid] to oai set[$set->{setSpec}]");
      } else {
        # record is not yet in oai -> create new one
        my $rec = getRecordUpdate($ua, $urlsolr, $urlapi, $pid);
        $rec->{pid} = $pid;
        my $now = time * 1000;
        $rec->{inserted} = $now;
        $rec->{updated} = $now;
        $rec->{deleted} = 0;
        $rec->{setSpec} = [ $set->{setSpec} ];
        # we're not iterating through a mongo cursor so we can directly add
        my $mdbres = $recordsColl->insert_one($rec);
        $log->debug("created pid[$pid] and inserted to oai set[$set->{setSpec}]");
        # $log->debug(Dumper($mdbres->assert));
        $created++;
      }
    }
  }
  batchAdd($recordsColl, \%docs, $set->{setSpec});
}

sub blacklist {
  my ($recordsColl, $recordsBlacklistColl) = @_;

  my $blacklistedRecords = $recordsBlacklistColl->find({}, { 'pid' => 1, 'sets' => 1 });
  while (my $blackListEntry = $blacklistedRecords->next) {
    my $rec = $recordsColl->find_one({'pid' => $blackListEntry->{pid}});
    # if there are no sets in this blacklist entry, it's blacklisted from all sets
    unless (exists($blackListEntry->{sets})) {
      if (scalar @{$rec->{'setSpec'}} > 0) {
        my $mdbres = $recordsColl->update_one({ pid => $blackListEntry->{pid} }, { '$set' => { 'setSpec' => [] } });
        $log->debug("update result pid[$blackListEntry->{pid}] matched[".$mdbres->matched_count."]");
        $blacklisted_post++;
      }
      next;
    }
    if (scalar @{$blackListEntry->{sets}} < 1) {
      if (scalar @{$rec->{'setSpec'}} > 0) {
        my $mdbres = $recordsColl->update_one({ pid => $blackListEntry->{pid} }, { '$set' => { 'setSpec' => [] } });
        $log->debug("update result pid[$blackListEntry->{pid}] matched[".$mdbres->matched_count."]");
        $blacklisted_post++;
      }
      next;
    }

    # if there are sets in this blacklist entry, the blacklisting only applies to those sets
    my %blacklistedSets = map { $_ => 1 }  @{$blackListEntry->{sets}};
    my @newSets;
    my $dirty = 0;
    # create new setSpec without the blacklisted sets
    for my $currentSet (@{$rec->{'setSpec'}}) {
      if($blacklistedSets{$currentSet}) {
        $dirty = 1
      } else {
        push @newSets, $currentSet;
      }
    }
    if ($dirty) {
      my $mdbres = $recordsColl->update_one({ pid => $rec->{pid} }, { '$set' => { 'setSpec' => \@newSets } });
      $log->debug("update result pid[$rec->{pid}] matched[".$mdbres->matched_count."]");
      $blacklisted_post++;
    }
  }
}

$log->info("started");

my $mdbcfg;
my $mdbclient;
my $mdb;
my $setColl;
my $recordsColl;
my $recordsBlacklistColl;

eval {
  $mdbclient=
    MongoDB::MongoClient->new(host => 'mongodb-phaidra',
                              port => 27017,
                              username => $ENV{MONGODB_PHAIDRA_USER},
                              password => $ENV{MONGODB_PHAIDRA_PASSWORD});
};

if ($@) {
  $log->error('MongoDB connection failed: '.$@);
  exit(1);
}
unless (defined ($mdbclient)) {
  $log->error('connection not established');
  exit(1);
}
eval { $mdb = $mdbclient->get_database('mongodb'); };
if ($@) {
  $log->error('MongoDB get_database failed: '.$@);
  exit(1);
}
unless (defined ($mdb)) {
  $log->error('MongoDB db not available');
  exit(1);
}
eval { $setColl = $mdb->get_collection('oai_sets'); };
if ($@) {
  $log->error('MongoDB get_collection oai_sets failed: '.$@);
  exit(1);
}
unless (defined ($setColl)) {
  $log->error('MongoDB collection oai_sets not available');
  exit(1);
}
my @sets;
my $setsCursor = $setColl->find();
while (my $s = $setsCursor->next) {
  push @sets, $s;
}
eval { $recordsColl = $mdb->get_collection('oai_records'); };
if ($@) {
  $log->error('MongoDB get_collection oai_records failed: '.$@);
  exit(1);
}
unless (defined ($recordsColl)) {
  $log->error('MongoDB collection oai_records not available');
  exit(1);
}
eval { $recordsBlacklistColl = $mdb->get_collection('oai_records_blacklist'); };
if ($@) {
  $log->error('MongoDB get_collection oai_records_blacklist failed: '.$@);
  exit(1);
}
unless (defined ($recordsBlacklistColl)) {
  $log->error('MongoDB collection oai_records_blacklist not available');
  exit(1);
}

my $ua = Mojo::UserAgent->new;

my $urlapi = "'$ENV{OUTSIDE_HTTP_SCHEME}'.$ENV{PHAIDRA_HOSTNAME}.$ENV{PHAIDRA_PORTSTUB}.$ENV{PHAIDRA_HOSTPORT}.'/api'";

my $urlsolr = Mojo::URL->new;
$urlsolr->scheme("http");
$urlsolr->host("solr");
$urlsolr->port(8983);
$urlsolr->path("/solr/phaidra/select");

$urlsolr->query(q => "*:*", rows => "1", wt => "json");
my $solrres = $ua->get($urlsolr)->result;
unless ($solrres->is_success) {
  $log->error("error querying solr: ".$solrres->code." ".$solrres->message);
  exit(1);
}

if (updateRecords($ua, $urlsolr, $urlapi, $recordsColl)) {
  for my $set (@sets) {
    $log->info("updating set setSpec[$set->{setSpec}] query[$set->{query}]");
    updateSetMembership($ua, $urlsolr, $urlapi, $recordsColl, $recordsBlacklistColl, $set);
  }
}
$log->info("checking blacklist");
blacklist($recordsColl, $recordsBlacklistColl);

$log->info("done updated[$updated] inserted_to_set[$inserted] removed_from_set[$removed] created[$created] deleted[$deleted] blacklisted_pre[$blacklisted_pre] blacklisted_post[$blacklisted_post]");

__END__


