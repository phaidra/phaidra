# What is PHAIDRA?

<a target="_blank" href="https://phaidra.org/">PHAIDRA</a> (an acronym for Permanent Hosting, Archiving and Indexing of Digital Resources and Assets) is an open source digital object repository, actively developed at the <a target="_blank" href="https://univie.ac.at/">University of Vienna</a> since 2007 and adopted by a number universities and organisations internationally.

PHAIDRA is an extension of <a target="_blank" href="https://fedora.lyrasis.org/">Fedora repository</a> (or Fedora Commons, or fcrepo, Fedora is itself an acronym for Flexible Extensible Digital Object Repository Architecture) and offers a comprehensive software bundle required to manage digital content from authentication and submit to preservation and dissemination. It's two main aspects are:

- publication

and

- archiving

PHAIDRA is best suited for situations where the goal is the combination of open access and long term preservation. For instance, it is only possible to restrict access to data, but not metadata, and although it is possible to edit data after ingestion, it is not the intended workflow.

# Features

To introduce some core features and properties of a typical PHAIDRA instance, we will categorize them according to the <a target="_blank" href="https://en.wikipedia.org/wiki/Open_Archival_Information_System">OAIS model</a>:

## Ingest

PHAIDRA can currently use 3 metadata "standards":

- JSON-LD - an RDF based, Linked-Data conform format combining many open metadata standards, like <a target="_blank" href="https://www.dublincore.org/specifications/dublin-core/usageguide/elements/">Dublin Core</a>, <a target="_blank" href="https://www.loc.gov/bibframe/">BIBFRAME</a>, <a target="_blank" href="https://schema.org/">Schema.org</a>, <a target="_blank" href="https://tech.ebu.ch/metadata/ebucore">EBUCore</a>, etc. (a <a target="_blank" href="https://www.w3.org/TR/shacl/">SHACL</a> shape) and making use of persistemt identifiers and controlled vocabularies.

- A <a target="_blank" href="https://en.wikipedia.org/wiki/Learning_object_metadata">LOM</a> based UWMETADATA format

- there is a rudimentary support for <a target="_blank" href="https://www.loc.gov/standards/mods/">MODS</a>

If data should be treated according to their media category (Picture, Video, Audio, PDFDocument, Book and soon Website), only specific, long term preservation suitable file formats are allowed. Other file formats can be ingested as well, but will be treated as binary data.

## Data management

- there are more than 50 metadata fields which can be organized in layers (digital object metadata vs metadata of represented object)

- there are simple (i.e. Video) as well as compound object types (i.e. Container, Book)

- multiple relations can be used, i.e. to create Collections (to organize objects hierarchically or in sets), connect various object versions or formats, etc

## Archival storage

PHAIDRA leverages the <a target="_blank" href="https://fedora.lyrasis.org/">Fedora Repository</a> (version 3.8 and 6+) for the archival storage. Both data and metadata are stored and versioned on the file system, as self-contained as possible, in a standardized layout (<a target="_blank" href="https://ocfl.io/">OCFL</a> in case of Fedora 6+)

## Access

PHAIDRA objects can be access in multiple ways:

- UI & SEO: Typically, PHAIDRA objects are submitted and managed via it's Nuxt based (server-side rendered) frontend where each object has a detail page including meta headers. A sitemap including all detail pages is rendered automatically.

- Harvesting: the API contains an OAI-PMH endpoint which is used by harvesters like <a target="_blank" href="https://www.openaire.eu/">OpenAIRE</a>, <a target="_blank" href="https://www.europeana.eu/">Europeana</a>, <a target="_blank" href="https://www.base-search.net/">BASE</a>, <a target="_blank" href="https://www.oapen.org/">OAPEN</a>, <a target="_blank" href="https://www.ebsco.com/">EBSCO</a> or <a target="_blank" href="https://exlibrisgroup.com/products/primo-discovery-service/">Primo</a>. Currently, <a target="_blank" href="https://oai-openedition.readthedocs.io/en/latest/oai_dc.html">oai_dc</a> and <a target="_blank" href="https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/latest/use_of_oai_pmh.html">oai_openaire</a>formats are available. The dcterms format will be added soon.

- Integrations: PHAIDRA API provides all methods for manipulating the digital objects necessary for implementing a custom integration or a specialized frontend (multiple frontends have been developed for PHAIDRA, see [Docked Applications](#docked-applications)) including a search endpoint based on <a target="_blank" href="https://solr.apache.org/">Solr</a>.

### Reuse

- all objects containing data need to provide a licence (<a target="_blank" href="https://creativecommons.org/">CC</a>, <a target="_blank" href="https://creativecommons.org/public-domain/pdm/">PDM</a>, etc) or an explicit copyright statement (All rights reserved).

- all objects have a persistent identifier which can be used for citation. Additional identifier schemes can be integrated (<a target="_blank" href="https://www.doi.org/the-identifier/what-is-a-doi/">DOI</a>, <a target="_blank" href="https://www.handle.net/">Handle</a>, etc).

### Presentation

- An <a target="_blank" href="https://iiif.io/">IIIF imageserver</a> is integrated for displaying Pictures (<a target="_blank" href="https://github.com/guglielmo/iipmooviewer">iipmooviewer</a>) and Books (<a target="_blank" href="https://projectmirador.org/">Mirador</a>).

- Videos can be viewed via html 5 video tag or a streaming server can be integrated (i.e. <a target="_blank" href="https://opencast.org/">OpenCast</a>. The streaming server is not part of PHAIDRA.)

- Audios can be played via html 5 audio tag.

- PDF documents are displayed on detail page using <a target="_blank" href="https://mozilla.github.io/pdf.js/">PDF.js</a> viewer.

- For 3D objects, <a target="_blank" href="https://3dhop.net/">3DHOP</a> viewer was integrated

- Websites (<a target="_blank" href="https://en.wikipedia.org/wiki/WACZ">WACZ</a>) can be displayed via <a target="_blank" href="https://replayweb.page/">replay.web</a> viewer.
