package PhaidraAPI;

use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use Log::Log4perl;
use Mojolicious::Static;
use Mojolicious::Plugin::I18N;
use Mojolicious::Plugin::Session;
use Mojolicious::Plugin::Log::Any;
use Mojo::Loader qw(load_class);
use FindBin;
use lib "$FindBin::Bin/lib/phaidra_directory";
use change_refs;
use MongoDB 1.8.3;
use Sereal::Encoder qw(encode_sereal);
use Sereal::Decoder qw(decode_sereal);
use Crypt::CBC              ();
use Crypt::Rijndael         ();
use Crypt::URandom          (qw/urandom/);
use Digest::SHA             (qw/hmac_sha256/);
use Math::Random::ISAAC::XS ();
use DBIx::Connector;

BEGIN {
  # that's what we want:
  # use MIME::Base64 3.12 (qw/encode_base64url decode_base64url/);

  # but you don't always get what you want, so:
  use MIME::Base64 (qw/encode_base64 decode_base64/);

  sub encode_base64url {
    my $e = encode_base64(shift, "");
    $e =~ s/=+\z//;
    $e =~ tr[+/][-_];
    return $e;
  }

  sub decode_base64url {
    my $s = shift;
    $s =~ tr[-_][+/];
    $s .= '=' while length($s) % 4;
    return decode_base64($s);
  }
}

use PhaidraAPI::Model::Session::Transport::Header;
use PhaidraAPI::Model::Session::Store::Mongo;

$ENV{MOJO_MAX_MESSAGE_SIZE}   = 207374182400;
$ENV{MOJO_INACTIVITY_TIMEOUT} = 1209600;
$ENV{MOJO_HEARTBEAT_TIMEOUT}  = 1209600;

#$ENV{MOJO_TMPDIR} = '/usr/local/fedora/imagemanipulator/tmp';

# This method will run once at server start
sub startup {
  my $self   = shift;
  my $config = $self->plugin('JSONConfig' => {file => 'PhaidraAPI.json'});
  change_refs::change_refs($config);
  $self->config($config);
  $self->mode($config->{mode});
  $self->secrets([$config->{secret}]);
  push @{$self->static->paths} => 'public';

  Log::Log4perl::init($FindBin::Bin . '/log4perl.conf');

  my $log = Log::Log4perl::get_logger("root");
  $self->plugin('Log::Any' => {logger => 'Log::Log4perl'});

  if ($config->{tmpdir}) {
    $self->app->log->debug("Setting MOJO_TMPDIR: " . $config->{tmpdir});
    $ENV{MOJO_TMPDIR} = $config->{tmpdir};
  }

  if ($config->{ssl_ca_path}) {
    $self->app->log->debug("Setting SSL_ca_path: " . $config->{ssl_ca_path});
    IO::Socket::SSL::set_defaults(SSL_ca_path => $config->{ssl_ca_path},);
  }

  my $directory_impl = $config->{directory_class};
  $self->app->log->debug("Loading directory implementation $directory_impl");
  my $e = load_class $directory_impl;
  if (ref $e) {
    $self->app->log->error("Loading $directory_impl failed: $e");

    #   next;
  }
  my $directory = $directory_impl->new($self, $config);

  $self->helper(directory => sub {return $directory;});

  # init I18N
  $self->plugin(I18N => {namespace => 'PhaidraAPI::I18N', support_url_langs => [qw(en de it sr)]});

  # init cache
  $self->plugin(
    CHI => {
      default => {
        driver => 'Memory',

        #driver     => 'File', # FastMmap seems to have problems saving the metadata structure (it won't save anything)
        #root_dir   => '/tmp/phaidra-api-cache',
        #cache_size => '20m',
        global => 1,

        #serializer => 'Storable',
      },
    }
  );

  # init databases
  my %databases;
  $databases{'db_metadata'} = {
    dsn      => $config->{phaidra_db}->{dsn},
    username => $config->{phaidra_db}->{username},
    password => $config->{phaidra_db}->{password},
    options  => {mysql_auto_reconnect => 1, mysql_enable_utf8 => 1}
  };

  if ($config->{phaidra_user_db}) {
    $databases{'db_user'} = {
      dsn      => $config->{phaidra_user_db}->{dsn},
      username => $config->{phaidra_user_db}->{username},
      password => $config->{phaidra_user_db}->{password},
      options  => {mysql_auto_reconnect => 1}
    };
  }

  if ($config->{phaidra}->{triplestore} &&
      $config->{phaidra}->{triplestore} eq 'localMysqlMPTTriplestore') {
    $databases{'db_triplestore'} = {
      dsn      => $config->{localMysqlMPTTriplestore}->{dsn},
      username => $config->{localMysqlMPTTriplestore}->{username},
      password => $config->{localMysqlMPTTriplestore}->{password},
      options  => {mysql_auto_reconnect => 1}
    };
  }

  if ($config->{fedora}->{fedora_db}) {
    $databases{'db_fedora'} = {
      dsn      => $config->{fedora}->{fedora_db}->{dsn},
      username => $config->{fedora}->{fedora_db}->{username},
      password => $config->{fedora}->{fedora_db}->{password},
      options  => {mysql_auto_reconnect => 1}
    };
  }

  if ($config->{imagemanipulator_db}) {
    $databases{'db_imagemanipulator'} = {
      dsn      => $config->{imagemanipulator_db}->{dsn},
      username => $config->{imagemanipulator_db}->{username},
      password => $config->{imagemanipulator_db}->{password},
      options  => {mysql_auto_reconnect => 1}
    };
  }

  if ($config->{ir}) {
    $databases{'db_ir'} = {
      dsn      => $config->{ir}->{'db'}->{dsn},
      username => $config->{ir}->{'db'}->{username},
      password => $config->{ir}->{'db'}->{password},
      options  => {mysql_auto_reconnect => 1}
    };
  }

  if (exists($config->{sites})) {
    for my $f (@{$config->{sites}}) {
      if (exists($f->{stats})) {
        if ($f->{stats}->{type} eq 'piwik') {
          $databases{'db_stats_' . $f->{site}} = {
            dsn      => $f->{stats}->{db_piwik}->{dsn},
            username => $f->{stats}->{db_piwik}->{username},
            password => $f->{stats}->{db_piwik}->{password},
            options  => {mysql_auto_reconnect => 1, RaiseError => 1}
          };
        }
      }
    }
  }

  foreach my $helper (keys %databases) {
    my $dbconf = $databases{$helper};
    $self->app->log->error('missing dsn parameter for ' . $helper) unless (defined($dbconf->{dsn}));
    my $attr_name = '_dbh_' . $helper;
    $self->app->attr(
      $attr_name => sub {
        my $cntr = DBIx::Connector->new($dbconf->{dsn}, $dbconf->{username}, $dbconf->{password}, $dbconf->{options});
        $cntr->mode('ping');
        return $cntr;
      }
    );
    $self->app->helper($helper => sub {return shift->app->$attr_name()});
  }

  # MongoDB driver
  $self->helper(
    mongo => sub {
      state $mongo = MongoDB::MongoClient->new(
        host               => $config->{mongodb}->{host},
        port               => $config->{mongodb}->{port},
        username           => $config->{mongodb}->{username},
        password           => $config->{mongodb}->{password},
        connect_timeout_ms => 300000,
        socket_timeout_ms  => 300000,
      )->get_database($config->{mongodb}->{database});
    }
  );

  if (exists($config->{paf_mongodb})) {
    $self->helper(
      paf_mongo => sub {
        state $paf_mongo = MongoDB::MongoClient->new(
          host     => $config->{paf_mongodb}->{host},
          port     => $config->{paf_mongodb}->{port},
          username => $config->{paf_mongodb}->{username},
          password => $config->{paf_mongodb}->{password},
        )->get_database($config->{paf_mongodb}->{database});
      }
    );
  }

  if (exists($config->{irma})) {
    $self->helper(
      irma_mongo => sub {
        state $irma_mongo = MongoDB::MongoClient->new(
          host     => $config->{irma}->{host},
          port     => $config->{irma}->{port},
          username => $config->{irma}->{username},
          password => $config->{irma}->{password},
          db_name  => $config->{irma}->{database}
        )->get_database($config->{irma}->{database});
      }
    );
  }

  if ($config->{fedora}->{version} > 6) {
    $self->helper(
      fedoraurl => sub {
        my $url = Mojo::URL->new;
        $url->scheme($config->{fedora}->{scheme});
        $url->host($config->{fedora}->{host});
        $url->port($config->{fedora}->{port}) if $config->{fedora}->{port};
        $url->path($config->{fedora}->{path});
        $url->userinfo($config->{fedora}->{adminuser} . ":" . $config->{fedora}->{adminpass});
        return $url;
      }
    );
  }

  # we might possibly save a lot of data to session
  # so we are not going to use cookies, but a database instead
  $self->plugin(
    session => {
      stash_key => 'mojox-session',
      store     => PhaidraAPI::Model::Session::Store::Mongo->new(
        mongo => $self->mongo,
        'log' => $self->log
      ),
      transport => PhaidraAPI::Model::Session::Transport::Header->new(
        header_name => $config->{authentication}->{token_header},
        cookie_name => $config->{authentication}->{token_cookie},
        'log'       => $self->log
      ),
      expires_delta => $config->{session_expiration},
      ip_match      => $config->{session_ip_match}
    }
  );

  $self->hook(
    'before_dispatch' => sub {
      my $self = shift;

      $self->app->log->debug('===> ' . $self->req->method . ' ' . $self->req->url);

      my $session = $self->stash('mojox-session');
      $session->load;
      if ($session->is_expired) {
        $session->expire;
        $session->flush;
      }
      elsif ($session->sid) {
        $session->extend_expires;
        $session->flush;
      }
    }
  );

  $self->hook(
    'after_dispatch' => sub {
      my $self = shift;

      $self->app->log->debug('<=== ' . $self->res->code . ' ' . $self->req->method . ' ' . $self->req->url);

      # CORS
      unless ($self->res->headers->header('Access-Control-Allow-Origin')) {
        if ($self->req->headers->header('Origin')) {
          $self->res->headers->add('Access-Control-Allow-Origin' => $self->req->headers->header('Origin'));
        }
        else {
          $self->res->headers->add('Access-Control-Allow-Origin' => $config->{authentication}->{'Access-Control-Allow-Origin'});
        }
      }
      $self->res->headers->add('Access-Control-Allow-Credentials' => 'true');
      $self->res->headers->add('Access-Control-Allow-Methods'     => 'GET, POST, PUT, DELETE, OPTIONS');

      # X-Prototype-Version, X-Requested-With - comes from prototype's Ajax.Updater
      my $allow_headers = 'Authorization, Content-Type, X-Prototype-Version, X-Requested-With, ' . $config->{authentication}->{token_header};
      if ($config->{authentication}->{upstream}->{principalheader}) {
        $allow_headers .= ', ' . $config->{authentication}->{upstream}->{principalheader};
      }
      if ($config->{authentication}->{upstream}->{affiliationheader}) {
        $allow_headers .= ', ' . $config->{authentication}->{upstream}->{affiliationheader};
      }

      $self->res->headers->add('Access-Control-Allow-Headers'  => $allow_headers);
      $self->res->headers->add('Access-Control-Expose-Headers' => 'x-json, Content-Disposition');
    }
  );

  $self->helper(
    save_cred => sub {
      my $self = shift;
      my $u    = shift;
      my $p    = shift;
      my $ru   = shift;
      my $firstname   = shift;
      my $lastname   = shift;
      my $email   = shift;
      my $affiliation   = shift;

      my $ciphertext;

      my $session = $self->stash('mojox-session');
      $session->load;
      unless ($session->sid) {
        $session->create;
      }
      my $ba;
      if (defined($u)) {
        $ba = encode_sereal({username => $u, password => $p});
      }
      if (defined($ru)) {
        $ba = encode_sereal({remote_user => $ru, firstname => $firstname, lastname => $lastname, email => $email, affiliation => $affiliation});
      }
      
      my $salt = Math::Random::ISAAC::XS->new(map {unpack("N", urandom(4))} 1 .. 256)->irand();
      my $key  = hmac_sha256($salt, $self->app->config->{enc_key});
      my $cbc  = Crypt::CBC->new(-key => $key, -pbkdf => 'pbkdf2');

      eval {$ciphertext = encode_base64url($cbc->encrypt($ba));};
      $self->app->log->error("Encoding error: $@") if $@;
      $session->data(cred => $ciphertext, salt => $salt);
      $session->flush;

      # $self->app->log->debug("Created session: ".$session->sid);
    }
  );

  $self->helper(
    load_cred => sub {
      my $self = shift;

      my $session = $self->stash('mojox-session');
      $session->load;
      unless ($session->sid) {
        return undef;
      }

      #$self->app->log->debug("Loaded session: ".$session->sid);

      my $salt       = $session->data('salt');
      my $ciphertext = $session->data('cred');
      my $key        = hmac_sha256($salt, $self->app->config->{enc_key});
      my $cbc        = Crypt::CBC->new(-key => $key, -pbkdf => 'pbkdf2');
      my $data;
      eval {$data = decode_sereal($cbc->decrypt(decode_base64url($ciphertext)))};
      $self->app->log->error("Decoding error: $@") if $@;

      return $data;
    }
  );

  # Set Content-Type header for XML rendering (default is 'application/xml', see https://docs.mojolicious.org/Mojolicious/Types) to be consistent with Fedora XML responses
  $self->types->type(xml => 'text/xml; charset=utf-8');

  my $r = $self->routes;
  $r->namespaces(['PhaidraAPI::Controller']);

  #<<< perltidy ignore
  $r->get('')                                       ->to('authentication#signin_shib');
  $r->get('openapi')                                ->to('utils#openapi');
  $r->get('openapi/json')                           ->to('utils#openapi_json');
  $r->get('languages')                              ->to('languages#get_languages');
  $r->get('licenses')                               ->to('licenses#get_licenses');
  $r->get('state')                                  ->to('utils#state');

  $r->get('uwmetadata/tree')                        ->to('uwmetadata#tree');
  $r->post('uwmetadata/json2xml')                   ->to('uwmetadata#json2xml');
  $r->post('uwmetadata/xml2json')                   ->to('uwmetadata#xml2json');
  $r->post('uwmetadata/validate')                   ->to('uwmetadata#validate');
  $r->post('uwmetadata/json2xml_validate')          ->to('uwmetadata#json2xml_validate');
  $r->post('uwmetadata/compress')                   ->to('uwmetadata#compress');
  $r->post('uwmetadata/decompress')                 ->to('uwmetadata#decompress');

  $r->get('mods/tree')                              ->to('mods#tree');
  $r->post('mods/json2xml')                         ->to('mods#json2xml');
  $r->post('mods/xml2json')                         ->to('mods#xml2json');
  $r->post('mods/validate')                         ->to('mods#validate');
  $r->post('mods/json2xml_validate')                ->to('mods#json2xml_validate');

  $r->post('rights/json2xml')                       ->to('rights#json2xml');
  $r->post('rights/xml2json')                       ->to('rights#xml2json');
  $r->post('rights/validate')                       ->to('rights#validate');
  $r->post('rights/json2xml_validate')              ->to('rights#json2xml_validate');

  $r->post('geo/json2xml')                          ->to('geo#json2xml');
  $r->post('geo/xml2json')                          ->to('geo#xml2json');
  $r->post('geo/validate')                          ->to('geo#validate');
  $r->post('geo/json2xml_validate')                 ->to('geo#json2xml_validate');

  $r->post('members/order/json2xml')                ->to('membersorder#json2xml');
  $r->post('members/order/xml2json')                ->to('membersorder#xml2json');

  $r->post('annotations/json2xml')                  ->to('annotations#json2xml');
  $r->post('annotations/xml2json')                  ->to('annotations#xml2json');
  $r->post('annotations/validate')                  ->to('annotations#validate');
  $r->post('annotations/json2xml_validate')         ->to('annotations#json2xml_validate');

  $r->get('help/tooltip')                           ->to('help#tooltip');

  $r->get('directory/get_study')                    ->to('directory#get_study');
  $r->get('directory/get_study_plans')              ->to('directory#get_study_plans');
  $r->get('directory/get_study_name')               ->to('directory#get_study_name');
  # old
  $r->get('directory/get_org_units')                ->to('directory#get_org_units');
  $r->get('directory/get_parent_org_unit_id')       ->to('directory#get_parent_org_unit_id');
  # new
  $r->get('directory/org_get_subunits')             ->to('directory#org_get_subunits');
  $r->get('directory/org_get_superunits')           ->to('directory#org_get_superunits');
  $r->get('directory/org_get_parentpath')           ->to('directory#org_get_parentpath');
  $r->get('directory/org_get_units')                ->to('directory#org_get_units');

  $r->get('search/triples')                         ->to('search#triples');
  $r->get('search/select')                          ->to('search#search_solr');
  $r->post('search/select')                         ->to('search#search_solr');
  $r->post('search/get_pids')                       ->to('search#get_pids');

  $r->get('utils/get_all_pids')                     ->to('utils#get_all_pids');

  $r->get('geonames/search')                        ->to('utils#geonames_search');
  $r->get('gnd/search')                             ->to('utils#gnd_search');

  $r->get('vocabulary')                             ->to('vocabulary#get_vocabulary');

  $r->get('terms/label')                   		      ->to('terms#label');
  $r->get('terms/children')                	        ->to('terms#children');
  $r->get('terms/search')                           ->to('terms#search');
  $r->get('terms/taxonpath')                        ->to('terms#taxonpath');
  $r->get('terms/parent')                           ->to('terms#parent');

  $r->get('resolve')                                ->to('resolve#resolve');

  # CORS
  $r->options('*')                                  ->to('authentication#cors_preflight');

  $r->get('signin')                                 ->to('authentication#signin');
  $r->get('signout')                                ->to('authentication#signout');
  $r->get('keepalive')                              ->to('authentication#keepalive');

  $r->get('collection/:pid/members')                ->to('collection#get_collection_members');
  $r->get('collection/:pid/descendants')            ->to('collection#descendants');

  # does not show inactive objects, not specific to collection (but does ordering)
  $r->get('object/:pid/related')                    ->to('search#related');

  # we will get this datastreams by using intcall credentials
  # (instead of defining a API-A disseminator for each of them)
  $r->get('object/:pid/uwmetadata')                 ->to('uwmetadata#get');
  $r->get('object/:pid/mods')                       ->to('mods#get');
  $r->get('object/:pid/jsonld')                     ->to('jsonld#get');
  $r->get('object/:pid/json-ld')                    ->to('jsonld#get', header => '1');
  $r->get('object/:pid/geo')                        ->to('geo#get');
  $r->get('object/:pid/members/order')              ->to('membersorder#get');
  $r->get('object/:pid/annotations')                ->to('annotations#get');
  $r->get('object/:pid/techinfo')                   ->to('techinfo#get');
  $r->get('object/:pid/dc')                         ->to('dc#get', dsid => 'DC');
  $r->get('object/:pid/oai_dc')                     ->to('dc#get', dsid => 'DC_OAI');
  $r->get('object/:pid/index')                      ->to('index#get');
  $r->get('object/:pid/index/dc')                   ->to('index#get_dc');
  $r->get('object/:pid/index/relationships')        ->to('index#get_relationships');
  $r->get('object/:pid/index/members')              ->to('index#get_object_members');
  $r->get('object/:pid/datacite')                   ->to('datacite#get');
  $r->get('object/:pid/lom')                        ->to('mappings#get', schema => 'lom');
  $r->get('object/:pid/edm')                        ->to('mappings#get', schema => 'edm');
  $r->get('object/:pid/openaire')                   ->to('mappings#get', schema => 'openaire');
  $r->get('object/:pid/state')                      ->to('object#get_state');
  $r->get('object/:pid/cmodel')                     ->to('object#get_cmodel');
  $r->get('object/:pid/relationships')              ->to('relationships#get');
  $r->get('object/:pid/iiifmanifest')               ->to('iiifmanifest#get_iiif_manifest');

  $r->get('object/:pid/id')                         ->to('search#id');

  $r->post('dc/uwmetadata_2_dc_index')              ->to('dc#uwmetadata_2_dc_index');

  $r->get('stats/aggregates')                       ->to('stats#aggregates');
  $r->get('stats/disciplines')                      ->to('stats#disciplines');
  $r->get('stats/:pid')                             ->to('stats#stats');
  $r->get('stats/:pid/downloads')                   ->to('stats#stats', stats_param_key => 'downloads');
  $r->get('stats/:pid/detail_page')                 ->to('stats#stats', stats_param_key => 'detail_page');
  $r->get('stats/:pid/chart')                       ->to('stats#chart');

  $r->get('ir/stats/topdownloads')                  ->to('ir#stats_topdownloads');
  $r->get('ir/stats/:pid')                          ->to('ir#stats');
  $r->get('ir/stats/:pid/downloads')                ->to('ir#stats', stats_param_key => 'downloads');
  $r->get('ir/stats/:pid/detail_page')              ->to('ir#stats', stats_param_key => 'detail_page');
  $r->get('ir/stats/:pid/chart')                    ->to('ir#stats_chart');

  $r->get('directory/user/#username/data')          ->to('directory#get_user_data');
  $r->get('directory/user/#username/name')          ->to('directory#get_user_name');
  $r->get('directory/user/#username/email')         ->to('directory#get_user_email');

  $r->get('oai')                                    ->to('oai#handler');
  $r->post('oai')                                   ->to('oai#handler');
  $r->get('oaitest')                                ->to('oaitest#handler');
  $r->post('oaitest')                               ->to('oaitest#handler');

  $r->get('termsofuse')                             ->to('termsofuse#get');

  $r->get('list/token/:token')                      ->to('lists#get_token_list');

  $r->get('app_settings')                           ->to('settings#get_app_settings');

  if ($self->app->config->{fedora}->{version} >= 6) {
    my $ext_creds = $r->under('/')->to('authentication#extract_credentials', creds_must_be_present => 0);

    my $loggedin  = $ext_creds->under('/')->to('authentication#authenticate');

    my $admin     = $ext_creds->under('/')->to('authentication#authenticate_admin');
    my $ir_admin  = $ext_creds->under('/')->to('authentication#authenticate_ir_admin');

    my $reader    = $ext_creds->under('/')->to('authorization#authorize', op => 'r');
    my $writer    = $loggedin->under('/')->to('authorization#authorize', op => 'w');

    if($self->app->config->{allow_userdata_queries}){
      $loggedin->get('directory/user/search')                                ->to('directory#search_user');
    }

    $loggedin->get('directory/user/data')                                    ->to('directory#get_user_data');

    $loggedin->get('settings')                                               ->to('settings#get_settings');

    $loggedin->get('groups')                                                 ->to('groups#get_users_groups');
    $loggedin->get('group/:gid')                                             ->to('groups#get_group');

    $loggedin->get('lists')                                                  ->to('lists#get_lists');
    $loggedin->get('list/:lid')                                              ->to('lists#get_list');

    $loggedin->get('jsonld/templates')                                       ->to('jsonld#get_users_templates');
    $loggedin->get('jsonld/template/:tid')                                   ->to('jsonld#get_template');

    $loggedin->get('authz/check/:pid/:op')                                   ->to('authorization#check_rights');

    $reader->get('streaming/:pid')                                           ->to('object#preview');
    $reader->get('streaming/:pid/key')                                       ->to('utils#streamingplayer_key');

    $reader->get('imageserver')                                              ->to('imageserver#imageserverproxy');
    $reader->get('imageserver/:pid/status')                                  ->to('imageserver#status');

    $ext_creds->get('object/:pid/info')                                      ->to('object#info');
    $ext_creds->get('object/:pid/metadata')                                  ->to('object#get_metadata');

    $reader->get('object/:pid/fulltext')                                     ->to('fulltext#get');
    $reader->get('object/:pid/thumbnail')                                    ->to('object#thumbnail');
    $reader->get('object/:pid/preview')                                      ->to('object#preview');
    $reader->get('object/:pid/md5')                                          ->to('inventory#get_md5');
    $reader->get('object/:pid/octets')                                       ->to('octets#proxy');
    $reader->get('object/:pid/download')                                     ->to('octets#get', operation => 'download');
    $reader->get('object/:pid/get')                                          ->to('octets#get', operation => 'get');
    $reader->get('object/:pid/comp/:ds')                                     ->to('object#get_legacy_container_member');
    $reader->get('object/:pid/datastream/:dsid')                             ->to('object#get_public_datastream');
    $reader->get('object/:pid/resourcelink/get')                             ->to('object#resourcelink', operation => 'get');
    $reader->get('object/:pid/resourcelink/redirect')                        ->to('object#resourcelink', operation => 'redirect');

    $writer->get('object/:pid/jsonldprivate')                                ->to('jsonldprivate#get');
    $writer->get('object/:pid/rights')                                       ->to('rights#get');

    $loggedin->get('termsofuse/getagreed')                                   ->to('termsofuse#getagreed');

    $ir_admin->post('ir/adminlistdata')                                      ->to('ir#adminlistdata');
    $ir_admin->get('ir/:pid/events')                                         ->to('ir#events');
    $ir_admin->get('ir/allowsubmit')                                         ->to('ir#allowsubmit');
    $ir_admin->get('ir/puresearch')                                          ->to('ir#puresearch');
    $ir_admin->get('ir/pureimport/locks')                                    ->to('ir#pureimport_getlocks');

    unless($self->app->config->{readonly}){

      $admin->post('app_settings')                                           ->to('settings#post_app_settings');

      $admin->post('index')                                                  ->to('index#update');
      $admin->post('dc')                                                     ->to('dc#update');

      $admin->post('object/:pid/index')                                      ->to('index#update');
      $admin->post('object/:pid/dc')                                         ->to('dc#update');

      $admin->post('imageserver/process')                                    ->to('imageserver#process_pids');
      $writer->post('imageserver/:pid/process')                              ->to('imageserver#process');
      $admin->post('streaming/process')                                      ->to('streaming#process_pids');
      $admin->post('streaming/:pid/process')                                 ->to('streaming#process');

      $writer->post('object/:pid/updateiiifmanifest')                        ->to('iiifmanifest#update_manifest_metadata');
      $writer->post('object/:pid/modify')                                    ->to('object#modify');
      $writer->post('object/:pid/delete')                                    ->to('object#delete');
      $writer->post('object/:pid/uwmetadata')                                ->to('uwmetadata#post');
      $writer->post('object/:pid/mods')                                      ->to('mods#post');
      $writer->post('object/:pid/jsonld')                                    ->to('jsonld#post');
      $writer->post('object/:pid/jsonldprivate')                             ->to('jsonldprivate#post');
      $writer->post('object/:pid/geo')                                       ->to('geo#post');
      $writer->post('object/:pid/annotations')                               ->to('annotations#post');
      $writer->post('object/:pid/rights')                                    ->to('rights#post');
      $writer->post('object/:pid/iiifmanifest')                              ->to('iiifmanifest#post');
      $writer->post('object/:pid/metadata')                                  ->to('object#metadata');
      $writer->post('object/:pid/relationship/add')                          ->to('object#add_relationship');
      $writer->post('object/:pid/relationship/remove')                       ->to('object#purge_relationship');
      $writer->post('object/:pid/id/add')                                    ->to('object#add_or_remove_identifier', operation => 'add');
      $writer->post('object/:pid/id/remove')                                 ->to('object#add_or_remove_identifier', operation => 'remove');
      $writer->post('object/:pid/datastream/:dsid')                          ->to('object#add_or_modify_datastream');
      $writer->post('object/:pid/data')                                      ->to('object#add_octets');

      $admin->post('objects/:currentowner/modify')                           ->to('object#modify_bulk');
      $admin->post('objects/:currentowner/delete')                           ->to('object#delete_bulk');

      $loggedin->post('picture/create')                                      ->to('object#create_simple', cmodel => 'cmodel:Picture');
      $loggedin->post('document/create')                                     ->to('object#create_simple', cmodel => 'cmodel:PDFDocument');
      $loggedin->post('video/create')                                        ->to('object#create_simple', cmodel => 'cmodel:Video');
      $loggedin->post('audio/create')                                        ->to('object#create_simple', cmodel => 'cmodel:Audio');
      $loggedin->post('unknown/create')                                      ->to('object#create_simple', cmodel => 'cmodel:Asset');
      $loggedin->post('resource/create')                                     ->to('object#create_simple', cmodel => 'cmodel:Resource');
      $loggedin->post('page/create')                                         ->to('object#create_simple', cmodel => 'cmodel:Page');
      $loggedin->post('object/create')                                       ->to('object#create_empty');
      $loggedin->post('object/create/:cmodel')                               ->to('object#create');
      $loggedin->post('container/create')                                    ->to('object#create_container');
      $loggedin->post('collection/create')                                   ->to('collection#create');

      $writer->post('container/:pid/members/order')                          ->to('membersorder#post');
      $writer->post('container/:pid/members/:itempid/order/:position')       ->to('membersorder#order_object_member');

      $writer->post('collection/:pid/members/remove')                        ->to('collection#remove_collection_members');
      $writer->post('collection/:pid/members/add')                           ->to('collection#add_collection_members');
      $writer->post('collection/:pid/members/order')                         ->to('membersorder#post');
      $writer->post('collection/:pid/members/:itempid/order/:position')      ->to('membersorder#order_object_member');

      $loggedin->post('group/add')                                           ->to('groups#add_group');
      $loggedin->post('group/:gid/remove')                                   ->to('groups#remove_group');
      $loggedin->post('group/:gid/members/add')                              ->to('groups#add_members');
      $loggedin->post('group/:gid/members/remove')                           ->to('groups#remove_members');

      $loggedin->post('list/add')                                            ->to('lists#add_list');
      $loggedin->post('list/:lid/token/create')                              ->to('lists#token_create');
      $loggedin->post('list/:lid/token/delete')                              ->to('lists#token_delete');
      $loggedin->post('list/:lid/remove')                                    ->to('lists#remove_list');
      $loggedin->post('list/:lid/members/add')                               ->to('lists#add_members');
      $loggedin->post('list/:lid/members/remove')                            ->to('lists#remove_members');

      $loggedin->post('jsonld/template/add')                                 ->to('jsonld#add_template');
      $loggedin->post('jsonld/template/:tid/remove')                         ->to('jsonld#remove_template');
      $loggedin->post('jsonld/template/:tid/edit')                           ->to('jsonld#edit_template');

      $loggedin->post('ir/submit')                                           ->to('ir#submit');
      $loggedin->post('ir/notifications')                                    ->to('ir#notifications');
      $ir_admin->post('ir/:pid/accept')                                      ->to('ir#accept');
      $ir_admin->post('ir/:pid/reject')                                      ->to('ir#reject');
      $ir_admin->post('ir/:pid/approve')                                     ->to('ir#approve');
      $ir_admin->post('ir/pureimport/lock/:pureid/:lockname')                ->to('ir#pureimport_lock');
      $ir_admin->post('ir/pureimport/unlock/:pureid/:lockname')              ->to('ir#pureimport_unlock');
      $ir_admin->post('ir/pureimport/reject/:uuid')                          ->to('ir#pureimport_reject');
      $admin->post('ir/embargocheck')                                        ->to('ir#embargocheck');

      $loggedin->post('feedback')                                            ->to('feedback#feedback');

      $loggedin->post('termsofuse/agree/:version')                           ->to('termsofuse#agree');

      $loggedin->post('settings')                                            ->to('settings#post_settings');

      $loggedin->post('utils/:pid/requestdoi')                               ->to('utils#request_doi');
    }
  } else {

    # this just extracts the credentials - authentication will be done by fedora
    my $proxyauth = $r->under('/')->to('authentication#extract_credentials', creds_must_be_present => 1);
    my $proxyauth_optional = $r->under('/')->to('authentication#extract_credentials', creds_must_be_present => 0);

    my $check_auth = $proxyauth->under('/')->to('authentication#authenticate');
    # check the user sends phaidra admin credentials
    my $admin = $proxyauth->under('/')->to('authentication#authenticate_admin');

    if($self->app->config->{allow_userdata_queries}){
      $check_auth->get('directory/user/search')                                 ->to('directory#search_user');
    }

    $check_auth->get('directory/user/data')                                     ->to('directory#get_user_data');

    $check_auth->get('settings')                                                ->to('settings#get_settings');

    $check_auth->get('groups')                                                  ->to('groups#get_users_groups');
    $check_auth->get('group/:gid')                                              ->to('groups#get_group');

    $check_auth->get('lists')                                                   ->to('lists#get_lists');
    $check_auth->get('list/:lid')                                               ->to('lists#get_list');

    $check_auth->get('jsonld/templates')                                        ->to('jsonld#get_users_templates');
    $check_auth->get('jsonld/template/:tid')                                    ->to('jsonld#get_template');

    $proxyauth_optional->get('authz/check/:pid/:op')                            ->to('authorization#check_rights');

    $proxyauth_optional->get('streaming/:pid')                                  ->to('object#preview');
    $proxyauth_optional->get('streaming/:pid/key')                              ->to('utils#streamingplayer_key');

    $proxyauth_optional->get('imageserver')                                     ->to('imageserver#imageserverproxy');

    $proxyauth_optional->get('object/:pid/diss/:bdef/:method')                  ->to('object#diss');
    $proxyauth_optional->get('object/:pid/fulltext')                            ->to('fulltext#get');
    $proxyauth_optional->get('object/:pid/metadata')                            ->to('object#get_metadata');
    $proxyauth_optional->get('object/:pid/info')                                ->to('object#info');
    $proxyauth_optional->get('object/:pid/thumbnail')                           ->to('object#thumbnail');
    $proxyauth_optional->get('object/:pid/preview')                             ->to('object#preview');
    $proxyauth_optional->get('object/:pid/md5')                                 ->to('inventory#get_md5');
    $proxyauth_optional->get('object/:pid/octets')                              ->to('octets#proxy');
    $proxyauth_optional->get('object/:pid/download')                            ->to('octets#get', operation => 'download');
    $proxyauth_optional->get('object/:pid/get')                                 ->to('octets#get', operation => 'get');
    $proxyauth_optional->get('object/:pid/comp/:ds')                            ->to('object#get_legacy_container_member');
    $proxyauth_optional->get('object/:pid/resourcelink/get')                    ->to('object#resourcelink', operation => 'get');
    $proxyauth_optional->get('object/:pid/resourcelink/redirect')               ->to('object#resourcelink', operation => 'redirect');

    $proxyauth_optional->get('imageserver/:pid/status')                         ->to('imageserver#status');

    $proxyauth->get('object/:pid/jsonldprivate')                                ->to('jsonldprivate#get');
    $proxyauth->get('object/:pid/rights')                                       ->to('rights#get');

    $check_auth->post('ir/requestedlicenses')                                   ->to('ir#adminlistdata'); # remove
    $check_auth->post('ir/adminlistdata')                                       ->to('ir#adminlistdata');
    $check_auth->get('ir/:pid/events')                                          ->to('ir#events');
    $check_auth->get('ir/allowsubmit')                                          ->to('ir#allowsubmit');
    $check_auth->get('ir/puresearch')                                           ->to('ir#puresearch');
    $check_auth->get('ir/pureimport/locks')                                     ->to('ir#pureimport_getlocks');

    $check_auth->get('termsofuse/getagreed')                                    ->to('termsofuse#getagreed');

    $admin->get('test/error')                                                   ->to('utils#testerror');

    unless($self->app->config->{readonly}){

      $admin->post('app_settings')                                              ->to('settings#post_app_settings');

      $admin->post('index')                                                     ->to('index#update');
      $admin->post('dc')                                                        ->to('dc#update');

      $check_auth->post('settings')                                             ->to('settings#post_settings');

      $admin->post('object/:pid/index')                                         ->to('index#update');
      $admin->post('object/:pid/dc')                                            ->to('dc#update');

      $admin->post('ir/embargocheck')                                           ->to('ir#embargocheck');

      $admin->post('imageserver/process')                                       ->to('imageserver#process_pids');

      $proxyauth->post('imageserver/:pid/process')                              ->to('imageserver#process');

      $admin->post('streaming/process')                                         ->to('streaming#process_pids');
      $proxyauth->post('streaming/:pid/process')                                ->to('streaming#process');

      $proxyauth->post('object/:pid/updateiiifmanifest')                        ->to('iiifmanifest#update_manifest_metadata');
      $proxyauth->post('object/:pid/modify')                                    ->to('object#modify');
      $proxyauth->post('object/:pid/delete')                                    ->to('object#delete');
      $proxyauth->post('object/:pid/uwmetadata')                                ->to('uwmetadata#post');
      $proxyauth->post('object/:pid/mods')                                      ->to('mods#post');
      $proxyauth->post('object/:pid/jsonld')                                    ->to('jsonld#post');
      $proxyauth->post('object/:pid/jsonldprivate')                             ->to('jsonldprivate#post');
      $proxyauth->post('object/:pid/geo')                                       ->to('geo#post');
      $proxyauth->post('object/:pid/annotations')                               ->to('annotations#post');
      $proxyauth->post('object/:pid/rights')                                    ->to('rights#post');
      $proxyauth->post('object/:pid/iiifmanifest')                              ->to('iiifmanifest#post');
      $proxyauth->post('object/:pid/metadata')                                  ->to('object#metadata');
      $proxyauth->post('object/create')                                         ->to('object#create_empty');
      $proxyauth->post('object/create/:cmodel')                                 ->to('object#create');
      $proxyauth->post('object/:pid/relationship/add')                          ->to('object#add_relationship');
      $proxyauth->post('object/:pid/relationship/remove')                       ->to('object#purge_relationship');
      $proxyauth->post('object/:pid/id/add')                                    ->to('object#add_or_remove_identifier', operation => 'add');
      $proxyauth->post('object/:pid/id/remove')                                 ->to('object#add_or_remove_identifier', operation => 'remove');
      $proxyauth->post('object/:pid/datastream/:dsid')                          ->to('object#add_or_modify_datastream');
      $proxyauth->post('object/:pid/data')                                      ->to('object#add_octets');

      $admin->post('objects/:currentowner/modify')                              ->to('object#modify_bulk');
      $admin->post('objects/:currentowner/delete')                              ->to('object#delete_bulk');

      $proxyauth->post('picture/create')                                        ->to('object#create_simple', cmodel => 'cmodel:Picture');
      $proxyauth->post('document/create')                                       ->to('object#create_simple', cmodel => 'cmodel:PDFDocument');
      $proxyauth->post('video/create')                                          ->to('object#create_simple', cmodel => 'cmodel:Video');
      $proxyauth->post('audio/create')                                          ->to('object#create_simple', cmodel => 'cmodel:Audio');
      $proxyauth->post('unknown/create')                                        ->to('object#create_simple', cmodel => 'cmodel:Asset');
      $proxyauth->post('resource/create')                                       ->to('object#create_simple', cmodel => 'cmodel:Resource');
      $proxyauth->post('page/create')                                           ->to('object#create_simple', cmodel => 'cmodel:Page');

      $proxyauth->post('container/create')                                      ->to('object#create_container');
      $proxyauth->post('container/:pid/members/order')                          ->to('membersorder#post');
      $proxyauth->post('container/:pid/members/:itempid/order/:position')       ->to('membersorder#order_object_member');

      $proxyauth->post('collection/create')                                     ->to('collection#create');
      $proxyauth->post('collection/:pid/members/remove')                        ->to('collection#remove_collection_members');
      $proxyauth->post('collection/:pid/members/add')                           ->to('collection#add_collection_members');
      $proxyauth->post('collection/:pid/members/order')                         ->to('membersorder#post');
      $proxyauth->post('collection/:pid/members/:itempid/order/:position')      ->to('membersorder#order_object_member');

      $check_auth->post('group/add')                                            ->to('groups#add_group');
      $check_auth->post('group/:gid/remove')                                    ->to('groups#remove_group');
      $check_auth->post('group/:gid/members/add')                               ->to('groups#add_members');
      $check_auth->post('group/:gid/members/remove')                            ->to('groups#remove_members');

      $check_auth->post('list/add')                                             ->to('lists#add_list');
      $check_auth->post('list/:lid/token/create')                               ->to('lists#token_create');
      $check_auth->post('list/:lid/token/delete')                               ->to('lists#token_delete');
      $check_auth->post('list/:lid/remove')                                     ->to('lists#remove_list');
      $check_auth->post('list/:lid/members/add')                                ->to('lists#add_members');
      $check_auth->post('list/:lid/members/remove')                             ->to('lists#remove_members');

      $check_auth->post('jsonld/template/add')                                  ->to('jsonld#add_template');
      $check_auth->post('jsonld/template/:tid/remove')                          ->to('jsonld#remove_template');
      $check_auth->post('jsonld/template/:tid/edit')                            ->to('jsonld#edit_template');

      $proxyauth->post('ir/submit')                                             ->to('ir#submit');
      $check_auth->post('ir/notifications')                                     ->to('ir#notifications');
      $check_auth->post('ir/:pid/accept')                                       ->to('ir#accept');
      $check_auth->post('ir/:pid/reject')                                       ->to('ir#reject');
      $check_auth->post('ir/:pid/approve')                                      ->to('ir#approve');
      $check_auth->post('ir/pureimport/lock/:pureid/:lockname')                 ->to('ir#pureimport_lock');
      $check_auth->post('ir/pureimport/unlock/:pureid/:lockname')               ->to('ir#pureimport_unlock');
      $check_auth->post('ir/pureimport/reject/:uuid')                           ->to('ir#pureimport_reject');

      $check_auth->post('feedback')                                             ->to('feedback#feedback');

      $check_auth->post('termsofuse/agree/:version')                            ->to('termsofuse#agree');

      $check_auth->post('utils/:pid/requestdoi')                                ->to('utils#request_doi');
    }
  }
  #>>>

  return $self;
}

1;
