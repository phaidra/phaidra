import i18n from '../../i18n/i18n'

export const state = () => ({
  metadataFieldsOverview: [
    {
      title: 'Metadata fields',
      open: true,
      fields: [
        {
          title: 'Abstract',
          predicate: 'bf:Summary',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'Summary or abstract of the described resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'In case of textual resources as articles, reviews, etc., you may provide an abstract of the content.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Accession number',
          predicate: 'opaque:cco_accessionNumber',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The identification number assigned to a particular donation or acquisition of the analogue object.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Enter the identification number assigned to a particular donation or acquisition of the object.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Associated with',
          predicate: 'rdax:P00009',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The corporate body associated with the object.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the corporate body associated with your resource. <br> You have two options: you can select the value from the drop-down list, or you can click on the diagram icon on the right and navigate the organizational structure of the University of Vienna.',
                level2: '',
                level3:
                  'Tracking down people and institutions associated with the resource can be useful to allow reuse, especially if data has restricted access or it is no longer available. These are cases where human intervention is involved (e.g. sending an email to the metadata owner or calling to receive instructions). Fill in the field to provide an explicit contact in the metadata.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://pid.phaidra.org/univie-org/"> University Vienna Organization Structure </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Available language',
          predicate: 'schema:availableLanguage',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'An additional available language someone may use with audio and video resources.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Use this field when your resource can be additionally viewed, played, run, etc., in languages other than the main one.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="http://id.loc.gov/vocabulary/languages"> MARC List for Languages </a> <br> <a href="https://vocab.phaidra.org/vocabulary/WKFZ-VG0C"> Language Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Event',
          predicate: 'ebucore:hasRelatedEvent',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Events, all real or fictional.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  '',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                ''
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Sound characteristic',
          predicate: 'bf:soundCharacteristic',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Technical specification relating to the encoding of sound in a resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  '',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                ''
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Audience',
          predicate: 'dcterms:audience',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The entity for whom the resource is intended or useful.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the class of target people (e.g. a restriction by age) for whom the object is intended or useful. <br> You can either enter your own value or select it from the controlled list.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/en/collections/T465-XDJS.html">Audience Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Awards',
          predicate: 'bf:awards',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information on awards associated with the described resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'If existing, you can provide information on an award associated with the described resource.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Carrier type',
          predicate: 'rdau:P60048',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The format of a storage medium.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'This field expresses the storage medium of the physical source. <br>Select a value from the drop-down list. In case the value you want to select is not in the list, choose <i>Other</i> and notify the metadata administrators.', // NB: there's no "Other" in the list rigtht now
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/YGE3-S9WD"> Carrier type Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Level of description',
          predicate: 'phaidra:levelOfDescription',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'Can be used inside "Complex subject" to specify what the subject metadata are describing.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Important in cases where the same metadata fields have to be used on different description levels (ie dimensions - of the photography vs dimensions of the instrument depicted on the photography -, creation date, etc).',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/W2ZN-QEF6">Level of description</a>. Current values: <a href="https://vocab.phaidra.org/vocabulary/HQ7N-3Q2W">Digitized object</a> or <a href="https://vocab.phaidra.org/vocabulary/TG30-5EM3">Represented object</a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Citation',
          predicate: 'cito:cites cito:isCitedBy cito:citesAsDataSource', // there are 3 predicates here. I didn't know how to encode them
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A reference to another resource. A citation may be either direct and explicit (as in the reference list of a journal article), indirect (e.g. a citation to a more recent paper by the same research group on the same topic), or implicit (e.g. as in artistic quotations or parodies, or in cases of plagiarism).'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'With this field you can provide a bibliographic reference for your resource. You first need to specify the type of citation (Cites or Is cited by) and then format the citation in the available subfields.',
                level2:
                  'When the resource you are uploading is research data, make sure you state the scholarly output of your dataset. Explicitly defining the link between dataset and the related publication is in compliance with Open Access policies. It also ensures faster exposure of the dataset in the OpenAIRE portal, to which Phaidra metadata are exposed.',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Condition',
          predicate: 'arm:ConditionAssessment',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Assessment and/or documentation of the physical condition of an item, including damage, material vulnerabilities, special storage requirements, etc.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'If relevant, provide an assessment regarding the physical condition of the resource, including damage, material vulnerabilities, etc.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Contribution',
          predicate: 'role:',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information about any person or organization involved in the lifecycle of the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'You are required to provide the name of at least one person involved in the lifecycle of the object. <br> This field consists of four parts: <ul> <br> <li><b>Contributor role</b>: <br> You can choose the type of role from the list offered to you through the suggester. On the right, specify if the role refers to a person (<i>Personal</i>) or an organization (<i>Corporate</i>).</li><br><li><b>Contributor name</b>: <br> Name and surname of the person or organization related to the role you previously selected. In case of an organization, select the unit of the University of Vienna from the drop-down list or enter the value manually if it is an external organization. </li><br><li><b>Contributor identifier</b>: <br> Where available, it is recommended to add an identifier. Choose the type of identifier from the drop-down list and write the code on the right.</li><br><li><b>Contributor affiliation</b>: <br> You can specify which organization the person is affiliated to. In case of an organizational unit of the University of Vienna, select the value from the list.</ul> <br> If you have more than one contributors, press on the right of the section to duplicate the section. You can also modify the order of the contributors by using the arrows.',
                level2: '',
                level3:
                  'A persistent author identifier can help computers to interpret your data in a meaningful way, to create links between datasets, publications and researchers, and to increase discoverability. To make your data Findable, reference author identifiers when describing your resource.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://www.loc.gov/marc/relators/relaterm.html">MARC Code List for Relators </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Date',
          predicate: 'dcterms:date', // should we add the whole list of predicates?
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A point or period of time associated with an event in the lifecycle of the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Each resource is bounded to a time span, whatever type of event it refers to (e.g. creation, production, publication or modification, acquisition). When you describe your resource, it is thus highly recommended to provide any chronological indication of its life cycle. <br><b>Note:</b> This field should not express a date associated with the intellectual content of the resource. If you refer to this type of information, use instead the <i>Temporal coverage</i> field. <br> Phaidra Editor provides you with many types of dates that you can choose from: <br> <ul><li><b>Date</b>: <br> A point or period of time associated with an event in the lifecycle of the resource.</li> <li><b>Date created</b>: <br>Date of creation of the resource.</li> <li><b>Date modified</b>: <br> Date on which the resource was changed. </li><li><b>Date available</b>: <br> Date (often a range) that the resource became or will become available.</li> <li><b>Date issued</b>: <br> Date of formal issuance (e.g. publication) of the resource</li> <li><b>Date valid</b>: <br>Date (often a range) of validity of a resource.</li> <li><b> Date accepted </b>: <br>Date of acceptance of the resource.</li> <li><b>Date copyrighted</b>: <br> Date of copyright.</li> <li><b>Date submitted</b>: <br>Date of submission of the resource.</li> <li><b>Date of production:</b> <br>Date of the inscription, fabrication, construction, etc., of an unpublished resource.</li> <li><b>Date accessioned</b>: <br> Date on which an identification number was assigned to a particular donation or acquisition of the analogue object.</li> </ul> <br>If you need more than one type of date, duplicate the field.',
                level2:
                  'Enriching the contextual knowledge about the data should be done in a machine-actionable way in order to foster its discovery. This means that selecting a specific Date which conforms to the context you are referring to (e.g. <i>Date created</i> or <i>Date issued</i>) should be preferrable to the more general <i>Date</i>. The more accurate and meaningful your metadata is, the more findable, interoperable and reusable your resource is. ',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Depicted/represented place',
          predicate: 'dcterms:spatial',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The geographic area represented in the content of the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Use this field when the intellectual or artistic content of your object is about or is depicting a place. E.g. the place represented in a photograph or the place which the research data refer to. <br> Use the suggester to find the suitable place or add your own value. If needed, you can duplicate the field. <br> <b>Note:</b> This field describes the place covered or represented by the content of the resource, not the place where the resource was created or published. For the latter type of information, use the other available fields.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://www.geonames.org/"> GeoNames </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Depth',
          predicate: 'schema:depth',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The depth of the item.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the depth of the object, choosing the measurement unit.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Description',
          predicate: 'bf:Note',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information, usually in textual form, on attributes of a resource or some aspect of a resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Enter a brief, general description of the resource.<br> This field is intended to give the user an overall account of the intellectual content of the resource.',
                level2:
                  'When describing your object, remember that using a specific field instead of combining information in a free-text general description will improve the quality of your metadata and would let your resource be more easily found and accessed in the <i>Linked Open Data</i> network. Before entering plain text, make sure to first check all the available fields, so you can granularly specify the content of the object in terms of topic, time and space. In case you have additional contextual details to mention (e.g. the linking to a project), we recommend you to press the button at the bottom of the submit form and check the list of additional fields if there is any that fits your needs. <br> Provide the description of your resource in another relevant language. Enriching your metadata by adding a translation makes the resource more findable for people speaking different languages and allows its reuse in a multilingual environment.',
                level3:
                  'All the above suggestions are pivotal to accomplish the goal of creating a FAIR digital resource. Accurate attributes and relationships specified in a machine-readable way (e.g. <i>X depicts Y</i>) ensure that the metadata you are creating are meaningful. Keep in mind that the more detail you put in your metadata, higher is the chance that your data will be further discovered and reused.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Diameter',
          predicate: 'vra:diameter',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The diameter of the item.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the diameter of the object, choosing the measurement unit.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Digitization note',
          predicate: 'phaidra:DigitizationNote',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information regarding the digitization process (e.g. scanner, OCR process, etc.).'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Use this field to record technical information about the digitization of the resource, e.g. the hardware, software, resolution, color settings, equipment and formats used for the digitization process.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Extent',
          predicate: 'rdau:P60550',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A type, number, and measurement unit that quantify an aspect of the extent of a resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Record the extent (size or dimension) of the object by giving the number of units and the type of unit (e.g. "4 folders", "4 boxes"). <br> Use this field only when the resource needs to be described in a measuring unit other than meter (m). If this is not the case, please consider the fields <i>Height</i>, <i>Width</i>, <i>Weight</i>, <i>Depth</i>, <i>Diameter</i>.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Funder',
          predicate: 'frapo:hasFundingAgency',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The funding agency that provides funding for the research or project related to the object.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the name of the Project Funder related to your data, providing its identifier where available.',
                level2: '',
                level3:
                  'A persistent author identifier can help computers to interpret your data in a meaningful way, to create links between datasets, publications and researchers, and to increase discoverability. To make your data Findable, reference the Funder identifier when describing your resource.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://pid.phaidra.org/vocabulary/en/collections/BBDA-1SJY.html"> Funders Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Genre',
          predicate: 'schema:genre',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'Genre of the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'In some cases, as for example a music album, a specification of the genre (e.g. &#34;pop&#34;) may be helpful to provide a more granular context to the resource. <br> Select the value from the drop-down list. If this is not in the list, choose <i>Other</i> and notify the metadata administrators.', // right now the value "Other" is not in the list
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/2H73-WG6Y">Genre Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Height',
          predicate: 'schema:height',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The height of the item.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the height of the object, choosing the measurement unit.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Inscription',
          predicate: 'vra:hasInscription',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'All marks or written words added to the object at the time of production or in its subsequent history, including signatures, dates, dedications, texts, and colophons, as well as marks, such as the stamps of silversmiths, publishers, or printers.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Enter any marks or written words added to the image at the time of production or in its subsequent history, including signatures, dates, dedications, texts, and colophons, as well as marks, such as the stamps of silversmiths, publishers, or printers.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Is contained in',
          predicate: 'rdau:P60101',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information about the larger resource of which the described resource is a discrete component.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'In case the object you are describing is part of a larger resource (for example, book chapters, multi-volume-books or maps within atlases), you can use this field to register information about the resource of which the object is a component.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Is in series',
          predicate: 'rdau:P60193',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information about the resource in which the described item has been issued as a part of a series.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'If you are uploading objects published periodically, with no defined end at the start, you can use this field for describing contextual information about. Additionally to article in journals, this field could also refer to films or television episodes which are part of a series.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Keywords',
          predicate: 'dce:subject',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The topic of the resource, represented using keywords.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Add useful keywords to represent the topic of the resource, specifying their language on the right.',
                level2:
                  'This field is particularly important to help users locate and retrieve the resource. The format of the values you put within the field thus plays an important role. To avoid the ambiguity that arises from synonymous terms, homonyms, variant spellings and other pitfalls, controlled vocabularies or authority files can be useful resources to look at. <br> If possible, duplicate the field in another relevant language. Providing keywords in more than one language makes the resource more findable for people speaking different languages and allows its reuse in a multilingual environment.',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Language',
          predicate: 'dcterms:language',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A designation of the language in which the content of the resource is expressed.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the language of the resource, choosing the value from the drop-down list. Make sure you are referring to the language of the resource, not the language of the metadata. <br>If the content of the resource is in more than one language, duplicate the field.',
                level2:
                  'The language of an object provides relevant context to the user. We highly encourage you to fill in this field if your resource contains text or speech.',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="http://id.loc.gov/vocabulary/languages"> MARC List for Languages </a> <br> <a href="https://vocab.phaidra.org/vocabulary/WKFZ-VG0C"> Language Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Language of subtitles',
          predicate: 'schema:subtitleLanguage',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Languages in which subtitles/captions are available.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'If the resource (e.g. an audio or video file) is provided of subtitles, specify their language choosing the value from the list. <br> If subtitles are given in more than one language, duplicate the field.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="http://id.loc.gov/vocabulary/languages"> MARC List for Languages </a> <br> <a href="https://vocab.phaidra.org/vocabulary/WKFZ-VG0C"> Language Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Material',
          predicate: 'vra:material',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The substance of which a work or an image is composed.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Provide information about the material of the physical resource. <br> You have two options to do that: you can manually enter the value using the first field <i>Material</i> or you can select a pre-filtered value from the drop-down list in the second field <i>Material</i>.', // review this guideline
                level2:
                  'The use of controlled vocabularies helps to better integrate your data with other resources in the Linked Open Data network. As best practice, check first the drop-down list of the field to see if the value you need is there.',
                level3:
                  'Controlled vocabularies that have globally unique and persistent identifiers are key to the vision of FAIR data. They remove ambiguity in the meaning of your published data, helping people and computers to understand exactly the concept you are referring to and ensuring access and interoperability. To render your data FAIR, choose a value for Material from the controlled list.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/VPSR-KHRC"> Material Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Motion picture adaptation of',
          predicate: 'rdau:P60227',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A relationship that links the object with a resource that is adapted as a motion picture.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Use this field when the the object you are describing is a motion picture that has been adapted from another resource. <br> In this field you can give information about the original resource:<ul><br><li>Title: <br> Title of the work. </li> <li>Role: <br>Choose the type of role from the suggester and add the name and surname of the person related to the role you previously selected.</li></ul>',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Number of pages',
          predicate: 'schema:numberOfPages',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The number of pages in the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Enter the number of pages of the object.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Issue',
          predicate: 'bibo:issue',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'An issue number.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Enter the issue number (e.g. of a journal).',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Volume',
          predicate: 'bibo:volume',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'A volume number.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Enter the volume number (e.g. of a journal).',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Object type',
          predicate: 'edm:hasType',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The physical form or intellectual content of the object being described. It is a more detailed sub-type refining the broader <i>Resource type</i> field.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'These controlled terms are useful for filtering search results. <br> Select a value from the drop-down list. If the resource involves more than one type, duplicate the field. In case the term you want to select is not in the list, choose <i>Other</i> and notify the metadata administrators. <br> If you are describing an audio or video resource, take into consideration also the <i>Carrier type</i> field.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/NB34-DPJR"> Object type Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Page end',
          predicate: 'schema:pageEnd',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The page on which the work ends.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Enter the page end of the object.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Page start',
          predicate: 'schema:pageStart',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The page on which the work starts.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Enter the page start of the object.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Parallel title',
          predicate: 'bf:ParallelTitle',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'An alternative name for the resource.' // TO-DO description
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Enter the title used as a substitute or alternative to the formal title of the resource. These are usually secondary titles, abbreviations, titles with different transliterations, translations of a title, etc. <br> The parallel title does not refer to the translation supplied by the cataloguer.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Place of creation',
          predicate: 'vra:placeOfCreation',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Place where the work or its components was or were created, designed, or produced. It may also be the presumed original location of the work.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Indicate the place where the resource was created. Use the suggester to find the suitable value or write your own value.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://www.geonames.org/"> GeoNames </a> '
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Place of site',
          predicate: 'vra:placeOfSite',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Geographic location where built works (architecture) or monumental works are found.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Indicate the place where the built work is located or where the monumental work is found. Use the suggester to find the suitable value or write your own value.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://www.geonames.org/"> GeoNames </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Physical location',
          predicate: 'bf:physicalLocation',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Location in the holding agency where the item is shelved or stored.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Indicate the place where the resource is stored.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Project',
          predicate: 'frapo:isOutputOf',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The project that is associated with the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'This field gathers information about the project which your resource is related to. <br>It consists of:<br> <br><ul><li> Project name: <br> Name of the project.</li> <br><li> Project acronym: <br> Acronym used to identify the project, based on its full name or title. For example, the ontology "Funding, Research Administration and Projects Ontology" has the acronym "FRAPO"</li> <br><li>Project description: <br> Brief description of the project.</li> <br> <li>Project identifier: <br>The project identification number.</li> <br> <li>Project homepage: <br> The main link to the project.</li> <br> <li> Funder name: <br> The name of the project funder, providing its identifier where available.</li></ul>',
                level2:
                  'Explicit EC or national funding information adheres to Open Access policies and meets the requirements of the <i>OpenAIRE</i> infrastructure. Where applicable, fill in the field to improve discoverability of your resource in the <i>OpenAIRE</i> portal.',
                level3:
                  'Globally unique and persistent identifiers can help computers to interpret your data in a meaningful way, to create automatic links between datasets, publications and researchers, and to increase discoverability. To make your data Findable, reference Project and Funder identifiers when describing your resource.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Provenance',
          predicate: 'dcterms:provenance',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A statement of any changes in ownership and custody of the resource since its creation that are significant for its authenticity, integrity, and interpretation. The statement may include a description of any changes successive custodians made to the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'You may use this field to record any changes in ownership and custody of the resource since its creation that are significant for its authenticity, integrity, and interpretation. The statement may include a description of any changes successive custodians made to the resource.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'bf:provisionActivity',
          predicate: 'bf:provisionActivity',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information about the agent or place relating to the publication, printing, distribution, issue, release, or production of a resource. Not to be used for the entity responsible for digitizing or making the digital representation available.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Use this field for objects which have known publisher and publication date. Enter the name of the publisher, the place and date of the publication. <br> When only the publication date is available, use the <i> Date issued </i> field.', // TO-DO usage notes
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Regional encoding',
          predicate: 'rdau:P60059',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A designation for one or more regions of the world for which a videodisc or video game carrier is encoded, indicating that playback is restricted to a device configured to decode it.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'By selecting the value from the drop-down menu, provide a designation for one or more regions of the world for which a videodisc or video game carrier is encoded.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/HHB2-GXRZ"> Regional encoding Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Remark',
          predicate: 'phaidra:Remark',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Additional information that could be relevant for the identification of the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'You may use this field to add information that generally relates to the resource as a whole. For example, contextual information about the item or the creator of the item, or any dissimilarity between the file you are uploading and a previous version.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Reproduction note',
          predicate: 'phaidra:ReproductionNote',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A note stating if the analogue object is a copy or an original.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'This field helps to make clear whether the analogue object is a copy or an original. Write the value <i>copy</i> or <i>original</i>.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/8MPB-RN23"> Reproduction note Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Scale',
          predicate: 'bf:scale',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Ratio of the dimensions of a form contained or embodied in a resource to the dimensions of the entity it represents, e.g., for images or cartographic resources.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Specify the scale of your cartographic resource.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'See also',
          predicate: 'rdfs:seeAlso',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A URL linking to a related resource that might provide additional information about the subject resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Use this field whenever you want to enter a link to other material related to the resource. <br> Filling in this separate field, instead of adding the URL in a free-text field, makes your data more machine-readable.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Shelf mark',
          predicate: 'bf:shelfMark',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Piece identifier, such as a call or other type of number.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Enter the piece identifier. This could be a call number or a shelf. <br> When filling in this field, make sure to record the physical location in the <i>Physical location</i> field as well.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Subject',
          predicate: 'dcterms:subject',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The topic of the resource, represented using terms from formal, controlled vocabularies.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'This field makes use of many subject classifications available in the Web, as for example the <i>GND (Gemeinsame Normdatei)</i>, a national authority file used by German-speaking libraries, museums and archives. <br> Use the suggester on this field to find the suitable terms that best describe the object. Choose as many terms as necessary by duplicating the field.',
                level2:
                  'The use of controlled vocabularies provides greater consistency helping your data to be searched and integrated with other resources in the <i>Linked Open Data</i> network. As best practice, fill in this field with as many terms as needed.',
                level3:
                  'Controlled vocabularies with globally unique and persistent identifiers are one of the keys to machine-understandability of (meta)data, which is what FAIR guidelines are all about. Metadata expressed in this format is unequivocably read and processed by computers, enabling your resource to be linked with other data, accessed or/and shared. Provide a meaningful classification filling in this field so that you can ensure a broad interoperability of your resource.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'Many'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Subtitle',
          predicate: 'bf:subtitle',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Word, character, or group of words and/or characters that contains the remainder of the title after the main title.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Add the secondary title as it appears in your resource or provide one that allows to complete the main title.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Supplementary content',
          predicate: 'bf:supplementaryContent',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Material such as an index, bibliography, appendix, intended to supplement the primary content of a resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'You may use this field to describe any other material which supplements the primary content of the resource, for example alternate endings or an audio commentary that could be provided as special features on a DVD.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Table of contents',
          predicate: 'bf:TableOfContents',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'A structured list of the contents of the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'If any, provide a list of subunits of the resource, e.g. the list of tracks on a CD or a list of chapters in a book.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Technique',
          predicate: 'vra:hasTechnique',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The production or manufacturing processes, techniques, and methods incorporated in the fabrication or alteration of the work or image.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'To specify the technique used for the creation of the object, you can either enter your own value (in the first occurrence of the field) or select it from a controlled list (in the second occurrence).',
                level2:
                  'The use of controlled vocabularies provides greater consistency helping your data to be searched and integrated with other resources in the <i>Linked Open Data </i> network. As best practice, check first the drop-down list of the field to see if the value you need is there.',
                level3:
                  'Controlled vocabularies which have globally unique and persistent identifiers are key to the vision of FAIR data. They remove ambiguity in the meaning of your published data, helping people and computers to understand exactly the concept you are referring to and ensuring access and interoperability. To render your data FAIR, choose a value for <i>Technique</i> from the controlled list.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/W6R8-EAQS"> Technique Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Temporal coverage',
          predicate: 'dcterms:temporal',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The time period that the content applies to, i.e. that it describes.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Describe the temporal characteristics of the intellectual content of the resource, i.e. what the resource is about (or depicts) in terms of time. You can enter either a formatted date, a range of dates or a period label (e.g. &#34;Neolithic period&#34;). Duplicate this field if needed. <br> <b>Note:</b> This field describes the time period covered or represented by the content of the resource, not the date when the resource was created or published. For this kind of information, use the <i>Date</i> field.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="http://vocab.getty.edu/aat/"> Art and Architecture Thesaurus </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Title',
          predicate: 'dce:title',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A name given to the resource. Typically, a title will be a name by which the resource is formally known.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'As an important access point for digital resources, you are required to provide a title to your resource. <br> If the resource has more than one title, choose the main one and use the <i>Parallel title</i> field for the alternative one. <br> If there is no formal title, formulate an adequate one that could uniquely identify the object in terms of content (e.g. people, events, activities), geographical location or period of time. Whenever possible, a descriptive and informative title is preferred against more general titles as &#34;unknown&#34; or id numbers. <br>Since titles are nearly always utilized for search, consider incorporating important keywords into the text. Also, make sure the object has its own unique title against the collection it is part of.',
                level2:
                  'Where possible, provide a translation of the title in another relevant language. Enriching your metadata by adding a translation makes the resource more findable for people speaking different languages and allows its reuse in a multilingual environment.',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Weight',
          predicate: 'schema:weight',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The weight of the item.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the weight of the object, choosing the measurement unit.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Width',
          predicate: 'schema:width',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The width of the item.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Specify the width of the object, choosing the measurement unit.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Alternate identifier',
          predicate: 'rdam:P30004',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'An identification that consists of a code, number, or other string, usually independent of natural language and social naming conventions, used to identify a resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'If any, add an alternative identifier (other than Phaidra persistent identifier) that the resource might be provided of. The types of identifiers could be: DOI, Handle, URI, URN, AC-Number. <br> If you have more than one, duplicate the field.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="http://id.loc.gov/vocabulary/identifiers.html"> Standard Identifier Scheme </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Duration',
          predicate: 'schema:duration',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The duration of the item (movie, audio recording, event, etc.) in ISO 8601 date and time format.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1: 'Specify the duration of the item.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'ISO 8601 date and time format'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'File name',
          predicate: 'ebucore:filename',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content: 'The name of the file containing the resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'The value of this field is automatically filled in when the user uploads the object. The name can still be changed by the user afterwards.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Format',
          predicate: 'dce:format',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Technical specification relating to the encoding of a resource.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'This field expresses technical specifications relating to the encoding of a resource, as for example "Dolby Digital 5.1". <br> Select the value from the controlled list.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/FDVS-NMG1">DC Format Phaidra Vocabulary</a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'MIME type',
          predicate: 'ebucore:hasMimeType',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The file format, expressed as an authorized term from the <i>Internet Media Types (IMT) </i> controlled vocabulary.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'The information about the file format can be relevant to determine the equipment needed to display or operate a resource (e.g. if the described resource has format PDF, you need a PDF reader to use it). <br> Once you upload the file, the value is pre-selected by the system. Check if this value fits your digital object. If not, choose the right one from the drop-down menu. <br><b>Note:</b> If possible, before uploading the file consider file formats that are widely used and supported by the most commonly used software and tools. A list of the formats recommended by Phaidra can be found <a href="https://datamanagement.univie.ac.at/en/about-phaidra/formats/">here</a>. ',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://www.iana.org/assignments/media-types/media-types.xhtml"> Internet Media Types (IMT) </a> '
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Resource type',
          predicate: 'dcterms:type',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'A term that specifies the characteristic and general type of content of the resource. This information characterizes the resource at a higher level than the <i>Object type</i> field.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'This field is automatically generated by the system once the content-specific submit form is selected.',
                level2: '',
                level3: ''
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://vocab.phaidra.org/vocabulary/7E4S-MA30"> Resource type Phaidra Vocabulary </a> '
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Access rights',
          predicate: 'dcterms:accessRights',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information about who can access the resource or an indication of its security status. <br>The Access rights vocabulary here implemented builds on <i>COAR Access Rights Vocabulary</i>.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'Declare the access status of a resource by selecting the value from the drop-down list.',
                level2: '',
                level3:
                  'Well-defined conditions under which data are accessible help a machine automatically understand the requirements and tell the user how he may access the resource. Make sure you are clearly stating accessibility, choosing <i>Open Access</i> when possible.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://pid.phaidra.org/vocabulary/PY38-5KQZ"> Access rights Phaidra Vocabulary </a>'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'License',
          predicate: 'edm:rights',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'The copyright, usage and access rights that apply to the digital representation.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'You are required to select the license from a controlled list. If you need to learn more about differences between these licenses, read the <a href="https://creativecommons.org/about/cclicenses/"> Creative Commons webpage</a>.',
                level2: '',
                level3:
                  'To increase the reusability of your data, make sure you know who the data rights holder is before uploading the resource. It should also be clear what license applies.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content:
                '<a href="https://creativecommons.org/licenses/"> Creative Commons licenses </a> '
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: 'Required'
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        },
        {
          title: 'Rights statement',
          predicate: 'dce:rights',
          open: false,
          sections: [
            {
              id: 'description',
              title: 'Description',
              content:
                'Information about rights held in and over the resource. Typically, rights information includes a statement about various property rights associated with the resource, including intellectual property rights.'
            },
            {
              id: 'usagenotes',
              title: 'Usage notes',
              content: {
                level1:
                  'You can use this field to give supplemental information on intellectual property rights or access arrangements that is additional to the license you selected. For instance, you could specify details concerning accessibility, reproduction, copyright holder, restrictions, or securing permissions for use.',
                level2: '',
                level3:
                  'In addition to machine-understandable license information, a human-readable text concerning the conditions (e.g. obligations, restrictions) under which data can be reused can still be significant to the user to prevent ambiguity on your data. When you think a further specification might be useful, consider fill in the field.'
              }
            },
            {
              id: 'vocabulary',
              title: 'Vocabulary',
              content: 'None'
            },
            {
              id: 'obligation',
              title: 'Obligation',
              content: ''
            },
            {
              id: 'occurrence',
              title: 'Occurrence',
              content: ''
            },
            {
              id: 'exampleHR',
              title: 'Example',
              content: ''
            }
          ]
        }
      ]
    }
  ]
})

const mutations = {
  sortFieldsOverview (state, locale) {
    i18n.locale = locale
    for (let section of state.metadataFieldsOverview) {
      section.fields.sort((a, b) => i18n.t(a.title).localeCompare(i18n.t(b.title), locale))
    }
  },
  initFieldsOverview (state) {
    state.metadataFieldsOverview[0].fields[0].open = true
  },
  switchFieldsOverview (state, id) {
    for (let cat of state.metadataFieldsOverview) {
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

const actions = {
  sortFieldsOverview ({ commit, state }, locale) {
    commit('sortFieldsOverview', locale)
  }
}

export default {
  state,
  mutations,
  actions
}
