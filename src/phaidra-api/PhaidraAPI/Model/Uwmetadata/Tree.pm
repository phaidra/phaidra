package PhaidraAPI::Model::Uwmetadata::Tree;

use strict;
use warnings;
use v5.10;
use utf8;
use base qw/Mojo::Base/;

our %tree = (
  tree => [
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 1,
          "help_id"     => "helpmeta_1",
          "hidden"      => 0,
          "input_regex" => "^o[0-9]:[0-9]+\$",
          "input_type"  => "static",
          "labels"      => {
            "de" => "Persistente Signatur",
            "en" => "Identifier",
            "it" => "Identificatore",
            "sr" => "identifikator"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "identifier",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 2,
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 2,
          "help_id"     => "helpmeta_2",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Titel",
            "en" => "Title",
            "it" => "Titolo",
            "sr" => "naslov"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "title",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 3,
          "help_id"     => "helpmeta_105",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Untertitel",
            "en" => "Subtitle",
            "it" => "Sottotitolo",
            "sr" => "podnaslov"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "subtitle",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 4,
          "help_id"     => "helpmeta_122",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "alternativer Titel",
            "en" => "Alternative Title",
            "it" => "Titolo alternativo",
            "sr" => "uporedni naslov"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "alt_title",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "Language",
          "disabled"    => 0,
          "field_order" => 5,
          "help_id"     => "helpmeta_3",
          "hidden"      => 0,
          "input_regex" => "^[a-z]+(-[A-Z]+)*\$",
          "input_type"  => "language_select",
          "labels"      => {
            "de" => "Sprache",
            "en" => "Language",
            "it" => "Lingua",
            "sr" => "jezik"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "language",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 6,
          "help_id"     => "helpmeta_4",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_textarea_lang",
          "labels"      => {
            "de" => "Beschreibung oder zus\x{e4}tzliche Angaben",
            "en" => "Description or Additional Data",
            "it" => "Descrizione",
            "sr" => "opis ili dodatni podaci"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "description",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 7,
          "help_id"     => "helpmeta_5",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Stichw\x{f6}rter",
            "en" => "Keywords",
            "it" => "Parole chiave",
            "sr" => "klju?ne re?i"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "keyword",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 8,
          "help_id"     => "helpmeta_6",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Geltungsbereich",
            "en" => "Coverage",
            "it" => "Copertura (temporale \x{96} geografica \x{96} amministrativa)",
            "sr" => "obseg"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "coverage",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 9,
          "help_id"     => "helpmeta_138",
          "hidden"      => 1,
          "input_regex" => "",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Institutional Repository",
            "en" => "Institutional Repository",
            "it" => "Archivio istituzionale",
            "sr" => "institucionalni repozitorij"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "irdata",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 1,
              "help_id"     => "helpmeta_124",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Quelle",
                "en" => "Resource",
                "it" => "Standard",
                "sr" => "izvor"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "Universit\x{e4}t Wien Objektidentifikatoren",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "VLB-Systemnummer",
                        "en" => "VLB-Systemnummer",
                        "it" => "VLB-Systemnummer",
                        "sr" => "VLB-Systemnummer"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1561316"
                    },
                    { "labels" => {
                        "de" => "HTTP/WWW",
                        "en" => "HTTP/WWW",
                        "it" => "HTTP/WWW",
                        "sr" => "HTTP/WWW"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552102"
                    },
                    { "labels" => {
                        "de" => "DOI",
                        "en" => "DOI",
                        "it" => "DOI",
                        "sr" => "DOI"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552099"
                    },
                    { "labels" => {
                        "de" => "eISSN",
                        "en" => "eISSN",
                        "it" => "eISSN"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552256"
                    },
                    { "labels" => {
                        "de" => "PI",
                        "en" => "PI",
                        "it" => "PI",
                        "sr" => "PI"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552105"
                    },
                    { "labels" => {
                        "de" => "ISMN",
                        "en" => "ISMN",
                        "it" => "ISMN",
                        "sr" => "ISMN"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552104"
                    },
                    { "labels" => {
                        "it" => "VLB-Systemnummer",
                        "sr" => "VLB-Systemnummer"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1561531"
                    },
                    { "labels" => {
                        "de" => "ISSN",
                        "en" => "ISSN",
                        "it" => "ISSN",
                        "sr" => "ISSN"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552101"
                    },
                    { "labels" => {
                        "de" => "ISBN",
                        "en" => "ISBN",
                        "it" => "ISBN",
                        "sr" => "ISBN"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552100"
                    },
                    { "labels" => {
                        "de" => "PrintISSN",
                        "en" => "PrintISSN",
                        "it" => "PrintISSN"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552255"
                    },
                    { "labels" => {
                        "de" => "URN",
                        "en" => "URN",
                        "it" => "URN",
                        "sr" => "URN"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552103"
                    },
                    { "labels" => {
                        "de" => "AC-Nummer",
                        "en" => "AC-Number",
                        "it" => "Numero-AC",
                        "sr" => "AC-broj"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_31/1552151"
                    }
                  ]
                }
              ],
              "xmlname" => "resource",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "CharacterString",
              "disabled"    => 0,
              "field_order" => 2,
              "help_id"     => "helpmeta_125",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "Identifikator",
                "en" => "Identifier",
                "it" => "Identificatore",
                "sr" => "identifikator"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "identifier",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 10,
          "help_id"     => "helpmeta_123",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Identifikatoren",
            "en" => "Identifiers",
            "it" => "Identificatori",
            "sr" => "identifikatori"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "identifiers",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 2,
      "help_id"     => "helpmeta_9",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Allgemein",
        "en" => "General",
        "it" => "Dati generali",
        "sr" => "op\x{9a}te"
      },
      "loaded" => 0,

      "mandatory" => 1,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "general",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "DateTime",
          "disabled"    => 0,
          "field_order" => 1,
          "help_id"     => "helpmeta_127",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "static",
          "labels"      => {
            "de" => "Phaidra Uploaddatum",
            "en" => "Phaidra Upload Date",
            "it" => "Data di caricamento di Phaidra",
            "sr" => "datum u?itavanja u Phaidru"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "upload_date",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 2,
          "help_id"     => "helpmeta_7",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Version",
            "en" => "Version",
            "it" => "Versione",
            "sr" => "verzija"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "version",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 3,
          "help_id"     => "helpmeta_8",
          "hidden"      => 0,
          "input_regex" => "^[0-9]+\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "Status",
            "en" => "Status",
            "it" => "Stato",
            "sr" => "status"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "LOM 2.2 Status",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/",
              "terms"       => [
                { "labels" => {
                    "de" => "Nicht verf\x{fc}gbar",
                    "en" => "Not Available",
                    "it" => "Non Disponibile",
                    "sr" => "nije prisutno"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/45"
                },
                { "labels" => {
                    "de" => "Entwurf",
                    "en" => "Draft",
                    "it" => "Bozza",
                    "sr" => "nacrt"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/43"
                },
                { "labels" => {
                    "de" => "Fertig",
                    "en" => "Complete",
                    "it" => "Completo",
                    "sr" => "kompletno"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_2/44"
                }
              ]
            }
          ],
          "xmlname" => "status",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 4,
          "help_id"     => "helpmeta_137",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Peer Reviewed",
            "en" => "Peer Reviewed",
            "it" => "Sottoposto a revisione paritaria (Peer Reviewed)",
            "sr" => "recenziran"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "peer_reviewed",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 1,
              "help_id"     => "helpmeta_12",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Rolle",
                "en" => "Role",
                "it" => "Ruolo",
                "sr" => "uloga"
              },
              "loaded" => 0,

              "mandatory" => 1,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 2.3.1 Role",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Uploader",
                        "en" => "Uploader",
                        "it" => "Uploader",
                        "sr" => "Uploader"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557146"
                    },
                    { "labels" => {
                        "de" => "AutorIn von Begleitmaterial",
                        "en" => "Writer of accompanying material",
                        "it" => "Autore del materiale allegato"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557103"
                    },
                    { "labels" => {
                        "de" => "Andere",
                        "en" => "Other",
                        "it" => "Altro",
                        "sr" => "drugo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/63"
                    },
                    { "labels" => {
                        "de" => "zugeschriebene/r AutorIn",
                        "en" => "Attributed name",
                        "it" => "Nome attribuito"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557128"
                    },
                    { "labels" => {
                        "de" => "musikalische/r LeiterIn",
                        "en" => "Musical director",
                        "it" => "Direttore musicale"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557118"
                    },
                    { "labels" => {
                        "de" => "IllustratorIn",
                        "en" => "Illustrator",
                        "it" => "Illustratore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557119"
                    },
                    { "labels" => {
                        "de" => "MetallstecherIn",
                        "en" => "Metal-engraver",
                        "it" => "Calcografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557105"
                    },
                    { "labels" => {
                        "de" => "BeurteilerIn",
                        "en" => "Judge",
                        "it" => "Giudice",
                        "sr" => "sudija"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552168"
                    },
                    { "labels" => {
                        "de" => "LibrettistIn",
                        "en" => "Librettist",
                        "it" => "Librettista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557125"
                    },
                    { "labels" => {
                        "de" => "DatenlieferantIn",
                        "en" => "Data Supplier",
                        "it" => "Fornitore dei dati",
                        "sr" => "dobavlja? podataka"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/55"
                    },
                    { "labels" => {
                        "de" => "BetreuerIn",
                        "en" => "Advisor",
                        "it" => "Consigliere",
                        "sr" => "savetnik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552167"
                    },
                    { "labels" => {
                        "de" => "BegutachterIn",
                        "en" => "Assessor",
                        "it" => "Assessor",
                        "sr" => "Assessor"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562799"
                    },
                    { "labels" => {
                        "de" => "MitbetreuerIn",
                        "en" => "Co-advisor",
                        "it" => "Co-advisor",
                        "sr" => "Co-advisor"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562800"
                    },
                    { "labels" => {
                        "de" => "AufbewahrerIn des Originals",
                        "en" => "Keeper of the original",
                        "it" => "Affidatario dell'originale",
                        "sr" => "?uvar orginala"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552155"
                    },
                    { "labels" => {
                        "de" => "InterpretIn",
                        "en" => "Interpreter",
                        "it" => "Interprete",
                        "sr" => "tuma?"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/61"
                    },
                    { "labels" => {
                        "de" => "Widmende/r",
                        "en" => "Dedicator",
                        "it" => "Dedicante"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557113"
                    },
                    { "labels" => {
                        "de" => "KartografIn",
                        "en" => "Cartographer",
                        "it" => "Cartografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557107"
                    },
                    { "labels" => {
                        "de" => "GraveurIn",
                        "en" => "Engraver",
                        "it" => "Incisore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557120"
                    },
                    { "labels" => {
                        "de" => "wissenschaftliche BeraterIn",
                        "en" => "Scientific advisor",
                        "it" => "Consulente scientifico"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557110"
                    },
                    { "labels" => {
                        "de" => "ArrangeurIn",
                        "en" => "Arranger",
                        "it" => "Arrangiatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557101"
                    },
                    { "labels" => {
                        "de" => "DissertantIn",
                        "en" => "Dissertant",
                        "it" => "Tesista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557143"
                    },
                    { "labels" => {
                        "de" => "Widmungstr\x{e4}gerIn",
                        "en" => "Dedicatee",
                        "it" => "Dedicatario"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557114"
                    },
                    { "labels" => {
                        "de" => "zweifelhafte AutorIn",
                        "en" => "Dubious author",
                        "it" => "Autore incerto"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557104"
                    },
                    { "labels" => {
                        "de" => "IngenieurIn",
                        "en" => "Engineer",
                        "it" => "Ingegnere"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557121"
                    },
                    { "labels" => {
                        "de" => "VideoanbieterIn",
                        "en" => "Videographer",
                        "it" => "Videografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557144"
                    },
                    { "labels" => {
                        "de" => "HerausgeberIn einer Sammlung",
                        "en" => "Compiler",
                        "it" => "Compilatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557108"
                    },
                    { "labels" => {
                        "de" => "KritikerIn",
                        "en" => "Reviewer",
                        "it" => "Recensore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557135"
                    },
                    { "labels" => {
                        "de" => "Eigent\x{fc}merIn",
                        "en" => "Owner",
                        "it" => "Proprietario"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557134"
                    },
                    { "labels" => {
                        "de" => "KomponistIn",
                        "en" => "Composer",
                        "it" => "Compositore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557109"
                    },
                    { "labels" => {
                        "de" => "TextbearbeiterIn",
                        "en" => "Text Processor",
                        "it" => "Estensore del testo",
                        "sr" => "tekst procesor"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/58"
                    },
                    { "labels" => {
                        "de" => "EditorIn",
                        "en" => "Editor",
                        "it" => "Curatore",
                        "sr" => "urednik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/52"
                    },
                    { "labels" => {
                        "de" => "FachexpertIn",
                        "en" => "Domain Expert",
                        "it" => "Esperto del settore",
                        "sr" => "stru?njak za domene"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/60"
                    },
                    { "labels" => {
                        "de" => "S\x{e4}ngerIn",
                        "en" => "Singer",
                        "it" => "Cantante"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557106"
                    },
                    { "labels" => {
                        "de" => "VerleiherIn des Diploms",
                        "en" => "Degree grantor",
                        "it" => "Istituzione che rilascia il titolo accademico"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557124"
                    },
                    { "labels" => {
                        "de" => "Technische/r Pr\x{fc}ferIn",
                        "en" => "Technical Inspector",
                        "it" => "Ispettore tecnico",
                        "sr" => "tehni?ki nadzornik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/56"
                    },
                    { "labels" => {
                        "de" => "ArchitektIn",
                        "en" => "Architect",
                        "it" => "Architetto"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557100"
                    },
                    { "labels" => {
                        "de" => "Technische/r UmsetzerIn",
                        "en" => "Technical Translator",
                        "it" => "Traduttore Tecnico",
                        "sr" => "tehni?ki prevodilac"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/54"
                    },
                    { "labels" => {
                        "de" => "HolzstecherIn",
                        "en" => "Wood-engraver",
                        "it" => "Xilografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557145"
                    },
                    { "labels" => {"en" => "Performer"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557130"
                    },
                    { "labels" => {
                        "de" => "VorbesitzerIn",
                        "en" => "Former owner",
                        "it" => "Precedente proprietario"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557131"
                    },
                    { "labels" => {
                        "de" => "KapellmeisterIn",
                        "en" => "Conductor",
                        "it" => "Direttore d\x{92}orchestra"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557116"
                    },
                    { "labels" => {
                        "de" => "BildhauerIn",
                        "en" => "Sculptor",
                        "it" => "Scultore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557140"
                    },
                    { "labels" => {
                        "de" => "DruckerIn",
                        "en" => "Printer",
                        "it" => "Stampatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557141"
                    },
                    { "labels" => {
                        "de" => "Film-EditorIn",
                        "en" => "Film editor",
                        "it" => "Responsabile del montaggio"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557137"
                    },
                    { "labels" => {
                        "de" => "k\x{fc}nstlerische/r LeiterIn",
                        "en" => "Artistic director",
                        "it" => "Direttore artistico"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557115"
                    },
                    { "labels" => {
                        "de" => "FotografIn",
                        "en" => "Photographer",
                        "it" => "Fotografo",
                        "sr" => "fotograf"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/10869"
                    },
                    { "labels" => {
                        "de" => "BearbeiterIn",
                        "en" => "Adapter",
                        "it" => "Adattatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557099"
                    },
                    { "labels" => {
                        "de" => "DigitalisiererIn",
                        "en" => "Digitiser",
                        "it" => "Autore della digitalizzazione",
                        "sr" => "digitalizator"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552154"
                    },
                    { "labels" => {
                        "de" => "P\x{e4}dagogische/r ExpertIn",
                        "en" => "Pedagogic Expert",
                        "it" => "Esperto pedagogico",
                        "sr" => "pedago\x{9a}ki stru?njak"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/59"
                    },
                    { "labels" => {
                        "de" => "InitiatorIn",
                        "en" => "Initiator",
                        "it" => "Iniziatore",
                        "sr" => "pokreta?"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/49"
                    },
                    { "labels" => {
                        "de" => "K\x{fc}nstlerIn",
                        "en" => "Artist",
                        "it" => "Artista",
                        "sr" => "umetnik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/10867"
                    },
                    { "labels" => {
                        "de" => "SongwriterIn",
                        "en" => "Lyricist",
                        "it" => "Paroliere"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557129"
                    },
                    { "labels" => {
                        "de" => "GrafikdesignerIn",
                        "en" => "Graphic Designer",
                        "it" => "Grafico",
                        "sr" => "grafi?ki dizajner"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/53"
                    },
                    { "labels" => {
                        "de" => "InterviewerIn",
                        "en" => "Interviewer",
                        "it" => "Intervistatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557123"
                    },
                    { "labels" => {
                        "de" => "Gr\x{c3}\x{bc}nderIn",
                        "en" => "Founder"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1562634"
                    },
                    { "labels" => {
                        "de" => "RadiererIn",
                        "en" => "Etcher",
                        "it" => "Acquafortista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557098"
                    },
                    { "labels" => {
                        "de" => "SzenentexterIn",
                        "en" => "Scenarist",
                        "it" => "Scenografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557139"
                    },
                    { "labels" => {
                        "de" => "ProduzentIn",
                        "en" => "Producer",
                        "it" => "Produttore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557132"
                    },
                    { "labels" => {
                        "de" => "AutorIn des digitalen Objekts",
                        "en" => "Author of the digital object",
                        "it" => "Autore dell'oggetto digitale",
                        "sr" => "autor digitalnog objekta"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/46"
                    },
                    { "labels" => {
                        "de" => "SchauspielerIn",
                        "en" => "Actor",
                        "it" => "Attore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557102"
                    },
                    { "labels" => {
                        "de" => "TonmeisterIn",
                        "en" => "Recording engineer",
                        "it" => "Tecnico della registrazione"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557142"
                    },
                    { "labels" => {
                        "de" => "MusikerIn",
                        "en" => "Musician",
                        "it" => "Musicista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557127"
                    },
                    { "labels" => {
                        "de" => "AutorIn des analogen Objekts",
                        "en" => "Author of the analogue object",
                        "it" => "Autore dell'oggetto  analogico",
                        "sr" => "autor analognog objekta"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1552095"
                    },
                    { "labels" => {
                        "de" => "ChoreographIn",
                        "en" => "Choreographer",
                        "it" => "Coreografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557112"
                    },
                    { "labels" => {
                        "de" => "IlluminatorIn",
                        "en" => "Illuminator",
                        "it" => "Miniatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557126"
                    },
                    { "labels" => {
                        "de" => "EvaluatorIn",
                        "en" => "Evaluator",
                        "it" => "Valutatore",
                        "sr" => "evaluator"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/51"
                    },
                    { "labels" => {
                        "de" => "HerausgeberIn",
                        "en" => "Publisher",
                        "it" => "Editore",
                        "sr" => "izdava?"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/47"
                    },
                    { "labels" => {
                        "de" => "Kameramann/frau",
                        "en" => "Cinematographer",
                        "it" => "Direttore della fotografia"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557117"
                    },
                    { "labels" => {
                        "de" => "AuftraggeberIn/StifterIn",
                        "en" => "Client/Donor",
                        "it" => "Cliente/Donatore",
                        "sr" => "klijent/primalac"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/10868"
                    },
                    { "labels" => {
                        "de" => "SounddesignerIn",
                        "en" => "Sound designer",
                        "it" => "Progettista del suono"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557133"
                    },
                    { "labels" => {
                        "de" => "WidersacherIn",
                        "en" => "Opponent",
                        "it" => "Controrelatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557111"
                    },
                    { "labels" => {
                        "de" => "AutorIn des Drehbuches",
                        "en" => "Author of screenplay",
                        "it" => "Sceneggiatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557138"
                    },
                    { "labels" => {
                        "de" => "InterviewpartnerIn",
                        "en" => "Interviewee",
                        "it" => "Intervistato"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557122"
                    },
                    { "labels" => {
                        "de" => "DissertationsbetreuerIn",
                        "en" => "Thesis advisor",
                        "it" => "Relatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_3/1557136"
                    }
                  ]
                }
              ],
              "xmlname" => "role",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "CharacterString",
              "disabled"    => 0,
              "field_order" => 2,
              "help_id"     => "helpmeta_126",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "Andere Rolle",
                "en" => "Different role",
                "it" => "Altro ruolo",
                "sr" => "razli?ita uloga"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "ext_role",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
            },
            { "cardinality" => "*",
              "children"    => [
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 1,
                  "help_id"     => "helpmeta_14",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Vorname",
                    "en" => "Firstname",
                    "it" => "Nome",
                    "sr" => " ime"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "firstname",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 2,
                  "help_id"     => "helpmeta_15",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Zuname",
                    "en" => "Lastname",
                    "it" => "Cognome",
                    "sr" => "prezime"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "lastname",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 3,
                  "help_id"     => "helpmeta_63",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Institution",
                    "en" => "Institution",
                    "it" => "Ente",
                    "sr" => "institucija"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "institution",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 4,
                  "help_id"     => "helpmeta_64",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Titel",
                    "en" => "Title",
                    "it" => "Titolo",
                    "sr" => "naslov"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "title1",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 5,
                  "help_id"     => "helpmeta_65",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Titel",
                    "en" => "Title",
                    "it" => "Titolo",
                    "sr" => "naslov"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "title2",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 6,
                  "help_id"     => "helpmeta_66",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Typ",
                    "en" => "Type",
                    "it" => "Tipo",
                    "sr" => "vrsta"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "type",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 7,
                  "help_id"     => "helpmeta_148",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Matrikelnummer",
                    "en" => "Student ID",
                    "it" => "Numero di matricola",
                    "sr" => "ID studenta"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "student_id",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 8,
                  "help_id"     => "helpmeta_154",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "ORCID",
                    "en" => "ORCID",
                    "it" => "ORCID",
                    "sr" => "ORCID"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "orcid",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9,
                  "help_id"     => "helpmeta_155",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "VIAF",
                    "en" => "VIAF",
                    "it" => "VIAF",
                    "sr" => "VIAF"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "viaf",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 10,
                  "help_id"     => "helpmeta_156",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "WDQ",
                    "en" => "WDQ",
                    "it" => "WDQ",
                    "sr" => "WDQ"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "wdq",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 11,
                  "help_id"     => "helpmeta_157",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "GND",
                    "en" => "GND",
                    "it" => "GND",
                    "sr" => "GND"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "gnd",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 12,
                  "help_id"     => "helpmeta_158",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "LCNAF",
                    "en" => "LCNAF",
                    "it" => "LCNAF",
                    "sr" => "LCNAF"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "lcnaf",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 13,
                  "help_id"     => "helpmeta_159",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "ISNI",
                    "en" => "ISNI",
                    "it" => "ISNI",
                    "sr" => "ISNI"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "isni",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                }
              ],
              "data_order"  => 0,
              "datatype"    => "Node",
              "disabled"    => 0,
              "field_order" => 3,
              "help_id"     => "helpmeta_13",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "node",
              "labels"      => {
                "de" => "Angaben zur Person",
                "en" => "Entity / Personal data",
                "it" => "Ruolo / Dati personali",
                "sr" => "entitet / li?ni podaci"
              },
              "loaded" => 0,

              "mandatory" => 1,
              "ordered"   => 1,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "entity",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "DateTime",
              "disabled"    => 0,
              "field_order" => 4,
              "help_id"     => "helpmeta_16",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_datetime",
              "labels"      => {
                "de" => "Datum",
                "en" => "Date",
                "it" => "Data",
                "sr" => "datum"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "date",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
            }
          ],
          "data_order"  => 0,
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 5,
          "help_id"     => "helpmeta_11",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Beitrag",
            "en" => "Contribute",
            "it" => "Contributo",
            "sr" => "doprineti"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 1,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "contribute",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 6,
          "help_id"     => "helpmeta_152",
          "hidden"      => 0,
          "input_regex" => "^[0-9]+\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "OpenAIRE Version Type",
            "en" => "OpenAIRE Version Type",
            "it" => "OpenAIRE Version Type",
            "sr" => "OpenAIRE Version Type"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "info-eu-repo-Version-type",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_38/",
              "terms"       => [
                { "labels" => {
                    "de" => "updatedVersion",
                    "en" => "updatedVersion",
                    "it" => "updatedVersion",
                    "sr" => "updatedVersion"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_38/1556251"
                },
                { "labels" => {
                    "de" => "acceptedVersion",
                    "en" => "acceptedVersion",
                    "it" => "acceptedVersion",
                    "sr" => "acceptedVersion"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_38/1556249"
                },
                { "labels" => {
                    "de" => "draft",
                    "en" => "draft",
                    "it" => "draft",
                    "sr" => "draft"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_38/1556247"
                },
                { "labels" => {
                    "de" => "publishedVersion",
                    "en" => "publishedVersion",
                    "it" => "publishedVersion",
                    "sr" => "publishedVersion"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_38/1556250"
                },
                { "labels" => {
                    "de" => "submittedVersion",
                    "en" => "submittedVersion",
                    "it" => "submittedVersion",
                    "sr" => "submittedVersion"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_38/1556248"
                }
              ]
            }
          ],
          "xmlname" => "infoeurepoversion",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 7,
          "help_id"     => "helpmeta_153",
          "hidden"      => 1,
          "input_regex" => "^[0-9]+\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "Metadata quality check",
            "en" => "Metadata quality check",
            "it" => "Metadata quality check",
            "sr" => "Metadata quality check"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "Metadata quality check",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_40/",
              "terms"       => [
                { "labels" => {
                    "de" => "nok",
                    "en" => "nok",
                    "it" => "nok",
                    "sr" => "nok"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_40/1557089"
                },
                { "labels" => {
                    "de" => "ok",
                    "en" => "ok",
                    "it" => "ok",
                    "sr" => "ok"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_40/1557088"
                },
                { "labels" => {
                    "de" => "todo",
                    "en" => "todo",
                    "it" => "todo",
                    "sr" => "todo"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_40/1557087"
                }
              ]
            }
          ],
          "xmlname" => "metadataqualitycheck",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 3,
      "help_id"     => "helpmeta_10",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Lebenszyklus",
        "en" => "Lifecycle",
        "it" => "Ciclo di vita",
        "sr" => "\x{9e}ivotni ciklus"
      },
      "loaded" => 0,

      "mandatory" => 1,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "lifecycle",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_23",
          "hidden"      => 0,
          "input_regex" => "^.+/.+\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Format",
            "en" => "Format",
            "it" => "Formato",
            "sr" => "format"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "format",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "FileSize",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_24",
          "hidden"      => 0,
          "input_regex" => "^[0-9]+\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Gr\x{f6}\x{df}e",
            "en" => "Size",
            "it" => "Dimensione",
            "sr" => "veli?ina"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "size",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_25",
          "hidden"      => 0,
          "input_regex" => "^https?://.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Permanenter Link",
            "en" => "Permanent Link",
            "it" => "Link permanente",
            "sr" => "trajni link"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "location",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => "*",
              "children"    => [
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "Vocabulary",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_28",
                  "hidden"      => 0,
                  "input_regex" => "^[0-9]+\$",
                  "input_type"  => "select",
                  "labels"      => {
                    "de" => "Typ",
                    "en" => "Type",
                    "it" => "Tipo",
                    "sr" => "vrsta"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang"   => "",
                  "vocabularies" => [
                    { "description" => "LOM 4.4.1.1 Type",
                      "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_4/",
                      "terms"       => [
                        { "labels" => {
                            "de" => "Betriebssystem",
                            "en" => "Operating system",
                            "it" => "Sistema operativo",
                            "sr" => "operativni sistem"
                          },
                          "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_4/64"
                        },
                        { "labels" => {
                            "de" => "Browser",
                            "en" => "Browser",
                            "it" => "Navigatore web",
                            "sr" => "pretra\x{9e}iva?"
                          },
                          "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_4/65"
                        }
                      ]
                    }
                  ],
                  "xmlname" => "type",
                  "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "Vocabulary",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_29",
                  "hidden"      => 0,
                  "input_regex" => "^[0-9]+\$",
                  "input_type"  => "select",
                  "labels"      => {
                    "de" => "Name",
                    "en" => "Name",
                    "it" => "Nome",
                    "sr" => "naziv"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang"   => "",
                  "vocabularies" => [
                    { "description" => "LOM 4.4.1.2 Name",
                      "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_5/",
                      "terms"       => [
                        { "labels" => {
                            "de" => "Mozilla Firefox",
                            "en" => "Mozilla Firefox",
                            "it" => "Mozilla Firefox",
                            "sr" => "Mozila Firefox"
                          },
                          "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_5/69"
                        },
                        { "labels" => {
                            "de" => "Mac OS X",
                            "en" => "Mac OS X",
                            "it" => "Mac OS X",
                            "sr" => "Mac OS X"
                          },
                          "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_5/67"
                        },
                        { "labels" => {
                            "de" => "Windows XP",
                            "en" => "Windows XP",
                            "it" => "Windows XP",
                            "sr" => "Windows XP"
                          },
                          "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_5/66"
                        },
                        { "labels" => {
                            "de" => "Internet Explorer",
                            "en" => "Internet Explorer",
                            "it" => "Internet Explorer",
                            "sr" => "Internet eksplorer"
                          },
                          "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement/voc_5/68"
                        }
                      ]
                    }
                  ],
                  "xmlname" => "name",
                  "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_30",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Minimal-Version",
                    "en" => "Minimum version",
                    "it" => "Versione minima",
                    "sr" => "minimalna verzija"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "minversion",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_31",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Maximal-Version",
                    "en" => "Maximum version",
                    "it" => "Versione massima",
                    "sr" => "maksimalna verzija"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "maxversion",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/requirement"
                }
              ],
              "data_order"  => "",
              "datatype"    => "Node",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_27",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "label_only",
              "labels"      => {
                "de" => "Oder-Komposit",
                "en" => "Or-Composite",
                "it" => "O-Struttura mista",
                "sr" => "logi?ki ili"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "orcomposite",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_26",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Anforderung",
            "en" => "Requirements",
            "it" => "Requisiti",
            "sr" => "zahtevi"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "requirement",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_32",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_textarea_lang",
          "labels"      => {
            "de" => "Installationshinweise",
            "en" => "Installation Guide",
            "it" => "Guida all'installazione",
            "sr" => "vodi? za instalaciju"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "installremarks",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_33",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_textarea_lang",
          "labels"      => {
            "de" => "Sonstige Anforderungen",
            "en" => "Requirements for the Use of the Object",
            "it" => "Requisiti per l'utilizzo dell'oggetto",
            "sr" => "uslovi za kori\x{9a}?enje objekta"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "otherrequirements",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Duration",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_34",
          "hidden"      => 0,
          "input_regex" => "^PT([0-9][0-9]H)?([0-9][0-9]M)?([0-9][0-9])S?\$",
          "input_type"  => "input_duration",
          "labels"      => {
            "de" => "Dauer",
            "en" => "Duration",
            "it" => "Durata",
            "sr" => "trajanje"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "duration",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 4,
      "help_id"     => "helpmeta_17",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "technische Angaben",
        "en" => "Technical Data",
        "it" => "Dati tecnici",
        "sr" => "tehni?ki podaci"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "technical",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => "*",
              "data_order"  => 0,
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 0,
              "help_id"     => "helpmeta_53",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Typ der Lehr-/Lernressource",
                "en" => "Type of Teaching and Educational Resource",
                "it" => "Tipo di risorsa didattica e pedagogica",
                "sr" => "vrsta nastavnog i obrazovnog izvora"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 1,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 5.2 Learning Resource Type",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Problemstellung",
                        "en" => "Problem Statement",
                        "it" => "Enunciato di un problema",
                        "sr" => "problem"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1700"
                    },
                    { "labels" => {
                        "de" => "Pr\x{e4}sentationsfolie",
                        "en" => "Slide",
                        "it" => "Diapositiva",
                        "sr" => "slajd"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1695"
                    },
                    { "labels" => {
                        "de" => "Abbildung",
                        "en" => "Figure",
                        "it" => "Figura",
                        "sr" => "slika"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1692"
                    },
                    { "labels" => {
                        "de" => "Fragebogen",
                        "en" => "Questionnaire",
                        "it" => "Questionario",
                        "sr" => "upitnik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1690"
                    },
                    { "labels" => {
                        "de" => "Simulation",
                        "en" => "Simulation",
                        "it" => "Simulazione",
                        "sr" => "simulacija"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1689"
                    },
                    { "labels" => {
                        "de" => "Selbsteinsch\x{e4}tzung",
                        "en" => "Self Assessment",
                        "it" => "Autovalutazione",
                        "sr" => "samoocenjivanje"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1701"
                    },
                    { "labels" => {
                        "de" => "Graphik",
                        "en" => "Graph",
                        "it" => "Grafico",
                        "sr" => "graf"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1693"
                    },
                    { "labels" => {
                        "de" => "Experiment",
                        "en" => "Experiment",
                        "it" => "Esperimento",
                        "sr" => "eksperiment"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1699"
                    },
                    { "labels" => {
                        "de" => "Pr\x{fc}fung",
                        "en" => "Exam",
                        "it" => "Esame",
                        "sr" => "ispit"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1698"
                    },
                    { "labels" => {
                        "de" => "Erz\x{e4}hlung",
                        "en" => "Narrative text",
                        "it" => "Testo narrativo",
                        "sr" => "narativni tekst"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1697"
                    },
                    { "labels" => {
                        "de" => "Inhaltsverzeichnis",
                        "en" => "Index",
                        "it" => "Indice",
                        "sr" => "indeks"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1694"
                    },
                    { "labels" => {
                        "de" => "Tabelle",
                        "en" => "Table",
                        "it" => "Tavola",
                        "sr" => "tabela"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1696"
                    },
                    { "labels" => {
                        "de" => "Diagramm",
                        "en" => "Diagram",
                        "it" => "Diagramma",
                        "sr" => "dijagram"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1691"
                    },
                    { "labels" => {
                        "de" => "Vortrag",
                        "en" => "Lecture",
                        "it" => "Conferenza",
                        "sr" => "predavanje"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1702"
                    },
                    { "labels" => {
                        "de" => "\x{dc}bung",
                        "en" => "Exercise",
                        "it" => "Esercizio",
                        "sr" => "ve\x{9e}ba"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_11/1688"
                    }
                  ]
                }
              ],
              "xmlname" => "learningresourcetype",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 1,
              "help_id"     => "helpmeta_52",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Form der Interaktivit\x{e4}t",
                "en" => "Interactivity Type",
                "it" => "Tipo di interattivit\x{e0}",
                "sr" => "vrsta interaktivnosti"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 5.1 Interactivity Type",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_10/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Aktiv",
                        "en" => "Active",
                        "it" => "Dinamica",
                        "sr" => "aktivna"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_10/1685"
                    },
                    { "labels" => {
                        "de" => "Erkl\x{e4}rend",
                        "en" => "Expositive",
                        "it" => "Descrittiva",
                        "sr" => "opisna"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_10/1686"
                    },
                    { "labels" => {
                        "de" => "Gemischt",
                        "en" => "Mixed",
                        "it" => "Mista",
                        "sr" => "me\x{9a}ana"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_10/1687"
                    }
                  ]
                }
              ],
              "xmlname" => "interactivitytype",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 2,
              "help_id"     => "helpmeta_54",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Grad der Interaktivit\x{e4}t",
                "en" => "Interactivity Level",
                "it" => "Livello di interattivit\x{e0}",
                "sr" => "nivo interaktivnosti"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 5.3 Interactivity Level",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Hoch",
                        "en" => "High",
                        "it" => "Alto",
                        "sr" => "visok"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/1706"
                    },
                    { "labels" => {
                        "de" => "Sehr niedrig",
                        "en" => "Very low",
                        "it" => "Molto bassa",
                        "sr" => "veoma nizak"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/1703"
                    },
                    { "labels" => {
                        "de" => "Mittel",
                        "en" => "Medium",
                        "it" => "Medio",
                        "sr" => "srednji"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/1705"
                    },
                    { "labels" => {
                        "de" => "Sehr hoch",
                        "en" => "Very High",
                        "it" => "Molto alto",
                        "sr" => "veoma visok"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/1707"
                    },
                    { "labels" => {
                        "de" => "Niedrig",
                        "en" => "Low",
                        "it" => "Basso",
                        "sr" => "nizak"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_12/1704"
                    }
                  ]
                }
              ],
              "xmlname" => "interactivitylevel",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 4,
              "help_id"     => "helpmeta_56",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Zielgruppe",
                "en" => "Intended End User Role",
                "it" => "Ruolo previsto per l'utente finale ",
                "sr" => "nameravana uloga krajnjeg korisnika"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 5.5 Intended End User Role",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Lehrende",
                        "en" => "Teacher",
                        "it" => "Docente",
                        "sr" => "nastavnik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1713"
                    },
                    { "labels" => {
                        "de" => "Studierende",
                        "en" => "Learner",
                        "it" => "Allievo",
                        "sr" => "u?enik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1715"
                    },
                    { "labels" => {
                        "de" => "StudienprogrammleiterIn",
                        "en" => "Manager",
                        "it" => "Gestore",
                        "sr" => "rukovodilac"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_14/1716"
                    }
                  ]
                }
              ],
              "xmlname" => "enduserrole",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 5,
              "help_id"     => "helpmeta_57",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Didaktischer Nutzungskontext",
                "en" => "Didactic Context of Use",
                "it" => "Contesto d'utilizzo didattico",
                "sr" => "didakti?ni kontekst kori\x{9a}?enja"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 5.6 Context",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Training",
                        "en" => "Training",
                        "it" => "Formazione",
                        "sr" => "obuka"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1719"
                    },
                    { "labels" => {
                        "de" => "Sonstiges",
                        "en" => "Other",
                        "it" => "Altro",
                        "sr" => "drugo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1720"
                    },
                    { "labels" => {
                        "de" => "Schule",
                        "en" => "School",
                        "it" => "Scuola",
                        "sr" => "\x{9a}kola"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1717"
                    },
                    { "labels" => {
                        "de" => "Hochschule",
                        "en" => "Higher Education",
                        "it" => "Istruzione universitaria",
                        "sr" => "visoko obrazovanje"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_15/1718"
                    }
                  ]
                }
              ],
              "xmlname" => "context",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "LangString",
              "disabled"    => 0,
              "field_order" => 6,
              "help_id"     => "helpmeta_58",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "input_text_lang",
              "labels"      => {
                "de" => "Durchnittliches Alter der Zielgruppe",
                "en" => "Typical Age Range",
                "it" => "Fascia d'et\x{e0} pi\x{f9} comune",
                "sr" => "uobi?ajeni raspon godina"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => undef,
              "xmlname"    => "agerange",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 7,
              "help_id"     => "helpmeta_59",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Schwierigkeitsgrad",
                "en" => "Difficulty Level",
                "it" => "Livello di difficolt\x{e0}",
                "sr" => "nivo te\x{9e}ine"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 5.8 Difficulty",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Mittel",
                        "en" => "Medium",
                        "it" => "Medio",
                        "sr" => "srednje"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/1723"
                    },
                    { "labels" => {
                        "de" => "Schwer",
                        "en" => "Difficult",
                        "it" => "Difficile",
                        "sr" => "te\x{9a}ko"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/1724"
                    },
                    { "labels" => {
                        "de" => "Sehr leicht",
                        "en" => "Very easy",
                        "it" => "Molto facile",
                        "sr" => "veoma lako"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/1721"
                    },
                    { "labels" => {
                        "de" => "Sehr schwer",
                        "en" => "Very difficult",
                        "it" => "Molto difficile",
                        "sr" => "veoma te\x{9a}ko"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/1725"
                    },
                    { "labels" => {
                        "de" => "Leicht",
                        "en" => "Easy",
                        "it" => "Facile",
                        "sr" => "lako"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational/voc_16/1722"
                    }
                  ]
                }
              ],
              "xmlname" => "difficulty",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Duration",
              "disabled"    => 0,
              "field_order" => 8,
              "help_id"     => "helpmeta_60",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "input_duration",
              "labels"      => {
                "de" => "Nutzungsdauer",
                "en" => "Typical Learning Time",
                "it" => "Tempo medio di utilizzo",
                "sr" => "uobi?ajeno vreme u?enja"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "learningtime",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "LangString",
              "disabled"    => 0,
              "field_order" => 9,
              "help_id"     => "helpmeta_61",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "input_textarea_lang",
              "labels"      => {
                "de" => "Beschreibung",
                "en" => "Description",
                "it" => "Note",
                "sr" => "opis"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => undef,
              "xmlname"    => "description",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "Language",
              "disabled"    => 0,
              "field_order" => 10,
              "help_id"     => "helpmeta_62",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "language_select",
              "labels"      => {
                "de" => "Sprache der Endanwendung",
                "en" => "Language",
                "it" => "Lingua",
                "sr" => "jezik"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "language",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/educational"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_51",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Didaktische Angaben",
            "en" => "Educational",
            "it" => "Ambito didattico",
            "sr" => "obrazovni podaci"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "educationals",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 5,
      "help_id"     => "helpmeta_18",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Didaktische Angaben",
        "en" => "Educational",
        "it" => "Ambito didattico",
        "sr" => "obrazovni podaci"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "educational",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 0,
          "help_id"     => "helpmeta_35",
          "hidden"      => 0,
          "input_regex" => "^Y|N\$",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Kosten",
            "en" => "Costs",
            "it" => "Costi",
            "sr" => "tro\x{9a}kovi"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "cost",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 1,
          "help_id"     => "helpmeta_36",
          "hidden"      => 0,
          "input_regex" => "^Y|N\$",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Copyright",
            "en" => "Copyright and Other Restrictions",
            "it" => "Copyright e altre limitazioni",
            "sr" => "kopirajt i druga ograni?enja"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "copyright",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "License",
          "disabled"    => 0,
          "field_order" => 2,
          "help_id"     => "helpmeta_81",
          "hidden"      => 0,
          "input_regex" => undef,
          "input_type"  => "select",
          "labels"      => {
            "de" => "Ausgew\x{e4}hlte Lizenz",
            "en" => "Licence Selected",
            "it" => "Licenza scelta",
            "sr" => "izabrana licenca"
          },
          "loaded" => 0,

          "mandatory" => 1,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "Lizenzen",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/",
              "terms"       => [
                { "labels" => {
                    "de" => "CC BY-NC-ND 3.0 Unported - Creative Commons Namensnennung - Nicht-kommerziell - Keine Bearbeitung 3.0 Unported",
                    "en" => "CC BY-NC-ND 3.0 Unported - Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported",
                    "it" => "CC BY-NC-ND 3.0 Unported - Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported",
                    "sr" => "CC BY-NC-ND 3.0 Unported - Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/33"
                },
                { "labels" => {
                    "de" => "CC BY-NC-SA 3.0 Unported - Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 3.0 Unported",
                    "en" => "CC BY-NC-SA 3.0 Unported - Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported",
                    "it" => "CC BY-NC-SA 3.0 Unported - Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported",
                    "sr" => "CC BY-NC-SA 3.0 Unported - Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/32"
                },
                { "labels" => {
                    "de" => "CC BY-SA 4.0 - Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 4.0 International",
                    "en" => "CC BY-SA 4.0 - Creative Commons Attribution-ShareAlike 4.0 International",
                    "it" => "Attribuzione - Condividi allo stesso modo 4.0 Internazionale"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/21"
                },
                { "labels" => {
                    "de" => "CC BY-SA 2.0 AT - Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 2.0 \x{d6}sterreich",
                    "en" => "CC BY-SA 2.0 AT - Creative Commons Attribution - Share Alike 2.0 Austria",
                    "it" => "CC BY-SA 2.0 AT - Creative Commons Attribuzione - Condividi allo stesso modo 2.0 Austria",
                    "sr" => "CC BY-SA 2.0 AT - Creative Commons Autorstvo - Deliti pod istim uslovima 2.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/7"
                },
                { "labels" => {
                    "de" => "CC BY-NC-SA 2.0 Generic - Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 2.0 Generic",
                    "en" => "CC BY-NC-SA 2.0 Generic - Creative Commons Attribution-NonCommercial-ShareAlike 2.0 Generic",
                    "it" => "CC BY-NC-SA 2.0 Generic - Creative Commons Attribution-NonCommercial-ShareAlike 2.0 Generic",
                    "sr" => "CC BY-NC-SA 2.0 Generic - Creative Commons Attribution-NonCommercial-ShareAlike 2.0 Generic"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/26"
                },
                { "labels" => {
                    "de" => "CC BY-NC 4.0 - Creative Commons Namensnennung - Nicht-kommerziell 4.0 International",
                    "en" => "CC BY-NC 4.0 - Creative Commons Attribution-NonCommercial 4.0 International",
                    "it" => "Attribuzione - Non commerciale 4.0 Internazionale"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/17"
                },
                { "labels" => {
                    "de" => "CC BY 2.0 AT - Creative Commons Namensnennung 2.0 \x{d6}sterreich",
                    "en" => "CC BY 2.0 AT - Creative Commons Attribution 2.0 Austria",
                    "it" => "CC BY 2.0 AT - Creative Commons Attribuzione 2.0 Austria",
                    "sr" => "CC BY 2.0 AT - Creative Commons Autorstvo 2.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/2"
                },
                { "labels" => {
                    "de" => "Keine Lizenz",
                    "en" => "No Licence",
                    "it" => "Tutti i diritti riservati",
                    "sr" => "Bez licence - direktna primena zakona"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/1"
                },
                { "labels" => {
                    "de" => "CC BY-NC-ND 4.0 - Creative Commons Namensnennung - Nicht-kommerziell - Keine Bearbeitungen 4.0 International",
                    "en" => "CC BY-NC-ND 4.0 - Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International",
                    "it" => "Attribuzione - Non commerciale - Non opere derivate 4.0 Internazionale"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/18"
                },
                { "labels" => {
                    "de" => "CC BY-NC 3.0 Unported - Creative Commons Namensnennung - Nicht kommerziell 3.0 Unported",
                    "en" => "CC BY-NC 3.0 Unported - Creative Commons Attribution-NonCommercial 3.0 Unported",
                    "it" => "CC BY-NC 3.0 Unported - Creative Commons Attribution-NonCommercial 3.0 Unported",
                    "sr" => "CC BY-NC 3.0 Unported - Creative Commons Attribution-NonCommercial 3.0 Unported"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/30"
                },
                { "labels" => {
                    "de" => "CC BY 4.0 - Creative Commons Namensnennung 4.0 International",
                    "en" => "CC BY 4.0 - Creative Commons Attribution 4.0 International",
                    "it" => "Attribuzione 4.0 Internazionale"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/16"
                },
                { "labels" => {
                    "de" => "CC BY-NC-ND 2.0 Generic - Creative Commons Namensnennung - Nicht-kommerziell - Keine Bearbeitung 2.0 Generic",
                    "en" => "CC BY-NC-ND 2.0 Generic - Creative Commons Attribution-NonCommercial-NoDerivs 2.0 Generic",
                    "it" => "CC BY-NC-ND 2.0 Generic - Creative Commons Attribution-NonCommercial-NoDerivs 2.0 Generic",
                    "sr" => "CC BY-NC-ND 2.0 Generic - Creative Commons Attribution-NonCommercial-NoDerivs 2.0 Generic"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/27"
                },
                { "labels" => {
                    "de" => "CC BY-ND 2.0 Generic - Creative Commons Namensnennung - Keine Bearbeitung 2.0 Generic",
                    "en" => "CC BY-ND 2.0 Generic - Creative Commons Attribution-NoDerivs 2.0 Generic",
                    "it" => "CC BY-ND 2.0 Generic - Creative Commons Attribution-NoDerivs 2.0 Generic",
                    "sr" => "CC BY-ND 2.0 Generic - Creative Commons Attribution-NoDerivs 2.0 Generic"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/25"
                },
                { "labels" => {
                    "de" => "CC BY 3.0 Unported - Creative Commons Namensnennung 3.0 Unported",
                    "en" => "CC BY 3.0 Unported - Creative Commons Attribution 3.0 Unported",
                    "it" => "CC BY 3.0 Unported - Creative Commons Attribution 3.0 Unported",
                    "sr" => "CC BY 3.0 Unported - Creative Commons Attribution 3.0 Unported"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/28"
                },
                { "labels" => {
                    "de" => "CC BY-ND 4.0 - Creative Commons Namensnennung - Keine Bearbeitungen 4.0 International",
                    "en" => "CC BY-ND 4.0 - Creative Commons Attribution-NoDerivs 4.0 International",
                    "it" => "Attribuzione - Non opere derivate 4.0 Internazionale"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/20"
                },
                { "labels" => {
                    "de" => "CC BY-ND 3.0 AT - Creative Commons Namensnennung - Keine Bearbeitungen 3.0 \x{d6}sterreich",
                    "en" => "CC BY-ND 3.0 AT - Creative Commons Attribution-NoDerivs 3.0 Austria",
                    "it" => "CC BY-ND 3.0 AT - Creative Commons Attribution-NoDerivs 3.0 Austria",
                    "sr" => "CC BY-ND 3.0 AT - Creative Commons Attribution-NoDerivs 3.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/14"
                },
                { "labels" => {
                    "de" => "CC BY-NC 2.0 Generic - Creative Commons Namensnennung - Nicht kommerziell 2.0 Generic",
                    "en" => "CC BY-NC 2.0 Generic - Creative Commons Attribution-NonCommercial 2.0 Generic",
                    "it" => "CC BY-NC 2.0 Generic - Creative Commons Attribution-NonCommercial 2.0 Generic",
                    "sr" => "CC BY-NC 2.0 Generic - Creative Commons Attribution-NonCommercial 2.0 Generic"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/24"
                },
                { "labels" => {
                    "de" => "CC BY 3.0 AT - Creative Commons Namensnennung 3.0 \x{d6}sterreich",
                    "en" => "CC BY 3.0 AT - Creative Commons Attribution 3.0 Austria",
                    "it" => "CC BY 3.0 AT - Creative Commons Attribution 3.0 Austria",
                    "sr" => "CC BY 3.0 AT - Creative Commons Attribution 3.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/10"
                },
                { "labels" => {
                    "de" => "CC BY-ND 3.0 Unported - Creative Commons Namensnennung - Keine Bearbeitung 3.0 Unported",
                    "en" => "CC BY-ND 3.0 Unported - Creative Commons Attribution-NoDerivs 3.0 Unported",
                    "it" => "CC BY-ND 3.0 Unported - Creative Commons Attribution-NoDerivs 3.0 Unported",
                    "sr" => "CC BY-ND 3.0 Unported - Creative Commons Attribution-NoDerivs 3.0 Unported"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/31"
                },
                { "labels" => {
                    "de" => "CC BY-NC 3.0 AT - Creative Commons Namensnennung - Keine kommerzielle Nutzung 3.0 \x{d6}sterreich",
                    "en" => "CC BY-NC 3.0 AT - Creative Commons Attribution-NonCommercial 3.0 Austria",
                    "it" => "CC BY-NC 3.0 AT - Creative Commons Attribution-NonCommercial 3.0 Austria",
                    "sr" => "CC BY-NC 3.0 AT - Creative Commons Attribution-NonCommercial 3.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/11"
                },
                { "labels" => {
                    "de" => "CC BY 2.0 Generic - Creative Commons Namensnennung 2.0 Generic",
                    "en" => "CC BY 2.0 Generic - Creative Commons Attribution 2.0 Generic",
                    "it" => "CC BY 2.0 Generic - Creative Commons Attribution 2.0 Generic",
                    "sr" => "CC BY 2.0 Generic - Creative Commons Attribution 2.0 Generic"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/22"
                },
                { "labels" => {
                    "de" => "CC BY-NC-SA 3.0 AT - Creative Commons Namensnennung - Keine kommerzielle Nutzung - Weitergabe unter gleichen Bedingungen 3.0 \x{d6}sterreich",
                    "en" => "CC BY-NC-SA 3.0 AT - Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Austria",
                    "it" => "CC BY-NC-SA 3.0 AT - Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Austria",
                    "sr" => "CC BY-NC-SA 3.0 AT - Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/13"
                },
                { "labels" => {
                    "de" => "CC BY-SA 2.0 Generic - Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 2.0 Generic",
                    "en" => "CC BY-SA 2.0 Generic - Creative Commons Attribution-ShareAlike 2.0 Generic",
                    "it" => "CC BY-SA 2.0 Generic - Creative Commons Attribution-ShareAlike 2.0 Generic",
                    "sr" => "CC BY-SA 2.0 Generic - Creative Commons Attribution-ShareAlike 2.0 Generic"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/23"
                },
                { "labels" => {
                    "de" => "CC BY-SA 3.0 Unported - Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 3.0 Unported",
                    "en" => "CC BY-SA 3.0 Unported - Creative Commons Attribution-ShareAlike 3.0 Unported",
                    "it" => "CC BY-SA 3.0 Unported - Creative Commons Attribution-ShareAlike 3.0 Unported",
                    "sr" => "CC BY-SA 3.0 Unported - Creative Commons Attribution-ShareAlike 3.0 Unported"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/29"
                },
                { "labels" => {
                    "de" => "CC BY-ND 2.0 AT - Creative Commons Namensnennung - Keine Bearbeitung 2.0 \x{d6}sterreich",
                    "en" => "CC BY-ND 2.0 AT - Creative Commons Attribution - No Derivative Works 2.0 Austria",
                    "it" => "CC BY-ND 2.0 AT - Creative Commons Attribuzione - Non opere derivate 2.0 Austria",
                    "sr" => "CC BY-ND 2.0 AT - Creative Commons Autorstvo - Bez prerada 2.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/6"
                },
                { "labels" => {
                    "de" => "CC BY-NC 2.0 AT - Creative Commons Namensnennung - Keine kommerzielle Nutzung 2.0 \x{d6}sterreich",
                    "en" => "CC BY-NC 2.0 AT - Creative Commons Attribution - Non-Commercial 2.0 Austria",
                    "it" => "CC BY-NC 2.0 AT - Creative Commons Attribuzione - Non commerciale 2.0 Austria",
                    "sr" => "CC BY-NC 2.0 AT - Creative Commons Autorstvo - Nekomercijalno 2.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/3"
                },
                { "labels" => {
                    "de" => "Public Domain Marke 1.0",
                    "en" => "Public Domain Mark 1.0",
                    "it" => "Public Domain Mark 1.0",
                    "sr" => "Public Domain Mark 1.0"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/9"
                },
                { "labels" => {
                    "de" => "CC BY-NC-ND 3.0 AT - Creative Commons Namensnennung - Keine kommerzielle Nutzung - Keine Bearbeitungen 3.0 \x{d6}sterreich",
                    "en" => "CC BY-NC-ND 3.0 AT - Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Austria",
                    "it" => "CC BY-NC-ND 3.0 AT - Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Austria",
                    "sr" => "CC BY-NC-ND 3.0 AT - Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/12"
                },
                { "labels" => {
                    "de" => "CC BY-SA 3.0 AT - Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 3.0 \x{d6}sterreich",
                    "en" => "CC BY-SA 3.0 AT - Creative Commons Attribution-ShareAlike 3.0 Austria",
                    "it" => "CC BY-SA 3.0 AT - Creative Commons Attribution-ShareAlike 3.0 Austria",
                    "sr" => "CC BY-SA 3.0 AT - Creative Commons Attribution-ShareAlike 3.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/15"
                },
                { "labels" => {
                    "de" => "GNU-Lizenz",
                    "en" => "GNU-Licence",
                    "it" => "Licenza GNU",
                    "sr" => "GNU/GPL licenca za softver "
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/8"
                },
                { "labels" => {
                    "de" => "CC BY-NC-ND 2.0 AT - Creative Commons Namensnennung - Keine kommerzielle Nutzung - Keine Bearbeitung 2.0 \x{d6}sterreich",
                    "en" => "CC BY-NC-ND 2.0 AT - Creative Commons Attribution - Non-Commercial - No Derivative Works 2.0 Austria",
                    "it" => "CC BY-NC-ND 2.0 AT - Creative Commons Attribuzione - Non commerciale - Non opere derivate 2.0 Austria",
                    "sr" => "CC BY-NC-ND 2.0 AT - Creative Commons Autorstvo - Nekomercijalno - Bez prerada 2.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/4"
                },
                { "labels" => {
                    "de" => "CC BY-NC-SA 4.0 - Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 4.0 International",
                    "en" => "CC BY-NC-SA 4.0 - Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International",
                    "it" => "Attribuzione - Non commerciale - Condividi allo stesso modo 4.0 Internazionale"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/19"
                },
                { "labels" => {
                    "de" => "CC BY-NC-SA 2.0 AT - Creative Commons Namensnennung - Keine kommerzielle Nutzung - Weitergabe unter gleichen Bedingungen 2.0 \x{d6}sterreich",
                    "en" => "CC BY-NC-SA 2.0 AT - Creative Commons Attribution - Non-Commercial - Share Alike 2.0 Austria",
                    "it" => "CC BY-NC-SA 2.0 AT - Creative Commons Attribuzione - Non commerciale - Condividi allo stesso modo 2.0 Austria",
                    "sr" => "CC BY-NC-SA 2.0 AT - Creative Commons Autorstvo - Nekomercijalno - Deliti pod istim uslovima 2.0 Austria"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/5"
                }
              ]
            }
          ],
          "xmlname" => "license",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 3,
          "help_id"     => "helpmeta_37",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_textarea_lang",
          "labels"      => {
            "de" => "Beschreibung oder zus\x{e4}tzliche Angaben",
            "en" => "Description or Additional Data",
            "it" => "Descrizione",
            "sr" => "opis ili dodatni podaci"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "description",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 4,
          "help_id"     => "helpmeta_150",
          "hidden"      => 0,
          "input_regex" => "^[0-9]+\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "OpenAIRE Access Rights",
            "en" => "OpenAIRE Access Rights",
            "it" => "OpenAIRE Access Rights",
            "sr" => "OpenAIRE Access Rights"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "info-eu-repo-AccessRights",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_36/",
              "terms"       => [
                { "labels" => {
                    "de" => "embargoedAccess",
                    "en" => "embargoedAccess",
                    "it" => "embargoedAccess",
                    "sr" => "embargoedAccess"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_36/1556225"
                },
                { "labels" => {
                    "de" => "openAccess",
                    "en" => "openAccess",
                    "it" => "openAccess",
                    "sr" => "openAccess"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_36/1556227"
                },
                { "labels" => {
                    "de" => "restrictedAccess",
                    "en" => "restrictedAccess",
                    "it" => "restrictedAccess",
                    "sr" => "restrictedAccess"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_36/1556226"
                },
                { "labels" => {
                    "de" => "closedAccess",
                    "en" => "closedAccess",
                    "it" => "closedAccess",
                    "sr" => "closedAccess"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0/voc_36/1556224"
                }
              ]
            }
          ],
          "xmlname" => "infoeurepoaccess",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "DateTime",
          "disabled"    => 0,
          "field_order" => 5,
          "help_id"     => "helpmeta_151",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "input_datetime",
          "labels"      => {
            "de" => "OpenAIRE Embargo End",
            "en" => "OpenAIRE Embargo End",
            "it" => "OpenAIRE Embargo End",
            "sr" => "OpenAIRE Embargo End"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "infoeurepoembargo",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/extended/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 6,
      "help_id"     => "helpmeta_19",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Rechte & Lizenzen",
        "en" => "Rights & Licences",
        "it" => "Diritti & Licenze",
        "sr" => "prava i licence"
      },
      "loaded" => 0,

      "mandatory" => 1,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "rights",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "children"    => [
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_39",
                  "hidden"      => 0,
                  "input_regex" => "^.+\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Vorname",
                    "en" => "Firstname",
                    "it" => "Nome",
                    "sr" => " ime"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "firstname",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_40",
                  "hidden"      => 0,
                  "input_regex" => "^.+\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Zuname",
                    "en" => "Lastname",
                    "it" => "Cognome",
                    "sr" => "prezime"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "lastname",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_67",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Institution",
                    "en" => "Institution",
                    "it" => "Ente",
                    "sr" => "institucija"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "institution",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_68",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Titel",
                    "en" => "Title",
                    "it" => "Titolo",
                    "sr" => "naslov"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "title1",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_69",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Titel",
                    "en" => "Title",
                    "it" => "Titolo",
                    "sr" => "naslov"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "title2",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_70",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Typ",
                    "en" => "Type",
                    "it" => "Tipo",
                    "sr" => "vrsta"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "type",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity"
                }
              ],
              "data_order"  => "",
              "datatype"    => "Node",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_38",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "node",
              "labels"      => {
                "de" => "Angaben zur Person",
                "en" => "Entity / Personal data",
                "it" => "Ruolo / Dati personali",
                "sr" => "entitet / li?ni podaci"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "entity",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "DateTime",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_42",
              "hidden"      => 0,
              "input_regex" => "^.+\$",
              "input_type"  => "input_datetime",
              "labels"      => {
                "de" => "Datum",
                "en" => "Date",
                "it" => "Data",
                "sr" => "datum"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "date",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "LangString",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_43",
              "hidden"      => 0,
              "input_regex" => "^.+\$",
              "input_type"  => "input_textarea_lang",
              "labels"      => {
                "de" => "Beschreibung oder zus\x{e4}tzliche Angaben",
                "en" => "Description or Additional Data",
                "it" => "Descrizione",
                "sr" => "opis ili dodatni podaci"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => undef,
              "xmlname"    => "description",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_50",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Anmerkungen",
            "en" => "Comments",
            "it" => "Commenti",
            "sr" => "napomene"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "annotations",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/annotation"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 7,
      "help_id"     => "helpmeta_21",
      "hidden"      => 1,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Anmerkungen",
        "en" => "Comments",
        "it" => "Commenti",
        "sr" => "napomene"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "annotation",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_44",
          "hidden"      => 0,
          "input_regex" => "^[0-9]+\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "Zweck",
            "en" => "Purpose",
            "it" => "Scopo",
            "sr" => "cilj"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "LOM 9.1 Purpose",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_6/",
              "terms"       => [
                { "labels" => {
                    "de" => "Disziplin",
                    "en" => "Discipline",
                    "it" => "Materia",
                    "sr" => "disciplina"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_6/70"
                }
              ]
            }
          ],
          "xmlname" => "purpose",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "ClassificationSource",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_46",
              "hidden"      => 0,
              "input_regex" => "^[0-9]+\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "Quelle",
                "en" => "Source",
                "it" => "Tipo di classificazione",
                "sr" => "Izvor"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "source",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification"
            },
            { "cardinality" => "*",
              "data_order"  => 0,
              "datatype"    => "Taxon",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_47",
              "hidden"      => 0,
              "input_regex" => "^[0-9]+\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "Pfad",
                "en" => "Path",
                "it" => "Percorso",
                "sr" => "putanja"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 1,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "taxon",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_45",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Klassifikation (Klassen,Unterklassen)",
            "en" => "Classifications (Classes, Subclasses)",
            "it" => "Classificazioni (Classi, Sottoclassi)",
            "sr" => "Klasifikacije ( klase, podklase)"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "taxonpath",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_48",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_textarea_lang",
          "labels"      => {
            "de" => "Beschreibung oder zus\x{e4}tzliche Angaben",
            "en" => "Description or Additional Data",
            "it" => "Descrizione",
            "sr" => "opis ili dodatni podaci"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "description",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification"
        },
        { "cardinality" => "*",
          "data_order"  => 0,
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_49",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Stichw\x{f6}rter",
            "en" => "Keywords",
            "it" => "Parole chiave",
            "sr" => "klju?ne re?i"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 1,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "keyword",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 8,
      "help_id"     => "helpmeta_22",
      "hidden"      => 1,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Klassifikation",
        "en" => "Classification",
        "it" => "Classificazione",
        "sr" => "Klasifikacija"
      },
      "loaded" => 0,

      "mandatory" => 1,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "classification",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 1,
          "help_id"     => "helpmeta_72",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "Publikationstyp",
            "en" => "Type of publication",
            "it" => "Tipologia pubblicazone",
            "sr" => "vrsta akademskog rada"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "LOM 10.1 Hochschulschriftentyp",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/",
              "terms"       => [
                { "labels" => {
                    "de" => "Buch",
                    "en" => "Book",
                    "it" => "Libro"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552257"
                },
                { "labels" => {
                    "de" => "Patent",
                    "en" => "Patent",
                    "it" => "Patent",
                    "sr" => "Patent"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556244"
                },
                { "labels" => {
                    "de" => "Conference Object",
                    "en" => "Conference Object",
                    "it" => "Conference Object",
                    "sr" => "Conference Object"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556237"
                },
                { "labels" => {
                    "de" => "Multimedia",
                    "en" => "Multimedia",
                    "it" => "Supporto multimediale"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552259"
                },
                { "labels" => {
                    "de" => "sonstige",
                    "en" => "other",
                    "it" => "altro"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552260"
                },
                { "labels" => {
                    "de" => "Dissertation",
                    "en" => "Dissertation",
                    "it" => "Tesi",
                    "sr" => "zavr\x{9a}ni rad"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1742"
                },
                { "labels" => {
                    "de" => "Vortragsserie (eine Person)",
                    "en" => "Lecture series (one person)",
                    "it" => "Atti di conferenza (una persona)"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552261"
                },
                { "labels" => {
                    "de" => "Artikel in Zeitschrift",
                    "en" => "Article",
                    "it" => "Articolo"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552253"
                },
                { "labels" => {
                    "de" => "Habilitationsschrift",
                    "en" => "Professorial Dissertation",
                    "it" => "Tesi magistrale",
                    "sr" => "stru?ni rad"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1743"
                },
                { "labels" => {
                    "de" => "Working Paper",
                    "en" => "Working Paper",
                    "it" => "Working Paper",
                    "sr" => "Working Paper"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556239"
                },
                { "labels" => {
                    "de" => "Review",
                    "en" => "Review",
                    "it" => "Review",
                    "sr" => "Review"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556236"
                },
                { "labels" => {
                    "de" => "Annotation",
                    "en" => "Annotation",
                    "it" => "Annotation",
                    "sr" => "Annotation"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556242"
                },
                { "labels" => {
                    "de" => "Forschungsdaten",
                    "en" => "Research Data",
                    "it" => "Dati della ricerca",
                    "sr" => "Istra\x{9e}iva?ki podaci"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1557090"
                },
                { "labels" => {
                    "de" => "Masterarbeit",
                    "en" => "Master's Dissertation",
                    "it" => "Tesi di Master",
                    "sr" => "magistarski rad"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1739"
                },
                { "labels" => {
                    "de" => "Book Part",
                    "en" => "Book Part",
                    "it" => "Book Part",
                    "sr" => "Book Part"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556235"
                },
                { "labels" => {
                    "de" => "Diplomarbeit",
                    "en" => "Diploma Dissertation",
                    "it" => "Tesi di Diploma",
                    "sr" => "diplomski rad"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1740"
                },
                { "labels" => {
                    "de" => "Preprint",
                    "en" => "Preprint",
                    "it" => "Preprint",
                    "sr" => "Preprint"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556240"
                },
                { "labels" => {
                    "de" => "Hochschulschrift",
                    "en" => "Theses",
                    "it" => "Tesi"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552258"
                },
                { "labels" => {
                    "de" => "Magisterarbeit",
                    "en" => "Master's (Austria) Dissertation",
                    "it" => "Tesi di Master (austriaco)",
                    "sr" => "master "
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1741"
                },
                { "labels" => {
                    "de" => "Bakkalaureatsarbeit",
                    "en" => "Baccalaureate Dissertation",
                    "it" => "Tesi di Baccalaureato",
                    "sr" => "doktorska disertacija"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1738"
                },
                { "labels" => {
                    "de" => "Vortrag",
                    "en" => "Lecture",
                    "it" => "Conferenza"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552262"
                },
                { "labels" => {
                    "de" => "Report",
                    "en" => "Report",
                    "it" => "Report",
                    "sr" => "Report"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556241"
                },
                { "labels" => {
                    "de" => "Beitrag im Sammelwerk",
                    "en" => "Article in collected edition",
                    "it" => "Articolo di miscellanea"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552263"
                }
              ]
            }
          ],
          "xmlname" => "hoschtyp",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "DateTime",
          "disabled"    => 0,
          "field_order" => 2,
          "help_id"     => "helpmeta_139",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_datetime",
          "labels"      => {
            "de" => "Approbationsdatum",
            "en" => "Date of approbation period",
            "it" => "Data di approvazione",
            "sr" => "datum potvr?ivanja"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "approbation_period",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Faculty",
              "disabled"    => 0,
              "field_order" => 1,
              "help_id"     => "helpmeta_74",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Fakultaet",
                "en" => "Faculty",
                "it" => "Facolt\x{e0}",
                "sr" => "fakultet"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "namespace" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/",
                  "terms"     => [
                    { "labels" => {
                        "de" => "A47: Fakultat fur Psychologie",
                        "en" => "A47: Faculty of Psychology"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A47"
                    },
                    { "labels" => {
                        "de" => "A40: Historisch-Kulturwissenschaftliche Fakultat",
                        "en" => "A40: Faculty of Historical and Cultural Studies"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A40"
                    },
                    { "labels" => {
                        "de" => "A59: Zentrum fur Sportwissenschaft und Universitatssport",
                        "en" => "A59: Centre for Sport Science and University Sports"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A59"
                    },
                    { "labels" => {
                        "de" => "A39: Fakultat fur Informatik",
                        "en" => "A39: Faculty of Computer Science"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A39"
                    },
                    { "labels" => {
                        "de" => "A32: Evangelisch-Theologische Fakultat",
                        "en" => "A32: Faculty of Protestant Theology"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A32"
                    },
                    { "labels" => {
                        "de" => "A56: Fakultat fur Mathematik",
                        "en" => "A56: Faculty of Mathematics"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A56"
                    },
                    { "labels" => {
                        "de" => "A58: Zentrum fur Translationswissenschaft",
                        "en" => "A58: Centre for Translation Studies"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A58"
                    },
                    { "labels" => {
                        "de" => "A74: Zentrum fur Molekulare Biologie",
                        "en" => "A74: Centre for Molecular Biology"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A74"
                    },
                    { "labels" => {
                        "de" => "A50: Fakultat fur Lebenswissenschaften",
                        "en" => "A50: Faculty of Life Sciences"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A50"
                    },
                    { "labels" => {
                        "de" => "A51: Fakultat fur Physik",
                        "en" => "A51: Faculty of Physics"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A51"
                    },
                    { "labels" => {
                        "de" => "A34: Rechtswissenschaftliche Fakultat",
                        "en" => "A34: Faculty of Law"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A34"
                    },
                    { "labels" => {
                        "de" => "A45: Philologisch-Kulturwissenschaftliche Fakultat",
                        "en" => "A45: Faculty of Philological and Cultural Studies"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A45"
                    },
                    { "labels" => {
                        "de" => "A53: Fakultat fur Geowissenschaften, Geographie und Astronomie",
                        "en" => "A53: Faculty of Earth Sciences, Geography and Astronomy"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A53"
                    },
                    { "labels" => {
                        "de" => "A46: Fakultat fur Philosophie und Bildungswissenschaft",
                        "en" => "A46: Faculty of Philosophy and Education"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A46"
                    },
                    { "labels" => {
                        "de" => "A60: Zentrum fur LehrerInnenbildung",
                        "en" => "A60: Centre for Teacher Education"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A60"
                    },
                    { "labels" => {
                        "de" => "A30: Katholisch-Theologische Fakultat",
                        "en" => "A30: Faculty of Catholic Theology"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A30"
                    },
                    { "labels" => {
                        "de" => "A49: Fakultat fur Sozialwissenschaften",
                        "en" => "A49: Faculty of Social Sciences"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A49"
                    },
                    { "labels" => {
                        "de" => "A37: Fakultat fur Wirtschaftswissenschaften",
                        "en" => "A37: Faculty of Business, Economics and Statistics"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A37"
                    },
                    { "labels" => {
                        "de" => "A52: Fakultat fur Chemie",
                        "en" => "A52: Faculty of Chemistry"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A52"
                    },
                    { "labels" => {
                        "de" => "Support facilities",
                        "en" => "Support facilities"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/A0"
                    },
                    { "labels" => {
                        "de" => "Please choose...",
                        "en" => "Please choose..."
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/-1"
                    }
                  ]
                }
              ],
              "xmlname" => "faculty",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Department",
              "disabled"    => 0,
              "field_order" => 2,
              "help_id"     => "helpmeta_75",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Institut",
                "en" => "Institute",
                "it" => "Istituto",
                "sr" => "institut"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "namespace" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_department/",
                  "terms"     => []
                }
              ],
              "xmlname" => "department",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 3,
          "help_id"     => "helpmeta_73",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Organisationszuordnung",
            "en" => "Organization Association",
            "it" => "Struttura",
            "sr" => "ustanova"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "orgassignment",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "SPL",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_77",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Studienprogrammleitung",
                "en" => "Study Program Direction",
                "it" => "Indicazione corso di laurea",
                "sr" => "smer studijskog programa"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "namespace" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/",
                  "terms"     => [
                    { "labels" => {"de" => "SPL 33: Ernahrungswissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/33"
                    },
                    { "labels" => {"de" => "SPL 32: Pharmazie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/32"
                    },
                    { "labels" => {"de" => "SPL 21: Politikwissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/21"
                    },
                    { "labels" => {"de" => "SPL 05: Informatik und Wirtschaftsinformatik"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/05"
                    },
                    { "labels" => {"de" => "SPL 26: Physik"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/26"
                    },
                    { "labels" => {"de" => "SPL 04: Wirtschaftswissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/04"
                    },
                    { "labels" => {"de" => "SPL 17: Theater-,  Film- und Medienwissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/17"
                    },
                    { "labels" => {"de" => "SPL 02: Evangelische Theologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/02"
                    },
                    { "labels" => {"de" => "SPL 99: besonderes Lehrangebot"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/99"
                    },
                    { "labels" => {"de" => "SPL 18: Philosophie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/18"
                    },
                    { "labels" => {"de" => "SPL 03: Rechtswissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/03"
                    },
                    { "labels" => {"de" => "SPL 30: Biologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/30"
                    },
                    { "labels" => {"de" => "SPL 16: Musikwissenschaft und Sprachwissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/16"
                    },
                    { "labels" => {"de" => "SPL 06: Agyptologie, Judaistik, Urgeschichte und Historische Archaologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/06"
                    },
                    { "labels" => {"de" => "SPL 44: Doktoratsstudium Naturwissenschaften und technische Wissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/44"
                    },
                    { "labels" => {"de" => "SPL 27: Chemie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/27"
                    },
                    { "labels" => {"de" => "SPL 25: Mathematik"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/25"
                    },
                    { "labels" => {"de" => "SPL 28: Erdwissenschaften, Meteorologie-Geophysik und Astronomie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/28"
                    },
                    { "labels" => {"de" => "SPL 01: Katholische Theologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/01"
                    },
                    { "labels" => {"de" => "SPL 40: Doktoratsstudium Sozialwissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/40"
                    },
                    { "labels" => {"de" => "SPL 14: Orientalistik, Afrikanistik, Indologie und Tibetologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/14"
                    },
                    { "labels" => {"de" => "SPL 20: Psychologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/20"
                    },
                    { "labels" => {"de" => "SPL 07: Geschichte"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/07"
                    },
                    { "labels" => {"de" => "SPL 49: LehrerInnenbildung"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/49"
                    },
                    { "labels" => {"de" => "SPL 24: Kultur- und Sozialanthropologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/24"
                    },
                    { "labels" => {"de" => "SPL 10: Deutsche Philologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/10"
                    },
                    { "labels" => {"de" => "SPL 31: Molekulare Biologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/31"
                    },
                    { "labels" => {"de" => "SPL 35: Sportwissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/35"
                    },
                    { "labels" => {"de" => "SPL 11: Romanistik"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/11"
                    },
                    { "labels" => {"de" => "SPL 48: Slawistik"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/48"
                    },
                    { "labels" => {"de" => "SPL 22: Publizistik- und Kommunikationswissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/22"
                    },
                    { "labels" => {"de" => "SPL 42: Philologisch-Kulturwissenschaftliches Doktoratsstudium"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/42"
                    },
                    { "labels" => {"de" => "SPL 08: Kunstgeschichte und Europaische Ethnologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/08"
                    },
                    { "labels" => {"de" => "SPL 46: Doktoratsstudium Psychologie und Sportwissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/46"
                    },
                    { "labels" => {"de" => "SPL 13: Finno-Ugristik, Nederlandistik, Skandinavistik und Vergleichende Literaturwissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/13"
                    },
                    { "labels" => {"de" => "SPL 23: Soziologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/23"
                    },
                    { "labels" => {"de" => "SPL 96: Zertifikatskurse"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/96"
                    },
                    { "labels" => {"de" => "SPL 29: Geographie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/29"
                    },
                    { "labels" => {"de" => "SPL 85: ZID - besondere Lehrangebote: EDV-Kurse"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/85"
                    },
                    { "labels" => {"de" => "SPL 39: Doktoratsstudium Wirtschaftswissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/39"
                    },
                    { "labels" => {"de" => "SPL 36: Doktoratsstudium Katholische Theologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/36"
                    },
                    { "labels" => {"de" => "SPL 97: Summer/Winter Schools"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/97"
                    },
                    { "labels" => {"de" => "SPL 12: Anglistik"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/12"
                    },
                    { "labels" => {"de" => "SPL 41: Historisch-Kulturwissenschaftliches Doktoratsstudium"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/41"
                    },
                    { "labels" => {"de" => "SPL 47: Doktoratsstudium Lebenswissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/47"
                    },
                    { "labels" => {"de" => "SPL 15: Ostasienwissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/15"
                    },
                    { "labels" => {"de" => "SPL 38: Doktoratsstudium Rechtswissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/38"
                    },
                    { "labels" => {"de" => "SPL 98: DoktorandInnenzentrum-Kursangebot"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/98"
                    },
                    { "labels" => {"de" => "SPL 34: Translationswissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/34"
                    },
                    { "labels" => {"de" => "SPL 45: Doktoratsstudium Geowissenschaften, Geographie und Astronomie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/45"
                    },
                    { "labels" => {"de" => "SPL 37: Doktoratsstudium Evangelische Theologie"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/37"
                    },
                    { "labels" => {"de" => "SPL 19: Bildungswissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/19"
                    },
                    { "labels" => {"de" => "SPL 43: Doktoratsstudium Philosophie und Bildungswissenschaft"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/43"
                    },
                    { "labels" => {"de" => "SPL 09: Altertumswissenschaften"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/09"
                    }
                  ]
                }
              ],
              "xmlname" => "spl",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
            },
            { "cardinality" => "*",
              "data_order"  => 0,
              "datatype"    => "Curriculum",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_78",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Studienkennzahl",
                "en" => "Study ID",
                "it" => "ID Corso di laurea ",
                "sr" => " ID studija"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 1,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "namespace" => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_kennzahl/",
                  "terms"     => []
                }
              ],
              "xmlname" => "kennzahl",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 4,
          "help_id"     => "helpmeta_76",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Studienrichtung",
            "en" => "Study",
            "it" => "Corso di laurea",
            "sr" => "studije"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "curriculum",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 5,
          "help_id"     => "helpmeta_149",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "weitere Zuordnung",
            "en" => "additional allocation",
            "it" => "ulteriore assegnazione"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "further_allocation",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 9,
      "help_id"     => "helpmeta_71",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Zuordnung",
        "en" => "Association",
        "it" => "Relazioni",
        "sr" => "ustanove"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "organization",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/lom/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_83",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Inschrift",
            "en" => "Inscription",
            "it" => "Descrizione",
            "sr" => "zapis"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "inscription",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 1,
              "help_id"     => "helpmeta_93",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Quelle",
                "en" => "Source",
                "it" => "Tipo di materiale",
                "sr" => "Izvor"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "HISTKULT Abbildungen",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Analoger Film",
                        "en" => "Analog Film",
                        "it" => "Pellicola analogica",
                        "sr" => "analogni film"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/1552150"
                    },
                    { "labels" => {
                        "de" => "Glasplattendia",
                        "en" => "Glass Plate Dia",
                        "it" => "Diapositiva su lastra di vetro",
                        "sr" => "Staklene plo?e Dia"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/1552077"
                    },
                    { "labels" => {
                        "de" => "Objekt",
                        "en" => "Object",
                        "it" => "Oggetto",
                        "sr" => "predmet"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/10910"
                    },
                    { "labels" => {
                        "de" => "Analoges Video",
                        "en" => "Analog Video",
                        "it" => "Video analogico",
                        "sr" => "analogni video"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/1552149"
                    },
                    { "labels" => {
                        "de" => "Bildtr\x{e4}ger",
                        "en" => "Image Carrier",
                        "it" => "Supporto dell'immagine",
                        "sr" => "nosilac slike"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/10911"
                    }
                  ]
                }
              ],
              "xmlname" => "resource",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 2,
              "help_id"     => "helpmeta_88",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Ma\x{df}einheit",
                "en" => "Measuring Unit",
                "it" => "Unit\x{e0} di misura",
                "sr" => "jedinica mere"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "Ma\x{df}einheiten",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "in.",
                        "en" => "in.",
                        "it" => "in.",
                        "sr" => "in."
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10882"
                    },
                    { "labels" => {
                        "de" => "m",
                        "en" => "m",
                        "it" => "m",
                        "sr" => "m"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10878"
                    },
                    { "labels" => {
                        "de" => "yd.",
                        "en" => "yd.",
                        "it" => "yd.",
                        "sr" => "yd."
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10883"
                    },
                    { "labels" => {
                        "de" => "cm",
                        "en" => "cm",
                        "it" => "cm",
                        "sr" => "cm"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10880"
                    },
                    { "labels" => {
                        "de" => "mm",
                        "en" => "mm",
                        "it" => "mm",
                        "sr" => "mm"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10881"
                    },
                    { "labels" => {
                        "de" => "km",
                        "en" => "km",
                        "it" => "km",
                        "sr" => "km"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10877"
                    },
                    { "labels" => {
                        "de" => "dm",
                        "en" => "dm",
                        "it" => "dm",
                        "sr" => "dm"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10879"
                    },
                    { "labels" => {
                        "de" => "ft.",
                        "en" => "ft.",
                        "it" => "ft"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_22/10884"
                    }
                  ]
                }
              ],
              "xmlname" => "dimension_unit",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "CharacterString",
              "disabled"    => 0,
              "field_order" => 3,
              "help_id"     => "helpmeta_85",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "L\x{e4}nge",
                "en" => "Length",
                "it" => "Lunghezza",
                "sr" => "du\x{9e}ina"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "length",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "CharacterString",
              "disabled"    => 0,
              "field_order" => 4,
              "help_id"     => "helpmeta_86",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "Breite",
                "en" => "Width",
                "it" => "Larghezza",
                "sr" => "\x{9a}irina"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "width",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "CharacterString",
              "disabled"    => 0,
              "field_order" => 5,
              "help_id"     => "helpmeta_87",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "H\x{f6}he",
                "en" => "Height",
                "it" => "Altezza",
                "sr" => "visina"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "height",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "CharacterString",
              "disabled"    => 0,
              "field_order" => 6,
              "help_id"     => "helpmeta_92",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "Durchmesser",
                "en" => "Circumference",
                "it" => "Diametro",
                "sr" => "obim"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "diameter",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            }
          ],
          "data_order"  => 0,
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_84",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Abmessungen",
            "en" => "Dimensions",
            "it" => "Dimensioni",
            "sr" => "dimenzije"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 1,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "dimensions",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
        },
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_94",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Referenz",
                "en" => "Reference",
                "it" => "Riferimento",
                "sr" => "referenca"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "HISTKULT Bezugsnummern",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "F\x{f6}rderungsnummer",
                        "en" => "Grant Number"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557233"
                    },
                    { "labels" => {
                        "de" => "UAW Signatur",
                        "en" => "UAW Signature",
                        "it" => "Firma UAW",
                        "sr" => "UAW signatura"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552144"
                    },
                    { "labels" => {
                        "de" => "UAW Signatur 2",
                        "en" => "UAW Signature 2",
                        "it" => "Firma UAW 2",
                        "sr" => "UAW signatura 2"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552145"
                    },
                    { "labels" => {
                        "de" => "URL des externen Objektes",
                        "en" => "External object URL",
                        "it" => "URL esterna dell'oggetto",
                        "sr" => "External object URL"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562604"
                    },
                    { "labels" => {
                        "de" => "Signatur",
                        "en" => "Signature",
                        "it" => "Firma",
                        "sr" => "signatura"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552119"
                    },
                    { "labels" => {
                        "de" => "Stammnummer",
                        "en" => "Serial Number",
                        "it" => "Matricola",
                        "sr" => "serijski broj"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/10917"
                    },
                    { "labels" => {
                        "de" => "RAD ID",
                        "en" => "RAD ID",
                        "it" => "RAD",
                        "sr" => "RAD ID"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552118"
                    },
                    { "labels" => {
                        "de" => "Inventarnummer",
                        "en" => "Inventory Number",
                        "it" => "Inventario",
                        "sr" => "inventarski broj"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/10885"
                    },
                    { "labels" => {
                        "de" => "F\x{f6}rderungsnummer: Bundesministerium f\x{fc}r Wissenschaft und Forschung (BMWF)",
                        "en" => "Grant Number: Bundesministerium f\x{fc}r Wissenschaft und Forschung (BMWF)",
                        "it" => "Grant Number: Bundesministerium f\x{fc}r Wissenschaft und Forschung (BMWF)",
                        "sr" => "Grant Number: Bundesministerium f\x{fc}r Wissenschaft und Forschung (BMWF)"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557091"
                    },
                    { "labels" => {
                        "de" => "F\x{f6}rderungsnummer: \x{d6}sterreichische Forschungsf\x{f6}rderungsgesellschaft mbH (FFG)",
                        "en" => "Grant Number: \x{d6}sterreichische Forschungsf\x{f6}rderungsgesellschaft mbH (FFG)",
                        "it" => "Grant Number: \x{d6}sterreichische Forschungsf\x{f6}rderungsgesellschaft mbH (FFG)",
                        "sr" => "Grant Number: \x{d6}sterreichische Forschungsf\x{f6}rderungsgesellschaft mbH (FFG)"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557096"
                    },
                    { "labels" => {
                        "de" => "Europ\x{e4}ische Kommission (FP7)",
                        "en" => "European Commission (FP7)",
                        "it" => "European Commission (FP7)",
                        "sr" => "European Commission (FP7)"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1556222"
                    },
                    { "labels" => {
                        "de" => "URL der externen Sammlung",
                        "en" => "External collection URL",
                        "it" => "URL esterna della collezione",
                        "sr" => "External collection URL"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1562603"
                    },
                    { "labels" => {
                        "de" => "F\x{f6}rderungsnummer: Wiener Wissenschafts-, Forschungs- und Technologiefonds (WWTF)",
                        "en" => "Grant Number: Vienna Science and Technology Fund (WWTF)",
                        "it" => "Grant Number: Vienna Science and Technology Fund (WWTF)",
                        "sr" => "Grant Number: Vienna Science and Technology Fund (WWTF)"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557097"
                    },
                    { "labels" => {
                        "de" => "Systematik Digitale Kunst",
                        "en" => "Taxonomy Digital Art",
                        "it" => "Tassonomia arte digitale",
                        "sr" => "taksonomija digitalna umetnost"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552147"
                    },
                    { "labels" => {
                        "de" => "Negativnummer",
                        "en" => "Negative Number",
                        "it" => "Numero negativo",
                        "sr" => "negativni broj"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/10914"
                    },
                    { "labels" => {
                        "de" => "F\x{f6}rderungsnummer: Fonds zur F\x{f6}rderung der wissenschaftlichen Forschung (FWF)",
                        "en" => "Grant Number: Austrian Science Fund (FWF)",
                        "it" => "Grant Number: Austrian Science Fund (FWF)",
                        "sr" => "Grant Number: Austrian Science Fund (FWF)"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557094"
                    },
                    { "labels" => {
                        "de" => "F\x{f6}rderungsnummer: European Science Foundation (ESF)",
                        "en" => "Grant Number: European Science Foundation (ESF)",
                        "it" => "Grant Number: European Science Foundation (ESF)",
                        "sr" => "Grant Number: European Science Foundation (ESF)"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557093"
                    },
                    { "labels" => {
                        "de" => "Glasplattendianummer",
                        "en" => "Glass Plate Dia Number",
                        "it" => "Numero Diapositive su lastra di vetro",
                        "sr" => "Broj Dia staklene plo?e"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552148"
                    },
                    { "labels" => {
                        "de" => "Europ\x{e4}ische Union (andere Programme)",
                        "en" => "European Union (other programs)",
                        "it" => "European Union (other programs)",
                        "sr" => "European Union (other programs)"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557092"
                    },
                    { "labels" => {
                        "de" => "F\x{f6}rderungsnummer: Jubil\x{e4}umsfonds der \x{f6}sterreichischen Nationalbank",
                        "en" => "Grant Number: Jubil\x{e4}umsfonds der \x{f6}sterreichischen Nationalbank",
                        "it" => "Grant Number: Jubil\x{e4}umsfonds der \x{f6}sterreichischen Nationalbank",
                        "sr" => "Grant Number: Jubil\x{e4}umsfonds der \x{f6}sterreichischen Nationalbank"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1557095"
                    },
                    { "labels" => {
                        "de" => "Abbildungsnachweis",
                        "en" => "Image Certificate",
                        "it" => "certificato dell'immagine",
                        "sr" => "sertifikat slike"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552000"
                    },
                    { "labels" => {
                        "de" => "Systematik Kasette Werk",
                        "en" => "Taxonomy Tape Work",
                        "it" => "Tassonomia opera su nastro",
                        "sr" => "taksonomija rada na traci"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552146"
                    },
                    { "labels" => {
                        "de" => "E-Theses ID",
                        "en" => "E-Theses ID",
                        "it" => "Tesi elettronica",
                        "sr" => "ID E-teze"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552137"
                    },
                    { "labels" => {
                        "de" => "UNIDAM ID",
                        "en" => "UNIDAM ID",
                        "it" => "UNIDAM ID",
                        "sr" => "UNIDAM ID"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_25/1552079"
                    }
                  ]
                }
              ],
              "xmlname" => "reference",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "CharacterString",
              "disabled"    => 0,
              "field_order" => 9999,
              "help_id"     => "helpmeta_95",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text",
              "labels"      => {
                "de" => "Nummer",
                "en" => "Number",
                "it" => "Numero",
                "sr" => "broj"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "number",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_89",
          "hidden"      => 0,
          "input_regex" => undef,
          "input_type"  => "node",
          "labels"      => {
            "de" => "Bezugsnummer",
            "en" => "Reference Number",
            "it" => "Numero di riferimento",
            "sr" => "referentni broj"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "reference_number",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_90",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "Stempel",
            "en" => "Stamp",
            "it" => "Timbro",
            "sr" => "pe?at"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "HISTKULT Stempel",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/",
              "terms"       => [
                { "labels" => {
                    "de" => "KHI Bonn (gerahmt von KHI Bonn)",
                    "en" => "KHI Bonn (gerahmt von KHI Bonn)",
                    "it" => "KHI Bonn (gerahmt von KHI Bonn)",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/1552075"
                },
                { "labels" => {
                    "de" => "Quadratstempel 1. Kunsthistorisches Institut Universit\x{e4}t Wien 1911-1938 (bzw. 1941)",
                    "en" => "Quadratstempel 1. Kunsthistorisches Institut Universit\x{e4}t Wien 1911-1938 (bzw. 1941)",
                    "it" => "Quadratstempel 1. Kunsthistorisches Institut Universit\x{e4}t Wien 1911-1938 (bzw. 1941)",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10906"
                },
                { "labels" => {
                    "de" => "Rundstempel - Schenkung Prof. V. Oberhammer",
                    "en" => "Rundstempel - Schenkung Prof. V. Oberhammer",
                    "it" => "Rundstempel - Schenkung Prof. V. Oberhammer",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10893"
                },
                { "labels" => {
                    "de" => "Rundstempel 2. Kunsthistorisches Institut der Universit\x{e4}t Wien 1920-1938 (bzw. 1941)",
                    "en" => "Rundstempel 2. Kunsthistorisches Institut der Universit\x{e4}t Wien 1920-1938 (bzw. 1941)",
                    "it" => "Rundstempel 2. Kunsthistorisches Institut der Universit\x{e4}t Wien 1920-1938 (bzw. 1941)",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10905"
                },
                { "labels" => {
                    "de" => "Rundstempel - mit Adler (neu)",
                    "en" => "Rundstempel - mit Adler (neu)",
                    "it" => "Rundstempel - mit Adler (neu)",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10899"
                },
                { "labels" => {
                    "de" => "Kunsthistorische Institut - Schenkung Prof. K. M. Swoboda",
                    "en" => "Kunsthistorische Institut - Schenkung Prof. K. M. Swoboda",
                    "it" => "Kunsthistorische Institut - Schenkung Prof. K. M. Swoboda",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10892"
                },
                { "labels" => {
                    "de" => "Hakenkreuzstempel whs. ab 1941 (neues Inventar)",
                    "en" => "Hakenkreuzstempel whs. ab 1941 (neues Inventar)",
                    "it" => "Hakenkreuzstempel whs. ab 1941 (neues Inventar)",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10904"
                },
                { "labels" => {
                    "de" => "Ovalstempel Kunsthistorisches Institut der k.k. Universit\x{e4}t Wien",
                    "en" => "Ovalstempel Kunsthistorisches Institut der k.k. Universit\x{e4}t Wien",
                    "it" => "Ovalstempel Kunsthistorisches Institut der k.k. Universit\x{e4}t Wien",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10907"
                },
                { "labels" => {
                    "de" => "Ovalstempel Kunsthistorisches Institut Universit\x{e4}t Wien",
                    "en" => "Ovalstempel Kunsthistorisches Institut Universit\x{e4}t Wien",
                    "it" => "Ovalstempel Kunsthistorisches Institut Universit\x{e4}t Wien",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10895"
                },
                { "labels" => {
                    "de" => "Rundstempel - mit Adler (Fraktur), Variante 2",
                    "en" => "Rundstempel - mit Adler (Fraktur), Variante 2",
                    "it" => "Rundstempel - mit Adler (Fraktur), Variante 2",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10901"
                },
                { "labels" => {
                    "de" => "Langstempel Kunsthistorisches Institut der Universit\x{e4}t Wien, Wien I., Dr. Karl Lueger-Ring 1, vor 1962",
                    "en" => "Langstempel Kunsthistorisches Institut der Universit\x{e4}t Wien, Wien I., Dr. Karl Lueger-Ring 1, vor 1962",
                    "it" => "Langstempel Kunsthistorisches Institut der Universit\x{e4}t Wien, Wien I., Dr. Karl Lueger-Ring 1, vor 1962",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10897"
                },
                { "labels" => {
                    "de" => "Rundstempel - mit Adler (Fraktur), Variante 3",
                    "en" => "Rundstempel - mit Adler (Fraktur), Variante 3",
                    "it" => "Rundstempel - mit Adler (Fraktur), Variante 3",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10902"
                },
                { "labels" => {
                    "de" => "Lehrapparat Universit\x{e4}t Wien",
                    "en" => "Lehrapparat Universit\x{e4}t Wien",
                    "it" => "Lehrapparat Universit\x{e4}t Wien",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10896"
                },
                { "labels" => {
                    "de" => "Kunsthistorischer Apparat der Universit\x{e4}t Wien",
                    "en" => "Kunsthistorischer Apparat der Universit\x{e4}t Wien",
                    "it" => "Kunsthistorischer Apparat der Universit\x{e4}t Wien",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10908"
                },
                { "labels" => {
                    "de" => "Ovalstempel k.k. Universit\x{e4}tbibliothek zu Wien",
                    "en" => "Ovalstempel k.k. Universit\x{e4}tbibliothek zu Wien",
                    "it" => "Ovalstempel k.k. Universit\x{e4}tbibliothek zu Wien",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10889"
                },
                { "labels" => {
                    "de" => "Langstempel Kunsthistorische Sammlungen des allerh\x{f6}chsten Kaiserhauses Direktion der Sammlungen von Waffen und kunstindustriellen Gegenst\x{e4}nden",
                    "en" => "Langstempel Kunsthistorische Sammlungen des allerh\x{f6}chsten Kaiserhauses Direktion der Sammlungen von Waffen und kunstindustriellen Gegenst\x{e4}nden",
                    "it" => "Langstempel Kunsthistorische Sammlungen des allerh\x{f6}chsten Kaiserhauses Direktion der Sammlungen von Waffen und kunstindustriellen Gegenst\x{e4}nden",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10894"
                },
                { "labels" => {
                    "de" => "\x{d6}ffentliche Hauptschule f\x{fc}r M\x{e4}dchen",
                    "en" => "\x{d6}ffentliche Hauptschule f\x{fc}r M\x{e4}dchen",
                    "it" => "\x{d6}ffentliche Hauptschule f\x{fc}r M\x{e4}dchen",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10888"
                },
                { "labels" => {
                    "de" => "Rundstempel - ohne Adler, Kunsthistorisches Institut der Universit\x{e4}t Wien",
                    "en" => "Rundstempel - ohne Adler, Kunsthistorisches Institut der Universit\x{e4}t Wien",
                    "it" => "Rundstempel - ohne Adler, Kunsthistorisches Institut der Universit\x{e4}t Wien",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10903"
                },
                { "labels" => {
                    "de" => "Aus dem Nachlass Frh. Heinrich v. Ferstel",
                    "en" => "Aus dem Nachlass Frh. Heinrich v. Ferstel",
                    "it" => "Aus dem Nachlass Frh. Heinrich v. Ferstel",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10891"
                },
                { "labels" => {
                    "de" => "Rundstempel mit Universit\x{e4}tssiegel, Institut f\x{fc}r Kunstgeschichte Universit\x{e4}t Wien, ab 2005",
                    "en" => "Rundstempel mit Universit\x{e4}tssiegel, Institut f\x{fc}r Kunstgeschichte Universit\x{e4}t Wien, ab 2005",
                    "it" => "Rundstempel mit Universit\x{e4}tssiegel, Institut f\x{fc}r Kunstgeschichte Universit\x{e4}t Wien, ab 2005",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10898"
                },
                { "labels" => {
                    "de" => "Rundstempel - mit Adler (Fraktur), Variante 1",
                    "en" => "Rundstempel - mit Adler (Fraktur), Variante 1",
                    "it" => "Rundstempel - mit Adler (Fraktur), Variante 1",
                    "sr" => ""
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_23/10900"
                }
              ]
            }
          ],
          "xmlname" => "stamp",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_91",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Notiz",
            "en" => "Note",
            "it" => "Note",
            "sr" => "bele\x{9a}ka"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "note",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "GPS",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_96",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Geogr. L\x{e4}nge und Breite",
            "en" => "Geograph. Coordinates",
            "it" => "Coordinate geogr.",
            "sr" => "geografske koordinate"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "gps",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 10,
      "help_id"     => "helpmeta_82",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Kontextuelle Angaben",
        "en" => "Contextual Allegation",
        "it" => "Dati dell'oggetto originale",
        "sr" => "detalji o objektu"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "histkult",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => "*",
          "children"    => [
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 1,
              "help_id"     => "helpmeta_121",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Digitale oder sonstige Quellen",
                "en" => "Digital or other source",
                "it" => "Tipo di materiale",
                "sr" => "digitalni ili drugi izvor"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "HISTKULT Abbildungen",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Analoger Film",
                        "en" => "Analog Film",
                        "it" => "Pellicola analogica",
                        "sr" => "analogni film"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/1552150"
                    },
                    { "labels" => {
                        "de" => "Glasplattendia",
                        "en" => "Glass Plate Dia",
                        "it" => "Diapositiva su lastra di vetro",
                        "sr" => "Staklene plo?e Dia"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/1552077"
                    },
                    { "labels" => {
                        "de" => "Objekt",
                        "en" => "Object",
                        "it" => "Oggetto",
                        "sr" => "predmet"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/10910"
                    },
                    { "labels" => {
                        "de" => "Analoges Video",
                        "en" => "Analog Video",
                        "it" => "Video analogico",
                        "sr" => "analogni video"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/1552149"
                    },
                    { "labels" => {
                        "de" => "Bildtr\x{e4}ger",
                        "en" => "Image Carrier",
                        "it" => "Supporto dell'immagine",
                        "sr" => "nosilac slike"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/10911"
                    }
                  ]
                }
              ],
              "xmlname" => "resource",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "LangString",
              "disabled"    => 0,
              "field_order" => 2,
              "help_id"     => "helpmeta_119",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_textarea_lang",
              "labels"      => {
                "de" => "Angaben zur Quelle",
                "en" => "Details about the Source",
                "it" => "Note",
                "sr" => "detalji o izvoru"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => undef,
              "xmlname"    => "comment",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "Vocabulary",
              "disabled"    => 0,
              "field_order" => 3,
              "help_id"     => "helpmeta_107",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "select",
              "labels"      => {
                "de" => "Rolle",
                "en" => "Role",
                "it" => "Ruolo",
                "sr" => "uloga"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang"   => "",
              "vocabularies" => [
                { "description" => "LOM 2.3.1 Role",
                  "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/",
                  "terms"       => [
                    { "labels" => {
                        "de" => "Uploader",
                        "en" => "Uploader",
                        "it" => "Uploader",
                        "sr" => "Uploader"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557146"
                    },
                    { "labels" => {
                        "de" => "AutorIn von Begleitmaterial",
                        "en" => "Writer of accompanying material",
                        "it" => "Autore del materiale allegato"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557103"
                    },
                    { "labels" => {
                        "de" => "Andere",
                        "en" => "Other",
                        "it" => "Altro",
                        "sr" => "drugo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/63"
                    },
                    { "labels" => {
                        "de" => "zugeschriebene/r AutorIn",
                        "en" => "Attributed name",
                        "it" => "Nome attribuito"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557128"
                    },
                    { "labels" => {
                        "de" => "musikalische/r LeiterIn",
                        "en" => "Musical director",
                        "it" => "Direttore musicale"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557118"
                    },
                    { "labels" => {
                        "de" => "IllustratorIn",
                        "en" => "Illustrator",
                        "it" => "Illustratore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557119"
                    },
                    { "labels" => {
                        "de" => "MetallstecherIn",
                        "en" => "Metal-engraver",
                        "it" => "Calcografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557105"
                    },
                    { "labels" => {
                        "de" => "BeurteilerIn/RichterIn",
                        "en" => "Judge",
                        "it" => "Giudice",
                        "sr" => "sudija"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1552168"
                    },
                    { "labels" => {
                        "de" => "LibrettistIn",
                        "en" => "Librettist",
                        "it" => "Librettista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557125"
                    },
                    { "labels" => {
                        "de" => "DatenlieferantIn",
                        "en" => "Data Supplier",
                        "it" => "Fornitore dei dati",
                        "sr" => "dobavlja? podataka"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/55"
                    },
                    { "labels" => {
                        "de" => "BetreuerIn",
                        "en" => "Advisor",
                        "it" => "Consigliere",
                        "sr" => "savetnik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1552167"
                    },
                    { "labels" => {
                        "de" => "AufbewahrerIn des Originals",
                        "en" => "Keeper of the original",
                        "it" => "Affidatario dell'originale",
                        "sr" => "?uvar orginala"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1552155"
                    },
                    { "labels" => {
                        "de" => "InterpretIn",
                        "en" => "Interpreter",
                        "it" => "Interprete",
                        "sr" => "tuma?"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/61"
                    },
                    { "labels" => {
                        "de" => "Widmende/r",
                        "en" => "Dedicator",
                        "it" => "Dedicante"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557113"
                    },
                    { "labels" => {
                        "de" => "KartografIn",
                        "en" => "Cartographer",
                        "it" => "Cartografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557107"
                    },
                    { "labels" => {
                        "de" => "GraveurIn",
                        "en" => "Engraver",
                        "it" => "Incisore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557120"
                    },
                    { "labels" => {
                        "de" => "wissenschaftliche BeraterIn",
                        "en" => "Scientific advisor",
                        "it" => "Consulente scientifico"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557110"
                    },
                    { "labels" => {
                        "de" => "ArrangeurIn",
                        "en" => "Arranger",
                        "it" => "Arrangiatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557101"
                    },
                    { "labels" => {
                        "de" => "DissertantIn",
                        "en" => "Dissertant",
                        "it" => "Tesista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557143"
                    },
                    { "labels" => {
                        "de" => "Widmungstr\x{e4}gerIn",
                        "en" => "Dedicatee",
                        "it" => "Dedicatario"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557114"
                    },
                    { "labels" => {
                        "de" => "zweifelhafte AutorIn",
                        "en" => "Dubious author",
                        "it" => "Autore incerto"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557104"
                    },
                    { "labels" => {
                        "de" => "IngenieurIn",
                        "en" => "Engineer",
                        "it" => "Ingegnere"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557121"
                    },
                    { "labels" => {
                        "de" => "VideoanbieterIn",
                        "en" => "Videographer",
                        "it" => "Videografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557144"
                    },
                    { "labels" => {
                        "de" => "HerausgeberIn einer Sammlung",
                        "en" => "Compiler",
                        "it" => "Compilatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557108"
                    },
                    { "labels" => {
                        "de" => "KritikerIn",
                        "en" => "Reviewer",
                        "it" => "Recensore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557135"
                    },
                    { "labels" => {
                        "de" => "Eigent\x{fc}merIn",
                        "en" => "Owner",
                        "it" => "Proprietario"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557134"
                    },
                    { "labels" => {
                        "de" => "KomponistIn",
                        "en" => "Composer",
                        "it" => "Compositore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557109"
                    },
                    { "labels" => {
                        "de" => "TextbearbeiterIn",
                        "en" => "Text Processor",
                        "it" => "Estensore del testo",
                        "sr" => "tekst procesor"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/58"
                    },
                    { "labels" => {
                        "de" => "EditorIn",
                        "en" => "Editor",
                        "it" => "Curatore",
                        "sr" => "urednik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/52"
                    },
                    { "labels" => {
                        "de" => "FachexpertIn",
                        "en" => "Domain Expert",
                        "it" => "Esperto del settore",
                        "sr" => "stru?njak za domene"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/60"
                    },
                    { "labels" => {
                        "de" => "S\x{e4}ngerIn",
                        "en" => "Singer",
                        "it" => "Cantante"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557106"
                    },
                    { "labels" => {
                        "de" => "VerleiherIn des Diploms",
                        "en" => "Degree grantor",
                        "it" => "Istituzione che rilascia il titolo accademico"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557124"
                    },
                    { "labels" => {
                        "de" => "Technische/r Pr\x{fc}ferIn",
                        "en" => "Technical Inspector",
                        "it" => "Ispettore tecnico",
                        "sr" => "tehni?ki nadzornik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/56"
                    },
                    { "labels" => {
                        "de" => "ArchitektIn",
                        "en" => "Architect",
                        "it" => "Architetto"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557100"
                    },
                    { "labels" => {
                        "de" => "Technische/r UmsetzerIn",
                        "en" => "Technical Translator",
                        "it" => "Traduttore Tecnico",
                        "sr" => "tehni?ki prevodilac"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/54"
                    },
                    { "labels" => {
                        "de" => "HolzstecherIn",
                        "en" => "Wood-engraver",
                        "it" => "Xilografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557145"
                    },
                    { "labels" => {"en" => "Performer"},
                      "uri"    => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557130"
                    },
                    { "labels" => {
                        "de" => "VorbesitzerIn",
                        "en" => "Former owner",
                        "it" => "Precedente proprietario"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557131"
                    },
                    { "labels" => {
                        "de" => "KapellmeisterIn",
                        "en" => "Conductor",
                        "it" => "Direttore d\x{92}orchestra"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557116"
                    },
                    { "labels" => {
                        "de" => "BildhauerIn",
                        "en" => "Sculptor",
                        "it" => "Scultore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557140"
                    },
                    { "labels" => {
                        "de" => "DruckerIn",
                        "en" => "Printer",
                        "it" => "Stampatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557141"
                    },
                    { "labels" => {
                        "de" => "Film-EditorIn",
                        "en" => "Film editor",
                        "it" => "Responsabile del montaggio"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557137"
                    },
                    { "labels" => {
                        "de" => "k\x{fc}nstlerische/r LeiterIn",
                        "en" => "Artistic director",
                        "it" => "Direttore artistico"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557115"
                    },
                    { "labels" => {
                        "de" => "FotografIn",
                        "en" => "Photographer",
                        "it" => "Fotografo",
                        "sr" => "fotograf"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/10869"
                    },
                    { "labels" => {
                        "de" => "BearbeiterIn",
                        "en" => "Adapter",
                        "it" => "Adattatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557099"
                    },
                    { "labels" => {
                        "de" => "DigitalisiererIn",
                        "en" => "Digitiser",
                        "it" => "Autore della digitalizzazione",
                        "sr" => "digitalizator"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1552154"
                    },
                    { "labels" => {
                        "de" => "P\x{e4}dagogische/r ExpertIn",
                        "en" => "Pedagogic Expert",
                        "it" => "Esperto pedagogico",
                        "sr" => "pedago\x{9a}ki stru?njak"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/59"
                    },
                    { "labels" => {
                        "de" => "InitiatorIn",
                        "en" => "Initiator",
                        "it" => "Iniziatore",
                        "sr" => "pokreta?"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/49"
                    },
                    { "labels" => {
                        "de" => "K\x{fc}nstlerIn",
                        "en" => "Artist",
                        "it" => "Artista",
                        "sr" => "umetnik"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/10867"
                    },
                    { "labels" => {
                        "de" => "SongwriterIn",
                        "en" => "Lyricist",
                        "it" => "Paroliere"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557129"
                    },
                    { "labels" => {
                        "de" => "GrafikdesignerIn",
                        "en" => "Graphic Designer",
                        "it" => "Grafico",
                        "sr" => "grafi?ki dizajner"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/53"
                    },
                    { "labels" => {
                        "de" => "InterviewerIn",
                        "en" => "Interviewer",
                        "it" => "Intervistatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557123"
                    },
                    { "labels" => {
                        "de" => "Gr\x{c3}\x{bc}nderIn",
                        "en" => "Founder"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1562634"
                    },
                    { "labels" => {
                        "de" => "RadiererIn",
                        "en" => "Etcher",
                        "it" => "Acquafortista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557098"
                    },
                    { "labels" => {
                        "de" => "SzenentexterIn",
                        "en" => "Scenarist",
                        "it" => "Scenografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557139"
                    },
                    { "labels" => {
                        "de" => "ProduzentIn",
                        "en" => "Producer",
                        "it" => "Produttore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557132"
                    },
                    { "labels" => {
                        "de" => "AutorIn des digitalen Objekts",
                        "en" => "Author of the digital object",
                        "it" => "Autore dell'oggetto digitale",
                        "sr" => "autor digitalnog objekta"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/46"
                    },
                    { "labels" => {
                        "de" => "SchauspielerIn",
                        "en" => "Actor",
                        "it" => "Attore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557102"
                    },
                    { "labels" => {
                        "de" => "TonmeisterIn",
                        "en" => "Recording engineer",
                        "it" => "Tecnico della registrazione"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557142"
                    },
                    { "labels" => {
                        "de" => "MusikerIn",
                        "en" => "Musician",
                        "it" => "Musicista"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557127"
                    },
                    { "labels" => {
                        "de" => "AutorIn des analogen Objekts",
                        "en" => "Author of the analogue object",
                        "it" => "Autore dell'oggetto  analogico",
                        "sr" => "autor analognog objekta"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1552095"
                    },
                    { "labels" => {
                        "de" => "ChoreographIn",
                        "en" => "Choreographer",
                        "it" => "Coreografo"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557112"
                    },
                    { "labels" => {
                        "de" => "IlluminatorIn",
                        "en" => "Illuminator",
                        "it" => "Miniatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557126"
                    },
                    { "labels" => {
                        "de" => "EvaluatorIn",
                        "en" => "Evaluator",
                        "it" => "Valutatore",
                        "sr" => "evaluator"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/51"
                    },
                    { "labels" => {
                        "de" => "HerausgeberIn",
                        "en" => "Publisher",
                        "it" => "Editore",
                        "sr" => "izdava?"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/47"
                    },
                    { "labels" => {
                        "de" => "Kameramann/frau",
                        "en" => "Cinematographer",
                        "it" => "Direttore della fotografia"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557117"
                    },
                    { "labels" => {
                        "de" => "AuftraggeberIn/StifterIn",
                        "en" => "Client/Donor",
                        "it" => "Cliente/Donatore",
                        "sr" => "klijent/primalac"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/10868"
                    },
                    { "labels" => {
                        "de" => "SounddesignerIn",
                        "en" => "Sound designer",
                        "it" => "Progettista del suono"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557133"
                    },
                    { "labels" => {
                        "de" => "WidersacherIn",
                        "en" => "Opponent",
                        "it" => "Controrelatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557111"
                    },
                    { "labels" => {
                        "de" => "AutorIn des Drehbuches",
                        "en" => "Author of screenplay",
                        "it" => "Sceneggiatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557138"
                    },
                    { "labels" => {
                        "de" => "InterviewpartnerIn",
                        "en" => "Interviewee",
                        "it" => "Intervistato"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557122"
                    },
                    { "labels" => {
                        "de" => "DissertationsbetreuerIn",
                        "en" => "Thesis advisor",
                        "it" => "Relatore"
                      },
                      "uri" => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_3/1557136"
                    }
                  ]
                }
              ],
              "xmlname" => "role",
              "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            },
            { "cardinality" => "*",
              "children"    => [
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_108",
                  "hidden"      => 0,
                  "input_regex" => "^.+\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Vorname",
                    "en" => "Firstname",
                    "it" => "Nome",
                    "sr" => " ime"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "firstname",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_109",
                  "hidden"      => 0,
                  "input_regex" => "^.+\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Zuname",
                    "en" => "Lastname",
                    "it" => "Cognome",
                    "sr" => "prezime"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "lastname",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_110",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Titel",
                    "en" => "Title",
                    "it" => "Titolo",
                    "sr" => "naslov"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "title1",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_111",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Titel",
                    "en" => "Title",
                    "it" => "Titolo",
                    "sr" => "naslov"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "title2",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_112",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Typ",
                    "en" => "Type",
                    "it" => "Tipo",
                    "sr" => "vrsta"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "type",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity"
                },
                { "cardinality" => 1,
                  "data_order"  => "",
                  "datatype"    => "CharacterString",
                  "disabled"    => 0,
                  "field_order" => 9999,
                  "help_id"     => "helpmeta_113",
                  "hidden"      => 0,
                  "input_regex" => "^.*\$",
                  "input_type"  => "input_text",
                  "labels"      => {
                    "de" => "Institution",
                    "en" => "Institution",
                    "it" => "Ente",
                    "sr" => "institucija"
                  },
                  "loaded" => 0,

                  "mandatory" => 0,
                  "ordered"   => 0,
                  "ui_value"  => "",

                  "value_lang" => "",
                  "xmlname"    => "institution",
                  "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity"
                }
              ],
              "data_order"  => 0,
              "datatype"    => "Node",
              "disabled"    => 0,
              "field_order" => 4,
              "help_id"     => "helpmeta_106",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "node",
              "labels"      => {
                "de" => "Angaben zur Person oder Institution",
                "en" => "Personal or Institutional Data",
                "it" => "Dati personali o istituzionali ",
                "sr" => "li?ni ili institucionalni podaci"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 1,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "entity",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "DateTime",
              "disabled"    => 0,
              "field_order" => 5,
              "help_id"     => "helpmeta_117",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "input_datetime",
              "labels"      => {
                "de" => "Datum von",
                "en" => "Date from",
                "it" => "Data a partire da",
                "sr" => "datum od"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "date_from",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            },
            { "cardinality" => 1,
              "data_order"  => "",
              "datatype"    => "DateTime",
              "disabled"    => 0,
              "field_order" => 6,
              "help_id"     => "helpmeta_118",
              "hidden"      => 0,
              "input_regex" => "",
              "input_type"  => "input_datetime",
              "labels"      => {
                "de" => "Datum bis",
                "en" => "Date until",
                "it" => "Data fino a",
                "sr" => "datum do"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => "",
              "xmlname"    => "date_to",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "LangString",
              "disabled"    => 0,
              "field_order" => 7,
              "help_id"     => "helpmeta_116",
              "hidden"      => 0,
              "input_regex" => ".*",
              "input_type"  => "input_text_lang",
              "labels"      => {
                "de" => "Zeitliche Abdeckung",
                "en" => "Time Coverage",
                "it" => "Periodo",
                "sr" => "vremenska pokrivenost"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => undef,
              "xmlname"    => "chronological",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            },
            { "cardinality" => "*",
              "data_order"  => "",
              "datatype"    => "LangString",
              "disabled"    => 0,
              "field_order" => 8,
              "help_id"     => "helpmeta_120",
              "hidden"      => 0,
              "input_regex" => "^.*\$",
              "input_type"  => "input_text_lang",
              "labels"      => {
                "de" => "Standort",
                "en" => "Location",
                "it" => "Collocazione",
                "sr" => "mesto"
              },
              "loaded" => 0,

              "mandatory" => 0,
              "ordered"   => 0,
              "ui_value"  => "",

              "value_lang" => undef,
              "xmlname"    => "location",
              "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
            }
          ],
          "data_order"  => "",
          "datatype"    => "Node",
          "disabled"    => 0,
          "field_order" => 9999,
          "help_id"     => "helpmeta_114",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "node",
          "labels"      => {
            "de" => "Angabe zur Quelle",
            "en" => "Details about the source",
            "it" => "Informazioni sulla fonte",
            "sr" => "detalji o izvoru"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "contribute",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 11,
      "help_id"     => "helpmeta_115",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Provenienz",
        "en" => "Provenience",
        "it" => "Provenienza",
        "sr" => "poreklo"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "provenience",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 1,
          "help_id"     => "helpmeta_129",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Name der Zeitschrift",
            "en" => "Name of Publication",
            "it" => "Titolo della monografia",
            "sr" => "ime publikacije"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "name_magazine",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 2,
          "help_id"     => "helpmeta_102",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Umfang",
            "en" => "Pages or Volume",
            "it" => "Pagine o volume della monografia",
            "sr" => "stranice ili volumen"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "pagination",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 3,
          "help_id"     => "helpmeta_103",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Reihentitel",
            "en" => "Series Title",
            "it" => "Titolo della collana o della rivista",
            "sr" => "naslov serije"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "reihentitel",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 4,
          "help_id"     => "helpmeta_131",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Band",
            "en" => "Volume",
            "it" => "Volume della collana o della rivista",
            "sr" => "volumen"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "volume",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 5,
          "help_id"     => "helpmeta_132",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Heft",
            "en" => "Number",
            "it" => "Numero di fascicolo della rivista",
            "sr" => "broj"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "booklet",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 6,
          "help_id"     => "helpmeta_133",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "von Seite",
            "en" => "From Page",
            "it" => "da pagina",
            "sr" => "od stranice"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "from_page",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 7,
          "help_id"     => "helpmeta_134",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "bis Seite",
            "en" => "To Page",
            "it" => "a pagina",
            "sr" => "do stranice"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "to_page",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 8,
          "help_id"     => "helpmeta_130",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Name der Sammlung/Monographie",
            "en" => "Name of Collection/Monograph",
            "it" => "Titolo della collezione",
            "sr" => "ime kolekcije/monografije"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "name_collection",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 9,
          "help_id"     => "helpmeta_99",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Verlagsort",
            "en" => "Publishing Address",
            "it" => "Luogo di pubblicazione",
            "sr" => "adresa izdava?a"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "publisherlocation",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 10,
          "help_id"     => "helpmeta_100",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Verlag",
            "en" => "Publisher",
            "it" => "Editore",
            "sr" => "izdava?"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "publisher",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "DateTime",
          "disabled"    => 0,
          "field_order" => 11,
          "help_id"     => "helpmeta_101",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "input_datetime",
          "labels"      => {
            "de" => "Erscheinungsdatum",
            "en" => "Publication Date",
            "it" => "Data di pubblicazione",
            "sr" => "datum izdavanja"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "releaseyear",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 12,
          "help_id"     => "helpmeta_135",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Auflage",
            "en" => "Edition/ Print Run",
            "it" => "Edizione/ Tiratura",
            "sr" => "izdanje/ broj \x{9a}tampe"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "edition",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 13,
          "help_id"     => "helpmeta_136",
          "hidden"      => 0,
          "input_regex" => ".*",
          "input_type"  => "input_textarea_lang",
          "labels"      => {
            "de" => "Ver\x{f6}ffentlichungsdaten",
            "en" => "Publication Dates",
            "it" => "Note",
            "sr" => "datumi publikovanja"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "release_notes",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Vocabulary",
          "disabled"    => 0,
          "field_order" => 14,
          "help_id"     => "helpmeta_128",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "select",
          "labels"      => {
            "de" => "Medium",
            "en" => "Medium",
            "it" => "Supporto",
            "sr" => "medij"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang"   => "",
          "vocabularies" => [
            { "description" => "Medium - Book Reiter",
              "namespace"   => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0/voc_32/",
              "terms"       => [
                { "labels" => {
                    "de" => "Band",
                    "en" => "Band",
                    "it" => "Nastro",
                    "sr" => "tom"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0/voc_32/1552131"
                },
                { "labels" => {
                    "de" => "CD",
                    "en" => "CD",
                    "it" => "CD",
                    "sr" => "CD"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0/voc_32/1552130"
                },
                { "labels" => {
                    "de" => "DVD",
                    "en" => "DVD",
                    "it" => "DVD",
                    "sr" => "DVD"
                  },
                  "uri" => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0/voc_32/1552129"
                }
              ]
            }
          ],
          "xmlname" => "medium",
          "xmlns"   => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "CharacterString",
          "disabled"    => 0,
          "field_order" => 15,
          "help_id"     => "helpmeta_104",
          "hidden"      => 0,
          "input_regex" => "",
          "input_type"  => "input_text",
          "labels"      => {
            "de" => "Link zu bibliografischen Angaben",
            "en" => "Link to bibliographic information",
            "it" => "URL Catalogo",
            "sr" => "Link to bibliographic information"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "alephurl",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 12,
      "help_id"     => "helpmeta_98",
      "hidden"      => 0,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "Digitales Buch",
        "en" => "Digital Book",
        "it" => "Libro digitale",
        "sr" => "podaci o knjizi"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "digitalbook",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/digitalbook/V1.0"
    },
    { "cardinality" => 1,
      "children"    => [
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 1,
          "help_id"     => "helpmeta_141",
          "hidden"      => 0,
          "input_regex" => "^Y|N\$",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Einverst\x{e4}ndniserkl\x{e4}rung",
            "en" => "Consent form",
            "it" => "Modulo di autorizzazione",
            "sr" => "izjava saglasnosti"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "consent_form",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 2,
          "help_id"     => "helpmeta_142",
          "hidden"      => 0,
          "input_regex" => "^Y|N\$",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Titelblatt",
            "en" => "Title page",
            "it" => "Pagina del titolo",
            "sr" => "naslovna strana"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "title_page",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 3,
          "help_id"     => "helpmeta_143",
          "hidden"      => 0,
          "input_regex" => "^Y|N\$",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Titelblatt ident",
            "en" => "Title page identical",
            "it" => "Pagina del titolo identica",
            "sr" => "identi?no naslovnoj strani"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "title_page_identical",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 4,
          "help_id"     => "helpmeta_144",
          "hidden"      => 0,
          "input_regex" => "^Y|N\$",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "PDF ident",
            "en" => "PDF identical",
            "it" => "PDF identico",
            "sr" => "PDF identi?no"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "pdf_identical",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
        },
        { "cardinality" => 1,
          "data_order"  => "",
          "datatype"    => "Boolean",
          "disabled"    => 0,
          "field_order" => 5,
          "help_id"     => "helpmeta_145",
          "hidden"      => 0,
          "input_regex" => "^Y|N\$",
          "input_type"  => "select_yesno",
          "labels"      => {
            "de" => "Abstract anzeigen",
            "en" => "Show abstract",
            "it" => "Mostra abstract",
            "sr" => "poka\x{9e}i apstrakt"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => "",
          "xmlname"    => "show_abstract",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 6,
          "help_id"     => "helpmeta_146",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Interne Notiz 1",
            "en" => "Note 1",
            "it" => "Note, 1",
            "sr" => "bele\x{9a}ka 1"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "note_1",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
        },
        { "cardinality" => "*",
          "data_order"  => "",
          "datatype"    => "LangString",
          "disabled"    => 0,
          "field_order" => 7,
          "help_id"     => "helpmeta_147",
          "hidden"      => 0,
          "input_regex" => "^.*\$",
          "input_type"  => "input_text_lang",
          "labels"      => {
            "de" => "Interne Notiz 2",
            "en" => "Note 2",
            "it" => "Note 2",
            "sr" => "bele\x{9a}ka 2"
          },
          "loaded" => 0,

          "mandatory" => 0,
          "ordered"   => 0,
          "ui_value"  => "",

          "value_lang" => undef,
          "xmlname"    => "note_2",
          "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
        }
      ],
      "data_order"  => "",
      "datatype"    => "Node",
      "disabled"    => 0,
      "field_order" => 13,
      "help_id"     => "helpmeta_140",
      "hidden"      => 1,
      "input_regex" => "",
      "input_type"  => "node",
      "labels"      => {
        "de" => "E-Theses",
        "en" => "E-Theses",
        "it" => "Tesi elettroniche",
        "sr" => "E - teze"
      },
      "loaded" => 0,

      "mandatory" => 0,
      "ordered"   => 0,
      "ui_value"  => "",

      "value_lang" => "",
      "xmlname"    => "etheses",
      "xmlns"      => "http://phaidra.univie.ac.at/XML/metadata/etheses/V1.0"
    }
  ]
);

sub get_languages {

  my ($self, $c, $nocache) = @_;
  return undef;
}

1;
__END__
