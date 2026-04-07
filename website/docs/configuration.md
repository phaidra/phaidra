# Configuration

PHAIDRA has to be configured in two ways:

* `.env` file in the root of the phaidra-docker repository
* admin section of the frontend

## .env

To see what values need to be and can be present in .env please refer to the [README](https://github.com/phaidra/phaidra/blob/main/README.md) file in the git repository.

## /admin

If you log in to PHAIDRA using admin credentials (`PHAIDRA_ADMIN_USER`, `PHAIDRA_ADMIN_PASSWORD` in `.env`, `phaidraAdmin`/`12345` by default), you will see the link to admin section in navigation.

The configuration in admin is split into a *private* and *public* configuration. Private is basically API configuration and also conains credentials. Public is the configuration of the UI and API which is open and only defines information like name of the repository, controlled vocabularies, etc (so it can be sent to the clients in single-page-applications as well).

Most of the settings have an explanatory hint text, but some, like datastructures, need some more explanation/examples.

### CMS

In CMS section you can define/modify Vue templates which should be used on specific pages like Header, Main page, Impressum, etc.

You can only define the template here (which will be included via rutime compiler) if any special

### Datastructures

#### Org units

In PHAIDRA we use to define the organisational structure in our own persistent-identifier based data model. The reason is that on one hand, we do not always have access to an API providing this information about the organization, on the other hand the organisational structure can be changing without keeping track of the history, which would make management of the links difficult.

The org units is a simple json structure looking like this:

```json
[
  {
    "@id": "https://pid.phaidra.org/univie-org/1MPF-FAME",
    "@type": "foaf:Organization",
    "parent_id": "https://pid.phaidra.org/univie-org/-1",
    "skos:notation": "A-1",
    "skos:prefLabel": {
      "deu": "Universität Wien",
      "eng": "University of Vienna"
    },
    "subunits": [
      {
        "@id": "https://pid.phaidra.org/univie-org/1DVY-S9TG",
        "@type": "aiiso:Division",
        "parent_id": "https://pid.phaidra.org/univie-org/1MPF-FAME",
        "skos:notation": "A99999905",
        "skos:prefLabel": {
          "deu": "Fakultäten und Zentren",
          "eng": "Faculties and Centers"
        },
        "subunits": [
          {
            "@id": "https://pid.phaidra.org/univie-org/A43K-BCN0",
            "@type": "aiiso:Faculty",
            "parent_id": "https://pid.phaidra.org/univie-org/1DVY-S9TG",
            "skos:notation": "A40",
            "skos:prefLabel": {
              "deu": "Historisch-Kulturwissenschaftliche Fakultät",
              "eng": "Faculty of Historical and Cultural Studies"
            },
            "subunits": [
              {
                "@id": "https://pid.phaidra.org/univie-org/VX0F-ETVT",
                "@type": "aiiso:Institute",
                "parent_id": "https://pid.phaidra.org/univie-org/A43K-BCN0",
                "skos:notation": "A406",
                "skos:prefLabel": {
                  "deu": "Institut für Klassische Archäologie",
                  "eng": "Department of Classical Archaeology"
                },
                "subunits": [],
                "superunits": []
              },
              ...
            ],
            "superunits": []
          }
          ...
        ],
        "superunits": []
      }
      ...
    ],
    "superunits": []
  },
  {
    "@id": "https://my-fqdn/my-namespace/9999-9999",
    "@type": "foaf:Organization",
    "parent_id": "https://my-fqdn/my-namespace/-1",
    "skos:notation": "EXT000",
    "skos:prefLabel": {
      "eng": "Some other root element (eg External organisations)"
    },
    "subunits": [
      ...
    ],
    "superunits": []
  }
]
```

#### Vocabularies

There are 3 ways in which a controlled vocabulary can be integrated to PHAIDRA.

* via external API (examples: Basisklassifikation, GND, Geonames, ...)
* via PHAIDRA API (examples: Thema, ISO-639-2, ...)
* directly in the `vocabulary` module of the [phaidra-vue-components store](https://github.com/phaidra/phaidra/blob/main/src/phaidra-vue-components/src/store/modules/vocabulary.js).

The `vocabularies` configuration field enables the overload of any of the vocabularies defined in the store.

Here's an example of a configuration which would only allow 2 licenses in the list of licenses used in metadata editor / submit form:

```json
{
  "licenses": {
    "terms": [
      {
        "@id": "http://creativecommons.org/publicdomain/mark/1.0/",
        "skos:prefLabel": {
          "eng": "Public Domain Mark 1.0",
          "ita": "Marchio di Pubblico Dominio 1.0"
        },
        "img": "pdm.png"
      },
      {
        "@id": "https://spdx.org/licenses/MIT/",
        "skos:prefLabel": {
          "eng": "MIT License",
          "ita": "Licenza MIT"
        },
        "img": "mit-license-icon.png"
      }
    ],
    "loaded": true
  }
}
```

#### Object types for resource types (ot4rt)

If you add/modify object type vocabulary you might need to change how object types (like Photography) are mapped to resource types (like Image) in the submit form. The default value of this structure can also be found in [phaidra-vue-components store](https://github.com/phaidra/phaidra/blob/main/src/phaidra-vue-components/src/store/modules/vocabulary.js).

Here's an example:

```json
{
  "https://pid.phaidra.org/vocabulary/44TN-P1S0": [
    "https://pid.phaidra.org/vocabulary/7CAB-P987",
    "https://pid.phaidra.org/vocabulary/4YS3-8T2K"
  ],
  "https://pid.phaidra.org/vocabulary/8YB5-1M0J": [
    "https://pid.phaidra.org/vocabulary/F4JN-ZST0",
    "https://pid.phaidra.org/vocabulary/8KGA-CH97"
  ]
}
```

#### i18n overrides

This structure allows to change/add i18n translations used throughout the frontend.

Example:

```json
{
  "deu": {
    "University of Veterinary Medicine Vienna": "Veterinärmedizinische Universität Wien"
  }
}
```

#### Facet queries

This structure defines what filters are used on the search page. The structure defines the filter and the Solr query associated with it.

Two exceptions to the structure are the `created` and `a11y` which you can see in the example. These are dynamically created, so you can only remove them (if the facet ID isn't present in the structure, it won't be generated), but not modify them.

Example:

```json
[
  {
    "exclusive": true,
    "field": "datastreams",
    "id": "datastreams",
    "label": "Access",
    "queries": [
      {
        "id": "restricted",
        "label": "Restricted",
        "query": "(isrestricted:1 OR datastreams:POLICY)"
      },
      {
        "id": "unrestricted",
        "label": "Unrestricted",
        "query": "-isrestricted:1 AND -datastreams:POLICY"
      }
    ],
    "resetable": true,
    "show": false
  },
  {
    "field": "tcreated",
    "id": "created",
    "label": "Date"
  },
  {
    "id": "a11y",
    "label": "Accessibility"
  }
]
```

#### Affiliations

If using SAML/Shibboleth affiliations to restrict access to objects, here's where you can define which affiliations are available to choose from when restricting access.

Example

```json
[
  "member@univie.ac.at",
  "staff@univie.ac.at",
  "student@univie.ac.at",
  "faculty@univie.ac.at"
]
```