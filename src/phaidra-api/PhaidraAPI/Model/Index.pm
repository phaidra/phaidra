package PhaidraAPI::Model::Index;

use strict;
use warnings;
use v5.10;
use utf8;
use Switch;
use Time::HiRes qw/tv_interval gettimeofday/;
use Mojo::ByteStream qw(b);
use Mojo::Util qw(encode decode trim);
use Mojo::JSON qw(encode_json decode_json from_json to_json);
use Mojo::URL;
use Mojo::UserAgent;
use base qw/Mojo::Base/;
use XML::LibXML;
use Storable qw(dclone);
use PhaidraAPI::Model::Uwmetadata;
use PhaidraAPI::Model::Mods;
use PhaidraAPI::Model::Search;
use PhaidraAPI::Model::Dc;
use PhaidraAPI::Model::Annotations;
use PhaidraAPI::Model::Membersorder;
use PhaidraAPI::Model::Octets;
use PhaidraAPI::Model::Fedora;
use Scalar::Util qw(reftype looks_like_number);

my %modifiedDateOverwriteDatastreams = (
  'OCTETS' => 1,
  'JSON-LD' => 1,
  'UWMETADATA' => 1,
  'MODS' => 1,
  'RIGHTS' => 1,
  'IIIF-MANIFEST' => 1
);

our %indexed_datastreams_xml = (
  "UWMETADATA"      => 1,
  "MODS"            => 1,
  "ANNOTATIONS"     => 1,
  "GEO"             => 1,
  "RELS-EXT"        => 1,
  "COLLECTIONORDER" => 1,
  "RIGHTS"          => 1,
  "BOOKINFO"        => 1
);

our %indexed_datastreams = (
  "UWMETADATA"      => 1,
  "MODS"            => 1,
  "ANNOTATIONS"     => 1,
  "GEO"             => 1,
  "RELS-EXT"        => 1,
  "JSON-LD"         => 1,
  "COLLECTIONORDER" => 1,
  "RIGHTS"          => 1,
  "BOOKINFO"        => 1
);

our %cmodel_2_resourcetype = (
  "Asset"         => "other",
  "Audio"         => "sound",
  "Book"          => "book",
  "Collection"    => "collection",
  "Container"     => "dataset",
  "LaTeXDocument" => "text",
  "PDFDocument"   => "text",
  "Page"          => "bookpart",
  "Picture"       => "image",
  "Resource"      => "interactiveresource",
  "Video"         => "video"
);

our %uwm_metadataqualitycheck = (
  "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_40/1557089" => "nok",
  "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_40/1557088" => "ok",
  "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_40/1557087" => "todo"
);

our %educational_learningresourcetype = (
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1700" => "problem_statement",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1695" => "slide",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1692" => "figure",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1690" => "questionnaire",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1689" => "simulation",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1701" => "self_assessment",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1693" => "graph",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1699" => "experiment",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1698" => "exam",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1697" => "narrative_text",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1694" => "index",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1696" => "table",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1691" => "diagram",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1702" => "lecture",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1688" => "exercise"
);

our %educational_enduserrole = (
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1713" => "teacher",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1715" => "learner",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1716" => "manager"
);

our %educational_context = (
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1719" => "training",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1720" => "other",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1717" => "school",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1718" => "higher_education"
);

our %uwm_2_mods_roles = (

  # author digital
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/46" => "aut",

  # author analogue
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552095" => "aut",

  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561101" => "abr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557102" => "act",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557099" => "adp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561102" => "rcp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552167" => "advisor",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561103" => "anl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561104" => "anm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561105" => "ann",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561106" => "apl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561107" => "ape",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561108" => "app",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557100" => "arc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557101" => "arr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561109" => "acp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561110" => "adi",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/10867"   => "art",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557115" => "ard",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562799" => "assessor",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561111" => "asg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561112" => "asn",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557128" => "att",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561113" => "auc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561114" => "aqt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561115" => "aft",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561116" => "aud",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561117" => "aui",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561118" => "authorofsubtitles",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561119" => "ato",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561120" => "ant",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561121" => "bnd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561122" => "bdd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561123" => "blw",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561124" => "bkd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561125" => "bkp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561126" => "bjd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561127" => "bpd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561128" => "bsl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561129" => "brl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561130" => "brd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561131" => "cll",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557107" => "ctg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561133" => "cas",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561134" => "cns",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557112" => "chr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557117" => "cng",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561135" => "cli",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562800" => "coadvisor",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562798" => "coach",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561136" => "cor",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561137" => "col",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561138" => "clt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561139" => "clr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561140" => "cmm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561141" => "cwt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557108" => "com",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561142" => "cpl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561143" => "cpt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561144" => "cpe",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557109" => "cmp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561145" => "cmt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561146" => "ccp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557116" => "cnd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561147" => "con",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561148" => "csl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561149" => "csp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561150" => "cos",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561151" => "cot",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561152" => "coe",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561153" => "cts",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561154" => "ctt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561155" => "cte",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561156" => "ctr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561157" => "ctb",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562629" => "copista",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561158" => "cpc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561159" => "cph",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561160" => "crr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561161" => "crp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561162" => "cst",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561163" => "cou",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561164" => "crt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561165" => "cov",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561166" => "cur",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561167" => "dnc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561168" => "dtc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561169" => "dtm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/55"      => "datasupplier",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557114" => "dte",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557113" => "dto",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561170" => "dfd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561171" => "dft",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561172" => "dfe",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561173" => "dgg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561174" => "dgs",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561175" => "dln",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561176" => "dpc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561177" => "dpt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561178" => "dsr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552154" => "digitiser",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561179" => "drt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557143" => "dis",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561180" => "dbp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561181" => "dst",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/60"      => "domainexpert",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/10868"   => "dnr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561182" => "drm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562797" => "dramaticadvisor",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557104" => "dub",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/52"      => "edt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561183" => "edc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561184" => "edm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561185" => "elg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561186" => "elt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561187" => "enj",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557121" => "eng",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557120" => "egr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557098" => "etr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/51"      => "evaluator",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561189" => "exp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561190" => "fac",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561191" => "fld",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561192" => "fmd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561193" => "fds",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557137" => "flm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561194" => "fmp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561195" => "fmk",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561196" => "fpy",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561197" => "frg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557131" => "fmo",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562634" => "founder",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561198" => "fnd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561199" => "gis",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/53"      => "graphicdesigner",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561200" => "hnr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561201" => "hst",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561202" => "his",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557126" => "ilu",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557119" => "ill",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/49"      => "initiator",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561203" => "ins",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561204" => "itr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/61"      => "interpreter",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557122" => "ive",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557123" => "ivr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561205" => "inv",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561206" => "isb",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552168" => "jud",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561207" => "jug",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552155" => "keeperoftheoriginal",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561208" => "lbr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561209" => "ldr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561210" => "lsa",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561211" => "led",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561212" => "len",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561213" => "lil",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561214" => "lit",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561215" => "lie",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561216" => "lel",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561217" => "let",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561218" => "lee",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557125" => "lbt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561219" => "lse",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561220" => "lso",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561221" => "lgd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561222" => "ltg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557129" => "lyr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561223" => "mfp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561224" => "mfr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561225" => "mrb",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561226" => "mrk",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561227" => "med",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561228" => "mdc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557105" => "emt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561229" => "mtk",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561230" => "mod",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561231" => "mon",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561232" => "mcp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557118" => "msd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557127" => "mus",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561233" => "nrt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561234" => "osp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557111" => "opn",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561235" => "orm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561236" => "org",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/63"      => "oth",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557134" => "own",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561237" => "pan",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561238" => "ppm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561239" => "pta",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561240" => "pth",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561241" => "pat",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/59"      => "pedagogicexpert",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557130" => "prf",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561242" => "pma",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/10869"   => "pht",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561243" => "ptf",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561244" => "ptt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561245" => "pte",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561246" => "plt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561247" => "pra",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561248" => "pre",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557141" => "prt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561249" => "pop",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561250" => "prm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561251" => "prc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557132" => "pro",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561252" => "prn",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561253" => "prs",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561254" => "pmn",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561255" => "prd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561257" => "prg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561258" => "pdr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561259" => "pfr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561260" => "prv",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/47"      => "pbl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561262" => "pbd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561263" => "ppt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561264" => "rdd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561265" => "rpc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557142" => "rce",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561266" => "rcd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561267" => "red",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561268" => "ren",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561269" => "rpt",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561271" => "rth",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561272" => "rtm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561273" => "res",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561274" => "rsp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561275" => "rst",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561276" => "rse",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561277" => "rpy",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561278" => "rsg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561279" => "rsr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557135" => "rev",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561280" => "rbr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557139" => "sce",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557110" => "sad",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561282" => "aus",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561283" => "scr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557140" => "scl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561284" => "spy",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561285" => "sec",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561286" => "sll",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561287" => "std",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561288" => "stg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561289" => "sgn",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557106" => "sng",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557133" => "sds",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561290" => "spk",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561291" => "spn",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561292" => "sgd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561293" => "stm",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561294" => "stn",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561295" => "str",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561296" => "stl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561297" => "sht",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561298" => "srv",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561299" => "tch",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561300" => "tcd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/56"      => "technicalinspector",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/54"      => "technicaltranslator",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561301" => "tld",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561302" => "tlp",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/58"      => "textprocessor",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557136" => "ths",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561303" => "trc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562795" => "trl",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561304" => "tyd",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561305" => "tyg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557146" => "uploader",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557144" => "vdg",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561307" => "vac",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561308" => "wit",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557145" => "wde",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561309" => "wdc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557103" => "wam",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561310" => "wac",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561311" => "wal",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561312" => "wat",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561313" => "win",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561314" => "wpr",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1561315" => "wst",

  # duplicates in padova, to be removed from objects
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562631" => "edc",
  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562630" => "trc",

  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562796" => "mfr",    # remove this from objects, it's a duplicate

  "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557138" => "aus"     # remove this from objects, it's a duplicate

);

our %uwm_funder = (
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1556222" => "European Union (all programmes)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557091" => "Bundesministerium für Wissenschaft und Forschung (BMWF)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557093" => "European Science Foundation (ESF)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557094" => "Austrian Science Fund (FWF)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557095" => "Jubiläumsfonds der Österreichischen Nationalbank",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557096" => "Österreichische Forschungsförderungsgesellschaft mbH (FFG)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557097" => "Vienna Science and Technology Fund (WWTF)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562635" => "Österreichischer Austauschdienst (OeAD)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562636" => "Österreichische Akademie der Wissenschaften (ÖAW)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562637" => "Österreichischer Nationalfonds für Opfer des Nationalsozialismus",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562638" => "Zukunftsfonds der Republik Österreich",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562639" => "Österreichische Forschungsgemeinschaft (ÖFG)",
  "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562640" => "University of Vienna"
);

sub get_doc {
  my ($self, $c, $pid) = @_;
  return $self->get_doc_from_core($c, $pid, $c->app->config->{solr}->{core});
}

sub get_page_doc {
  my ($self, $c, $pid) = @_;
  return $self->get_doc_from_core($c, $pid, $c->app->config->{solr}->{core_pages});
}

sub get_doc_from_core {
  my ($self, $c, $pid, $core) = @_;

  my $res = {alerts => [], status => 200};
  my $doc;

  my $urlget = Mojo::URL->new;
  $urlget->scheme($c->app->config->{solr}->{scheme});
  $urlget->host($c->app->config->{solr}->{host});
  $urlget->port($c->app->config->{solr}->{port});
  if ($c->app->config->{solr}->{path}) {
    $urlget->path("/" . $c->app->config->{solr}->{path} . "/solr/" . $core . "/select");
  }
  else {
    $urlget->path("/solr/" . $core . "/select");
  }

  $urlget->query(q => "pid:\"$pid\"", rows => "1", wt => "json");

  my $ua = Mojo::UserAgent->new;

  my $getres = $ua->get($urlget)->result;

  if ($getres->is_success) {
    if ($getres->json->{response}->{numFound} eq 0) {
      my $err = "[$pid] object not found in index";
      $c->app->log->error($err);
      unshift @{$res->{alerts}}, {type => 'error', msg => $err};
      $res->{status} = 404;
      return $res;
    }
    for my $d (@{$getres->json->{response}->{docs}}) {
      $doc = $d;
      last;
    }
  }
  else {
    my $err = "[$pid] error getting object info from solr host[" . $c->app->config->{solr}->{host} . "] core[$core]: " . $getres->code . " " . $getres->message;
    $c->app->log->error($err);
    unshift @{$res->{alerts}}, {type => 'error', msg => $err};
    $res->{status} = $getres->code ? $getres->code : 500;
    return $res;
  }

  $res->{doc} = $doc;
  return $res;
}

sub getSolrUpdateUrl {
  no warnings 'uninitialized';
  my ($self, $c, $cmodel, $core) = @_;

  unless ($core) {
    $core = $c->app->config->{solr}->{core};
  }
  if (exists($c->app->config->{solr}->{core_pages}) and $c->app->config->{solr}->{core_pages} ne '' and $cmodel eq 'Page') {
    $core = $c->app->config->{solr}->{core_pages};
  }

  my $updateurl = Mojo::URL->new;
  $updateurl->scheme($c->app->config->{solr}->{scheme});
  $updateurl->userinfo($c->app->config->{solr}->{username} . ":" . $c->app->config->{solr}->{password});
  $updateurl->host($c->app->config->{solr}->{host});
  $updateurl->port($c->app->config->{solr}->{port});
  if ($c->app->config->{solr}->{path}) {
    $updateurl->path("/" . $c->app->config->{solr}->{path} . "/solr/$core/update");
  }
  else {
    $updateurl->path("/solr/$core/update");
  }
  $updateurl->query(commit => 'true');

  return $updateurl;
}

sub updateDoc {
  my ($self, $c, $pid) = @_;

  my $dc_model     = PhaidraAPI::Model::Dc->new;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $object_model = PhaidraAPI::Model::Object->new;

  return $self->update($c, $pid, $dc_model, $search_model, $object_model);
}

sub update {
  my ($self, $c, $pid, $dc_model, $search_model, $object_model, $ignorestatus, $norecursion, $core) = @_;

  my $res = {status => 200};

  my $ua = Mojo::UserAgent->new;

  if (exists($c->app->config->{solr})) {

    my $tcm        = [gettimeofday];
    my $cmodel_res = $search_model->get_cmodel($c, $pid);
    $c->app->log->debug("getting cmodel[" . ($cmodel_res->{cmodel} ? $cmodel_res->{cmodel} : '') . "] took " . tv_interval($tcm). " status[".$cmodel_res->{status}."]");
    
    if (($cmodel_res->{status} eq 410) && ($c->app->config->{fedora}->{version} >= 6)) {
      # object was deleted
      $c->app->log->debug("[$pid] object returns 410 Gone - deleting from index");
      my $post = $ua->post($self->getSolrUpdateUrl($c) => json => {delete => $pid})->result;
      if ($post->is_success) {
        $c->app->log->debug("[$pid] solr document deleted");
      }
      else {
        unshift @{$res->{alerts}}, {type => 'error', msg => "[$pid] Error deleting document from solr: " . $post->message};
        $res->{status} = $post->code ? $post->code : 500;
      }
      $res->{status} = 200;
      return $res;
    }
    if ($cmodel_res->{status} ne 200) {
      return $cmodel_res;
    }

    my $updateurl = $self->getSolrUpdateUrl($c, $cmodel_res->{cmodel}, $core);

    if ($cmodel_res->{cmodel} eq '') {

      # triplestore works but returns nothing for this object -> it was probably deleted -> remove from index
      $c->app->log->debug("[$pid] no cmodel found, deleting from index");
      if (exists($c->app->config->{solr})) {
        my $post = $ua->post($updateurl => json => {delete => $pid});
        my $r    = $post->result;
        if ($r->is_success) {
          $c->app->log->debug("[$pid] solr document deleted (not found in triplestore)");
        }
        else {
          my ($err, $code) = $post->error;
          unshift @{$res->{alerts}}, {type => 'error', msg => "[$pid] Error deleting document from solr: " . $c->app->dumper($err)};
          $res->{status} = $code ? $code : 500;
        }
      }
      $res->{status} = 200;
      return $res;
    }

    if (
      $cmodel_res->{cmodel}
      && ($cmodel_res->{cmodel} ne 'Page'
        or (exists($c->app->config->{solr}->{core_pages}) and $c->app->config->{solr}->{core_pages} ne ''))
      )
    {

      my $t0 = [gettimeofday];
      my $r  = $self->_get($c, $pid, $dc_model, $search_model, $object_model, $ignorestatus);
      $c->app->log->debug("update indexing took " . tv_interval($t0));
      $res = $r;

      my $collectionMembers = $r->{index}->{haspart} if exists $r->{index}->{haspart};

      my $members = $r->{index}->{hasmember} if exists $r->{index}->{hasmember};

      my $membersorder = $r->{index}->{membersorder} if exists $r->{index}->{membersorder};

      # don't save this
      delete $r->{index}->{membersorder};

      my $getStatus = $r->{status};
      $c->app->log->debug("[$pid] index get status $getStatus");
      if ($getStatus eq 200) {

        if (exists($c->app->config->{solr})) {
          $t0 = [gettimeofday];
          my @docs = ($r->{index});
          my $post = $ua->post($updateurl => json => \@docs)->result;
          $c->app->log->debug("posting index took " . tv_interval($t0));

          # log solr response, on 8.1.1 if there's an error 200 is returned and commit is skipped
          # while the error is only sent back to client (not in solr log)
          $c->app->log->debug("[$pid] solr result code[" . $post->code . "] message [" . $post->message . "] json:\n" . $c->app->dumper($post->json));
          if ($post->is_success) {
            $c->app->log->debug("[$pid] solr document updated");
          }
          else {
            unshift @{$res->{alerts}}, {type => 'error', msg => "[$pid] Error updating solr code[" . $post->code . "] message [" . $post->message . "]"};
            $res->{status} = $post->code ? $post->code : 500;
          }

        }
      }
      elsif (($getStatus eq 301) || ($getStatus eq 302)) {

        # 301 - object is in state Deleted
        # 302 - object is in state Inactive
        if (exists($c->app->config->{solr})) {
          my $post = $ua->post($updateurl => json => {delete => $pid})->result;
          if ($post->is_success) {
            $c->app->log->debug("[$pid] solr document deleted getStatus[$getStatus]");
          }
          else {
            unshift @{$res->{alerts}}, {type => 'error', msg => "[$pid] Error deleting document from solr: " . $post->message};
            $res->{status} = $post->code ? $post->code : 500;
          }
        }

        # change back to 200, deleting an Inactive or Deleted object from index is ok
        $res->{status} = 200;
      }

      if ($cmodel_res->{cmodel} eq 'Collection') {

        # if this collection is Inactive or Deleted, set collectionMembers to 0
        # so that the ispartof is removed from members
        if (($getStatus eq 301) || ($getStatus eq 302)) {
          @{$collectionMembers} = ();
        }
        unless (defined($collectionMembers)) {
          @{$collectionMembers} = ();
        }
        my $umr = $self->_update_members($c, $pid, $cmodel_res->{cmodel}, $updateurl, $collectionMembers, 'ispartof');
        if ($umr->{status} ne 200) {
          $res->{status} = $umr->{status};
          push @{$res->{alerts}}, @{$umr->{alerts}} if scalar @{$umr->{alerts}} > 0;
        }
      }

      if ($cmodel_res->{cmodel} eq 'Container') {

        # if this container is Inactive or Deleted, set members to 0
        # so that the ismemberof is removed from members
        if (($getStatus eq 301) || ($getStatus eq 302)) {
          @{$collectionMembers} = ();
        }
        unless (defined($members)) {
          @{$members} = ();
        }
        my $umr = $self->_update_members($c, $pid, $cmodel_res->{cmodel}, $updateurl, $members, 'ismemberof');
        if ($umr->{status} ne 200) {
          $res->{status} = $umr->{status};
          push @{$res->{alerts}}, @{$umr->{alerts}} if scalar @{$umr->{alerts}} > 0;
        }

      }

      if (($cmodel_res->{cmodel} eq 'Collection') || ($cmodel_res->{cmodel} eq 'Container')) {

        # if this container or collection is Inactive or Deleted, set membersorder to 0
        # so that the pos_in_<pid> is removed from members
        if (($getStatus eq 301) || ($getStatus eq 302)) {
          @{$collectionMembers} = ();
        }
        unless (defined($membersorder)) {
          @{$membersorder} = ();
        }
        my $umr = $self->_update_membersorder($c, $pid, $cmodel_res->{cmodel}, $updateurl, $membersorder);
        if ($umr->{status} ne 200) {
          $res->{status} = $umr->{status};
          push @{$res->{alerts}}, @{$umr->{alerts}} if scalar @{$umr->{alerts}} > 0;
        }
      }

      unless ($norecursion) {
        if (exists($r->{index}->{ismemberof})) {
          if ((scalar @{$r->{index}->{ismemberof}}) > 0) {
            for my $cnt_pid (@{$r->{index}->{ismemberof}}) {
              $c->app->log->info("$pid is a member of $cnt_pid -> indexing $cnt_pid");
              if ($cnt_pid ne $pid) {
                $self->update($c, $cnt_pid, $dc_model, $search_model, $object_model, $ignorestatus, 1);
              }
            }
          }
        }
      }

    }
    else {
      my $msg = "[$pid] cmodel: " . $cmodel_res->{cmodel} . ", skipping update";
      $c->app->log->debug($msg);
      unshift @{$res->{alerts}}, {type => 'info', msg => $msg};
    }

  }

  return $res;
}

sub _get_solrget_url {
  my ($self, $c, $cmodel) = @_;

  my $urlget = Mojo::URL->new;
  $urlget->scheme($c->app->config->{solr}->{scheme});
  $urlget->host($c->app->config->{solr}->{host});
  $urlget->port($c->app->config->{solr}->{port});
  my $core = $c->app->config->{solr}->{core};
  if ($cmodel eq 'Page' and exists($c->app->config->{solr}->{core_pages}) and $c->app->config->{solr}->{core_pages} ne '') {
    $core = $c->app->config->{solr}->{core_pages};
  }
  if ($c->app->config->{solr}->{path}) {
    $urlget->path("/" . $c->app->config->{solr}->{path} . "/solr/$core/select");
  }
  else {
    $urlget->path("/solr/$core/select");
  }

  return $urlget;
}

sub _update_membersorder {
  my ($self, $c, $pid, $cmodel, $updateurl, $membersorder) = @_;

  my $pidunderscore = $pid;
  $pidunderscore =~ s/:/_/;
  my $field = 'pos_in_' . $pidunderscore;

  my $res = {status => 200};

  # get current order
  my $urlget = $self->_get_solrget_url($c, $cmodel);

  $urlget->query(q => "$field:*", fl => "pid,$field", rows => "0", wt => "json");

  my $ua = Mojo::UserAgent->new;

  my $get = $ua->get($urlget)->result;
  my $numFound;
  if ($get->is_success) {
    $numFound = $get->json->{response}->{numFound};
  }
  else {
    $c->app->log->error("[$pid] error getting object $field relations count " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting object $field relations count"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  $urlget->query(q => "$field:*", fl => "pid,$field", rows => $numFound, wt => "json");

  $get = $ua->get($urlget)->result;

  my @curr_membersorder;
  if ($get->is_success) {
    for my $c_m (@{$get->json->{response}->{docs}}) {
      push @curr_membersorder, {'pid' => $c_m->{pid}, 'pos' => $c_m->{$field}};
    }
  }
  else {
    $c->app->log->error("[$pid] error getting object $field relations " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting object $field relations"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  $c->app->log->debug("[$pid] there are " . (scalar @curr_membersorder) . " docs currently having $field relation");

  my @add_to;
  my @remove_from;
  my @update;
  for my $m (@{$membersorder}) {
    my $found = 0;
    for my $mc (@curr_membersorder) {
      if ($m->{pid} eq $mc->{pid}) {
        $found = 1;
        if ($m->{pos} ne $mc->{pos}) {
          push @update, {pid => $m->{pid}, value => $m->{pos}};
        }
      }
    }
    unless ($found) {
      push @add_to, {pid => $m->{pid}, value => $m->{pos}};
    }
  }
  $c->app->log->debug("[$pid] found " . (scalar @add_to) . " $field relations to add");
  $c->app->log->debug("[$pid] found " . (scalar @update) . " $field relations to update");

  for my $mc (@curr_membersorder) {
    my $found = 0;
    for my $m (@{$membersorder}) {
      if ($m->{pid} eq $mc->{pid}) {
        $found = 1;
      }
    }
    unless ($found) {
      push @remove_from, {pid => $mc->{pid}, value => $mc->{pos}};
    }
  }
  $c->app->log->debug("[$pid] found " . (scalar @remove_from) . " $field relations to remove");

  if (scalar @add_to > 0) {
    my $r_add = $self->_update_value($c, $pid, $field, \@add_to, $updateurl, 'add');
    if ($r_add->{status} ne 200) {
      $res->{status} = $r_add->{status};
      push @{$res->{alerts}}, @{$r_add->{alerts}} if scalar @{$r_add->{alerts}} > 0;
    }
  }

  if (scalar @update > 0) {
    my $r_update = $self->_update_value($c, $pid, $field, \@update, $updateurl, 'set');
    if ($r_update->{status} ne 200) {
      $res->{status} = $r_update->{status};
      push @{$res->{alerts}}, @{$r_update->{alerts}} if scalar @{$r_update->{alerts}} > 0;
    }
  }

  if (scalar @remove_from > 0) {
    my $r_remove = $self->_update_value($c, $pid, $field, \@remove_from, $updateurl, 'remove');
    if ($r_remove->{status} ne 200) {
      $res->{status} = $r_remove->{status};
      push @{$res->{alerts}}, @{$r_remove->{alerts}} if scalar @{$r_remove->{alerts}} > 0;
    }
  }
  return $res;
}

sub _update_value {

  my ($self, $c, $pid, $field, $docsvalues, $updateurl, $action) = @_;

  my $res = {status => 200};

  #$c->app->log->debug("[$pid] updating ".(scalar @{$members})." members");

  if (scalar @{$docsvalues} <= 500) {
    return $self->_update_value_post($c, $pid, $field, $docsvalues, $updateurl, $action);
  }
  else {
    my @batch;
    for my $m (@{$docsvalues}) {
      push @batch, $m;
      if (scalar @batch >= 500) {
        my $r = $self->_update_value_post($c, $pid, $field, \@batch, $updateurl, $action);
        if ($r->{status} ne 200) {
          push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
          $res->{status} = $r->{status};
        }
        @batch = ();
      }
    }
    my $r = $self->_update_value_post($c, $pid, $field, \@batch, $updateurl, $action);
    if ($r->{status} ne 200) {
      push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      $res->{status} = $r->{status};
    }
  }

  return $res;
}

sub _update_value_post {

  my ($self, $c, $pid, $field, $docsvalues, $updateurl, $action) = @_;

  my $res = {status => 200};

  my @update;
  for my $dv (@{$docsvalues}) {
    push @update,
      {
      pid    => $dv->{pid},
      $field => {$action => $dv->{value}}
      };
  }

  my $ua = Mojo::UserAgent->new;

  # versions makes sure the document exists already
  # if it does not the field would be created as "ispartof.add" which is wrong
  # plus the member might not exist for a reason, eg it's a Page, we don't want to add it
  $updateurl->query(commit => 'true', versions => 'true', _version_ => 1);

  my $post = $ua->post($updateurl => json => \@update)->result;

  if ($post->is_success) {
    $c->app->log->debug("[$pid] updated " . (scalar @{$docsvalues}) . " documents");
  }
  else {
    unshift @{$res->{alerts}}, {type => 'error', msg => $post->message};
    $res->{status} = $post->code ? $post->code : 500;
  }

  return $res;
}

sub _update_members {
  no warnings;
  my ($self, $c, $pid, $cmodel, $updateurl, $members, $relation) = @_;

  my $res = {status => 200};

  my $numMem = scalar @{$members};

  $c->app->log->debug("[$pid] [$numMem] objects should have [$relation] relation to [$pid]");

  #$c->app->log->debug("XXXXXXXXXXXX ".$c->app->dumper($members));

  # get current members
  my $urlget = $self->_get_solrget_url($c, $cmodel);

  $urlget->query(q => "$relation:\"$pid\"", fl => "pid", rows => "0", wt => "json");

  my $ua = Mojo::UserAgent->new;

  my $get = $ua->get($urlget)->result;
  my $numFound;
  if ($get->is_success) {
    $numFound = $get->json->{response}->{numFound};
  }
  else {
    $c->app->log->error("[$pid] error getting object $relation relations count " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting object $relation relations count"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  $urlget->query(q => "$relation:\"$pid\"", fl => "pid", rows => $numFound, wt => "json");

  $get = $ua->get($urlget)->result;

  my @curr_members;
  if ($get->is_success) {
    for my $c_m (@{$get->json->{response}->{docs}}) {
      push @curr_members, $c_m->{pid};
    }
  }
  else {
    $c->app->log->error("[$pid] error getting object $relation relations " . $get->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting object $relation relations"};
    unshift @{$res->{alerts}}, {type => 'error', msg => $get->message};
    $res->{status} = $get->code ? $get->code : 500;
    return $res;
  }

  $c->app->log->debug("[$pid] there are [" . (scalar @curr_members) . "] objects currently having [$relation] relation to [$pid]");

  #$c->app->log->debug("XXXXXXXXXXXX ".$c->app->dumper(\@curr_members));

  my @add_to;
  my @remove_from;

  for my $m (@{$members}) {
    unless ($m ~~ @curr_members) {
      push @add_to, $m;
    }
  }
  $c->app->log->debug("[$pid] found " . (scalar @add_to) . " $relation relations to add");

  #$c->app->log->debug("XXXXXXXXXXXX ".$c->app->dumper(\@add_to));
  for my $m (@curr_members) {
    unless ($m ~~ @{$members}) {
      push @remove_from, $m;
    }
  }
  $c->app->log->debug("[$pid] found " . (scalar @remove_from) . " $relation relations to remove");

  #$c->app->log->debug("XXXXXXXXXXXX ".$c->app->dumper(\@remove_from));

  my $addCnt = scalar @add_to;
  my $removeCnt = scalar @remove_from;

  if ($addCnt > 0) {
    if ($addCnt > 1000) {
      $c->app->log->error("[$pid] skipping _update_members add_to, too many members to add: [$addCnt]");
      unshift @{$res->{alerts}}, {type => 'warning', msg => "[$pid] skipping _update_members add_to, too many members to add: [$addCnt]"};
      return $res;
    }
    my $r_add = $self->_update_relation($c, $pid, $relation, \@add_to, $updateurl, 'add');
    if ($r_add->{status} ne 200) {
      $res->{status} = $r_add->{status};
      push @{$res->{alerts}}, @{$r_add->{alerts}} if scalar @{$r_add->{alerts}} > 0;
    }
  }

  if ($removeCnt > 0) {
    if ($removeCnt > 1000) {
      $c->app->log->error("[$pid] skipping _update_members remove_from, too many members to remove: [$addCnt]");
      unshift @{$res->{alerts}}, {type => 'warning', msg => "[$pid] skipping _update_members remove_from, too many members to remove: [$addCnt]"};
      return $res;
    }
    my $r_remove = $self->_update_relation($c, $pid, $relation, \@remove_from, $updateurl, 'remove');
    if ($r_remove->{status} ne 200) {
      $res->{status} = $r_remove->{status};
      push @{$res->{alerts}}, @{$r_remove->{alerts}} if scalar @{$r_remove->{alerts}} > 0;
    }
  }

  return $res;
}

sub _update_relation {

  my ($self, $c, $pid, $relation, $members, $updateurl, $action) = @_;

  my $res = {status => 200};

  #$c->app->log->debug("[$pid] updating ".(scalar @{$members})." members");

  if (scalar @{$members} <= 500) {
    return $self->_update_relation_post($c, $pid, $relation, $members, $updateurl, $action);
  }
  else {
    my @batch;
    for my $m (@{$members}) {
      push @batch, $m;
      if (scalar @batch >= 500) {
        my $r = $self->_update_relation_post($c, $pid, $relation, \@batch, $updateurl, $action);
        if ($r->{status} ne 200) {
          push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
          $res->{status} = $r->{status};
        }
        @batch = ();
      }
    }
    my $r = $self->_update_relation_post($c, $pid, $relation, \@batch, $updateurl, $action);
    if ($r->{status} ne 200) {
      push @{$res->{alerts}}, @{$r->{alerts}} if scalar @{$r->{alerts}} > 0;
      $res->{status} = $r->{status};
    }
  }

  return $res;
}

sub _update_relation_post {

  my ($self, $c, $pid, $relation, $members, $updateurl, $action) = @_;

  my $res = {status => 200};

  my @update;
  for my $m (@{$members}) {
    push @update,
      {
      pid       => $m,
      $relation => {$action => $pid}
      };
  }

  my $ua = Mojo::UserAgent->new;

  # versions makes sure the document exists already
  # if it does not the field would be created as "ispartof.add" which is wrong
  # plus the member might not exist for a reason, eg it's a Page, we don't want to add it
  $updateurl->query(commit => 'true', versions => 'true', _version_ => 1);

  my $post = $ua->post($updateurl => json => \@update)->result;

  if ($post->is_success) {
    $c->app->log->debug("[$pid] updated " . (scalar @{$members}) . " documents");
  }
  else {
    unshift @{$res->{alerts}}, {type => 'error', msg => $post->message};
    $res->{status} = $post->code ? $post->code : 500;
  }

  return $res;
}

sub get {
  my ($self, $c, $pid, $ignorestatus) = @_;

  my $dc_model     = PhaidraAPI::Model::Dc->new;
  my $search_model = PhaidraAPI::Model::Search->new;
  my $object_model = PhaidraAPI::Model::Object->new;

  return $self->_get($c, $pid, $dc_model, $search_model, $object_model, $ignorestatus);
}

sub removeInfoFedoraPrefix {
  my ($self, $c, $pid) = @_;

  return $pid =~ s/info:fedora\///r;
}

sub _get {

  my ($self, $c, $pid, $dc_model, $search_model, $object_model, $ignorestatus) = @_;

  my $res = {status => 200};

  my $t0 = [gettimeofday];

  my %index;
  $res->{index} = \%index;

  my %datastreams;
  my %datastreamids;

  # get basic object properties and a list of datastreams
  if ($c->app->config->{fedora}->{version} >= 6) {

    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $fres         = $fedora_model->getObjectProperties($c, $pid);
    if ($fres->{status} ne 200) {
      return $fres;
    }

    # skip inactive objects
    my $state = $fres->{state};
    if ($state ne 'Active') {
      my $errmsg = "[_get index] $pid is $state, deleting from index.";
      $c->app->log->warn($errmsg);
      push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
      if ($state eq 'Deleted') {
        $res->{status} = 301;
      }
      if ($state eq 'Inactive') {
        $res->{status} = 302;
      }
      return $res;
    }
    $index{owner}    = $fres->{owner};
    $index{cmodel}   = $fres->{cmodel};
    $index{created}  = $fres->{created};
    $index{modified} = $fres->{modified};
    if (ref($fres->{identifier}) eq 'ARRAY') {
      for my $v (@{$fres->{identifier}}) {
        push @{$index{dc_identifier}}, $v;
      }
    }
    if (ref($fres->{references}) eq 'ARRAY') {
      for my $v (@{$fres->{references}}) {
        push @{$index{references}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{isbacksideof}) eq 'ARRAY') {
      for my $v (@{$fres->{isbacksideof}}) {
        push @{$index{isbacksideof}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{isthumbnailfor}) eq 'ARRAY') {
      for my $v (@{$fres->{isthumbnailfor}}) {
        push @{$index{isthumbnailfor}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{hassuccessor}) eq 'ARRAY') {
      for my $v (@{$fres->{hassuccessor}}) {
        push @{$index{hassuccessor}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{isalternativeformatof}) eq 'ARRAY') {
      for my $v (@{$fres->{isalternativeformatof}}) {
        push @{$index{isalternativeformatof}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{isalternativeversionof}) eq 'ARRAY') {
      for my $v (@{$fres->{isalternativeversionof}}) {
        push @{$index{isalternativeversionof}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{isinadminset}) eq 'ARRAY') {
      for my $v (@{$fres->{isinadminset}}) {
        push @{$index{isinadminset}}, $v;
      }
    }
    if (ref($fres->{haspart}) eq 'ARRAY') {
      for my $v (@{$fres->{haspart}}) {
        push @{$index{haspart}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{hasmember}) eq 'ARRAY') {
      for my $v (@{$fres->{hasmember}}) {
        push @{$index{hasmember}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{hastrack}) eq 'ARRAY') {
      for my $v (@{$fres->{hastrack}}) {
        push @{$index{hastrack}}, $self->removeInfoFedoraPrefix($c, $v);
      }
    }
    if (ref($fres->{sameAs}) eq 'ARRAY') {
      for my $v (@{$fres->{sameAs}}) {
        push @{$index{owl_sameas}}, $v;
      }
    }

    for my $dsid (@{$fres->{contains}}) {
      if ($modifiedDateOverwriteDatastreams{$dsid}) {
        # if metadata was modified later, we want that date in 'modified' date
        my $propresDs = $fedora_model->_getObjectProperties($c, "$pid/$dsid/fcr:metadata");
        if ($propresDs->{status} == 200) {
          my $dsModified = $fedora_model->getFirstJsonldValue($c, $propresDs->{props}, 'http://fedora.info/definitions/v4/repository#lastModified');
          if ($dsModified gt $index{modified}) {
            $index{modified} = $dsModified;
          }
        }
      }
      if ($indexed_datastreams{$dsid}) {
        $datastreamids{$dsid} = 1;
        if ($indexed_datastreams_xml{$dsid}) {
          my $getdsres = $fedora_model->getDatastream($c, $pid, $dsid);
          if ($getdsres->{status} != 200) {
            return $getdsres;
          }
          my $dom = Mojo::DOM->new();
          $dom->xml(1);
          $dom->parse('<foxml:xmlContent>' . decode('UTF-8', $getdsres->{$dsid}) . '</foxml:xmlContent>');
          $datastreams{$dsid} = $dom;
        }
        else {
          $datastreams{$dsid} = 1;
        }
      }
    }
    push @{$index{datastreams}}, keys %datastreamids;
  }
  else {
    $c->app->log->debug("indexing $pid: getting foxml");
    my $tgetfoxml = [gettimeofday];
    my $r_oxml    = $object_model->get_foxml($c, $pid);
    $c->app->log->debug("getting foxml took " . tv_interval($tgetfoxml));
    if ($r_oxml->{status} ne 200) {
      return $r_oxml;
    }
    $c->app->log->debug("indexing $pid: parsing foxml");
    my $tparsefoxml = [gettimeofday];
    my $dom         = Mojo::DOM->new();
    $dom->xml(1);
    $dom->parse($r_oxml->{foxml});
    $c->app->log->debug("parsing foxml took " . tv_interval($tparsefoxml));
    $c->app->log->debug("indexing $pid: foxml parsed!");

    for my $e ($dom->find('foxml\:datastream')->each) {

      my $dsid = $e->attr('ID');

      $datastreamids{$dsid} = 1;

      if ($indexed_datastreams{$dsid}) {
        my $latestVersion = $e->find('foxml\:datastreamVersion')->first;
        for my $e1 ($e->find('foxml\:datastreamVersion')->each) {
          if ($e1->attr('CREATED') gt $latestVersion->attr('CREATED')) {
            $latestVersion = $e1;
          }
        }
        $datastreams{$dsid} = $latestVersion;
      }

    }

    push @{$index{datastreams}}, keys %datastreamids;

    # keep this first so that we always get the cmodel
    if (exists($datastreams{'RELS-EXT'})) {    # it should

      my $r_relsext = $self->_index_relsext($c, $datastreams{'RELS-EXT'}->find('foxml\:xmlContent')->first, \%index);
      if ($r_relsext->{status} ne 200) {
        push @{$res->{alerts}}, {type => 'error', msg => "Error indexing RELS-EXT for $pid"};
        push @{$res->{alerts}}, @{$r_relsext->{alerts}} if scalar @{$r_relsext->{alerts}} > 0;
      }

    }

    for my $e ($dom->find('foxml\:objectProperties')->each) {
      for my $e1 ($e->find('foxml\:property')->each) {

        if ($e1->attr('NAME') eq 'info:fedora/fedora-system:def/model#state') {
          if ($ignorestatus && ($ignorestatus eq '1')) {
            $c->app->log->debug("[_get index] ignorestatus=$ignorestatus");
          }
          else {
            # skip inactive objects
            my $state = $e1->attr('VALUE');
            if ($state ne 'Active') {
              my $errmsg = "[_get index] $pid is $state, deleting from index.";
              $c->app->log->warn($errmsg);
              push @{$res->{alerts}}, {type => 'error', msg => $errmsg};
              if ($state eq 'Deleted') {
                $res->{status} = 301;
              }
              if ($state eq 'Inactive') {
                $res->{status} = 302;
              }
              return $res;
            }
          }
        }

        if ($e1->attr('NAME') eq 'info:fedora/fedora-system:def/model#ownerId') {
          $index{owner} = $e1->attr('VALUE');
        }

        if ($e1->attr('NAME') eq 'info:fedora/fedora-system:def/model#createdDate') {
          $index{created} = $e1->attr('VALUE');
        }

        if ($e1->attr('NAME') eq 'info:fedora/fedora-system:def/view#lastModifiedDate') {
          $index{modified} = $e1->attr('VALUE');
        }

      }
    }
  }

  if (exists($datastreams{'BOOKINFO'})) {
    $index{firstpagepid} = $datastreams{'BOOKINFO'}->find('book\:page[abspagenum="1"]')->first->attr('pid');
  }

  if (exists($datastreams{'GEO'})) {
    my $geo_model = PhaidraAPI::Model::Geo->new;
    my $r_geo     = $geo_model->xml_2_json($c, $datastreams{'GEO'}->find('foxml\:xmlContent')->first);
    if ($r_geo->{status} ne 200) {

      push @{$res->{alerts}}, {type => 'error', msg => "Error adding GEO fields from $pid"};
      push @{$res->{alerts}}, @{$r_geo->{alerts}} if scalar @{$r_geo->{alerts}} > 0;

    }
    else {

      for my $plm (@{$r_geo->{geo}->{kml}->{document}->{placemark}}) {

        # bbox -> WKT/CQL ENVELOPE syntax. Example: ENVELOPE(-175.360000, -173.906827, -18.568055, -21.268064) which is minX, maxX, maxY, minY order
        if (exists($plm->{polygon})) {
          my $coords = $plm->{polygon}->{outerboundaryis}->{linearring}->{coordinates};

          # we have to sort them minX, maxX, maxY, minY
          my $minLat = 90;
          my $maxLat = -90;
          my $minLon = 180;
          my $maxLon = -180;
          for my $ll (@$coords) {
            $maxLon = $ll->{longitude} if $ll->{longitude} >= $maxLon;
            $minLon = $ll->{longitude} if $ll->{longitude} <= $minLon;
            $maxLat = $ll->{latitude}  if $ll->{latitude} >= $maxLat;
            $minLat = $ll->{latitude}  if $ll->{latitude} <= $minLat;
          }

          push @{$index{bbox}}, "ENVELOPE($minLon, $maxLon, $maxLat, $minLat)";

          # add some latlon
          $index{latlon} = (($minLat + $maxLat) / 2) . ',' . (($minLon + $maxLon) / 2);
        }

        # latlon -> latitude,longitude
        my $lon_dec = $plm->{point}->{coordinates}->{longitude};
        my $lat_dec = $plm->{point}->{coordinates}->{latitude};
        if ($lon_dec >= -180 and $lon_dec <= 180 and $lat_dec >= -90 and $lat_dec <= 90) {
          if (exists($plm->{point})) {
            $index{latlon} = "$lat_dec,$lon_dec";
          }
        }
      }
    }

  }

  if (exists($datastreams{'MODS'})) {
    my $mods_model = PhaidraAPI::Model::Mods->new;
    my $r_mods     = $mods_model->xml_2_json($c, $datastreams{'MODS'}->find('foxml\:xmlContent')->first, 'basic');
    if ($r_mods->{status} ne 200) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error converting MODS xml to json for $pid"};
      push @{$res->{alerts}}, @{$r_mods->{alerts}} if scalar @{$r_mods->{alerts}} > 0;
    }
    else {
      my $r_add_mods = $self->_add_mods_index($c, $pid, $r_mods->{mods}, \%index);
      if ($r_add_mods->{status} ne 200) {
        push @{$res->{alerts}}, {type => 'error', msg => "Error adding MODS fields for $pid"};
        push @{$res->{alerts}}, @{$r_add_mods->{alerts}} if scalar @{$r_add_mods->{alerts}} > 0;
      }
      else {
        my ($dc_p, $dc_oai) = $dc_model->map_mods_2_dc_hash($c, $pid, $index{cmodel}, $datastreams{'MODS'}->find('foxml\:xmlContent')->first, $mods_model, 1);
        $self->_add_dc_index($c, $dc_p, \%index);
      }
    }

  }

  if (exists($datastreams{'JSON-LD'})) {
    my $jsonld_model = PhaidraAPI::Model::Jsonld->new;
    my $r_jsonld     = $jsonld_model->get_object_jsonld_parsed($c, $pid, $c->app->config->{phaidra}->{intcallusername}, $c->app->config->{phaidra}->{intcallpassword});

    if ($r_jsonld->{status} ne 200) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error getting JSON-LD for $pid"};
      push @{$res->{alerts}}, @{$r_jsonld->{alerts}} if scalar @{$r_jsonld->{alerts}} > 0;
    }
    else {

      my $jsonld = $r_jsonld->{'JSON-LD'};

      my $r_add_jsonld = $self->_add_jsonld_index($c, $pid, $jsonld, \%index);
      if ($r_add_jsonld->{status} ne 200) {
        push @{$res->{alerts}}, {type => 'error', msg => "Error adding JSON-LD fields for $pid"};
        push @{$res->{alerts}}, @{$r_add_jsonld->{alerts}} if scalar @{$r_add_jsonld->{alerts}} > 0;
      }
      else {
        my ($dc_p, $dc_oai) = $dc_model->map_jsonld_2_dc_hash($c, $pid, $index{cmodel}, $jsonld, $jsonld_model, 1);
        $self->_add_dc_index($c, $dc_p, \%index);
      }
    }
  }
  elsif (exists($datastreams{'UWMETADATA'})) {    # keep in else to avoid overwriting index fields for objects which have both JSON-LD and uwmetadata
    my $tadduwmindex = [gettimeofday];
    my $r_add_uwm    = $self->_add_uwm_index($c, $pid, $datastreams{'UWMETADATA'}->find('foxml\:xmlContent')->first, \%index);
    # $c->app->log->debug("_add_uwm_index took " . tv_interval($tadduwmindex));
    if ($r_add_uwm->{status} ne 200) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error adding UWMETADATA fields for $pid"};
      push @{$res->{alerts}}, @{$r_add_uwm->{alerts}} if scalar @{$r_add_uwm->{alerts}} > 0;
    }

    my $uw_model = PhaidraAPI::Model::Uwmetadata->new;

    my $tgetuwmtree = [gettimeofday];
    my $r0          = $uw_model->metadata_tree($c);
    # $c->app->log->debug("getting metadata_tree took " . tv_interval($tgetuwmtree));

    if ($r0->{status} ne 200) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error getting UWMETADATA tree for $pid"};
      push @{$res->{alerts}}, @{$r0->{alerts}} if scalar @{$r0->{alerts}} > 0;
    }
    else {
      my $tmapuwmdc = [gettimeofday];
      my ($dc_p, $dc_oai) = $dc_model->map_uwmetadata_2_dc_hash($c, $pid, $index{cmodel}, $datastreams{'UWMETADATA'}->find('foxml\:xmlContent')->first, $r0->{metadata_tree}, $uw_model, 1);
      # $c->app->log->debug("mapping uwm to dc took " . tv_interval($tmapuwmdc));

      $self->_add_dc_index($c, $dc_p, \%index);
    }
  }

  if (exists($datastreams{'ANNOTATIONS'})) {

    my $ann_model = PhaidraAPI::Model::Annotations->new;
    my $r_ann     = $ann_model->xml_2_json($c, $datastreams{'ANNOTATIONS'}->find('foxml\:xmlContent')->first);
    if ($r_ann->{status} ne 200) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error adding ANNOTATIONS from $pid"};
      push @{$res->{alerts}}, @{$r_ann->{alerts}} if scalar @{$r_ann->{alerts}} > 0;
    }
    else {
      for my $id (keys %{$r_ann->{annotations}}) {
        my $title = $r_ann->{annotations}->{$id}->{title} if exists $r_ann->{annotations}->{$id}->{title};
        my $text  = $r_ann->{annotations}->{$id}->{text}  if exists $r_ann->{annotations}->{$id}->{text};
        my $ann   = "";
        $ann .= $title . ": " if defined $title;
        $ann .= $text;
        push @{$index{annotations}}, $ann;
      }
    }

    # for fast annotation access, add them as json as well
    $index{annotations_json} = b(encode_json($r_ann->{annotations}))->decode('UTF-8');
  }

  if (exists($datastreams{'RIGHTS'})) {

    my $rights_model = PhaidraAPI::Model::Rights->new;
    my $r_rights     = $rights_model->xml_2_json($c, $datastreams{'RIGHTS'}->find('foxml\:xmlContent')->first);
    if ($r_rights->{status} ne 200) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error indexing RIGHTS from $pid"};
      push @{$res->{alerts}}, @{$r_rights->{alerts}} if scalar @{$r_rights->{alerts}} > 0;
    }
    else {
      my @expires;
      for my $id (keys %{$r_rights->{rights}}) {
        if (exists($r_rights->{rights}->{$id})) {
          $index{isrestricted} = '1';
          for my $rule (@{$r_rights->{rights}->{$id}}) {
            if (ref $rule eq ref {}) {
              if (exists($rule->{expires})) {
                push @expires, $rule->{expires};
              }
            }
          }
        }
      }
      my $nrExpires = scalar @expires;
      if ($nrExpires > 0) {
        my @sorted_expires = sort @expires;
        $index{checkafter} = $sorted_expires[0];
      }
    }
  }

  if (exists($datastreams{'COLLECTIONORDER'})) {

    my $membersorder_model = PhaidraAPI::Model::Membersorder->new;
    my $r_mo               = $membersorder_model->xml_2_json($c, $datastreams{'COLLECTIONORDER'}->find('foxml\:xmlContent')->first);
    if ($r_mo->{status} ne 200) {
      push @{$res->{alerts}}, {type => 'error', msg => "Error adding COLLECTIONORDER from $pid"};
      push @{$res->{alerts}}, @{$r_mo->{alerts}} if scalar @{$r_mo->{alerts}} > 0;
    }
    else {
      $index{membersorder} = $r_mo->{members};
    }

  }

  # relations
  my $r_add_rrels = $self->_add_reverse_relations($c, $pid, $index{cmodel}, $search_model, \%index);
  if ($r_add_rrels->{status} ne 200) {
    push @{$res->{alerts}}, {type => 'error', msg => "Error adding reverse relationships for $pid"};
    push @{$res->{alerts}}, @{$r_add_rrels->{alerts}} if scalar @{$r_add_rrels->{alerts}} > 0;
  }

  # inventory
  if ($c->app->config->{fedora}->{version} >= 6) {

    my $fedora_model = PhaidraAPI::Model::Fedora->new;
    my $dssres       = $fedora_model->getDatastreamAttributes($c, $pid, 'OCTETS');
    if ($dssres->{status} == 200) {
      $index{size} = $dssres->{size};
    }
  }
  else {
    if (exists($c->app->config->{paf_mongodb})) {
      my $inv_coll = $c->paf_mongo->get_collection('foxml.ds');
      if ($inv_coll) {
        my $ds_doc = $inv_coll->find_one({pid => $pid}, {}, {"sort" => {"updated_at" => -1}});
        $index{size} = $ds_doc->{ds_sizes}->{OCTETS};
      }
    }
    unless ($index{size}) {
      my $octets_model = PhaidraAPI::Model::Octets->new;
      my $parthres     = $octets_model->_get_ds_path($c, $pid, 'OCTETS');
      if ($parthres->{status} == 200) {
        $index{size} = -s $parthres->{path};
      }
    }
  }

  # pid
  $index{pid} = $pid;

  my $resourcetype;
  $resourcetype = $cmodel_2_resourcetype{$index{cmodel}};
  if (exists($index{"bib_ir"}) && defined($index{"bib_ir"}) && $index{"bib_ir"} eq "yes") {
    $resourcetype = "journalarticle";
  }
  if (exists($index{"owner"}) && defined($index{"owner"}) && $index{"owner"} eq "ubmapsp2") {
    $resourcetype = "map";
  }
  if (exists($index{"dc_subject"})) {
    for my $s (@{$index{"dc_subject"}}) {
      if ($s eq "Altkarte" || $s eq "Karte" || $s eq "Themakarte") {
        $resourcetype = "map";
      }
    }
  }
  $index{resourcetype} = $resourcetype;

  if ($c->app->config->{ir}) {
    if ($c->app->config->{ir}->{adminset}) {
      if (exists($index{isinadminset})) {
        for my $as (@{$index{isinadminset}}) {
          if ($as eq $c->app->config->{ir}->{adminset}) {
            if (exists($index{dc_title})) {
              for my $t (@{$index{dc_title}}) {
                push @{$index{title_suggest_ir}}, $t;
              }
            }
          }
        }
      }
    }
  }

  # update the index with members metadata:
  # member_metadata - so that basic metadata of members (pid, title, desc, subject) will be indexed
  # also "memberresourcetype:<resourcetype>" is added as a value - so that we can filter containers containing particular types of members (eg videos)
  my $membersCnt = scalar $index{hasmember};
  if (defined($membersCnt) && $membersCnt > 0) {
    my $urlget = $self->_get_solrget_url($c, $index{cmodel});

    # rows:100 - some conainert can be really big, but indexing all members is unlikely to make sense in such big containers
    $urlget->query(q => "*:*", fq => 'ismemberof:"' . $pid . '"', rows => 100, wt => "json");

    my $getres = $c->ua->get($urlget)->result;

    if ($getres->is_success) {
      if ($getres->json->{response}->{numFound} > 0) {

        # hash, to avoid duplicity
        my $values;
        for my $mem_doc (@{$getres->json->{response}->{docs}}) {
          if ($mem_doc->{pid}) {
            unless (exists($values->{$mem_doc->{pid}})) {
              $values->{$mem_doc->{pid}} = 1;
            }
            unless (exists($values->{'memberresourcetype:' . $mem_doc->{resourcetype}})) {
              $values->{'memberresourcetype:' . $mem_doc->{resourcetype}} = 1;
            }
            for my $k (keys %{$mem_doc}) {
              if ($k =~ m/^dc_([a-z]+)_?([a-z]+)?$/) {
                if (($1 eq 'title') || ($1 eq 'description') || ($1 eq 'subject')) {
                  for my $dcv (@{$mem_doc->{$k}}) {
                    unless (exists($values->{$dcv})) {
                      $values->{$dcv} = 1;
                    }
                  }
                }
              }
            }
          }
        }
        push @{$index{'members_metadata'}}, keys %{$values};
      }
    }
  }

  # ts
  $index{_updated} = time;

  # $c->app->log->debug("XXXXXXXXXXXXX index: " . $c->app->dumper(\%index));

  $c->app->log->debug("_get indexing took " . tv_interval($t0));
  return $res;
}

# info:fedora/fedora-system:def/model#hasModel
# info:fedora/fedora-system:def/relations-external#hasCollectionMember
# http://pcdm.org/models#hasMember
# http://purl.org/dc/terms/references
# http://phaidra.org/XML/V1.0/relations#isBackSideOf
# http://phaidra.univie.ac.at/XML/V1.0/relations#hasSuccessor
# http://phaidra.org/XML/V1.0/relations#isAlternativeFormatOf
# http://phaidra.org/XML/V1.0/relations#isAlternativeVersionOf
# http://phaidra.org/ontology/isInAdminSet

sub _index_relsext {
  my ($self, $c, $xml, $index) = @_;

  my $res = {alerts => [], status => 200};

  my $cmodel = $xml->find('hasModel')->first->attr('rdf:resource');
  $cmodel =~ s/^info:fedora\/cmodel:(.*)$/$1/;
  $index->{cmodel} = $cmodel;

  for my $e ($xml->find('identifier')->each) {
    my $o = $e->attr('rdf:resource');
    push @{$index->{dc_identifier}}, $o;
  }

  for my $e ($xml->find('references')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{references}}, $o;
  }

  for my $e ($xml->find('isBackSideOf')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{isbacksideof}}, $o;
  }

  for my $e ($xml->find('isThumbnailFor')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{isthumbnailfor}}, $o;
  }

  for my $e ($xml->find('hasSuccessor')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{hassuccessor}}, $o;
  }

  for my $e ($xml->find('isAlternativeFormatOf')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{isalternativeformatof}}, $o;
  }

  for my $e ($xml->find('isAlternativeVersionOf')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{isalternativeversionof}}, $o;
  }

  for my $e ($xml->find('isInAdminSet')->each) {
    my $o = $e->attr('rdf:resource');
    push @{$index->{isinadminset}}, $o;
  }

  for my $e ($xml->find('hasCollectionMember')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{haspart}}, $o;
  }

  for my $e ($xml->find('hasMember')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{hasmember}}, $o;
  }

  for my $e ($xml->find('hasTrack')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{hastrack}}, $o;
  }

  # padova
  for my $e ($xml->find('sameAs')->each) {
    my $o = $e->attr('rdf:resource');
    $o =~ s/^info:fedora\/(.*)$/$1/;
    push @{$index->{owl_sameas}}, $o;
  }

  return $res;
}

sub _add_dc_index {
  my ($self, $c, $dc, $index) = @_;
  while (my ($xmlname, $values) = each %{$dc}) {
    for my $v (@{$values}) {
      if (exists($v->{value}) && defined($v->{value}) && $v->{value} ne '') {
        my $val = $v->{value};
        if (exists($v->{lang})) {
          if (($xmlname eq 'title') || ($xmlname eq 'description')) {
            push @{$index->{'dc_' . $xmlname}}, $val;
          }
          my $lang = $v->{lang};
          if (length($v->{lang}) eq 2) {
            $lang = $PhaidraAPI::Model::Languages::iso639map{$v->{lang}};
          }
          push @{$index->{'dc_' . $xmlname . "_" . $lang}}, $val;
          if ($xmlname eq 'title') {
            $index->{sort_dc_title} = trim $val;
            $index->{'sort_' . $lang . '_dc_title'} = trim $val;
          }
        }
        else {
          push @{$index->{'dc_' . $xmlname}}, $val;
          if ($xmlname eq 'title') {
            $index->{sort_dc_title} = trim $val;
          }
        }
      }
    }
  }
}

sub _add_reverse_relations {

  my ($self, $c, $pid, $cmodel, $search_model, $index) = @_;

  my $res = {alerts => [], status => 200};

  my $urlget = $self->_get_solrget_url($c, $cmodel);
  $urlget->query(q => "*:*", fq => 'haspart:"' . $pid . '"', rows => 1000, wt => "json");
  my $r = $c->ua->get($urlget)->result;
  if ($r->is_success) {
    for my $d (@{$r->json->{response}->{docs}}) {
      push @{$index->{ispartof}}, $d->{pid};
    }
  }
  else {
    $c->app->log->error("[$pid] error getting solr doc in _add_reverse_relations for pid[$pid]: " . $r->code . " " . $r->message);
  }

  $urlget->query(q => "*:*", fq => 'hasmember:"' . $pid . '"', rows => 1000, wt => "json");
  $r = $c->ua->get($urlget)->result;
  if ($r->is_success) {
    for my $d (@{$r->json->{response}->{docs}}) {
      push @{$index->{ismemberof}}, $d->{pid};
    }
  }
  else {
    $c->app->log->error("[$pid] error getting solr doc in _add_reverse_relations for pid[$pid]: " . $r->code . " " . $r->message);
  }

  return $res;
}

sub _add_mods_index {
  my ($self, $c, $pid, $modsjson, $index) = @_;

  my $res = {alerts => [], status => 200};

  my @roles;
  for my $n (@{$modsjson}) {

    if ($n->{xmlname} eq 'name') {
      next unless exists $n->{children};
      my $firstname;
      my $lastname;
      my $institution;
      my $role;
      for my $n1 (@{$n->{children}}) {
        if ($n1->{xmlname} eq 'namePart') {
          if (exists($n1->{attributes})) {
            for my $a (@{$n1->{attributes}}) {
              if ($a->{xmlname} eq 'type' && $a->{ui_value} eq 'given') {
                $firstname = $n1->{ui_value} if $n1->{ui_value} ne '';
              }
              if ($a->{xmlname} eq 'type' && $a->{ui_value} eq 'family') {
                $lastname = $n1->{ui_value} if $n1->{ui_value} ne '';
              }
              if ($a->{xmlname} eq 'type' && $a->{ui_value} eq 'corporate') {
                $institution = $n1->{ui_value} if $n1->{ui_value} ne '';
              }
            }
          }
        }
        if ($n1->{xmlname} eq 'role') {
          if (exists($n1->{children})) {
            for my $ch (@{$n1->{children}}) {
              if ($ch->{xmlname} eq 'roleTerm') {
                if (exists($ch->{attributes})) {
                  my $type;
                  for my $a (@{$ch->{attributes}}) {
                    if ($a->{xmlname} eq 'type') {
                      $type = $a->{ui_value};
                    }
                  }
                  if ($type eq 'code') {
                    $role = $ch->{ui_value} if $ch->{ui_value} ne '';
                  }
                }
              }
            }
          }
        }
      }
      my $name = (defined($firstname) ? $firstname : '') . " " . (defined($lastname) ? $lastname : '');
      push @{$index->{"bib_roles_pers_$role"}}, trim $name unless $name eq ' ';
      push @{$index->{"bib_roles_corp_$role"}}, $institution if defined $institution;
    }

    if ($n->{xmlname} eq 'originInfo') {
      next unless exists $n->{children};
      for my $n1 (@{$n->{children}}) {
        if ($n1->{xmlname} eq 'dateIssued') {
          push @{$index->{"bib_published"}}, $n1->{ui_value} if $n1->{ui_value} ne '';
        }
        if ($n1->{xmlname} eq 'publisher') {
          push @{$index->{"bib_publisher"}}, $n1->{ui_value} if $n1->{ui_value} ne '';
        }
        if ($n1->{xmlname} eq 'place') {
          if (exists($n1->{children})) {
            for my $n2 (@{$n1->{children}}) {
              if ($n2->{xmlname} eq 'placeTerm') {
                push @{$index->{"bib_publisherlocation"}}, $n2->{ui_value} if $n2->{ui_value} ne '';
              }
            }
          }
        }
        if ($n1->{xmlname} eq 'edition') {
          push @{$index->{"bib_edition"}}, $n1->{ui_value} if $n1->{ui_value} ne '';
        }
      }
    }
  }

  return $res;
}

sub _add_jsonld_index {
  my ($self, $c, $pid, $jsonld, $index) = @_;

  my $res = {alerts => [], status => 200};

  my @roles;

  my @descriptions;
  if ($jsonld->{'bf:note'}) {
    for my $d (@{$jsonld->{'bf:note'}}) {
      push @descriptions, $d;
    }
  }

  my $titles = $jsonld->{'dce:title'};
  for my $o (@{$titles}) {
    for my $mt (@{$o->{'bf:mainTitle'}}) {
      if ($o->{'@type'} eq 'bf:Title') {
        push @{$index->{"bf_title_maintitle"}}, $mt->{'@value'};
      }
      if ($o->{'@type'} eq 'bf:ParallelTitle') {
        push @{$index->{"bf_paralleltitle_maintitle"}}, $mt->{'@value'};
      }
    }
    if ($o->{'bf:subtitle'}) {
      for my $st (@{$o->{'bf:subtitle'}}) {
        if ($o->{'@type'} eq 'bf:Title') {
          push @{$index->{"bf_title_subtitle"}}, $st->{'@value'};
        }
        if ($o->{'@type'} eq 'bf:ParallelTitle') {
          push @{$index->{"bf_paralleltitle_subtitle"}}, $st->{'@value'};
        }
      }
    }
  }

  if ($jsonld->{'dcterms:created'}) {
    for my $date (@{$jsonld->{'dcterms:created'}}) {
      my $dccreatedsub = substr($date, 0, 4);
      if (looks_like_number($dccreatedsub)) {
        my $dccreated = int($dccreatedsub);
        push @{$index->{"dcterms_created_year"}}, $dccreated;
        $index->{"dcterms_created_year_sort"} = $dccreated;
      }
    }
  }

  if ($jsonld->{'rdau:P60071'}) {
    for my $date (@{$jsonld->{'rdau:P60071'}}) {
      my $rdauprodsub = substr($date, 0, 4);
      if (looks_like_number($rdauprodsub)) {
        my $rdauprod = int($rdauprodsub);
        push @{$index->{"rdau_P60071_year"}}, $rdauprod;
        $index->{"rdau_P60071_year_sort"} = $rdauprod;
      }
    }
  }

  if ($jsonld->{'rdam:P30004'}) {
    for my $id (@{$jsonld->{'rdam:P30004'}}) {
      my $prefix = '';
      if (exists($id->{'@type'})) {
        my $type = $id->{'@type'};
        if ($type =~ m/^ids:(\w)+$/) {
          $prefix = substr($type, 4);
        }
        if ($type =~ m/^phaidra:(\w)+$/) {
          $prefix = substr($type, 8);
        }
      }
      if ($prefix eq 'urn') {
        push @{$index->{"dc_identifier"}}, $id->{'@value'};
      }
      else {
        push @{$index->{"dc_identifier"}}, $prefix . ":" . $id->{'@value'};
      }
    }
  }

  my %foundAss;
  my %foundAssIds;
  if ($jsonld->{'rdax:P00009'}) {
    for my $ass (@{$jsonld->{'rdax:P00009'}}) {
      for my $l (@{$ass->{'skos:prefLabel'}}) {
        unless (exists($foundAssIds{$l->{'@value'}})) {
          push @{$index->{"association"}}, $l->{'@value'};
          $foundAss{$l->{'@value'}} = 1;
        }
      }
      if ($ass->{'skos:exactMatch'}) {
        for my $id (@{$ass->{'skos:exactMatch'}}) {
          unless (exists($foundAssIds{$id})) {
            push @{$index->{"association_id"}}, $id;
            $foundAssIds{$id} = 1;
            my $pp = $c->app->directory->org_get_parentpath($c, $id);
            if ($pp->{status} eq 200) {
              for my $parent (@{$pp->{parentpath}}) {
                if ($parent->{'@id'} ne $id) {
                  unless (exists($foundAssIds{$parent->{'@id'}})) {
                    push @{$index->{"association_id"}}, $parent->{'@id'};
                    $foundAssIds{$parent->{'@id'}} = 1;
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  my $roles_res = $self->_add_jsonld_roles($c, $pid, $jsonld, $index, \%foundAss, \%foundAssIds);
  push @{$res->{alerts}}, @{$roles_res->{alerts}} if scalar @{$roles_res->{alerts}} > 0;
  for my $r (@{$roles_res->{roles}}) {
    push @roles, $r;
  }

  if ($jsonld->{'vra:hasInscription'}) {
    for my $o (@{$jsonld->{'vra:hasInscription'}}) {
      for my $l (@{$o->{'skos:prefLabel'}}) {
        push @{$index->{"vra_inscription"}}, $l->{'@value'};
      }
    }
  }

  $index->{"roles_json"} = b(encode_json(\@roles))->decode('UTF-8');

  if (scalar @descriptions) {
    $index->{"descriptions_json"} = b(encode_json(\@descriptions))->decode('UTF-8');
  }

  if (exists($jsonld->{'dcterms:subject'})) {
    for my $o (@{$jsonld->{'dcterms:subject'}}) {
      if ($o->{'@type'} eq 'phaidra:Subject') {
        my $rr = $self->_add_jsonld_index($c, $pid, $o, $index);
        push @{$res->{alerts}}, @{$rr->{alerts}} if scalar @{$rr->{alerts}} > 0;
      }
      else {
        # the @values will be indexed as part of DC, but IDs (skos:exactMatch) not
        if ($o->{'skos:exactMatch'}) {
          for my $subject_id (@{$o->{'skos:exactMatch'}}) {
            push @{$index->{"dcterms_subject_id"}}, $subject_id;
          }
        }
      }
    }
  }

  if (exists($jsonld->{'bf:provisionActivity'})) {
    for my $pa (@{$jsonld->{'bf:provisionActivity'}}) {
      if (exists($pa->{'bf:agent'})) {
        for my $ag (@{$pa->{'bf:agent'}}) {
          if (exists($ag->{'schema:name'})) {
            my %publisherNames;
            for my $pn (@{$ag->{'schema:name'}}) {
              if (exists($pn->{'@language'}) && ($pn->{'@language'} ne 'xxx')) {
                $publisherNames{$pn->{'@language'}} = $pn->{'@value'};
              }
              else {
                $publisherNames{'nolang'} = $pn->{'@value'};
              }
            }
            my $publisher;
            my $addInstitutionName = 0;
            if (exists($ag->{'skos:exactMatch'})) {
              for my $pubId (@{$ag->{'skos:exactMatch'}}) {
                if (rindex($pubId, 'https://pid.phaidra.org/', 0) == 0) {
                  $addInstitutionName = 1;
                  last;
                }
              }
            }
            if (exists($publisherNames{'nolang'})) {
              $publisher = $publisherNames{'nolang'} if $publisherNames{'nolang'} ne '';
            }
            else {
              if (exists($publisherNames{'eng'})) {
                $publisher = $publisherNames{'eng'} if $publisherNames{'eng'} ne '';
              }
              else {
                for my $pubNameLang (keys %publisherNames) {
                  $publisher = $publisherNames{$pubNameLang} if $publisherNames{$pubNameLang} ne '';
                  last;
                }
              }
            }
            if ($addInstitutionName) {
              my $institutionName = $c->app->directory->org_get_name($c, 'eng');
              if ($institutionName) {
                if ((index($publisher, $institutionName) == -1)) {
                  $publisher = "$institutionName. $publisher";
                }
              }
            }
            push @{$index->{"bib_publisher"}}, $publisher;
          }
        }
      }
    }
  }

  if (exists($jsonld->{'frapo:isOutputOf'})) {
    for my $proj (@{$jsonld->{'frapo:isOutputOf'}}) {
      if (defined($proj->{'@type'})) {
        if ($proj->{'@type'} eq 'foaf:Project') {
          if (exists($proj->{'skos:exactMatch'})) {
            for my $projId (@{$proj->{'skos:exactMatch'}}) {
              push @{$index->{"project_id"}}, $projId;
            }
          }
          if (exists($proj->{'skos:prefLabel'})) {
            for my $l (@{$proj->{'skos:prefLabel'}}) {
              push @{$index->{"project"}}, $l->{'@value'};
            }
          }
        }
        if ($proj->{'@type'} eq 'aiiso:Programme') {
          if (exists($proj->{'skos:exactMatch'})) {
            for my $projId (@{$proj->{'skos:exactMatch'}}) {
              push @{$index->{"programme_id"}}, $projId;
            }
          }
          if (exists($proj->{'skos:prefLabel'})) {
            for my $l (@{$proj->{'skos:prefLabel'}}) {
              push @{$index->{"programme"}}, $l->{'@value'};
            }
          }
        }
      }
      if (exists($proj->{'frapo:hasFundingAgency'})) {
        for my $funder (@{$proj->{'frapo:hasFundingAgency'}}) {
          if (exists($funder->{'skos:prefLabel'})) {
            for my $l (@{$funder->{'skos:prefLabel'}}) {
              push @{$index->{"funder"}}, $l->{'@value'};
            }
          }
          if (exists($funder->{'skos:exactMatch'})) {
            for my $id (@{$funder->{'skos:exactMatch'}}) {
              push @{$index->{"funder_id"}}, $id;
            }
          }
        }
      }
    }
    push @{$index->{"frapo_isoutputof_json"}}, b(encode_json($jsonld->{'frapo:isOutputOf'}))->decode('UTF-8');
  }

  if (exists($jsonld->{'frapo:hasFundingAgency'})) {
    for my $funder (@{$jsonld->{'frapo:hasFundingAgency'}}) {
      if (exists($funder->{'skos:prefLabel'})) {
        for my $l (@{$funder->{'skos:prefLabel'}}) {
          push @{$index->{"funder"}}, $l->{'@value'};
        }
      }
      if (exists($funder->{'skos:exactMatch'})) {
        for my $id (@{$funder->{'skos:exactMatch'}}) {
          push @{$index->{"funder_id"}}, $id;
        }
      }
    }
    push @{$index->{"frapo_hasfundingagency_json"}}, b(encode_json($jsonld->{'frapo:hasFundingAgency'}))->decode('UTF-8');
  }

  if (exists($jsonld->{'dcterms:issued'}) && $jsonld->{'dcterms:issued'} ne '') {
    push @{$index->{"bib_published"}}, $jsonld->{'dcterms:issued'}[0];
  }

  # if (exists($jsonld->{'dcterms:dateSubmitted'}) && $jsonld->{'dcterms:dateSubmitted'} ne '') {
  #   push @{$index->{"dcterms_datesubmitted"}}, $jsonld->{'dcterms:dateSubmitted'}[0];
  # }

  if (exists($jsonld->{'rdau:P60193'})) {
    for my $o (@{$jsonld->{'rdau:P60193'}}) {
      if (exists($o->{'dce:title'})) {
        if ($o->{'dce:title'}[0]->{'bf:mainTitle'}[0]->{'@value'} ne '') {
          push @{$index->{"bib_journal"}}, $o->{'dce:title'}[0]->{'bf:mainTitle'}[0]->{'@value'};
        }
      }
      if (exists($o->{'bibo:volume'}) && $o->{'bibo:volume'} ne '') {
        push @{$index->{"bib_volume"}}, $o->{'bibo:volume'}[0];
      }
      if (exists($o->{'bibo:issue'}) && $o->{'bibo:issue'} ne '') {
        push @{$index->{"bib_issue"}}, $o->{'bibo:issue'}[0];
      }
      unless (exists($index->{"bib_published"})) {
        if ((exists($o->{'bibo:volume'}) && $o->{'bibo:volume'} ne '') or (exists($o->{'bibo:issue'}) && $o->{'bibo:issue'} ne '')) {
          if (exists($o->{'dcterms:issued'}) && $o->{'dcterms:issued'} ne '') {
            push @{$index->{"bib_published"}}, $o->{'dcterms:issued'}[0];
          }
        }
      }
    }
  }

  if (exists($jsonld->{'rdau:P60101'})) {
    for my $o (@{$jsonld->{'rdau:P60101'}}) {
      if (exists($o->{'bf:provisionActivity'})) {
        if (exists($o->{'bf:provisionActivity'}[0]->{'bf:date'})) {
          if (exists($o->{'bf:provisionActivity'}[0]->{'bf:date'}[0]) and ($o->{'bf:provisionActivity'}[0]->{'bf:date'}[0] ne '')) {
            unless (exists($index->{"bib_published"})) {
              push @{$index->{"bib_published"}}, $o->{'bf:provisionActivity'}[0]->{'bf:date'}[0];
            }
          }
        }
      }
    }
  }

  if (exists($jsonld->{'schema:pageStart'})) {
    for my $o (@{$jsonld->{'schema:pageStart'}}) {
      push @{$index->{"schema_pagestart"}}, $o;
    }
  }

  if (exists($jsonld->{'schema:pageEnd'})) {
    for my $o (@{$jsonld->{'schema:pageEnd'}}) {
      push @{$index->{"schema_pageend"}}, $o;
    }
  }

  if ($jsonld->{'edm:hasType'}) {
    for my $o (@{$jsonld->{'edm:hasType'}}) {
      for my $l (@{$o->{'skos:prefLabel'}}) {
        push @{$index->{"edm_hastype"}}, $l->{'@value'};
      }
      for my $id (@{$o->{'skos:exactMatch'}}) {
        push @{$index->{"edm_hastype_id"}}, $id;
        push @{$index->{"object_type_id"}}, $id;
        if ($id eq 'https://pid.phaidra.org/vocabulary/YA8R-1M0D') {
          $index->{"oer"} = '1';
        }
      }
    }
  }

  if ($jsonld->{'rdau:P60048'}) {
    for my $o (@{$jsonld->{'rdau:P60048'}}) {
      for my $l (@{$o->{'skos:prefLabel'}}) {
        push @{$index->{"rdau_P60048"}}, $l->{'@value'};
      }
      for my $id (@{$o->{'skos:exactMatch'}}) {
        push @{$index->{"rdau_P60048_id"}}, $id;
      }
    }
  }

  if ($jsonld->{'schema:genre'}) {
    for my $o (@{$jsonld->{'schema:genre'}}) {
      for my $l (@{$o->{'skos:prefLabel'}}) {
        push @{$index->{"schema_genre"}}, $l->{'@value'};
      }
      for my $id (@{$o->{'skos:exactMatch'}}) {
        push @{$index->{"schema_genre_id"}}, $id;
      }
    }
  }

  if ($jsonld->{'dcterms:accessRights'}) {
    for my $o (@{$jsonld->{'dcterms:accessRights'}}) {
      for my $id (@{$o->{'skos:exactMatch'}}) {
        push @{$index->{"dcterms_accessrights_id"}}, $id;
      }
    }
  }

  if ($jsonld->{'oaire:version'}) {
    for my $o (@{$jsonld->{'oaire:version'}}) {
      for my $id (@{$o->{'skos:exactMatch'}}) {
        push @{$index->{"oaire_version_id"}}, $id;
      }
    }
  }

  if ($jsonld->{'dcterms:available'}) {
    for my $d (@{$jsonld->{'dcterms:available'}}) {
      push @{$index->{"dcterms_available"}}, $d;
    }
  }

  if ($jsonld->{'bf:shelfMark'}) {
    for my $o (@{$jsonld->{'bf:shelfMark'}}) {
      push @{$index->{"bf_shelfmark"}}, $o;
    }
  }

  if ($jsonld->{'phaidra:systemTag'}) {
    for my $o (@{$jsonld->{'phaidra:systemTag'}}) {

      # org.apache.lucene.util.BytesRefHash$MaxBytesLengthExceededException: bytes can be at most 32766 in length; got 40045
      if (length($o) <= 32766) {
        push @{$index->{"systemtag"}}, $o;
      }
    }
  }

  if ($jsonld->{'bf:physicalLocation'}) {
    for my $o (@{$jsonld->{'bf:physicalLocation'}}) {
      push @{$index->{"bf_physicallocation"}}, $o->{'@value'};
    }
  }

  return $res;
}

sub _add_jsonld_roles {
  my ($self, $c, $pid, $jsonld, $index, $foundAss, $foundAssIds) = @_;
  my $res = {alerts => [], status => 200};
  my @roles;
  for my $pred (keys %{$jsonld}) {
    if ($pred =~ m/role:(\w+)/g) {
      my $role = $1;
      push @roles, {$pred => $jsonld->{$pred}};
      my $name;
      for my $contr (@{$jsonld->{$pred}}) {
        if ($contr->{'@type'} eq 'schema:Person') {
          if ($contr->{'schema:givenName'} || $contr->{'schema:familyName'}) {
            $name = $contr->{'schema:givenName'}[0]->{'@value'} . " " . $contr->{'schema:familyName'}[0]->{'@value'};
          }
          else {
            $name = $contr->{'schema:name'}[0]->{'@value'};
          }
          if ($contr->{'skos:exactMatch'}) {
            for my $exm (@{$contr->{'skos:exactMatch'}}) {
              my $type = $exm->{'@type'};
              my $id   = trim($exm->{'@value'});
              $type =~ s/^ids://;
              push @{$index->{"id_bib_roles_pers_" . $role}}, $type . ':' . $id unless ($id eq '');
            }
          }
          if ($contr->{'schema:affiliation'}) {
            for my $aff (@{$contr->{'schema:affiliation'}}) {
              for my $affname (@{$aff->{'schema:name'}}) {
                unless (exists($foundAss->{$affname->{'@value'}})) {
                  push @{$index->{"association"}}, $affname->{'@value'};
                  $foundAss->{$affname->{'@value'}} = 1;
                }
              }
              if ($aff->{'skos:exactMatch'}) {
                for my $id (@{$aff->{'skos:exactMatch'}}) {
                  unless (exists($foundAssIds->{$id})) {
                    if (reftype $id ne reftype {}) {
                      push @{$index->{"association_id"}}, $id;
                      $foundAssIds->{$id} = 1;
                      my $pp = $c->app->directory->org_get_parentpath($c, $id);
                      if ($pp->{status} eq 200) {
                        for my $parent (@{$pp->{parentpath}}) {
                          if ($parent->{'@id'} ne $id) {
                            unless (exists($foundAssIds->{$parent->{'@id'}})) {
                              push @{$index->{"association_id"}}, $parent->{'@id'};
                              $foundAssIds->{$parent->{'@id'}} = 1;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        elsif ($contr->{'@type'} eq 'schema:Organization') {
          unless (exists($foundAss->{$name})) {
            $name = $contr->{'schema:name'}[0]->{'@value'};
            push @{$index->{"association"}}, $name;
            $foundAss->{$name} = 1;
          }
          if ($contr->{'skos:exactMatch'}) {
            for my $id (@{$contr->{'skos:exactMatch'}}) {
              unless (exists($foundAssIds->{$id})) {
                if (reftype $id ne reftype {}) {
                  push @{$index->{"association_id"}}, $id;
                  $foundAssIds->{$id} = 1;
                }
              }
            }
          }
        }
        else {
          $c->app->log->error("Unknown contributor type in jsonld for pid $pid");
          push @{$res->{alerts}}, {type => 'error', msg => "Unknown contributor type in jsonld for pid $pid"};
        }
        push @{$index->{"bib_roles_pers_$role"}}, trim $name unless ($name eq '' || $name eq ' ');
      }
    }
  }
  $res->{roles} = \@roles;
  return $res;
}

sub _add_uwm_index {
  my ($self, $c, $pid, $uwmetadata, $index) = @_;

  my $res = {alerts => [], status => 200};

  my $uwmetadata_model = PhaidraAPI::Model::Uwmetadata->new;
  my $r_uwm            = $uwmetadata_model->uwmetadata_2_json_basic($c, $uwmetadata, 'resolved');

  #my $r_uwm = $uwmetadata_model->get_object_metadata($c, $pid, 'resolved', $c->stash->{basic_auth_credentials}->{username}, $c->stash->{basic_auth_credentials}->{password});
  #  $c->app->log->debug("XXXXXXXXXXXXXXX".$c->app->dumper($r_uwm));
  if ($r_uwm->{status} ne 200) {
    return $r_uwm;
  }

  my $uwm = $r_uwm->{uwmetadata};

  # general
  my $general = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0", "general", $uwm);
  if ($general) {
    if ($general->{children}) {
      for my $gf (@{$general->{children}}) {
        if ($gf->{xmlname} eq 'irdata') {
          $index->{"bib_ir"} = $gf->{ui_value} if $gf->{ui_value} ne '';
        }
      }
    }
  }

  # lifecycle -> metadataqualitycheck
  my $metadataqualitycheck = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0", "metadataqualitycheck", $uwm);
  if ($metadataqualitycheck) {
    $index->{"bib_mqc"} = $uwm_metadataqualitycheck{$metadataqualitycheck->{ui_value}};
  }

  # roles
  my ($roles, $contributions) = $self->_get_uwm_roles($c, $uwm);

  # $c->app->log->debug("XXXXXXXXXXXX ".$c->app->dumper($contributions));
  $index->{"uwm_roles_json"} = to_json($contributions);
  for my $r (@{$roles}) {
    push @{$index->{"bib_roles_pers_" . $r->{role}}}, trim $r->{name}   if $r->{name} && ($r->{name} ne '');
    push @{$index->{"bib_roles_corp_" . $r->{role}}}, $r->{institution} if $r->{institution} && ($r->{institution} ne '');
  }

  my $org = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0", "organization", $uwm);
  if ($org) {
    if ($org->{children}) {
      for my $orgch (@{$org->{children}}) {
        if ($orgch->{xmlname} eq 'hoschtyp') {
          $index->{"oer"} = '1' if $orgch->{ui_value} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1562801';
          push @{$index->{"object_type_id"}}, $orgch->{ui_value};
        }
      }
    }
  }

  my $curr = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization", "curriculum", $uwm);
  if ($curr) {
    if ($curr->{children}) {
      for my $currch (@{$curr->{children}}) {
        if ($currch->{xmlname} eq 'spl') {
          my $spl = $currch->{ui_value};
          $spl =~ s/http:\/\/phaidra\.univie\.ac\.at\/XML\/metadata\/lom\/V1\.0\/organization\/voc_spl\///g;
          push @{$index->{"programme_id"}}, $spl if $spl ne '';
        }
      }
    }
  }

  # reference numbers
  my $histkult = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0", "histkult", $uwm);
  if ($histkult) {
    if ($histkult->{children}) {
      for my $histkultch (@{$histkult->{children}}) {
        if ($histkultch->{xmlname} eq 'reference_number') {
          if ($histkultch->{children}) {
            my $reference = '';
            my $number    = '';
            for my $refnumch (@{$histkultch->{children}}) {
              if ($refnumch->{xmlname} eq 'reference') {
                $reference = $refnumch->{ui_value};
              }
              if ($refnumch->{xmlname} eq 'number') {
                $number = $refnumch->{ui_value};
              }
            }

            # shelfmark/signatur
            if ($reference eq 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552119') {
              push @{$index->{"bf_shelfmark"}}, $number;
            }

            # get grants
            my $referenceLabel = $uwm_funder{$reference};
            if ($referenceLabel) {
              $index->{"uwm_funding"} = $referenceLabel . ': ' . $number;
            }
            elsif ($reference eq 'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557233') {    # unspecified grant number
              $index->{"uwm_funding"} = $number;
            }

            # just index the rest, whatever that is
            push @{$index->{"_text_"}}, $number;
          }
        }
      }
    }
  }

  # digital book stuff
  my $digbook = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0", "digitalbook", $uwm);
  if ($digbook) {
    if ($digbook->{children}) {
      for my $dbf (@{$digbook->{children}}) {
        if ($dbf->{xmlname} eq 'publisher') {
          push @{$index->{"bib_publisher"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'publisherlocation') {
          push @{$index->{"bib_publisherlocation"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'name_magazine') {
          push @{$index->{"bib_journal"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'volume') {
          push @{$index->{"bib_volume"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'edition') {
          push @{$index->{"bib_edition"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'booklet') {
          push @{$index->{"bib_issue"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'from_page') {
          push @{$index->{"schema_pagestart"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'to_page') {
          push @{$index->{"schema_pageend"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'releaseyear') {
          push @{$index->{"bib_published"}}, $dbf->{ui_value} if $dbf->{ui_value} ne '';
        }
        if ($dbf->{xmlname} eq 'alephurl') {
          $dbf->{ui_value} =~ m/(AC\d+)/;
          if ($1) {
            push @{$index->{"dc_identifier"}}, $1;
          }
        }
      }
    }
  }
  unless (exists($index->{"bib_published"})) {
    for my $con (@{$contributions}) {
      if (($con->{role} eq 'aut') && exists($con->{date}) && $con->{date} ne '') {
        push @{$index->{"bib_published"}}, $con->{date};
        last;
      }
    }
  }

  my $edu = $self->_get_uwm_educational($c, $uwm);
  for my $e (@{$edu}) {
    push @{$index->{'educational_' . $e->{xmlname}}}, $e->{ui_value} if $e->{ui_value} ne '';
  }

  # "GPS"
  #<ns9:gps>13°3&apos;6&apos;&apos;E|47°47&apos;45&apos;&apos;N</ns9:gps>
  #<ns9:gps>23°12&apos;19&apos;&apos;E|35°27&apos;8&apos;&apos;N</ns9:gps>
  my $gps = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0", "gps", $uwm);

  #"ui_value": "13Â°3'6''E|47Â°47'45''N",
  if ($gps) {
    my $coord = $gps->{ui_value};
    $coord =~ s/Â//g;
    if ($coord =~ m/(\d+)°(\d+)'(\d+)''(E|W)\|(\d+)°(\d+)'(\d+)''(N|S)/g) {
      my $lon_deg  = $1;
      my $lon_min  = $2;
      my $lon_sec  = $3;
      my $lon_sign = $4;
      my $lat_deg  = $5;
      my $lat_min  = $6;
      my $lat_sec  = $7;
      my $lat_sign = $8;

      my $lon_dec = $lon_deg + ($lon_min / 60) + ($lon_sec / 3600);
      $lon_dec = -$lon_dec if $lon_sign eq 'W';

      my $lat_dec = $lat_deg + ($lat_min / 60) + ($lat_sec / 3600);
      $lat_dec = -$lat_dec if $lat_sign eq 'S';

      if ($lon_dec >= -180 and $lon_dec <= 180 and $lat_dec >= -90 and $lat_dec <= 90) {
        push @{$index->{latlon}}, "$lat_dec,$lon_dec";
      }
    }
  }

  return $res;
}

sub _get_uwm_educational {
  my ($self, $c, $uwm) = @_;

  my @edu;
  for my $n (@{$uwm}) {
    if (($n->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0') && ($n->{xmlname} eq 'educational')) {
      if (defined($n->{children})) {
        for my $n1 (@{$n->{children}}) {
          if (($n1->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0') && ($n1->{xmlname} eq 'educationals')) {
            if (defined($n1->{children})) {
              for my $n2 (@{$n1->{children}}) {
                if (($n2->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational') && ($n2->{xmlname} eq 'learningresourcetype')) {
                  push @edu, {xmlname => $n2->{xmlname}, ui_value => $educational_learningresourcetype{$n2->{ui_value}}};
                }
                if (($n2->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational') && ($n2->{xmlname} eq 'enduserrole')) {
                  push @edu, {xmlname => $n2->{xmlname}, ui_value => $educational_enduserrole{$n2->{ui_value}}};
                }
                if (($n2->{xmlns} eq 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational') && ($n2->{xmlname} eq 'context')) {
                  push @edu, {xmlname => $n2->{xmlname}, ui_value => $educational_context{$n2->{ui_value}}};
                }
              }
            }
          }
        }
      }
      last;
    }
  }

  return \@edu;
}

sub _get_uwm_roles {
  my ($self, $c, $uwm) = @_;

  my $life = $self->_find_first_uwm_node_rec($c, "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0", "lifecycle", $uwm);

  my @roles;
  my @contributions_json;
  for my $ch (@{$life->{children}}) {
    if ($ch->{xmlname} eq "contribute") {

      my %contribution_json;
      my $contribution_data_order;
      my $role;
      my @names;
      for my $n (@{$ch->{children}}) {
        if (($n->{xmlname} eq "role")) {
          if (exists($uwm_2_mods_roles{$n->{ui_value}})) {
            $role = $uwm_2_mods_roles{$n->{ui_value}};
            $contribution_json{role} = $role;
          }
          else {
            $c->app->log->error("Failed to map uwm role " . $n->{ui_value} . " to a role code.");
          }
        }
        if ($n->{xmlname} eq "date") {
          $contribution_json{date} = $n->{ui_value} if $n->{ui_value} ne '';
        }
      }
      for my $n (@{$ch->{attributes}}) {
        if ($n->{xmlname} eq 'data_order') {

          # we are going to make the hierarchy flat so multiply the higher level order value
          $contribution_data_order = $n->{ui_value} * 100;
          $contribution_json{data_order} = $n->{ui_value};
        }
      }

      if ($role) {
        for my $l1 (@{$ch->{children}}) {

          my %entity;
          my %entity_json;

          next if $l1->{xmlname} eq "role";
          next if $l1->{xmlname} eq "date";

          if ($l1->{xmlname} eq "entity") {
            my $firstname;
            my $lastname;
            my $institution;
            for my $l2 (@{$l1->{children}}) {

              next if $l2->{xmlname} eq "type";

              $entity_json{$l2->{xmlname}} = $l2->{ui_value};

              if ($l2->{xmlname} eq "firstname") {
                $firstname = $l2->{ui_value} if $l2->{ui_value} ne '';
              }
              elsif ($l2->{xmlname} eq "lastname") {
                $lastname = $l2->{ui_value} if $l2->{ui_value} ne '';
              }
              elsif ($l2->{xmlname} eq "institution") {
                $institution = $l2->{ui_value} if $l2->{ui_value} ne '';
              }
              else {
                $entity{$l2->{xmlname}} = $l2->{ui_value} if $l2->{ui_value} ne '';
              }
            }
            my $name = (defined($firstname) ? $firstname : '') . " " . (defined($lastname) ? $lastname : '');
            $entity{name}        = $name unless $name eq ' ';
            $entity{institution} = $institution if defined($institution);
            $entity{role}        = $role;
          }

          for my $n (@{$l1->{attributes}}) {
            if ($n->{xmlname} eq 'data_order') {
              $entity{data_order}      = $n->{ui_value} + $contribution_data_order;
              $entity_json{data_order} = $n->{ui_value};
            }
          }

          push @{$contribution_json{entities}}, \%entity_json;

          push @roles, \%entity if defined $role;
        }
      }

      push @contributions_json, \%contribution_json;
    }
  }

  return \@roles, \@contributions_json;
}

sub _find_first_uwm_node_rec {
  my ($self, $c, $xmlns, $xmlname, $uwm) = @_;

  my $ret;
  for my $n (@{$uwm}) {
    if (($n->{xmlname} eq $xmlname) && ($n->{xmlns} eq $xmlns)) {
      $ret = $n;
      last;
    }
    else {
      my $ch_size = defined($n->{children}) ? scalar(@{$n->{children}}) : 0;
      if ($ch_size > 0) {
        $ret = $self->_find_first_uwm_node_rec($c, $xmlns, $xmlname, $n->{children});
        last if $ret;
      }
    }
  }

  return $ret;
}

sub get_haspart_size {
  my ($self, $c, $pid, $cmodel) = @_;
  my $res = {alerts => [], status => 200};

  my $urlget = $self->_get_solrget_url($c, $cmodel);

  $urlget->query(q => "ispartof:\"$pid\"", fl => "pid", rows => "0", wt => "json");

  my $ua = Mojo::UserAgent->new;

  my $r_num = $ua->get($urlget)->result;
  my $numFound;
  if ($r_num->is_success) {
    $res->{haspartsize} = $r_num->json->{response}->{numFound};
  }
  else {
    $c->app->log->error("[$pid] error getting haspart size: " . $r_num->code . " " . $r_num->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting haspart size: " . $r_num->code . " " . $r_num->message};
  }

  return $res;
}

sub get_object_members {
  my ($self, $c, $pid, $cmodel) = @_;
  my $res = {alerts => [], status => 200};

  my $urlget        = $self->_get_solrget_url($c, $cmodel);
  my $pidunderscore = $pid;
  $pidunderscore =~ s/:/_/;
  $urlget->query(q => "ismemberof:\"$pid\"", rows => "100", sort => "pos_in_$pidunderscore asc", wt => "json");

  my $ua = Mojo::UserAgent->new;

  my $r_num = $ua->get($urlget)->result;
  my $numFound;
  if ($r_num->is_success) {
    $res->{members} = $r_num->json->{response}->{docs};
  }
  else {
    $c->app->log->error("[$pid] error getting object members: " . $r_num->code . " " . $r_num->message);
    unshift @{$res->{alerts}}, {type => 'error', msg => "error getting object members: " . $r_num->code . " " . $r_num->message};
  }

  return $res;
}

sub get_relationships {
  my ($self, $c, $pid, $cmodel) = @_;
  my $res = {alerts => [], status => 200};

  my $ua     = Mojo::UserAgent->new;
  my $urlget = $self->_get_solrget_url($c, $cmodel);

  # $c->app->log->debug("getting doc of $pid");
  my $idx = $self->get_doc_from_ua($c, $ua, $urlget, $pid);
  $idx = {} unless $idx;

  my $rels = {

    # own
    # these two are supported elsewhere, not needed here
    # hascollectionmember => [],
    # hasmember => [],
    hastrack               => [],
    references             => [],
    isbacksideof           => [],
    isthumbnailfor         => [],
    hasthumbnail           => [],
    hassuccessor           => [],
    isalternativeformatof  => [],
    isalternativeversionof => [],

    # reverse
    ispartof              => [],
    ismemberof            => [],
    isreferencedby        => [],
    hasbackside           => [],
    issuccessorof         => [],
    hasalternativeformat  => [],
    hasalternativeversion => []
  };

  # reverse only
  #'info:fedora/fedora-system:def/relations-external#hasCollectionMember'
  if ($idx->{ispartof}) {
    for my $relpid (@{$idx->{ispartof}}) {

      # $c->app->log->debug("reverse: getting doc of $relpid (of which $pid is ispartof)");
      my $d = $self->get_doc_from_ua($c, $ua, $urlget, $relpid);
      push @{$rels->{ispartof}}, $d if $d;
    }
  }

  # reverse only
  #'http://pcdm.org/models#hasMember'
  if ($idx->{ismemberof}) {
    for my $relpid (@{$idx->{ismemberof}}) {

      # $c->app->log->debug("reverse: getting doc of $relpid (of which $pid is ismemberof)");
      my $d = $self->get_doc_from_ua($c, $ua, $urlget, $relpid);
      push @{$rels->{ismemberof}}, $d if $d;
    }
  }

  #'http://purl.org/dc/terms/references'
  $self->add_indexed_and_reverse($c, $ua, $urlget, $idx, 'references', 'isreferencedby', $pid, $rels);

  #'http://phaidra.org/XML/V1.0/relations#isBackSideOf'
  $self->add_indexed_and_reverse($c, $ua, $urlget, $idx, 'isbacksideof', 'hasbackside', $pid, $rels);

  #'http://phaidra.org/XML/V1.0/relations#isThumbnailFor'
  $self->add_indexed_and_reverse($c, $ua, $urlget, $idx, 'isthumbnailfor', 'hasthumbnail', $pid, $rels);

  #'http://phaidra.univie.ac.at/XML/V1.0/relations#hasSuccessor'
  $self->add_indexed_and_reverse($c, $ua, $urlget, $idx, 'hassuccessor', 'issuccessorof', $pid, $rels);

  #'http://phaidra.org/XML/V1.0/relations#isAlternativeFormatOf'
  $self->add_indexed_and_reverse($c, $ua, $urlget, $idx, 'isalternativeformatof', 'hasalternativeformat', $pid, $rels);

  #'http://phaidra.org/XML/V1.0/relations#isAlternativeVersionOf'
  $self->add_indexed_and_reverse($c, $ua, $urlget, $idx, 'isalternativeversionof', 'hasalternativeversion', $pid, $rels);

  my @versions;
  my $versionsCheck = {
    $pid => {
      loaded  => 1,
      checked => 1
    }
  };
  for my $v (@{$rels->{hassuccessor}}) {
    push @versions, $v;
    $versionsCheck->{$v->{pid}} = {
      loaded  => 1,
      checked => 0
    };
    for my $r (@{$v->{hassuccessor}}) {
      unless ($versionsCheck->{$r}) {
        $versionsCheck->{$r} = {
          loaded  => 0,
          checked => 0
        };
      }
    }
  }
  for my $v (@{$rels->{issuccessorof}}) {
    push @versions, $v;
    $versionsCheck->{$v->{pid}} = {
      loaded  => 1,
      checked => 0
    };
    for my $r (@{$v->{issuccessorof}}) {
      unless ($versionsCheck->{$r}) {
        $versionsCheck->{$r} = {
          loaded  => 0,
          checked => 0
        };
      }
    }
  }
  $self->add_set_rec($c, $ua, $urlget, 'hassuccessor', $pid, \@versions, $versionsCheck);
  @versions        = grep defined, @versions;
  @versions        = grep {$_ ne ''} @versions;
  @versions        = sort {$a->{created} cmp $b->{created}} @versions;
  $res->{versions} = \@versions;

  my @altformats;
  my $altformatsCheck = {
    $pid => {
      loaded  => 1,
      checked => 1
    }
  };
  for my $v (@{$rels->{isalternativeformatof}}) {
    push @altformats, $v;
    $altformatsCheck->{$v->{pid}} = {
      loaded  => 1,
      checked => 0
    };
    for my $r (@{$v->{isalternativeformatof}}) {
      unless ($altformatsCheck->{$r}) {
        $altformatsCheck->{$r} = {
          loaded  => 0,
          checked => 0
        };
      }
    }
  }
  for my $v (@{$rels->{hasalternativeformat}}) {
    push @altformats, $v;
    $altformatsCheck->{$v->{pid}} = {
      loaded  => 1,
      checked => 0
    };
    for my $r (@{$v->{hasalternativeformat}}) {
      unless ($altformatsCheck->{$r}) {
        $altformatsCheck->{$r} = {
          loaded  => 0,
          checked => 0
        };
      }
    }
  }
  $self->add_set_rec($c, $ua, $urlget, 'isalternativeformatof', $pid, \@altformats, $altformatsCheck);
  $res->{alternativeformats} = \@altformats;

  my @altversions;
  my $altversionsCheck = {
    $pid => {
      loaded  => 1,
      checked => 1
    }
  };
  for my $v (@{$rels->{isalternativeversionof}}) {
    push @altversions, $v;
    $altversionsCheck->{$v->{pid}} = {
      loaded  => 1,
      checked => 0
    };
    for my $r (@{$v->{isalternativeversionof}}) {
      unless ($altversionsCheck->{$r}) {
        $altversionsCheck->{$r} = {
          loaded  => 0,
          checked => 0
        };
      }
    }
  }
  for my $v (@{$rels->{hasalternativeversion}}) {
    push @altversions, $v;
    $altversionsCheck->{$v->{pid}} = {
      loaded  => 1,
      checked => 0
    };
    for my $r (@{$v->{hasalternativeversion}}) {
      unless ($altversionsCheck->{$r}) {
        $altversionsCheck->{$r} = {
          loaded  => 0,
          checked => 0
        };
      }
    }
  }
  $self->add_set_rec($c, $ua, $urlget, 'isalternativeversionof', $pid, \@altversions, $altversionsCheck);
  $res->{alternativeversions} = \@altversions;

  $res->{relationships} = $rels;

  return $res;
}

sub add_set_rec {
  my ($self, $c, $ua, $urlget, $relationfield, $pid, $related, $relatedCheck) = @_;

  #$c->app->log->debug("$pid - $relationfield before relatedCheck: " . $c->app->dumper($relatedCheck));
  for my $relpid (keys %{$relatedCheck}) {
    unless ($relatedCheck->{$relpid}->{checked}) {
      unless ($relatedCheck->{$relpid}->{loaded}) {

        # load
        my $d = $self->get_doc_from_ua($c, $ua, $urlget, $relpid);
        push @{$related}, $d;
        $relatedCheck->{$relpid}->{loaded} = 1;

        # add found relationships
        if ($d) {
          if ($d->{$relationfield}) {
            for my $r (@{$d->{$relationfield}}) {
              unless ($relatedCheck->{$r}) {
                $relatedCheck->{$r} = {
                  loaded  => 0,
                  checked => 0
                };
              }
            }
          }
        }
      }

      # add reverse relationships
      # $c->app->log->debug("reverse: getting docs where $pid is $relationfield");
      $c->app->log->debug("for $relpid checking its REVERSE of '$relationfield'");
      $urlget->query(q => "$relationfield:\"$relpid\"", rows => "1000", wt => "json");
      my $r = $ua->get($urlget)->result;
      if ($r->is_success) {
        for my $d (@{$r->json->{response}->{docs}}) {
          unless ($relatedCheck->{$d->{pid}}) {
            $c->app->log->debug("adding " . $d->{pid} . " to related");
            push @{$related}, $d;
            $relatedCheck->{$d->{pid}} = {
              loaded  => 1,
              checked => 0
            };

            # add found relationships
            if ($d->{$relationfield}) {
              for my $r (@{$d->{$relationfield}}) {
                $c->app->log->debug($d->{pid} . " found $relationfield: " . $r);
                unless ($relatedCheck->{$r}) {
                  $relatedCheck->{$r} = {
                    loaded  => 0,
                    checked => 0
                  };
                }
              }
            }
          }
        }
      }
      else {
        $c->app->log->error("[$pid] error getting solr query[$relationfield:\"$relpid\"]: " . $r->code . " " . $r->message);
      }
      $relatedCheck->{$relpid}->{checked} = 1;
    }
  }

  #$c->app->log->debug("$pid - $relationfield after relatedCheck: " . $c->app->dumper($relatedCheck));

  for my $pidtocheck (keys %{$relatedCheck}) {
    unless ($relatedCheck->{$pidtocheck}->{checked}) {
      $self->add_set_rec($c, $ua, $urlget, 'hassuccessor', $pidtocheck, $related, $relatedCheck);
    }
  }
}

sub add_indexed_and_reverse {
  my ($self, $c, $ua, $urlget, $idx, $relationfield, $reverserelation, $pid, $rels) = @_;

  if ($idx->{$relationfield}) {

    # get doc of the related document
    for my $relpid (@{$idx->{$relationfield}}) {

      # $c->app->log->debug("getting doc of $relpid ($relationfield of $pid)");
      my $d = $self->get_doc_from_ua($c, $ua, $urlget, $relpid);
      push @{$rels->{$relationfield}}, $d if $d;
    }
  }

  # get reverse relationships
  # $c->app->log->debug("reverse: getting docs where $pid is $relationfield");
  $urlget->query(q => "$relationfield:\"$pid\"", rows => "1000", wt => "json");
  my $r = $ua->get($urlget)->result;
  if ($r->is_success) {
    for my $d (@{$r->json->{response}->{docs}}) {
      push @{$rels->{$reverserelation}}, $d;
    }
  }
  else {
    $c->app->log->error("[$pid] error getting solr query[$relationfield:\"$pid\"]: " . $r->code . " " . $r->message);
  }
  return undef;
}

sub get_doc_from_ua {
  my ($self, $c, $ua, $urlget, $pid) = @_;

  $urlget->query(q => "pid:\"$pid\"", rows => "1", wt => "json");
  my $r = $ua->get($urlget)->result;
  if ($r->is_success) {
    for my $d (@{$r->json->{response}->{docs}}) {
      return $d;
    }
  }
  else {
    $c->app->log->error("[$pid] error getting solr doc for object[$pid]: " . $r->code . " " . $r->message);
  }
}

1;
__END__
