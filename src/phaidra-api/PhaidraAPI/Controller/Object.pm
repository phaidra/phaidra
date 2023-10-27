package PhaidraAPI::Controller::Object;

use strict;
use warnings;
use v5.10;
use Switch;
use base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(encode decode);
use Mojo::ByteStream qw(b);
use Mojo::Upload;
use Mojo::Path;
use Mojo::IOLoop;
use Scalar::Util qw(looks_like_number);
use Mojo::Util qw(url_escape);
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Collection;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Rights;
use PhaidraAPI::Model::Octets;
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Geo;
use PhaidraAPI::Model::Mods;
use PhaidraAPI::Model::Imageserver;
use PhaidraAPI::Model::Util;
use PhaidraAPI::Model::Authorization;
use PhaidraAPI::Model::Languages;
use PhaidraAPI::Model::Hooks;
use Digest::SHA qw(hmac_sha1_hex);
use Time::HiRes qw/tv_interval gettimeofday/;
use File::Find::utf8;

sub info {
  my $self = shift;

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  my $pid = $self->stash('pid');
  unless ($pid =~ m/^o:\d+$/) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Invalid pid'}]}, status => 400);
    return;
  }

  my $mode = $self->param('mode');

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->info($self, $pid, $mode, $username, $password);

  if ($r->{status} eq 200) {
    $self->track_info($pid);
  }

  $self->render(json => $r, status => $r->{status});
}

sub imageserver_job_status {
  my $self = shift;
  my $pid  = shift;

  if (exists($self->app->config->{paf_mongodb})) {
    my $jobs_coll = $self->paf_mongo->get_collection('jobs');
    if ($jobs_coll) {
      my $job_record = $jobs_coll->find_one({pid => $pid, agent => 'pige'}, {}, {"sort" => {"created" => -1}});

      # $self->app->log->debug($self->app->dumper($job_record));
      return $job_record->{status};
    }
  }

  return 'job not found';
}

sub get_is_thumbnail_for {
  my $self = shift;
  my $pid  = shift;

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
  $urlget->query(q => "*:*", fq => "isthumbnailfor:\"$pid\"", rows => "1", wt => "json");
  my $ua     = Mojo::UserAgent->new;
  my $getres = $ua->get($urlget)->result;
  if ($getres->is_success) {
    for my $d (@{$getres->json->{response}->{docs}}) {
      $self->app->log->info($d->{pid} . " is thumbnail for $pid");
      return $d->{pid};
    }
  }
  else {
    $self->app->log->debug("error searching for isthumbnailfor: " . $getres->code . " " . $getres->message);
  }
}

sub setNoCacheHeaders {
  my $self = shift;

  $self->res->headers->add('Pragma-Directive' => 'no-cache');
  $self->res->headers->add('Cache-Directive'  => 'no-cache');
  $self->res->headers->add('Cache-Control'    => 'no-cache');
  $self->res->headers->add('Pragma'           => 'no-cache');
  $self->res->headers->add('Expires'          => 0);
}

sub thumbnail {
  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  my $pid = $self->stash('pid');

  my $w = $self->param('w');
  my $h = $self->param('h');
  if (!$w and !$h) {
    $w = 120;
    $h = '';
  }

  my $thumbPid = $self->get_is_thumbnail_for($pid);
  if ($thumbPid) {
    $pid = $thumbPid;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $res         = $authz_model->check_rights($self, $pid, 'ro');
  unless ($res->{status} eq '200') {
    $self->setNoCacheHeaders();
    $self->reply->static('images/locked.png');
    return;
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $cmodelr      = $search_model->get_cmodel($self, $pid);
  if ($cmodelr->{status} ne 200) {
    $self->app->log->error("pid[$pid] could not get cmodel");
    $self->setNoCacheHeaders();
    $self->reply->static('images/error.png');
    return;
  }

  switch ($cmodelr->{cmodel}) {
    case ['Picture', 'Page', 'PDFDocument'] {
      if ($self->imageserver_job_status($pid) eq 'finished') {

        # use imageserver
        my $size       = "!$w,$h";
        my $isrv_model = PhaidraAPI::Model::Imageserver->new;
        my $res        = $isrv_model->get_url($self, Mojo::Parameters->new(IIIF => "$pid.tif/full/$size/0/default.jpg"), 0);
        if ($res->{status} ne 200) {
          $self->render(json => $res, status => $res->{status});
          return;
        }
        if (Mojo::IOLoop->is_running) {
          $self->render_later;
          $self->ua->get(
            $res->{url},
            sub {
              my ($c, $tx) = @_;
              _proxy_tx($self, $tx);
            }
          );
        }
        else {
          my $tx = $self->ua->get($res->{url});
          _proxy_tx($self, $tx);
        }

        # $self->render_later;
        # $self->ua->get($res->{url} => sub {my ($ua, $tx) = @_; $self->tx->res($tx->res); $self->rendered;});
        return;
      }
      else {
        switch ($cmodelr->{cmodel}) {
          case 'Picture' {
            $self->reply->static('images/image.png');
            return;
          }
          case 'Page' {
            $self->reply->static('images/document.png');
            return;
          }
          case 'PDFDocument' {
            $self->reply->static('images/document.png');
            return;
          }
        }
      }
    }
    case 'Book' {
      my $index_model = PhaidraAPI::Model::Index->new;
      my $docres      = $index_model->get_doc($self, $pid);
      if ($docres->{status} ne 200) {
        $self->app->log->error("pid [$pid] error searching for firstpage: " . $self->app->dumper($docres));
        $self->setNoCacheHeaders();
        $self->reply->static('images/error.png');
        return;
      }
      my $firstpage;
      if (exists($docres->{doc}->{firstpage})) {
        $firstpage = $docres->{doc}->{firstpage};
      }
      if ($firstpage) {
        if ($self->imageserver_job_status($firstpage) eq 'finished') {
          my $size       = "!$w,$h";
          my $isrv_model = PhaidraAPI::Model::Imageserver->new;
          my $res        = $isrv_model->get_url($self, Mojo::Parameters->new(IIIF => "$firstpage.tif/full/$size/0/default.jpg"), 0);
          if ($res->{status} ne 200) {
            $self->render(json => $res, status => $res->{status});
            return;
          }
          $self->render_later;
          $self->ua->get($res->{url} => sub {my ($ua, $tx) = @_; $self->tx->res($tx->res); $self->rendered;});
          return;
        }
        else {
          $self->reply->static('images/book.png');
          return;
        }
      }
      else {
        $self->reply->static('images/book.png');
        return;
      }
    }
    case 'Video' {
      if ($self->config->{streaming}) {
        my $u_model = PhaidraAPI::Model::Util->new;
        my $r       = $u_model->get_video_key($self, $pid);
        if ($r->{status} eq 200) {
          my $thumburl = 'https://' . $self->config->{streaming}->{server} . '/media/' . $self->config->{streaming}->{basepath} . '/' . $r->{video_key} . '.jpeg';
          if (Mojo::IOLoop->is_running) {
            $self->render_later;
            $self->ua->get(
              $thumburl,
              sub {
                my ($c, $tx) = @_;
                _proxy_tx($self, $tx);
              }
            );
          }
          else {
            my $tx = $self->ua->get($thumburl);
            _proxy_tx($self, $tx);
          }
          return;
        }
      }
      else {
        $self->reply->static('images/video.png');
        return;
      }
    }
    case 'Audio' {
      $self->reply->static('images/audio.png');
      return;
    }
    case 'Container' {
      $self->reply->static('images/container.png');
      return;
    }
    case 'Collection' {
      $self->reply->static('images/collection.png');
      return;
    }
    case 'Resource' {
      $self->reply->static('images/resource.png');
      return;
    }
    case 'Asset' {
      $self->reply->static('images/asset.png');
      return;
    }
  }

  $self->app->log->error("pid[$pid] oops!");
  $self->setNoCacheHeaders();
  $self->reply->static('images/error.png');
}

sub preview {
  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }
  my $pid = $self->stash('pid');

  my $force = $self->param('force');

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $resro       = $authz_model->check_rights($self, $pid, 'ro');
  unless ($resro->{status} eq '200') {
    $self->setNoCacheHeaders();
    $self->reply->static('images/locked.png');
    return;
  }

  my $trywebversion = 0;

  # we need mimetype for the audio/viedo player and size (either octets or webversion) to know if to use load button
  my ($filename, $mimetype, $size, $cmodel);

  if ($self->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;

    my $propres = $fedora_model->getObjectProperties($self, $pid);
    if ($propres->{status} != 200) {
      return $propres;
    }
    $cmodel = $propres->{cmodel};
    my $dsAttr;
    if (exists($propres->{contains})) {
      for my $contains (@{$propres->{contains}}) {
        if ($contains eq 'WEBVERSION') {
          $trywebversion = 1;
          $dsAttr        = $fedora_model->getDatastreamAttributes($self, $pid, 'WEBVERSION');
          if ($dsAttr->{status} eq 200) {
            $filename = $dsAttr->{filename};
            $mimetype = $dsAttr->{mimetype};
            $size     = $dsAttr->{size};
          }
          last;
        }
      }
    }

    unless ($trywebversion) {
      $dsAttr = $fedora_model->getDatastreamAttributes($self, $pid, 'OCTETS');
      if ($dsAttr->{status} ne 200) {
        $self->render(json => $dsAttr, status => $dsAttr->{status});
        return;
      }
      $filename = $dsAttr->{filename};
      $mimetype = $dsAttr->{mimetype};
      $size     = $dsAttr->{size};
    }
  }
  else {

    my $object_model = PhaidraAPI::Model::Object->new;
    my $r_oxml       = $object_model->get_foxml($self, $pid);
    if ($r_oxml->{status} ne 200) {
      $self->render(json => $r_oxml, status => $r_oxml->{status});
      return;
    }
    my $foxmldom = Mojo::DOM->new();
    $foxmldom->xml(1);
    $foxmldom->parse($r_oxml->{foxml});

    my $relsext;
    for my $e ($foxmldom->find('foxml\:datastream[ID="RELS-EXT"]')->each) {
      $relsext = $e->find('foxml\:datastreamVersion')->first;
      for my $e1 ($e->find('foxml\:datastreamVersion')->each) {
        if ($e1->attr('CREATED') gt $relsext->attr('CREATED')) {
          $relsext = $e1;
        }
      }
    }
    $cmodel = $relsext->find('foxml\:xmlContent')->first->find('hasModel')->first->attr('rdf:resource');
    $cmodel =~ s/^info:fedora\/cmodel:(.*)$/$1/;

    my $octets_model = PhaidraAPI::Model::Octets->new;

    if ($foxmldom->find('foxml\:datastream[ID="WEBVERSION"]')->first) {
      $trywebversion = 1;
      ($filename, $mimetype, $size) = $octets_model->_get_ds_attributes($self, $pid, 'WEBVERSION', $foxmldom);
    }
    else {
      ($filename, $mimetype, $size) = $octets_model->_get_ds_attributes($self, $pid, 'OCTETS', $foxmldom);
    }
  }

  my $docres;
  my $index_model = PhaidraAPI::Model::Index->new;
  if (!$size or $size == -1) {
    $self->app->log->debug("pid[$pid] getting size from index");
    $docres = $index_model->get_doc($self, $pid);
    if ($docres->{status} ne 200) {
      $self->app->log->error("pid[$pid] error searching for doc: " . $self->app->dumper($docres));

      #$self->reply->static('images/error.png');
      #return;
    }
    else {
      $size = $docres->{doc}->{size};
    }
  }

  my $showloadbutton = 0;
  unless ($force) {
    if ($size) {
      my $limit = 10000000;
      if (exists($self->config->{preview_size_limit})) {
        $limit = $self->config->{preview_size_limit};
      }
      if ($size > $limit) {
        $showloadbutton = 1;
      }
    }
  }
  if (defined($force)) {
    $self->app->log->info("preview pid[$pid] force[$force] cmodel[$cmodel] mimetype[$mimetype] size[$size] showloadbutton[$showloadbutton]");
  }
  else {
    $self->app->log->info("preview pid[$pid] force[NO] cmodel[$cmodel] mimetype[$mimetype] size[$size] showloadbutton[$showloadbutton]");
  }

  switch ($cmodel) {
    case ['Picture', 'Page'] {
      my $imgsrvjobstatus = $self->imageserver_job_status($pid);
      unless ($imgsrvjobstatus) {
        $self->app->log->info("Imageserver job not found: creating imageserver job pid[$pid] cm[$cmodel]");
        my $hash = hmac_sha1_hex($pid, $self->app->config->{imageserver}->{hash_secret});
        $self->paf_mongo->get_collection('jobs')->insert_one({pid => $pid, cmodel => $cmodel, agent => "pige", status => "new", idhash => $hash, created => time});
        $self->app->log->info("Imageserver job queued: sleeping... pid[$pid] cm[$cmodel]");
        Mojo::IOLoop->timer(8 => sub { });
        Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
        $self->app->log->info("Imageserver job queued: waking up... pid[$pid] cm[$cmodel]");
        $imgsrvjobstatus = $self->imageserver_job_status($pid);
        $self->app->log->info("Imageserver job queued: job status [$imgsrvjobstatus] pid[$pid] cm[$cmodel]");

        if ($imgsrvjobstatus ne 'finished') {
          $self->render(text => "Image processing status: queued. Please try again later.", status => 200);
          return;
        }
      }
      if ($imgsrvjobstatus eq 'new' or $imgsrvjobstatus eq 'in_progess') {
        $self->app->log->info("Imageserver job new/in_progess: sleeping... pid[$pid] cm[$cmodel]");
        Mojo::IOLoop->timer(6 => sub { });
        Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
        $self->app->log->info("Imageserver job new/in_progess: waking up... pid[$pid] cm[$cmodel]");
        $imgsrvjobstatus = $self->imageserver_job_status($pid);
        $self->app->log->info("Imageserver job new/in_progess: job status [$imgsrvjobstatus] pid[$pid] cm[$cmodel]");
      }
      if ($imgsrvjobstatus eq 'finished') {
        my $license = '';
        if (($cmodel eq 'Page') and ($self->app->config->{solr}->{core_pages})) {
          $docres = $index_model->get_page_doc($self, $pid);
        }

        if (!$docres or ($docres->{status} ne 200)) {
          $docres = $index_model->get_doc($self, $pid);
        }

        if (!$docres or ($docres->{status} ne 200)) {
          $docres = $index_model->get($self, $pid);
        }

        if ($docres->{status} ne 200) {
          $self->app->log->error("pid[$pid] error searching for doc: " . $self->app->dumper($docres));
          $self->reply->static('images/error.png');
          return;
        }
        for my $l (@{$docres->{doc}->{dc_license}}) {
          $license = $l;
        }

        $self->stash(rights => '');
        if ($resro->{status} eq '200') {
          $self->stash(rights => 'ro');
        }
        my $resrw = $authz_model->check_rights($self, $pid, 'rw');
        if ($resrw->{status} eq '200') {
          $self->stash(rights => 'rw');
        }

        $self->stash(annotations_json => '');
        if ( exists($docres->{doc}->{annotations_json})
          && defined($docres->{doc}->{annotations_json})
          && $docres->{doc}->{annotations_json} ne '')
        {
          $self->stash(annotations_json => @{$docres->{doc}->{annotations_json}}[0]);
        }

        $self->stash(baseurl  => $self->config->{baseurl});
        $self->stash(scheme   => $self->config->{scheme});
        $self->stash(basepath => $self->config->{basepath});
        $self->stash(pid      => $pid);
        $self->stash(license  => $license);

        my $u_model = PhaidraAPI::Model::Util->new;
        $u_model->track_action($self, $pid, 'preview');

        $self->render(template => 'utils/imageviewer', format => 'html');
        return;
      }
      else {
        $self->render(text => "Image processing status: " . $imgsrvjobstatus . ". Please try again later.", status => 200);
        return;
      }
    }
    case ['Book'] {
      unless ($docres) {
        $docres = $index_model->get_doc($self, $pid);
        if ($docres->{status} ne 200) {
          $self->app->log->error("pid[$pid] error searching for doc: " . $self->app->dumper($docres));
          $self->setNoCacheHeaders();
          $self->reply->static('images/error.png');
          return;
        }
      }

      my $page = $self->param('page');
      $page = looks_like_number($page) ? $page : 1;
      $self->stash(page     => $page);
      $self->stash(baseurl  => $self->config->{baseurl});
      $self->stash(basepath => $self->config->{basepath});
      $self->stash(pid      => $pid);

      my $u_model = PhaidraAPI::Model::Util->new;
      $u_model->track_action($self, $pid, 'preview');

      $self->render(template => 'utils/bookviewer', format => 'html');
      return;
    }
    case 'PDFDocument' {
      if ($showloadbutton) {
        $self->render(template => 'utils/loadbutton', format => 'html');
        return;
      }
      $self->stash(baseurl       => $self->config->{baseurl});
      $self->stash(scheme        => $self->config->{scheme});
      $self->stash(basepath      => $self->config->{basepath});
      $self->stash(trywebversion => $trywebversion);
      $self->stash(pid           => $pid);

      my $u_model = PhaidraAPI::Model::Util->new;
      $u_model->track_action($self, $pid, 'preview');

      $self->render(template => 'utils/pdfviewer', format => 'html');
      return;
    }
    case 'Asset' {

      unless ($docres) {
        if ($docres->{status} ne 200) {
          $self->app->log->error("pid[$pid] error searching for doc: " . $self->app->dumper($docres));
          $self->setNoCacheHeaders();
          $self->reply->static('images/error.png');
          return;
        }
      }

      # the mimetype in index can be coming from metadata too
      my $index_mime;
      for my $mt (@{$docres->{doc}->{dc_format}}) {
        $index_mime = $mt if $mt =~ m/\//g;
      }
      $self->app->log->info("preview pid[$pid] metadata mimetype[$index_mime]");
      if (($index_mime eq 'model/ply') || ($index_mime eq 'model/nxz')) {
        if ($showloadbutton) {
          $self->render(template => 'utils/loadbutton', format => 'html');
          return;
        }
        $self->stash(baseurl  => $self->config->{baseurl});
        $self->stash(basepath => $self->config->{basepath});
        $self->stash(pid      => $pid);
        $self->stash(mType    => 'ply')   if $index_mime eq 'model/ply';
        $self->stash(mType    => 'nexus') if $index_mime eq 'model/nxz';

        my $u_model = PhaidraAPI::Model::Util->new;
        $u_model->track_action($self, $pid, 'preview');

        $self->render(template => 'utils/3dviewer', format => 'html');
        return;
      }
      else {
        $self->reply->static('images/asset.png');
        return;
      }
    }
    case 'Video' {
      if ($self->config->{streaming}) {

        my $u_model = PhaidraAPI::Model::Util->new;
        my $r       = $u_model->get_video_key($self, $pid);
        if ($r->{status} eq 200) {
          my $trackpid;
          my $tracklabel;
          my $tracklanguage;

          # check if there isn't a track object
          unless ($docres) {
            $docres = $index_model->get_doc($self, $pid);
          }
          if ($docres->{status} ne 200) {
            $self->app->log->error("pid[$pid] error searching for doc: " . $self->app->dumper($docres));
          }
          else {
            for my $tpid (@{$docres->{doc}->{hastrack}}) {
              $self->app->log->info("pid[$pid] found track object: $tpid");
              $trackpid = $tpid;
              my $trackdocres = $index_model->get_doc($self, $trackpid);
              if ($trackdocres->{status} ne 200) {
                $self->app->log->error("pid[$pid] error searching for doc trackpid[$trackpid]: " . $self->app->dumper($docres));
              }
              else {
                for my $ttit (@{$trackdocres->{doc}->{dc_title}}) {
                  $tracklabel = $ttit;
                  last;
                }

                # pretend you don't see this
                my $lang_model   = PhaidraAPI::Model::Languages->new;
                my %iso6393ToBCP = reverse %{$lang_model->get_iso639map()};
                for my $lng3 (@{$trackdocres->{doc}->{dc_language}}) {
                  $tracklanguage = exists($iso6393ToBCP{$lng3}) ? $iso6393ToBCP{$lng3} : $lng3;
                  last;
                }
              }
            }
          }

          $self->stash(baseurl           => $self->config->{baseurl});
          $self->stash(basepath          => $self->config->{basepath});
          $self->stash(video_key         => $r->{video_key});
          $self->stash(errormsg          => $r->{errormsq});
          $self->stash(server            => $self->config->{streaming}->{server});
          $self->stash(server_rtmp       => $self->config->{streaming}->{server_rtmp});
          $self->stash(server_cd         => $self->config->{streaming}->{server_cd});
          $self->stash(streamingbasepath => $self->config->{streaming}->{basepath});
          $self->stash(trackpid          => $trackpid);
          $self->stash(tracklabel        => $tracklabel);
          $self->stash(tracklanguage     => $tracklanguage);

          my $u_model = PhaidraAPI::Model::Util->new;
          $u_model->track_action($self, $pid, 'preview');

          $self->render(template => 'utils/streamingplayer', format => 'html');
          return;
        }
        else {
          $self->app->log->error("Video key not available: " . $self->app->dumper($r));
          if ($r->{status} eq 404 or $r->{status} eq 503) {
            $self->render(text => "Stream is not available. Reason: Video is being prepared for streaming, please try again later.", status => $r->{status});
          }
          else {
            $self->render(text => "Stream is not available. Reason: " . $r->{alerts}[0]->{msg}, status => $r->{status});
          }

          return;
        }
      }
      else {
        if ($showloadbutton) {
          $self->render(template => 'utils/loadbutton', format => 'html');
          return;
        }
        $self->stash(scheme        => $self->config->{scheme});
        $self->stash(baseurl       => $self->config->{baseurl});
        $self->stash(basepath      => $self->config->{basepath});
        $self->stash(trywebversion => $trywebversion);

        # html tag won't work with video/quicktime
        $self->stash(mimetype => $mimetype = 'video/quicktime' ? 'video/mp4' : $mimetype);
        $self->stash(pid      => $pid);
        my $thumbPid = $self->get_is_thumbnail_for($pid);
        if ($thumbPid) {
          $self->stash(thumbpid => $pid);
        }

        my $u_model = PhaidraAPI::Model::Util->new;
        $u_model->track_action($self, $pid, 'preview');

        $self->render(template => 'utils/videoplayer', format => 'html');
        return;
      }
      return;
    }
    case 'Audio' {
      if ($showloadbutton) {
        $self->render(template => 'utils/loadbutton', format => 'html');
        return;
      }
      $self->stash(scheme        => $self->config->{scheme});
      $self->stash(baseurl       => $self->config->{baseurl});
      $self->stash(basepath      => $self->config->{basepath});
      $self->stash(trywebversion => $trywebversion);
      $self->stash(mimetype      => $mimetype);
      $self->stash(pid           => $pid);
      my $thumbPid = $self->get_is_thumbnail_for($pid);

      if ($thumbPid) {
        $self->stash(thumbpid => $pid);
      }

      my $u_model = PhaidraAPI::Model::Util->new;
      $u_model->track_action($self, $pid, 'preview');

      $self->render(template => 'utils/audioplayer', format => 'html');
      return;
    }
    else {
      my $thumbPid = $self->get_is_thumbnail_for($pid);
      if ($thumbPid) {
        if ($self->imageserver_job_status($thumbPid) eq 'finished') {
          my $thsize     = "!480,480";
          my $isrv_model = PhaidraAPI::Model::Imageserver->new;
          my $resis      = $isrv_model->get_url($self, Mojo::Parameters->new(IIIF => "$thumbPid.tif/full/$thsize/0/default.jpg"), 0);
          if ($resis->{status} ne 200) {
            $self->render(json => $resis, status => $resis->{status});
            return;
          }
          $self->render_later;
          $self->ua->get($resis->{url} => sub {my ($ua, $tx) = @_; $self->tx->res($tx->res); $self->rendered;});
          return;
        }
      }
      else {
        switch ($cmodel) {
          case 'Container' {
            $self->reply->static('images/container.png');
            return;
          }
          case 'Collection' {
            $self->reply->static('images/collection.png');
            return;
          }
          case 'Resource' {
            $self->reply->static('images/resource.png');
            return;
          }
        }
      }
    }
  }
  $self->reply->exception("pid[$pid] internal error");
}

sub delete {
  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->delete($self, $self->stash('pid'), $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  $self->render(json => $r, status => $r->{status});
}

sub modify {
  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $state            = $self->param('state');
  my $label            = $self->param('label');
  my $ownerid          = $self->param('ownerid');
  my $logmessage       = $self->param('logmessage');
  my $lastmodifieddate = $self->param('lastmodifieddate');

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->modify($self, $self->stash('pid'), $state, $label, $ownerid, $logmessage, $lastmodifieddate, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  $self->render(json => $r, status => $r->{status});
}

sub get_state {
  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $r;
  if ($self->param('foxml')) {
    my $object_model = PhaidraAPI::Model::Object->new;
    $r = $object_model->get_state($self, $self->stash('pid'));
  }
  else {
    my $search_model = PhaidraAPI::Model::Search->new;
    $r = $search_model->get_state($self, $self->stash('pid'));
  }

  $self->render(json => $r, status => $r->{status});
}

sub get_cmodel {
  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $r            = $search_model->get_cmodel($self, $self->stash('pid'));

  $self->render(json => $r, status => $r->{status});
}

sub create {
  my $self = shift;

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->create($self, $self->stash('cmodel'), $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  $self->render(json => $r, status => $r->{status});
}

sub create_empty {
  my $self = shift;

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->create_empty($self, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  $self->render(json => $r, status => $r->{status});
}

sub create_simple {

  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $object_model = PhaidraAPI::Model::Object->new;

  if ($self->req->is_limit_exceeded) {
    $self->app->log->debug("Size limit exceeded. Current max_message_size:" . $self->req->max_message_size);
    $self->render(json => {alerts => [{type => 'error', msg => 'File is too big'}]}, status => 400);
    return;
  }

  # $self->app->log->debug("XXXXXXXXXXXXXXXXXXXXXXXXX ".$self->app->dumper($self->req));

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
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
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

  my $mimetype = $self->param('mimetype');
  my $upload   = $self->req->upload('file');
  unless ($upload) {
    my $pullupload = $self->param('pullupload');
    if ($pullupload) {
      if (!$self->app->config->{'pullupload'}) {
        $self->app->log->error("Error: pullupload sent [$pullupload] but pullupload [" . $self->app->config->{'pullupload'} . "] was not configured.");
        unshift @{$res->{alerts}}, {type => 'error', msg => $@};
        $res->{status} = 400;
        $self->render(json => $res, status => $res->{status});
        return;
      }

      for my $rule (@{$self->app->config->{'pullupload'}}) {
        if ($rule->{username} eq $self->stash->{basic_auth_credentials}->{username}) {
          $self->directory->authenticate($self, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
          my $res = $self->stash('phaidra_auth_result');
          unless (($res->{status} eq 200)) {
            $self->app->log->info("User " . $self->stash->{basic_auth_credentials}->{username} . " not authenticated (pullupload)");
            $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});
            return;
          }
          $self->app->log->info("User " . $self->stash->{basic_auth_credentials}->{username} . " successfully authenticated (pullupload)");

          $pullupload = $rule->{folder} . '/' . $pullupload;

          my @files;
          my $start_dir = $rule->{folder};
          find(sub {push @files, $File::Find::name unless -d;}, $start_dir);
          my $foundfile;
          for my $file (@files) {
            if ($pullupload eq $file) {
              $foundfile = $file;
            }
          }
          if ($foundfile) {
            if (-r $pullupload) {
              my $fileAssset = Mojo::Asset::File->new(path => $pullupload);
              $upload = Mojo::Upload->new;
              $upload->asset($fileAssset);
              my $pulluploadPath = Mojo::Path->new($pullupload);
              my @parts          = @{$pulluploadPath->parts};
              my $filename       = $parts[-1];
              $upload->filename($filename);
            }
            else {
              $self->app->log->error("Error: pullupload [$pullupload] not readable.");
              unshift @{$res->{alerts}}, {type => 'error', msg => $@};
              $res->{status} = 400;
              $self->render(json => $res, status => $res->{status});
              return;
            }
            unless ($mimetype) {
              $mimetype = $object_model->get_mimetype($self, $upload->asset);
              $self->app->log->info("Undefined mimetype, using magic: $mimetype");
            }
          }
          else {
            $self->app->log->error("Error: pullupload [$pullupload] not found.");
            unshift @{$res->{alerts}}, {type => 'error', msg => $@};
            $res->{status} = 400;
            $self->render(json => $res, status => $res->{status});
            return;
          }
        }
      }
    }
  }
  my $checksumtype = $self->param('checksumtype');
  my $checksum     = $self->param('checksum');

  my $r = $object_model->create_simple($self, $self->stash('cmodel'), $metadata, $mimetype, $upload, $checksumtype, $checksum, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($r->{status} ne 200) {
    $res->{status} = $r->{status};
    foreach my $a (@{$r->{alerts}}) {
      unshift @{$res->{alerts}}, $a;
    }

    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error creating ' . $self->stash('cmodel') . ' object'};
    $self->render(json => $res, status => $res->{status});
    return;
  }

  foreach my $a (@{$r->{alerts}}) {
    unshift @{$res->{alerts}}, $a;
  }
  $res->{status} = $r->{status};
  $res->{pid}    = $r->{pid};

  $self->render(json => $res, status => $res->{status});
}

sub create_container {

  my $self = shift;

  my $res = {alerts => [], status => 200};

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
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
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

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->create_container($self, $metadata, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
  if ($r->{status} ne 200) {
    $res->{status} = $r->{status};
    foreach my $a (@{$r->{alerts}}) {
      unshift @{$res->{alerts}}, $a;
    }
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error creating ' . $self->stash('cmodel') . ' object'};
    $self->render(json => $res, status => $res->{status});
    return;
  }

  foreach my $a (@{$r->{alerts}}) {
    unshift @{$res->{alerts}}, $a;
  }
  $res->{status} = $r->{status};
  $res->{pid}    = $r->{pid};

  $self->render(json => $res, status => $res->{status});
}

sub add_relationship {

  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $predicate = $self->param('predicate');
  my $object    = $self->param('object');

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->add_relationship($self, $self->stash('pid'), $predicate, $object, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  $self->render(json => $r, status => $r->{status});

}

sub purge_relationship {

  my $self = shift;
  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $predicate = $self->param('predicate');
  my $object    = $self->param('object');

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->purge_relationship($self, $self->stash('pid'), $predicate, $object, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});

  $self->render(json => $r, status => $r->{status});

}

sub add_or_remove_identifier {

  my $self = shift;

  my $pid = $self->stash('pid');
  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $operation = $self->stash('operation');
  unless ($operation) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Unknown operation'}]}, status => 400);
    return;
  }

  my @ids;
  if ($self->param('hdl')) {
    push @ids, "hdl:" . $self->param('hdl');
  }
  if ($self->param('doi')) {
    push @ids, "doi:" . $self->param('doi');
  }
  if ($self->param('urn')) {
    push @ids, $self->param('urn');
  }

  unless (scalar @ids > 0) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No known identifier sent (param should be [hdl|doi|urn])'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r;
  for my $id (@ids) {
    if ($operation eq 'add') {
      $r = $object_model->add_relationship($self, $pid, 'http://purl.org/dc/terms/identifier', $id, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
    }
    elsif ($operation eq 'remove') {
      $r = $object_model->purge_relationship($self, $pid, 'http://purl.org/dc/terms/identifier', $id, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password});
    }
  }

  $self->render(json => $r, status => $r->{status});

}

sub add_octets {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $object_model = PhaidraAPI::Model::Object->new;

  $self->app->log->debug("=== headers ===");
  $self->app->log->debug($self->app->dumper($self->req->headers));
  $self->app->log->debug("==============");

  $self->app->log->debug("=== params ===");
  for my $pn (@{$self->req->params->names}) {
    $self->app->log->debug($pn);
  }
  for my $up (@{$self->req->uploads}) {
    $self->app->log->debug($up->{name} . ": " . $up->{filename});
  }
  $self->app->log->debug("==============");

  my $upload = $self->req->upload('file');

  if ($self->req->is_limit_exceeded) {
    $self->render(json => {alerts => [{type => 'error', msg => 'File is too big'}]}, status => 400);
    return;
  }

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $mimetype;
  if (defined($self->param('mimetype'))) {
    $mimetype = $self->param('mimetype');
  }
  else {
    $mimetype = $object_model->get_mimetype($self, $upload->asset);
    unshift @{$res->{alerts}}, {type => 'info', msg => "Undefined mimetype, using magic: $mimetype"};
  }

  my $pid          = $self->stash('pid');
  my $checksumtype = $self->param('checksumtype');
  my $checksum     = $self->param('checksum');

  my $addres = $object_model->add_octets($self, $pid, $upload, $mimetype, $checksumtype, $checksum, undef);
  push @{$res->{alerts}}, @{$addres->{alerts}} if scalar @{$addres->{alerts}} > 0;
  $res->{status} = $addres->{status};

  $self->render(json => $res, status => $res->{status});
}

sub add_or_modify_datastream {

  my $self = shift;

  unless (defined($self->stash('pid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  unless (defined($self->stash('dsid'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined dsid'}]}, status => 400);
    return;
  }

  unless (defined($self->param('mimetype'))) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined mimetype'}]}, status => 400);
    return;
  }

  my $mimetype     = $self->param('mimetype');
  my $location     = $self->param('location');
  my $checksumtype = $self->param('checksumtype');
  my $checksum     = $self->param('checksum');
  my $label        = undef;
  if ($self->param('dslabel')) {
    $label = $self->param('dslabel');
  }
  my $dscontent = undef;
  if ($self->param('dscontent')) {
    $dscontent = $self->param('dscontent');
    if (ref $dscontent eq 'Mojo::Upload') {

      # this is a file upload
      $self->app->log->debug("Parameter dscontent is a file parameter file=[" . $dscontent->filename . "] size=[" . $dscontent->size . "]");
      $dscontent = $dscontent->asset->slurp;
    }
    else {
      # $self->app->log->debug("Parameter dscontent is a text parameter");
    }
  }

  my $controlgroup = $self->param('controlgroup');

  my $object_model = PhaidraAPI::Model::Object->new;

  my $r = $object_model->add_or_modify_datastream($self, $self->stash('pid'), $self->stash('dsid'), $mimetype, $location, $label, $dscontent, $controlgroup, $checksumtype, $checksum, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0, 0);

  $self->render(json => $r, status => $r->{status});
}

sub get_metadata {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  my $mode = $self->param('mode');

  unless (defined($mode)) {
    $mode = 'basic';
  }

  my $search_model = PhaidraAPI::Model::Search->new;
  my $r            = $search_model->datastreams_hash($self, $pid);
  if ($r->{status} ne 200) {
    return $r;
  }

  my $writerights = 0;
  if ($self->app->config->{fedora}->{version} >= 6) {
    my $authz = PhaidraAPI::Model::Authorization->new;
    my $wr    = $authz->check_rights($self, $pid, 'w');
    if ($wr->{status} == 200) {
      $writerights = 1;
    }
  }

  if ($r->{dshash}->{'JSON-LD'}) {
    my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
    my $r_jsonld     = $jsonld_model->get_object_jsonld_parsed($self, $pid, $username, $password);
    if ($r_jsonld->{status} ne 200) {
      push @{$res->{alerts}}, @{$r_jsonld->{alerts}} if scalar @{$r_jsonld->{alerts}} > 0;
      push @{$res->{alerts}}, {type => 'error', msg => 'Error getting JSON-LD'};
    }
    else {
      $res->{metadata}->{'JSON-LD'} = $r_jsonld->{'JSON-LD'};
    }
  }

  if ($r->{dshash}->{'JSON-LD-PRIVATE'}) {
    if (($self->app->config->{fedora}->{version} < 6) || (($self->app->config->{fedora}->{version} >= 6) && $writerights)) {
      my $jsonldprivate_model = PhaidraAPI::Model::Jsonldprivate->new;
      my $r_jsonldprivate     = $jsonldprivate_model->get_object_jsonldprivate_parsed($self, $pid, $username, $password);
      if ($r_jsonldprivate->{status} ne 200) {
        if (($r->{status} eq 401) || ($r->{status} eq 403)) {

          # unauthorized users should not see that JSON-LD-PRIVATE exists
        }
        else {
          push @{$res->{alerts}}, @{$r_jsonldprivate->{alerts}} if scalar @{$r_jsonldprivate->{alerts}} > 0;
          push @{$res->{alerts}}, {type => 'error', msg => 'Error getting JSON-LD-PRIVATE'};
        }
      }
      else {
        $res->{metadata}->{'JSON-LD-PRIVATE'} = $r_jsonldprivate->{'JSON-LD-PRIVATE'};
      }
    }
  }

  if ($r->{dshash}->{'MODS'}) {
    my $mods_model = PhaidraAPI::Model::Mods->new;
    my $r          = $mods_model->get_object_mods_json($self, $pid, $mode, $username, $password);
    if ($r->{status} ne 200) {
      push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      push @{$res->{alerts}}, {type => 'error', msg => 'Error getting MODS'};
    }
    else {
      $res->{metadata}->{mods} = $r->{mods};
    }
  }

  if ($r->{dshash}->{'UWMETADATA'}) {
    my $uwmetadata_model = PhaidraAPI::Model::Uwmetadata->new;
    my $r                = $uwmetadata_model->get_object_metadata($self, $pid, $mode, $username, $password);
    if ($r->{status} ne 200) {
      push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      push @{$res->{alerts}}, {type => 'error', msg => 'Error getting UWMETADATA'};
    }
    else {
      $res->{metadata}->{uwmetadata} = $r->{uwmetadata};
    }
  }

  if ($r->{dshash}->{'GEO'}) {
    my $geo_model = PhaidraAPI::Model::Geo->new;
    my $r         = $geo_model->get_object_geo_json($self, $pid, $username, $password);
    if ($r->{status} ne 200) {
      push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      push @{$res->{alerts}}, {type => 'error', msg => 'Error getting GEO'};
    }
    else {
      $res->{metadata}->{geo} = $r->{geo};
    }
  }

  if ($r->{dshash}->{'RIGHTS'}) {
    if (($self->app->config->{fedora}->{version} < 6) || (($self->app->config->{fedora}->{version} >= 6) && $writerights)) {
      my $rights_model = PhaidraAPI::Model::Rights->new;
      my $r            = $rights_model->get_object_rights_json($self, $pid, $username, $password);
      if ($r->{status} ne 200) {
        if (($r->{status} eq 401) || ($r->{status} eq 403)) {

          # unauthorized users should not see that RIGHTS exists
        }
        else {
          push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
          push @{$res->{alerts}}, {type => 'error', msg => 'Error getting RIGHTS'};
        }
      }
      else {
        $res->{metadata}->{rights} = $r->{rights};
      }
    }
  }

  $self->render(json => $res, status => $res->{status});
}

sub metadata {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $t0 = [gettimeofday];

  my $pid = $self->stash('pid');

  my $metadata = $self->param('metadata');
  unless (defined($metadata)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata sent'}]}, status => 400);
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
      # http://showmetheco.de/articles/2010/10/how-to-avoid-unicode-pitfalls-in-mojolicious.html
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

  unless (defined($metadata->{metadata})) {
    $self->render(json => {alerts => [{type => 'error', msg => 'No metadata found'}]}, status => 400);
    return;
  }
  $metadata = $metadata->{metadata};

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $cmodel;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $res_cmodel   = $search_model->get_cmodel($self, $pid);
  if ($res_cmodel->{status} ne 200) {
    my $err = "ERROR saving metadata for object $pid, could not get cmodel:" . $self->app->dumper($res_cmodel);
    $self->app->log->error($err);
    $self->render(json => {alerts => [{type => 'error', msg => $err}]}, status => 500);
    return;
  }
  else {
    $cmodel = $res_cmodel->{cmodel};
  }

  my $object_model = PhaidraAPI::Model::Object->new;
  my $r            = $object_model->save_metadata($self, $pid, $cmodel, $metadata, $self->stash->{basic_auth_credentials}->{username}, $self->stash->{basic_auth_credentials}->{password}, 0, 0);
  if ($r->{status} ne 200) {
    $res->{status} = $r->{status};
    foreach my $a (@{$r->{alerts}}) {
      unshift @{$res->{alerts}}, $a;
    }
    unshift @{$res->{alerts}}, {type => 'error', msg => 'Error saving metadata'};

  }
  else {
    my $t1 = tv_interval($t0);
    unshift @{$res->{alerts}}, {type => 'success', msg => "Metadata for $pid saved successfully ($t1 s)"};

  }

  $self->render(json => $res, status => $res->{status});

}

sub get_legacy_container_member {
  my $self = shift;

  my $res = {alerts => [], status => 200};

  my $pid = $self->stash('pid');
  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}], status => 404}, status => 404);
    return;
  }

  my $ds = $self->stash('ds');
  unless (defined($ds)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined ds'}], status => 404}, status => 404);
    return;
  }

  my $authz_model = PhaidraAPI::Model::Authorization->new;
  my $authzres    = $authz_model->check_rights($self, $pid, 'ro');
  if ($authzres->{status} != 200) {
    $res->{status} = $authzres->{status};
    push @{$res->{alerts}}, @{$authzres->{alerts}} if scalar @{$authzres->{alerts}} > 0;
    $self->render(json => $res, status => $res->{status});
    return;
  }

  my ($filename, $mimetype, $size, $path);

  if ($self->app->config->{fedora}->{version} >= 6) {
    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $dsAttr       = $fedora_model->getDatastreamAttributes($self, $pid, 'OCTETS');
    if ($dsAttr->{status} ne 200) {
      $self->render(json => $dsAttr, status => $dsAttr->{status});
      return;
    }
    $filename = $dsAttr->{filename};
    $mimetype = $dsAttr->{mimetype};
    $size     = $dsAttr->{size};
    $dsAttr   = $fedora_model->getDatastreamPath($self, $pid, 'OCTETS');
    if ($dsAttr->{status} ne 200) {
      $self->render(json => $dsAttr, status => $dsAttr->{status});
      return;
    }
    $path = $dsAttr->{path};
  }
  else {
    my $object_model = PhaidraAPI::Model::Object->new;
    my $r_oxml       = $object_model->get_foxml($self, $pid);
    if ($r_oxml->{status} ne 200) {
      $self->render(json => $r_oxml, status => $r_oxml->{status});
      return;
    }
    my $dom = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($r_oxml->{foxml});

    my $octets_model = PhaidraAPI::Model::Octets->new;
    my $parthres     = $octets_model->_get_ds_path($self, $pid, $ds);
    if ($parthres->{status} != 200) {
      $res->{status} = $parthres->{status};
      push @{$res->{alerts}}, @{$parthres->{alerts}} if scalar @{$parthres->{alerts}} > 0;
      $self->render(json => $res, status => $res->{status});
      return;
    }
    else {
      $path = $parthres->{path};
    }
    ($filename, $mimetype, $size) = $octets_model->_get_ds_attributes($self, $pid, $ds, $dom);
  }
  $self->app->log->debug("operation[download_member] pid[$pid] path[$path] mimetype[$mimetype] filename[$filename] size[$size]");

  $self->res->headers->content_disposition("attachment;filename=\"$filename\"");
  $self->res->headers->content_type($mimetype);

  my $asset = Mojo::Asset::File->new(path => $path);
  $self->res->headers->add('Content-Length' => $asset->size);

  $self->res->content->asset($asset);
  $self->rendered($res->{status});
}

sub track_info {
  my ($self, $pid) = @_;

  my $fr = undef;
  if (exists($self->app->config->{sites})) {
    for my $f (@{$self->app->config->{sites}}) {
      if (defined($f->{site}) && $f->{site} eq 'phaidra') {
        $fr = $f;
      }
    }

    unless (defined($fr)) {
      $self->app->log->debug("pid[$pid] Not tracking detail: Site is not configured");
      return;
    }
    unless ($fr->{site} eq 'phaidra') {
      $self->app->log->error("pid[$pid] Error tracking detail: Site [" . $fr->{site} . "] is not supported");
      return;
    }
    unless (defined($fr->{stats})) {
      $self->app->log->error("pid[$pid] Error tracking detail: Statistics source is not configured");
      return;
    }
    unless (defined($fr->{stats}->{serverbaseurl})) {
      $self->app->log->error("pid[$pid] Error tracking detail: serverbaseurl is not configured");
      return;
    }
    unless (defined($fr->{stats}->{token})) {
      $self->app->log->error("pid[$pid] Error tracking detail: token is not configured");
      return;
    }

    # only piwik now
    unless ($fr->{stats}->{type} eq 'piwik') {
      $self->app->log->error("pid[$pid] Error tracking detail: Statistics source [" . $fr->{stats}->{type} . "] is not supported.");
      return;
    }

    unless (defined($fr->{stats}->{siteid})) {
      $self->app->log->error("pid[$pid] Error tracking detail: Piwik siteid is not configured.");
      return;
    }

    my $siteid      = $fr->{stats}->{siteid};
    my $matomoapi   = "https://" . $fr->{stats}->{serverbaseurl} . "/matomo.php";
    my $matomotoken = $fr->{stats}->{token};
    my $actionname  = url_escape("detail/$pid");

    my $trackurl  = "https://" . $self->app->config->{phaidra}->{baseurl} . "/detail/$pid";
    my $url       = url_escape($trackurl);
    my $cip       = url_escape($self->tx->remote_address);
    my $tracklink = "?idsite=$siteid&rec=1&url=$url&action_name=$actionname&cip=$cip";

    my $ua = Mojo::UserAgent->new;
    $ua->request_timeout(1);

    $ua->post_p(
      "$matomoapi" => json => {
        "token_auth" => "$matomotoken",
        "requests"   => [$tracklink]
      }
    )->then(
      sub {
        my ($tx) = @_;
        if ($tx->result->is_success) {
          $self->app->log->debug("pid[$pid] tracking detail successful");
        }
        else {
          $self->app->log->error("pid[$pid] tracking detail failed");
        }
      }
    )->catch(
      sub {
        my $err = shift;
        $self->app->log->error("pid[$pid] tracking detail failed: $err");
      }
    )->wait;
  }
  else {
    my $u_model = PhaidraAPI::Model::Util->new;
    $u_model->track_action($self, $pid, 'info');
  }
}

# Diss method is for calling the disseminator which is api-a access, so it can also be called without credentials.
# However, if the credentials are necessary, we want to send 401 so that the browser creates login prompt. Fedora sends 403
# in such case which won't create login prompt, so user cannot access locked object even if he should be able to login.
sub diss {
  my $self = shift;

  my $pid    = $self->stash('pid');
  my $bdef   = $self->stash('bdef');
  my $method = $self->stash('method');

  unless (defined($pid)) {
    $self->render(json => {alerts => [{type => 'error', msg => 'Undefined pid'}]}, status => 400);
    return;
  }

  my $object_model = PhaidraAPI::Model::Object->new;

  # do we have access without credentials?
  unless ($self->stash->{basic_auth_credentials}->{username}) {
    my $res = $object_model->get_datastream($self, $pid, 'READONLY', undef, undef);
    $self->app->log->info("pid[$pid] read rights: " . $res->{status});
    unless ($res->{status} eq '404') {
      $self->res->headers->www_authenticate('Basic');
      $self->render(json => {alerts => [{type => 'error', msg => 'authentication needed'}]}, status => 401);
      return;
    }
  }

  my $url = Mojo::URL->new;
  $url->scheme('https');
  $url->host($self->app->config->{phaidra}->{fedorabaseurl});
  $url->userinfo($self->stash->{basic_auth_credentials}->{username} . ":" . $self->stash->{basic_auth_credentials}->{password}) if $self->stash->{basic_auth_credentials}->{username};
  $url->path("/fedora/get/$pid/bdef:$bdef/$method");

  if (($bdef eq 'Resource') && ($method eq 'get')) {
    my $redres = $self->ua->get($url)->result;
    $self->app->log->info("fedora resource get result code[" . $redres->code . "] message[" . $redres->message . "] location[" . $redres->headers->location . "]");
    if ($redres->code == 302) {

      $self->res->headers->location($redres->headers->location);
      $self->rendered(302);
      return;
    }
    else {
      $self->render(json => {alerts => [{type => 'error', msg => $redres->message}]}, status => $redres->code);
      return;
    }
  }
  else {
    $self->app->log->info("user[" . $self->stash->{basic_auth_credentials}->{username} . "] proxying $url");
    if (Mojo::IOLoop->is_running) {
      $self->render_later;
      $self->ua->get(
        $url,
        sub {
          my ($c, $tx) = @_;
          _proxy_tx($self, $tx);
        }
      );
    }
    else {
      my $tx = $self->ua->get($url);
      _proxy_tx($self, $tx);
    }
  }
}

sub _proxy_tx {
  my ($c, $tx) = @_;
  my $res = $tx->result;
  if ($res->is_success) {
    $c->tx->res($res);
    $c->rendered;
  }
  else {
    my $error = $tx->error;
    $c->tx->res->headers->add('X-Remote-Status', $error->{code} . ': ' . $error->{message});
    $c->render(status => 500, text => 'Failed to fetch data from Fedora: ' . $c->app->dumper($tx->error));
  }
}

1;
