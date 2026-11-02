import { defineStore } from 'pinia'

const metadataFieldsOverview = [
  {
    "title": "Metadata fields",
    "open": true,
    "fields": [
      {
        "title": "Instance of work",
        "predicate": "bf:instanceOf",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Work the Instance described instantiates or manifests"
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:instanceOf",
          "dce:title",
          "bf:mainTitle"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:instanceOf\": [\n    {\n      \"@type\": \"schema:CreativeWork\",\n      \"dce:title\": [\n        {\n          \"@type\": \"bf:Title\",\n          \"bf:mainTitle\": [\n            {\n              \"@value\": \"Example work\",\n              \"@language\": \"eng\"\n            }\n          ]\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Access mode",
        "predicate": "schema:accessMode",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The human sensory perceptual system or cognitive faculty through which a person may process or perceive the intellectual content of a resource, not including any adaptations of the content (e.g., text alternatives for images)"
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "auditory, textual, visual"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:accessMode",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Access mode vocabulary",
            "entries": [
              [
                "Supported values"
              ],
              [
                "auditory"
              ],
              [
                "textual"
              ],
              [
                "visual"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"schema:accessMode\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"auditory\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"auditory\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "accessMode",
        "vocabularyNote": ""
      },
      {
        "title": "Accessibility control",
        "predicate": "schema:accessibilityControl",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Identifies input methods that are sufficient to fully control the described resource"
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "fullKeyboardControl, fullMouseControl, fullSwitchControl, fullTouchControl, fullVideoControl, fullVoiceControl"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:accessibilityControl",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Accessibility control vocabulary",
            "entries": [
              [
                "Supported values"
              ],
              [
                "fullKeyboardControl"
              ],
              [
                "fullMouseControl"
              ],
              [
                "fullSwitchControl"
              ],
              [
                "fullTouchControl"
              ],
              [
                "fullVideoControl"
              ],
              [
                "fullVoiceControl"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"schema:accessibilityControl\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"fullKeyboardControl\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"fullKeyboardControl\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "accessibilityControl",
        "vocabularyNote": ""
      },
      {
        "title": "Accessibility feature",
        "predicate": "schema:accessibilityFeature",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Content features of the resource, such as accessible media, alternatives and supported enhancements for accessibility"
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "annotations, ARIA, bookmarks, index, pageBreakMarkers, pageNavigation, readingOrder, structuralNavigation, tableOfContents, taggedPDF, alternativeText, audioDescription, closedCaptions, describedMath, longDescription, openCaptions, rubyAnnotations, signLanguage, transcript, displayTransformability, synchronizedAudioText, timingControl, unlocked, ChemML, latex, MathML, ttsMarkup, highContrastAudio, highContrastDisplay, none"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:accessibilityFeature",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Accessibility feature vocabulary",
            "entries": [
              [
                "Supported values"
              ],
              [
                "annotations"
              ],
              [
                "ARIA"
              ],
              [
                "bookmarks"
              ],
              [
                "index"
              ],
              [
                "pageBreakMarkers"
              ],
              [
                "pageNavigation"
              ],
              [
                "readingOrder"
              ],
              [
                "structuralNavigation"
              ],
              [
                "tableOfContents"
              ],
              [
                "taggedPDF"
              ],
              [
                "alternativeText"
              ],
              [
                "audioDescription"
              ],
              [
                "closedCaptions"
              ],
              [
                "describedMath"
              ],
              [
                "longDescription"
              ],
              [
                "openCaptions"
              ],
              [
                "rubyAnnotations"
              ],
              [
                "signLanguage"
              ],
              [
                "transcript"
              ],
              [
                "displayTransformability"
              ],
              [
                "synchronizedAudioText"
              ],
              [
                "timingControl"
              ],
              [
                "unlocked"
              ],
              [
                "ChemML"
              ],
              [
                "latex"
              ],
              [
                "MathML"
              ],
              [
                "ttsMarkup"
              ],
              [
                "highContrastAudio"
              ],
              [
                "highContrastDisplay"
              ],
              [
                "none"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"schema:accessibilityFeature\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"alternativeText\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"alternativeText\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "accessibilityFeature",
        "vocabularyNote": ""
      },
      {
        "title": "Accessibility hazard",
        "predicate": "schema:accessibilityHazard",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A characteristic of the described resource that is physiologically dangerous to some users. Related to WCAG 2.0 guideline 2.3."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "flashing, noFlashingHazard, motionSimulation, noMotionSimulationHazard, sound, noSoundHazard, none"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:accessibilityHazard",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Accessibility hazard vocabulary",
            "entries": [
              [
                "Supported values"
              ],
              [
                "flashing"
              ],
              [
                "noFlashingHazard"
              ],
              [
                "motionSimulation"
              ],
              [
                "noMotionSimulationHazard"
              ],
              [
                "sound"
              ],
              [
                "noSoundHazard"
              ],
              [
                "none"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"schema:accessibilityHazard\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"noFlashingHazard\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"noFlashingHazard\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "accessibilityHazard",
        "vocabularyNote": ""
      },
      {
        "title": "Study plan",
        "predicate": "frapo:isOutputOf",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Study plan that is associated with the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "frapo:isOutputOf",
          "skos:prefLabel",
          "skos:notation"
        ],
        "lists": [],
        "jsonLdExample": "  \"frapo:isOutputOf\": [\n    {\n      \"@type\": \"aiiso:Programme\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"LA Musikerziehung LA Physik (ASVS)\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"skos:notation\": [\n        \"spl-26-593-288\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "studyplans",
        "vocabularyNote": ""
      },
      {
        "title": "Abstract",
        "predicate": "bf:Summary",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Summary or abstract of the described resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "In case of textual resources as articles, reviews, etc., you may provide an abstract of the content.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Description",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Accession number",
        "predicate": "opaque:cco_accessionNumber",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The identification number assigned to a particular donation or acquisition of the analogue object."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the identification number assigned to a particular donation or acquisition of the object.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "opaque:cco_accessionNumber"
        ],
        "lists": [],
        "jsonLdExample": "  \"opaque:cco_accessionNumber\": [\n    \"XA1234\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Associated with",
        "predicate": "rdax:P00009",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The corporate body associated with the object."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the corporate body associated with your resource. <br> You have two options: you can select the value from the drop-down list, or you can click on the diagram icon on the right and navigate the organizational structure of your institution.",
              "level2": "",
              "level3": "Tracking down people and institutions associated with the resource can be useful to allow reuse, especially if data has restricted access or it is no longer available. These are cases where human intervention is involved (e.g. sending an email to the metadata owner or calling to receive instructions). Fill in the field to provide an explicit contact in the metadata."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdax:P00009",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"rdax:P00009\": [\n    {\n      \"@type\": \"aiiso:Faculty\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Fakultät für Informatik\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/univie-org/WWYA-96YK\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "orgunits",
        "vocabularyNote": ""
      },
      {
        "title": "Available language",
        "predicate": "schema:availableLanguage",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "An additional available language someone may use with audio and video resources."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field when your resource can be additionally viewed, played, run, etc., in languages other than the main one.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"http://id.loc.gov/vocabulary/languages\">MARC List for Languages</a> <br> <a href=\"https://vocab.phaidra.org/vocabulary/WKFZ-VG0C\">Language PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:availableLanguage",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:availableLanguage\": [\n    \"ara\",\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Lebanese\",\n          \"@language\": \"eng\"\n        },\n        {\n          \"@value\": \"Libanesisch-Arabisch\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/vocabulary/MKXZ-SARM\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "lang",
        "vocabularyNote": ""
      },
      {
        "title": "Event",
        "predicate": "ebucore:hasRelatedEvent",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A property to identify the Events, all real or fictional"
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field to describe an event related to the resource. Provide at least an event name or an identifier. <br> This field consists of six parts: <ul> <br> <li><b>Name</b>: <br> The name of the event and its language.</li><br><li><b>Description</b>: <br> A multilingual description of the event.</li><br><li><b>Number of conference</b>: <br> The sequence number when the event is a recurring conference.</li><br><li><b>Place</b>: <br> The location associated with the event.</li><br><li><b>Date from / Date to</b>: <br> The start and end dates of the event.</li><br><li><b>Type of identifier / Identifier</b>: <br> A persistent or external identifier and its identifier scheme.</li></ul>",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": ""
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "ebucore:hasRelatedEvent",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"ebucore:hasRelatedEvent\": [\n    {\n      \"@type\": \"ebucore:Event\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Example event\",\n          \"@language\": \"eng\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Sound characteristic",
        "predicate": "bf:soundCharacteristic",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Technical specification relating to the encoding of sound in a resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": ""
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:soundCharacteristic"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:soundCharacteristic\": [\n    {\n      \"@value\": \"stereo\",\n      \"@language\": \"eng\"\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Audience",
        "predicate": "dcterms:audience",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The entity for whom the resource is intended or useful."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the class of target people (e.g. a restriction by age) for whom the object is intended or useful. <br> You can either enter your own value or select it from the controlled list.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/en/collections/T465-XDJS.html\">Audience PHAIDRA Vocabulary </a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:audience",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "\"dcterms:audience\": [\n  {\n    \"@type\": \"skos:Concept\",\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"ab 16 Jahre\",\n        \"@language\": \"deu\"\n      } \n    ]\n  }\n]",
        "parentTitle": null,
        "vocabularyId": "audience",
        "vocabularyNote": ""
      },
      {
        "title": "Awards",
        "predicate": "bf:awards",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information on awards associated with the described resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "If existing, you can provide information on an award associated with the described resource.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:awards",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "\"bf:awards\": [\n  {\n    \"@type\": \"skos:Concept\",\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"Butaca Awards 2002: Millor actor català de cinema\"\n      } \n    ]\n  },\n  {\n    \"@type\": \"skos:Concept\",\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"Karlovy Vary International Film Festival 2002: Special Mention\",\n        \"@language\": \"eng\"\n      } \n    ]\n  }\n]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Carrier type",
        "predicate": "rdau:P60048",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The format of a storage medium."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "This field expresses the storage medium of the physical source. <br>Select a value from the drop-down list. In case the value you want to select is not in the list, choose <i>Other</i> and notify the metadata administrators.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/YGE3-S9WD\">Carrier type PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdau:P60048",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"rdau:P60048\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"tape\",\n          \"@language\": \"eng\"\n        },\n        {\n          \"@value\": \"Tonband\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/vocabulary/X627-FCV9\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "carriertype",
        "vocabularyNote": ""
      },
      {
        "title": "Level of description",
        "predicate": "phaidra:levelOfDescription",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Can be used inside \"Complex subject\" to specify what the subject metadata are describing."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Important in cases where the same metadata fields have to be used on different description levels (ie dimensions - of the photography vs dimensions of the instrument depicted on the photography -, creation date, etc).",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/W2ZN-QEF6\">Level of description</a>. Current values: <a href=\"https://vocab.phaidra.org/vocabulary/HQ7N-3Q2W\">Digitized object</a> or <a href=\"https://vocab.phaidra.org/vocabulary/TG30-5EM3\">Represented object</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "phaidra:levelOfDescription",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"phaidra:levelOfDescription\": [ \n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Digitized object\",\n          \"@language\": \"eng\"\n        },\n        {\n          \"@value\": \"Digitalisiertes Objekt\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/vocabulary/HQ7N-3Q2W\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "levelofdescription",
        "vocabularyNote": ""
      },
      {
        "title": "Citation",
        "predicate": "cito:cites cito:isCitedBy cito:citesAsDataSource",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A reference to another resource. A citation may be either direct and explicit (as in the reference list of a journal article), indirect (e.g. a citation to a more recent paper by the same research group on the same topic), or implicit (e.g. as in artistic quotations or parodies, or in cases of plagiarism)."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "With this field you can provide a bibliographic reference for your resource. You first need to specify the type of citation (Cites or Is cited by) and then format the citation in the available subfields.",
              "level2": "When the resource you are uploading is research data, make sure you state the scholarly output of your dataset. Explicitly defining the link between dataset and the related publication is in compliance with Open Access policies. It also ensures faster dissemination of the dataset, e.g. in the OpenAIRE portal.",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "cito:cites",
          "cito:isCitedBy",
          "cito:citesAsDataSource",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Citation predicates",
            "entries": [
              [
                "Citation predicates"
              ],
              [
                "cito:cites"
              ],
              [
                "cito:isCitedBy"
              ],
              [
                "cito:citesAsDataSource"
              ]
            ]
          }
        ],
        "jsonLdExample": "\"cito:cites\": [\n  {\n    \"@type\": \"rdfs:Resource\",\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"Plakat Phaidra: Phaidra – digitale Bestände effizient aufbewahren\",\n        \"@language\": \"deu\"\n      }\n    ],\n    \"skos:exactMatch\": [\n       \"https://phaidra.univie.ac.at/o:359991\"\n    ]\n  },\n  {\n    \"@type\": \"rdfs:Resource\",\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"Kopacsi, Sandor. (2017, May). COAR Resource Type Vocabulary in the Classification Server of Phaidra. Zenodo.\",\n        \"@language\": \"eng\"\n      }\n    ],\n    \"skos:exactMatch\": [\n       \"doi:10.5281/zenodo.579874\"\n    ]\n  },\n  {\n    \"@type\": \"rdfs:Resource\",\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"Phaidra Folder\"\n      }\n    ],\n    \"skos:exactMatch\": [\n       \"hdl:11353/10.438701\"\n    ]\n  }\n]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Condition",
        "predicate": "arm:ConditionAssessment",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Assessment and/or documentation of the physical condition of an item, including damage, material vulnerabilities, special storage requirements, etc."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "If relevant, provide an assessment regarding the physical condition of the resource, including damage, material vulnerabilities, etc.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Description",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Contribution",
        "predicate": "role:",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information about any person or organization involved in the lifecycle of the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "You are required to provide the name of at least one person involved in the lifecycle of the object. <br> This field consists of four parts: <ul> <br> <li><b>Contributor role</b>: <br> You can choose the type of role from the list offered to you through the suggester. On the right, specify if the role refers to a person (<i>Personal</i>) or an organization (<i>Corporate</i>).</li><br><li><b>Contributor name</b>: <br> Name and surname of the person or organization related to the role you previously selected. In case of an organization, select the organisational unit of your institution from the drop-down list or enter the value manually if it is an external organization. </li><br><li><b>Contributor identifier</b>: <br> Where available, it is recommended to add an identifier. Choose the type of identifier from the drop-down list and write the code on the right.</li><br><li><b>Contributor affiliation</b>: <br> You can specify which organization the person is affiliated to. In case of an organizational unit of the University of Vienna, select the value from the list.</ul> <br> If you have more than one contributors, press on the right of the section to duplicate the section. You can also modify the order of the contributors by using the arrows.",
              "level2": "",
              "level3": "A persistent author identifier can help computers to interpret your data in a meaningful way, to create links between datasets, publications and researchers, and to increase discoverability. To make your data Findable, reference author identifiers when describing your resource."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://www.loc.gov/marc/relators/relaterm.html\">MARC Code List for Relators </a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "role:aut",
          "schema:givenName",
          "schema:familyName",
          "schema:affiliation",
          "schema:name",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Identifier types",
            "entries": [
              [
                "Currently supported types",
                "Type ID"
              ],
              [
                "ORCID",
                "ids:orcid"
              ],
              [
                "VIAF",
                "ids:viaf"
              ],
              [
                "GND",
                "ids:gnd"
              ],
              [
                "Wikidata",
                "ids:wikidata"
              ],
              [
                "LCNAF",
                "ids:lcnaf"
              ],
              [
                "ISNI",
                "ids:isni"
              ],
              [
                "URI",
                "ids:uri"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"role:aut\": [\n    {\n      \"@type\": \"schema:Person\",\n      \"schema:givenName\": [\n        {\n          \"@value\": \"Brenda\"\n        }\n      ],\n      \"schema:familyName\": [\n        {\n          \"@value\": \"Walsh\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "rolepredicate",
        "vocabularyNote": ""
      },
      {
        "title": "Date",
        "predicate": "dcterms:date",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A point or period of time associated with an event in the lifecycle of the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Each resource is bounded to a time span, whatever type of event it refers to (e.g. creation, production, publication, modification, or acquisition). When you describe your resource, it is highly recommended to provide a chronological indication of its life cycle. <br><b>Note:</b> This field should not express a date associated with the intellectual content of the resource. For that information, use the <i>Temporal coverage</i> field. <br> This field consists of the following date types: <ul> <br> <li><b>Date</b>: <br> A point or period of time associated with an event in the lifecycle of the resource.</li><br><li><b>Date created</b>: <br> Date of creation of the resource.</li><br><li><b>Date modified</b>: <br> Date on which the resource was changed.</li><br><li><b>Date available</b>: <br> Date, often a range, when the resource became or will become available.</li><br><li><b>Date issued</b>: <br> Date of formal issuance, for example publication.</li><br><li><b>Date valid</b>: <br> Date, often a range, of validity of a resource.</li><br><li><b>Date accepted</b>: <br> Date of acceptance of the resource.</li><br><li><b>Date copyrighted</b>: <br> Date of copyright.</li><br><li><b>Date submitted</b>: <br> Date of submission of the resource.</li><br><li><b>Date of production</b>: <br> Date of the inscription, fabrication, construction, or similar activity for an unpublished resource.</li><br><li><b>Date accessioned</b>: <br> Date on which an identification number was assigned to a particular donation or acquisition of the analogue object.</li></ul> <br> If you need more than one type of date, duplicate the field.",
              "level2": "Enriching the contextual knowledge about the data should be done in a machine-actionable way in order to foster its discovery. This means that selecting a specific Date which conforms to the context you are referring to (e.g. <i>Date created</i> or <i>Date issued</i>) should be preferrable to the more general <i>Date</i>. The more accurate and meaningful your metadata is, the more findable, interoperable and reusable your resource is.",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:date",
          "dcterms:created",
          "dcterms:modified",
          "dcterms:available",
          "dcterms:issued",
          "dcterms:valid",
          "dcterms:dateAccepted",
          "dcterms:dateCopyrighted",
          "dcterms:dateSubmitted",
          "rdau:P60071",
          "phaidra:dateAccessioned",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Date predicates",
            "entries": [
              [
                "Date predicates",
                "Definition"
              ],
              [
                "dcterms:date",
                ""
              ],
              [
                "dcterms:created",
                ""
              ],
              [
                "dcterms:modified",
                ""
              ],
              [
                "dcterms:available",
                ""
              ],
              [
                "dcterms:issued",
                ""
              ],
              [
                "dcterms:valid",
                ""
              ],
              [
                "dcterms:dateAccepted",
                ""
              ],
              [
                "dcterms:dateCopyrighted",
                ""
              ],
              [
                "dcterms:dateSubmitted",
                ""
              ],
              [
                "rdau:P60071",
                "\"has date of production\": \"Relates a resource to a timespan associated with the inscription, fabrication, construction, etc., of an unpublished resource.\""
              ],
              [
                "phaidra:dateAccessioned",
                ""
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"dcterms:issued\": [\n    \"1983\"\n  ],\n  \"dcterms:valid\": [\n    \"2004-06/2006-08\"\n  ],\n  \"dcterms:created\": [\n    \"72~\",\n    {\n      \"@type\": \"edm:TimeSpan\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Imperial Roman\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"http://vocab.getty.edu/aat/300020541\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Depicted/represented place",
        "predicate": "dcterms:spatial",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The geographic area represented in the content of the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field when the intellectual or artistic content of your object is about or is depicting a place. E.g. the place represented in a photograph or the place which the research data refer to. <br> Use the suggester to find the suitable place or add your own value. If needed, you can duplicate the field. <br> <b>Note:</b> This field describes the place covered or represented by the content of the resource, not the place where the resource was created or published. For the latter type of information, use the other available fields.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://www.geonames.org/\">GeoNames</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:spatial",
          "vra:placeOfCreation",
          "vra:placeOfRepository",
          "vra:placeOfSite",
          "skos:prefLabel",
          "rdfs:label",
          "schema:geo",
          "schema:latitude",
          "schema:longitude",
          "skos:exactMatch"
        ],
        "lists": [
          {
            "name": "Spatial predicates",
            "entries": [
              [
                "Spatial predicates"
              ],
              [
                "dcterms:spatial"
              ],
              [
                "vra:placeOfCreation"
              ],
              [
                "vra:placeOfRepository"
              ],
              [
                "vra:placeOfSite"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"dcterms:spatial\": [\n    {\n      \"@type\": \"schema:Place\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Gloggnitz\"\n        }\n      ],\n      \"rdfs:label\": [\n        {\n          \"@value\": \"Gloggnitz--Niederösterreich--Österreich--Europe--World\"\n        }\n      ],\n      \"schema:geo\": [\n        {\n          \"@type\": \"schema:GeoCoordinates\",\n          \"schema:latitude\": [\n            \"47.6833\"\n          ],\n          \"schema:longitude\": [\n            \"15.95\"\n          ]\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://www.geonames.org/7872991\"\n      ]\n    },\n    {\n      \"@type\": \"schema:Place\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Klokotnica\",\n          \"@language\": \"sla\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Depth",
        "predicate": "schema:depth",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The depth of the item."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the depth of the object, choosing the measurement unit.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:depth",
          "schema:unitCode",
          "schema:value"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:depth\": [\n    {\n      \"@type\": \"schema:QuantitativeValue\",\n      \"schema:unitCode\": [\n        \"CMT\"\n      ],\n      \"schema:value\": [\n        \"10\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "uncefactsize",
        "vocabularyNote": "This vocabulary defines the unit type, not the value."
      },
      {
        "title": "Description",
        "predicate": "bf:Note",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information, usually in textual form, on attributes of a resource or some aspect of a resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter a brief, general description of the resource.<br> This field is intended to give the user an overall account of the intellectual content of the resource.",
              "level2": "When describing your object, remember that using a specific field instead of combining information in a free-text general description will improve the quality of your metadata and would let your resource be more easily found and accessed in the <i>Linked Open Data</i> network. Before entering plain text, make sure to first check all the available fields, so you can granularly specify the content of the object in terms of topic, time and space. In case you have additional contextual details to mention (e.g. the linking to a project), we recommend you to press the button at the bottom of the submit form and check the list of additional fields if there is any that fits your needs. <br> Provide the description of your resource in another relevant language. Enriching your metadata by adding a translation makes the resource more findable for people speaking different languages and allows its reuse in a multilingual environment.",
              "level3": "All the above suggestions are pivotal to accomplish the goal of creating a FAIR digital resource. Accurate attributes and relationships specified in a machine-readable way (e.g. <i>X depicts Y</i>) ensure that the metadata you are creating are meaningful. Keep in mind that the more detail you put in your metadata, higher is the chance that your data will be further discovered and reused."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:note",
          "skos:prefLabel"
        ],
        "lists": [
          {
            "name": "Description type vocabulary",
            "entries": [
              [
                "Label",
                "Class",
                "Comment"
              ],
              [
                "Description",
                "bf:Note",
                "General description"
              ],
              [
                "Abstract",
                "bf:Summary",
                "Abstract"
              ],
              [
                "Remark",
                "phaidra:Remark",
                "Additional information"
              ],
              [
                "Condition",
                "arm:ConditionAssessment",
                "Assessment and/or documentation of the physical condition of an item, including damage, material vulnerabilities, special storage requirements, etc. The assessment is generally the output of a condition assessment activity, and may or may not result in a conservator activity."
              ],
              [
                "Reproduction note",
                "phaidra:ReproductionNote",
                "States if the analogue object is a copy or an original"
              ],
              [
                "Digitization note",
                "phaidra:DigitizationNote",
                "Describes the digitization process (e.g. scanner, OCR process...)"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"bf:note\": [\n    {\n      \"@type\": \"bf:Note\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"This is a description\",\n          \"@language\": \"eng\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Diameter",
        "predicate": "vra:diameter",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The diameter of the item."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the diameter of the object, choosing the measurement unit.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "vra:diameter",
          "schema:unitCode",
          "schema:value"
        ],
        "lists": [],
        "jsonLdExample": "  \"vra:diameter\": [\n    {\n      \"@type\": \"schema:QuantitativeValue\",\n      \"schema:unitCode\": [\n        \"CMT\"\n      ],\n      \"schema:value\": [\n        \"10\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "uncefactsize",
        "vocabularyNote": "This vocabulary defines the unit type, not the value."
      },
      {
        "title": "Digitization note",
        "predicate": "phaidra:DigitizationNote",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information regarding the digitization process (e.g. scanner, OCR process, etc.)."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field to record technical information about the digitization of the resource, e.g. the hardware, software, resolution, color settings, equipment and formats used for the digitization process.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Description",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Extent",
        "predicate": "rdau:P60550",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A type, number, and measurement unit that quantify an aspect of the extent of a resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Record the extent (size or dimension) of the object by giving the number of units and the type of unit (e.g. \"4 folders\", \"4 boxes\"). <br> Use this field only when the resource needs to be described in a measuring unit other than meter (m). If this is not the case, please consider the fields <i>Height</i>, <i>Width</i>, <i>Weight</i>, <i>Depth</i>, <i>Diameter</i>.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdau:P60550"
        ],
        "lists": [],
        "jsonLdExample": "  \"rdau:P60550\": [\n    {\n      \"@value\": \"47 S. (Textteil), [24] Bl. (Bildteil) : zahlr. Ill.\",\n      \"@language\": \"deu\"\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Funder",
        "predicate": "frapo:hasFundingAgency",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The funding agency that provides funding for the research or project related to the object."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the name of the Project Funder related to your data, providing its identifier where available.",
              "level2": "",
              "level3": "A persistent author identifier can help computers to interpret your data in a meaningful way, to create links between datasets, publications and researchers, and to increase discoverability. To make your data Findable, reference the Funder identifier when describing your resource."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "frapo:hasFundingAgency",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"frapo:hasFundingAgency\": [\n    {\n      \"@type\": \"frapo:FundingAgency\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Austrian Science Fund\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"http://dx.doi.org/10.13039/501100002428\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "funders",
        "vocabularyNote": ""
      },
      {
        "title": "Genre",
        "predicate": "schema:genre",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Genre of the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "In some cases, as for example a music album, a specification of the genre (e.g. &#34;pop&#34;) may be helpful to provide a more granular context to the resource. <br> Select the value from the drop-down list. If this is not in the list, choose <i>Other</i> and notify the metadata administrators.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/2H73-WG6Y\">Genre PHAIDRA Vocabulary </a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:genre",
          "rdfs:label",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:genre\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"science-fiction\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/vocabulary/YV6T-SWAF\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "genre",
        "vocabularyNote": ""
      },
      {
        "title": "Height",
        "predicate": "schema:height",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The height of the item."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the height of the object, choosing the measurement unit.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:height",
          "schema:unitCode",
          "schema:value"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:height\": [\n    {\n      \"@type\": \"schema:QuantitativeValue\",\n      \"schema:unitCode\": [\n        \"CMT\"\n      ],\n      \"schema:value\": [\n        \"10\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "uncefactsize",
        "vocabularyNote": "This vocabulary defines the unit type, not the value."
      },
      {
        "title": "Inscription",
        "predicate": "vra:hasInscription",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "All marks or written words added to the object at the time of production or in its subsequent history, including signatures, dates, dedications, texts, and colophons, as well as marks, such as the stamps of silversmiths, publishers, or printers."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter any marks or written words added to the image at the time of production or in its subsequent history, including signatures, dates, dedications, texts, and colophons, as well as marks, such as the stamps of silversmiths, publishers, or printers.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "vra:hasInscription",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"vra:hasInscription\": [\n    {\n      \"@type\": \"vra:Inscription\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"I was here. F.\",\n          \"@language\": \"eng\"\n        }\n      ]\n    },\n    {\n      \"@type\": \"vra:Inscription\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Aus dem Nachlass Frh. Heinrich v. Ferstel\",\n          \"@language\": \"deu\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Is contained in",
        "predicate": "rdau:P60101",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information about the larger resource of which the described resource is a discrete component."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field when the object you are describing is part of a larger resource, for example a book chapter, a volume in a multi-volume work, or a map within an atlas. <br> This field consists of the following parts: <ul> <br> <li><b>Title / Subtitle</b>: <br> The title and optional subtitle of the larger resource.</li><br><li><b>Role</b>: <br> The role and name of a person associated with the larger resource.</li><br><li><b>Page start / Page end</b>: <br> The pages occupied by the described resource within the larger resource.</li><br><li><b>ISBN / Identifier</b>: <br> An ISBN or other identifier for the larger resource.</li><br><li><b>Series</b>: <br> The series title, volume, issue, issued date, ISSN, and identifier, where applicable.</li><br><li><b>Publisher</b>: <br> The publisher, place, and date of publication.</li></ul>",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdau:P60101",
          "schema:pageStart",
          "schema:pageEnd",
          "dce:title",
          "bf:mainTitle",
          "bf:subtitle",
          "role:edt",
          "schema:givenName",
          "schema:familyName",
          "ids:isbn",
          "rdau:P60193",
          "bibo:volume",
          "bibo:issue",
          "ids:issn",
          "dcterms:issued",
          "bf:provisionActivity",
          "bf:agent",
          "schema:name",
          "bf:place",
          "skos:prefLabel",
          "skos:exactMatch",
          "bf:date"
        ],
        "lists": [],
        "jsonLdExample": "  \"rdau:P60101\": [\n    {\n      \"@type\": \"schema:CreativeWork\",\n      \"dce:title\": [\n        {\n          \"@type\": \"bf:Title\",\n          \"bf:mainTitle\": [\n            {\n              \"@value\": \"Example larger resource\",\n              \"@language\": \"eng\"\n            }\n          ],\n          \"bf:subtitle\": [\n            {\n              \"@value\": \"An example subtitle\",\n              \"@language\": \"eng\"\n            }\n          ]\n        }\n      ],\n      \"role:edt\": [\n        {\n          \"@type\": \"schema:Person\",\n          \"schema:givenName\": [\n            {\n              \"@value\": \"Maxwell\"\n            }\n          ],\n          \"schema:familyName\": [\n            {\n              \"@value\": \"Perkins\"\n            }\n          ]\n        }\n      ],\n      \"ids:isbn\": [\n        \"9780000000002\"\n      ],\n      \"rdau:P60193\": [\n        {\n          \"@type\": \"schema:CreativeWork\",\n          \"dce:title\": [\n            {\n              \"@type\": \"bf:Title\",\n              \"bf:mainTitle\": [\n                {\n                  \"@value\": \"Example series\",\n                  \"@language\": \"eng\"\n                }\n              ]\n            }\n          ],\n          \"bibo:volume\": [\n            \"1\"\n          ],\n          \"bibo:issue\": [\n            \"10\"\n          ],\n          \"ids:issn\": [\n            \"0021-9738\"\n          ],\n          \"dcterms:issued\": [\n            \"2017-05\"\n          ]\n        }\n      ],\n      \"bf:provisionActivity\": [\n        {\n          \"@type\": \"bf:Publication\",\n          \"bf:agent\": [\n            {\n              \"@type\": \"schema:Organization\",\n              \"schema:name\": [\n                {\n                  \"@value\": \"Example Publishing\"\n                }\n              ]\n            }\n          ],\n          \"bf:place\": [\n            {\n              \"@type\": \"schema:Place\",\n              \"skos:prefLabel\": [\n                {\n                  \"@value\": \"Graz\"\n                }\n              ],\n              \"skos:exactMatch\": [\n                \"https://www.geonames.org/2778067\"\n              ]\n            }\n          ],\n          \"bf:date\": [\n            \"1996\"\n          ]\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Is in series",
        "predicate": "rdau:P60193",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information about the resource in which the described item has been issued as a part of a series."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field to describe the series in which the resource was issued, for example a journal article, film, or television episode. <br> This field consists of the following parts: <ul> <br> <li><b>Title</b>: <br> The title of the series.</li><br><li><b>Volume</b>: <br> The volume number of the series.</li><br><li><b>Issue</b>: <br> The issue number of the series.</li><br><li><b>Issued</b>: <br> The publication date of the series issue.</li><br><li><b>Page start / Page end</b>: <br> The pages occupied by the resource in the series.</li><br><li><b>ISSN / Identifier</b>: <br> An ISSN or other identifier for the series.</li></ul>",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdau:P60193",
          "schema:pageStart",
          "schema:pageEnd",
          "dce:title",
          "bf:mainTitle",
          "bibo:volume",
          "bibo:issue",
          "ids:issn",
          "dcterms:issued",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "\"schema:pageStart\": [\n  \"4387\"\n],\n\"schema:pageEnd\": [\n  \"4394\"\n], \n\"rdau:P60193\": [\n    {\n      \"@type\": \"schema:CreativeWork\",\n      \"dce:title\": [\n        {\n          \"@type\": \"bf:Title\",\n          \"bf:mainTitle\": [\n            {\n              \"@value\": \"Journal of Clinical Investigation\"\n            }\n          ]\n        }\n      ],\n      \"bibo:volume\": [\n        \"1\"\n      ],\n      \"bibo:issue\": [\n        \"10\"\n      ],\n      \"ids:issn\": [\n        \"0021-9738\"\n      ],\n      \"dcterms:issued\": [\n        \"2017-05\"\n      ],\n      \"skos:exactMatch\": [\n        \"http://ld.zdb-services.de/resource/2018375-6\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Keywords",
        "predicate": "dce:subject",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The topic of the resource, represented using keywords."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Add useful keywords to represent the topic of the resource, specifying their language on the right.",
              "level2": "This field is particularly important to help users locate and retrieve the resource. The format of the values you put within the field thus plays an important role. To avoid the ambiguity that arises from synonymous terms, homonyms, variant spellings and other pitfalls, controlled vocabularies or authority files can be useful resources to look at. <br> If possible, duplicate the field in another relevant language. Providing keywords in more than one language makes the resource more findable for people speaking different languages and allows its reuse in a multilingual environment.",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dce:subject",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"dce:subject\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@language\": \"eng\",\n          \"@value\": \"barbaricum\"\n        }\n      ]\n    },\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@language\": \"eng\",\n          \"@value\": \"rome\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Language",
        "predicate": "dcterms:language",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A designation of the language in which the content of the resource is expressed."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the language of the resource, choosing the value from the drop-down list. Make sure you are referring to the language of the resource, not the language of the metadata. <br>If the content of the resource is in more than one language, duplicate the field.",
              "level2": "The language of an object provides relevant context to the user. We highly encourage you to fill in this field if your resource contains text or speech.",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"http://id.loc.gov/vocabulary/languages\">MARC List for Languages</a> <br> <a href=\"https://vocab.phaidra.org/vocabulary/WKFZ-VG0C\">Language PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:language",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"dcterms:language\": [\n    \"ara\"\n  ]",
        "parentTitle": null,
        "vocabularyId": "lang",
        "vocabularyNote": ""
      },
      {
        "title": "Language of subtitles",
        "predicate": "schema:subtitleLanguage",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Languages in which subtitles/captions are available."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "If the resource (e.g. an audio or video file) is provided of subtitles, specify their language choosing the value from the list. <br> If subtitles are given in more than one language, duplicate the field.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"http://id.loc.gov/vocabulary/languages\">MARC List for Languages</a> <br> <a href=\"https://vocab.phaidra.org/vocabulary/WKFZ-VG0C\">Language PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:subtitleLanguage",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:subtitleLanguage\": [\n    \"ara\",\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Lebanese\",\n          \"@language\": \"eng\"\n        },\n        {\n          \"@value\": \"Libanesisch-Arabisch\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/vocabulary/MKXZ-SARM\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "lang",
        "vocabularyNote": ""
      },
      {
        "title": "Material",
        "predicate": "vra:material",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The substance of which a work or an image is composed."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Provide information about the material of the physical resource. <br> You have two options to do that: you can manually enter the value using the first field <i>Material</i> or you can select a pre-filtered value from the drop-down list in the second field <i>Material</i>.",
              "level2": "The use of controlled vocabularies helps to better integrate your data with other resources in the Linked Open Data network. As best practice, check first the drop-down list of the field to see if the value you need is there.",
              "level3": "Controlled vocabularies that have globally unique and persistent identifiers are key to the vision of FAIR data. They remove ambiguity in the meaning of your published data, helping people and computers to understand exactly the concept you are referring to and ensuring access and interoperability. To render your data FAIR, choose a value for Material from the controlled list."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/VPSR-KHRC\">Material PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "vra:material",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"vra:material\": [\n    {\n      \"@type\": \"vra:Material\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"black marble\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"http://vocab.getty.edu/aat/300011484\"\n      ]\n    },\n    {\n      \"@type\": \"vra:Material\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"celluloid\",\n          \"@language\": \"deu\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "material",
        "vocabularyNote": ""
      },
      {
        "title": "Motion picture adaptation of",
        "predicate": "rdau:P60227",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A relationship that links the object with a resource that is adapted as a motion picture."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field when the object you are describing is a motion picture that has been adapted from another resource. <br> This field consists of two parts: <ul> <br> <li><b>Title</b>: <br> Title of the original work.</li><br><li><b>Role</b>: <br> Choose the type of role from the suggester and add the name and surname of the person related to the role you previously selected.</li></ul>",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdau:P60227",
          "dce:title",
          "bf:mainTitle",
          "role:aut",
          "schema:givenName",
          "schema:familyName"
        ],
        "lists": [],
        "jsonLdExample": "  \"rdau:P60227\": [\n    {\n      \"@type\": \"schema:CreativeWork\",\n      \"dce:title\": [\n        {\n          \"@type\": \"bf:Title\",\n          \"bf:mainTitle\": [\n            {\n              \"@value\": \"The Third Son\",\n              \"@language\": \"eng\"\n            }\n          ]\n        }\n      ],\n      \"role:aut\": [\n        {\n          \"@type\": \"schema:Person\",\n          \"schema:givenName\": [\n            {\n              \"@value\": \"Andrei\"\n            }\n          ],\n          \"schema:familyName\": [\n            {\n              \"@value\": \"Platanov\"\n            }\n          ]\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Number of pages",
        "predicate": "schema:numberOfPages",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The number of pages in the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the number of pages of the object.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:numberOfPages"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:numberOfPages\": [\n    \"123\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Issue",
        "predicate": "bibo:issue",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "An issue number."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the issue number (e.g. of a journal).",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bibo:issue"
        ],
        "lists": [],
        "jsonLdExample": "\"bibo:issue\": [\n  \"10\"\n]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Volume",
        "predicate": "bibo:volume",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A volume number."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the volume number (e.g. of a journal).",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bibo:volume"
        ],
        "lists": [],
        "jsonLdExample": "\"bibo:volume\": [\n  \"1\"\n]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Book edition",
        "predicate": "bibo:edition",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The edition of the book."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the edition statement of the book (for example, “2nd revised edition”).",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Object type",
        "predicate": "edm:hasType",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The physical form or intellectual content of the object being described. It is a more detailed sub-type refining the broader <i>Resource type</i> field."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "These controlled terms are useful for filtering search results. <br> Select a value from the drop-down list. If the resource involves more than one type, duplicate the field. In case the term you want to select is not in the list, choose <i>Other</i> and notify the metadata administrators. <br> If you are describing an audio or video resource, take into consideration also the <i>Carrier type</i> field.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/NB34-DPJR\">Object type PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "edm:hasType",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"edm:hasType\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"astronomical photography\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"http://vocab.getty.edu/aat/300134506\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "objecttype",
        "vocabularyNote": ""
      },
      {
        "title": "Page end",
        "predicate": "schema:pageEnd",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The page on which the work ends."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the page end of the object.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:pageEnd"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:pageEnd\": [\n    \"138\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Page start",
        "predicate": "schema:pageStart",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The page on which the work starts."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the page start of the object.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:pageStart"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:pageStart\": [\n    \"135\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Parallel title",
        "predicate": "bf:ParallelTitle",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "An alternative name for the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the title used as a substitute or alternative to the formal title of the resource. These are usually secondary titles, abbreviations, titles with different transliterations, translations of a title, etc. <br> The parallel title does not refer to the translation supplied by the cataloguer.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Title",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Place of creation",
        "predicate": "vra:placeOfCreation",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Place where the work or its components was or were created, designed, or produced. It may also be the presumed original location of the work."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Indicate the place where the resource was created. Use the suggester to find the suitable value or write your own value.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://www.geonames.org/\">GeoNames</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Depicted/represented place",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Place of repository",
        "predicate": "vra:placeOfRepository",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Place where the work or its components are stored."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Indicate the place where the work is stored. Use the suggester to find the suitable value or write your own value.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://www.geonames.org/\">GeoNames</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Depicted/represented place",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Place of site",
        "predicate": "vra:placeOfSite",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Geographic location where built works (architecture) or monumental works are found."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Indicate the place where the built work is located or where the monumental work is found. Use the suggester to find the suitable value or write your own value.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://www.geonames.org/\">GeoNames</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Depicted/represented place",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Physical location",
        "predicate": "bf:physicalLocation",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Location in the holding agency where the item is shelved or stored."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Indicate the place where the resource is stored.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:physicalLocation"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:physicalLocation\": [\n    {\n      \"@value\": \"Some Collection, Some institution\",\n      \"@language\": \"eng\"\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Project",
        "predicate": "frapo:isOutputOf",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The project that is associated with the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "This field gathers information about the project to which your resource is related. <br> This field consists of six parts: <ul> <br> <li><b>Project name</b>: <br> Name of the project.</li><br><li><b>Project acronym</b>: <br> Acronym used to identify the project, based on its full name or title. For example, the ontology \"Funding, Research Administration and Projects Ontology\" has the acronym \"FRAPO\".</li><br><li><b>Project description</b>: <br> Brief description of the project.</li><br><li><b>Project identifier</b>: <br> The project identification number.</li><br><li><b>Project homepage</b>: <br> The main link to the project.</li><br><li><b>Funder name</b>: <br> The name of the project funder; provide its identifier where available.</li></ul>",
              "level2": "Explicit EC or national funding information adheres to Open Access policies and meets the requirements of the <i>OpenAIRE</i> infrastructure. Where applicable, fill in the field to improve discoverability of your resource, e.g. in the <i>OpenAIRE</i> portal.",
              "level3": "Globally unique and persistent identifiers can help computers to interpret your data in a meaningful way, to create automatic links between datasets, publications and researchers, and to increase discoverability. To make your data Findable, reference Project and Funder identifiers when describing your resource."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "frapo:isOutputOf",
          "skos:prefLabel",
          "rdfs:comment",
          "foaf:homepage",
          "frapo:hasProjectIdentifier",
          "skos:exactMatch",
          "frapo:hasFundingAgency"
        ],
        "lists": [],
        "jsonLdExample": "  \"frapo:isOutputOf\": [\n    {\n      \"@type\": \"foaf:Project\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Vom Vorbild zum Abbild\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"rdfs:comment\": [\n        {\n          \"@value\": \"From Object to Icon is an interdisciplinary research project, conducted at the Institute of Egyptology in cooperation with the research group Multimedia Information Systems at the University of Vienna. It is based on the research that was initiated with the project MeKeTRE.\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"foaf:homepage\": [\n        \"http://meketre.org/\"\n      ],\n      \"frapo:hasProjectIdentifier\": [\n        \"P25958\"\n      ],\n      \"skos:exactMatch\": [\n        {\n           \"@type\": \"ids:doi\",\n           \"@value\": \"10.xxxxx/xxxxxxxxx\"\n        }\n      ],\n      \"frapo:hasFundingAgency\": [\n        {\n          \"@type\": \"frapo:FundingAgency\",\n          \"skos:prefLabel\": [\n            {\n              \"@value\": \"Austrian Science Fund\",\n              \"@language\": \"eng\"\n            }\n          ],\n          \"skos:exactMatch\": [\n            \"http://dx.doi.org/10.13039/501100002428\"\n          ]\n       }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Provenance",
        "predicate": "dcterms:provenance",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A statement of any changes in ownership and custody of the resource since its creation that are significant for its authenticity, integrity, and interpretation. The statement may include a description of any changes successive custodians made to the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "You may use this field to record any changes in ownership and custody of the resource since its creation that are significant for its authenticity, integrity, and interpretation. The statement may include a description of any changes successive custodians made to the resource.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:provenance",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"dcterms:provenance\": [\n    {\n      \"@type\": \"dcterms:ProvenanceStatement\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"bla bla bla\",\n          \"@language\": \"deu\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Publication",
        "predicate": "bf:provisionActivity",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information about the agent or place relating to the publication, printing, distribution, issue, release, or production of a resource. Not to be used for the entity responsible for digitizing or making the digital representation available."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field for resources with a known publisher or publication date. <br> This field consists of three parts: <ul> <br> <li><b>Publisher</b>: <br> The publisher or organizational unit responsible for publication.</li><br><li><b>Place</b>: <br> The place of publication.</li><br><li><b>Date</b>: <br> The publication date.</li></ul> <br> When only the publication date is available, use the <i>Date issued</i> field.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:provisionActivity",
          "bf:agent",
          "schema:name",
          "bf:place",
          "skos:prefLabel",
          "skos:exactMatch",
          "bf:date"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:provisionActivity\": [\n    {\n      \"@type\": \"bf:Publication\",\n      \"bf:agent\": [\n        {\n          \"@type\": \"schema:Organization\",\n          \"schema:name\": [\n            {\n              \"@value\": \"Example Publishing\"\n            }\n          ]\n        }\n      ],\n      \"bf:place\": [\n        {\n          \"@type\": \"schema:Place\",\n          \"skos:prefLabel\": [\n            {\n              \"@value\": \"Graz\"\n            }\n          ],\n          \"skos:exactMatch\": [\n            \"https://www.geonames.org/2778067\"\n          ]\n        }\n      ],\n      \"bf:date\": [\n        \"1996\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Regional encoding",
        "predicate": "rdau:P60059",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A designation for one or more regions of the world for which a videodisc or video game carrier is encoded, indicating that playback is restricted to a device configured to decode it."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "By selecting the value from the drop-down menu, provide a designation for one or more regions of the world for which a videodisc or video game carrier is encoded.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/HHB2-GXRZ\">Regional encoding PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdau:P60059",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "\"rdau:P60059\": [\n  {\n    \"@type\": \"skos:Concept\",\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"region 1\"\n      }\n    ],\n    \"skos:exactMatch\": [\n       \"https://pid.phaidra.org/vocabulary/XXXX-XXXX\"\n    ]\n  }\n]",
        "parentTitle": null,
        "vocabularyId": "regionalencoding",
        "vocabularyNote": ""
      },
      {
        "title": "Remark",
        "predicate": "phaidra:Remark",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Additional information that could be relevant for the identification of the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "You may use this field to add information that generally relates to the resource as a whole. For example, contextual information about the item or the creator of the item, or any dissimilarity between the file you are uploading and a previous version.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Description",
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Reproduction note",
        "predicate": "phaidra:ReproductionNote",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A note stating if the analogue object is a copy or an original."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "This field helps to make clear whether the analogue object is a copy or an original. Write the value <i>copy</i> or <i>original</i>.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [],
        "lists": [],
        "jsonLdExample": "",
        "parentTitle": "Description",
        "vocabularyId": "reproduction",
        "vocabularyNote": ""
      },
      {
        "title": "Scale",
        "predicate": "bf:scale",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Ratio of the dimensions of a form contained or embodied in a resource to the dimensions of the entity it represents, e.g., for images or cartographic resources."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the scale of your cartographic resource.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:scale",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:scale\": [\n    {\n      \"@type\": \"bf:Scale\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"1:20000\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "See also",
        "predicate": "rdfs:seeAlso",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A URL linking to a related resource that might provide additional information about the subject resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Use this field whenever you want to enter a link to other material related to the resource. <br> Filling in this separate field, instead of adding the URL in a free-text field, makes your data more machine-readable.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdfs:seeAlso",
          "schema:url",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"rdfs:seeAlso\": [\n    {\n      \"@type\": \"schema:URL\",\n      \"schema:url\": [\n        \"http://users.unimi.it/museozoo/TavoleParietali/Cd/html/0079.html\"\n      ],\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Università degli Studi di Milano, Leuckart Tafel XXXVIII\",\n          \"@language\": \"deu\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Shelf mark",
        "predicate": "bf:shelfMark",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Piece identifier, such as a call or other type of number."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Enter the piece identifier. This could be a call number or a shelf. <br> When filling in this field, make sure to record the physical location in the <i>Physical location</i> field as well.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:shelfMark"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:shelfMark\": [\n    \"XA1234\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Subject",
        "predicate": "dcterms:subject",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The topic of the resource, represented using terms from formal, controlled vocabularies."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "This field makes use of many subject classifications available in the Web, as for example the <i>GND (Gemeinsame Normdatei)</i>, a national authority file used by German-speaking libraries, museums and archives. <br> Use the suggester on this field to find the suitable terms that best describe the object. Choose as many terms as necessary by duplicating the field.",
              "level2": "The use of controlled vocabularies provides greater consistency helping your data to be searched and integrated with other resources in the <i>Linked Open Data</i> network. As best practice, fill in this field with as many terms as needed.",
              "level3": "Controlled vocabularies with globally unique and persistent identifiers are one of the keys to machine-understandability of (meta)data, which is what FAIR guidelines are all about. Metadata expressed in this format is unequivocably read and processed by computers, enabling your resource to be linked with other data, accessed or/and shared. Provide a meaningful classification filling in this field so that you can ensure a broad interoperability of your resource."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<b>Internal PHAIDRA vocabularies</b>: <ul><li>ÖFOS</li><li>Thema</li><li>BIC (deprecated)</li></ul><b>External vocabularies</b>: <ul><li>GND (Gemeinsame Normdatei)</li><li>Basisklassifikation</li></ul>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:subject",
          "skos:prefLabel",
          "rdfs:label",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"dcterms:subject\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"crows\",\n          \"@language\": \"eng\"\n        },\n        {\n          \"@value\": \"krähen\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"rdfs:label\": [\n        {\n          \"@value\": \"crows--corvids--birds--animals\",\n          \"@language\": \"eng\"\n        },\n        {\n          \"@value\": \"krähen--rabenvögel--vögel--tiere\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://gd.eppo.int/taxon/1CORVG\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Supplementary content",
        "predicate": "bf:supplementaryContent",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Material such as an index, bibliography, appendix, intended to supplement the primary content of a resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "You may use this field to describe any other material which supplements the primary content of the resource, for example alternate endings or an audio commentary that could be provided as special features on a DVD.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:supplementaryContent",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:supplementaryContent\": [\n    {\n      \"@type\": \"bf:SupplementaryContent\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Interaktive Menü\",\n          \"@language\": \"deu\"\n        }\n      ]\n    },\n    {\n      \"@type\": \"bf:SupplementaryContent\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Szenenauswahl\",\n          \"@language\": \"deu\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Table of contents",
        "predicate": "bf:TableOfContents",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A structured list of the contents of the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "If any, provide a list of subunits of the resource, e.g. the list of tracks on a CD or a list of chapters in a book.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "bf:TableOfContents",
          "bf:tableOfContents",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "  \"bf:tableOfContents\": [\n    {\n      \"@type\": \"bf:TableOfContents\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Chapter 1\\\\nChapter 2\",\n          \"@language\": \"eng\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Technique",
        "predicate": "vra:hasTechnique",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The production or manufacturing processes, techniques, and methods incorporated in the fabrication or alteration of the work or image."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "To specify the technique used for the creation of the object, you can either enter your own value (in the first occurrence of the field) or select it from a controlled list (in the second occurrence).",
              "level2": "The use of controlled vocabularies provides greater consistency helping your data to be searched and integrated with other resources in the <i>Linked Open Data </i> network. As best practice, check first the drop-down list of the field to see if the value you need is there.",
              "level3": "Controlled vocabularies which have globally unique and persistent identifiers are key to the vision of FAIR data. They remove ambiguity in the meaning of your published data, helping people and computers to understand exactly the concept you are referring to and ensuring access and interoperability. To render your data FAIR, choose a value for <i>Technique</i> from the controlled list."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "vra:technique",
          "vra:hasTechnique",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"vra:hasTechnique\": [\n    {\n      \"@type\": \"vra:Technique\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"mural painting\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"http://vocab.getty.edu/aat/300178677\"\n      ]\n    },\n    {\n      \"@type\": \"vra:Technique\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"in mehreren Schichten aufgebaut\",\n          \"@language\": \"deu\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "technique",
        "vocabularyNote": ""
      },
      {
        "title": "Temporal coverage",
        "predicate": "dcterms:temporal",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The time period that the content applies to, i.e. that it describes."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Describe the temporal characteristics of the intellectual content of the resource, i.e. what the resource is about (or depicts) in terms of time. You can enter either a formatted date, a range of dates or a period label (e.g. &#34;Neolithic period&#34;). Duplicate this field if needed. <br> <b>Note:</b> This field describes the time period covered or represented by the content of the resource, not the date when the resource was created or published. For this kind of information, use the <i>Date</i> field.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": ""
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:temporal",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"dcterms:temporal\": [\n    \"72?\",\n    {\n      \"@type\": \"edm:TimeSpan\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Imperial Roman\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"http://vocab.getty.edu/aat/300020541\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Title",
        "predicate": "dce:title",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A name given to the resource. Typically, a title will be a name by which the resource is formally known."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "As an important access point for digital resources, you are required to provide a title to your resource. <br> This field consists of two parts: <ul> <br> <li><b>Title</b>: <br> The main title of the resource. If the resource has more than one title, choose the main one and use the <i>Parallel title</i> field for the alternative one.</li><br><li><b>Subtitle</b>: <br> The word, character, or group of words and/or characters that contains the remainder of the title after the main title.</li></ul> <br> If there is no formal title, formulate an adequate one that could uniquely identify the object in terms of content (e.g. people, events, activities), geographical location or period of time. Whenever possible, a descriptive and informative title is preferred against more general titles as &#34;unknown&#34; or id numbers. <br>Since titles are nearly always utilized for search, consider incorporating important keywords into the text. Also, make sure the object has its own unique title against the collection it is part of.",
              "level2": "Where possible, provide a translation of the title in another relevant language. Enriching your metadata by adding a translation makes the resource more findable for people speaking different languages and allows its reuse in a multilingual environment.",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dce:title",
          "bf:mainTitle",
          "bf:subtitle"
        ],
        "lists": [
          {
            "name": "Title type vocabulary",
            "entries": [
              [
                "Label",
                "Class"
              ],
              [
                "Title",
                "bf:Title"
              ],
              [
                "Parallel title",
                "bf:ParallelTitle"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"dce:title\": [\n    {\n      \"@type\": \"bf:Title\",\n      \"bf:mainTitle\": [\n        {\n          \"@value\": \"This is the main title\",\n          \"@language\": \"deu\"\n        }\n      ],\n      \"bf:subtitle\": [\n        {\n          \"@value\": \"This is subtitle\",\n          \"@language\": \"deu\"\n        }\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Weight",
        "predicate": "schema:weight",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The weight of the item."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the weight of the object, choosing the measurement unit.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:weight",
          "schema:unitCode",
          "schema:value"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:weight\": [\n    {\n      \"@type\": \"schema:QuantitativeValue\",\n      \"schema:unitCode\": [\n        \"KGM\"\n      ],\n      \"schema:value\": [\n        \"10\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "uncefactweight",
        "vocabularyNote": "This vocabulary defines the unit type, not the value."
      },
      {
        "title": "Width",
        "predicate": "schema:width",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The width of the item."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the width of the object, choosing the measurement unit.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:width",
          "schema:unitCode",
          "schema:value"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:width\": [\n    {\n      \"@type\": \"schema:QuantitativeValue\",\n      \"schema:unitCode\": [\n        \"CMT\"\n      ],\n      \"schema:value\": [\n        \"10\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "uncefactsize",
        "vocabularyNote": "This vocabulary defines the unit type, not the value."
      },
      {
        "title": "Alternate identifier",
        "predicate": "rdam:P30004",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "An identification that consists of a code, number, or other string, usually independent of natural language and social naming conventions, used to identify a resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "If any, add an alternative identifier (other than PHAIDRA persistent identifier) that the resource might be provided of. The types of identifiers could be: DOI, Handle, URI, URN, AC-Number. <br> If you have more than one, duplicate the field.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "rdam:P30004"
        ],
        "lists": [
          {
            "name": "Identifier types",
            "entries": [
              [
                "Currently supported types",
                "Type ID"
              ],
              [
                "DOI",
                "ids:doi"
              ],
              [
                "Handle",
                "ids:hdl"
              ],
              [
                "URI",
                "ids:uri"
              ],
              [
                "URN",
                "ids:urn"
              ],
              [
                "AC-Number",
                "phaidra:acnumber"
              ]
            ]
          }
        ],
        "jsonLdExample": "  \"rdam:P30004\": [\n    {\n      \"@type\": \"ids:doi\",\n      \"@value\": \"10.5281/zenodo.579874\"\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Duration",
        "predicate": "schema:duration",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The duration of the item (movie, audio recording, event, etc.) in ISO 8601 date and time format."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Specify the duration of the item in the <a href=\"https://en.wikipedia.org/wiki/ISO_8601#Durations\">ISO 8601 date and time format</a>",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": ""
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "schema:duration"
        ],
        "lists": [],
        "jsonLdExample": "  \"schema:duration\": [\n    \"PT4M5S\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "File name",
        "predicate": "ebucore:filename",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The name of the file containing the resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "The value of this field is automatically filled in when the user uploads the object. The name can still be changed by the user afterwards.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "ebucore:filename"
        ],
        "lists": [],
        "jsonLdExample": "  \"ebucore:filename\": [\n    \"test.jpg\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "Encoding format (audio/video)",
        "predicate": "dce:format",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Technical specification relating to the encoding of a resource."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "This field expresses technical specifications relating to the encoding of a resource, as for example \"Dolby Digital 5.1\". <br> Select the value from the controlled list.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/FDVS-NMG1\">DC Format PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dce:format",
          "skos:exactMatch",
          "skos:prefLabel"
        ],
        "lists": [],
        "jsonLdExample": "\"dce:format\": [\n  {\n    \"@type\": \"skos:Concept\",\n    \"skos:exactMatch\": [\n      \"https://pid.phaidra.org/vocabulary/FRJJ-4376\"\n    ],\n    \"skos:prefLabel\": [\n      {\n        \"@value\": \"DTS\",\n        \"@language\": \"eng\"\n      }\n    ]\n  }\n]",
        "parentTitle": null,
        "vocabularyId": "dceformat",
        "vocabularyNote": ""
      },
      {
        "title": "MIME type",
        "predicate": "ebucore:hasMimeType",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The file format, expressed as an authorized term from the <i>Internet Media Types (IMT) </i> controlled vocabulary."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "The information about the file format can be relevant to determine the equipment needed to display or operate a resource (e.g. if the described resource has format PDF, you need a PDF reader to use it). <br> Once you upload the file, the value is pre-selected by the system. Check if this value fits your digital object. If not, choose the right one from the drop-down menu. <br><b>Note:</b> If possible, before uploading the file consider file formats that are widely used and supported by the most commonly used software and tools.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://www.iana.org/assignments/media-types/media-types.xhtml\">Internet Media Types (IMT)</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "ebucore:hasMimeType"
        ],
        "lists": [],
        "jsonLdExample": "  \"ebucore:hasMimeType\": [\n    \"image/tiff\"\n  ]",
        "parentTitle": null,
        "vocabularyId": "mimetypes",
        "vocabularyNote": ""
      },
      {
        "title": "Resource type",
        "predicate": "dcterms:type",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A term that specifies the characteristic and general type of content of the resource. This information characterizes the resource at a higher level than the <i>Object type</i> field."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "This field is automatically generated by the system once the content-specific submit form is selected.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://vocab.phaidra.org/vocabulary/7E4S-MA30\">Resource type PHAIDRA Vocabulary</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:type",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"dcterms:type\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"image\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/vocabulary/44TN-P1S0\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "resourcetype",
        "vocabularyNote": ""
      },
      {
        "title": "Version type",
        "predicate": "oaire:version",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The status in the publication process of journal articles."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Select the status that best describes the resource in its publication process.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "oaire:version",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"oaire:version\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"publishedVersion\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"publishedVersion\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "versiontypes",
        "vocabularyNote": ""
      },
      {
        "title": "Access rights",
        "predicate": "dcterms:accessRights",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information about who can access the resource or an indication of its security status. <br>The Access rights vocabulary here implemented builds on <i>COAR Access Rights Vocabulary</i>."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Declare the access status of a resource by selecting the value from the drop-down list.",
              "level2": "",
              "level3": "Well-defined conditions under which data are accessible help a machine automatically understand the requirements and tell the user how he may access the resource. Make sure you are clearly stating accessibility, choosing <i>Open Access</i> when possible."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dcterms:accessRights",
          "skos:prefLabel",
          "skos:exactMatch"
        ],
        "lists": [],
        "jsonLdExample": "  \"dcterms:accessRights\": [\n    {\n      \"@type\": \"skos:Concept\",\n      \"skos:prefLabel\": [\n        {\n          \"@value\": \"Open Access\",\n          \"@language\": \"eng\"\n        }\n      ],\n      \"skos:exactMatch\": [\n        \"https://pid.phaidra.org/vocabulary/PY38-5KQZ\"\n      ]\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": "accessright",
        "vocabularyNote": ""
      },
      {
        "title": "License",
        "predicate": "edm:rights",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "The copyright, usage and access rights that apply to the digital representation."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "You are required to select the license from a controlled list. If you need to learn more about differences between these licenses, read the <a href=\"https://creativecommons.org/about/cclicenses/\"> Creative Commons webpage</a>.",
              "level2": "",
              "level3": "To increase the reusability of your data, make sure you know who the data rights holder is before uploading the resource. It should also be clear what license applies."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "<a href=\"https://creativecommons.org/licenses/\">Creative Commons licenses</a>"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": "Required"
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "edm:rights"
        ],
        "lists": [],
        "jsonLdExample": "  \"edm:rights\": [\n    \"https://creativecommons.org/licenses/by-nc-nd/4.0/\"\n  ]",
        "parentTitle": null,
        "vocabularyId": "alllicenses",
        "vocabularyNote": ""
      },
      {
        "title": "Rights statement",
        "predicate": "dce:rights",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "Information about rights held in and over the resource. Typically, rights information includes a statement about various property rights associated with the resource, including intellectual property rights."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "You can use this field to give supplemental information on intellectual property rights or access arrangements that is additional to the license you selected. For instance, you could specify details concerning accessibility, reproduction, copyright holder, restrictions, or securing permissions for use.",
              "level2": "",
              "level3": "In addition to machine-understandable license information, a human-readable text concerning the conditions (e.g. obligations, restrictions) under which data can be reused can still be significant to the user to prevent ambiguity on your data. When you think a further specification might be useful, consider fill in the field."
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "dce:rights"
        ],
        "lists": [],
        "jsonLdExample": "  \"dce:rights\": [\n    {\n      \"@value\": \"© The Author(s) 2023\",\n      \"@language\": \"eng\"\n    },\n    {\n      \"@value\": \"You may find additional information about the copyright status of the Item on the website of the organization that has made the Item available.\",\n      \"@language\": \"eng\"\n    }\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      },
      {
        "title": "System tag",
        "predicate": "phaidra:systemTag",
        "open": false,
        "sections": [
          {
            "id": "description",
            "title": "Description",
            "content": "A tag for the purpose of identification or to give other information."
          },
          {
            "id": "usagenotes",
            "title": "Usage notes",
            "content": {
              "level1": "Information to support system logic that are not relevant to the user.",
              "level2": "",
              "level3": ""
            }
          },
          {
            "id": "vocabulary",
            "title": "Vocabulary",
            "content": "None"
          },
          {
            "id": "obligation",
            "title": "Obligation",
            "content": ""
          },
          {
            "id": "occurrence",
            "title": "Occurrence",
            "content": ""
          },
          {
            "id": "exampleHR",
            "title": "Example",
            "content": ""
          }
        ],
        "predicates": [
          "phaidra:systemTag"
        ],
        "lists": [],
        "jsonLdExample": "  \"phaidra:systemTag\": [\n    \"whatever\"\n  ]",
        "parentTitle": null,
        "vocabularyId": null,
        "vocabularyNote": ""
      }
    ]
  },
  {
    "title": "Namespaces",
    "open": false,
    "fields": [],
    "items": [
      {
        "name": "Phaidra",
        "prefix": "phaidra",
        "url": "https://phaidra.org/ontology/"
      },
      {
        "name": "BIBFRAME (v.2)",
        "prefix": "bf",
        "url": "http://id.loc.gov/ontologies/bibframe/"
      },
      {
        "name": "LOC Standard Identifiers Scheme",
        "prefix": "ids",
        "url": "http://id.loc.gov/vocabulary/identifiers/"
      },
      {
        "name": "The Bibliographic Ontology",
        "prefix": "bibo",
        "url": "http://purl.org/ontology/bibo/"
      },
      {
        "name": "Bibliotek-o",
        "prefix": "bib",
        "url": "https://bibliotek-o.org/"
      },
      {
        "name": "Classification Schemes",
        "prefix": "classSchemes",
        "url": "http://id.loc.gov/vocabulary/classSchemes"
      },
      {
        "name": "DBPedia Ontology",
        "prefix": "dbo",
        "url": "http://dbpedia.org/ontology/"
      },
      {
        "name": "Dublin Core Metadata Element Set, Version 1.1",
        "prefix": "dce",
        "url": "http://purl.org/dc/elements/1.1/"
      },
      {
        "name": "DCMI Metadata Terms",
        "prefix": "dcterms",
        "url": "http://purl.org/dc/terms/"
      },
      {
        "name": "DCMI Type Vocabulary",
        "prefix": "dcmitype",
        "url": "http://dublincore.org/documents/2000/07/11/dcmi-type-vocabulary/#"
      },
      {
        "name": "EBUCore - the Dublin Core for media",
        "prefix": "ebucore",
        "url": "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#"
      },
      {
        "name": "Europeana Data Model",
        "prefix": "edm",
        "url": "http://www.europeana.eu/schemas/edm/"
      },
      {
        "name": "FOAF (Friend of a Friend)",
        "prefix": "foaf",
        "url": "http://xmlns.com/foaf/0.1/"
      },
      {
        "name": "OpaqueNamespace",
        "prefix": "opaque",
        "url": "http://opaquenamespace.org/ [might change]"
      },
      {
        "name": "OpenAIRE Guidelines Application Profile",
        "prefix": "oaire",
        "url": "http://namespace.openaire.eu/schema/oaire/"
      },
      {
        "name": "ÖFOS 2012",
        "prefix": "oefos2012",
        "url": "https://vocabs.acdh.oeaw.ac.at/oefosdisciplines/"
      },
      {
        "name": "Portland Common Data Model",
        "prefix": "pcdm",
        "url": "http://pcdm.org/models#"
      },
      {
        "name": "RDA Unconstrained",
        "prefix": "rdau",
        "url": "http://rdaregistry.info/Elements/u/"
      },
      {
        "name": "RDA Agent",
        "prefix": "rdaa",
        "url": "http://rdaregistry.info/Elements/a/"
      },
      {
        "name": "The RDF Concepts Vocabulary (RDF)",
        "prefix": "rdf",
        "url": "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      },
      {
        "name": "RDF Schema 1.1",
        "prefix": "rdfs",
        "url": "http://www.w3.org/2000/01/rdf-schema#"
      },
      {
        "name": "MARC Code List for Relators",
        "prefix": "relators",
        "url": "http://id.loc.gov/vocabulary/relators/"
      },
      {
        "name": "Schema.org",
        "prefix": "schema",
        "url": "http://schema.org/"
      },
      {
        "name": "SKOS Simple Knowledge Organization System",
        "prefix": "skos",
        "url": "http://www.w3.org/2004/02/skos/core#"
      },
      {
        "name": "SKOS Simple Knowledge Organization System eXtension for Labels",
        "prefix": "skosxl",
        "url": "http://www.w3.org/2008/05/skos-xl#"
      },
      {
        "name": "Standard Identifiers Scheme",
        "prefix": "identifiers",
        "url": "http://id.loc.gov/vocabulary/identifiers/"
      },
      {
        "name": "The Funding, Research Administration and Projects Ontology",
        "prefix": "frap",
        "url": "http://purl.org/cerif/frapo/"
      },
      {
        "name": "Academic Institution Internal Structure Ontology",
        "prefix": "aiiso",
        "url": "http://purl.org/vocab/aiiso/schema#"
      },
      {
        "name": "CiTO, the Citation Typing Ontology",
        "prefix": "cito",
        "url": "http://purl.org/spar/cito/"
      },
      {
        "name": "Art and Rare Materials Core Ontology",
        "prefix": "arm",
        "url": "https://ld4p.github.io/arm/core/ontology/0.1/"
      },
      {
        "name": "VRA Core",
        "prefix": "vra",
        "url": "http://purl.org/vra/"
      }
    ]
  },
  {
    "title": "Resources",
    "open": false,
    "fields": [],
    "items": [
      {
        "label": "Samvera MODS to RDF Working Group: MODS to RDF Mapping Recommendations",
        "url": "https://goo.gl/SGCfev"
      },
      {
        "label": "Predicate decision tree",
        "url": "https://docs.google.com/document/d/1oMvVlGuBwD5U1251oxNmTZn7WgkNTj6tF-k1hOYjnac/edit"
      },
      {
        "label": "Notes to BIBFRAME title use",
        "url": "https://www.loc.gov/bibframe/docs/pdf/bf2-titles-march2017.pdf"
      },
      {
        "label": "VRA Core",
        "url": "http://www.core.vraweb.org/"
      },
      {
        "label": "imageOf example",
        "url": "http://core.vraweb.org/examples/html/example029_full.html"
      },
      {
        "label": "TTL example",
        "url": "https://github.com/mixterj/VRA-RDF-Project/blob/master/data/sample/ttl/record2.ttl"
      },
      {
        "label": "Mapping of fcrepo3 attributes",
        "url": "https://github.com/fcrepo4-exts/migration-utils"
      }
    ]
  }
]

export const state = () => ({
  metadataFieldsOverview: JSON.parse(JSON.stringify(metadataFieldsOverview))
})

export const useInfoStore = defineStore('info', {
  state,
  actions: {
    sortFieldsOverview (payload) {
      // Handle both old format (just locale) and new format ({locale, i18nInstance})
      const params = typeof payload === 'string' ? { locale: payload } : payload
      if (!params?.i18nInstance) return
      params.i18nInstance.locale = params.locale
      for (let section of this.metadataFieldsOverview) {
        section.fields.sort((a, b) => params.i18nInstance.t(a.title).localeCompare(params.i18nInstance.t(b.title), params.locale))
      }
    },
    initFieldsOverview () {
      this.metadataFieldsOverview[0].fields[0].open = true
    },
    switchFieldsOverview (id) {
      for (let cat of this.metadataFieldsOverview) {
        for (let f of cat.fields) {
          if (f.id === id) {
            f.open = true
          } else {
            f.open = false
          }
        }
      }
    }
  }
})

export default useInfoStore
