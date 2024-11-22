# upcoming

## phaidra-api

  + possibility to make templates public
  + it can be configured that username scope (shib) will be removed
  + IIIF manifests are now generated automatically for pictures
  + fixed EDM mapping for object types

## phaidra-ui

  + fix book redirect

## docker

  + api log is now going to stdout
  + fixed loki config

# v3.3.14

## phaidra-api

  + fixed aaiso to aiiso
  + now considering lastModifiedDate of datastreams when indexing sinde lastModifiedDate of object does not change on datastream edit in f6
  + fixed oai config
  + fix handling SPL terms in uwmetadata
  + sending 200 and html redirect instead of 302 in shibboleth login so that the strict token cookie is sent

## phaidra-ui

  + fixed aaiso to aiiso
  + fixed access:open facet
  + allow abstract to be validated as description
  + allow field configuration in template
  + fixed facetQueries config
  + disable markdown for now
  + fix rights config in submit form

# v3.3.12

## phaidra-api

  + added nocache for config requests, to avoid fetching cached value in admin

## phaidra-ui

  + dashboard component facetqueries fix
  + added date of approbation field

# v3.3.11

## phaidra-api

  + logStorageSize.pl script can be used to do daily storage stats (of it makes sense on the particular storage)
  + scheme is now corrdctly added to PID when generating DC
  + caching public/private config (helps a bit even if workers are spawned by Apache and don't share cache)
  + fixed request DOI config
  + fixed group owner when using shibboleth
  + adding more data to session and passing more upstream auth headers (this is only needed in Fedora 3 instances)
  + other small fixes

## phaidra-ui

  + cookie and local storage handling
  + disabling emphasis in markdown for now because it conflict's with German gender-neutral text
  + alternative display of project metadata
  + role validation fix
  + fixed accessibility vocabularies
  + other small fixes

## chronos

  + fixed updateOai script and removed some files which are not needed

## docker

  + fixed default value syntax for PHAIDRA_HOSTPORT

# v3.3.10

## phaidra-api

  + fix missing uwmetadata roles
  + a little script to figure out OCFL dir path for a pid was added

## phaidra-ui

  + dashboard component title pre-wrap class

# v3.3.9

## phaidra-ui

  + fix missing dashboard component change

# v3.3.8

## phaidra-api

  + fix missing assessor role

## phaidra-ui

  + new form validation variant: validationWithoutKeywords
  + fix selecting defailt template
  + fix some role labels
  + fix object type field label not being translated
  + fix marking mandatory fields

# v3.3.7

## phaidra-ui

  + small improvements in dashboard components

# v3.3.6

## phaidra-ui

  + fix linking IDs which are not URLs
  + fix cc-by-nc facet
  + fix dashboard component 

# v3.3.5

## phaidra-api

  + use ldapgroups and ou/departmentnumber for autz
  + fix affiliation resolve in uwmetadata
  + fix for migrated external content links

## phaidra-ui

  + fix access search facet

## solr

  + fix some missing schema fields
  
# v3.3.4

## phaidra-ui

  + Facetqueries and Latestpreview components were added for more homepage customization possibilities
  + facetQueries base structure can now be overridden via config

## phaidra-api

  + eduPersonAffiliation was changed (back) to affiliation for backwards compatibility 

# v3.3.3

## phaidra-api

  + minor fixes in directory class

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
