# v3.3.1

## phaidra-api

  + changing eduPersonAffiliation to affiliation in RIGHTS because it was already used this way
  + fixes in methods dealing with org units
  + the session cookie is now httpOnly
  + layout changes in replayweb template

## phaidra-ui

  + fixed display of "published date" in UWMETADATA
  + fix publication field label
  + using local storage for session token in case we're running on localhost to prevent logout on reload
  + fix config for request DOI button
  + adding convenient import/export to admin config

# v3.3.0

## phaidra-api

  + the OAI-PMH endpoint now supports EDM and LOM (as per https://oer-repo.uibk.ac.at/lom/latest/ v2024-07-21) metadata formats
  + bulk methods for object modify and delete were added
  + public/private config methods
  + possibility to use eduPersonAffiliation for authz
  + delete can now be disabled via private config (as it was possible via policies in fedora 3.x)

## phaidra-ui

  + improved components for selecting metadata field language
  + markdown can be used in description, provenience and table of contens fields (no images or html allowed)
  + metadata fields for accessibility were added
  + possibility to show "Request DOI" button if object does not have a DOI; sends email to a specified request-doi-email address
  + submit for open educational resources was added
  + educational resource and open educational resource are now search facets
  + signposting via html link elements is now integrated to detail view
  + roles now show definitions in select box
  + the download file name can now be changed via filename metadata field
  + GND and Geonames search now has a backend proxy to avoid CORS issues (..so it works in firefox too)
  + fix: license facet now works correctly
  + fix: identifiers in is-contained-in field are now saved correctly
  + project field now supports additional identifier
  + a date can now also be freetext (edm:TimeSpan) - can only be saved via API
  + fix: validation now does not throw error on uploading a new version of an object
  + publisher ID is now linked
  + project homepage is now linked
  + open in new window button is now more prominent
  + 'see also' and 'references' fields now support a search in YARM
  + 'see also' and 'references' and cito fields are now listed together under 'bibliography' on view
  + on metadata edit the read-only and input field pairs are now visually separated from other fields
  + book pid now redirects to book only if it's not restricted
  + the webversion upload components was disabled (confusing for users)
  + there is a content model icon in search results
  + object typed Website and 3D-model were added
  + fix: correct layout padding and navigation menu on mobile
  + rights definition is now saved with templates
  + eduPersonAffiliation can be selected as access restriction
  + i18n messages/labels can be overriden via admin config
  + parts of access restriction component can be disabled via admin config
  + easy 'restrict to owner/me' button in access restrictions
  + admin account can now delete objects (if deleting is allowed in admin config; admin can always delete) and replace data (create new versions of OCTETS)

# v3.2.0
  + move to docker profiles.
  + profiles make use of images including all code now (using commit tags), only *-dev profiles use code mounted from repo.
  + initial S3 support with caching for imageserver images.

# v3.1.0
  + last release that makes use of compose_* directories in repo, we are moving towards docker profiles.
  + various stability enhancements
  + preparation for k8s

# phaidra-3.0.0

  + phaidra-ui: added possibility to customize submit form via default template
  + phaidra-ui: UI config can now be changed in admin and read from database
  + phaidra-ui: instance UI config can now be read from database
  + phaidra-vue-components: added possibility to change field properties in templates
  + phaidra-vue-components: volume and issue fields can now be used in top level metadata
  + phaidra-vue-components: levelofdescription field has beed added to differentiate between digitized and represented objects
  + vige/phaidra-api: Opencast integration
  + phaidra-api: all imageserver requests should now be properly authorized
  + phaidra-api: updated OEFOS
  + minor fixes

# phaidra-pre3
  + formal community enhancements.

# fcrepo-6.4.1-with-integrity-checks
  + now makes full use of fedora's fixity feature. By default, sha512sum checks on all repository files are performed every 2nd a month.
