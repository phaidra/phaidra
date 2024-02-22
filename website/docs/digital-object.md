# Digital object

The fundamental building block of PHAIDRA repository is it's digital object model. Here's a simple conceptual diagram of it:

![](../pictures/digital_object.svg)

The object is composed of two parts: preservation metadata and datastreams.

## Preservation metadata

In preservation metadata, the repository holds information about object's basic properties and it's components (i.e. which datastreams it has).

The basic properties are

- created - The date at which object was created.
- createdBy - The Fedora Repository account which created the object.
- lastModified - The date at which the object was last modified.
- lastModifiedBy - The Fedora Repository account which modified the object.
- contains - Lists object's datastreams. See [Datastreams](#datastreams) for possible values.
- hasModel - The "content model" of the object. This value tells PHAIDRA how the object should be treated. See [Content models](#content-models) for possible values.
- ownerId - The PHAIDRA account, which created this object.
- state - The state should be Active or Inactive. See [Object states](#object-states) for possible values.

## Datastreams

Many types of datasteams have been used in PHAIDRA throughout it's history. Currently, the most important are:

- OCTETS - Holds the binary data of the object, if there are any. I.e. if the object is a Picture, then OCTETS is the JPEG file (or TIFF, or any other file type allowed by the repository, see [Content models](#content-models) for typical values). If the object is a Collection however, there will be no OCTETS datastream, since Collection does not contain binary data of it's own, only relationships to other objects. Access restriction apply to this datastream.

- JSON-LD - This is where currently bibliographic metadata are stored. It is an RDF based metadata format saved as JSON.

- JSON-LD-PRIVATE - Here bibliographic metadata can be stored which are only visible to the owner of the object.

- RIGHTS - Holds information about access restriction which are used for authorization. It is in XML format and contains the restriction definition (username, org unit or group) with an optional expiry date. If the object has no access restrictions, there will be either no RIGHTS datastream, or it will not contain any restrictions. This datastream is only visible to the owner of the object.

- WEBVERSION - If the original binary data are not well suited for web, the WEBVERSION can contain a format which is less problematic. I.e. if the original PDF is too big for the PDF viewer because the images have a high dpi, one can upload a smaller version by reducing the dpi of the pictures. Access restriction apply to this datastream.

- COLLECTIONORDER - Collection and Container are content models which define relations to other objects ("members"). By default, these are not ordered, unless the order is defined in the COLLECTIONORDER datastream. It is basically a list of PIDs with a position in XML format.

- LINK - In case of the Resource object, LINK contains the link to the external resource.

- IIIF-MANIFEST - Contains the <a target="_blank" href="https://iiif.io/">IIIF manifest</a> used for book viewer. The IIIF manifest normally contains an excerpt of the bibliographic metadata, which gets automatically updated if metadata are edited.

- FULLTEXT - Can contain the fulltext extracted from the object. Access restriction apply to this datastream.

- ANNOTATIONS - If Pictures are annotated, the annotations are saved here. An annotation consits of the bounding box coordinates (x,y,w,h), title, category and text (the implementation follows the annotation feature of <a target="_blank" href="https://github.com/guglielmo/iipmooviewer">iipmooviewer</a>).

- ? - One can also save a custom datastream (i.e. MY-MIGRATION-DATA) and retrieve it back from API. Access restriction apply to custom datastreams.

There are other datastreams in some PHAIDRA instances still in use, i.e.

- UWMETADATA - A LOM based XML metadata schema used for bibliographic metadata on older objects.

- MODS - PHAIDRA has a rudimentary support for MODS schema, which was used when objects were ingested from external systems (i.e. Goobi). In that case, the MODS datastream contains the MODS XML.

- THUMBNAIL, STYLESHEET, DC, DC_P, GEO... - many datastream have been used for various purposes in PHAIDRA which are no more part of the current application logic.

## Content models

Here are the current content models. The allowed types can vary on PHAIDRA instances as institution may follow different needs when archiving digital assets. The best practice is to restrict the allowed file types to formats which make long term preservation possible (i.e. are typically open, contain no patents, are well documented, etc).

- Picture - Examples: image/tiff, image/jpeg, image/gif, image/png

- Video - Examples: video/mpeg, video/avi, video/x-msvideo, video/mp4, video/quicktime, video/x-matroska

- Audio - Examples: audio/x-wav, audio/wav, audio/mpeg, audio/flac, audio/ogg, audio/x-aiff, audio/aiff

- PDFDocument - Exampes: application/pdf, application/x-pdf

- Asset - Anything that contains binary data and does not fit into the content models listed above can be saved as an Asset.

- Resource - This content model can be currently only created via API. The resource content model basically represents an object which is only a link outside of the repository. This way, content outside of the repository can be incorporated into repository's logical structure, assigned metadata and an persistent identifier. It is only advisable to use links which are persistent or maintained (i.e. pointing to own infrastructure).

- Collection - Object containing metadata and links to other objects, hence representing a persistent link to a list of objects. The objects are loosely coupled and the owner of the collection does not need to be the owner of collection's members.

- Container - Object containing metadata and links to other objects, which represent one contextual unit. I.e. a digitized audio tape can contain and Audio object, the Picture of the cassette, and the PDFDocument with a transcript. The members of the Container are not visible in the search and are typically not disseminated, only the Container is, as the metadata of the Container can be understood as superordinate metadata, and the members should not be viewed outside of this context.

- Website - Work in progress - This content model should represent website archives (saved as wacz files).

## Object states

An object can be in states:

- Active - the object is normally accessible, is indexed, and can be disseminated.

- Inactive - the object can only be accessed by the owner, is not indexed and is usually not part of any workflows.

- Deleted - historically, Fedora Repository used this state to mark an object for purge. It is not used in instances based on Fedora Repository in version 6+.