package PhaidraAPI;

use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use Log::Log4perl;
use Mojolicious::Static;
use Mojolicious::Plugin::I18N;
use Mojolicious::Plugin::Session;
use Mojolicious::Plugin::Log::Any;
use Mojolicious::Plugin::Prometheus;
use Mojo::Loader qw(load_class);
use MongoDB 1.8.3;
use Sereal::Encoder qw(encode_sereal);
use Sereal::Decoder qw(decode_sereal);
use Crypt::CBC      ();
use Crypt::Rijndael ();
use Crypt::URandom (qw/urandom/);
use Digest::SHA    (qw/hmac_sha256/);
use Math::Random::ISAAC::XS ();
use DBIx::Connector;
use PhaidraAPI::Model::Fedora;

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

sub is_bot_ua {
  my ($ua) = @_;
  return 0 unless defined $ua;
  my $l = lc $ua;

  # Any UA containing 'bot', 'spider' or 'crawl'
  return 1 if index($l, 'bot') >= 0;
  return 1 if index($l, 'spider') >= 0;
  return 1 if index($l, 'crawl') >= 0;

  # Known non-'bot' identifiers
  return 1 if index($l, 'slurp') >= 0;                  # Yahoo
  return 1 if index($l, 'facebookexternalhit') >= 0;    # Facebook
  return 1 if index($l, 'bingpreview') >= 0;            # Bing link preview
  return 0;
}

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->log->level('debug');

  my $config = $self->plugin('Config' => {file => 'PhaidraAPI.conf'});
  $self->config($config);

  $self->log->info(
    sprintf(
      'OPA config enabled[%s] url[%s] path[%s] fail_mode[%s] dual_run[%s] institution[%s]',
      ($config->{opa}->{enabled} ? 'true' : 'false'),
      $config->{opa}->{url}         // '',
      $config->{opa}->{policy_path} // '',
      $config->{opa}->{fail_mode}   // '',
      ($config->{opa}->{dual_run} ? 'true' : 'false'),
      $config->{opa}->{institution} // '',
    )
  );

  $self->mode($config->{mode});
  $self->secrets([$config->{secret}]);
  push @{$self->static->paths} => 'public';

  if ($config->{tmpdir}) {
    $self->app->log->debug("Setting MOJO_TMPDIR: " . $config->{tmpdir});
    $ENV{MOJO_TMPDIR} = $config->{tmpdir};
    $ENV{TMPDIR}      = $config->{tmpdir};
  }

  if ($config->{ssl_ca_path}) {
    $self->app->log->debug("Setting SSL_ca_path: " . $config->{ssl_ca_path});
    IO::Socket::SSL::set_defaults(SSL_ca_path => $config->{ssl_ca_path},);
  }

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

  if ($config->{fedora}->{fedora_db}) {
    $databases{'db_fedora'} = {
      dsn      => $config->{fedora}->{fedora_db}->{dsn},
      username => $config->{fedora}->{fedora_db}->{username},
      password => $config->{fedora}->{fedora_db}->{password},
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

  # Override log level
  my $privconfig = eval {$self->mongo->get_collection('config')->find_one({config_type => 'private'})};
  if ($@) {
    $self->log->warn("Could not read private config for log level: $@");
  }
  elsif ($privconfig && $privconfig->{loglevel}) {
    my %valid_levels = map {$_ => 1} qw(trace debug info warn error fatal);
    if ($valid_levels{$privconfig->{loglevel}}) {
      $self->log->level($privconfig->{loglevel});
      $self->log->info("Log level set from private config: " . $privconfig->{loglevel});
    }
    else {
      $self->log->warn("Invalid loglevel in private config: " . $privconfig->{loglevel});
    }
  }

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

      my $bot = "";
      if (is_bot_ua($self->req->headers->user_agent)) {
        $bot = "[bot] ";
        $self->{isbot} = 1;
      }

      $self->app->log->debug("$bot===> " . $self->req->method . ' ' . $self->req->url);

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
    around_action => sub {
      my ($next, $c, $action, $last) = @_;

      my $pid = $c->stash('pid');
      if (defined $pid && $pid =~ /^o:/) {

        my $url_path = $c->req->url->path;
        $url_path = $url_path->to_string if ref($url_path);
        if ($url_path =~ m{/object/\Q$pid\E/index}) {
          return $next->();
        }

        my $cachekey = 'e_' . $pid;
        my $cacheval = $c->app->chi->get($cachekey);

        if ($cacheval) {
          return $next->();
        }

        my $fedora_model = PhaidraAPI::Model::Fedora->new;
        my $res          = $fedora_model->headObjectExists($c, $pid);

        if ($res->{status} && $res->{status} == 404) {
          $c->render(text => 'Object not found', status => 404);
          return;
        }

        if ($res->{status} && ($res->{status} == 200 || $res->{status} == 410)) {
          $c->app->chi->set($cachekey, 1, '1 day');
          return $next->();
        }
      }

      return $next->();
    }
  );

  $self->hook(
    'after_dispatch' => sub {
      my $self = shift;

      my $bot = "";
      if ($self->{isbot}) {
        $bot = "[bot] ";
      }
      $self->app->log->debug("$bot<=== " . $self->res->code . ' ' . $self->req->method . ' ' . $self->req->url);

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
      $self->res->headers->add('Access-Control-Allow-Headers'  => $allow_headers);
      $self->res->headers->add('Access-Control-Expose-Headers' => 'x-json, Content-Disposition');
    }
  );

  $self->helper(
    save_cred => sub {
      my $self         = shift;
      my $u            = shift;
      my $p            = shift;
      my $ru           = shift;
      my $firstname    = shift;
      my $lastname     = shift;
      my $email        = shift;
      my $affiliation  = shift;
      my $org_units_l1 = shift;
      my $org_units_l2 = shift;
      my $localgroups  = shift;
      my $displayname  = shift;

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
        $ba = encode_sereal(
          { remote_user  => $ru,
            firstname    => $firstname,
            lastname     => $lastname,
            displayname  => $displayname,
            email        => $email,
            affiliation  => $affiliation,
            org_units_l1 => $org_units_l1,
            org_units_l2 => $org_units_l2,
            localgroups  => $localgroups
          }
        );
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
  $self->types->type(mjs => 'application/javascript');

  my $r = $self->routes;
  $r->namespaces(['PhaidraAPI::Controller']);

  # Extract credentials from request.
  my $ext_creds = $r->under('/')->to('authentication#extract_credentials');

  # Does not force authentication.
  my $optionally_authenticated = $ext_creds->under('/')->to('authentication#authenticate_if_username');

  # Authn optional (anonymous allowed). Authorization always runs.
  my $authz_authnoptional = $optionally_authenticated->under('/')->to('authorization#authorize');

  # Only authentication (kept for /authz/capabilities and /authz/check).
  my $authenticated = $ext_creds->under('/')->to('authentication#authenticate');

  # Only for authenticated users. Includes authorization.
  my $authz = $authenticated->under('/')->to('authorization#authorize');

  # Site-admin password bridge kept for Prometheus only
  my $admin = $ext_creds->under('/')->to('authentication#authenticate_admin');
  $self->plugin('Prometheus' => {'route' => $admin});

  #<<< perltidy ignore
  $r->get('')                                       ->to('authentication#signin_shib');
  $r->get('openapi')                                ->to('utils#openapi');
  $r->get('openapi/json')                           ->to('utils#openapi_json');
  $r->get('languages')                              ->to('languages#get_languages');
  $r->get('licenses')                               ->to('licenses#get_licenses');
  $r->get('state')                                  ->to('utils#state');
  $r->get('robotstxt')                              ->to('utils#robots_txt');

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

  $r->get('directory/org_get_subunits')             ->to('directory#org_get_subunits');
  $r->get('directory/org_get_superunits')           ->to('directory#org_get_superunits');
  $r->get('directory/org_get_parentpath')           ->to('directory#org_get_parentpath');
  $r->get('directory/org_get_units')                ->to('directory#org_get_units');

  $r->get('search/select')                          ->to('search#search_solr');
  $r->post('search/select')                         ->to('search#search_solr');
  $r->get('search/:pid/ocr')                        ->to('search#search_ocr');
  $r->post('search/get_pids')                       ->to('search#get_pids');

  $r->get('geonames/search')                        ->to('utils#geonames_search');
  $r->get('gnd/search')                             ->to('utils#gnd_search');
  
  $r->get('alma/search')                            ->to('alma#search');
  $r->get('alma/:acnumber/jsonld')                  ->to('alma#get_record_jsonld');
  $r->get('alma/:acnumber/json')                    ->to('alma#get_record_json');

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
  $r->get('collection/:pid/rss')                    ->to('collection#rss');

  $r->get('object/:pid/members/order')              ->to('membersorder#get');
  $r->get('object/:pid/dc')                         ->to('dc#get');
  $r->get('object/:pid/index')                      ->to('index#get');
  $r->get('object/:pid/index/dc')                   ->to('dc#get');
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
  
  $r->get('stats/aggregates')                       ->to('stats#aggregates');
  $r->get('stats/disciplines')                      ->to('stats#disciplines');
  $r->get('stats/:pid')                             ->to('stats#stats');
  $r->get('stats')                                  ->to('stats#stats_general');
  $r->get('stats/:pid/downloads')                   ->to('stats#stats', stats_param_key => 'downloads');
  $r->get('stats/:pid/detail_page')                 ->to('stats#stats', stats_param_key => 'detail_page');
  $r->get('stats/:pid/chart')                       ->to('stats#chart');
  $authz->get('stats/myobjects')                    ->to('stats#myobjects', action_id => 'stats_myobjects');

  $r->get('directory/user/#username/data')          ->to('directory#get_user_data');
  $r->get('directory/user/#username/name')          ->to('directory#get_user_name');
  $r->get('directory/user/#username/email')         ->to('directory#get_user_email');

  $r->get('oai')                                    ->to('oai#handler');
  $r->post('oai')                                   ->to('oai#handler');

  $r->get('termsofuse')                             ->to('termsofuse#get');

  $r->get('list/token/:token')                      ->to('lists#get_token_list');

  $r->get('config/public')                          ->to('config#get_public_config');
  $r->get('cms/template/all')                       ->to('cms#get_all_templates');
  $r->get('cms/template/:templateName')             ->to('cms#get_template');

  $r->get('/jwks')                                  ->to('utils#jwks');

  $authz->get('directory/user/data')                                       ->to('directory#get_user_data', action_id => 'directory_self');

  $authz->get('settings')                                                  ->to('settings#get_settings', action_id => 'settings_read');

  $authz->get('groups')                                                    ->to('groups#get_users_groups', action_id => 'group_read');
  $authz->get('group/:gid')                                                ->to('groups#get_group', action_id => 'group_read');

  $authz->get('lists')                                                     ->to('lists#get_lists', action_id => 'list_read');
  $authz->get('list/:lid')                                                 ->to('lists#get_list', action_id => 'list_read');

  $authz->get('inactive-objects')                                          ->to('inactive_objects#list', action_id => 'inactive_objects_read');

  $authz->get('jsonld/templates')                                          ->to('jsonld#get_users_templates', action_id => 'template_read');
  $authz->get('jsonld/template/:tid')                                      ->to('jsonld#get_template', action_id => 'template_read');

  $authenticated->post('authz/check')                                      ->to('authorization#check_batch');
  $authenticated->get('authz/capabilities')                                ->to('authorization#capabilities');

  $authz_authnoptional->get('streaming/:pid')                                   ->to('object#preview', action_id => 'read');
  $authz_authnoptional->get('streaming/:pid/key')                               ->to('streaming#key', action_id => 'read');

  $optionally_authenticated->get('imageserver')                            ->to('imageserver#imageserverproxy');
  $authz_authnoptional->get('imageserver/:pid/status')                          ->to('imageserver#status', action_id => 'read');

  # Only authn, authz happens in controller because metadata might be partially restricted (JSON-LD-PRIVATE)
  $optionally_authenticated->get('object/:pid/metadata')                   ->to('object#get_metadata');
  # Only authn, authz is queried in model to find out if the user (if any) has write rights to set the flag for UI
  $optionally_authenticated->get('object/:pid/info')                       ->to('object#info');

  # This might need authorization if the object is inactive.
  $authz_authnoptional->get('object/:pid/uwmetadata')                           ->to('uwmetadata#get', action_id => 'read');
  $authz_authnoptional->get('object/:pid/mods')                                 ->to('mods#get', action_id => 'read');
  $authz_authnoptional->get('object/:pid/jsonld')                               ->to('jsonld#get', action_id => 'read');
  $authz_authnoptional->get('object/:pid/json-ld')                              ->to('jsonld#get', header => '1', action_id => 'read');
  $authz_authnoptional->get('object/:pid/geo')                                  ->to('geo#get', action_id => 'read');
  $authz_authnoptional->get('object/:pid/annotations')                          ->to('annotations#get', action_id => 'read');

  # This might need authorization if the object is restricted.
  $authz_authnoptional->get('object/:pid/fulltext')                             ->to('fulltext#get', action_id => 'read');
  # authz_deny_static: on authz 403 return this image (HTTP 200) so <img> tags still render a lock icon.
  $authz_authnoptional->get('object/:pid/thumbnail')                            ->to('object#thumbnail', action_id => 'read', authz_deny_static => 'images/locked.png');
  $authz_authnoptional->get('object/:pid/preview')                              ->to('object#preview', action_id => 'read');
  $authz_authnoptional->get('object/:pid/3d_resource')                          ->to('threed#get_resource', action_id => 'read');
  $authz_authnoptional->get('object/:pid/360_frame')                            ->to('viewer360#get_frame', action_id => 'read');
  $authz_authnoptional->get('object/:pid/360_frames/*filename')                 ->to('viewer360#get_frame_by_name', action_id => 'read');
  $authz_authnoptional->get('object/:pid/octets')                               ->to('octets#proxy', action_id => 'read');
  $authz_authnoptional->get('object/:pid/download')                             ->to('octets#download', action_id => 'read');
  $authz_authnoptional->get('object/:pid/get')                                  ->to('octets#get', action_id => 'read');
  $authz_authnoptional->get('object/:pid/comp/:ds')                             ->to('object#get_legacy_container_member', action_id => 'read');
  $authz_authnoptional->get('object/:pid/datastream/:dsid')                     ->to('object#get_datastream', action_id => 'read');
  $authz_authnoptional->get('object/:pid/resourcelink/get')                     ->to('object#get_resourcelink', action_id => 'read');
  $authz_authnoptional->get('object/:pid/resourcelink/redirect')                ->to('object#redirect_resourcelink', action_id => 'read');
  $authz_authnoptional->get('object/:pid/jsonldprivate')                        ->to('jsonldprivate#get', dsid => 'JSON-LD-PRIVATE', action_id => 'read');
  $authz_authnoptional->get('object/:pid/rights')                               ->to('rights#get', dsid => 'RIGHTS', action_id => 'read');

  $authz->get('termsofuse/getagreed')                                      ->to('termsofuse#getagreed', action_id => 'termsofuse_read');
  $authz->get('users/search')                                              ->to('utils#search_users', action_id => 'users_search');

  # This is a POST only because of the size of the request data.
  $authz->post('ir/adminlistdata')                                         ->to('ir#adminlistdata', action_id => 'ir_admin_listdata');
  $authz->get('ir/:pid/events')                                            ->to('ir#events', action_id => 'ir_admin_events');
  $authz->get('ir/allowsubmit')                                            ->to('ir#allowsubmit', action_id => 'ir_allowsubmit');
  $authz->get('ir/puresearch')                                             ->to('ir#puresearch', action_id => 'ir_admin_puresearch');
  $authz->get('ir/pureimport/locks')                                       ->to('ir#pureimport_getlocks', action_id => 'ir_admin_pureimport_locks');

  $authz->get('utils/fedora_storage_usage')                                ->to('utils#fedora_storage_usage', action_id => 'admin_storage_usage');
  $authz->get('utils/fedora_storage_avg_year')                             ->to('utils#fedora_storage_avg_year', action_id => 'admin_storage_avg_year');
  $authz->get('utils/imageserver_storage_avg_year')                        ->to('utils#imageserver_storage_avg_year', action_id => 'admin_imageserver_storage_avg_year');
  $authz->get('config/private')                                            ->to('config#get_private_config', action_id => 'admin_config_private_read');

  unless($self->app->config->{readonly}){

    $authz->post('utils/send_daily_report')                                ->to('utils#send_daily_report', action_id => 'admin_send_daily_report');

    $authz->post('config/public')                                          ->to('config#post_public_config', action_id => 'admin_config_public_write');
    $authz->post('config/private')                                         ->to('config#post_private_config', action_id => 'admin_config_private_write');

    $authz->post('oai/blacklist')                                          ->to('oai#blacklist', action_id => 'admin_oai_blacklist');

    $authz->post('index')                                                  ->to('index#update', action_id => 'admin_index');
    $authz->post('object/:pid/index')                                      ->to('index#update', action_id => 'admin_object_index');

    $authz->post('imageserver/process')                                    ->to('imageserver#process_pids', action_id => 'admin_imageserver_process');
    $authz->post('tikaserver/process')                                     ->to('tikaserver#process_pids', action_id => 'admin_tikaserver_process');
    $authz->post('imageserver/:pid/process')                               ->to('imageserver#process', action_id => 'write');
    $authz->post('tikaserver/:pid/process')                                ->to('tikaserver#process', action_id => 'write');
    $authz->post('streaming/process')                                      ->to('streaming#process_pids', action_id => 'admin_streaming_process');
    $authz->post('streaming/:pid/process')                                 ->to('streaming#process', action_id => 'admin_streaming_process');

    $authz->post('object/:pid/updateiiifmanifest')                         ->to('iiifmanifest#update_manifest_metadata', action_id => 'write');
    $authz->post('object/:pid/approve')                                    ->to('object#approve', action_id => 'approve');
    $authz->post('object/:pid/modify')                                     ->to('object#modify', action_id => 'write');
    $authz->post('object/:pid/delete')                                     ->to('object#delete', action_id => 'delete');
    $authz->post('object/:pid/uwmetadata')                                 ->to('uwmetadata#post', action_id => 'write');
    $authz->post('object/:pid/mods')                                       ->to('mods#post', action_id => 'write');
    $authz->post('object/:pid/jsonld')                                     ->to('jsonld#post', action_id => 'write');
    $authz->post('object/:pid/jsonldprivate')                              ->to('jsonldprivate#post', dsid => 'JSON-LD-PRIVATE', action_id => 'write');
    $authz->post('object/:pid/geo')                                        ->to('geo#post', action_id => 'write');
    $authz->post('object/:pid/annotations')                                ->to('annotations#post', action_id => 'write');
    $authz->post('object/:pid/rights')                                     ->to('rights#post', dsid => 'RIGHTS', action_id => 'restrict');
    $authz->post('object/:pid/iiifmanifest')                               ->to('iiifmanifest#post', action_id => 'write');
    $authz->post('object/:pid/metadata')                                   ->to('object#metadata', action_id => 'write');
    $authz->post('object/:pid/relationship/add')                           ->to('object#add_relationship', action_id => 'write');
    $authz->post('object/:pid/relationships/add')                          ->to('object#add_relationships', action_id => 'write');
    $authz->post('object/:pid/relationship/remove')                        ->to('object#purge_relationship', action_id => 'write');
    $authz->post('object/:pid/id/add')                                     ->to('object#add_identifier', action_id => 'write');
    $authz->post('object/:pid/id/remove')                                  ->to('object#remove_identifier', action_id => 'write');
    $authz->post('object/:pid/datastream/:dsid')                           ->to('object#add_or_modify_datastream', action_id => 'write');
    $authz->post('object/:pid/data')                                       ->to('object#add_octets', action_id => 'write');

    $authz->post('objects/:currentowner/modify')                           ->to('object#modify_bulk', action_id => 'admin_objects_modify_bulk');
    $authz->post('objects/:currentowner/delete')                           ->to('object#delete_bulk', action_id => 'admin_objects_delete_bulk');

    $authz->post('picture/create')                                         ->to('object#create_simple', cmodel => 'cmodel:Picture', action_id => 'create');
    $authz->post('document/create')                                        ->to('object#create_simple', cmodel => 'cmodel:PDFDocument', action_id => 'create');
    $authz->post('video/create')                                           ->to('object#create_simple', cmodel => 'cmodel:Video', action_id => 'create');
    $authz->post('audio/create')                                           ->to('object#create_simple', cmodel => 'cmodel:Audio', action_id => 'create');
    $authz->post('unknown/create')                                         ->to('object#create_simple', cmodel => 'cmodel:Asset', action_id => 'create');
    $authz->post('resource/create')                                        ->to('object#create_simple', cmodel => 'cmodel:Resource', action_id => 'create');
    $authz->post('page/create')                                            ->to('object#create_simple', cmodel => 'cmodel:Page', action_id => 'create');
    $authz->post('object/create')                                          ->to('object#create_empty', action_id => 'create');
    $authz->post('object/create/:cmodel')                                  ->to('object#create', action_id => 'create');
    $authz->post('container/create')                                       ->to('object#create_container', action_id => 'create');
    $authz->post('collection/create')                                      ->to('collection#create', action_id => 'create');

    $authz->post('container/:pid/members/order')                           ->to('membersorder#post', action_id => 'write');
    $authz->post('container/:pid/members/:itempid/order/:position')        ->to('membersorder#order_object_member', action_id => 'write');

    $authz->post('collection/:pid/members/remove')                         ->to('collection#remove_collection_members', action_id => 'write');
    $authz->post('collection/:pid/members/add')                            ->to('collection#add_collection_members', action_id => 'write');
    $authz->post('collection/:pid/members/order')                          ->to('membersorder#post', action_id => 'write');
    $authz->post('collection/:pid/members/:itempid/order/:position')       ->to('membersorder#order_object_member', action_id => 'write');

    $authz->post('group/add')                                              ->to('groups#add_group', action_id => 'group_write');
    $authz->post('group/:gid/remove')                                      ->to('groups#remove_group', action_id => 'group_write');
    $authz->post('group/:gid/members/add')                                 ->to('groups#add_members', action_id => 'group_write');
    $authz->post('group/:gid/members/remove')                              ->to('groups#remove_members', action_id => 'group_write');

    $authz->post('list/add')                                               ->to('lists#add_list', action_id => 'list_write');
    $authz->post('list/:lid/token/create')                                 ->to('lists#token_create', action_id => 'list_write');
    $authz->post('list/:lid/token/delete')                                 ->to('lists#token_delete', action_id => 'list_write');
    $authz->post('list/:lid/remove')                                       ->to('lists#remove_list', action_id => 'list_write');
    $authz->post('list/:lid/members/add')                                  ->to('lists#add_members', action_id => 'list_write');
    $authz->post('list/:lid/members/remove')                               ->to('lists#remove_members', action_id => 'list_write');

    $authz->post('inactive-objects/:pid/register')                         ->to('inactive_objects#register', action_id => 'inactive_objects_manage');
    $authz->post('inactive-objects/:pid/status')                           ->to('inactive_objects#set_status', action_id => 'inactive_objects_manage');
    $authz->post('inactive-objects/:pid/activate')                         ->to('inactive_objects#activate', action_id => 'inactive_objects_manage');
    $authz->post('inactive-objects/:pid/remove')                           ->to('inactive_objects#remove', action_id => 'inactive_objects_manage');
    $authz->post('inactive-objects/:pid/delete')                           ->to('inactive_objects#delete', action_id => 'inactive_objects_manage');

    $authz->post('jsonld/template/add')                                    ->to('jsonld#add_template', action_id => 'template_write');
    $authz->post('jsonld/template/:tid/remove')                            ->to('jsonld#remove_template', action_id => 'template_write');
    $authz->post('jsonld/template/:tid/edit')                              ->to('jsonld#edit_template', action_id => 'template_write');
    
    $authz->get('jsonld/templates/admin')                                  ->to('jsonld#get_templates_admin', action_id => 'admin_templates_read');
    $authz->post('jsonld/template/admin/:tid/remove')                      ->to('jsonld#remove_template_admin', action_id => 'admin_templates_write');
    $authz->post('jsonld/template/admin/:tid/edit')                        ->to('jsonld#edit_template_admin', action_id => 'admin_templates_write');

    $authz->post('ir/submit')                                              ->to('ir#submit', action_id => 'ir_submit');
    $authz->post('ir/notifications')                                       ->to('ir#notifications', action_id => 'ir_notifications');
    $authz->post('ir/:pid/accept')                                         ->to('ir#accept', action_id => 'ir_admin_accept');
    $authz->post('ir/:pid/reject')                                         ->to('ir#reject', action_id => 'ir_admin_reject');
    $authz->post('ir/:pid/approve')                                        ->to('ir#approve', action_id => 'ir_admin_approve');
    $authz->post('ir/pureimport/lock/:pureid/:lockname')                   ->to('ir#pureimport_lock', action_id => 'ir_admin_pureimport_lock');
    $authz->post('ir/pureimport/unlock/:pureid/:lockname')                 ->to('ir#pureimport_unlock', action_id => 'ir_admin_pureimport_unlock');
    $authz->post('ir/pureimport/reject/:uuid')                             ->to('ir#pureimport_reject', action_id => 'ir_admin_pureimport_reject');
    $authz->post('ir/embargocheck')                                        ->to('ir#embargocheck', action_id => 'admin_ir_embargocheck');

    $authz->post('feedback')                                               ->to('feedback#feedback', action_id => 'feedback');

    $authz->post('termsofuse/agree/:version')                              ->to('termsofuse#agree', action_id => 'termsofuse_agree');

    $authz->post('settings')                                               ->to('settings#post_settings', action_id => 'settings_write');

    $authz->post('utils/:pid/requestdoi')                                  ->to('utils#request_doi', action_id => 'request_doi');
  }
  #>>>
  $self->app->log->error(__LINE__);
  return $self;
}

1;
