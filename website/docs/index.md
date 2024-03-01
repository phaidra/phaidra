# Index

The following fields are available in PHAIDRA's Solr index.

Notes:

- pid only contains the local part. When showing pid, always add the URL of the instance (e.g. show https://phaidra.univie.ac.at/o:1 instead of only o:1)

- owner contains the username of the owner, not its name

- resourcetype does not have to correspond to cmodel. Resourcetype should be the more adequate choice to describe an object's type

- bib_roles_, dc_creator, dc_contributor and uwm_roles_json all contain the same information or its part. bib_roles should be the best choice to search/show data. Use uwm_roles_json if you need to show affiliations (institutional repository).

- latlon is provided by the user, except for objects where user provided bounding box, in that case, the latlon was automatically generated to point to the middle of the bounding box

- datastreams. You can use this to filter objects having particular metadata datastreams etc. If an object has POLICY datastream, it means access to it is restricted in some way and access will require authentication (do not use RIGHTS datastream as the filter - objects with RIGHTS datastream can still have unrestricted access).

Field name | Description
------------ | -------------
pid | the local part of the permanent identifier (eg: o:1)
owner | username of the owner
resourcetype | [type of object](#resource-types)
bib_roles_pers_(role code) | [personal roles](#role-codes)
bib_roles_corp_(role code) | [corporate roles](#role-codes)
dc_title | titles of the object
dc_title_(lang) | titles in available language variants
dc_description | descriptions of the object
dc_description_(lang) | descriptions in available language variants
dc_subject | subject (keyword, classification,...) of the object
dc_subject_(lang) | subject (keyword, classification,...) in available language variants
dc_language | languages of the object
dc_creator | roles mapped to Dublin Core as creator (consider using bib_roles_* instead)
dc_creator_(lang) | roles mapped to Dublin Core as creator in available language variants (eg 'University of Vienna', 'Universität Wien') (consider using bib_roles_* instead)
dc_contributor | roles mapped to Dublin Core as contributor (consider using bib_roles_* instead)
dc_contributor_(lang) | roles mapped to Dublin Core as contributor in available language variants (eg 'University of Vienna', 'Universität Wien') (consider using bib_roles_* instead)
dc_rights | rights statements
dc_rights_(lang) | rights statements in available language variants
dc_license | license of the object
dc_coverage | coverage statements
dc_coverage_(lang) | coverage statements in available language variants
dc_identifier | identifiers associated with the object
dc_date | dates associated with the object (provided by the user in metadata, eg 'published')
dc_format | format (could be size or MIME type)
dc_publisher | roles mapped to Dublin Core as publishers
dc_relation | relations
dc_type | type of object (consider using resourcetype instead)
haspart | contains collection members' identifiers for collection objects
ispartof | contains an array of collections the object is part of
created | date the object was created
tcreated | created date saved in a field type better suited for range queries
modified | date of the last modification
tmodified | modified date saved in a field type better suited for range queries
cmodel | object's content model (consider using resourcetype instead)
size | size in bytes
tsize | size saved in a field type better suited for range queries
latlon | latitude and longitude associated with the object
alt_formats | identifiers of objects representing alternate formats of the object (eg LaTex version of the PDF object)
alt_versions | identifiers of objects representing alternate versions of the object (eg Published version of the preprint)
bbox | bounding box associated with the object in the WKT/CQL ENVELOPE syntax.  (eg ENVELOPE(-10, 20, 15, 10) which is minX, maxX, maxY, minY)
bib_ir | "yes" for objects which are part of the institutional repository (uscholar.univie.ac.at)
bib_edition | edition (used mainly for journal articles, eg 2)
bib_journal | journal name
bib_published | published date
bib_publisher | publisher name
bib_publisherlocation | publisher location
bib_volume | volume (used mainly for journal articles, eg 2)
uwm_roles_json | JSON with roles structured as in uwmetadata (consider using bib_roles_* instead)
datastreams | list of datastreams

### Resource types
```javascript
   var resourcetypes = {
      image: "Image",
      book: "Book",
      journalarticle: "Journal article",
      text: "Text",
      collection: "Collection",
      video: "Viedo",
      other: "Other",
      dataset: "Dataset",
      map: "Map",
      interactiveresource: "Resource",
      sound: "Sound"
    };
```

### Role codes
```javascript
    var roles = {      
      "initiator": "Initiator",
      "evaluator": "Evaluator",  
      "technicalinspector": "Technical inspector",
      "textprocessor": "Textprocessor",
      "pedagogicexpert": "Pedagogic expert",
      "interpreter": "Interpreter",
      "digitiser": "Digitiser",
      "keeperoftheoriginal": "Keeper of the original",
      "adviser": "Adviser",
      "degreegrantor": "Degree grantor",
      "uploader": "Uploader",
      "dtc": "Data contributor",
      "aut": "Author",
      "pbl": "Publisher",  
      "edt": "Editor",
      "dsr": "Designer",
      "trl": "Translator",
      "exp": "Expert",
      "oth": "Other",
      "art": "Artist",
      "dnr": "Donor",
      "pht": "Photographer",
      "jud": "Judge",
      "prf": "Performer",
      "wde": "Wood engraver",
      "rce": "Recording engineer",
      "sce": "Scenarist",
      "ths": "Thesis advisor",
      "sds": "Sound designer",
      "lyr": "Lyricist",
      "ilu": "Illuminator",
      "eng": "Engineer",
      "cnd": "Conductor",
      "dto": "Dedicator",
      "opn": "Opponent",
      "cmp": "Composer",
      "ctg": "Cartographer",
      "dub": "Dubious author",
      "wam": "Writer of accompanying material",
      "arc": "Architect",
      "vdg": "Videographer",
      "scl": "Sculptor",
      "aus": "Screenwriter",
      "own": "Owner",
      "fmo": "Former owner",
      "mus": "Musician",
      "ive": "Interviewee",
      "ill": "Illustrator",
      "cng": "Cinematographer",
      "dte": "Dedicatee",
      "sad": "Scientific advisor",
      "mte": "Metal-engraver",
      "arr": "Arranger",
      "etr": "Etcher",
      "dis": "Dissertant",
      "prt": "Printer",
      "flm": "Film editor",
      "rev": "Reviewer",
      "pro": "Producer",
      "att": "Attributed name",
      "lbt": "Librettist",
      "ivr": "Interviewer",
      "egr": "Engraver",
      "msd": "Musical director",
      "ard": "Artistic director",
      "chr": "Choreographer",
      "com": "Compiler",
      "sng": "Singer",
      "act": "Actor",
      "adp": "Adapter"
    };
```

### Example
```json
{
        "bib_roles_corp_digitiser":["DiFaB"],
        "resourcetype":"image",
        "uwm_roles_json":["[{\"role\":\"uploader\",\"entities\":[{\"firstname\":\"Imola Dora\",\"lastname\":\"Traub\",\"data_order\":0,\"institution\":\"DiFaB\"},{}],\"data_order\":1},{\"role\":\"digitiser\",\"entities\":[{\"firstname\":\"Nina\",\"lastname\":\"Rannharter\",\"data_order\":0,\"institution\":\"DiFaB\"},{}],\"data_order\":2},{\"role\":\"dtc\",\"entities\":[{\"firstname\":\"Nina\",\"lastname\":\"Rannharter\",\"data_order\":0,\"institution\":\"DiFaB\"},{}],\"data_order\":0}]"],
        "dc_contributor":["Rannharter, Nina",
          "DiFaB",
          "Rannharter, Nina",
          "DiFaB",
          "Hallensleben, Horst"],
        "pid":"o:409034",
        "bib_roles_pers_dtc":["Nina Rannharter"],
        "owner":"theisd9",
        "dc_description_deu":["Diabeschriftung Hallensleben: \"Oşki (Ösk) / Naos / 958-61 / Nordfassade / [Bild] / Stirn der nördl. Konche / von NO gesehen\""],
        "dc_title":["Öşk, Öşk-Kloster"],
        "size":1.26942795E8,
        "latlon":"40.6,41.583333",
        "bib_roles_pers_uploader":["Imola Dora Traub"],
        "dc_title_deu":["Öşk, Öşk-Kloster"],
        "dc_subject":["Kirche, Architektur, Hallensleben, Katholikon, Kloster, Naos",
          "Church, Architecture, Hallensleben, Monastery, Catholicon, Naos",
          "Getty Art & Architecture Thesaurus, friezes",
          "Getty Art & Architecture Thesaurus, friezes",
          "Getty Art & Architecture Thesaurus, sculpture",
          "Getty Art & Architecture Thesaurus, sculpture",
          "Getty Art & Architecture Thesaurus, blind arches",
          "Getty Art & Architecture Thesaurus, blind arches",
          "Getty Art & Architecture Thesaurus, churches",
          "Getty Art & Architecture Thesaurus, churches",
          "Getty Thesaurus of Geographic Names, Erzurum Ili",
          "Getty Thesaurus of Geographic Names, Erzurum Ili",
          "Getty Art & Architecture Thesaurus, Middle Byzantine",
          "Getty Art & Architecture Thesaurus, Middle Byzantine"],
        "dc_rights":["CC BY-NC-ND 2.0 AT",
          "http://creativecommons.org/licenses/by-nc-nd/2.0/at/"],
        "dc_license":["CC BY-NC-ND 2.0 AT",
          "http://creativecommons.org/licenses/by-nc-nd/2.0/at/"],
        "dc_subject_eng":["Church, Architecture, Hallensleben, Monastery, Catholicon, Naos",
          "Getty Art & Architecture Thesaurus, friezes",
          "Getty Art & Architecture Thesaurus, sculpture",
          "Getty Art & Architecture Thesaurus, blind arches",
          "Getty Art & Architecture Thesaurus, churches",
          "Getty Thesaurus of Geographic Names, Erzurum Ili",
          "Getty Art & Architecture Thesaurus, Middle Byzantine"],
        "dc_identifier":["hdl:11353/10.409034",
          "http://phaidra.univie.ac.at/o:409034"],
        "ns":"solr-ph001.index",
        "bib_roles_corp_uploader":["DiFaB"],
        "datastreams":["GEO",
          "TECHINFO",
          "THUMBNAIL",
          "UWMETADATA",
          "DC_P",
          "DC_OAI",
          "DC",
          "STYLESHEET",
          "OCTETS",
          "RELS-EXT"],
        "_ts":6.3142083315525222E18,
        "dc_date":["2014-12-10",
          "2014-12-10",
          "2014-12-10",
          "2014-12-10"],
        "dc_format":["126942795 bytes"],
        "_updated":[1.468799959E9],
        "bib_roles_pers_digitiser":["Nina Rannharter"],
        "created":"2015-11-17T18:23:31.917Z",
        "cmodel":"Picture",
        "modified":"2016-03-09T07:15:04.061Z",
        "bib_roles_corp_dtc":["DiFaB"],
        "dc_description":["Diabeschriftung Hallensleben: \"Oşki (Ösk) / Naos / 958-61 / Nordfassade / [Bild] / Stirn der nördl. Konche / von NO gesehen\""],
        "dc_subject_deu":["Kirche, Architektur, Hallensleben, Katholikon, Kloster, Naos",
          "Getty Art & Architecture Thesaurus, friezes",
          "Getty Art & Architecture Thesaurus, sculpture",
          "Getty Art & Architecture Thesaurus, blind arches",
          "Getty Art & Architecture Thesaurus, churches",
          "Getty Thesaurus of Geographic Names, Erzurum Ili",
          "Getty Art & Architecture Thesaurus, Middle Byzantine"],
        "_id":"57868d996f5e284bf8448e0a",
        "tcreated":["2015-11-17T18:23:31.917Z"],
        "ispartof":["o:409041",
          "o:409288"],
        "tsize":[1.26942795E8],
        "tmodified":["2016-03-09T07:15:04.061Z"],
        "_version_":1.54155485712351232E18
}
```