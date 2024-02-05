package PhaidraAPI::Model::Search;

use strict;
use warnings;
use v5.10;
use XML::Parser::PerlSAX;
use XML::XPath;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Fedora;
use base qw/Mojo::Base/;

sub triples {
  my $self  = shift;
  my $c     = shift;
  my $query = shift;
  my $limit = shift;

  my $res = {alerts => [], status => 200};

  my %params;
  $params{dt}     = 'on';
  $params{lang}   = 'spo';
  $params{format} = 'N-Triples';
  $params{limit}  = $limit if $limit;
  $params{query}  = $query;
  $params{type}   = 'triples';

  my $url = Mojo::URL->new;
  $url->scheme($c->app->config->{fedora}->{scheme} ? $c->app->config->{fedora}->{scheme} : 'https');
  $url->host($c->app->config->{phaidra}->{fedorabaseurl});
  $url->path("/fedora/risearch");
  $url->query(\%params);

  my $ua    = Mojo::UserAgent->new;
  my $txres = $ua->post($url)->result;

  if ($txres->is_success) {

    my @a;
    my $str = $txres->body;
    while ($str =~ /([^\n]+)\n?/g) {
      my $line = $1;

      #$c->app->log->debug("line: $line");
      #my @spo = split(' ', $line);
      #push @a, [$spo[0], $spo[1], $spo[2]];
      $line =~ /([^\s]+) ([^\s]+) ([^\n]+)/g;
      my $o = $3;
      chop($o) if (substr($o, -1) eq '.');
      chop($o) if (substr($o, -1) eq ' ');

      #$c->app->log->debug("\nsub: $1 \npred: $2 \nobj: $3");
      push @a, [$1, $2, $o];
    }

    $res->{result} = \@a;

  }
  else {
    unshift @{$res->{alerts}}, {type => 'error', msg => $txres->message};
    $res->{status} = $txres->code;
  }

  return $res;
}

sub related_objects_itql() {

  my ($self, $c, $subject, $relation, $right, $offset, $limit) = @_;

  my $res = {alerts => [], status => 200};

  my $rel = '<info:fedora/' . $subject . '> <' . $relation . '> $item';
  if ($right) {
    $rel = '$item <' . $relation . '> <info:fedora/' . $subject . '>';
  }

  my $count;
  my $relcount = '
	select count(
		select $item
		from <#ri>
		where
		$item <http://www.openarchives.org/OAI/2.0/itemID> $itemID and
		' . $rel . ' and
		$item <info:fedora/fedora-system:def/model#state> <info:fedora/fedora-system:def/model#Active>)
	from <#ri>
	where
	$item <http://www.openarchives.org/OAI/2.0/itemID> $itemID and
	' . $rel . ' and
	$item <info:fedora/fedora-system:def/model#state> <info:fedora/fedora-system:def/model#Active>';

  my $result = $self->risearch_tuple($c, $relcount);
  if ($result->{status} ne 200) {
    unshift @{$res->{alerts}}, $result->{alerts};
    $res->{status} = $result->{status};
    return $res;
  }
  my $xp      = XML::XPath->new(xml => $res->{result});
  my $nodeset = $xp->findnodes('//result');
  foreach my $node ($nodeset->get_nodelist) {
    $count = int($node->findvalue('k0'));
    last;    # should be only one
  }

  my $query = '
	select $itemID $title $cmodel
	from <#ri>
	where
	$item <http://www.openarchives.org/OAI/2.0/itemID> $itemID and
	' . $rel . ' and
	$item <info:fedora/fedora-system:def/model#state> <info:fedora/fedora-system:def/model#Active> and
	$item <http://purl.org/dc/elements/1.1/title> $title and
	$item <info:fedora/fedora-system:def/model#hasModel> $cmodel
	minus $cmodel <mulgara:is> <info:fedora/fedora-system:FedoraObject-3.0>
	order by $itemID asc';

  if ($limit) {
    $query .= ' limit ' . $limit;
  }
  if ($offset) {
    $query .= ' offset ' . $offset;
  }

  $result = $self->risearch_tuple($c, $query, $offset, $limit);
  if ($result->{status} ne 200) {
    unshift @{$res->{alerts}}, $result->{alerts};
    $res->{status} = $result->{status};
    return $res;
  }

  my @objects;
  my $oaiid = $c->{config}->{phaidra}->{proaiRepositoryIdentifier};
  $xp      = XML::XPath->new(xml => $res->{result});
  $nodeset = $xp->findnodes('//result');
  foreach my $node ($nodeset->get_nodelist) {

    my $cmodel = $node->findvalue('cmodel/@uri');

    if ($cmodel =~ m/fedora-system/) {
      next;
    }

    $cmodel =~ s/^info:fedora\/cmodel:(.*)$/$1/;

    my $itemID = $node->findvalue('itemID/@uri');
    $itemID =~ s/^info:fedora\/oai:$oaiid:(.*)$/$1/;
    $itemID =~ s/^oai:$oaiid:(.*)$/$1/;                # the second format without info:fedora/, used by phaidraimporter

    push @objects,
      {
      pid    => $itemID,
      title  => $node->findvalue('title'),
      cmodel => $cmodel
      };
  }

  $res->{objects} = \@objects;
  $res->{hits}    = $count;
  return $res;
}

sub risearch_tuple ($$$) {
  my ($self, $c, $query, $offset, $limit) = @_;

  my $res = {alerts => [], status => 200};

  my %params;
  $params{lang}   = 'itql';
  $params{type}   = 'tuples';
  $params{format} = 'Sparql';
  $params{limit}  = $limit  if $limit;
  $params{offset} = $offset if $offset;
  $params{query}  = $query;

  my $url = Mojo::URL->new;
  $url->scheme($c->app->config->{fedora}->{scheme} ? $c->app->config->{fedora}->{scheme} : 'https');
  $url->host($c->app->config->{phaidra}->{fedorabaseurl});
  $url->path("/fedora/risearch");
  $url->query(\%params);

  my $ua = Mojo::UserAgent->new;
  my $tx = $ua->post($url)->result;

  if ($tx->is_success) {
    $res->{result} = $tx->body;
  }
  else {
    unshift @{$res->{alerts}}, {type => 'error', msg => $tx->message};
    $res->{status} = $tx->code;
  }

  return $res;

}

sub related_objects_mptmysql() {

  my ($self, $c, $subject, $relation, $right, $offset, $limit, $fields) = @_;

  my $res = {alerts => [], status => 200};

  my $oaiid = $c->config->{phaidra}->{proaiRepositoryIdentifier};

  my $ss = qq/SELECT pKey, p FROM tMap/;

  my $sth = $c->app->db_triplestore->dbh->prepare($ss) or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
  $sth->execute()                                      or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
  my ($num, $rel);
  $sth->bind_columns(undef, \$num, \$rel) or $c->app->log->error($c->app->db_triplestore->dbh->errstr);

  my %relmap;
  while ($sth->fetch()) {
    $relmap{$rel} = $num;
  }
  $sth->finish();

  my $staterel   = '<info:fedora/fedora-system:def/model#state>';
  my $statetable = 't' . $relmap{$staterel};

  # if triple store does not know the relation or relation is not provided
  # then there are no related objects
  if (defined($relation) && !(exists($relmap{"<$relation>"}))) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Unknown relation"};
    $res->{status} = 400;
    return $res;
  }

  my $relationtable = 't' . $relmap{"<$relation>"};

  my $activestr = '<info:fedora/fedora-system:def/model#Active>';

  my $reljoin  = "LEFT JOIN $relationtable ON $relationtable.o=$statetable.s";
  my $relwhere = "$relationtable.s=?";
  if ($right) {
    $reljoin  = "LEFT JOIN $relationtable ON $relationtable.s=$statetable.s";
    $relwhere = "$relationtable.o=?";
  }

  # group by subject, because there might be multiple titles
  my $titsep = '#tit-sep#';
  $ss = "
		SELECT SQL_CALC_FOUND_ROWS $statetable.s AS subject
		FROM
		$statetable
		$reljoin
		WHERE $statetable.o = ? AND $relwhere
		GROUP BY subject
		ORDER BY $statetable.s ASC
		";

  if ($limit) {
    $ss .= " LIMIT $limit";
  }
  if ($offset) {
    $ss .= " OFFSET $offset";
  }

  #$c->app->log->debug("Related objects query: ".$ss);

  $sth = $c->app->db_triplestore->dbh->prepare($ss)           or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
  $sth->execute($activestr, '<info:fedora/' . $subject . '>') or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
  my ($pid);
  $sth->bind_columns(undef, \$pid) or $c->app->log->error($c->app->db_triplestore->dbh->errstr);

  my @objects;
  while ($sth->fetch()) {
    if (defined($oaiid) && $pid =~ m#^<info:fedora/oai:$oaiid:(.*)>$#) {
      $pid = $1;
    }
    elsif ($pid =~ m#^<info:fedora/(.*)>$#) {
      $pid = $1;
    }
    else {
      next;
    }

    push @objects,
      {
      pid    => $pid,
      title  => '',
      titles => [],
      cmodel => ''
      };
  }
  $sth->finish();

  $ss  = qq/SELECT FOUND_ROWS();/;
  $sth = $c->app->db_triplestore->dbh->prepare($ss) or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
  $sth->execute() or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
  my $count;
  $sth->bind_columns(undef, \$count) or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
  $sth->fetch();
  $sth->finish();

  # get title	 and cmodel
  my $titlerel = '<http://purl.org/dc/elements/1.1/title>';
  my $modelrel = '<info:fedora/fedora-system:def/model#hasModel>';

  #my $itemidrel = '<http://www.openarchives.org/OAI/2.0/itemID>';

  my $descrel   = '<http://purl.org/dc/elements/1.1/description>';
  my $desctable = 't' . $relmap{$descrel};
  my $descsep   = '#desc-sep#';

  #my $itemidtable = 't'.$relmap{$itemidrel};
  my $titletable = 't' . $relmap{$titlerel};
  my $modeltable = 't' . $relmap{$modelrel};
  #
  my $fedoraobjstr = '<info:fedora/fedora-system:FedoraObject-3.0>';

  foreach my $o (@objects) {

    $ss
      = qq/SELECT a.pid, a.title, a.titles, a.cmodel, $desctable.o AS description, GROUP_CONCAT($desctable.o SEPARATOR '$descsep') AS descriptions FROM $desctable RIGHT JOIN (SELECT $titletable.s AS pid, $titletable.o AS title, GROUP_CONCAT($titletable.o SEPARATOR '$titsep') AS titles, $modeltable.o AS cmodel FROM $titletable JOIN $modeltable ON $modeltable.s = $titletable.s WHERE $titletable.s = ? AND $modeltable.o != ?) AS a ON $desctable.s = a.pid/;

    $sth = $c->app->db_triplestore->dbh->prepare($ss)               or $c->app->log->error($c->app->db_triplestore->dbh->errstr);
    $sth->execute('<info:fedora/' . $o->{pid} . '>', $fedoraobjstr) or $c->app->log->error($c->app->db_triplestore->dbh->errstr);

    my ($pid, $title, $titles, $cmodel, $desc, $descs);
    $sth->bind_columns(undef, \$pid, \$title, \$titles, \$cmodel, \$desc, \$descs) or $c->app->log->error($c->app->db_triplestore->dbh->errstr);

    while ($sth->fetch()) {

      my @titles = split($titsep, $titles);
      my @titles_out;
      my $session_lang = 'ita';
      my $pref_title   = '';
      my $en_title     = '';
      my $text         = '';
      foreach my $t (@titles) {
        my $lang = '';
        $text = $t;
        if ($t =~ m/"@([^@]+)$/) {
          $lang = $1;
          $text =~ s/$lang$//g;
          $text =~ s/\@$//g;
          $text =~ s/^"|"$//g;
          $text =~ s/\\"/"/g;

          # unicode escaped stuff to utf8
          $text =~ s/\\u([0-9a-fA-F]{4})/pack('U', hex($1))/eg;

          if ($lang eq $session_lang) {
            $pref_title = $text;
          }
          if ($lang eq 'eng') {
            $en_title = $text;
          }
        }
        else {
          $text =~ s/^"|"$//g;
          $text =~ s/\\"/"/g;

          # unicode escaped stuff to utf8
          $text =~ s/\\u([0-9a-fA-F]{4})/pack('U', hex($1))/eg;
        }
        push @titles_out, {text => $text, lang => $lang};
      }

      if ($pref_title eq '') {
        if ($en_title ne '') {
          $pref_title = $en_title;
        }
        else {
          $pref_title = $text;
        }
      }

      foreach my $field (@{$fields}) {
        if ($field eq 'dc.description') {
          my @descs = split($descsep, $descs);
          my @descs_out;
          my $session_lang = 'ita';
          my $pref_desc    = '';
          my $en_desc      = '';
          my $text         = '';
          foreach my $t (@descs) {
            my $lang = '';
            $text = $t;
            if ($t =~ m/"@([^@]+)$/) {
              $lang = $1;
              $text =~ s/$lang$//g;
              $text =~ s/\@$//g;
              $text =~ s/^"|"$//g;
              $text =~ s/\\"/"/g;

              # unicode escaped stuff to utf8
              $text =~ s/\\u([0-9a-fA-F]{4})/pack('U', hex($1))/eg;

              if ($lang eq $session_lang) {
                $pref_desc = $text;
              }
              if ($lang eq 'eng') {
                $en_desc = $text;
              }
            }
            else {
              $text =~ s/^"|"$//g;
              $text =~ s/\\"/"/g;
              $text =~ s/\\u([0-9a-fA-F]{4})/pack('U', hex($1))/eg;
            }
            push @descs_out, {text => $text, lang => $lang};
          }

          if ($pref_desc eq '') {
            if ($en_desc ne '') {
              $pref_desc = $en_desc;
            }
            else {
              $pref_desc = $text;
            }
          }
          $o->{description}  = $pref_desc;
          $o->{descriptions} = \@descs_out;
        }
      }

      $o->{title}  = $pref_title;
      $o->{titles} = \@titles_out;
      $cmodel =~ s/^<info:fedora\/(.*)>$/$1/;
      $o->{cmodel} = $cmodel;

    }

    $sth->finish();
  }

  $res->{objects} = \@objects;
  $res->{hits}    = $count;
  return $res;
}

sub related {

  my ($self, $c, $pid, $relation, $right, $from, $limit, $fields) = @_;

  # on frontend the first item is 1, but in triplestore its 0
  if ($from > 0) {
    $from--;
  }

  my $from_orig;
  my $limit_orig;
  if ($relation eq 'info:fedora/fedora-system:def/relations-external#hasCollectionMember') {

    # if we want to sort, we have to get them all, currently position is not in triplestore
    $from_orig  = $from;
    $limit_orig = $limit;
    $from       = 0;
    $limit      = 0;
  }

  my $sr;
  if ($c->config->{phaidra}->{triplestore} eq "localMysqlMPTTriplestore") {
    $sr = $self->related_objects_mptmysql($c, $pid, $relation, $right, $from, $limit, $fields);
  }
  else {
    $sr = $self->related_objects_itql($c, $pid, $relation, $right, $from, $limit, $fields);
  }

  if ($relation eq 'info:fedora/fedora-system:def/relations-external#hasCollectionMember') {

    my %members;
    foreach my $o (@{$sr->{objects}}) {
      $o->{'pos'} = undef;
      $members{$o->{pid}} = $o;
    }

    my $ce = $self->datastream_exists($c, $pid, 'COLLECTIONORDER');
    if ($ce->{status} ne 200) {
      $c->app->log->error("Cannot find out if COLLECTIONORDER exists for pid: $pid and username: " . $c->stash->{basic_auth_credentials}->{username});
    }
    else {
      if ($ce->{'exists'}) {
        my $object_model = PhaidraAPI::Model::Object->new;
        my $ores         = $object_model->get_datastream($c, $pid, 'COLLECTIONORDER', undef, undef, 1);
        if ($ores->{status} ne 200) {
          $c->app->log->error("Cannot get COLLECTIONORDER for pid: $pid and username: " . $c->stash->{basic_auth_credentials}->{username});
        }
        else {

          # order members
          my $xml = Mojo::DOM->new();
          $xml->xml(1);
          $xml->parse($ores->{COLLECTIONORDER});
          $xml->find('member[pos]')->each(
            sub {
              my $m   = shift;
              my $pid = $m->text;
              $members{$pid}->{'pos'} = $m->{'pos'};
            }
          );

          sub undef_sort {
                $a->{pos} eq "" && $b->{pos} eq "" ? 0
              : $a->{pos} eq ""                    ? +1
              : $b->{pos} eq ""                    ? -1
              :                                      $a->{pos} cmp $b->{pos};
          }
          @{$sr->{objects}} = sort undef_sort @{$sr->{objects}};

        }
      }
    }

    # now use 'from' and 'limit' to return only the page
    if ($limit_orig > 0) {
      @{$sr->{objects}} = splice(@{$sr->{objects}}, $from_orig, $limit_orig);
    }
    else {
      @{$sr->{objects}} = splice(@{$sr->{objects}}, $from_orig);
    }

  }

  return $sr;
}

sub datastream_exists {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;
  my $dsid = shift;

  my $res = {alerts => [], status => 200};

  if ($c->app->config->{fedora}->{version} >= 6) {
    my $exists       = 0;
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $propres      = $fedora_model->getObjectProperties($c, $pid);
    if ($propres->{status} ne 200) {
      return $propres;
    }
    if (exists($propres->{contains})) {
      for my $contains (@{$propres->{contains}}) {
        if ($contains eq $dsid) {
          $exists = 1;
          last;
        }
      }
    }
    $res->{'exists'} = $exists;
  }
  else {

    my $triplequery = "<info:fedora/$pid> <info:fedora/fedora-system:def/view#disseminates> <info:fedora/$pid/$dsid>";

    my %params;
    $params{dt}     = 'on';
    $params{format} = 'count';
    $params{lang}   = 'spo';
    $params{limit}  = '1';
    $params{query}  = $triplequery;
    $params{type}   = 'triples';

    my $url = Mojo::URL->new;
    $url->scheme($c->app->config->{fedora}->{scheme} ? $c->app->config->{fedora}->{scheme} : 'https');
    $url->host($c->app->config->{phaidra}->{fedorabaseurl});
    $url->path("/fedora/risearch");
    $url->query(\%params);

    my $ua    = Mojo::UserAgent->new;
    my $txres = $ua->post($url)->result;

    if ($txres->is_success) {
      $res->{'exists'} = scalar($txres->body);
    }
    else {
      unshift @{$res->{alerts}}, {type => 'error', msg => $txres->message};
      $res->{status} = $txres->code;
    }
  }

  return $res;
}

sub get_state {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  my $sr = $self->triples($c, "<info:fedora/$pid> <info:fedora/fedora-system:def/model#state> *");
  push @{$res->{alerts}}, @{$sr->{alerts}} if scalar @{$sr->{alerts}} > 0;
  $res->{status} = $sr->{status};
  if ($sr->{status} ne 200) {
    return $res;
  }

  foreach my $statement (@{$sr->{result}}) {
    if (@{$statement}[2] =~ m/info:fedora\/fedora-system:def\/model#(\w+)/) {
      $res->{state} = $1;
      return $res;
    }
  }

  unshift @{$res->{alerts}}, {type => 'error', msg => "Cannot determine status"};
  $res->{status} = 500;
  return $res;

}

sub get_ownerid {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  if ($c->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $r            = $fedora_model->getObjectProperties($c, $pid);
    if ($r->{status} ne 200) {
      return $r;
    }
    $res->{ownerid} = $r->{owner};
    return $res;
  }

  my $sr = $self->triples($c, "<info:fedora/$pid> <info:fedora/fedora-system:def/model#ownerId> *");
  push @{$res->{alerts}}, @{$sr->{alerts}} if scalar @{$sr->{alerts}} > 0;
  $res->{status} = $sr->{status};
  if ($sr->{status} ne 200) {
    return $res;
  }

  foreach my $statement (@{$sr->{result}}) {
    $res->{ownerid} = @{$statement}[2];
    return $res;
  }

  unshift @{$res->{alerts}}, {type => 'error', msg => "Cannot determine ownerId"};
  $res->{status} = 500;
  return $res;
}

sub get_last_modified_date {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  my $sr = $self->triples($c, "<info:fedora/$pid> <info:fedora/fedora-system:def/view#lastModifiedDate> *");
  push @{$res->{alerts}}, @{$sr->{alerts}} if scalar @{$sr->{alerts}} > 0;
  $res->{status} = $sr->{status};
  if ($sr->{status} ne 200) {
    return $res;
  }

  foreach my $statement (@{$sr->{result}}) {
    if (@{$statement}[2] =~ m/\"([\d\-\:\.TZ]+)\"/) {
      $res->{lastmodifieddate} = $1;
      return $res;
    }
  }

  unshift @{$res->{alerts}}, {type => 'error', msg => "Cannot get lastModifiedDate"};
  $res->{status} = 500;
  return $res;
}

sub get_cmodel {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  my $cmodel;
  my $cachekey = 'cmodel_' . $pid;
  unless ($cmodel = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");
    if ($c->app->config->{fedora}->{version} >= 6) {
      my $fedora_model = PhaidraAPI::Model::Fedora->new;
      my $r            = $fedora_model->getObjectProperties($c, $pid);
      if ($r->{status} ne 200) {
        return $r;
      }
      $cmodel = $r->{cmodel};
    }
    else {
      my $r = $self->triples($c, "<info:fedora/$pid> <info:fedora/fedora-system:def/model#hasModel> *");
      if ($r->{status} ne 200) {
        return $r;
      }

      for my $t (@{$r->{result}}) {
        next if (@{$t}[2] =~ m/fedora-system/g);

        @{$t}[2] =~ m/<(info:fedora\/)(\w+):(\w+)>/g;

        if ($2 eq 'cmodel' && defined($3) && ($3 ne '')) {
          $cmodel = $3;
        }
      }
    }
    $c->app->chi->set($cachekey, $cmodel, '1 day');
  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  $res->{cmodel} = $cmodel;
  return $res;
}

sub get_book_for_page {
  my $self    = shift;
  my $c       = shift;
  my $pagepid = shift;

  my $res = {alerts => [], status => 200};

  my $bookpid;
  my $cachekey = 'bookforpage_' . $pagepid;
  unless ($bookpid = $c->app->chi->get($cachekey)) {
    $c->app->log->debug("[cache miss] $cachekey");

    my $search_model = PhaidraAPI::Model::Search->new;

    # todo: add hasMember as well (new books)
    my $r = $search_model->triples($c, "* <info:fedora/fedora-system:def/relations-external#hasCollectionMember> <info:fedora/$pagepid>");
    if ($r->{status} ne 200) {
      return $r;
    }

    for my $t (@{$r->{result}}) {
      next if (@{$t}[0] =~ m/fedora-system/g);
      @{$t}[0] =~ m/<(info:fedora\/)(\w+:[0-9]+)>/g;
      $bookpid = $2;
    }

    $c->app->chi->set($cachekey, $bookpid, '1 day');
  }
  else {
    $c->app->log->debug("[cache hit] $cachekey");
  }

  $res->{bookpid} = $bookpid;
  return $res;
}

sub datastreams_hash {
  my $self = shift;
  my $c    = shift;
  my $pid  = shift;

  my $res = {alerts => [], status => 200};

  if ($c->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    return $fedora_model->getDatastreamsHash($c, $pid);
  }

  my $sr = $self->triples($c, "<info:fedora/$pid> <info:fedora/fedora-system:def/view#disseminates> *");
  push @{$res->{alerts}}, @{$sr->{alerts}} if scalar @{$sr->{alerts}} > 0;
  $res->{status} = $sr->{status};
  if ($sr->{status} ne 200) {
    return $res;
  }

  my %dsh;
  foreach my $statement (@{$sr->{result}}) {
    if (@{$statement}[2] =~ m/info:fedora\/o:[0-9]+\/([A-Z_\-]+)/) {
      $dsh{$1} = 1;
    }
  }

  $res->{dshash} = \%dsh;

  return $res;
}

sub get_pids {
  my ($self, $c, $query) = @_;

  my @pids;
  my $res = {alerts => [], status => 200};

  my $ua = Mojo::UserAgent->new;

  my $urlget = Mojo::URL->new;
  $urlget->scheme($c->app->config->{solr}->{scheme});
  $urlget->host($c->app->config->{solr}->{host});
  $urlget->port($c->app->config->{solr}->{port});
  if ($c->app->config->{solr}->{path}) {
    $urlget->path("/" . $c->app->config->{solr}->{path} . "/solr/" . $c->app->config->{solr}->{core} . "/select");
  }
  else {
    $urlget->path("/solr/" . $c->app->config->{solr}->{core} . "/select");
  }

  # get numFound
  $urlget->query(q => $query, fl => "pid", rows => "0", wt => "json");
  my $get = $ua->get($urlget)->result;
  my $numFound;
  if ($get->is_success) {
    $numFound = $get->json->{response}->{numFound};
    $c->app->log->debug("get_pids: found $numFound");
  }
  else {
    $c->app->log->error("error getting count " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting count"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  # get results
  $urlget->query(q => $query, fl => "pid", rows => $numFound, wt => "json");

  # $urlget->query(q => $query, fl => "pid,dc_identifier", rows => $numFound, wt => "json");
  $get = $ua->get($urlget)->result;

  if ($get->is_success) {
    for my $d (@{$get->json->{response}->{docs}}) {

      #			my $ac;
      #			for my $dcid (@{$d->{dc_identifier}}){
      #				if($dcid =~ /^AC/g){
      #					$ac = $dcid;
      #				}
      #			}
      #     push @pids, $d->{pid}.';'.$ac;

      push @pids, $d->{pid};
    }
  }
  else {
    $c->app->log->error("error getting results " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting results"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  $res->{pids} = \@pids;

  return $res;
}

1;
__END__
