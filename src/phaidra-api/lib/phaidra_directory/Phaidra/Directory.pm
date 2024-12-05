package Phaidra::Directory;

use strict;
use warnings;
use v5.10;

sub new {
  my ($class, $mojo, $config) = @_;

  my $self = {};
  bless($self, $class);
  $self->_init($mojo, $config);
  return $self;
}

sub _init {
  my $self   = shift;
  my $mojo   = shift;
  my $config = shift;
  return $self;
}

sub update_info_data {
  my $self = shift;
  my $c    = shift;
  my $info = shift;

  return $info;
}

sub authenticate($$$$) {
  my $self = shift;
  my $app       = shift;
  my $username  = shift;
  my $password  = shift;
  my $extradata = shift;

  $app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub validate_user() {
  my $app       = shift;
  my $username  = shift;
  my $password  = shift;
  my $extradata = shift;

  my $ret = authenticate($app, $username, $password, $extradata);

  # Mojolicious::Plugin::Authenticate requires that error returns undef and success uid
  if ($ret->{status} eq 200) {
    $app->log->info("successfully authenticated $username");
    return $username;
  }
  else {
    $app->log->error("authentication failed, error code: " . $ret->{status} . "\n" . $app->dumper($ret->{alerts}));
    return undef;
  }
}

sub get_name {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub get_email {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# getFaculties
# getDepartments
sub get_org_units {
  my $self      = shift;
  my $c         = shift;
  my $parent_id = shift;    # undef if none
  my $lang      = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# getFacultyId
sub get_parent_org_unit_id {
  my $self     = shift;
  my $c        = shift;
  my $child_id = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# getFacultyName
# getDepartmentName
sub get_org_unit_name {
  my $self    = shift;
  my $c       = shift;
  my $unit_id = shift;
  my $lang    = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# getAuthorInstitutionName
# getAuthorInstitutionNameNoCtx
sub get_affiliation {
  my $self    = shift;
  my $c       = shift;
  my $unit_id = shift;
  my $lang    = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# getInstitutionName
sub get_org_name {
  my $self = shift;
  my $c    = shift;
  my $lang = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# uni specific
sub get_study_plans {
  my $self = shift;
  my $c    = shift;
  my $lang = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# uni specific
sub get_study {
  my $self  = shift;
  my $c     = shift;
  my $id    = shift;
  my $index = shift;
  my $lang  = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# uni specific
sub get_study_name {
  my $self  = shift;
  my $c     = shift;
  my $id    = shift;
  my $index = shift;
  my $lang  = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# getPersFunk
sub get_pers_funktions {
  my $self = shift;
  my $c    = shift;
  my $lang = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

# getPersFunkName
sub get_pers_funktion_name {
  my $self = shift;
  my $c    = shift;
  my $id   = shift;
  my $lang = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub get_user_data {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  # $fname,$lname,\@inums,\@fakcodes;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub is_superuser {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub is_superuser_for_user {
  my $self     = shift;
  my $c        = shift;
  my $username = shift;

  # \@users
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub search_user {
  my $self  = shift;
  my $c     = shift;
  my $query = shift;

  # $person = { uid => $uid, name => $name };
  #return \@persons,$hits;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub get_users_groups {
  my ($self, $c, $username) = @_;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub get_group {
  my ($self, $c, $gid) = @_;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub create_group {
  my ($self, $c, $groupname, $username) = @_;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub delete_group {
  my ($self, $c, $gid) = @_;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub add_group_member {
  my ($self, $c, $gid, $uid) = @_;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub remove_group_member {
  my ($self, $c, $gid, $uid) = @_;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub get_member_groups {
  my ($self, $c, $gid, $uid) = @_;
  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub _get_org_units {
  my ($self, $c) = @_;

  $c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub org_get_subunits_for_notation {
 my ($self, $c, $notation) = @_;
$c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub org_get_parentpath {
   my ($self, $c, $id)= @_;
$c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}

sub org_get_unit_for_notation {
  my ($self, $c, $id) = @_;
$c->app->log->error("Directory.pm - " . ((caller(0))[3]) . " - this method is not implemented");
}


1;
__END__
