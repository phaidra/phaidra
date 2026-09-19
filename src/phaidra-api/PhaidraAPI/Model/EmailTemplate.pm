package PhaidraAPI::Model::EmailTemplate;

use strict;
use warnings;
use v5.10;
use Mojo::File qw(path);
use Template;
use base qw/Mojo::Base/;

# Older admin config stored subject/html/text as separate flat keys.
my %LEGACY_FLAT = (
  passwordresetemail => {
    subject => 'passwordresetemailsubject',
    html    => 'passwordresetemailhtml',
    text    => 'passwordresetemailtext',
  },
  inactiveactivatedemail => {
    subject => 'inactiveactivatedemailsubject',
    html    => 'inactiveactivatedemailhtml',
    text    => 'inactiveactivatedemailtext',
  },
  doirequestemail => {
    subject => 'doirequestemailsubject',
    html    => 'doirequestemailhtml',
    text    => 'doirequestemailtext',
  },
  reportingemailtemplates => {
    subject => 'reportingemailsubject',
    html    => 'reportingemailhtml',
    text    => 'reportingemailtext',
  },
  feedbackemail => {
    subject => 'feedbackemailsubject',
    html    => 'feedbackemailhtml',
    text    => 'feedbackemailtext',
  },
);

sub normalize_lang {
  my ($self, $lang) = @_;
  return 'eng' unless defined $lang && length $lang;
  my $l = lc $lang;
  $l =~ s/_/-/g;
  $l = (split /-/, $l)[0];
  return 'eng' if $l eq 'en';
  return 'deu' if $l eq 'de';
  return 'ita' if $l eq 'it';
  return $l;
}

sub _file {
  my ($self, $c, $filename) = @_;
  return '' unless $filename;
  my $path = path($c->app->home, 'templates', 'email', $filename);
  return -f $path ? $path->slurp : '';
}

sub _legacy_entry {
  my ($self, $privconfig, $key) = @_;
  return unless $privconfig && ref $privconfig eq 'HASH';

  my $map     = $LEGACY_FLAT{$key} or return;
  my $subject = $privconfig->{$map->{subject}};
  my $html    = $privconfig->{$map->{html}};
  my $text    = $privconfig->{$map->{text}};
  return
       unless (defined $subject && length $subject)
    || (defined $html && length $html)
    || (defined $text && length $text);
  return {
    language => 'eng',
    subject  => defined $subject ? $subject : '',
    html     => defined $html    ? $html    : '',
    text     => defined $text    ? $text    : '',
  };
}

sub list_entries {
  my ($self, $privconfig, $key) = @_;
  return [] unless $privconfig && ref $privconfig eq 'HASH';

  my $val = $privconfig->{$key};
  if (ref $val eq 'ARRAY') {
    my @entries;
    for my $entry (@$val) {
      next unless ref $entry eq 'HASH';
      push @entries,
        {
        language => $self->normalize_lang($entry->{language} || 'eng'),
        subject  => defined $entry->{subject} ? $entry->{subject} : '',
        html     => defined $entry->{html}    ? $entry->{html}    : '',
        text     => defined $entry->{text}    ? $entry->{text}    : '',
        };
    }
    return \@entries if @entries;
  }
  elsif (defined $val && !ref($val) && length $val && ($key eq 'irmdcheckemail' || $key eq 'irembargoendemail')) {
    return [{language => 'eng', subject => '', html => $val, text => ''}];
  }

  my $legacy = $self->_legacy_entry($privconfig, $key);
  return $legacy ? [$legacy] : [];
}

sub resolve {
  my ($self, $c, $privconfig, $key, $lang, $defaults) = @_;
  $defaults ||= {};
  my $want    = $self->normalize_lang($lang);
  my $entries = $self->list_entries($privconfig, $key);
  my $picked;
  for my $entry (@$entries) {
    if ($entry->{language} eq $want) {
      $picked = $entry;
      last;
    }
  }
  $picked ||= $entries->[0] if @$entries;

  return {
    language => $picked                                ? $picked->{language} : $want,
    subject  => ($picked && length $picked->{subject}) ? $picked->{subject}  : $self->_file($c, $defaults->{subject}),
    html     => ($picked && length $picked->{html})    ? $picked->{html}     : $self->_file($c, $defaults->{html}),
    text     => ($picked && length $picked->{text})    ? $picked->{text}     : $self->_file($c, $defaults->{text}),
  };
}

sub render {
  my ($self, $template, $vars) = @_;
  return '' unless defined $template && length $template;
  my $tt     = Template->new;
  my $output = '';
  $tt->process(\$template, $vars || {}, \$output) or die $tt->error;
  return $output;
}

sub language_from_request {
  my ($self, $c) = @_;
  my $param = $c->param('lang') // $c->param('language');
  return $self->normalize_lang($param) if defined $param && length $param;

  my $header = $c->req->headers->accept_language;
  if ($header) {
    my ($first) = split /,/, $header;
    $first =~ s/;.*//;
    $first =~ s/^\s+|\s+$//g;
    return $self->normalize_lang($first) if length $first;
  }
  return 'eng';
}

1;
