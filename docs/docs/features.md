## Main Usecase

PHAIDRA's two main aspects are:

- **1. Publication**
- **2. Archiving**

PHAIDRA is best suited for situations where the goal is the combination of open access and long term preservation. For instance, it is only possible to restrict access to data, but not metadata, and although it is possible to edit data after ingestion, it is not the intended workflow.

## Features

To introduce some core features and properties of a typical PHAIDRA instance, we will categorize them according to the [OAIS model](https://en.wikipedia.org/wiki/Open_Archival_Information_System):

### Ingest

PHAIDRA can currently use 3 metadata schemas:

- JSON-LD - an RDF based, Linked-Data conform format combining many open metadata standards, like [Dublin Core](https://www.dublincore.org/specifications/dublin-core/usageguide/elements/), [BIBFRAME](https://www.loc.gov/bibframe/), [Schema.org](https://schema.org/), [EBUCore](https://tech.ebu.ch/metadata/ebucore), etc. (a [SHACL](https://www.w3.org/TR/shacl/) shape) and making use of persistent identifiers and controlled vocabularies.

- A [LOM](https://en.wikipedia.org/wiki/Learning_object_metadata) based UWMETADATA format

- there is a rudimentary support for [MODS](https://www.loc.gov/standards/mods/)

If data should be treated according to their media category (Picture, Video, Audio, PDFDocument, Book and soon Website), only specific, long term preservation suitable file formats are allowed. Other file formats can be ingested as well, but will be treated as binary data.

### Data management

- there are more than 50 metadata fields which can be organized in layers (digital object metadata vs metadata of represented object)

- there are simple (i.e. Video) as well as compound object types (i.e. Container, Book)

- multiple relations can be used, i.e. to create Collections (to organize objects hierarchically or in sets), connect various object versions or formats, etc

### Archival storage

PHAIDRA leverages the [Fedora repository](https://fedora.lyrasis.org/) (version 3.8 and 6+) for the archival storage. Both data and metadata are stored and versioned on the file system, as self-contained as possible, in a standardized layout ([OCFL](https://ocfl.io/) in case of Fedora 6+)

### Access

PHAIDRA objects can be access in multiple ways:

- UI & SEO: Typically, PHAIDRA objects are submitted and managed via it's Nuxt based (server-side rendered) frontend where each object has a detail page including meta headers. A sitemap including all detail pages is rendered automatically.

- Harvesting: the API contains an OAI-PMH endpoint which is used by harvesters like 
[OpenAIRE](https://www.openaire.eu/), [Europeana](https://www.europeana.eu/), [BASE](https://www.base-search.net/), [OAPEN](https://www.oapen.org/), [EBSCO](https://www.ebsco.com/) or [Primo](https://exlibrisgroup.com/products/primo-discovery-service/). Currently, [oai_dc](https://oai-openedition.readthedocs.io/en/latest/oai_dc.html) and [oai_openaire](https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/latest/use_of_oai_pmh.html) formats are available. The dcterms format will be added in the future.

- Integrations: PHAIDRA API provides all methods for manipulating the digital objects necessary for implementing a custom integration or a specialized frontend (multiple frontends have been developed for PHAIDRA, see [Docked Applications](#docked-applications)) including a search endpoint based on [Solr](https://solr.apache.org/).

### Reuse

- all objects containing data need to provide a licence ([CC](https://creativecommons.org/), [PDM](https://creativecommons.org/public-domain/pdm/), etc) or an explicit copyright statement (All rights reserved).

- all objects have a persistent identifier which can be used for citation. Additional identifier schemes can be integrated ([DOI](https://www.doi.org/the-identifier/what-is-a-doi/), [Handle](https://www.handle.net/), etc).

### Presentation

- An [IIIF imageserver](https://iiif.io/) is integrated for displaying Pictures ([iipmooviewer](https://github.com/guglielmo/iipmooviewer)) and Books ([Mirador](https://projectmirador.org/)).

- Videos can be viewed via html 5 video tag or a streaming server can be integrated (i.e. [OpenCast](https://opencast.org/). The streaming server is not part of PHAIDRA.)

- Audios can be played via html 5 audio tag.

- PDF documents are displayed on detail page using [PDF.js](https://mozilla.github.io/pdf.js/) viewer.

- For 3D objects, [3DHOP](https://3dhop.net/) viewer was integrated

- Websites ([WACSZ](https://en.wikipedia.org/wiki/WACZ)) can be displayed via [replay.web](https://replayweb.page/) viewer.
