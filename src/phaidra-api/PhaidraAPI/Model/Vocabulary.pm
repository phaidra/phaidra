package PhaidraAPI::Model::Vocabulary;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::File;

sub get_vocabulary {
  my ($self, $c, $uri, $nocache) = @_;

  if ($uri eq 'oefos2012') {
    return $self->_get_oefos_vocabulary($c, $nocache);
  }

  if ($uri eq 'thema') {
    return $self->_get_thema_vocabulary($c, $nocache);
  }

  if ($uri eq 'bic') {
    return $self->_get_bic_vocabulary($c, $nocache);
  }

  my %vocab_router = (
    'http://id.loc.gov/vocabulary/iso639-2' => $c->app->config->{vocabulary_folder} . '/iso639-2.json',
    'roles' => $c->app->config->{vocabulary_folder} . '/roles.json'
  );

  my $url;
  if($vocab_router{$uri}) {
    return $self->_get_file_vocabulary($c, $vocab_router{$uri}, $nocache);
  } else {
    return $self->_get_server_vocabulary($c, $url, $nocache);
  }
  
}

sub _get_file_vocabulary {
  my ($self, $c, $file, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  if ($nocache) {
    $c->app->log->debug("Reading vocabulary file [$file] (nocache request)");

    # read metadata tree from file
    my $path  = Mojo::File->new($file);
    my $bytes = $path->slurp;
    unless (defined($bytes)) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error reading vocabulary file [$file], no content"};
      $res->{status} = 500;
      return $res;
    }
    my $json = decode_json($bytes);

    $res->{vocabulary} = $json;

  }
  else {

    $c->app->log->debug("Reading vocabulary file [$file] (cache request)");

    my $cachekey = $file;
    my $cacheval = $c->app->chi->get($cachekey);

    my $miss = 1;
    if ($cacheval) {
      $miss = 0;

      #$c->app->log->debug("[cache hit] $cachekey");
    }

    if ($miss) {
      $c->app->log->debug("[cache miss] $cachekey");

      # read metadata tree from file
      my $path  = Mojo::File->new($file);
      my $bytes = $path->slurp;
      unless (defined($bytes)) {
        push @{$res->{alerts}}, {type => 'error', msg => "Error reading vocabulary file [$file], no content"};
        $res->{status} = 500;
        return $res;
      }
      $cacheval = decode_json($bytes);

      $c->app->chi->set($cachekey, $cacheval, '1 day');

      # save and get the value. the serialization can change integers to strings so
      # if we want to get the same structure for cache miss and cache hit we have to run it through
      # the cache serialization process even if cache miss [when we already have the structure]
      # so instead of using the structure created we will get the one just saved from cache.
      $cacheval = $c->app->chi->get($cachekey);

      #$c->app->log->debug($c->app->dumper($cacheval));
    }
    $res->{vocabulary} = $cacheval;
  }

  return $res;
}

sub _get_server_vocabulary {

  # TODO! - sparql to provided url
}


sub _get_bic_vocabulary {
  my ($self, $c, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  if ($nocache) {
    $c->app->log->debug("Reading bic (nocache request)");

    my $json = $self->_get_bic_vocabulary_hash($c);

    $res->{vocabulary} = $json;

  }
  else {

    $c->app->log->debug("Reading bic (cache request)");

    my $cachekey = 'bic_vocab';
    my $cacheval = $c->app->chi->get($cachekey);

    my $miss = 1;
    if ($cacheval) {
      $miss = 0;

      #$c->app->log->debug("[cache hit] $cachekey");
    }

    if ($miss) {
      $c->app->log->debug("[cache miss] $cachekey");

      $cacheval = $self->_get_bic_vocabulary_hash($c);

      $c->app->chi->set($cachekey, $cacheval, '1 day');
      $cacheval = $c->app->chi->get($cachekey);

      #$c->app->log->debug($c->app->dumper($cacheval));
    }
    $res->{vocabulary} = $cacheval;
  }

  return $res;
}


sub _get_bic_vocabulary_hash {
  my ($self, $c) = @_;

  my $json;
  my $termsHash = {};

  my $csvEn = $c->app->config->{vocabulary_folder} . '/101201-BIC2.1-Subj-only.csv';
  open my $data_1, '<:encoding(UTF-8)', $csvEn or $c->app->log->error("Can't open '" . $csvEn . "' for reading: $!");
  <$data_1>; # ignore csv header to reduce log warnings
  while (my $line = <$data_1>) {
    chomp $line;
    my @fields = split ',', $line;
    for my $field (@fields) {
      $field =~ s/^"//;
      $field =~ s/"$//;
      $field =~ s/^\s+|\s+$//g;
    }

    my $code  = $fields[0];
    my $heading = $fields[1];
    my $level = length($code);

    # $c->app->log->debug("level[$level] code[$code] title[$heading]");

    if ($level == 1) {
      push @$json, $self->_get_eng_term($c, $termsHash, 'bic', $code, $heading);
    }
    if ($level == 2) {
      my $parent = substr($code, 0, 1);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'bic', $code, $heading);
    }
    if ($level == 3) {
      my $parent = substr($code, 0, 2);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'bic', $code, $heading);
    }
    if ($level == 4) {
      my $parent = substr($code, 0, 3);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'bic', $code, $heading);
    }
    if ($level == 5) {
      my $parent = substr($code, 0, 4);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'bic', $code, $heading);
    }
    if ($level == 6) {
      my $parent = substr($code, 0, 5);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'bic', $code, $heading);
    }
  }

  return $json;
}

sub _get_thema_vocabulary {
  my ($self, $c, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  my $fileVoc = $self->_get_file_vocabulary($c, $c->app->config->{vocabulary_folder} . '/20230707_Thema_v1.5_en.json', $nocache);
  my $themaEn = $fileVoc->{vocabulary};

  my $json;
  my $termsHash = {};

  # CodeValue: "A",
  # CodeDescription: "The Arts",
  # CodeNotes: "Use all A* codes for: specialist and general adult titles, including both highly illustrated and more text-based works. For a hobby or recreational approach, prefer a WF* code as the main subject and supplement with A* code(s) where appropriate. Use all A* codes with: other subject categories and qualifiers as appropriate, in particular STYLE 6*, plus PLACE 1* and TIME PERIOD 3* Qualifiers",
  # CodeParent: "",
  # IssueNumber: 1,
  # Modified: 1.4
  for my $codeNode (@{$themaEn->{CodeList}->{ThemaCodes}->{Code}}) {
    #$c->app->log->debug("code[".$codeNode->{CodeValue}."] title[".$codeNode->{CodeDescription}."]");
    if ($codeNode->{CodeParent} eq "") {
      push @$json, $self->_get_eng_term($c, $termsHash, 'thema', $codeNode->{CodeValue}, $codeNode->{CodeDescription}, $codeNode->{CodeNotes});
    } else {
      push @{$termsHash->{$codeNode->{CodeParent}}->{children}}, $self->_get_eng_term($c, $termsHash, 'thema', $codeNode->{CodeValue}, $codeNode->{CodeDescription}, $codeNode->{CodeNotes});
    }
  }

  $fileVoc = $self->_get_file_vocabulary($c, $c->app->config->{vocabulary_folder} . '/20231031_Thema_v1.5_de.json', $nocache);
  my $themaDe = $fileVoc->{vocabulary};
  for my $codeNode (@{$themaDe->{CodeList}->{ThemaCodes}->{Code}}) {
    # $c->app->log->debug("code[".$codeNode->{CodeValue}."] title[".$codeNode->{CodeDescription}."]");
    $termsHash->{$codeNode->{CodeValue}}->{'skos:prefLabel'}->{'deu'} = $codeNode->{CodeDescription};
    $termsHash->{$codeNode->{CodeValue}}->{'skos:definition'}->{'deu'} = $codeNode->{CodeNotes};
  }

  $res->{vocabulary} = $json;
  return $res;
}

sub _get_oefos_vocabulary {
  my ($self, $c, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  if ($nocache) {
    $c->app->log->debug("Reading oefos (nocache request)");

    my $json = $self->_get_oefos_vocabulary_hash($c);

    $res->{vocabulary} = $json;

  }
  else {

    $c->app->log->debug("Reading oefos (cache request)");

    my $cachekey = 'oefos2012';
    my $cacheval = $c->app->chi->get($cachekey);

    my $miss = 1;
    if ($cacheval) {
      $miss = 0;

      #$c->app->log->debug("[cache hit] $cachekey");
    }

    if ($miss) {
      $c->app->log->debug("[cache miss] $cachekey");

      $cacheval = $self->_get_oefos_vocabulary_hash($c);

      $c->app->chi->set($cachekey, $cacheval, '1 day');
      $cacheval = $c->app->chi->get($cachekey);

      #$c->app->log->debug($c->app->dumper($cacheval));
    }
    $res->{vocabulary} = $cacheval;
  }

  return $res;
}

sub _get_oefos_vocabulary_hash {
  my ($self, $c) = @_;

  my $json;
  my $termsHash = {};

  my $csvEn = $c->app->config->{vocabulary_folder} . '/OEFOS2012_EN_CTI_utf8.csv';
  open my $data_1, '<:encoding(UTF-8)', $csvEn or $c->app->log->error("Can't open '" . $csvEn . "' for reading: $!");
  <$data_1>; # ignore csv header to reduce log warnings
  while (my $line = <$data_1>) {
    chomp $line;
    my @fields = split ';', $line;
    for my $field (@fields) {
      $field =~ s/^"//;
      $field =~ s/"$//;
      $field =~ s/^\s+|\s+$//g;
    }

    my $level = $fields[0];
    my $code  = $fields[2];
    my $title = $fields[3];

    #$c->app->log->debug("level[$level] code[$code] title[$title]");

    if ($level == 1) {
      push @$json, $self->_get_eng_term($c, $termsHash, 'oefos2012', $code, $title);
    }
    if ($level == 2) {
      my $parent = substr($code, 0, 1);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'oefos2012', $code, $title);
    }
    if ($level == 3) {
      my $parent = substr($code, 0, 3);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'oefos2012', $code, $title);
    }
    if ($level == 4) {
      my $parent = substr($code, 0, 4);
      push @{$termsHash->{$parent}->{children}}, $self->_get_eng_term($c, $termsHash, 'oefos2012', $code, $title);
    }
  }

  my $csvDe = $c->app->config->{vocabulary_folder} . '/OEFOS2012_DE_CTI_utf8.csv';
  open my $data_2, '<:encoding(UTF-8)', $csvDe or $c->app->log->error("Can't open '" . $csvDe . "' for reading: $!");
  <$data_2>; # ignore csv header to reduce log warnings
  while (my $line = <$data_2>) {
    chomp $line;
    my @fields = split ';', $line;
    for my $field (@fields) {
      $field =~ s/^"//;
      $field =~ s/"$//;
      $field =~ s/^\s+|\s+$//g;
    }

    my $level = $fields[0];
    my $code  = $fields[2];
    my $title = $fields[3];

    $termsHash->{$code}->{'skos:prefLabel'}->{'deu'} = $title;
  }

  return $json;
}

sub _get_eng_term {
  my ($self, $c, $termsHash, $ns, $code, $title, $def) = @_;
  my $n = {
    '@id'            => "$ns:$code",
    'skos:notation'  => [],
    'skos:prefLabel' => {'eng' => $title},
    'children'       => []
  };
  push @{$n->{'skos:notation'}}, $code;
  $n->{'skos:definition'} = { 'eng' => $def } if $def;
  $termsHash->{$code} = $n;
  return $n;
}

1;
__END__
