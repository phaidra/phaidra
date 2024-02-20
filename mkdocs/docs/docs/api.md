# API Usage Guide

## Introduction

PHAIDRA API is a REST(ish) application interface implementing most of core PHAIDRA logic and processes.

The most frequent usage of PHAIDRA API from external developers is the ingest of object(s).

You can refer to the [OpenAPI documentation of PHAIDRA API](https://github.com/phaidra/phaidra-api/blob/master/public/docs/openapi.json) on your instance under the URL /api/openapi, e.g. http://localhost:8899/api/openapi.

If you are developing a frontend or an upload script, consider [using PHAIDRA Vue Components](#using-phaidra-vue-components) (or rather the javascripts inside) to manipulate the metadata. See the example [here](#using-phaidra-vue-components).

## Creating simple objects

Creating a digital object consists of multiple steps, but you can create a digital object in PHAIDRA using just on call.

Here is an example for creating a picture. If you want to create another object type, you simply have to use the corresponding endpoint (possibilities are: picture, audio, video, document, unknown, collection, container, page), the parameters are the same.

[POST http://localhost:8899/api/picture/create](http://localhost:8899/api/openapi#/object-basics/post_picture_create)

| Param | Value |
| ----- | ----- |
| file | [upload file via "multipart/form-data"] |
| metadata | See JSON-LD example |
| mimetype | optional: if not provided, heuristics is used on server side |

Request example:
```bash
curl -X POST -u pone:1234 -F "file=@dashboard.png" -F metadata=@metadata.json http://localhost:8899/api/picture/create
```

Response example:
```json
{"alerts":[],"pid":"o:1","status":200}
```

Possible content models
| Content model | Content model internal | Method |
| ----- | ----- | ----- |
| picture | cmodel:Picture | picture/create |
| document | cmodel:PDFDocument | document/create |
| video | cmodel:Video | video/create |
| audio | cmodel:Audio | audio/create |
| collection | cmodel:Collection | collection/create |
| data | cmodel:Asset | unknown/create |

JSON-LD example:
```json
{
  "metadata": {
    "json-ld": {
      "edm:hasType": [
        {
          "@type": "skos:Concept",
          "skos:exactMatch": [
            "https://pid.phaidra.org/vocabulary/7CAB-P987"
          ],
          "skos:prefLabel": [
            {
              "@language": "eng",
              "@value": "still image"
            }
          ]
        }
      ],
      "dce:title": [
        {
          "@type": "bf:Title",
          "bf:mainTitle": [
            {
              "@value": "Test object",
              "@language": "eng"
            }
          ]
        }
      ],
      "role:aut": [
        {
          "@type": "schema:Person",
          "schema:familyName": [
            {
              "@value": "Max"
            }
          ],
          "schema:givenName": [
            {
              "@value": "Mustermann"
            }
          ]
        }
      ],
      "dce:subject": [
        {
          "@type": "skos:Concept",
          "skos:prefLabel": [
            {
              "@value": "test",
              "@language": "eng"
            }
          ]
        },
        {
          "@type": "skos:Concept",
          "skos:prefLabel": [
            {
              "@value": "Test",
              "@language": "deu"
            }
          ]
        }
      ],
      "bf:note" : [
        {
           "skos:prefLabel" : [
              {
                 "@value" : "A test object.",
                 "@language" : "eng"
              }
           ],
           "@type" : "bf:Summary"
        }
      ],
      "dcterms:language" : [
        "eng"
      ],
      "ebucore:filename": [
        "dashboard.png"
      ],
      "ebucore:hasMimeType": [
        "image/png"
      ],
      "edm:rights": [
        "http://rightsstatements.org/vocab/InC/1.0/"
      ]
    }
  }
}
```
For a description of the metadata format, see [Metadata](/docs/metadata/)

Additionally, metadata hash can contain:

#### Order of members

Applicable for container and collection

```json
"membersorder": [ 
    { 
        "member": "member_foo", 
        "pos": "1"
    },
    { 
        "member": "member_bar", 
        "pos": "2"
    }  
]
```

#### Access rights definition

This example restricts access to a particular username.
```json
"rights": {
  "username": [
    {
      "value": "username",
      "expires": "2026-08-25T14:31:34Z"
    }
  ]
}
```
Access can also be restricted to faculties, institutes and groups.
```json
"rights": {
  "department": [
    "A421"
  ],
  "faculty": [
    {
      "expires": "2026-03-18T00:00:00.000Z",
      "value": "A51"
    },
    "A-1"
  ],
  "gruppe": [
    "8096BF32-DE44-11E6-A167-ECEC734D5710"
  ],
  "username": [
    "username1",
    {
      "expires": "2020-03-28T00:00:00.000Z",
      "value": "usernam2"
    }
  ]
}
```

#### Owner

The object's ownership will be transferred to `ownerid` after the object was created. This allows for using another account for the upload itself. The accounts which are allowed to transfer ownership need to be configured in PhaidraAPI.json (contact your Phaidra support if your instance is hosted and you need this feature).

```json
"ownerid": "projectusername"
```

## Creating container objects

### Creating an empty container

```bash
curl -X POST -u pone:1234 "http://localhost:8899/api/container/create" -F "metadata=@cont_metadata.json"

{"alerts":[],"pid":"o:1","status":200}
```

Container metadata example: cont_metadata.json
```json
{ 
  "metadata": { 
    "json-ld": {
        "dcterms:type": [
          {
            "@type": "skos:Concept",
            "skos:exactMatch": [
              "https://pid.phaidra.org/vocabulary/8MY0-BQDQ"
            ],
            "skos:prefLabel": [
              {
                "@language": "eng",
                "@value": "container"
              }
            ]
          }
        ],
        "edm:hasType": [
         {
            "@type": "skos:Concept",
            "skos:prefLabel": [
              {
                "@value": "interview",
                "@language": "eng"
              }
            ],
            "skos:exactMatch": [
              "https://pid.phaidra.org/vocabulary/8KGA-CH97"
            ]
          }
        ],
        "dce:title": [
          {
            "@type": "bf:Title",
            "bf:mainTitle": [
              {
                "@value": "test container",
                "@language": "eng"
              }
            ]
          }
        ]
      }
    }
  }
```
Container metadata should be interpreted as parent metadata record for the members, ie. all container metadata apply for members too unless re-defined on member level.

### Creating a member (see [Creating simple objects](creating-simple-objects))

```bash
curl -X POST -u pone:1234 "http://localhost:8899/api/document/create" -F "metadata=@foo_metadata.json" -F "file=@test.wav" -F "mimetype=audio/wav"

{"alerts":[],"pid":"o:2","status":200}
```

Member metadata example: foo_metadata.json
```json
{
  "metadata": {
    "json-ld": {
      "dcterms:type": [
        {
          "@type": "skos:Concept",
          "skos:exactMatch": [
            "https://pid.phaidra.org/vocabulary/8YB5-1M0J"
          ],
          "skos:prefLabel": [
            {
              "@language": "eng",
              "@value": "sound"
            }
          ]
        }
      ],
      "dce:title": [
        {
          "@type": "bf:Title",
          "bf:mainTitle": [
            {
              "@value": "My title",
              "@language": "eng"
            }
          ]
        }
      ],
      "schema:duration": [
        "PT1M30S"
      ],
      "ebucore:filename": [
        "interview.wav"
      ],
      "ebucore:hasMimeType": [
        "audio/wav"
      ],
      "edm:rights": [
        "http://rightsstatements.org/vocab/InC/1.0/"
      ]
    }
  }
}
```

### Add container member to container
```bash
curl -X POST -u pone:1234 "http://localhost:8899/api/object/o:1/relationship/add" -F "predicate=http://pcdm.org/models#hasMember" -F "object=info:fedora/o:2"

{"alerts":[{"msg":"true","type":"success"}],"status":200}
```

### Creating a container with members
```bash
curl -X POST -u pone:1234 "http://localhost:8899/api/container/create" -F "metadata=@cont_metadata.json" -F "member_foo=@test.wav" -F "member_bar=@test1.wav"
```

In this case, the metadata do not have the structure 
metadata->json-ld->{predicates}

but 

metadata->json-ld->container->{predicates} 

metadata->json-ld->member_foo->{predicates} 

metadata->json-ld->member_bar->{predicaes}

etc.

Example:
```json
{ 
  "metadata": { 
    "json-ld": {
      "container": {
        "dcterms:type": [
          {
            "@type": "skos:Concept",
            "skos:exactMatch": [
              "https://pid.phaidra.org/vocabulary/8MY0-BQDQ"
            ],
            "skos:prefLabel": [
              {
                "@language": "eng",
                "@value": "container"
              }
            ]
          }
        ],
        "edm:hasType": [
         {
          "@type": "skos:Concept",
          "skos:prefLabel": [
            {
              "@value": "interview",
              "@language": "eng"
            }
          ],
          "skos:exactMatch": [
            "https://pid.phaidra.org/vocabulary/8KGA-CH97"
          ]
         }
        ],
        "dce:title": [
          {
            "@type": "bf:Title",
            "bf:mainTitle": [
              {
                "@value": "test container",
                "@language": "eng"
              }
            ]
          }
        ]
      },
      "member_foo": {
        "dcterms:type": [
          {
            "@type": "skos:Concept",
            "skos:exactMatch": [
              "https://pid.phaidra.org/vocabulary/8YB5-1M0J"
            ],
            "skos:prefLabel": [
              {
                "@language": "eng",
                "@value": "sound"
              }
            ]
          }
        ],
        "dce:title": [
          {
            "@type": "bf:Title",
            "bf:mainTitle": [
              {
                "@value": "My title",
                "@language": "eng"
              }
            ]
          }
        ],
        "schema:duration": [
          "PT1M30S"
        ],
        "ebucore:filename": [
          "test.wav"
        ],
        "ebucore:hasMimeType": [
          "audio/wav"
        ],
        "edm:rights": [
          "http://rightsstatements.org/vocab/InC/1.0/"
        ]
      },
      "member_bar": {
        "dcterms:type": [
          {
            "@type": "skos:Concept",
            "skos:exactMatch": [
              "https://pid.phaidra.org/vocabulary/8YB5-1M0J"
            ],
            "skos:prefLabel": [
              {
                "@language": "eng",
                "@value": "sound"
              }
            ]
          }
        ],
        "dce:title": [
          {
            "@type": "bf:Title",
            "bf:mainTitle": [
              {
                "@value": "track 2",
                "@language": "deu"
              }
            ]
          }
        ],
        "schema:duration": [
          "PT1M30S"
        ],
        "ebucore:filename": [
          "test2.wav"
        ],
        "ebucore:hasMimeType": [
          "audio/wav"
        ],
        "edm:rights": [
          "http://rightsstatements.org/vocab/InC/1.0/"
        ]
      }
    }
  } 
}
```

#### Relationships

You can add "relationships" to "metadata" where you can define a specific relationship between the member (referred to as `member_<key>`) and the container (referred to as `container`), eg
```json
"relationships": [ 
    { 
        "s": "member_foo", 
        "p": "http://phaidra.org/XML/V1.0/relations#isThumbnailFor", 
        "o": "container"
    } 
]
```
The `http://pcdm.org/models#hasMember` relationship is added automatically for members.


## Managing relationships
The add or remove a relationship, you can use the following calls.
See the [Digital Object](/docs/digital-object/) for types of relationships.

[POST http://localhost:8899/api/{pid}/relationship/add](http://localhost:8899/api/openapi#/relationships/post_object__pid__relationship_add)

Adding some system relationships (like hasModel) might be restricted.

| Param | Value |
| ----- | ----- |
| predicate | the relationship (eg: 'info:fedora/fedora-system:def/model#hasModel' or 'http://phaidra.org/XML/V1.0/relations#isBackSideOf') |
| object | the value or the identifier of the related object in the repository  (eg: 'info:fedora/cmodel:Picture' or 'info:fedora/o:1' ) |

Example
```bash
curl -X POST -u pone:1234 "http://localhost:8899/api/object/o:2/relationship/add" -F "predicate=http://phaidra.org/XML/V1.0/relations#isBackSideOf" -F "object=info:fedora/o:1"
```

Response
```json
{
  "alerts": [],
  "status": 200
}
```

[POST http://localhost:8899/api/{pid}/relationship/remove](http://localhost:8899/api/openapi#/relationships/post_object__pid__relationship_remove)

Removing some system relationships (like hasModel) might be restricted.
See the [Digital Object](/docs/digital-object/) for types of relationships.

| Param | Value |
| ----- | ----- |
| predicate | the relationship (eg: 'info:fedora/fedora-system:def/model#hasModel' or 'http://phaidra.org/XML/V1.0/relations#isBackSideOf') |
| object | the value or the identifier of the related object in the repository  (eg: 'info:fedora/cmodel:Picture' or 'info:fedora/o:1' ) |

Example
```bash
curl -X POST -u pone:1234 "http://localhost:8899/api/object/o:2/relationship/remove" -F "predicate=http://phaidra.org/XML/V1.0/relations#isBackSideOf" -F "object=info:fedora/o:1"
```

Response
```json
{
  "alerts": [],
  "status": 200
}
```


## Changing object properties

[POST object/{pid}/modify](http://localhost:8899/api/openapi#/object-advanced/post_object__pid__modify)

Possible parameters (all are optional)

| Param | Value |
| ----- | ----- |
| state | A (= Active), I (= Inactive) |
| ownerid | owner's  username |

Example:
```bash
curl -X POST -u pone:1234 http://localhost:8899/api/object/o:1/modify -F 'state=A'
```

Response
```json
{
  "alerts":[],
  "status":200
}
```

## Search

PHAIDRA users Solr as it's search engine. You can query Solr via the [/solr/select endpoint](http://localhost:8899/api/openapi#/search/post_search_select). The parameters are the same as for the /select endpoint of Solr, see [Solr common query parameters](https://solr.apache.org/guide/solr/latest/query-guide/common-query-parameters.html) for more information.

The return value is directly proxied from Solr too.

Since the Solr query can be considerably large, the method is also available via POST.

Example:
```bash
curl -X GET -u pone:1234 "http://localhost:8899/api/search/select?q=*:*"
```

## Retrieving metadata

The most convenient way of retrieving metadata is by using the [/object/{pid}/info endpoint](http://localhost:8899/api/openapi#/object-basics/get_object__pid__info). This will deliver all the indexed data as well as the content of metadata datastreams (e.g. JSON-LD), plus all the related objects (e.g. previous versions, container members, etc) with their index data (with the exception of collection members - use "fq=ismemberof:'o:123'" search query to efficiently get collection members and their index data from search index).

Example:
```bash
curl -X GET -u pone:1234 "http://localhost:8899/api/object/o:1/info"
```

## Displaying objects

PHAIDRA API takes care of providing a web-friendly display endpoint for the objects, where possible. Even if every type of object has a different view, the URL is the same for obtaining thumbnail as it is obtaining the viewer/player.

For the thumbnail, you can use the [/object/{pid}/thumbnail endpoint](http://localhost:8899/api/openapi#/object-basics/get_object__pid__thumbnail) and for the viewer/player the [/object/{pid}/preview endpoint](http://localhost:8899/api/openapi#/object-basics/get_object__pid__preview).

The preview endpoint will try to use the WEBVERSION, if any was provided and it will show a load button instead of the preview if the object size is beyond certain limit. This endpoint is meant to be easily embedded in iframes (in fact, PHAIDRA UI is using it too). If the object is restricted, the preview will not work without being logged into PHAIDRA or if the page with the iframe comes from a different domain (since PHAIDRA session cookies will not be passed).

Example: http://localhost:8899/api/object/o:1/preview


## OAI-PMH

The OAI-PMH endpoint is available at [/oai](http://localhost:8899/api/openapi#/oai-pmh/get_oai) URL. See the [OAI-PMH protocol](https://www.openarchives.org/pmh/) for parameters.

For the objects to be available in the OAI interface, 

1) sets needs to be defined in the mongo database of PHAIDRA API
2) the updateOai script needs to run (it's set up as a cronjob that runs every night)

Here is an example of a set definition:

```
[
  {
    "setSpec": "driver",
    "setName": "driver",
    "query": "-hassuccessor:* AND -ismemberof:[\"\" TO *]",
    "setDescription": {
      "dc_creator": [
        "PHAIDRA"
      ],
      "dc_description": [
        "PHAIDRA supports the Open Access Policy of the University of Vienna. The Open Access Collection contains freely available texts, pictures, videos and audio files."
      ],
      "dc_title": [
        "PHAIDRA Open Access Collection"
      ]
    },
    "created": "2020-02-19T12:00:00.000Z"
  }
]
```

The ***query** field is a query definition for the Solr search engine. 

The definition in the example selects objects which
* are not older versions
* are not members of a container

The setSpec field defines the name of the set under which the objects in the OAI-PMH endpoint can be found.

Example:
```bash
curl -X GET "http://localhost:8899/api/oai?verb=ListRecords&metadataPrefix=oai_dc"
```

## Using PHAIDRA Vue Components

Let's assume we want to parse a CSV file and use the metadata inside to bulk upload objects to PHAIDRA. Here's an example how we can do this using parts of PHAIDRA Vue Components library.

First, we need to import the relevant parts.

```js
import fieldslib from 'phaidra-vue-components/src/utils/fields'
import jsonld from 'phaidra-vue-components/src/utils/json-ld'
import vocutils from 'phaidra-vue-components/src/utils/vocabulary'
```

And some utilities

```js
import base64 from 'base-64'
import axios from 'axios'
import md5File from 'md5-file'
```

Now we'll define the form which will contain the metadata fields.

```js
  let metadata = { 'metadata': {} }
  const digFields = []
  const form = {
    sections: [
      {
        title: 'container-dig',
        type: 'digitalobject',
        id: 1,
        fields: digFields
      }
    ]
  }
```

Assuming we have read the necessary information from CSV, e.g. a title, let's add a title field to the form and set it's value. (See the [fields.js](https://github.com/phaidra/phaidra/blob/main/src/phaidra-vue-components/src/utils/fields.js) for the list of possible fields)

```js
  let title = 'My value from CSV'
  let f = fieldslib.getField('title')
  f.title = title
  f.language = 'eng'
  digFields.push(f)
```

Now let the jsonld js library transform the form to the JSON-LD schema we need to PHAIDRA

```js
  let metadata = { 'metadata': {} }
  metadata['metadata']['json-ld'] = jsonld.form2json(form)
```

That's it. Now we only need to upload the metadata along with the data.

You don't have to provide the checksum, but it is recommended, as if you do, the Fedora Repository will checksum the uploaded file as part of the upload method and returns an error if the checksums do not match.

```js
  let md = JSON.stringify(metadata)
  let md5sum = md5File.sync('picture.tif')

  const response = await axios.post('http://localhost:8899/api/picture/create', {
      'mimetype': 'image/tiff',
      'metadata': md,
      'checksumtype': 'MD5',
      'checksum': md5sum,
      file: fs.createReadStream('picture.tif'))
    }, {
      headers: {
        'Authorization': 'Basic ' + base64.encode('pone:1234'),
        'Content-Type': 'multipart/form-data'
      }
    }
  )
```