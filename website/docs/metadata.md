# Metadata

## Introduction

Here we describe the current bibliographic metadata scheme of PHAIDRA. It is a scheme based on RDF and the ideas of Linked-Data and it is saved in the JSON-LD format (for ease of use).

Formally, the scheme should be described as a <a target="_blank" href="https://www.w3.org/TR/shacl/">SHACL</a> shape, the definition is a work in progress.

For a user-friendlier overview of metadata fields, you can use the <a target="_blank" href="https://phaidra.univie.ac.at/metadata-fields-help">help page</a> directly in an PHAIDRA instance.

If you are developing a frontend or an upload script, consider using PHAIDRA Vue Components (or rather the javascripts inside) to manipulate the metadata. See the <a href="/docs/api/">API usage guide</a> for examples.

Many fields are using controlled vocabularies. Most of the controlled vocabularies are defined in our <a target="_blank" href="https://vocab.phaidra.org/">vocabulary server</a>, but the lists of terms are also available in the vocabulary <a target="_blank" href="https://github.com/phaidra/phaidra/blob/main/src/phaidra-vue-components/src/store/modules/vocabulary.js">vuex store js file</a>.

## Overview

| Field | Predicate | Note |
| :---- | :---- | :---- |
| [Alternate identifier](#alternate-identifier) | rdam:P30004 | for identifiers other than Phaidra PID |
| [Type of resource](#type-of-resource) | dcterms:type | technical (e.g. audio) |
| [Type of object](#type-of-object) | edm:hasType | type of described object (e.g. journal article) |
| [Genre](#genre) | schema:genre | content (e.g. comedy) |
| [Title](#title) | dce:title | see [title type vocabulary](#title-type-vocabulary) |
| [Language](#language) | dcterms:language |  |
| [Roles](#roles) | role:`phaidra role code` | |
| [Publisher](#publisher) | bf:provisionActivity | |
| [Description / Note](#description--note) | bf:note | see [description type vocabulary](#description-type-vocabulary) |
| [Table of contents](#table-of-contents) | bf:TableOfContents | "@type": "bf:TableOfContents" |
| [Simple subject](#simple-subject) | dcterms:subject | "@type":"skos:Concept" |
| [Complex subject](#complex-subject) | dcterms:subject | "@type":"phaidra:Subject" |
| [Level of description](#level-of-description) | phaidra:levelOfDescription | |
| [Keywords](#keywords) | dce:subject | |
| [Date](#date) | see [date predicates](#date-predicates) | |
| [Temporal coverage](#temporal-coverage) | dcterms:temporal | |
| [License](#license) | edm:rights |  |
| [Rights statement](#rights-statement) | dce:rights | |
| [Funder](#funder) | frapo:hasFundingAgency |  |
| [Project](#project) | frapo:isOutputOf | "@type":"foaf:Project" |
| [Study plan](#study-plan) | frapo:isOutputOf | "@type":"aiiso:Programme" |
| [Associated with](#associated-with) | rdax:P00009 |  |
| [See also](#see-also) | rdfs:seeAlso |  |
| [Is contained in](#is-contained-in) | rdau:P60101 |  |
| [Is in series](#is-in-series) | rdau:P60193 |  |
| [Citation](#citation) | see [citation predicates](#citation-predicates) |  |
| [Instance of work](#instance-of-work) | bf:instanceOf | "@type":"schema:CreativeWork" |
| [Motion picture adaptation of](#motion-picture-adaptation-of) | rdau:P60227 | "@type":"schema:CreativeWork"  |
| [Number of pages](#number-of-pages) | schema:numberOfPages |  |
| [Page start](#page-start) | schema:pageStart |  |
| [Page end](#page-end) | schema:pageEnd |  |
| [Extent](#extent) | rdau:P60550  |  |
| [Supplementary material](#supplementary-material) | bf:supplementaryContent |  |
| [Awards](#awards) | bf:awards |  |
| [Audience](#audience) | dcterms:audience |  |
| [Regional encoding](#regional-encoding) | rdau:P60059 | |
| [Accession number](#accession-number) | opaque:cco_accessionNumber |  |
| [Call number / Shelf mark](#call-number--shelf-mark) | bf:shelfMark |  |
| [Physical location](#physical-location) | bf:physicalLocation |  |
| [Inscription](#inscription) | vra:hasInscription |  |
| [Material](#material) | vra:material |  |
| [Technique](#technique) | vra:technique |  |
| [Width](#width) | schema:width |  |
| [Height](#height) | schema:height |  |
| [Depth](#depth) | schema:depth |  |
| [Diameter](#diameter) | vra:diameter |  |
| [Weight](#weight) | schema:weight |  |
| [Provenance](#provenance) | dcterms:provenance |  |
| [Georeference](#georeference) | see [spatial predicates](#spatial-predicates) |  |
| [Scale](#scale) | bf:scale |  |
| [Available language](#available-language) | schema:availableLanguage |  |
| [Subtitle language](#subtitle-language) | schema:subtitleLanguage |  |
| [Format](#format) | dce:format |  |
| [Carrier type](#carrier-type) | rdau:P60048 | |
| [Duration](#duration) | schema:duration |  |
| [File name](#file-name) | ebucore:filename |  |
| [MIME type](#mime-type) | ebucore:hasMimeType |  |
| [System fields](#system-fields) | various | by default not visible in display component |

## Fields

### Alternate identifier

#### Description

An alternative identifier (other than Phaidra persistent identifier) that uniquely identifies the resource.

Relates a manifestation to an appellation of manifestation that consists of a code, number, or other string, usually independent of natural language and social naming conventions, used to identify a manifestation.

### Identifier types

Identifier types should be taken from http://id.loc.gov/vocabulary/identifiers.html if possible.

| Currently supported types | Type ID |
| :----- | :----- |
| DOI | ids:doi |
| Handle | ids:hdl |
| URI | ids:uri |
| URN | ids:urn |
| AC-Number | phaidra:acnumber |

#### JSON-LD Example

```json
  "rdam:P30004": [
    {
      "@type": "ids:doi",
      "@value": "10.5281/zenodo.579874"
    }
  ]
```

### Type of resource

#### Description

The Resource Type vocabulary defines concepts to identify the genre of a resource. Such resources, like publications, research data, audio and video objects, are typically deposited in institutional and thematic repositories or published in ejournals. This vocabulary supports a hierarchical model that relates narrower and broader concepts. Multilingual labels regard regional distinctions in language and term. Concepts of this vocabulary are mapped with terms and concepts of similar vocabularies and dictionaries.

[COAR Resource Type Vocabulary](http://vocabularies.coar-repositories.org/documentation/resource_types/)

#### JSON-LD Example

```json
  "dcterms:type": [
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "image"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/vocabulary/44TN-P1S0"
      ]
    }
  ]
```

### Type of object

#### Description

A term or terms that designate a category characterizing a particular style, form, or content, such as artistic, musical, literary composition, etc.

#### JSON-LD example

```json
  "edm:hasType": [
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "astronomical photography",
          "@language": "eng"
        }
      ],
      "skos:exactMatch": [
        "http://vocab.getty.edu/aat/300134506"
      ]
    }
  ]
```

### Genre

#### Description

Genre of the creative work, broadcast channel or group.

#### JSON-LD example

```json
  "schema:genre": [
    {
      "@type": "skos:Concept",
      "rdfs:label": [
        {
          "@value": "science-fiction",
          "@language": "eng"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/vocabulary/YV6T-SWAF"
      ]
    }
  ]
```

### Membership

TODO See mods:relatedItem in Samvera mapping.

### Title 

#### Description

A name given to the resource. Typically, a title will be a name by which the resource is formally known.

#### Title type vocabulary

| Label | Class |
| ----------------------- | ------------------------ |
| Title | bf:Title |
| Parallel title | bf:ParallelTitle |

#### JSON-LD Example

```json
  "dce:title": [
    {
      "@type": "bf:Title",
      "bf:mainTitle": [
        {
          "@value": "This is the main title",
          "@language": "deu"
        }
      ],
      "bf:subtitle": [
        {
          "@value": "This is subtitle",
          "@language": "deu"
        }
      ]
    }
  ]
```
### Language

#### Description

It could be a code from [MARC List for Languages](http://id.loc.gov/vocabulary/languages.html), see also [lang.js](https://github.com/phaidra/phaidra-vue-components/blob/master/src/utils/lang.js) or a vocabulary value.

#### JSON-LD example

```json
  "dcterms:language": [
    "ara",
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "Lebanese",
          "@language": "eng"
        },
        {
          "@value": "Libanesisch-Arabisch",
          "@language": "deu"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/vocabulary/MKXZ-SARM"
      ]
    }
  ]
```

### Roles

#### Description

Contributors. The list of possible roles comes from [MARC Code List for Relators](https://www.loc.gov/marc/relators/relaterm.html) with the following Phaidra extensions:

TODO

The array of objects the role predicate is pointing at (e.g. authors) is [ordered in @context](https://www.w3.org/2018/jsonld-cg-reports/json-ld/#sets-and-lists) as a @list.

### Identifier types

Identifier types can be taken from http://id.loc.gov/vocabulary/identifiers.html.

| Currently supported types | Type ID |
| :----- | :----- |
| ORCID | ids:orcid |
| VIAF | ids:viaf |
| GND | ids:gnd |
| Wikidata | ids:wikidata |
| LCNAF | ids:lcnaf |
| ISNI | ids:isni |
| URI | ids:uri |

#### JSON-LD example

Personal
```json
  "role:aut": [
    {
      "@type": "schema:Person",
      "schema:givenName": [
        {
          "@value": "Brenda"
        }
      ],
      "schema:familyName": [
        {
          "@value": "Walsh"
        }
      ],
      "schema:affiliation": [
        {
          "@type": "schema:Organization",
          "schema:name": [
            {
              "@value": "University of Vienna"
            }
          ]
        }
      ]
    }
  ]
```

Corporate
```json
  "role:aut": [
    {
      "@type": "schema:Organization",
      "schema:name": [
        {
          "@value": "University of Vienna"
        }
      ]
    }
  ]
```

With ID
```json
  "role:aut": [
    {
      "@type": "schema:Person",
      "schema:givenName": [
        {
          "@value": "Erika"
        }
      ],
      "schema:familyName": [
        {
          "@value": "Mustermann"
        }
      ],
      "skos:exactMatch": [
        {
           "@type": "ids:orcid",
           "@value": "0000-0002-1825-0097"
        }
      ]
    }
  ]
```

### Publisher

#### Description

[bf:ProvisionActivity](http://id.loc.gov/ontologies/bibframe.html#c_ProvisionActivity)

#### JSON-LD example

```json
  "bf:provisionActivity": [
    {
      "@type": "bf:Publication",
      "bf:agent": [
        {
          "@type": "schema:Organization",
          "schema:name": [
            {
              "@value": "Example Publishing"
            }
          ]
        }
      ],
      "bf:place": [
        {
          "@type": "schema:Place",
          "skos:prefLabel": [
            {
              "@value": "Graz"
            }
          ],
          "skos:exactMatch": [
            "http://vocab.getty.edu/page/tgn/7003097"
          ],
        }
      ],
      "bf:date": [
        "1996"
      ]
    }
  ]
```

### Awards

#### Description

Information on awards associated with the described resource.

:exclamation: BIBFRAME says this should be literal, but I can see it being exactMatch to some awards vocabulary? So I keep it as skos:Concept.

#### JSON-LD example

```json
"bf:awards": [
  {
    "@type": "skos:Concept",
    "skos:prefLabel": [
      {
        "@value": "Butaca Awards 2002: Millor actor català de cinema"
      } 
    ]
  },
  {
    "@type": "skos:Concept",
    "skos:prefLabel": [
      {
        "@value": "Karlovy Vary International Film Festival 2002: Special Mention",
        "@language": "eng"
      } 
    ]
  }
]
```

### Audience

#### Description

A class of entity for whom the resource is intended or useful, e.g. age restriction.

#### JSON-LD example

```json
"dcterms:audience": [
  {
    "@type": "skos:Concept",
    "skos:prefLabel": [
      {
        "@value": "ab 16 Jahre",
        "@language": "deu"
      } 
    ]
  }
]
```

### Regional encoding

#### Description

Relates a resource to a designation for one or more regions of the world for which a videodisc or video game carrier is encoded, indicating that playback is restricted to a device configured to decode it.

#### JSON-LD example

```json
"rdau:P60059": [
  {
    "@type": "skos:Concept",
    "skos:prefLabel": [
      {
        "@value": "region 1"
      }
    ],
    "skos:exactMatch": [
       "https://pid.phaidra.org/vocabulary/XXXX-XXXX"
    ]
  }
]
```

### Is contained in

#### Description

rdau:P60101 (is contained in) - eg. part of a book - "Relates a resource to a larger resource of which a part is a discrete component".

Inside is-contained-in metadata, metadata about series (rdau:P60193) and publisher (bf:provisionActivity) can be nested.

#### JSON-LD example

```json
"schema:pageStart": [
  "4387"
],
"schema:pageEnd": [
  "4394"
],
"rdau:P60101": [
  {
    "dce:title": [
      {
        "@type": "bf:Title",
        "bf:mainTitle": [
          {
            "@value": "This is the main title",
            "@language": "deu"
          }
        ],
        "bf:subtitle": [
          {
            "@value": "This is subtitle",
            "@language": "deu"
          }
        ]
      }
    ],
    "role:edt": [
      {
        "@type": "schema:Person",
        "schema:givenName": {
          "@value": "Maxwell"
        },
        "schema:familyName": {
          "@value": "Perkins"
        }
      }
    ],
    "ids:isbn": [
      "0021-9738"
    ],
    "rdau:P60193": [
      {
        "@type": "schema:CreativeWork",
        "dce:title": [
          {
            "@type": "bf:Title",
            "bf:mainTitle": [
              {
                "@value": "Book or series title"
              }
            ]
          }
        ],
        "bibo:volume": [
          "1"
        ],
        "bibo:issue": [
          "10"
        ],
        "ids:issn": [
          "0021-9738"
        ],
        "dcterms:issued": [
          "2017-05"
        ]
      }
    ],
    "bf:provisionActivity": [
    {
      "@type": "bf:Publication",
      "bf:agent": [
        {
          "@type": "schema:Organization",
          "schema:name": [
            {
              "@value": "Example Publishing"
            }
          ]
        }
      ],
      "bf:place": [
        {
          "@type": "schema:Place",
          "skos:prefLabel": [
            {
              "@value": "Graz"
            }
          ],
          "skos:exactMatch": [
            "http://vocab.getty.edu/page/tgn/7003097"
          ],
        }
      ],
      "bf:date": [
        "1996"
      ]
    }
  ]
  }
]
```

### Is in series

#### Description

rdau:P60193 (is in series) - e.g. article in journal - "Relates a resource to a resource in which a part has been issued; a title of a larger resource appears on a part".

#### JSON-LD example

```json
"schema:pageStart": [
  "4387"
],
"schema:pageEnd": [
  "4394"
], 
"rdau:P60193": [
    {
      "@type": "schema:CreativeWork",
      "dce:title": [
        {
          "@type": "bf:Title",
          "bf:mainTitle": [
            {
              "@value": "Journal of Clinical Investigation"
            }
          ]
        }
      ],
      "bibo:volume": [
        "1"
      ],
      "bibo:issue": [
        "10"
      ],
      "ids:issn": [
        "0021-9738"
      ],
      "dcterms:issued": [
        "2017-05"
      ],
      "skos:exactMatch": [
        "http://ld.zdb-services.de/resource/2018375-6"
      ]
    }
  ]
```

### Citation

#### Description

The citations characterized may be either direct and explicit (as in the reference list of a journal article), indirect (e.g. a citation to a more recent paper by the same research group on the same topic), or implicit (e.g. as in artistic quotations or parodies, or in cases of plagiarism).

##### Citation predicates

| Citation predicates |
| :----- |
| cito:cites |
| cito:isCitedBy |
| cito:citesAsDataSource |

#### JSON-LD example

```json
"cito:cites": [
  {
    "@type": "rdfs:Resource",
    "skos:prefLabel": [
      {
        "@value": "Plakat Phaidra: Phaidra – digitale Bestände effizient aufbewahren",
        "@language": "deu"
      }
    ],
    "skos:exactMatch": [
       "https://phaidra.univie.ac.at/o:359991"
    ]
  },
  {
    "@type": "rdfs:Resource",
    "skos:prefLabel": [
      {
        "@value": "Kopacsi, Sandor. (2017, May). COAR Resource Type Vocabulary in the Classification Server of Phaidra. Zenodo.",
        "@language": "eng"
      }
    ],
    "skos:exactMatch": [
       "doi:10.5281/zenodo.579874"
    ]
  },
  {
    "@type": "rdfs:Resource",
    "skos:prefLabel": [
      {
        "@value": "Phaidra Folder"
      }
    ],
    "skos:exactMatch": [
       "hdl:11353/10.438701"
    ]
  }
]
```

### Motion picture adaptation of

#### Description

Relates a resource to a resource that is adapted as a motion picture.

#### JSON-LD example

```json
  "rdau:P60227": [
    {
      "@type": "schema:CreativeWork",
      "dce:title": [
        {
          "@type": "bf:Title",
          "bf:mainTitle": {
            "@value": "The Third Son",
            "@language": "eng"
          }
        }
      ],
      "role:aut": [
        {
          "@type": "schema:Person",
          "schema:givenName": {
            "@value": "Andrei"
          },
          "schema:familyName": {
            "@value": "Platanov"
          }
        }
      ]
    }
  ]
```

### Number of pages 

#### Description

The number of pages in the resource.

#### JSON-LD example

```json
  "schema:numberOfPages": [
    "123"
  ]
```

### Page start

#### Description

The page on which the work starts. For example, "135".

#### JSON-LD example

```json
  "schema:pageStart": [
    "135"
  ]
```

### Page end

#### Description

The page on which the work ends. For example, "138".

#### JSON-LD example

```json
  "schema:pageEnd": [
    "138"
  ]
```

### Extent

#### Description

Use to represent the extent of a resource.

#### JSON-LD example

```json
  "rdau:P60550": [
    {
      "@value": "47 S. (Textteil), [24] Bl. (Bildteil) : zahlr. Ill.",
      "@language": "deu"
    }
  ]
```


### Description / Note

#### Description

Information, usually in textual form, on attributes of a resource or some aspect of a resource.

#### Description type vocabulary

| Label | Class | Comment |
| ----------------------- | ------------------------ | ----------------- |
| Description | bf:Note | General description |
| Abstract | bf:Summary | Abstract |
| Remark | phaidra:Remark | Additional information |
| Condition | arm:ConditionAssessment | Assessment and/or documentation of the physical condition of an item, including damage, material vulnerabilities, special storage requirements, etc. The assessment is generally the output of a condition assessment activity, and may or may not result in a conservator activity. |
| Reproduction note | phaidra:ReproductionNote | States if the analogue object is a copy or an original |
| Digitization note | phaidra:DigitizationNote | Describes the digitization process (e.g. scanner, OCR process...) |

#### JSON-LD example

```json
  "bf:note": [
    {
      "@type": "bf:Note",
      "skos:prefLabel": [
        {
          "@value": "This is a description",
          "@language": "deu"
        }
      ]
    }
  ]
```

A note may have a type, expressed by class. There are no specific note classes defined within BIBFRAME, so the class would be from our own [vocabulary](#description-type-vocabulary). 

```json
  "bf:note": [
    {
      "@type": "phaidra:ConditionNote",
      "skos:prefLabel": [
        {
          "@value": "Top-left corner damaged by plasma cannon",
          "@language": "eng"
        }
      ]
    }
  ]
```

### Table Of Contents 

#### Description

Table of contents of the described resource.

#### JSON-LD example

```json
  "bf:tableOfContents": [
    {
      "@type": "bf:TableOfContents",
      "skos:prefLabel": [
        {
          "@value": "Chapter 1\\nChapter 2",
          "@language": "eng"
        }
      ]
    }
  ]
```

### Simple subject

#### Description

Points to an external concept (`skos:exactMatch`).

#### JSON-LD example

```json
  "dcterms:subject": [
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "crows",
          "@language": "eng"
        },
        {
          "@value": "krähen",
          "@language": "deu"
        }
      ],
      "rdfs:label": [
        {
          "@value": "crows--corvids--birds--animals",
          "@language": "eng"
        },
        {
          "@value": "krähen--rabenvögel--vögel--tiere",
          "@language": "eng"
        }
      ],
      "skos:exactMatch": [
        "https://gd.eppo.int/taxon/1CORVG"
      ]
    }
  ]
```

### Complex Subject

#### Description

Defines an RDF object describing a particular subject of the digital object.

#### JSON-LD example

```json
  "dcterms:subject": [ 
    {
      "@type":"phaidra:Subject",
      ... can contain all fields ...
    }
  ]
```

### Level of description

#### Description

Can be used inside [Complex subject](#complex-subject) to specify what the subject metadata are describing. Important in cases where the same metadata fields have to be used on different description levels (ie dimensions - of the photography vs dimensions of the instrument depicted on the photography -, creation date, etc).

Currently 2 values are possible:

* [Digitized object](https://pid.phaidra.org/vocabulary/HQ7N-3Q2W) - the metadata are describing the physical object which was digitized, eg an old photography
* [Represented object](https://pid.phaidra.org/vocabulary/TG30-5EM3) - the metadata are describing the content of the digital (or digitized) object, eg an instrument depicted on the photography

#### JSON-LD example

```json
  "phaidra:levelOfDescription": [ 
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "Digitized object",
          "@language": "eng"
        },
        {
          "@value": "Digitalisiertes Objekt",
          "@language": "deu"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/vocabulary/HQ7N-3Q2W"
      ]
    }
  ]
```

### Keywords

#### Description

Keywords

#### JSON-LD Example

```json
  "dce:subject": [
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@language": "eng",
          "@value": "barbaricum"
        }
      ]
    },
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@language": "eng",
          "@value": "rome"
        }
      ]
    }
  ]
```

### Date

#### Description

##### Date predicates

| Date predicates | Definition |
| :----- | :----- |
| dcterms:date | |
| dcterms:created | |
| dcterms:modified | |
| dcterms:available | |
| dcterms:issued | |
| dcterms:valid | |
| dcterms:dateAccepted | |
| dcterms:dateCopyrighted | |
| dcterms:dateSubmitted | |
| rdau:P60071 | "has date of production": "Relates a resource to a timespan associated with the inscription, fabrication, construction, etc., of an unpublished resource." |
| phaidra:dateAccessioned | |

Possible types: [EDTF](https://www.loc.gov/standards/datetime/edtf.html) or edm:TimeSpan

#### JSON-LD Example

```json
  "dcterms:issued": [
    "1983"
  ],
  "dcterms:valid": [
    "2004-06/2006-08"
  ],
  "dcterms:created": [
    "72~",
    {
      "@type": "edm:TimeSpan",
      "skos:prefLabel": [
        {
          "@value": "Imperial Roman"
        }
      ],
      "skos:exactMatch": [
        "http://vocab.getty.edu/aat/300020541"
      ]
    }
  ]
```

### Temporal coverage

#### Description

The temporalCoverage indicates the period that the content applies to, i.e. that it describes.

[EDTF](https://www.loc.gov/standards/datetime/edtf.html) or edm:TimeSpan

#### JSON-LD Example

```json
  "dcterms:temporal": [
    "72?",
    {
      "@type": "edm:TimeSpan",
      "skos:prefLabel": [
        {
          "@value": "Imperial Roman"
        }
      ],
      "skos:exactMatch": [
        "http://vocab.getty.edu/aat/300020541"
      ]
    }
  ]
```

### Supplementary material

#### Description

Material such as an index, bibliography, and appendix intended to supplement the primary content of a resource.

#### JSON-LD example

```json
  "bf:supplementaryContent": [
    {
      "@type": "bf:SupplementaryContent",
      "skos:prefLabel": [
        {
          "@value": "Interaktive Menü",
          "@language": "deu"
        }
      ]
    },
    {
      "@type": "bf:SupplementaryContent",
      "skos:prefLabel": [
        {
          "@value": "Szenenauswahl",
          "@language": "deu"
        }
      ]
    }
  ]
```

## Rights

### License

#### Description

Defines license of the digital object.

#### JSON-LD example

```json
  "edm:rights": [
    "https://creativecommons.org/licenses/by-nc-nd/4.0/"
  ]
```

### Rights statement

#### Description

Additional rights statement.

#### JSON-LD example

```json
  "dce:rights": [
    {
      "@value": "© The Author(s) 2023",
      "@language": "eng"
    },
    {
      "@value": "You may find additional information about the copyright status of the Item on the website of the organization that has made the Item available.",
      "@language": "eng"
    }
  ]
```

### Funder

#### Description

Describes the funding agency associated with the resource.

This field can also be nested inside [Project](#project).

#### JSON-LD example

```json
  "frapo:hasFundingAgency": [
    {
      "@type": "frapo:FundingAgency",
      "skos:prefLabel": [
        {
          "@value": "Austrian Science Fund",
          "@language": "eng"
        }
      ],
      "skos:exactMatch": [
        "http://dx.doi.org/10.13039/501100002428"
      ]
    }
  ]
```

### Project

#### Description

Describes the project that is associated with the resource.

#### JSON-LD example

```json
  "frapo:isOutputOf": [
    {
      "@type": "foaf:Project",
      "skos:prefLabel": [
        {
          "@value": "Vom Vorbild zum Abbild",
          "@language": "deu"
        }
      ],
      "rdfs:comment": [
        {
          "@value": "From Object to Icon is an interdisciplinary research project, conducted at the Institute of Egyptology in cooperation with the research group Multimedia Information Systems at the University of Vienna. It is based on the research that was initiated with the project MeKeTRE.",
          "@language": "eng"
        }
      ],
      "foaf:homepage": [
        "http://meketre.org/"
      ],
      "skos:exactMatch": [
        "P25958"
      ],
      "frapo:hasFundingAgency": [
        {
          "@type": "frapo:FundingAgency",
          "skos:prefLabel": [
            {
              "@value": "Austrian Science Fund",
              "@language": "eng"
            }
          ],
          "skos:exactMatch": [
            "http://dx.doi.org/10.13039/501100002428"
          ]
       }
      ]
    }
  ]
```

### Study plan

#### Description

Study plan that is associated with the resource.

#### JSON-LD example

```json
  "frapo:isOutputOf": [
    {
      "@type": "aiiso:Programme",
      "skos:prefLabel": [
        {
          "@value": "LA Musikerziehung LA Physik (ASVS)",
          "@language": "deu"
        }
      ],
      "skos:notation": [
        "spl-26-593-288"
      ]
    }
  ]
```

### Associated with

#### Description

Relates an RDA entity to a corporate body that is associated with an entity.

#### JSON-LD example

```json
  "rdax:P00009": [
    {
      "@type": "aiiso:Faculty",
      "skos:prefLabel": [
        {
          "@value": "Fakultät für Informatik",
          "@language": "deu"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/univie-org/WWYA-96YK"
      ]
    }
  ]
```

### See also

#### Description

A URL linking to a related resource.

#### JSON-LD example

```json
  "rdfs:seeAlso": [
    {
      "@type": "schema:URL",
      "schema:url": [
        "http://users.unimi.it/museozoo/TavoleParietali/Cd/html/0079.html"
      ],
      "skos:prefLabel": [
        {
          "@value": "Università degli Studi di Milano, Leuckart Tafel XXXVIII",
          "@language": "deu"
        }
      ]
    }
  ]
```

### Accession number

#### Description

Use for identification number assigned to a particular donation or acquisition of the analogue object.

#### JSON-LD example

```json
  "opaque:cco_accessionNumber": [
    "XA1234"
  ]
```

### Call number / Shelf mark

#### Description

Piece identifier, such as a call or other type of number.

#### JSON-LD example

```json
  "bf:shelfMark": [
    "XA1234"
  ]
```

### Physical location

#### Description

Location in the holding agency where the item is shelved or stored.

#### JSON-LD example

```json
  "bf:physicalLocation": [
    {
      "@value": "Some Collection, Some institution",
      "@language": "eng"
    }
  ]
```

### Inscription

#### Description

All marks or written words added to the object at the time of production or in its subsequent history, including signatures, dates, dedications, texts, and colophons, as well as marks, such as the stamps of silversmiths, publishers, or printers.

TODO component variants

#### JSON-LD example

:exclamation: The text should probably be under vra:text but it does not bring much (?) so I stay with skos:prefLabel.

```json
  "vra:hasInscription": [
    {
      "@type": "vra:Inscription",
      "skos:prefLabel": [
        {
          "@value": "I was here. F.",
          "@language": "eng"
        }
      ]
    },
    {
      "@type": "vra:Inscription",
      "skos:prefLabel": [
        {
          "@value": "Aus dem Nachlass Frh. Heinrich v. Ferstel",
          "@language": "deu"
        }
      ]
    }
  ]
```

### Material

#### Description

The substance of which a work or an image is composed. 

#### JSON-LD example

```json
  "vra:material": [
    {
      "@type": "vra:Material",
      "skos:prefLabel": [
        {
          "@value": "black marble",
          "@language": "eng"
        }
      ],
      "skos:exactMatch": [
        "http://vocab.getty.edu/aat/300011484"
      ]
    },
    {
      "@type": "vra:Material",
      "skos:prefLabel": [
        {
          "@value": "celluloid",
          "@language": "deu"
        }
      ]
    }
  ]
```

### Technique

#### Description

The production or manufacturing processes, techniques, and methods incorporated in the fabrication or alteration of the work or image.

TODO component variants

#### JSON-LD example

```json
  "vra:hasTechnique": [
    {
      "@type": "vra:Technique",
      "skos:prefLabel": [
        {
          "@value": "mural painting",
          "@language": "eng"
        }
      ],
      "skos:exactMatch": [
        "http://vocab.getty.edu/aat/300178677"
      ]
    },
    {
      "@type": "vra:Technique",
      "skos:prefLabel": [
        {
          "@value": "in mehreren Schichten aufgebaut",
          "@language": "deu"
        }
      ]
    }
  ]
```

### Width

#### Description

The width of the item.

#### JSON-LD example

```json
  "schema:width": [
    {
      "@type": "schema:QuantitativeValue",
      "schema:unitCode": [
        "CMT"
      ],
      "schema:value": [
        "10"
      ]
    }
  ]
```

### Height

#### Description

The height of the item.

#### JSON-LD example

```json
  "schema:height": [
    {
      "@type": "schema:QuantitativeValue",
      "schema:unitCode": [
        "CMT"
      ],
      "schema:value": [
        "10"
      ]
    }
  ]
```

### Depth

#### Description

The depth of the item.

#### JSON-LD example

```json
  "schema:depth": [
    {
      "@type": "schema:QuantitativeValue",
      "schema:unitCode": [
        "CMT"
      ],
      "schema:value": [
        "10"
      ]
    }
  ]
```

### Diameter

#### Description

The diameter of the item.

#### JSON-LD example

```json
  "vra:diameter": [
    {
      "@type": "schema:QuantitativeValue",
      "schema:unitCode": [
        "CMT"
      ],
      "schema:value": [
        "10"
      ]
    }
  ]
```

### Weight

#### Description

The weight of the product or person.

#### JSON-LD example

```json
  "schema:weight": [
    {
      "@type": "schema:QuantitativeValue",
      "schema:unitCode": [
        "KGM"
      ],
      "schema:value": [
        "10"
      ]
    }
  ]
```

### Provenance

#### Description

A statement of any changes in ownership and custody of the resource since its creation that are significant for its authenticity, integrity, and interpretation. The statement may include a description of any changes successive custodians made to the resource.

#### JSON-LD example

```json
  "dcterms:provenance": [
    {
      "@type": "dcterms:ProvenanceStatement",
      "skos:prefLabel": [
        {
          "@value": "bla bla bla",
          "@language": "deu"
        }
      ]
    }
  ]
```

### Georeference

#### Description

##### Spatial predicates

| Spatial predicates |
| :----- |
| dcterms:spatial |
| vra:placeOfCreation |
| vra:placeOfRepository |
| vra:placeOfSite |

#### JSON-LD example

```json
  "dcterms:spatial": [
    {
      "@type": "schema:Place",
      "skos:prefLabel": [
        {
          "@value": "Gloggnitz"
        }
      ],
      "rdfs:label": [
        {
          "@value": "Gloggnitz--Niederösterreich--Österreich--Europe--World"
        }
      ],
      "schema:geo": [
        {
          "@type": "schema:GeoCoordinates",
          "schema:latitude": [
            "47.6833"
          ],
          "schema:longitude": [
            "15.95"
          ]
        }
      ],
      "skos:exactMatch": [
        "http://vocab.getty.edu/tgn/7003182"
      ]
    },
    {
      "@type": "schema:Place",
      "skos:prefLabel": [
        {
          "@value": "Klokotnica",
          "@language": "sla"
        }
      ]
    }
  ]
```

### Scale

#### Description

The ratio of the dimensions of a form contained or embodied in a resource to the dimensions of the entity it represents, e.g. for images or cartographic resources.

#### JSON-LD example

```json
  "bf:scale": [
    {
      "@type": "bf:Scale",
      "skos:prefLabel": [
        {
          "@value": "1:20000"
        }
      ]
    }
  ]
```

### Subtitle language

#### Description

Languages in which subtitles/captions are available.

#### JSON-LD example

```json
  "schema:subtitleLanguage": [
    "ara",
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "Lebanese",
          "@language": "eng"
        },
        {
          "@value": "Libanesisch-Arabisch",
          "@language": "deu"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/vocabulary/MKXZ-SARM"
      ]
    }
  ]
```

### Available language

#### Description

A language someone may use with or at the item, service or place.

#### JSON-LD example

```json
  "schema:availableLanguage": [
    "ara",
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "Lebanese",
          "@language": "eng"
        },
        {
          "@value": "Libanesisch-Arabisch",
          "@language": "deu"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/vocabulary/MKXZ-SARM"
      ]
    }
  ]
```

### Format

#### Description

Technical specification relating to the encoding of a resource.

#### JSON-LD example

```json
"dce:format": [
  {
    "@type": "skos:Concept",
    "skos:exactMatch": [
      "https://pid.phaidra.org/vocabulary/FRJJ-4376"
    ],
    "skos:prefLabel": [
      {
        "@value": "DTS",
        "@language": "eng"
      }
    ]
  }
]
```

### Carrier type

#### Description

Relates a resource to a categorization reflecting a format of a storage medium and housing of a carrier in combination with a type of intermediation device required to view, play, run, etc., the content of a resource.

#### JSON-LD example

```json
  "rdau:P60048": [
    {
      "@type": "skos:Concept",
      "skos:prefLabel": [
        {
          "@value": "tape",
          "@language": "eng"
        },
        {
          "@value": "Tonband",
          "@language": "deu"
        }
      ],
      "skos:exactMatch": [
        "https://pid.phaidra.org/vocabulary/X627-FCV9"
      ]
    }
  ]
```
	
### Duration

#### Description

The duration of the item (movie, audio recording, event, etc.) in [ISO 8601 date format](https://en.wikipedia.org/wiki/ISO_8601#Durations).

#### JSON-LD example

```json
  "schema:duration": [
    "PT4M5S"
  ]
```

### File name

#### Description

The name of the file containing the Resource.

#### JSON-LD example

```json
  "ebucore:filename": [
    "test.jpg"
  ]
```

### MIME type

#### Description

To specify the MIME type of a resource.

#### JSON-LD example

```json
  "ebucore:hasMimeType": [
    "image/tiff"
  ]
```

### System fields

#### Description

These fields are meant to support system logic and are not relevant to the user.

| Name        | Predicate           | Usage  |
| ------------- | ------------- | ----- |
| Tag | phaidra:systemTag | a tag for the purpose of identification or to give other information |

#### JSON-LD example

```json
  "phaidra:systemTag": [
    "whatever"
  ]
```

# Namespaces	

| Vocabulary Name        | Abbreviation           | Vocabulary URL  |
| ------------- | ------------- | ----- |
| Phaidra | phaidra | https://phaidra.org/ontology/ |
| BIBFRAME (v.2) | bf |	http://id.loc.gov/ontologies/bibframe/ |
| LOC Standard Identifiers Scheme | ids | http://id.loc.gov/vocabulary/identifiers/ |
| The Bibliographic Ontology | bibo | http://purl.org/ontology/bibo/ |
| Bibliotek-o | bib |	https://bibliotek-o.org/ |
| Classification Schemes | classSchemes | http://id.loc.gov/vocabulary/classSchemes |
| DBPedia Ontology | dbo | http://dbpedia.org/ontology/  |
| Dublin Core Metadata Element Set, Version 1.1 | dce |	http://purl.org/dc/elements/1.1/ |
| DCMI Metadata Terms | dcterms | http://purl.org/dc/terms/ |
| DCMI Type Vocabulary | dcmitype | http://dublincore.org/documents/2000/07/11/dcmi-type-vocabulary/# |
| EBUCore | ebucore | https://www.ebu.ch/metadata/ontologies/ebucore/ebucore# |
| Europeana Data Model | edm | http://www.europeana.eu/schemas/edm/ |
| FOAF (Friend of a Friend) | foaf | http://xmlns.com/foaf/spec/# |
| OpaqueNamespace  | opaque | http://opaquenamespace.org/ [might change]  |
| Portland Common Data Model | pcdm |	http://pcdm.org/models# |
| RDA Unconstrained | rdau | http://rdaregistry.info/Elements/u/ |
| The RDF Concepts Vocabulary (RDF) | rdf | http://www.w3.org/1999/02/22-rdf-syntax-ns# |
| RDF Schema 1.1 | rdfs | https://www.w3.org/TR/rdf-schema/ |
| MARC Code List for Relators | relators | http://id.loc.gov/vocabulary/relators |
| Schema.org | schema |	http://schema.org/ |
| SKOS Simple Knowledge Organization System | skos | http://www.w3.org/2004/02/skos/core# |
| SKOS Simple Knowledge Organization System eXtension for Labels | skosxl | http://www.w3.org/2008/05/skos-xl |
| Standard Identifiers Scheme | identifiers | http://id.loc.gov/vocabulary/identifiers |
| The Funding, Research Administration and Projects Ontology | frapo | http://purl.org/cerif/frapo |
| EBUCore - the Dublin Core for media | ebucore | http://www.ebu.ch/metadata/ontologies/ebucore/ebucore |
| Academic Institution Internal Structure Ontology | aiiso | http://purl.org/vocab/aiiso/schema# |
| CiTO, the Citation Typing Ontology | cito | http://purl.org/spar/cito/ |
| Art and Rare Materials Core Ontology | arm | https://ld4p.github.io/arm/core/ontology/0.1/ |

# Resources
* [Samvera MODS to RDF Working Group: MODS to RDF Mapping Recommendations](https://goo.gl/SGCfev)
* [Predicate decision tree](https://docs.google.com/document/d/1oMvVlGuBwD5U1251oxNmTZn7WgkNTj6tF-k1hOYjnac/edit)
* [Notes to BIBFRAME title use](https://www.loc.gov/bibframe/docs/pdf/bf2-titles-march2017.pdf)
* [VRA Core](http://www.core.vraweb.org/)  
  * [imageOf example](http://core.vraweb.org/examples/html/example029_full.html)  
  * [TTL example](https://github.com/mixterj/VRA-RDF-Project/blob/master/data/sample/ttl/record2.ttl)
  * [Mapping of fcrepo3 attributes](https://github.com/fcrepo4-exts/migration-utils)
