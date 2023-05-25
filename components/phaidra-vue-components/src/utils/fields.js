import uuid from './uuid'

const fields = [
  {
    id: 'alternate-identifier',
    fieldname: 'Alternate identifier',
    predicate: 'rdam:P30004',
    component: 'p-alternate-identifier',
    type: 'ids:doi',
    showType: true,
    disableType: false,
    multiplicable: false,
    identifierLabel: 'Identifier',
    valueErrorMessages: [],
    value: '',
    definition: 'An alternative identifier (other than Phaidra persistent identifier) that uniquely identifies the resource. Relates a manifestation to an appellation of manifestation that consists of a code, number, or other string, usually independent of natural language and social naming conventions, used to identify a manifestation.'
  },
  {
    id: 'resource-type',
    fieldname: 'Resource type',
    predicate: 'dcterms:type',
    component: 'p-select',
    vocabulary: 'resourcetype',
    required: true,
    multiplicable: false,
    disabled: true,
    hidden: false,
    readonly: true,
    label: 'Resource type',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The nature of the resource. Example: Image, Text, Sound'

  },
  {
    id: 'resource-type-buttongroup',
    fieldname: 'Resource type (button group)',
    predicate: 'dcterms:type',
    component: 'p-resource-type-buttongroup',
    vocabulary: 'resourcetype',
    required: true,
    multiplicable: false,
    disabled: true,
    hidden: false,
    readonly: true,
    label: 'Resource type',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The nature of the resource. Example: Image, Text, Sound'
  },
  {
    id: 'object-type',
    fieldname: 'Object type',
    predicate: 'edm:hasType',
    component: 'p-select',
    vocabulary: 'objecttype',
    multiplicable: true,
    label: 'Object type',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'This property relates a resource with the concepts it belongs to. It does not capture aboutness. Example: Photography',
    helptext: 'An object type represents real-world entity. For example, an object type can represent a photography, an interview, a lecture or a letter.'
  },
  {
    id: 'object-type-checkboxes',
    fieldname: 'Object type (checkboxes)',
    predicate: 'edm:hasType',
    component: 'p-object-type-checkboxes',
    vocabulary: 'objecttype',
    resourceType: '',
    multiplicable: true,
    label: 'Object type',
    selectedTerms: [],
    errorMessages: [],
    definition: 'This property relates a resource with the concepts it belongs to. It does not capture aboutness. Example: Photography',
    helptext: 'An object type represents real-world entity. For example, an object type can represent a photography, an interview, a lecture or a letter.'
  },
  {
    id: 'genre',
    fieldname: 'Genre',
    predicate: 'schema:genre',
    component: 'p-select',
    vocabulary: 'genre',
    label: 'Genre',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'Genre of the creative work, broadcast channel or group. Example: Master thesis, Comedy, Late Renaissance'

  },
  {
    id: 'version-type',
    fieldname: 'Version type',
    predicate: 'oaire:version',
    component: 'p-select',
    vocabulary: 'versiontypes',
    label: 'Version type',
    showValueDefinition: false,
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The status in the publication process of journal articles.'
  },
  {
    id: 'access-right',
    fieldname: 'Access rights',
    predicate: 'dcterms:accessRights',
    component: 'p-select',
    vocabulary: 'accessright',
    label: 'Access right',
    showValueDefinition: false,
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'Information about who can access the resource or an indication of its security status.'
  },
  {
    id: 'title',
    fieldname: 'Title',
    predicate: 'dce:title',
    component: 'p-title',
    type: 'bf:Title',
    required: true,
    multiplicable: true,
    multilingual: true,
    ordergroup: 'title',
    titleLabel: 'Title',
    title: '',
    titleErrorMessages: [],
    subtitle: '',
    subtitleLabel: '',
    hideSubtitle: false,
    language: '',
    definition: 'A name given to the resource. Typically, a Title will be a name by which the resource is formally known.'
  },
  {
    id: 'parallel-title',
    fieldname: 'Parallel title',
    predicate: 'dce:title',
    component: 'p-title',
    type: 'bf:ParallelTitle',
    required: true,
    multiplicable: true,
    multilingual: true,
    ordergroup: 'title',
    titleLabel: '',
    title: '',
    titleErrorMessages: [],
    subtitle: '',
    subtitleLabel: '',
    hideSubtitle: false,
    language: '',
    definition: 'Title in another language and/or script.'
  },
  {
    id: 'description',
    fieldname: 'Description',
    predicate: 'bf:note',
    type: 'bf:Note',
    component: 'p-text-field',
    multiplicable: true,
    multilingual: true,
    multiline: true,
    label: 'Description',
    value: '',
    language: '',
    definition: 'Information, usually in textual form, on attributes of a resource or some aspect of a resource.'
  },
  {
    id: 'abstract',
    fieldname: 'Abstract',
    predicate: 'bf:note',
    type: 'bf:Summary',
    component: 'p-text-field',
    multiplicable: true,
    multilingual: true,
    multiline: true,
    label: 'Abstract',
    value: '',
    language: '',
    definition: 'Summary or abstract of the resource described.'
  },
  {
    id: 'table-of-contents',
    fieldname: 'Table of contents',
    predicate: 'bf:tableOfContents',
    type: 'bf:TableOfContents',
    component: 'p-text-field',
    multiplicable: true,
    multilingual: true,
    multiline: true,
    label: 'Table of contents',
    value: '',
    language: '',
    definition: 'Table of contents of the described resource.'
  },
  {
    id: 'date-edtf',
    fieldname: 'Date',
    predicate: 'date',
    component: 'p-date-edtf',
    multiplicable: true,
    picker: false,
    label: 'Date',
    value: '',
    dateLabel: '',
    type: 'dcterms:created',
    hideType: false,
    valueErrorMessages: [],
    typeErrorMessages: [],
    definition: 'A point or period of time associated with an event in the lifecycle of the resource.'
  },
  {
    id: 'note',
    fieldname: 'Note',
    predicate: 'bf:note',
    type: 'phaidra:Remark',
    component: 'p-text-field',
    multilingual: true,
    multiline: true,
    label: 'Note',
    value: '',
    language: '',
    definition: 'Information, usually in textual form, on attributes of a resource or some aspect of a resource.'
  },
  {
    id: 'digitization-note',
    fieldname: 'Digitization note',
    predicate: 'bf:note',
    type: 'phaidra:DigitizationNote',
    component: 'p-text-field',
    multilingual: true,
    multiline: true,
    label: 'Digitization note',
    value: '',
    language: '',
    definition: 'Information, usually in textual form, on attributes of a resource or some aspect of a resource.'
  },
  {
    id: 'condition-note',
    fieldname: 'Condition',
    predicate: 'bf:note',
    type: 'arm:ConditionAssessment',
    component: 'p-text-field',
    multilingual: true,
    multiline: true,
    label: 'Condition',
    value: '',
    language: '',
    definition: 'Information, usually in textual form, on attributes of a resource or some aspect of a resource.'
  },
  {
    id: 'reproduction-note',
    fieldname: 'Reproduction note',
    predicate: 'bf:note',
    type: 'phaidra:ReproductionNote',
    component: 'p-text-field',
    label: 'Reproduction note',
    value: '',
    definition: 'Information, usually in textual form, on attributes of a resource or some aspect of a resource.'
  },
  {
    id: 'language',
    fieldname: 'Language',
    predicate: 'dcterms:language',
    component: 'p-select',
    vocabulary: 'lang',
    required: false,
    multiplicable: true,
    label: 'Language',
    value: '',
    errorMessages: [],
    definition: 'A language of the resource.'
  },
  {
    id: 'subtitle-language',
    fieldname: 'Language of subtitles',
    predicate: 'schema:subtitleLanguage',
    component: 'p-select',
    vocabulary: 'lang',
    multiplicable: true,
    label: 'Language of subtitles',
    value: '',
    errorMessages: [],
    definition: 'Languages in which subtitles/captions are available.'
  },
  {
    id: 'role',
    fieldname: 'Role',
    predicate: 'role',
    type: 'schema:Person',
    component: 'p-entity',
    roleVocabulary: 'rolepredicate',
    multiplicable: true,
    ordered: true,
    firstname: '',
    firstnameLabel: 'Firstname',
    lastname: '',
    lastnameLabel: 'Lastname',
    name: '',
    nameLabel: 'Name',
    role: '',
    roleLabel: 'Role',
    hideRole: false,
    definition: 'Function played or provided by a contributor, e.g., author, illustrator, etc.'
  },
  {
    id: 'production-place',
    fieldname: 'Production place',
    predicate: 'role',
    type: 'schema:Organization',
    component: 'p-entity',
    roleVocabulary: 'rolepredicate',
    multiplicable: true,
    ordered: true,
    firstname: '',
    lastname: '',
    name: '',
    organizationText: '',
    organizationLabel: 'Production place',
    role: 'role:prp',
    hideRole: true,
    definition: 'The place of production (e.g., inscription, fabrication, construction, etc.) of a resource in an unpublished form'
  },
  {
    id: 'production-company',
    fieldname: 'Production company',
    predicate: 'role',
    type: 'schema:Organization',
    component: 'p-entity',
    roleVocabulary: 'rolepredicate',
    multiplicable: true,
    ordered: true,
    firstname: '',
    lastname: '',
    name: '',
    organizationText: '',
    organizationLabel: 'Production company',
    role: 'role:prn',
    hideRole: true,
    definition: 'An organization that is responsible for financial, technical, and organizational management of a production for stage, screen, audio recording, television, webcast, etc.'
  },
  {
    id: 'role-extended',
    fieldname: 'Role - extended',
    predicate: 'role',
    type: 'schema:Person',
    component: 'p-entity-extended',
    label: 'Contribution',
    multiplicable: true,
    ordered: true,
    institutionLabel: '',
    affiliation: '',
    affiliationText: '',
    affiliationType: 'select',
    organization: '',
    organizationText: '',
    organizationType: 'select',
    identifierText: '',
    identifierLabel: '',
    showIdentifier: true,
    showIdentifierType: true,
    disableIdentifierType: false,
    identifierVocabulary: 'entityidentifiertype',
    firstname: '',
    firstnameLabel: '',
    lastname: '',
    lastnameLabel: '',
    name: '',
    nameLabel: 'Name',
    role: '',
    roleLabel: 'Role',
    roleVocabulary: 'rolepredicate',
    nameErrorMessages: [],
    firstnameErrorMessages: [],
    lastnameErrorMessages: [],
    roleErrorMessages: [],
    affiliationErrorMessages: [],
    affiliationTextErrorMessages: [],
    organizationErrorMessages: [],
    organizationTextErrorMessages: [],
    hideRole: false,
    enableTypeSelect: true,
    organizationSelectLabel: 'Please choose',
    affiliationSelectLabel: 'Please choose affiliation',
    definition: 'Function played or provided by a contributor, e.g., author, illustrator, etc.'
  },
  {
    id: 'keyword',
    fieldname: 'Keywords',
    predicate: 'dce:subject',
    component: 'p-keyword',
    suggester: 'keywordsuggester',
    disableSuggest: false,
    multiplicable: true,
    multilingual: true,
    label: 'Keywords',
    hint: 'Confirm each keyword with enter',
    value: [],
    language: '',
    definition: 'The topic of the resource, represented using keywords.'
  },
  {
    id: 'subject',
    fieldname: 'Subject',
    predicate: 'dcterms:subject',
    type: 'skos:Concept',
    component: 'p-select',
    vocabulary: '',
    multiplicable: true,
    label: 'Subject',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The topic of the resource, represented using a controlled vocabulary.'
  },
  {
    id: 'bk-subject',
    fieldname: 'Basisklassifikation',
    predicate: 'dcterms:subject',
    type: 'skos:Concept',
    component: 'p-subject-bk',
    multiplicable: true,
    label: 'Basisklassifikation',
    searchlabel: 'Search...',
    value: '',
    'rdfs:label': [],
    'skos:prefLabel': [],
    loadedpreflabel: '',
    definition: 'The topic of the resource, represented using a controlled vocabulary.'
  },
  {
    id: 'gnd-subject',
    fieldname: 'Subject (GND)',
    predicate: 'dcterms:subject',
    type: 'skos:Concept',
    component: 'p-subject-gnd',
    multiplicable: true,
    label: 'Subject (GND)',
    searchlabel: 'Search...',
    'rdfs:label': [],
    'skos:prefLabel': [],
    definition: 'The topic of the resource, represented using a controlled vocabulary.'
  },
  {
    id: 'oefos-subject',
    fieldname: 'Subject (ÖFOS)',
    predicate: 'dcterms:subject',
    type: 'skos:Concept',
    component: 'p-subject-oefos',
    multiplicable: true,
    label: 'Subject (ÖFOS)',
    value: '',
    'rdfs:label': [],
    'skos:prefLabel': [],
    loadedpreflabel: '',
    definition: 'The topic of the resource, represented using a controlled vocabulary.'
  },
  {
    id: 'sociocultural-category',
    fieldname: 'Soziokulturelle Kategorie',
    predicate: 'dcterms:subject',
    type: 'skos:Concept',
    component: 'p-select',
    vocabulary: '60PM-DY5T',
    multiplicable: true,
    label: 'Soziokulturelle Kategorie',
    value: '',
    'skos:prefLabel': [],
    showIds: true,
    errorMessages: [],
    definition: 'Subjects from terms collection https://vocab.phaidra.org/vocabulary/en/collections/60PM-DY5T.html'
  },
  {
    id: 'study-plan',
    fieldname: 'Study plan',
    predicate: 'frapo:isOutputOf',
    type: 'aaiso:Programme',
    component: 'p-study-plan',
    multiplicable: true,
    multilingual: true,
    'skos:prefLabel': [],
    notation: '',
    identifier: '',
    name: '',
    nameLanguage: '',
    definition: 'Study plan.'
  },
  {
    id: 'series',
    fieldname: 'Is in series',
    predicate: 'rdau:P60193',
    type: 'schema:CreativeWork',
    component: 'p-series',
    label: 'rdau:P60193',
    title: '',
    titleLanguage: '',
    volume: '',
    issue: '',
    issued: '',
    issuedDateLabel: 'Issued',
    issuedDatePicker: true,
    issn: '',
    idnetifierType: '',
    identifier: '',
    hidePages: true,
    pageStart: '',
    pageEnd: '',
    pageStartLabel: 'Page start',
    pageEndLabel: 'Page end',
    journalSuggest: false,
    definition: 'Relates a resource to a resource in which a part has been issued; a title of a larger resource appears on a part.'
  },
  {
    id: 'contained-in',
    fieldname: 'Is contained in',
    predicate: 'rdau:P60101',
    type: 'schema:CreativeWork',
    component: 'p-contained-in',
    label: 'rdau:P60101',
    title: '',
    titleLanguage: '',
    titleErrorMessages: [],
    subtitle: '',
    roles: [
      {
        id: 'contained-in-role',
        role: 'role:edt',
        firstname: '',
        lastname: '',
        ordergroup: 'contained-in-role'
      }
    ],
    pageStart: '',
    pageEnd: '',
    pageStartLabel: 'Page start',
    pageEndLabel: 'Page end',
    isbn: '',
    isbnLabel: 'ISBN',
    isbnErrorMessages: [],
    identifier: '',
    identifierType: '',
    series: [
      {
        id: 'contained-in-series',
        seriesTitle: '',
        seriesTitleLanguage: '',
        seriesVolume: '',
        seriesIssue: '',
        seriesIssued: '',
        seriesIssn: '',
        seriesIdentifier: '',
        seriesIdentifierType: '',
        multiplicable: false,
        multiplicableCleared: false,
        removable: false
      }
    ],
    seriesType: 'schema:CreativeWork',
    seriesLabel: 'rdau:P60101_rdau:P60193',
    seriesCollapse: false,
    publisherLabel: 'Publisher',
    publisherShowPlace: true,
    publisherShowDate: true,
    publisherType: 'other',
    publisherSearch: false,
    publisherNameLabel: 'PUBLISHER_VERLAG',
    publishingPlaceLabel: 'Place',
    publishingDateLabel: 'Date',
    publisherName: '',
    publisherNameErrorMessages: [],
    publisherOrgUnit: '',
    publisherOrgUnitErrorMessages: [],
    publishingPlace: '',
    publishingDate: '',
    publishingDatePicker: true,
    publisherCollapse: false,
    definition: 'Relates a resource to a larger resource of which a part is a discrete component.'
  },
  {
    id: 'instance-of',
    fieldname: 'Instance of',
    predicate: 'bf:instanceOf',
    type: 'schema:CreativeWork',
    component: 'p-instance-of',
    label: 'Instance of',
    title: '',
    subtitle: '',
    titleLanguage: '',
    indentifierType: '',
    identifierText: '',
    identifierLabel: null,
    identifierTypePlaceholder: '',
    definition: 'Work the Instance described instantiates or manifests. For use to connect Instances to Works.'
  },
  {
    id: 'movieadaptation',
    fieldname: 'Is motion picture adaptation of',
    predicate: 'rdau:P60227',
    type: 'schema:CreativeWork',
    component: 'p-adaptation',
    label: 'Is motion picture adaptation of',
    title: '',
    subtitle: '',
    titleLanguage: '',
    firstname: '',
    lastname: '',
    name: '',
    role: '',
    definition: 'Relates a resource to a resource that is adapted as a motion picture.'
  },
  {
    id: 'event',
    fieldname: 'Event',
    predicate: 'ebucore:hasRelatedEvent',
    type: 'ebucore:Event',
    component: 'p-event',
    name: '',
    nameLanguage: '',
    place: '',
    indentifierType: '',
    identifier: '',
    identifierLabel: null,
    description: '',
    descriptionLanguage: '',
    dateFrom: '',
    dateTo: '',
    definition: 'Events, all real or fictional.'
  },
  {
    id: 'project',
    fieldname: 'Project',
    predicate: 'frapo:isOutputOf',
    type: 'foaf:Project',
    component: 'p-project',
    name: '',
    nameLanguage: '',
    acronym: '',
    description: '',
    descriptionLanguage: '',
    identifier: '',
    homepage: '',
    funderName: '',
    funderIdentifier: '',
    dateFrom: '',
    dateTo: '',
    definition: 'An administrative entity that enabled an endeavour such as a research investigation.'
  },
  {
    id: 'funder',
    fieldname: 'Funder',
    predicate: 'frapo:hasFundingAgency',
    component: 'p-funder',
    name: '',
    nameLanguage: '',
    identifier: '',
    definition: 'A funding agency that provided funding for the resource.'
  },
  {
    id: 'association',
    fieldname: 'Association',
    predicate: 'rdax:P00009',
    component: 'p-association',
    multiplicable: true,
    label: 'Association',
    value: '',
    'skos:prefLabel': [],
    definition: 'Relates an object to a corporate body who is associated with an object.'
  },
  {
    id: 'bf-publication',
    fieldname: 'Publication',
    predicate: 'bf:provisionActivity',
    component: 'p-bf-publication',
    multiplicable: true,
    label: 'Publication',
    showPlace: true,
    showDate: true,
    publisherType: 'other',
    publisherSearch: false,
    publisherNameLabel: 'PUBLISHER_VERLAG',
    publishingPlaceLabel: 'Place',
    publishingDateLabel: 'Date',
    publisherName: '',
    publisherNameErrorMessages: [],
    publisherOrgUnit: '',
    publisherOrgUnitErrorMessages: [],
    publishingPlace: '',
    publishingDate: '',
    publishingDatePicker: true,
    definition: 'Information relating to publication of a resource.'
  },
  {
    id: 'carrier-type',
    fieldname: 'Carrier type',
    predicate: 'rdau:P60048',
    component: 'p-select',
    vocabulary: 'carriertype',
    multiplicable: true,
    label: 'Carrier type',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'Relates a resource to a categorization reflecting a format of a storage medium and housing of a carrier in combination with a type of intermediation device required to view, play, run, etc., the content of a resource.'
  },
  {
    id: 'citation',
    fieldname: 'Citation',
    predicate: 'citation',
    component: 'p-citation',
    multiplicable: true,
    citationLabel: 'Citation',
    identifierLabel: 'Identifier',
    identifier: '',
    type: '',
    citation: '',
    citationLanguage: '',
    disabletype: false,
    definition: 'The citations characterized may be either direct and explicit (as in the reference list of a journal article), indirect (e.g. a citation to a more recent paper by the same research group on the same topic), or implicit (e.g. as in artistic quotations or parodies, or in cases of plagiarism).'
  },
  {
    id: 'shelf-mark',
    fieldname: 'Shelf mark',
    predicate: 'bf:shelfMark',
    component: 'p-text-field',
    multiplicable: true,
    label: 'Call number',
    value: '',
    definition: 'Piece/item identifier, such as a call or other type of number.'
  },
  {
    id: 'temporal-coverage',
    fieldname: 'Temporal coverage',
    predicate: 'dcterms:temporal',
    component: 'p-text-field',
    label: 'Temporal coverage',
    multilingual: true,
    value: '',
    language: '',
    definition: 'Temporal characteristics of the resource. Indicates the period that the content applies to, i.e. that it describes.'
  },
  {
    id: 'provenance',
    fieldname: 'Provenance',
    predicate: 'dcterms:provenance',
    component: 'p-text-field',
    multiline: true,
    multilingual: true,
    label: 'Provenance',
    value: '',
    language: '',
    definition: 'A statement of any changes in ownership and custody of a resource since its creation that are significant for its authenticity, integrity, and interpretation.'
  },
  {
    id: 'physical-location-select-text',
    fieldname: 'Physical location (select)',
    predicate: 'bf:physicalLocation',
    component: 'p-select-text',
    label: 'Physical location',
    selectlabel: 'Physical location',
    multilingual: true,
    selectdisabled: false,
    selectvalue: '',
    textvalue: '',
    value: '',
    vocabulary: '',
    language: '',
    definition: 'Location in the holding agency where the item is shelved or stored. Select box value will be combined with text field.'
  },
  {
    id: 'physical-location-select-text-pool',
    fieldname: 'Standort / Arbeitsbereich (Mediathek - Romanistik)',
    predicate: 'bf:physicalLocation',
    component: 'p-select-text',
    label: 'Arbeitsbereich',
    selectlabel: 'Standort',
    multilingual: true,
    selectdisabled: false,
    selectvalue: '',
    textvalue: '',
    value: '',
    vocabulary: 'pool',
    language: '',
    definition: 'Location in the holding agency where the item is shelved or stored. Select box value will be combined with text field.'
  },
  {
    id: 'physical-location',
    fieldname: 'Physical location',
    predicate: 'bf:physicalLocation',
    component: 'p-text-field',
    label: 'Physical location',
    multilingual: true,
    value: '',
    language: '',
    definition: 'Location in the holding agency where the item is shelved or stored.'
  },
  {
    id: 'accession-number',
    fieldname: 'Accession number',
    predicate: 'opaque:cco_accessionNumber',
    component: 'p-text-field',
    label: 'Accession number',
    value: '',
    definition: 'Use for identification number assigned to a particular donation or acquisition.'
  },
  {
    id: 'extent',
    fieldname: 'Extent',
    predicate: 'rdau:P60550',
    component: 'p-text-field',
    label: 'Extent',
    multilingual: true,
    value: '',
    language: '',
    definition: 'Use to represent the extent of a resource.'
  },
  {
    id: 'number-of-pages',
    fieldname: 'Number of pages',
    predicate: 'schema:numberOfPages',
    component: 'p-literal',
    label: 'Number of pages',
    value: '',
    definition: 'The number of pages in the resource.'
  },
  {
    id: 'sound-characteristic',
    fieldname: 'Sound characteristic',
    predicate: 'bf:soundCharacteristic',
    component: 'p-literal',
    label: 'Sound characteristic',
    value: '',
    definition: 'Technical specification relating to the encoding of sound in a resource.'
  },
  {
    id: 'dce-format-vocab',
    fieldname: 'Format',
    predicate: 'dce:format',
    component: 'p-select',
    vocabulary: 'dceformat',
    multiplicable: true,
    label: 'Format',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The file format, physical medium, or dimensions of the resource.'
  },
  {
    id: 'supplementary-content',
    fieldname: 'Supplementary content',
    predicate: 'bf:supplementaryContent',
    type: 'bf:SupplementaryContent',
    component: 'p-text-field',
    multiplicable: true,
    multilingual: true,
    multiline: true,
    label: 'Supplementary content',
    value: '',
    language: '',
    definition: 'Material such as an index, bibliography, appendix intended to supplement the primary content of a resource.'
  },
  {
    id: 'award',
    fieldname: 'Awards',
    predicate: 'bf:awards',
    type: 'skos:Concept',
    component: 'p-text-field',
    multiplicable: true,
    multilingual: true,
    label: 'Award',
    value: '',
    language: '',
    definition: 'Information on an award associated with the described resource.'
  },
  {
    id: 'audience',
    fieldname: 'Audience',
    predicate: 'dcterms:audience',
    type: 'skos:Concept',
    component: 'p-text-field',
    multiplicable: true,
    multilingual: true,
    label: 'Audience',
    value: '',
    language: '',
    definition: 'A class of entity for whom the resource is intended or useful.'
  },
  {
    id: 'audience-vocab',
    fieldname: 'Audience (vocabulary)',
    predicate: 'dcterms:audience',
    type: 'skos:Concept',
    component: 'p-select',
    vocabulary: 'audience',
    label: 'Audience',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'A class of entity for whom the resource is intended or useful.'
  },
  {
    id: 'regional-encoding',
    fieldname: 'Regional encoding',
    predicate: 'rdau:P60059',
    component: 'p-select',
    vocabulary: 'regionalencoding',
    label: 'Regional encoding',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'A designation for one or more regions of the world for which a videodisc or video game carrier has been encoded, restricting playback to a device configured to decode it.'
  },
  {
    id: 'technique-vocab',
    fieldname: 'Technique (vocabulary)',
    predicate: 'vra:hasTechnique',
    type: 'vra:Technique',
    component: 'p-select',
    vocabulary: 'technique',
    label: 'Technique',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The production or manufacturing processes, techniques, and methods incorporated in the fabrication or alteration of the work or image.'
  },
  {
    id: 'technique-text',
    fieldname: 'Technique',
    predicate: 'vra:hasTechnique',
    type: 'vra:Technique',
    component: 'p-text-field',
    multilingual: true,
    multiplicable: true,
    label: 'Technique',
    value: '',
    language: '',
    'skos:prefLabel': [],
    definition: 'The production or manufacturing processes, techniques, and methods incorporated in the fabrication or alteration of the work or image.'
  },
  {
    id: 'material-vocab',
    fieldname: 'Material (vocabulary)',
    predicate: 'vra:material',
    type: 'vra:Material',
    component: 'p-select',
    vocabulary: 'material',
    label: 'Material',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The substance of which a work or an image is composed.'
  },
  {
    id: 'material-text',
    fieldname: 'Material',
    predicate: 'vra:material',
    type: 'vra:Material',
    component: 'p-text-field',
    multilingual: true,
    multiplicable: true,
    label: 'Material',
    value: '',
    language: '',
    definition: 'The substance of which a work or an image is composed.'
  },
  {
    id: 'diameter',
    fieldname: 'Diameter',
    predicate: 'vra:diameter',
    component: 'p-dimension',
    label: 'Diameter',
    unit: 'CMT',
    vocabulary: 'uncefactsize',
    value: '',
    definition: 'The diameter of the item.'
  },
  {
    id: 'height',
    fieldname: 'Height',
    predicate: 'schema:height',
    component: 'p-dimension',
    label: 'Height',
    unit: 'CMT',
    vocabulary: 'uncefactsize',
    value: '',
    definition: 'The height of the item.'
  },
  {
    id: 'width',
    fieldname: 'Width',
    predicate: 'schema:width',
    component: 'p-dimension',
    label: 'Width',
    unit: 'CMT',
    vocabulary: 'uncefactsize',
    value: '',
    definition: 'The width of the item.'
  },
  {
    id: 'depth',
    fieldname: 'Depth',
    predicate: 'schema:depth',
    component: 'p-dimension',
    label: 'Depth',
    unit: 'CMT',
    vocabulary: 'uncefactsize',
    value: '',
    definition: 'The depth of the item.'
  },
  {
    id: 'weight',
    fieldname: 'Weight',
    predicate: 'schema:weight',
    component: 'p-dimension',
    label: 'Weight',
    unit: 'KGM',
    vocabulary: 'uncefactweight',
    value: '',
    definition: 'The weight of the item.'
  },
  {
    id: 'scale',
    fieldname: 'Scale',
    predicate: 'bf:scale',
    type: 'bf:Scale',
    component: 'p-text-field',
    multilingual: false,
    multiplicable: false,
    label: 'Scale',
    value: '',
    definition: 'Ratio of the dimensions of a form contained or embodied in a resource to the dimensions of the entity it represents, e.g., for images or cartographic resources.'
  },
  {
    id: 'duration',
    fieldname: 'Duration',
    predicate: 'schema:duration',
    component: 'p-duration',
    label: 'Duration',
    value: '',
    hideHours: false,
    hideMinutes: false,
    hideSeconds: false,
    definition: 'The duration of the item (movie, audio recording, event, etc.) in ISO 8601 date format.'
  },
  {
    id: 'see-also',
    fieldname: 'See also',
    predicate: 'rdfs:seeAlso',
    component: 'p-see-also',
    url: '',
    urlLabel: 'URL',
    title: '',
    titleLabel: 'Title',
    titleLanguage: '',
    multiplicable: true,
    multilingual: true,
    definition: 'A URL linking to a related resource.'
  },
  {
    id: 'inscription',
    fieldname: 'Inscription/Stamp',
    predicate: 'vra:hasInscription',
    component: 'p-text-field',
    multiplicable: true,
    multilingual: true,
    label: 'Inscription/Stamp',
    value: '',
    language: '',
    definition: 'All marks or written words added to the object at the time of production or in its subsequent history, including signatures, dates, dedications, texts, and colophons, as well as marks, such as the stamps of silversmiths, publishers, or printers.'
  },
  {
    id: 'spatial-geonames',
    fieldname: 'Depicted/Represented place (Geonames)',
    predicate: 'dcterms:spatial',
    component: 'p-spatial-geonames',
    multiplicable: true,
    label: 'Depicted/Represented place',
    searchlabel: 'Search...',
    hint: 'Press Enter to initiate search',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    'rdfs:label': [],
    'skos:prefLabel': [],
    definition: 'Depicted/Represented place.'
  },
  {
    id: 'spatial-text',
    fieldname: 'Depicted/Represented place',
    predicate: 'dcterms:spatial',
    component: 'p-spatial-text',
    multilingual: true,
    multiplicable: true,
    label: 'Depicted/Represented place',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    language: '',
    definition: 'Depicted/Represented place.'
  },
  {
    id: 'place-of-creation-geonames',
    fieldname: 'Place of creation (Geonames)',
    predicate: 'vra:placeOfCreation',
    component: 'p-spatial-geonames',
    multiplicable: true,
    label: 'Place of creation',
    searchlabel: 'Wien, Großvenediger, Donau Kanal, ...',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    'rdfs:label': [],
    'skos:prefLabel': [],
    definition: 'Place of creation.'
  },
  {
    id: 'place-of-creation-text',
    fieldname: 'Place of creation',
    predicate: 'vra:placeOfCreation',
    component: 'p-spatial-text',
    multilingual: true,
    multiplicable: true,
    label: 'Place of creation',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    language: '',
    definition: 'Place of creation.'
  },
  {
    id: 'place-of-repository-geonames',
    fieldname: 'Place of repository (Geonames)',
    predicate: 'vra:placeOfRepository',
    component: 'p-spatial-geonames',
    multiplicable: true,
    label: 'Place of repository',
    searchlabel: 'Wien, Großvenediger, Donau Kanal, ...',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    'rdfs:label': [],
    'skos:prefLabel': [],
    definition: 'Place of repository.'
  },
  {
    id: 'place-of-repository-text',
    fieldname: 'Place of repository',
    predicate: 'vra:placeOfRepository',
    component: 'p-spatial-text',
    multilingual: true,
    multiplicable: true,
    label: 'Place of repository',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    language: '',
    definition: 'Place of repository.'
  },
  {
    id: 'place-of-site-geonames',
    fieldname: 'Place of site (Geonames)',
    predicate: 'vra:placeOfSite',
    component: 'p-spatial-geonames',
    multiplicable: true,
    label: 'Place of site',
    searchlabel: 'Wien, Großvenediger, Donau Kanal, ...',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    'rdfs:label': [],
    'skos:prefLabel': [],
    definition: 'Place of site.'
  },
  {
    id: 'place-of-site-text',
    fieldname: 'Place of site',
    predicate: 'vra:placeOfSite',
    component: 'p-spatial-text',
    multilingual: true,
    multiplicable: true,
    label: 'Place of site',
    value: '',
    type: 'schema:Place',
    disabletype: false,
    language: '',
    definition: 'Place of site.'
  },
  {
    id: 'mime-type',
    fieldname: 'MIME type',
    predicate: 'ebucore:hasMimeType',
    component: 'p-select',
    vocabulary: 'mimetypes',
    label: 'MIME type',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The definition of the container if available as a MIME type.'
  },
  {
    id: 'license',
    fieldname: 'License',
    predicate: 'edm:rights',
    component: 'p-select',
    vocabulary: 'licenses',
    label: 'License',
    value: '',
    'skos:prefLabel': [],
    errorMessages: [],
    definition: 'The value will indicate the copyright, usage and access rights that apply to this digital representation.'
  },
  {
    id: 'rights',
    fieldname: 'Rights statement',
    predicate: 'dce:rights',
    component: 'p-text-field',
    multiline: true,
    multilingual: true,
    label: 'Rights statement',
    value: '',
    language: '',
    definition: 'Information about rights held in and over the resource. Typically, rights information includes a statement about various property rights associated with the resource, including intellectual property rights.'
  },
  {
    id: 'file',
    fieldname: 'File',
    predicate: 'ebucore:filename',
    component: 'p-file',
    label: 'File to upload',
    mimeLabel: 'File type',
    value: '',
    mimetype: '',
    autoMimetype: false,
    fileErrorMessages: [],
    mimetypeErrorMessages: [],
    definition: 'File input.'
  },
  {
    id: 'filename-readonly',
    fieldname: 'Filename readonly',
    predicate: 'ebucore:filename',
    component: 'p-filename-readonly',
    label: '',
    value: '',
    readonly: true,
    definition: 'Filename readonly.'
  },
  {
    id: 'filename',
    fieldname: 'Filename',
    predicate: 'ebucore:filename',
    component: 'p-filename',
    label: '',
    value: '',
    definition: 'Filename. Filename is also automatically provided when using the \'File\' field.'
  },
  {
    id: 'unknown',
    fieldname: 'Unknown (input)',
    predicate: '',
    component: 'p-unknown',
    label: '',
    jsonld: '',
    removable: true,
    readonly: true,
    definition: 'Used to show unsupported data on input.'
  },
  {
    id: 'display-unknown',
    fieldname: 'Unknown',
    predicate: '',
    component: 'p-unknown',
    label: '',
    jsonld: '',
    readonly: true,
    definition: 'Used to show unsupported data.'
  },
  {
    id: 'vocab-ext-readonly',
    fieldname: 'Vocabulary value readonly',
    predicate: 'dcterms:subject',
    type: 'skos:Concept',
    component: 'p-vocab-ext-readonly',
    label: '',
    'skos:prefLabel': [],
    'rdfs:label': [],
    value: '',
    readonly: true,
    definition: 'Vocabulary value readonly.'
  },
  {
    id: 'spatial-readonly',
    fieldname: 'Readonly spatial object',
    predicate: '',
    component: 'p-spatial-readonly',
    label: '',
    'skos:prefLabel': [],
    'rdfs:label': [],
    coordinates: [],
    value: '',
    readonly: true,
    definition: 'Readonly spatial object.'
  },
  {
    id: 'system-tag',
    fieldname: 'System tag',
    predicate: 'phaidra:systemTag',
    component: 'p-literal',
    label: 'System tag',
    value: '',
    definition: 'A tag for the purpose of identification or to give other information'
  }
]

const predicateOrder = [
  'rdam:P30004',

  'dcterms:type',
  'edm:hasType',
  'schema:genre',

  'dce:title',
  'role',
  'role-extended',
  'bf:note',
  'bf:tableOfContents',

  'dcterms:language',
  'schema:subtitleLanguage',
  'dce:subject',
  'dcterms:subject',

  'dcterms:date',
  'dcterms:created',
  'dcterms:modified',
  'dcterms:available',
  'dcterms:issued',
  'dcterms:valid',
  'dcterms:dateAccepted',
  'dcterms:dateCopyrighted',
  'dcterms:dateSubmitted',
  'rdau:P60071',
  'phaidra:dateAccessioned',
  'date',
  'dcterms:temporal',

  'ebucore:hasRelatedEvent',

  'oaire:version',
  'dcterms:accessRights',
  'edm:rights',
  'dce:rights',
  'dcterms:provenance',

  'dcterms:spatial',
  'vra:placeOfCreation',
  'vra:placeOfRepository',
  'vra:placeOfSite',

  'rdau:P60550',
  'schema:numberOfPages',
  'bf:soundCharacteristic',
  'bf:supplementaryContent',
  'bf:awards',
  'dcterms:audience',
  'rdau:P60059',

  'ebucore:filename',
  'ebucore:hasMimeType',

  'opaque:cco_accessionNumber',
  'bf:shelfMark',
  'bf:physicalLocation',

  'vra:hasInscription',
  'vra:material',
  'vra:hasTechnique',
  'dce:format',
  'rdau:P60048',
  'schema:width',
  'schema:height',
  'schema:depth',
  'vra:diameter',
  'schema:weight',
  'schema:duration',
  'bf:scale',

  'schema:pageStart',
  'schema:pageEnd',
  'rdau:P60193',
  'rdau:P60101',
  'bf:provisionActivity',
  'rdau:P60227',
  'bf:instanceOf',
  'frapo:hasFundingAgency',
  'frapo:isOutputOf',
  'rdax:P00009',
  'citation',
  'rdfs:seeAlso',

  'phaidra:systemTag'
]

export default {
  getFields: function () {
    let fieldsNew = []
    for (let f of fields) {
      switch (f.id) {
        case 'sociocultural-category':
        case 'physical-location-select-text-pool':
        case 'subject':
          break
        default:
          fieldsNew.push(f)
          break
      }
    }
    return fieldsNew
  },
  getEditableFields: function (locale) {
    var editable = fields.filter(item => !(item.readonly))
    // hack: some bug in vuetify autocomplete can't handle the value property
    var newarr = []
    for (var i = 0; i < editable.length; i++) {
      switch (editable[i].id) {
        case 'sociocultural-category':
        case 'physical-location-select-text-pool':
        case 'subject':
          break
        default:
          var field = JSON.parse(JSON.stringify(editable[i]))
          delete field['value']
          newarr.push(field)
          break
      }
    }
    return newarr
  },
  getField: function (id, ordergroup) {
    for (var i = 0; i < fields.length; i++) {
      if (fields[i]['id'] === id) {
        var field = JSON.parse(JSON.stringify(fields[i]))
        field.id = field.id + '_' + uuid.generate()
        field.ordergroup = ordergroup
        return field
      }
    }
  },
  getPredicateOrder: function () {
    return predicateOrder
  }
}