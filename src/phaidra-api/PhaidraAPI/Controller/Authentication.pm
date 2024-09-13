package PhaidraAPI::Controller::Authentication;

use strict;
use warnings;
use v5.10;
use Mojo::ByteStream qw(b);
use Scalar::Util qw(looks_like_number);
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Object;
use PhaidraAPI::Model::Termsofuse;

sub extract_credentials {
  my $self = shift;

  my $username;
  my $password;
  my $upstream_auth_success = 0;
  if ($self->app->config->{authentication}->{upstream}->{enabled}) {

    $self->app->log->debug("Trying to extract upstream authentication");

    my $remoteuser = $self->req->headers->header($self->app->config->{authentication}->{upstream}->{principalheader});

    # remote user in header - basic auth must contain correct upstreamusername/upstreampassword as per config
    if ($remoteuser) {
      $self->app->log->debug("remote user: " . $remoteuser);

      my $upstreamusername;
      my $upstreampassword;
      ($upstreamusername, $upstreampassword) = $self->extract_basic_auth_credentials();

      my $configupstreamusername = $self->app->config->{authentication}->{upstream}->{upstreamusername};
      my $configupstreampassword = $self->app->config->{authentication}->{upstream}->{upstreampassword};

      if ( defined($upstreamusername)
        && defined($upstreampassword)
        && defined($configupstreamusername)
        && defined($configupstreampassword)
        && ($upstreamusername eq $configupstreamusername)
        && ($upstreampassword eq $configupstreampassword))
      {
        $self->app->log->debug("upstream credentials OK");
        $self->stash->{basic_auth_credentials} = {username => $self->app->config->{authentication}->{upstream}->{upstreamusername}, password => $self->app->config->{authentication}->{upstream}->{upstreampassword}};
        $self->stash->{remote_user}            = $remoteuser;
        my $remoteaffiliation = $self->req->headers->header($self->app->config->{authentication}->{upstream}->{affiliationheader});
        if ($remoteaffiliation) {
          $self->stash->{remote_affiliation} = $remoteaffiliation;
          $self->app->log->debug("remote affiliation: " . $remoteaffiliation);
        }
        my $remotegroups = $self->req->headers->header($self->app->config->{authentication}->{upstream}->{groupsheader});
        if ($remotegroups) {
          $self->stash->{remote_groups} = $remotegroups;
          $self->app->log->debug("remote groups: " . $remotegroups);
        }
        $upstream_auth_success = 1;
      }
      else {
        # the request contains the principal header with a remote user definition but it has wrong upstream auth credentials
        $self->render(json => {status => 500, alerts => [{type => 'error', msg => 'upstream authentication failed'}]}, status => 500);
        return 0;
      }

    }
    else {

      # this is ok, even if upstream auth is enabled, someone can send a non-upstream-auth request
      $self->app->log->debug("no upstream authentication: missing principal header");
    }

  }

  unless ($upstream_auth_success) {

    # try to find basic authentication
    $self->app->log->debug("Trying to extract basic authentication");
    ($username, $password) = $self->extract_basic_auth_credentials();
    if (defined($username) && defined($password)) {
      $self->app->log->info("User $username, basic authentication provided");
      $self->stash->{basic_auth_credentials} = {username => $username, password => $password};
      return 1;
    }

    # try to find token session
    $self->app->log->debug("Trying to extract token authentication");
    my $cred = $self->load_cred;
    $username = $cred->{username};
    $password = $cred->{password};
    my $remote_user = $cred->{remote_user};
    if (defined($username) && defined($password)) {
      $self->app->log->info("User $username, token authentication provided");
      $self->stash->{basic_auth_credentials} = {username => $username, password => $password};
      return 1;
    }
    else {
      # remote user in token - this is the case for shib
      if (defined($remote_user)) {
        $self->app->log->info("Remote user $remote_user, token authentication provided");
        $self->stash->{remote_user} = $remote_user;
        if ($self->app->config->{fedora}->{version} >= 6) {

          # TODO fix code to use BA creds OR remote_user if available (controllers currently pass BA username as username... -> becomes owner on create)
          $self->stash->{basic_auth_credentials} = {username => $remote_user};
        }
        else {
          # in fedora 3 we need to use it's upstream authentication feature
          $self->stash->{basic_auth_credentials} = {username => $self->app->config->{authentication}->{upstream}->{upstreamusername}, password => $self->app->config->{authentication}->{upstream}->{upstreampassword}};
        }
        return 1;
      }
    }

    if ($self->stash('creds_must_be_present')) {
      unless ((defined($username) && defined($password)) || defined($remote_user)) {
        my $t = $self->tx->req->headers->header($self->app->config->{authentication}->{token_header});
        my $errmsg;
        if ($t) {
          $errmsg = 'session invalid or expired';
        }
        else {
          $errmsg = 'no credentials found';
        }
        $self->app->log->error($errmsg);

        # If I use the realm the browser does not want to show the prompt!
        # $self->res->headers->www_authenticate('Basic "'.$self->app->config->{authentication}->{realm}.'"');
        $self->res->headers->www_authenticate('Basic');
        $self->render(json => {status => 401, alerts => [{type => 'error', msg => $errmsg}]}, status => 401);
        return 0;
      }
    }
    else {
      return 1;
    }
  }

}

sub extract_basic_auth_credentials {

  my $self = shift;

  my $auth_header = $self->req->headers->authorization;

  return unless ($auth_header);

  my ($method, $str) = split(/ /, $auth_header);

  return split(/:/, b($str)->b64_decode);
}

sub keepalive {
  my $self    = shift;
  my $session = $self->stash('mojox-session');
  $session->load;
  if ($session->sid) {
    $self->render(json => {expires => $session->expires, sid => $session->sid, status => 200}, status => 200);
  }
  else {
    $self->res->headers->www_authenticate('Basic');
    $self->render(json => {status => 401, alerts => [{type => 'error', msg => 'session invalid or expired'}]}, status => 401);
  }
}

sub cors_preflight {
  my $self = shift;

  # headers are set in after_dispatch,
  # because these are needed for the actual request as well
  # not just for preflight
  $self->render(text => '', status => 200);
}

sub authenticate {

  my $self = shift;

  if ($self->stash->{remote_user}) {
    $self->app->log->info("Remote user " . $self->stash->{remote_user});
    return 1;
  }

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  $self->app->log->info("Authenticating user $username");

  $self->directory->authenticate($self, $username, $password);
  my $res = $self->stash('phaidra_auth_result');
  unless (($res->{status} eq 200)) {
    $self->app->log->info("User $username not authenticated");
    $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});
    return 0;
  }
  $self->app->log->info("User $username successfully authenticated");
  return 1;
}

sub authenticate_admin {

  my $self = shift;

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  unless (($username eq $self->app->config->{phaidra}->{adminusername}) && ($password eq $self->app->config->{phaidra}->{adminpassword})) {
    $self->app->log->info("Not authenticated");
    $self->render(json => {status => 403, alerts => [{type => 'error', msg => "Not authenticated"}]}, status => 403);
    return 0;
  }
  $self->app->log->info("Admin successfully authenticated");
  return 1;
}

sub authenticate_ir_admin {

  my $self = shift;

  if ($self->stash->{remote_user}) {
    $self->app->log->info("Remote user " . $self->stash->{remote_user});
    return 1;
  }

  my $username = $self->stash->{basic_auth_credentials}->{username};
  my $password = $self->stash->{basic_auth_credentials}->{password};

  $self->app->log->info("Authenticating user $username");

  $self->directory->authenticate($self, $username, $password);
  my $res = $self->stash('phaidra_auth_result');
  unless (($res->{status} eq 200)) {
    $self->app->log->info("User $username not authenticated");
    $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});
    return 0;
  }
  unless ($username eq $self->config->{ir}->{iraccount}) {
    $self->app->log->info("Not IR admin");
    $self->render(json => {status => 403, alerts => [{type => 'error', msg => "Not IR admin"}]}, status => 403);
    return 0;
  }
  $self->app->log->info("User $username successfully authenticated");
  return 1;
}

sub signin {

  my $self = shift;

  # get credentials
  my $auth_header = $self->req->headers->authorization;
  unless ($auth_header) {
    $self->res->headers->www_authenticate('Basic "' . $self->app->config->{authentication}->{realm} . '"');
    $self->render(json => {status => 401, alerts => [{type => 'error', msg => 'please authenticate'}]}, status => 401);
    return;
  }
  my ($method,   $str)      = split(/ /, $auth_header);
  my ($username, $password) = split(/:/, b($str)->b64_decode);

  # authenticate, return 401 if authentication failed
  $self->directory->authenticate($self, $username, $password);
  my $res = $self->stash('phaidra_auth_result');
  unless (($res->{status} eq 200)) {
    $self->app->log->info("User $username not authenticated");
    $self->render(json => {status => $res->{status}, alerts => $res->{alerts}}, status => $res->{status});
    return;
  }
  $self->app->log->info("User $username successfully authenticated");

  # init session, save credentials
  $self->save_cred($username, $password);
  my $session = $self->stash('mojox-session');

  # send token cookie
  my $cookie = Mojo::Cookie::Response->new;
  $cookie->name($self->app->config->{authentication}->{token_cookie})->value($session->sid);
  $cookie->secure(1);
  $cookie->path('/');
  $cookie->httponly(1);
  $cookie->samesite('Strict');
  if ($self->app->config->{authentication}->{cookie_domain}) {
    $cookie->domain($self->app->config->{authentication}->{cookie_domain});
  }
  $self->tx->res->cookies($cookie);

  $self->render(json => {status => $res->{status}, alerts => [], $self->app->config->{authentication}->{token_cookie} => $session->sid}, status => $res->{status});
}

sub signout {
  my $self = shift;

  # destroy session
  my $session = $self->stash('mojox-session');
  $session->load;
  if ($session->sid) {
    $session->expire;
    $session->flush;
    my $cookie = Mojo::Cookie::Response->new;
    $cookie->name($self->app->config->{authentication}->{token_cookie})->value("");
    $cookie->secure(1);
    $cookie->path('/');
    $cookie->expires(-1);
    $cookie->samesite('Strict');
    if ($self->app->config->{authentication}->{cookie_domain}) {
      $cookie->domain($self->app->config->{authentication}->{cookie_domain});
    }
    $self->tx->res->cookies($cookie);
    $self->app->log->info("signout: unsetting cookie ".$self->app->dumper($cookie));
    $self->render(json => {status => 200, alerts => [{type => 'success', msg => 'You have been signed out'}], sid => $session->sid}, status => 200);
  }
  else {
    $self->render(json => {status => 200, alerts => [{type => 'info', msg => 'No session found'}]}, status => 200);
  }

}

sub signin_shib {
  my $self = shift;

  # $self->app->log->debug("XXXXXXXXXXXX shib XXXXXXXXXXX: " . $self->app->dumper(\%ENV));

  my $username = $ENV{$self->app->config->{authentication}->{shibboleth}->{attributes}->{username}};
  $username = $self->req->headers->header($self->app->config->{authentication}->{shibboleth}->{attributes}->{username}) unless $username;

  if (exists($self->app->config->{authentication}->{shibboleth}->{stripemaildomain})) {
    if ($self->app->config->{authentication}->{shibboleth}->{stripemaildomain}) {
      if ($username =~ m/(\w+)@*/g) {
        $username =~ s/@([\w|\.]+)//g;
      }
    }
  }

  $self->app->log->debug("[$username] shibboleth login");

  # $self->app->log->debug("[$username] headers:");
  # $self->app->log->debug($self->req->headers->to_string);

  my $firstname;
  my $lastname;
  my $email;
  my $affiliation;
  my $authorized;

  $firstname = $ENV{$self->app->config->{authentication}->{shibboleth}->{attributes}->{firstname}};
  $firstname = $self->req->headers->header($self->app->config->{authentication}->{shibboleth}->{attributes}->{firstname}) unless $firstname;
  $lastname  = $ENV{$self->app->config->{authentication}->{shibboleth}->{attributes}->{lastname}};
  $lastname  = $self->req->headers->header($self->app->config->{authentication}->{shibboleth}->{attributes}->{lastname}) unless $lastname;
  $email     = $ENV{$self->app->config->{authentication}->{shibboleth}->{attributes}->{email}};
  $email     = $self->req->headers->header($self->app->config->{authentication}->{shibboleth}->{attributes}->{email}) unless $email;

  if ($self->app->config->{authentication}->{shibboleth}->{attributes}->{affiliation}) {
    $affiliation = $ENV{$self->app->config->{authentication}->{shibboleth}->{attributes}->{affiliation}};
    $affiliation = $self->req->headers->header($self->app->config->{authentication}->{shibboleth}->{attributes}->{affiliation}) unless $affiliation;

    my @userAffs = split(';', $affiliation);
    for my $userAff (@userAffs) {
      last if $authorized;
      $self->app->log->debug("Checking if affiliation $userAff can login");
      my @valid_affiliations = map {split(/,/)} @{$self->app->config->{authentication}->{shibboleth}->{requiredaffiliations}};

      # $self->app->log->debug(Dumper(@valid_affiliations));
      for my $configAff (@valid_affiliations) {
        $self->app->log->debug("$configAff");
        if ($configAff eq $userAff) {
          $self->app->log->debug($configAff . " can login");
          $authorized = 1;
          last;
        }
      }
    }
  }

  $self->app->log->debug("[$username] attributes: firstname[$firstname] lastname[$lastname] email[$email] affiliation[$affiliation]");

  if ($username && $authorized) {

    my $version = $self->param('consentversion');
    if ($version) {
      $self->app->log->debug("consentversion[$version] provided");

      unless(looks_like_number($version)) {
        $self->render(json => {alerts => [{type => 'error', msg => 'Invalid version provided'}]}, status => 400);
        return;
      }

      my $termsofuse_model = PhaidraAPI::Model::Termsofuse->new;
      my $agreeres = $termsofuse_model->agree($self, $username, $version);
      # $self->app->log->debug("agree result: \n".$self->app->dumper($agreeres));
    }
    
    my $termsofuse_model = PhaidraAPI::Model::Termsofuse->new;
    my $termsres = $termsofuse_model->getagreed($self, $username);
    unless($termsres->{agreed}) {
      $self->app->log->debug("redirecting to " . $self->app->config->{authentication}->{shibboleth}->{frontendconsenturl});
      $self->redirect_to($self->app->config->{authentication}->{shibboleth}->{frontendconsenturl});
      return;
    }

    # init session, save credentials
    $self->app->log->debug("remote user authorized: username[$username]");
    $self->save_cred(undef, undef, $username, $firstname, $lastname, $email, $affiliation);
    my $session = $self->stash('mojox-session');

    # send token cookie
    my $cookie = Mojo::Cookie::Response->new;
    $cookie->name($self->app->config->{authentication}->{token_cookie})->value($session->sid);
    $cookie->secure(1);
    $cookie->samesite('Strict');
    $cookie->path('/');
    if ($self->app->config->{authentication}->{cookie_domain}) {
      $cookie->domain($self->app->config->{authentication}->{cookie_domain});
    }
    else {
      $cookie->domain($self->app->config->{phaidra}->{baseurl});
    }
    $self->tx->res->cookies($cookie);

  }

  $self->app->log->debug("redirecting to " . $self->app->config->{authentication}->{shibboleth}->{frontendloginurl});
  $self->redirect_to($self->app->config->{authentication}->{shibboleth}->{frontendloginurl});

}

1;
