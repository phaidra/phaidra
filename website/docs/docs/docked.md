# Docked applications

Here are some examples for the so called "Docked applications". These are alternative frontends for PHAIDRA making use of PHAIDRA API and PHAIDRA Vue Components library.

## PHAIDRA IR

PHAIDRA IR (as for Institutional Repository) is a PHAIDRA frontend focused on upload of journal articles, working papers, monographs, conference papers and other scholarly materials. The platform supports both secondary and primary publication. It's main feature is curated ingest: an administrator can decide, whether a submit will be accepted into IR or not (in which case it is only accessible via PHAIDRA UI, but not PHAIDRA IR). In case the submit is accepted, the IR admin takes ownership of the object and can edit metadata and access rights. The submit enables import of metadata from a DOI agency and provides a possibility to check publication rights of the journals via Sherpa Romeo services.

Here is how a typical submit form and detail view in PHAIDRA IR look like

![](/assets/img/docs/ir_submit_view.png)

The DOI metadata import feature

![](/assets/img/docs/ir_doi_submit.png)

## Media library

The Media Library is focused on ingesting digitized movies (e.g. DVDs). The submit contains metadatafields relevant in this context and also enables an import from The Movie Database (TMDb).

Here is how a typical submit form and detail view in the Media Library look like

![](/assets/img/docs/theke_submit_view.png)

The TMDb metadata import feature

![](/assets/img/docs/theke_moviedb_import.png)

## Book Importer

The Book Importer was created to enable ingest of digital books. Digital books consist of a series of scans and a PDF file (containing all the images, for easier download). The user needs to create the structure of the book (i.e. organize scans/images into chapters) as well as bibliographic metadata. Upon ingest, the Book Importer creates the digital Book object in PHAIDRA as well as the IIIF-Manifest necessary for the viewer (currently Mirador). The Book Importer was created for robustness: it tries not to overload the repository and can recover from failed ingest in case it runs into network issues or timeouts.

Creating the Book structure:

![](/assets/img/docs/bookimporter_structure.png)

Defining bibliographic metadata (using PHAIDRA Vue Components library):

![](/assets/img/docs/bookimporter_metadata.png)

## In development

### Correspondence UI

A special frontend is being developed which is focused on digitized correspondence (composed of TEI files and scans). It also enables annotations.

![](/assets/img/docs/correspondence.png)

### PHAIDRA OER

The submit of Open Educational Resources will have a dedicated frontend soon.
