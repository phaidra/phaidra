# Head

## Upgrade

### Renaming volumes

Some volumes have been renamed, here's how you can migrate to the new structure:

NOTICE: If you have a lot of data in some volume (probably pixelgecko), you can remove it from migration script and instead do eg `docker volume create phaidra_derivates-images` and then mv the files manually if both volumes are on the same storage.

* compose down

* pull to get newest version

* copy volumes
```
./scripts/migrations/v3.4.0/01_migrate_volumes.sh
```

* compose up

* change agent names in jobs
```
docker exec -it phaidra-api-1 perl migrations/v3.4.0/01_rename_mongodb_agents.pl
```

* check if everything is fine

* remove old volumes
```
docker volume rm phaidra_mariadb_fedora
docker volume rm phaidra_mariadb_phaidra
docker volume rm phaidra_mongodb_phaidra
docker volume rm phaidra_converted_3d
docker volume rm phaidra_converted_360
docker volume rm phaidra_pdf-extraction
docker volume rm phaidra_vige-mongosh
docker volume rm phaidra_vige
docker volume rm phaidra_pixelgecko
```

### Usage stats update

In an ongoing effort to optimize usage stats, we have changes some tables and a migration is necessary.

Execute the migration scripts as follows:

```
docker exec -it phaidra-api-1 perl migrations/v3.4.0/02_create_new_usage_stats_tables.pl
docker exec -it phaidra-api-1 perl migrations/v3.4.0/03_load_ip2country_to_db.pl
docker exec -it phaidra-api-1 perl migrations/v3.4.0/04_migrate_usage_stats_to_usage_log.pl
```

### OAI collection index

An additional index is necessary to avoid disk usage for sort in mongodb, execute:

```
docker exec -it phaidra-api-1 perl migrations/v3.4.0/05_add_oai_records_index.pl
```

### Updating solr schema

We had to change the way we use copy fields in solr schema. You need to execute the following script to add new definitions to schema (change SOLR_URL and AUTH accordingly):

```
docker exec -it phaidra-api-1 perl migrations/v3.4.0/06_add_solr_copyfields.pl
```

# v3.3.17

Here are the key highlights from the fixes and enhancements since the last release:

## Product-wide Improvements
- Accessibility: Broad WCAG fixes across navigation, filters, headings/landmarks, focus order, contrast, labels, keyboard operability, media alternatives, and zoom responsiveness (#154–#225, #197–#205, #208–#224).
- Internationalization: Translatable labels/messages, UTF‑8 in LDAP and filenames, localized date pickers, improved locale handling and `html lang` attribute (#6, #52, #55–#57, #60–#61, #66, #81, #83, #101, #123, #145, #270, #297).
- UI/UX & Navigation: Breadcrumb and toolbar fixes, “Preview” button, dark theme, cancelable dialogs, clearer feedback/errors, better sorting/empty states, go-back after login, cookie banner (#10, #40, #42, #84–#88, #130, #136–#141, #147, #258, #261, #271, #286, #378).
- Performance & Stability: Solr/Mongo indexing and migrations, facet count fixes, caching user attributes, compact Fedora relationship updates (#33, #70, #247, #267, #342, #309, #268).

## Metadata, Search, and Interoperability
- Metadata Editor & Validation: Numerous legacy/uwmetadata fixes, multiplicable fields, preserve essential sections, clearer labels, role ordering, EDTF support (incl. “%” qualifier), checksum on upload, funder name, temporal coverage, ROR affiliations, identifiers (#17, #63–#69, #73, #76, #79, #82, #87, #91–#93, #95–#106, #181, #189, #221, #232, #235, #242, #244, #245, #352, #387, #393–#395).
- Search & Indexing: Language indexing, identifier searchability, affiliation indexing, richer role display, facet deselection fixes (#33, #143, #239, #245, #247, #283, #405).
- OAI-PMH/Exports: DataCite export fix, added EDM/LOM, stylesheet support, DC mappings, correct field deletion on update (#29, #71, #182, #211, #279).
- IIIF/Book Viewer: Mirador localization, consistent IIIF Presentation versions, book preview on detail page, book PDFs included in full-text search (#270, #334, #364, #375).
- New Integrations: DOI import, updated ROR handling, collection RSS feeds, Google verification/analytics placement (#337, #190, #292, #380, #404).

## Files, Viewers, and Media
- New Formats/Viewers: 3D OBJ with three.js (#114); Video.js for non‑streaming videos (#369).
- Derivatives & Downloads: Delete derivatives with objects; restrict downloads where required (#93, #281).
- Image/PDF Handling: Color profile conversion, PDF opening fix, more robust Tika extraction, clearer processing status (#72, #124, #353, #354).

## Bulk Upload and Templates
- Bulk Upload Overhaul: Multilingual support, robust CSV handling (newlines/quotes), correct field mapping, UI stability, breadcrumbs, disabled inputs when appropriate, language applied to core fields (#264, #284–#289, #344–#346, #351).
- Templates & CMS: Templates management/enhancements, collection presentation pages, Admin CMS additions (Contact/Ethics/Editorial Policies, File formats), safer runtime templates (#126, #136–#138, #291, #293, #349, #350, #363).

## Admin, Platform, and Ops
- Integrity & Services: Fixity service (Camel toolbox); SMTP requirement note (#110, #358).
- Object Lifecycle: Tombstones for deletes, latest-version redirect (#131, #373).
- Security & Access: Close authenticated routes, global HTTP headers, fetch/cache external attributes, SCIM org attribute propagation, cookie domain to API, option to hide uploader in UI (#371, #384, #302, #308–#309, #315, #366).
- Monitoring & Stats: Storage use statistics, cron fixes, Prometheus auth, usage stats UI help, repository totals on home page (#338, #257, #333, #256, #347).
- Ecosystem & Previews: PHAIDRA‑IR support, favicon on API previews, “generator” meta tag (#339, #275, #331).

## Notable Quick Wins
- UTF‑8 filenames and better uploader encoding (#52, #122).
- Identifier/UI links and DOI/PI display improvements (#83–#85, #104, #150, #248, #303).
- Better redirects and URL handling (#266, #271, #301).
- Quality-of-life: Autolinker, file size on download button, default identifier labels, resource type icons (#125, #248, #254, #185).

Overall, this release strengthens accessibility and internationalization, stabilizes search/indexing and metadata workflows, introduces 3D and DOI import support, improves IIIF/Book experiences, modernizes bulk upload and templates, and adds admin/ops tooling for a more reliable, configurable platform.

## Full list of closed issues

#1	MIT License  
#6	Local LDAP account names UTF-8 support missing  
#8	Unclicking facet filter seems to brake facet counts  
#10	Add "Preview" button next to upload?  
#13	Link thumbnails in collection members list  
#14	Improve account search  
#17	Object type Book should have editor role ordered before author  
#24	Allow adding users to group without directory search  
#25	Restricted container member audio preview shows error  
#26	Improve display of accessibility fields  
#29	DataCite export broken  
#30	Data upload validation bug  
#31	Linguistic adjustments UI  
#32	Make pagestart/end visible by default in Is-in-series field  
#33	Index identifiers without prefix for easier search  
#40	Hide the sort links when collection is empty  
#42	Dashboard: fix the "More" link  
#45	Legacy metadata: Dimensions field not displayed after saving metadata  
#46	Phaidra management links in the Admin panel  
#47	Favicon management  
#49	Show informative feedback message on non-existent pages  
#51	Use JSON instead of js for i18n locale files.  
#52	UTF-8 filenames  
#53	Some labels are not translatable  
#55	Make Load Button label translatable  
#56	Alert messages translatable  
#57	Object rights date picker i18n  
#58	Fix role:<role> in json-ld @context  
#60	Submit form: "All rights reserved" licence description  
#61	Metadata field labels not translatable in metadata editor  
#62	Thumbnail rights  
#63	Submit form: do not allow removal of General Metadata section  
#64	Legacy metadata: Faculty field in Association section is duplicable  
#65	Make identifier field (in bibliographic metadata) in submit multiplicable  
#66	Breadcrumb labels not fully translatable  
#67	Link to object detail in object list items table not working  
#68	Remove "Physical Location (Select)" metadata field from "add metadata field" list  
#69	Unable to deselect the language on language-independent metadata fields  
#70	Add indexes to oai_records collection in in mongodb-after-entry.sh  
#71	Add edm and lom to ListMetadataFormats oai-pmh response  
#72	Pictures without color profile won't get converted  
#73	Add  schema:birthDate and schema:deathDate to role metadata  
#74	Add object lists search to Manage Object Lists page  
#75	Add table header to Manage Object Lists and Manage User Groups pages  
#76	Add legacy metadata vocabulary terms to database and regenerate Uwmetadata XSD  
#78	"Enable groups" instance config option seems ignored  
#79	Remove Alert field from "Add metadata field" list  
#80	Use user search component also in access rights management  
#81	Labels of selected fields in "Add metadata fields" list are not translated  
#82	Remove "Note (checkbox)" and "Note (checkbox with link)" from "Add metadata fields" list  
#83	"Persistent identifier" label not translatable on object detail page  
#84	Add support for UI dark theme  
#85	Add Cancel button to language selection dialog  
#87	Legacy metadata editor: hide skos:notation value in Organization Association dropdown  
#88	Meta tags download link broken  
#90	Citation styles list request seems broken  
#91	Legacy metadata: removing classification path value in metadata editor throws API error  
#92	Legacy metadata: object detail page displays empty provenience fields  
#93	When deleting an object, derivatives should be deleted too.  
#95	API call directory/get_org_units always returns the English label  
#96	Licence field is editable after object upload  
#97	Add Public Domain Mark to selectable licences  
#98	Resource type is removable in Edit Metadata form  
#100	"Is contained in" metadata field not removable  
#101	Phaidra Vue Components I18N seems overwriting or not using Phaidra UI I18N translations  
#103	Undefined subject classification term labels in JSON-LD metadata  
#104	BIC subject term link on object detail page  
#105	Adding Temporal Coverage metadata throws validation error  
#106	Accessibility issues  
#107	Add config option to admin panel to enable/disable the Feedback feature in the UI  
#110	Fixity service (based on F6 fixity service + Camel)  
#114	Support for 3D obj format and three.js viewer  
#120	Legacy metadata: missing classification labels  
#122	Encoding problems in uploader Details Box  
#123	Date Picker i18n  
#124	Opening PDF broken  
#125	Use autolinker again  
#126	Templates management  
#129	Bibo:issue on top level shows no value  
#130	Groups and Help pages miss breadcrumb label  
#131	Make <pid>/latest redirect to the latest version of the object  
#132	Legacy metadata: sort vocabulary term lists in metadata editor  
#136	Manage templates page enhancement  
#137	Templates tab in Submit shows created date as Unix timestamp  
#138	Add header to table in Submit > Import tab  
#139	Missing breadcrumb on Login, Admin, Terms of Use, and Credits pages  
#140	Add link to Repository Statistics page in the Admin panel  
#141	add displayname for ldap, using description. This help for organization accounts that don't have given and last name  
#142	Resource type on object detail page  
#143	Language isn't indexed to solr  
#145	Error messages translatable  
#146	Show members in search ignores sort  
#147	Custom CSS should come after Vuetify CSS  
#150	Show OpenCast ID on detail page  
#152	On uwmetadata objects the metadata won't be fully displayed on mobile  
#154	Accessibility issue - Home page - Linked logo lacks correct alternative text - #15  
#155	Accessibility issue - Home page - Decorative picture not hidden #33  
#156	Accessibility issue - Home page - Redundancy in card elements #36  
#157	Accessibility issue - Home page - Main landmark missing #8  
#158	Accessibility issue - Home page - H1 missing  #10  
#159	Accessibility issue - Home page - Embed all content in Landmarks #11  
#160	Accessibility issue - Home page - Contents of the mobile menu not in the correct order #48  
#161	Accessibility issue - Home page - Links must be distinguishable #7  
#162	Accessibility issue - Home page - Left with button style low-contrast #3  
#163	Accessibility issue - Home page - "New" low-contrast #35  
#164	Accessibility issue - Home page - Font graphics require an equivalent alternative text #37  
#165	Accessibility issue - Home page - Texts cut off or overlapping #16  
#166	Accessibility issue - Home page - Logo not in focus order #14  
#167	Accessibility issue - Home page - Quicklinks button not accessible #16  
#168	Accessibility issue - Home page - Missing skip link #28  
#169	Accessibility issue - Home page - Empty area is focussed #13  
#170	Accessibility issue - Home page - Social media links without an accessible name #38  
#171	Accessibility issue - Home page - Poorly recognisable focus / no focus available #26  
#172	Accessibility issue - Home page - Language of the page is  missing #5  
#173	Accessibility issue - Home page - Paragraphs in other languages not labelled #27  
#174	Accessibility issue - Home page - Incorrect use of Aria progress bar / incorrect roles #1  
#175	Accessibility issue - Home page - Buttons / links are missing an accessible name #2  
#176	Accessibility issue - Home page - Burger menu button not labelled correctly #36  
#178	Configurable Add Annotation button display  
#181	EDTF support  
#182	Map composer role to dc:creator in oai dc  
#184	No collection thumbnail shown when the first collection member is itself a collection  
#185	Add the resource type icon next to created date on detail page collection members list  
#186	Legacy metadata: missing labels in "Other links" box on detail page  
#187	Legacy metadata: duplicate vocabulary entry for VLB-Systemnummer identifier  
#188	Terms of use text content doesn't change depending on the language of UI  
#189	Enable adding phaidra:Subject / represented object section in metadata editor.  
#190	RSS Feed for collections  
#194	3d docker image tag missing in docker-compose.yml  
#197	Accessibility issue - Filter not operable with zoom #18  
#198	Accessibility - Several errors in filter #23  
#199	Legacy metadata: keywords display on detail page  
#200	Accessibility - The page becomes unreadable on zoom #45  
#201	MIME Type field is addable in upload and edit metadata forms  
#202	Accessibility - Filter not accessible with keyboard #21  
#203	Accessibility - Clickable elements without function #25  
#204	Accessibility - iframe needs title #43  
#205	Accessibility - Number of low-contrast filters #4  
#207	Accessibility - Checkbox missing label #6  
#208	Accessibility - No subtitles #40  
#209	Accessibility - No audio description #42  
#210	Accessibility - Page title could be more concise #26  
#211	Add stylesheet to the OAI-PMH output  
#213	Accessibility - Links not linked #17  
#214	Accessibility - Interactive elements in English and unclear labelling #12  
#215	Accessibility - Overlapping of text (display problem) #47  
#216	Accessibility - Unclear link texts #46  
#217	Accessibility - White font on red low-contrast #24  
#218	Accessibility - Unclear error recommendation #31  
#219	Accessibility - Information not structurally categorised #46  
#220	Accessibility - No audio description or media alternative #41  
#221	Add possibility to skip validation for admin  
#222	Accessibility - Incorrect heading hierarchy #20  
#223	Accessibility - Labelling repeats the role #34  
#224	Accessibility - Position of the filter function #22  
#225	Accessibility - Tabindex value for interactive elements greater than 0 #44  
#232	Odd whitespaces in contributors first name and last name on object detail page  
#235	Legacy metadata: emptying the Dimensions section in Uwmetadata editor throws validation error at saving  
#236	Long strings without spaces overflow column in search result and detail pages  
#239	More roles in search results  
#241	Export md formats error on restricted objects  
#242	Uwmetadata object detail: show link to license text on object detail  
#243	User can't see objects added to own objectlist until public  
#244	Add note to submit form License field about the possibility to later change the license  
#245	Missing rdax and rdam prefixes in JSON-LD context  
#247	Missing facet counts  
#248	Add file size to Download button text on object detail page  
#254	Uwmetadata object detail: show a default label on identifiers that miss the identifier type  
#255	Object title UI language localization  
#256	Object Usage Statistics: add example to "Filter by country code" input field  
#257	Missing processUsageStats.pl and logStorageSize.pl in crontab  
#258	Hide "Select results" button in Search page toolbar for unauthenticated users  
#260	Book Viewer uses favicon.ico which doesn't exist  
#261	Missing edit when following detail link  
#262	Show/hide institution name in breadcrumbs  
#263	Runtime template: custom templates throw errors when using components not already used in corresponding default template  
#264	Bulk Upload stuck  
#266	Incorrect redirect when visiting instance_baseurl/PID URL  
#267	Solr document update failed  
#268	Fedora: Object created with embed relation in the metadata (eg: Book), compact multiple relationship calls on one single operation  
#270	Mirador Book Viewer language localisation support  
#271	Go back to previous page after login  
#272	ROR ID should also be possible in Publication field  
#273	Show in Search page the search term inserted in homepage search field  
#275	Show favicon on Phaidra API Preview templates  
#277	Bug: metadata field "dc_format" duplicated/multiplied  
#278	Adding collection members to existing collection fails  
#279	Fields in an OAI record won't get deleted if not part of update  
#281	Download of resources should not be possible  
#282	ÖFOS and Thema subject classifications: undefined labels in tree view if no term translation is available  
#283	Unchecking Access search facet doesn't remove the mark from selected radio button  
#284	Bulk Upload: add multilingual support  
#285	Bulk Upload: missing breadcrumb  
#286	Show/hide breadcrumbs on home page  
#287	Bulk Upload: multiple Vue errors in browser console  
#288	Bulk Upload: Keywords input field should be disabled if CSV radio button is selected  
#289	Bulk Upload: the Duplicate button on Step 2 does not work  
#291	Add Contact, Code of Ethics, Editorial Policies pages to Admin CMS panel  
#292	Add google verification code to admin  
#293	Collection presentation pages management  
#294	Light theme collection toolbar missing background (or has wrong text color)  
#295	Role - affiliation - ROR assignment broken  
#296	Index affiliation in affiliation_id field  
#297	Vue Meta html lang attribute is always "en"  
#298	Keywords metadata input field calls non-existent Solr keyword suggester  
#299	Remove link to old book-viewer  
#301	Object detail page: show created date as UTC timezone  
#302	Enable fetching external user attributes  
#303	Add link to IIIF-MANIFEST to metadata tab on object detail (for Books and Pictures)  
#304	RSS feed for collection contains links to localhost:3001  
#308	When fetching org attribute via SCIM, pass it to both org unit levels  
#309	Cache user attributes on API side  
#310	Invalid PID error  
#315	Pass cookiedomain to API from env  
#317	Broken component navigation  
#331	Add a "generator" tag to the HTML meta tags  
#332	Legacy container members are not shown and not downloadable  
#333	Prometheus is not using configured fedora user for scraping  
#334	Different versions of IIIF Presentation API in IIIF manifest of Picture and Book objects  
#337	DOI import  
#338	Storage use statistics  
#339	Support for phaidra-ir  
#342	Add solr schema changes to migration script  
#343	Mongo DB public config and changing phaidra url  
#344	Bulk upload: wrong contributor name metadata field in uploaded object  
#345	Bulk upload: upload fails if CSV column value contains newline characters  
#346	Bulk upload: duplicate double quotes in uploaded metadata  
#347	Home page: add support to display the total number of object  
#348	Submit form: make Recommended formats link text and destination customisable  
#349	Add "File formats" page to Admin CMS panel  
#350	Make cmstemplates MongoDB collection documents available in custom home page and collections index page  
#351	Bulk upload: no language applied to title, description, and keywords metadata fields  
#352	Add Depth and Diameter metadata fields to default submit form  
#353	pdf text extraction: tika failure on some pdfs  
#354	Detail page image processing status message wording  
#355	Dedicated translatable label for Uploader on object details page  
#356	Add /static folder to httpd container  
#357	Allow overwriting of submit form featured object type lists  
#358	SMTP_HOST is mandatory for camel toolbox fixity checker  
#359	Adding relationships ignores subjects  
#361	Info text in html header  
#362	error in console if the repo is empty  
#363	Avoid error message on search when the env language is ita and the repo is empty  
#364	Show book preview on object details page  
#365	IMAGESERVER_HOST is exposed to the UI?  
#366	Admin setting: checkbox: disable showing "uploader" in object detail > detail box  
#368	Object type (checkboxes) metadata field not removable in submit form  
#369	Consider using Video.js player also for non-streaming Video objects  
#370	Make more evident rights metadata on object detail page  
#371	Some authenticated pages are available without logging in  
#372	Shibboleth login does not work on mobile  
#373	Deleted objects do not show tombstone  
#375	Include PDF of Book objects in full-text search  
#376	Upload of Resource/Link object not possible via default submit form  
#377	Search page: applying subfilters scrolls to the top of the page  
#378	Cookie banner  
#380	Where to put Matomo/Google Analytics javascript snippet?  
#381	Some metadata fields are not multilingual when added to submit/edit form  
#383	Downloadable custom public metadata on object detail page  
#384	Allow adding http headers globally to every response  
#385	Uploading data object which do not provide mimetype does not work  
#386	Funder name does not get saved  
#387	Show vocabulary code for object type in editor  
#393	Temporal coverage field is empty on edit  
#394	Add support for '%' qualifier character in EDTF Date metadata field  
#395	Add a possibility to add checksum to upload  
#404	ROR api deprecated  
#405	Identifiers cannot be searched for  

## upgrade

  + to upgrade from previous version, please execute the migration scripts as follows

  ```
  docker exec -it phaidra-api-1 perl migrations/v3.3.17/01_add_uwm_object_types.pl
  docker exec -it phaidra-api-1 perl migrations/v3.3.17/02_add_uwm__roles.pl
  docker exec -it phaidra-api-1 perl migrations/v3.3.17/03_add_missing_labels.pl
  docker exec -it phaidra-api-1 perl migrations/v3.3.17/04_add_phaidra_ir_tables.pl
  docker exec -it phaidra-api-1 perl migrations/v3.3.17/05_add_more_usage_stats_indexes.pl
  ```

# v3.3.16

## upgrade

  + to upgrade from previous version, please execute the migration script

  ```
  docker exec -it phaidra-api-1 perl migrations/v3.3.16/alter_usage_stats_table.pl
  ```

## phaidra-api

  + added object types to dc:type
  + added visitor_id to usage_stats database, to be able to filter bots

## phaidra-ui

  + added italian to nuxt config
  + added validateThesis submit validation

## docker

  + ui-dev is now started in hotreload

# v3.3.15

## phaidra-api

  + possibility to make templates public
  + it can be configured that username scope (shib) will be removed
  + IIIF manifests are now generated automatically for pictures
  + fixed EDM mapping for object types
  + fixed redirect after consent when returning from SSO
  + fixed/optimized reindex script
  + fixed owner name being falsly resolved from remote_user
  + fixed groups authz
  + logStorageSize considers imageserver folder too
  + json-ld is now validated with schema json

## phaidra-ui

  + fix book redirect
  + fixed validation of file input if resource type is data
  + various fixes of json-ld

## docker

  + api log is now going to stdout
  + fixed loki config
  + updated to fedora 6.5.0
  + imageserver now specifies FcgidInitialEnv BASE_URL so that info.json contains correct ID
  + certbot certs are now persisted

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
