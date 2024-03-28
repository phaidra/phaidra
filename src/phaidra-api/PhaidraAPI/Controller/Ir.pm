package PhaidraAPI::Controller::Ir;

use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(encode decode);
use Mojo::ByteStream qw(b);
use Mojo::URL;
use Mojo::UserAgent;
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Collection;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Rights;
use PhaidraAPI::Model::Index;
use PhaidraAPI::Model::Jsonld;
use Time::HiRes qw/tv_interval gettimeofday/;
use Storable qw(dclone);
use POSIX qw/strftime/;
use MIME::Lite;
use MIME::Lite::TT::HTML;
use DateTime;
use DateTime::Format::ISO8601;

our $ir2pureVersion = {

  # AO
  "https://pid.phaidra.org/vocabulary/TV31-080M" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/authorsversion",

  # SMUR
  "https://pid.phaidra.org/vocabulary/JTD4-R26P" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/preprint",

  # AM
  "https://pid.phaidra.org/vocabulary/PHXV-R6B3" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/other",

  # P
  "https://pid.phaidra.org/vocabulary/83ZP-CPP2" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/proof",

  # VoR
  "https://pid.phaidra.org/vocabulary/PMR8-3C8D" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/publishersversion",

  # CVoR
  "https://pid.phaidra.org/vocabulary/MT1G-APSB" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/other",

  # EVoR
  "https://pid.phaidra.org/vocabulary/SSQW-AP1S" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/other",

  # NA
  "https://pid.phaidra.org/vocabulary/KZB5-0F5G" => "/dk/atira/pure/researchoutput/electronicversion/versiontype/other"
};

our $ir2pureAccess = {

  # open
  "https://pid.phaidra.org/vocabulary/QW5R-NG4J" => "/dk/atira/pure/core/openaccesspermission/open",

  # embargoed
  "https://pid.phaidra.org/vocabulary/AVFC-ZZSZ" => "/dk/atira/pure/core/openaccesspermission/embargoed",

  # restricted
  "https://pid.phaidra.org/vocabulary/KC3K-CCGM" => "/dk/atira/pure/core/openaccesspermission/restricted",

  # metadata only
  "https://pid.phaidra.org/vocabulary/QNGE-V02H" => "/dk/atira/pure/core/openaccesspermission/closed"
};

our $ir2pureLicense = {
  "http://rightsstatements.org/vocab/InC/1.0/"           => "/dk/atira/pure/core/document/licenses/unspecified",
  "http://creativecommons.org/licenses/by/4.0/"          => "/dk/atira/pure/core/document/licenses/cc_by",
  "http://creativecommons.org/licenses/by-nc/4.0/"       => "/dk/atira/pure/core/document/licenses/cc_by_nc",
  "http://creativecommons.org/licenses/by-nc-nd/4.0/"    => "/dk/atira/pure/core/document/licenses/cc_by_nc_nd",
  "http://creativecommons.org/licenses/by-nc-sa/4.0/"    => "/dk/atira/pure/core/document/licenses/cc_by_nc_sa",
  "http://creativecommons.org/licenses/by-nd/4.0/"       => "/dk/atira/pure/core/document/licenses/cc_by_nd",
  "http://creativecommons.org/licenses/by-sa/4.0/"       => "/dk/atira/pure/core/document/licenses/cc_by_sa",
  "http://creativecommons.org/publicdomain/mark/1.0/"    => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by/3.0/"          => "/dk/atira/pure/core/document/licenses/cc_by_3_0",
  "http://creativecommons.org/licenses/by-nc/3.0/"       => "/dk/atira/pure/core/document/licenses/cc_by_nc_3_0",
  "http://creativecommons.org/licenses/by-nc-nd/3.0/"    => "/dk/atira/pure/core/document/licenses/cc_by_nc_nd_3_0",
  "http://creativecommons.org/licenses/by-nc-sa/3.0/"    => "/dk/atira/pure/core/document/licenses/cc_by_nc_sa_3_0",
  "http://creativecommons.org/licenses/by-nd/3.0/"       => "/dk/atira/pure/core/document/licenses/cc_by_nd_3_0",
  "http://creativecommons.org/licenses/by-sa/3.0/"       => "/dk/atira/pure/core/document/licenses/cc_by_sa_3_0",
  "http://creativecommons.org/licenses/by/3.0/at/"       => "/dk/atira/pure/core/document/licenses/cc_by_3_0_at",
  "http://creativecommons.org/licenses/by-nc/3.0/at/"    => "/dk/atira/pure/core/document/licenses/cc_by_nc_3_0_at",
  "http://creativecommons.org/licenses/by-nc-nd/3.0/at/" => "/dk/atira/pure/core/document/licenses/cc_by_nc_nd_3_0_at",
  "http://creativecommons.org/licenses/by-nc-sa/3.0/at/" => "/dk/atira/pure/core/document/licenses/cc_by_nc_sa_3_0_at",
  "http://creativecommons.org/licenses/by-nd/3.0/at/"    => "/dk/atira/pure/core/document/licenses/cc_by_nd_3_0_at",
  "http://creativecommons.org/licenses/by-sa/3.0/at/"    => "/dk/atira/pure/core/document/licenses/cc_by_sa_3_0_at",
  "http://creativecommons.org/licenses/by/2.0/"          => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nc/2.0/"       => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nc-nd/2.0/"    => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nc-sa/2.0/"    => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nd/2.0/"       => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-sa/2.0/"       => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by/2.0/at/"       => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nc/2.0/at/"    => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nc-nd/2.0/at/" => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nc-sa/2.0/at/" => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-nd/2.0/at/"    => "/dk/atira/pure/core/document/licenses/other",
  "http://creativecommons.org/licenses/by-sa/2.0/at/"    => "/dk/atira/pure/core/document/licenses/other"
};

sub notifications {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  $self->app->log->debug("=== params ===");
  for my $pn (@{$self->req->params->names}) {
    $self->app->log->debug($pn);
  }
  $self->app->log->debug("==============");

  my $pid = $self->param('pid');

  unless ($pid) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No pid sent.'}]}, status => 400);
    return;
  }

  my @pids;

  push @pids, $pid;

  my $alternatives = $self->every_param('alternatives[]');

  if ($alternatives) {
    if (ref($alternatives) eq 'ARRAY') {
      for my $apid (@$alternatives) {
        push @pids, $apid;
      }
    }
    else {
      push @pids, $alternatives;
    }
  }

  my $notification = $self->param('notification');
  if ($notification) {
    $self->addAlert('mdcheck', \@pids, $username);
  }
  my $embargonotification = $self->param('embargonotification');
  if ($embargonotification) {
    $self->addAlert('embargo', \@pids, $username);
  }

  $self->render(json => $res, status => $res->{status});
}

sub addEvent {
  my ($self, $eventtype, $pids, $username) = @_;

  my $time = strftime "%Y-%m-%dT%H:%M:%SZ", (gmtime);

  foreach my $pid (@$pids) {
    if ($eventtype eq 'submit') {

      # do not add double 'submits'
      my $check_ss  = qq/SELECT * FROM event WHERE user_id = ? AND event_type = 'submit' AND pid = ? LIMIT 1/;
      my $check_sth = $self->app->db_ir->dbh->prepare($check_ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
      $check_sth->execute($username, $pid) or $self->app->log->error($self->app->db_ir->dbh->errstr);
      if ($check_sth->rows) {
        $self->app->log->info("IR skipping addEvent (username=" . $username . ", alerttype=$eventtype, pids=$pid), already added.");
        next;
      }
    }
    $self->app->log->info("IR addEvent (username=" . $username . ", alerttype=$eventtype, pids=$pid)");
    my $ss  = qq/INSERT INTO event (event_type, pid, user_id, gmtimestamp) VALUES (?,?,?,?)/;
    my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
    $sth->execute($eventtype, $pid, $username, $time) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  }
}

sub addAlert {
  my ($self, $alerttype, $pidsArr, $username) = @_;

  my $pids = join(',', @{$pidsArr});

  if ($self->hasAlerts($alerttype, $pids, $username)) {
    $self->app->log->info("IR skipping addAlert (username=" . $username . ", alerttype=$alerttype, pids=$pids), already added.");
  }
  else {
    $self->app->log->info("IR addAlert (username=" . $username . ", alerttype=$alerttype, pids=$pids)");
    my $time = strftime "%Y-%m-%dT%H:%M:%SZ", (gmtime);
    my $ss   = qq/INSERT INTO alert (username,alert_type,pids,gmtimestamp,processed) VALUES (?,?,?,?,?)/;
    my $sth  = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
    $sth->execute($username, $alerttype, $pids, $time, 0) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  }
}

sub hasAlerts {
  my ($self, $alerttype, $pids, $username) = @_;

  my $ss  = qq/SELECT * FROM alert WHERE username = ? AND alert_type = ? AND pids = ? LIMIT 1/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute($username, $alerttype, $pids) or $self->app->log->error($self->app->db_ir->dbh->errstr);

  return $sth->rows;
}

sub getAlertForPid {
  my ($self, $alerttype, $pids) = @_;

  my $ss  = qq/SELECT id, username, pids FROM alert WHERE alert_type = ? AND processed = 0 AND alert.pids LIKE ?;/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute($alerttype, $pids) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  my ($id, $username, $pids_out);
  $sth->bind_columns(\$id, \$username, \$pids_out) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  while ($sth->fetch()) {
    return {id => $id, username => $username, pids => $pids_out};
  }
}

sub setAlertProcessed {
  my ($self, $id) = @_;

  $self->app->log->info("Ir::setAlertProcessed id[$id]");
  my $ss  = qq/UPDATE alert SET processed = 1 WHERE id = ?;/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute($id) or $self->app->log->error($self->app->db_ir->dbh->errstr);
}

sub accept {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my $pid = $self->stash('pid');

  unless ($pid) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No pid sent.'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;

  my $r = $object_model->modify($self, $pid, undef, undef, $self->config->{ir}->{iraccount}, 'ir accept', undef, $username, $password, 1);
  if ($r->{status} ne 200) {
    $res->{status} = 500;
    unshift @{$res->{alerts}}, @{$r->{alerts}};
    unshift @{$res->{alerts}}, {type => 'error', msg => "Error accepting object $pid"};
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my @pids = ($pid);
  $self->addEvent('accept', \@pids, $username);

  $self->render(json => $res, status => $res->{status});
}

sub reject {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my $pid = $self->stash('pid');

  unless ($pid) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No pid sent.'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;

  my $r = $object_model->purge_relationship($self, $pid, "http://phaidra.org/ontology/isInAdminSet", $self->config->{ir}->{adminset}, $self->config->{phaidra}->{adminusername}, $self->config->{phaidra}->{adminpassword}, 0);
  push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
  if ($r->{status} ne 200) {
    $res->{status} = 500;
    unshift @{$res->{alerts}}, @{$r->{alerts}};
    unshift @{$res->{alerts}}, {type => 'error', msg => "Error rejecting object $pid"};
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my @pids = ($pid);
  $self->addEvent('reject', \@pids, $username);

  $self->render(json => $res, status => $res->{status});
}

sub approve {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my $pid = $self->stash('pid');

  unless ($pid) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No pid sent.'}]}, status => 400);
    return;
  }

  $self->app->log->debug("ir: approve: [$pid] adding tag...");
  my $cmodel;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $res_cmodel   = $search_model->get_cmodel($self, $pid);
  if ($res_cmodel->{status} ne 200) {
    $self->app->log->error("ERROR saving json-ld for object $pid, could not get cmodel:" . $self->app->dumper($res_cmodel));
    return;
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  $res = $jsonld_model->get_object_jsonld_parsed($self, $pid, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    $self->app->log->error("ERROR getting json-ld for object $pid:\n" . $self->app->dumper($res));
    return;
  }

  if (exists($res->{'JSON-LD'}->{'phaidra:systemTag'})) {
    $self->app->log->error("ERROR phaidra:systemTag already exists");
    return;
  }

  $res->{'JSON-LD'}->{'phaidra:systemTag'} = [$self->config->{ir}->{adminset} . ':approved'];

  my $saveres = $jsonld_model->save_to_object($self, $pid, $cmodel, $res->{'JSON-LD'}, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);
  if ($saveres->{status} ne 200) {
    $self->app->log->error("ERROR saving json-ld for object $pid:\n" . $self->app->dumper($res));
    return;
  }
  $self->app->log->debug("ir: approve: [$pid] adding tag...finished");

  my @pids = ($pid);
  $self->addEvent('approve', \@pids, $username);

  my $alert = $self->getAlertForPid('mdcheck', $pid);
  unless ($alert->{username}) {
    $self->app->log->debug("approve pid[$pid]: no alerts found");
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my $owner = $alert->{username};

  my $email = $self->app->directory->get_email($self, $owner);

  my %emaildata;
  $emaildata{pid}     = $pid;
  $emaildata{baseurl} = $self->config->{ir}->{baseurl};

  my $subject        = $self->config->{ir}->{name} . " - Redaktionelle Bearbeitung abgeschlossen / Submission process completed";
  my $templatefolder = $self->config->{ir}->{templatefolder};

  my $supportEmail = $self->config->{ir}->{supportemail};
  my $from = $supportEmail;
  $from = substr($supportEmail, 0, index($supportEmail, ',')) if index($supportEmail, ',') != -1;

  my %options;
  $options{INCLUDE_PATH} = $templatefolder;
  eval {
    my $msg = MIME::Lite::TT::HTML->new(
      From        => $from,
      To          => $email,
      Subject     => $subject,
      Charset     => 'utf8',
      Encoding    => 'quoted-printable',
      Template    => {html => 'mdcheck.html.tt', text => 'mdcheck.txt.tt'},
      TmplParams  => \%emaildata,
      TmplOptions => \%options
    );
    $msg->send;
  };
  if ($@) {
    $self->addEvent('approval_notification_failed', \@pids, $username);
    my $err = "[$pid] sending notification email failed: " . $@;
    $self->app->log->error($err);

    # 200 - the object was approved, notification failure goes to alerts
    $res->{status} = 200;
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};
    $self->render(json => $res, status => $res->{status});
    return;
  }

  # update history
  $self->setAlertProcessed($alert->{id});
  $self->addEvent('approval_notification_sent', \@pids, $username);

  $self->render(json => $res, status => $res->{status});
}

sub events {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my $pid = $self->stash('pid');

  unless ($pid) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No pid sent.'}]}, status => 400);
    return;
  }

  my @events;
  my $ss  = qq/SELECT event_type, user_id, gmtimestamp FROM event WHERE pid = ? ORDER BY gmtimestamp DESC;/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute($pid) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  my ($event, $username_out, $ts);
  $sth->bind_columns(\$event, \$username_out, \$ts) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  while ($sth->fetch()) {
    push @events, {event => $event, username => $username_out, ts => $ts};
  }

  $res->{events} = \@events;

  $self->render(json => $res, status => $res->{status});
}

sub adminlistdata {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  $self->app->log->debug("=== params ===");
  for my $pn (@{$self->req->params->names}) {
    $self->app->log->debug($pn);
  }
  $self->app->log->debug("==============");

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my @pids;
  my $pids = $self->every_param('pids[]');

  if ($pids) {
    if (ref($pids) eq 'ARRAY') {
      for my $apid (@$pids) {
        push @pids, $apid;
      }
    }
    else {
      push @pids, $pids;
    }
  }

  my @pidsquoted;
  for my $p (@pids) {
    push @pidsquoted, "'" . $p . "'";
  }
  my $pidsparam = join ',', @pidsquoted;

  my @licenses;
  my $ss  = "SELECT pid, license FROM requested_license WHERE pid IN ($pidsparam)";
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_ir->dbh->errstr);
  my ($pid, $license);
  $sth->bind_columns(undef, \$pid, \$license) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  while ($sth->fetch()) {
    push @licenses, {pid => $pid, requestedlicense => $license};
  }

  $res->{requestedlicenses} = \@licenses;

  my @submits;
  $ss  = "SELECT pid, user_id FROM event WHERE event_type = 'submit' AND pid IN ($pidsparam)";
  $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_ir->dbh->errstr);
  my $username_out;
  $sth->bind_columns(undef, \$pid, \$username_out) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  while ($sth->fetch()) {
    push @submits, {pid => $pid, user => {username => $username_out}};
  }

  my $namesCache;
  for my $submit (@submits) {
    unless (exists($namesCache->{$submit->{user}->{username}})) {
      $namesCache->{$submit->{user}->{username}} = $self->app->directory->get_name($self, $submit->{user}->{username});
    }
    $submit->{user}->{name} = $namesCache->{$submit->{user}->{username}};
  }

  $res->{submits} = \@submits;

  $self->render(json => $res, status => $res->{status});
}

sub addrequestedlicense {
  my $self     = shift;
  my $pid      = shift;
  my $username = shift;
  my $license  = shift;

  my $time = strftime "%Y-%m-%dT%H:%M:%SZ", (gmtime);

  my $ss  = qq/INSERT INTO requested_license (pid, license, user_id, gmtimestamp) VALUES (?,?,?,?)/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute($pid, $license, $username, $time) or $self->app->log->error($self->app->db_ir->dbh->errstr);
}

sub allowsubmit {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  $res->{allowsubmit}     = 0;
  $res->{candobulkupload} = 0;

  my $username = $self->stash->{basic_auth_credentials}->{username};

  if ($self->config->{ir}->{bulkuploadlimit}->{nruploads} && $self->config->{ir}->{bulkuploadlimit}->{nrdays}) {
    my $nruploads = $self->config->{ir}->{bulkuploadlimit}->{nruploads};
    my $nrdays    = $self->config->{ir}->{bulkuploadlimit}->{nrdays};
    $res->{nruploads} = $nruploads;
    $res->{nrdays}    = $nrdays;
    $self->app->log->info("Bulk upload check configured: nruploads[$nruploads] within days[$nrdays]");
    my $candobulkupload = 0;
    if ($self->config->{ir}->{candobulkupload}) {
      for my $acc (@{$self->config->{ir}->{candobulkupload}}) {
        if ($username eq $acc) {
          $res->{candobulkupload} = 1;
          $candobulkupload = 1;
        }
      }
    }

    unless ($candobulkupload) {
      $self->app->log->info("User[$username] CAN NOT do bulk uploads. Checking if this is bulk upload...");
      my $nr = $self->getNrUnapprovedUploads($username, $nrdays);
      $res->{nrunapproveduploads} = $nr;
      if ($nr >= $nruploads) {
        $self->app->log->info("User[$username] deny submitform, user has [$nr] unapproved uploads within " . $nrdays . " days.");
        $res->{allowsubmit} = 0;
      }
      else {
        $self->app->log->info("User[$username] - not a bulk upload, user has [$nr] unapproved uploads within " . $nrdays . " days.");
        $res->{allowsubmit} = 1;
      }
    }
    else {
      $self->app->log->info("User[$username] CAN do bulk uploads.");
      $res->{allowsubmit} = 1;
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub getNrUnapprovedUploads {
  my ($self, $username, $nrdays) = @_;

  my $ss
    = 'SELECT COUNT(*) AS nrunapproveduploads FROM (SELECT INSTR(GROUP_CONCAT(event_type),"approve") as approvedstrpos, pid, INSTR(GROUP_CONCAT(user_id),?) as userstrpos, gmtimestamp FROM event as e, (SELECT MAX(STR_TO_DATE(gmtimestamp,"%Y-%m-%dT%TZ")) as maxd FROM event WHERE user_id = ? AND event_type = "submit") subq1 WHERE user_id = ? OR user_id = ? AND STR_TO_DATE(e.gmtimestamp,"%Y-%m-%dT%TZ") >= SUBDATE(subq1.maxd, ?) GROUP BY pid) uploads WHERE approvedstrpos = 0 AND userstrpos > 0;';
  my $res = $self->app->db_ir->dbh->selectrow_hashref($ss, undef, ($username, $username, $self->config->{ir}->{iraccount}, $username, $nrdays)) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  return $res->{nrunapproveduploads};
}

sub submit {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  $self->app->log->debug("=== params ===");
  for my $pn (@{$self->req->params->names}) {
    $self->app->log->debug($pn);
  }
  for my $up (@{$self->req->uploads}) {
    $self->app->log->debug($up->{name} . ": " . $up->{filename});
  }
  $self->app->log->debug("==============");

  if ($self->req->is_limit_exceeded) {
    $self->app->log->debug("Size limit exceeded. Current max_message_size:" . $self->req->max_message_size);
    $self->render(json => {alerts => [{type => 'error', msg => 'File is too big'}]}, status => 400);
    return;
  }

  my $metadata = $self->param('metadata');
  unless ($metadata) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent.'}]}, status => 400);
    return;
  }

  eval {
    if (ref $metadata eq 'Mojo::Upload') {
      $self->app->log->debug("Metadata sent as file param");
      $metadata = $metadata->asset->slurp;
      $self->app->log->debug("parsing json");
      $metadata = decode_json($metadata);
    }
    else {
      $self->app->log->debug("parsing json");
      $metadata = decode_json(b($metadata)->encode('UTF-8'));
    }
  };

  if ($@) {
    $self->app->log->error("Error: $@");
    unshift @{$res->{alerts}}, {type => 'error', msg => $@};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (exists($metadata->{metadata}->{'json-ld'}->{'ebucore:filename'})) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Missing ebucore:filename"};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  unless (exists($metadata->{metadata}->{'json-ld'}->{'ebucore:hasMimeType'})) {
    unshift @{$res->{alerts}}, {type => 'error', msg => "Missing ebucore:hasMimeType"};
    $res->{status} = 400;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my %rights;
  if (exists($metadata->{metadata}->{'json-ld'}->{'dcterms:accessRights'})) {
    for my $ar (@{$metadata->{metadata}->{'json-ld'}->{'dcterms:accessRights'}}) {
      if (exists($ar->{'skos:exactMatch'})) {
        for my $arId (@{$ar->{'skos:exactMatch'}}) {

          # embargoed
          if ($arId eq 'https://pid.phaidra.org/vocabulary/AVFC-ZZSZ') {
            if (exists($metadata->{metadata}->{'json-ld'}->{'dcterms:available'})) {
              for my $embargoDate (@{$metadata->{metadata}->{'json-ld'}->{'dcterms:available'}}) {
                push @{$rights{'username'}}, {value => $username, expires => $embargoDate . "T00:00:00Z"};
                push @{$rights{'username'}}, {value => $self->config->{ir}->{iraccount}, expires => $embargoDate . "T00:00:00Z"};
                last;
              }
            }
          }

          # closed
          if ($arId eq 'https://pid.phaidra.org/vocabulary/QNGE-V02H') {
            push @{$rights{'username'}}, $username;
            push @{$rights{'username'}}, $self->config->{ir}->{iraccount};
          }

          # restricted
          if ($arId eq 'https://pid.phaidra.org/vocabulary/KC3K-CCGM') {
            push @{$rights{'username'}}, $username;
            push @{$rights{'username'}}, $self->config->{ir}->{iraccount};
          }
        }
      }
    }
  }

  my @filenames = @{$metadata->{metadata}->{'json-ld'}->{'ebucore:filename'}};
  my @mimetypes = @{$metadata->{metadata}->{'json-ld'}->{'ebucore:hasMimeType'}};

  my $object_model = PhaidraAPI::Model::Object->new;

  my $cnt = scalar @filenames;
  my $mainObjectPid;
  my @alternativeFormatPids;
  for (my $i = 0; $i < $cnt; $i++) {
    my $filename = $filenames[$i];
    my $mimetype = $mimetypes[$i];

    my $fileupload;
    for my $up (@{$self->req->uploads}) {
      if ($filename eq $up->{filename}) {
        $fileupload = $up;
      }
    }
    unless (defined($fileupload)) {
      unshift @{$res->{alerts}}, {type => 'error', msg => "Missing file [$filename]"};
      $res->{status} = 400;
      $self->render(json => $res, status => $res->{status});
      return;
    }

    my $size = $fileupload->size;
    my $name = $fileupload->filename;
    $self->app->log->debug("Found file: $name [$size B]");

    my $jsonld = dclone($metadata->{metadata}->{'json-ld'});

    my $title;
    my $titles = $jsonld->{'dce:title'};
    for my $o (@{$titles}) {
      $title = $o->{'bf:mainTitle'}[0]->{'@value'};
      last;
    }

    my @filenameArr = ($filename);
    $jsonld->{'ebucore:filename'} = \@filenameArr;
    my @mimetypeArr = ($mimetype);
    $jsonld->{'ebucore:hasMimeType'} = \@mimetypeArr;

    $self->app->log->debug('Requested license:' . $self->app->dumper($jsonld->{'edm:rights'}));
    my $requestedLicense = @{$jsonld->{'edm:rights'}}[0];
    if ($username ne $self->config->{ir}->{iraccount}) {
      my @lic;
      push @lic, 'http://rightsstatements.org/vocab/InC/1.0/';
      $jsonld->{'edm:rights'} = \@lic;
    }

    if ($username eq $self->config->{ir}->{iraccount}) {
      $jsonld->{'phaidra:systemTag'} = [$self->config->{ir}->{adminset} . ":approved"];
    }

    my $isAlternativeFormat = 0;
    my $cmodel;
    if ($mimetype eq 'application/pdf' || $mimetype eq 'application/x-pdf') {
      $cmodel = 'cmodel:PDFDocument';
    }
    else {
      $cmodel = 'cmodel:Asset';
      if ($cnt > 1) {
        $isAlternativeFormat = 1;
      }
    }

    my $md = {metadata => {'json-ld' => $jsonld}};

    if (exists($rights{'username'})) {
      $self->app->log->debug("Setting rights: \n" . $self->app->dumper(\%rights));
      $md->{metadata}->{rights} = \%rights;
    }

    my $r = $object_model->create_simple($self, $cmodel, $md, $mimetype, $fileupload, undef, undef, $username, $password);
    if ($r->{status} ne 200) {
      $res->{status} = 500;
      unshift @{$res->{alerts}}, @{$r->{alerts}};
      unshift @{$res->{alerts}}, {type => 'error', msg => "Error creating object [filename=$filename]"};
      $self->render(json => $res, status => $res->{status});
      return;
    }

    if ($isAlternativeFormat) {
      push @alternativeFormatPids, $r->{pid};
    }
    else {
      $mainObjectPid = $r->{pid};
    }

    $self->addrequestedlicense($r->{pid}, $username, $requestedLicense);

    $self->sendAdminEmail($title, $username, $r->{pid}, $requestedLicense);
  }

  my @mainObjectRelationships = (
    { predicate => "http://phaidra.org/ontology/isInAdminSet",
      object    => $self->config->{ir}->{adminset}
    }
  );

  my $alternativeVersionPid = $self->param('isAlternativeVersionOf');
  if ($alternativeVersionPid) {
    push @mainObjectRelationships,
      {
      predicate => "http://phaidra.org/XML/V1.0/relations#isAlternativeVersionOf",
      object    => "info:fedora/" . $alternativeVersionPid
      };
  }

  $self->app->log->debug("Adding relationships[" . $self->app->dumper(\@mainObjectRelationships) . "] to pid[$mainObjectPid]");

  my $r = $object_model->add_relationships($self, $mainObjectPid, \@mainObjectRelationships, $username, $password);
  push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
  if ($r->{status} ne 200) {
    $self->app->log->error("Error adding relationships[" . $self->app->dumper(\@mainObjectRelationships) . "] pid[$mainObjectPid] res[" . $self->app->dumper($res) . "]");

    # continue, this isn't fatal
  }

  for my $alternativeFormatPid (@alternativeFormatPids) {

    my @alternativeFormatsRelationships = (
      { predicate => "http://phaidra.org/XML/V1.0/relations#isAlternativeFormatOf",
        object    => "info:fedora/" . $mainObjectPid
      },
      { predicate => "http://phaidra.org/ontology/isInAdminSet",
        object    => $self->config->{ir}->{adminset}
      }
    );

    $self->app->log->debug("Adding relationships[" . $self->app->dumper(\@alternativeFormatsRelationships) . "] to pid[$alternativeFormatPid]");

    my $r = $object_model->add_relationships($self, $alternativeFormatPid, \@alternativeFormatsRelationships, $username, $password);
    push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
    if ($r->{status} ne 200) {
      $self->app->log->error("Error adding relationships[" . $self->app->dumper(\@alternativeFormatsRelationships) . "] pid[$alternativeFormatPid] res[" . $self->app->dumper($res) . "]");

      # continue, this isn't fatal
    }
  }

  if ($username eq $self->config->{ir}->{iraccount}) {
    if ($self->app->config->{apis}->{pure}) {
      my $uuid = $self->param('uuid');
      $self->app->log->debug("pure import uuid[$uuid]");
      if ($uuid) {
        my $urlget = Mojo::URL->new($self->app->config->{apis}->{pure}->{url} . "/research-outputs/$uuid");
        my $params = {apiKey => $self->app->config->{apis}->{pure}->{key}};

        my $pureUpdate = $self->createPureUpdate($mainObjectPid, $uuid, $metadata);
        $self->app->log->debug("pure update:\n" . $self->app->dumper($pureUpdate));
        my $putres = $self->ua->put($urlget => {Accept => 'application/json', 'api-key' => $self->app->config->{apis}->{pure}->{key}} => json => $pureUpdate)->result;
        $self->app->log->debug("XXXXXXXXx pure update result:\n" . $self->app->dumper($putres));
        if ($putres->is_success) {
          $res->{response} = $putres->json;
          $self->app->log->debug("pure response:\n" . $self->app->dumper($putres->json));
        }
        else {
          $self->render(json => {alerts => [{type => 'error', msg => 'error updating pure object ' . $putres->code . " " . $putres->message}]}, status => 500);
          return;
        }
      }
    }
  }

  my @pids;
  push @pids, $mainObjectPid;
  for my $p (@alternativeFormatPids) {
    push @pids, $p;
  }
  $self->addEvent('submit', \@pids, $username);

  $res->{pid}          = $mainObjectPid;
  $res->{alternatives} = \@alternativeFormatPids;

  $self->render(json => $res, status => $res->{status});
}

sub sendAdminEmail {
  my ($self, $title, $owner, $pid, $license) = @_;

  my $phaidrabaseurl = $self->config->{phaidra}->{baseurl};
  my $irbaseur       = $self->config->{ir}->{baseurl};

  my $email = "
  <html>
    <body>
      <p>Title: $title</p>
      <p>Owner: $owner</p>
      <p>IR: <a href=\"https://$irbaseur/detail/$pid\" target=\"_blank\">https://$irbaseur/detail/$pid</a></p>
      <p>Phaidra: <a href=\"https://$phaidrabaseurl/detail/$pid\" target=\"_blank\">https://$phaidrabaseurl/detail/$pid</a></p>		
      <p>Requested license: $license</p>
    </body>
  </html>	
  ";

  $self->app->log->info("Sending email for pid[$pid]: \n$email");

  my $supportEmail = $self->config->{ir}->{supportemail};
  my $from = $supportEmail;
  $from = substr($supportEmail, 0, index($supportEmail, ',')) if index($supportEmail, ',') != -1;

  my $msg = MIME::Lite->new(
    From    => $from,
    To      => $supportEmail,
    Type    => 'text/html; charset=UTF-8',
    Subject => "New upload: $pid",
    Data    => encode('UTF-8', $email)
  );

  $msg->send;
}

sub stats {
  my $self = shift;

  my $pid      = $self->stash('pid');
  my $irsiteid = $self->param('siteid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $key = $self->stash('stats_param_key');

  my $fr = undef;
  if (exists($self->app->config->{sites})) {
    for my $f (@{$self->app->config->{sites}}) {
      if (defined($f->{site}) && $f->{site} eq 'phaidra') {
        $fr = $f;
      }
    }
  }

  unless (defined($fr)) {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Site is not configured'}]}, status => 200);
    return;
  }
  unless ($fr->{site} eq 'ir' or $fr->{site} eq 'phaidra') {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Site [' . $fr->{site} . '] is not supported'}]}, status => 200);
    return;
  }
  unless (defined($fr->{stats})) {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Statistics source is not configured'}]}, status => 200);
    return;
  }

  # only piwik now
  unless ($fr->{stats}->{type} eq 'piwik') {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Statistics source [' . $fr->{stats}->{type} . '] is not supported.'}]}, status => 200);
    return;
  }
  unless ($irsiteid) {
    unless (defined($fr->{stats}->{siteid})) {
      $self->render(json => {alerts => [{type => 'info', msg => 'Piwik siteid is not configured'}]}, status => 500);
      return;
    }
    $irsiteid = $fr->{stats}->{siteid};
  }

  my $stats;

  my $downloads = $self->app->db_stats_phaidra->dbh->selectrow_array("SELECT count(*) FROM downloads_$irsiteid WHERE pid = '$pid';");
  unless (defined($downloads)) {
    $self->app->log->error("Error querying piwik database for download stats:" . $self->app->db_stats_phaidra->dbh->errstr);
  }

  my $detail_page = $self->app->db_stats_phaidra->dbh->selectrow_array("SELECT count(*) FROM views_$irsiteid WHERE pid = '$pid';");
  unless (defined($detail_page)) {
    $self->app->log->error("Error querying piwik database for detail stats:" . $self->app->db_stats_phaidra->dbh->errstr);
  }

  if (defined($detail_page) || defined($downloads)) {
    $stats = {downloads => $downloads, detail_page => $detail_page};
  }

  $self->app->log->debug("stats: " . $self->app->dumper($stats));

  $self->render(json => {stats => $stats}, status => 200);
}

sub stats_chart {
  my $self = shift;

  my $pid      = $self->stash('pid');
  my $irsiteid = $self->param('siteid');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $key = $self->stash('stats_param_key');

  my $fr = undef;
  if (exists($self->app->config->{sites})) {
    for my $f (@{$self->app->config->{sites}}) {
      if (defined($f->{site}) && $f->{site} eq 'phaidra') {
        $fr = $f;
      }
    }
  }

  unless (defined($fr)) {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Site is not configured'}]}, status => 200);
    return;
  }
  unless ($fr->{site} eq 'ir' or $fr->{site} eq 'phaidra') {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Site [' . $fr->{site} . '] is not supported'}]}, status => 200);
    return;
  }
  unless (defined($fr->{stats})) {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Statistics source is not configured'}]}, status => 200);
    return;
  }

  # only piwik now
  unless ($fr->{stats}->{type} eq 'piwik') {

    # return 200, this is just ok
    $self->render(json => {alerts => [{type => 'info', msg => 'Statistics source [' . $fr->{stats}->{type} . '] is not supported.'}]}, status => 200);
    return;
  }
  unless ($irsiteid) {
    unless (defined($fr->{stats}->{siteid})) {
      $self->render(json => {alerts => [{type => 'info', msg => 'Piwik siteid is not configured'}]}, status => 500);
      return;
    }
    $irsiteid = $fr->{stats}->{siteid};
  }

  my $downloads;
  my $sth = $self->app->db_stats_phaidra->dbh->prepare("SELECT DATE_FORMAT(server_time,'%Y-%m-%d'), location_country FROM downloads_$irsiteid WHERE pid = '$pid';")
    or $self->app->log->error("Error querying piwik database for download stats chart:" . $self->app->db_stats_phaidra->dbh->errstr);
  $sth->execute() or $self->app->log->error("Error querying piwik database for download stats chart:" . $self->app->db_stats_phaidra->dbh->errstr);
  my $date;
  my $country;
  $sth->bind_columns(undef, \$date, \$country);

  while ($sth->fetch) {
    if ($downloads->{$country}) {
      $downloads->{$country}->{$date}++;
    }
    else {
      $downloads->{$country} = {$date => 1};
    }
  }

  my $detail_page;
  $sth = $self->app->db_stats_phaidra->dbh->prepare("SELECT DATE_FORMAT(server_time,'%Y-%m-%d'), location_country FROM views_$irsiteid WHERE pid = '$pid';")
    or $self->app->log->error("Error querying piwik database for detail stats chart:" . $self->app->db_stats_phaidra->dbh->errstr);
  $sth->execute() or $self->app->log->error("Error querying piwik database for detail stats chart:" . $self->app->db_stats_phaidra->dbh->errstr);
  $sth->bind_columns(undef, \$date, \$country);
  while ($sth->fetch) {
    if ($detail_page->{$country}) {
      $detail_page->{$country}->{$date}++;
    }
    else {
      $detail_page->{$country} = {$date => 1};
    }
  }

  if (defined($key)) {
    if ($key eq 'downloads') {
      $self->render(text => $downloads, status => 200);
      return;
    }
    if ($key eq 'detail_page') {
      $self->render(text => $detail_page, status => 200);
      return;
    }
  }
  else {
    $self->render(json => {stats => {downloads => $downloads, detail_page => $detail_page}}, status => 200);
  }
}

sub isRestricted {
  my $self = shift;
  my $pid  = shift;

  my $rights_model = PhaidraAPI::Model::Rights->new;
  my $res          = $rights_model->get_object_rights_json($self, $pid, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    $self->app->log->error("ERROR getting rights for object $pid:\n" . $self->app->dumper($res));

    # assume it is restricted -> this means nothing will be done (no email sent etc)
    return 1;
  }

  # example
  #  "rights": {
  #      "faculty": [
  #          "A34"
  #      ],
  #      "spl": [
  #          "29"
  #      ],
  #      "username": [
  #          {
  #              "expires": "2019-12-11T16:11:45Z",
  #              "value": "blumess6"
  #          }
  #      ]
  #  }

  for my $key (keys %{PhaidraAPI::Model::Rights::allowed_tags}) {
    if ($res->{rights}->{$key}) {
      for my $rule (@{$res->{rights}->{$key}}) {
        $self->app->log->debug("$pid is restricted:\n" . $self->app->dumper($res));
        return 1;
      }
    }
  }

  return 0;
}

sub changeEmbargoedToOpenAccess {
  my $self = shift;
  my $pid  = shift;

  my $cmodel;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $res_cmodel   = $search_model->get_cmodel($self, $pid);
  if ($res_cmodel->{status} ne 200) {
    $self->app->log->error("ERROR saving json-ld for object $pid, could not get cmodel:" . $self->app->dumper($res_cmodel));
    return;
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
  my $res          = $jsonld_model->get_object_jsonld_parsed($self, $pid, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($res->{status} ne 200) {
    $self->app->log->error("ERROR getting json-ld for object $pid:\n" . $self->app->dumper($res));
    return;
  }

  # dcterms:accessRights: [
  #   {
  #     @type: "skos:Concept",
  #     skos:prefLabel: [
  #       {
  #         @language: "eng",
  #         @value: "embargoed access"
  #       }
  #     ],
  #     skos:exactMatch: [
  #       "https://pid.phaidra.org/vocabulary/AVFC-ZZSZ"
  #     ]
  #   }
  # ]

  if (exists($res->{'JSON-LD'}->{'dcterms:accessRights'})) {
    for my $ar (@{$res->{'JSON-LD'}->{'dcterms:accessRights'}}) {
      my $isEmbargoAccessRight = 0;
      if ($ar->{'skos:exactMatch'}) {
        for my $em (@{$ar->{'skos:exactMatch'}}) {

          # embargoed access
          if ($em eq 'https://pid.phaidra.org/vocabulary/AVFC-ZZSZ') {
            $isEmbargoAccessRight = 1;
            last;
          }
        }
      }
      if ($isEmbargoAccessRight) {
        $ar = {
          '@type'          => 'skos:Concept',
          'skos:prefLabel' => [
            { '@language' => 'eng',
              '@value'    => 'open access'
            }
          ],
          'skos:exactMatch' => ['https://pid.phaidra.org/vocabulary/QW5R-NG4J']
        };
        last;
      }
    }
    my $saveres = $jsonld_model->save_to_object($self, $pid, $cmodel, $res->{'JSON-LD'}, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0);
    if ($saveres->{status} ne 200) {
      $self->app->log->error("ERROR saving json-ld for object $pid:\n" . $self->app->dumper($res));
      return;
    }
  }
  else {
    $self->app->log->error("ERROR object $pid is missing dcterms:accessRights:\n" . $self->app->dumper($res));
  }

}

sub sendEmbargoendEmail {
  my ($self, $username, $pid) = @_;

  my $email = $self->app->directory->get_email($self, $username);

  my %emaildata;
  $emaildata{pid}     = $pid;
  $emaildata{baseurl} = $self->config->{ir}->{baseurl};

  my $subject        = $self->config->{ir}->{name} . " - Embargofrist abgelaufen / Embargo period expired";
  my $templatefolder = $self->config->{ir}->{templatefolder};

  my $supportEmail = $self->config->{ir}->{supportemail};
  my $from = substr($supportEmail, 0, index($supportEmail, ','));

  my %options;
  $options{INCLUDE_PATH} = $templatefolder;
  eval {
    my $msg = MIME::Lite::TT::HTML->new(
      From        => $from,
      To          => $email,
      Subject     => $subject,
      Charset     => 'utf8',
      Encoding    => 'quoted-printable',
      Template    => {html => 'embargoend.html.tt', text => 'embargoend.txt.tt'},
      TmplParams  => \%emaildata,
      TmplOptions => \%options
    );
    $msg->send;
  };
  if ($@) {
    my @pids;
    push @pids, $pid;
    $self->addEvent('embargoend_notification_failed', \@pids, $username);
    my $err = "[$pid] sending notification email to username[$username] email[$email] failed: " . $@;
    $self->app->log->error($err);
  }
}

sub embargocheck {
  my $self = shift;

  $self->app->log->info("embargocheck processing alerts");

  my @rows;

  my $ss  = qq/SELECT alert.id, alert.username, alert.pids FROM alert WHERE alert_type = ? AND alert.processed = 0;/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute('embargo') or $self->app->log->error($self->app->db_ir->dbh->errstr);
  my ($id, $username, $pids);
  $sth->bind_columns(\$id, \$username, \$pids) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  while ($sth->fetch()) {
    push @rows, {id => $id, username => $username, pids => $pids};
  }

  my $i        = 0;
  my $nrAlerts = scalar @rows;
  foreach my $row (@rows) {
    $i++;
    $self->app->log->info("embargocheck alerts processing[$i/$nrAlerts] checking alert definition: alert[" . $row->{id} . "] username[" . $row->{username} . "] pids[" . $row->{pids} . "]");

    my @pids;
    my $pid = $row->{pids};
    if ($pid =~ m/^o:\d+$/) {
      push @pids, $pid;
    }
    else {    # in this case there are more pids separated by a comma
      @pids = split(',', $pid);
    }

    my $j      = 0;
    my $nrPids = scalar @pids;
    foreach my $p (@pids) {
      $j++;
      $self->app->log->info("embargocheck alerts processing[$i/$nrAlerts] alert[" . $row->{id} . "] processing pid[$p]");

      if ($self->isRestricted($p)) {
        $self->app->log->info("embargocheck alerts processing[$i/$nrAlerts] alert[" . $row->{id} . "] pid[$p] restricted");
      }
      else {
        $self->app->log->info("embargocheck alerts processing[$i/$nrAlerts] alert[" . $row->{id} . "] pid[$p] not restricted");

        # set alert processed
        $self->app->log->info("embargocheck alerts processing[$i/$nrAlerts] alert[" . $row->{id} . "] pid[$p] setting alert as processed");
        my $ss  = qq/UPDATE alert SET processed = 1 WHERE id = ?;/;
        my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
        $sth->execute($row->{id}) or $self->app->log->error($self->app->db_ir->dbh->errstr);

        # change object's 'dcterms:accessRights' metadata field to open access
        $self->app->log->info("embargocheck alerts processing[$i/$nrAlerts] alert[" . $row->{id} . "] pid[$p] changing infoeurepoaccess");
        $self->changeEmbargoedToOpenAccess($p);

        # send email
        $self->app->log->info("embargocheck alerts processing[$i/$nrAlerts] alert[" . $row->{id} . "] pid[$p] sending email");
        $self->sendEmbargoendEmail($row->{username}, $p);
      }
    }
  }

  $self->app->log->info("embargocheck processing embargoed objects from solr");

  my $urlget = Mojo::URL->new;
  $urlget->scheme($self->app->config->{solr}->{scheme});
  $urlget->host($self->app->config->{solr}->{host});
  $urlget->port($self->app->config->{solr}->{port});
  if ($self->app->config->{solr}->{path}) {
    $urlget->path("/" . $self->app->config->{solr}->{path} . "/solr/" . $self->app->config->{solr}->{core} . "/select");
  }
  else {
    $urlget->path("/solr/" . $self->app->config->{solr}->{core} . "/select");
  }
  $urlget->query(q => "*:*", fq => "isinadminset:\"" . $self->app->config->{ir}->{adminset} . "\" AND dcterms_accessrights_id:\"https://pid.phaidra.org/vocabulary/AVFC-ZZSZ\"", rows => "10000", wt => "json");

  my $ua     = Mojo::UserAgent->new;
  my $getres = $ua->get($urlget)->result;

  if ($getres->is_success) {
    my $nrDocs = $getres->json->{response}->{numFound};
    my $k      = 0;
    for my $d (@{$getres->json->{response}->{docs}}) {
      $k++;
      my $p = $d->{pid};
      $self->app->log->info("embargocheck solr processing[$k/$nrDocs] pid[$p]");
      if ($self->isRestricted($p)) {
        $self->app->log->info("embargocheck solr processing[$k/$nrDocs] pid[$p] restricted");
      }
      else {
        # change object's 'dcterms:accessRights' metadata field to open access
        $self->app->log->info("embargocheck processing[$k/$nrDocs] pid[$p] changing infoeurepoaccess");
        $self->changeEmbargoedToOpenAccess($p);
      }
    }
  }
  else {
    $self->app->log->error("embargocheck error getting embargoed objects from solr: " . $getres->code . " " . $getres->message);
  }

  $self->render(text => 'finished', status => 200);
}

sub puresearch {
  my ($self) = @_;

  my $res = {alerts => [], status => 200};

  # already went through check_auth
  my $username = $self->stash->{basic_auth_credentials}->{username};
  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  unless ($self->app->config->{apis}->{pure}) {
    $self->render(json => {alerts => [{type => 'info', msg => 'Pure integration not configured'}]}, status => 400);
    return;
  }

  my $ir_status = $self->param('ir_status');
  unless ($ir_status eq 'ir_pending' or $ir_status eq 'ir_okay' or $ir_status eq 'ir_rejected') {
    $self->render(json => {alerts => [{type => 'info', msg => 'Invalid ir_status'}]}, status => 400);
    return;
  }

  my $size     = $self->param('size');
  my $offset   = $self->param('offset');
  my $page     = $self->param('page');
  my $pageSize = $self->param('pageSize');

  # $self->app->log->debug("XXXXXXXXXXXXXXXXXXXX : " . $self->app->config->{apis}->{pure}->{url} . '/research-outputs/search');
  # HACK:
  my $urlget;
  if ($self->app->config->{apis}->{pure}->{url} eq "https://ucris.univie.ac.at/ws/api/523/research-outputs") {
    $urlget = Mojo::URL->new($self->app->config->{apis}->{pure}->{url});
  }
  else {
    $urlget = Mojo::URL->new($self->app->config->{apis}->{pure}->{url} . '/research-outputs/search');
  }

  my $params = {apiKey => $self->app->config->{apis}->{pure}->{key}};
  if ($size) {
    $params->{size} = $size;
  }
  if ($offset) {
    $params->{offset} = $offset;
  }
  if ($page) {
    $params->{page} = $page;
  }
  if ($pageSize) {
    $params->{pageSize} = $pageSize;
  }
  $urlget->query($params);

  my $getres = $self->ua->post($urlget => {Accept => 'application/json'} => json => {"keywordUris" => ["/dk/atira/pure/keywords/ir_status/$ir_status"]})->result;
  if ($getres->is_success) {
    $res->{response} = $getres->json;
  }
  else {
    $self->render(json => {alerts => [{type => 'error', msg => 'error getting results from Pure ' . $getres->code . " " . $getres->message}]}, status => 500);
    return;
  }

  # $self->app->log->debug("XXXXXXXXXXXXXXXXXXXX res: " . $self->app->dumper($res));
  $self->render(json => $res, status => $res->{status});
}

sub pureimport_lock {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my $pureid   = $self->stash->{pureid};
  my $lockname = $self->stash->{lockname};

  $self->app->log->debug("pureimport_lock pureid[$pureid] lockname[$lockname]");

  my $ss  = qq/INSERT INTO pureimport_locks (pureId, lockName) VALUES (?,?)/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute($pureid, $lockname) or $self->app->log->error($self->app->db_ir->dbh->errstr);

  $self->render(json => $res, status => $res->{status});
}

sub pureimport_unlock {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my $pureid   = $self->stash->{pureid};
  my $lockname = $self->stash->{lockname};

  $self->app->log->debug("pureimport_unlock pureid[$pureid] lockname[$lockname]");

  my $ss  = qq/DELETE FROM pureimport_locks WHERE pureId = ?/;
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute($pureid) or $self->app->log->error($self->app->db_ir->dbh->errstr);

  $self->render(json => $res, status => $res->{status});
}

sub pureimport_getlocks {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  $self->_pureimport_expirelocks();

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my @locks;
  my $ss  = "SELECT pureId, lockName, created FROM pureimport_locks;";
  my $sth = $self->app->db_ir->dbh->prepare($ss) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  $sth->execute() or $self->app->log->error($self->app->db_ir->dbh->errstr);
  my ($pureId, $lockName, $created);
  $sth->bind_columns(undef, \$pureId, \$lockName, \$created) or $self->app->log->error($self->app->db_ir->dbh->errstr);
  while ($sth->fetch()) {
    push @locks, {pureId => $pureId, lockName => $lockName, created => $created};
  }

  $res->{locks} = \@locks;

  $self->render(json => $res, status => $res->{status});
}

sub _pureimport_expirelocks {
  my ($self) = @_;

  my $res = {alerts => [], status => 200};

  eval {$self->app->db_ir->dbh->do('DELETE FROM pureimport_locks WHERE created + INTERVAL 2 HOUR < CURRENT_TIMESTAMP();');};
  if ($@) {
    unshift @{$res->{alerts}}, {type => 'error', msg => 'error in pureimport locks cleanup: ' . $@};
  }

  return $res;
}

sub pureimport_reject {
  my ($self) = @_;

  my $res = {alerts => [], status => 200};

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  if ($username ne $self->config->{ir}->{iraccount}) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Not authorized.'}]}, status => 403);
    return;
  }

  my $uuid = $self->param('uuid');

  # get pure metadata
  my $puremetadata;
  my $url    = Mojo::URL->new($self->app->config->{apis}->{pure}->{url} . "/research-outputs/$uuid");
  my $getres = $self->ua->get($url => {Accept => 'application/json', 'api-key' => $self->app->config->{apis}->{pure}->{key}})->result;
  if ($getres->is_success) {
    $puremetadata = $getres->json;
    $self->app->log->debug("Pure metadata:\n" . $self->app->dumper($puremetadata));
  }
  else {
    $self->render(json => {alerts => [{type => 'error', msg => 'error getting Pure object ' . $getres->code . " " . $getres->message}]}, status => 500);
    return;
  }

  my $update = {};

  $update->{keywordGroups} = $puremetadata->{keywordGroups};

  for my $kwg (@{$update->{keywordGroups}}) {
    if ($kwg->{logicalName} eq "/dk/atira/pure/keywords/ir_status") {
      delete $kwg->{name};
      $kwg->{classifications} = [{"uri" => "/dk/atira/pure/keywords/ir_status/ir_rejected"}];
    }
  }

  my $putres = $self->ua->put($url => {Accept => 'application/json', 'api-key' => $self->app->config->{apis}->{pure}->{key}} => json => $update)->result;
  if ($putres->is_success) {
    $self->app->log->debug("Pure response:\n" . $self->app->dumper($res));
  }
  else {
    $self->render(json => {alerts => [{type => 'error', msg => 'error updating Pure object ' . $putres->code . " " . $putres->message}]}, status => 500);
    return;
  }
  $self->render(json => $res, status => $res->{status});
}

sub createPureUpdate {

  my ($self, $pid, $uuid, $metadata) = @_;

  my $version;
  for my $e (@{$metadata->{metadata}->{'json-ld'}->{'oaire:version'}}) {
    for my $id (@{$e->{'skos:exactMatch'}}) {
      $version = $id;
    }
  }
  my $crisVersion = $ir2pureVersion->{$version};

  my $access;
  for my $e (@{$metadata->{metadata}->{'json-ld'}->{'dcterms:accessRights'}}) {
    for my $id (@{$e->{'skos:exactMatch'}}) {
      $access = $id;
    }
  }
  my $crisAccess = $ir2pureAccess->{$access};

  my $license;
  for my $e (@{$metadata->{metadata}->{'json-ld'}->{'edm:rights'}}) {
    $license = $e;
  }
  my $crisLicense = $ir2pureLicense->{$license};

  # get pure metadata
  my $puremetadata;
  my $url    = Mojo::URL->new($self->app->config->{apis}->{pure}->{url} . "/research-outputs/$uuid");
  my $getres = $self->ua->get($url => {Accept => 'application/json', 'api-key' => $self->app->config->{apis}->{pure}->{key}})->result;
  if ($getres->is_success) {
    $puremetadata = $getres->json;
    $self->app->log->debug("Pure metadata:\n" . $self->app->dumper($puremetadata));
  }
  else {
    $self->render(json => {alerts => [{type => 'error', msg => 'error getting Pure object ' . $getres->code . " " . $getres->message}]}, status => 500);
    return;
  }

  my $update = {};

  if (exists($puremetadata->{electronicVersions})) {
    $update->{electronicVersions} = $puremetadata->{electronicVersions};
  }
  else {
    $update->{electronicVersions} = [];
  }

  $update->{keywordGroups} = $puremetadata->{keywordGroups};

  push @{$update->{electronicVersions}},
    {
    "typeDiscriminator"   => "LinkElectronicVersion",
    "visibleOnPortalDate" => DateTime->now->ymd,
    "link"                => "https://" . $self->app->config->{phaidra}->{baseurl} . "/$pid",
    "accessType"          => {"uri" => $crisAccess},
    "licenseType"         => {"uri" => $crisLicense},
    "versionType"         => {"uri" => $crisVersion}
    };

  my $doi;
  for my $e (@{$metadata->{metadata}->{'json-ld'}->{'rdam:P30004'}}) {
    if (($e->{'@type'} eq 'ids:hdl') or ($e->{'@type'} eq 'ids:urn') or ($e->{'@type'} eq 'ids:uri')) {
      my $link_or_id = $e->{'@value'};
      my $link       = $link_or_id;
      if ($e->{'@type'} eq 'ids:hdl') {
        $link = 'https://hdl.handle.net/' . $link_or_id unless $link_or_id =~ m/http/;
      }
      if ($e->{'@type'} eq 'ids:urn') {
        $link = 'https://nbn-resolving.org/' . $link_or_id unless $link_or_id =~ m/http/;
      }
      push @{$update->{electronicVersions}},
        {
        "typeDiscriminator"   => "LinkElectronicVersion",
        "visibleOnPortalDate" => DateTime->now->ymd,
        "link"                => $link,
        "accessType"          => {"uri" => $crisAccess},
        "licenseType"         => {"uri" => $crisLicense},
        "versionType"         => {"uri" => $crisVersion}
        };
    }
    if ($e->{'@type'} eq 'ids:doi') {
      $doi = $e->{'@value'};
    }
  }

  if ($doi) {
    my $pureHasDoi = 0;
    for my $ev (@{$update->{electronicVersions}}) {
      if ($ev->{typeDiscriminator} eq 'DoiElectronicVersion') {
        $pureHasDoi = 1;
        last;
      }
    }
    unless ($pureHasDoi) {
      push @{$update->{electronicVersions}},
        {
        "typeDiscriminator"   => "DoiElectronicVersion",
        "visibleOnPortalDate" => DateTime->now->ymd,
        "doi"                 => $doi,
        "accessType"          => {"uri" => $crisAccess},
        "licenseType"         => {"uri" => $crisLicense},
        "versionType"         => {"uri" => $crisVersion}
        };
    }
  }

  for my $kwg (@{$update->{keywordGroups}}) {
    if ($kwg->{logicalName} eq "/dk/atira/pure/keywords/ir_status") {
      delete $kwg->{name};
      $kwg->{classifications} = [{"uri" => "/dk/atira/pure/keywords/ir_status/ir_okay"}];
    }
  }

  if ($crisLicense eq "/dk/atira/pure/core/document/licenses/other") {
    $update->{userDefinedLicense} = $license;
  }

  return $update;
}

1;
