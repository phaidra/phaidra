package PhaidraAPI::Model::Languages;

use strict;
use warnings;
use v5.10;
use base qw/Mojo::Base/;
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json decode_json);
use Mojo::File;

our %iso639map = (
  'xx' => 'xxx',
  'aa' => 'aar',
  'ab' => 'abk',
  'af' => 'afr',
  'ak' => 'aka',
  'am' => 'amh',
  'ar' => 'ara',
  'an' => 'arg',
  'as' => 'asm',
  'av' => 'ava',
  'ae' => 'ave',
  'ay' => 'aym',
  'az' => 'aze',
  'ba' => 'bak',
  'bm' => 'bam',
  'be' => 'bel',
  'bn' => 'ben',
  'bh' => 'bho',
  'bi' => 'bis',
  'bo' => 'bod',
  'bs' => 'bos',
  'br' => 'bre',
  'bg' => 'bul',
  'ca' => 'cat',
  'cs' => 'ces',
  'ch' => 'cha',
  'ce' => 'che',
  'cu' => 'chu',
  'cv' => 'chv',
  'kw' => 'cor',
  'co' => 'cos',
  'cr' => 'cre',
  'cy' => 'cym',
  'da' => 'dan',
  'de' => 'deu',
  'dv' => 'div',
  'dz' => 'dzo',
  'el' => 'ell',
  'en' => 'eng',
  'eo' => 'epo',
  'et' => 'est',
  'eu' => 'eus',
  'ee' => 'ewe',
  'fo' => 'fao',
  'fa' => 'fas',
  'fj' => 'fij',
  'fi' => 'fin',
  'fr' => 'fra',
  'fy' => 'fry',
  'ff' => 'ful',
  'gd' => 'gla',
  'ga' => 'gle',
  'gl' => 'glg',
  'gv' => 'glv',
  'gn' => 'grn',
  'gu' => 'guj',
  'ht' => 'hat',
  'ha' => 'hau',
  'sh' => 'hbs',
  'he' => 'heb',
  'hz' => 'her',
  'hi' => 'hin',
  'ho' => 'hmo',
  'hr' => 'hrv',
  'hu' => 'hun',
  'hy' => 'hye',
  'ig' => 'ibo',
  'io' => 'ido',
  'ii' => 'iii',
  'iu' => 'iku',
  'ie' => 'ile',
  'ia' => 'ina',
  'id' => 'ind',
  'ik' => 'ipk',
  'is' => 'isl',
  'it' => 'ita',
  'jv' => 'jav',
  'ja' => 'jpn',
  'kl' => 'kal',
  'kn' => 'kan',
  'ks' => 'kas',
  'ka' => 'kat',
  'kr' => 'kau',
  'kk' => 'kaz',
  'km' => 'khm',
  'ki' => 'kik',
  'rw' => 'kin',
  'ky' => 'kir',
  'kv' => 'kom',
  'kg' => 'kon',
  'ko' => 'kor',
  'kj' => 'kua',
  'ku' => 'kur',
  'lo' => 'lao',
  'la' => 'lat',
  'lv' => 'lav',
  'li' => 'lim',
  'ln' => 'lin',
  'lt' => 'lit',
  'lb' => 'ltz',
  'lu' => 'lub',
  'lg' => 'lug',
  'mh' => 'mah',
  'ml' => 'mal',
  'mr' => 'mar',
  'mk' => 'mkd',
  'mg' => 'mlg',
  'mt' => 'mlt',
  'mn' => 'mon',
  'mi' => 'mri',
  'ms' => 'msa',
  'my' => 'mya',
  'na' => 'nau',
  'nv' => 'nav',
  'nr' => 'nbl',
  'nd' => 'nde',
  'ng' => 'ndo',
  'ne' => 'nep',
  'nl' => 'nld',
  'nn' => 'nno',
  'nb' => 'nob',
  'no' => 'nor',
  'ny' => 'nya',
  'oc' => 'oci',
  'oj' => 'oji',
  'or' => 'ori',
  'om' => 'orm',
  'os' => 'oss',
  'pa' => 'pan',
  'pi' => 'pli',
  'pl' => 'pol',
  'pt' => 'por',
  'ps' => 'pus',
  'qu' => 'que',
  'rm' => 'roh',
  'ro' => 'ron',
  'rn' => 'run',
  'ru' => 'rus',
  'sg' => 'sag',
  'sa' => 'san',
  'si' => 'sin',
  'sk' => 'slk',
  'sl' => 'slv',
  'se' => 'sme',
  'sm' => 'smo',
  'sn' => 'sna',
  'sd' => 'snd',
  'so' => 'som',
  'st' => 'sot',
  'es' => 'spa',
  'sq' => 'sqi',
  'sc' => 'srd',
  'sr' => 'srp',
  'ss' => 'ssw',
  'su' => 'sun',
  'sw' => 'swa',
  'sv' => 'swe',
  'ty' => 'tah',
  'ta' => 'tam',
  'tt' => 'tat',
  'te' => 'tel',
  'tg' => 'tgk',
  'tl' => 'tgl',
  'th' => 'tha',
  'ti' => 'tir',
  'to' => 'ton',
  'tn' => 'tsn',
  'ts' => 'tso',
  'tk' => 'tuk',
  'tr' => 'tur',
  'tw' => 'twi',
  'ug' => 'uig',
  'uk' => 'ukr',
  'ur' => 'urd',
  'uz' => 'uzb',
  've' => 'ven',
  'vi' => 'vie',
  'vo' => 'vol',
  'wa' => 'wln',
  'wo' => 'wol',
  'xh' => 'xho',
  'yi' => 'yid',
  'yo' => 'yor',
  'za' => 'zha',
  'zh' => 'zho',
  'zu' => 'zul',
  'ji' => 'yid',
  'mo' => 'ron',
  'jw' => 'jav',
  'in' => 'ind',
  'iw' => 'heb',
  'zz' => 'grc'
);

sub get_iso639map {
  my ($self) = @_;
  return \%iso639map;
}

sub get_languages {

  my ($self, $c, $nocache) = @_;

  my $res = {alerts => [], status => 200};

  if ($nocache) {
    $c->app->log->debug("Reading languages_file (nocache request)");

    # read metadata tree from file
    my $path  = Mojo::File->new($c->app->config->{languages_file});
    my $bytes = $path->slurp;
    unless (defined($bytes)) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error reading languages_file, no content"};
      $res->{status} = 500;
      return $res;
    }
    my $lan = decode_json($bytes);

    $res->{languages} = $lan->{languages};

  }
  else {

    $c->app->log->debug("Reading languages from cache");

    my $cachekey = 'languages';
    my $cacheval = $c->app->chi->get($cachekey);

    my $miss = 1;

    #$c->app->log->debug($c->app->dumper($cacheval));
    if ($cacheval) {
      if ($cacheval->{languages}) {
        $miss = 0;

        #$c->app->log->debug("[cache hit] $cachekey");
      }
    }

    if ($miss) {
      $c->app->log->debug("[cache miss] $cachekey");

      # read metadata tree from file
      my $path  = Mojo::File->new($c->app->config->{languages_file});
      my $bytes = $path->slurp;
      unless (defined($bytes)) {
        push @{$res->{alerts}}, {type => 'error', msg => "Error reading languages_file, no content"};
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
    $res->{languages} = $cacheval->{languages};
  }

  return $res;
}

1;
__END__
