## Main Usecase

PHAIDRA's two main aspects are:

- **1. Publication**
- **2. Archiving**

PHAIDRA is best suited for situations where the goal is the combination of open access and long term preservation. For instance, it is only possible to restrict access to data, but not metadata, and although it is possible to edit data after ingestion, it is not the intended workflow.

## Features

To introduce some core features and properties of a typical PHAIDRA instance, we will categorize them according to the OAIS model:

### Ingest

PHAIDRA can currently use 3 metadata schemas:

- JSON-LD - an RDF based, Linked-Data conform format combining many open metadata standards, like Dublin Core, BIBFRAME, Schema.org, EBUCore, etc. (a SHACL shape) and making use of persistent identifiers and controlled vocabularies.

- A LOM based UWMETADATA format

- there is a rudimentary support for MODS

If data should be treated according to their media category (Picture, Video, Audio, PDFDocument, Book and soon Website), only specific, long term preservation suitable file formats are allowed. Other file formats can be ingested as well, but will be treated as binary data.

### Data management

- there are more than 50 metadata fields which can be organized in layers (digital object metadata vs metadata of represented object)

- there are simple (i.e. Video) as well as compound object types (i.e. Container, Book)

- multiple relations can be used, i.e. to create Collections (to organize objects hierarchically or in sets), connect various object versions or formats, etc

### Archival storage

PHAIDRA leverages the Fedora repository (version 3.8 and 6+) for the archival storage. Both data and metadata are stored and versioned on the file system, as self-contained as possible, in a standardized layout (OCFL in case of Fedora 6+)

### Access

PHAIDRA objects can be access in multiple ways:

- UI & SEO: Typically, PHAIDRA objects are submitted and managed via it's Nuxt based (server-side rendered) frontend where each object has a detail page including meta headers. A sitemap including all detail pages is rendered automatically.

- Harvesting: the API contains an OAI-PMH endpoint which is used by harvesters like OpenAIRE, Europeana, BASE, OAPEN, EBSCO or Primo. Currently, oai_dc and oai_openaire formats are available. The dcterms format will be added soon.

- Integrations: PHAIDRA API provides all methods for manipulating the digital objects necessary for implementing a custom integration or a specialized frontend (multiple frontends have been developed for PHAIDRA, see [Docked Applications](#docked-applications)) including a search endpoint based on Solr.

### Reuse

- all objects containing data need to provide a licence (CC, PDM, etc) or an explicit copyright statement (All rights reserved).

- all objects have a persistent identifier which can be used for citation. Additional identifier schemes can be integrated (DOI, Handle, etc).

### Presentation

- An IIIF imageserver is integrated for displaying Pictures (iipmooviewer) and Books (Mirador).

- Videos can be viewed via html 5 video tag or a streaming server can be integrated (i.e. OpenCast. The streaming server is not part of PHAIDRA.)

- Audios can be played via html 5 audio tag.

- PDF documents are displayed on detail page using PDF.js viewer.

- For 3D objects, 3DHOP viewer was integrated

- Websites (wacz) can be displayed via replay.web viewer.
