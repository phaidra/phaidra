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
