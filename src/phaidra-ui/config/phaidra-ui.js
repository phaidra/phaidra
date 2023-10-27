export default {
  defaultinstance: '<HOST_WITH_OR_WITHOUT_PORT>',
  global: {
    title: 'Phaidra Docker',
    showinstanceswitch: 0,
    enablelogin: 1,
    enabledelete: 1,
    suggesters: {
      geonames: 'https://ws.gbv.de/suggest/geonames/'
    },
    search: {
      selectionlimit: 100
    },
    apis: {
      doi: {
        baseurl: 'doi.org',
        accept: 'application/vnd.citationstyles.csl+json',
        citationstyles: 'https://citation.crosscite.org/styles/'
      },
      lobid: {
        baseurl: 'lobid.org'
      },
      ror: {
        baseurl: 'api.ror.org'
      },
      sherparomeo: {
        url: 'http://www.sherpa.ac.uk/romeo/api29.php',
        key: 'V9cjsv6PTJE'
      },
      vocserver: {
        ns: 'https://vocab.phaidra.org/vocabulary/',
        url: 'https://vocab.phaidra.org/fuseki/',
        dataset: 'vocab'
      },
      geonames: {
        search: 'https://secure.geonames.org/searchJSON',
        username: 'phaidra',
        maxRows: 50
      },
      dante: {
        search: 'https://api.dante.gbv.de/search',
        resolve: 'https://api.dante.gbv.de/data',
        limit: 50
      }
    },
    monitor: {
      sentry: {
        dsn: ''
      }
    }
  },
  instances: {
    '<HOST_WITH_OR_WITHOUT_PORT>': {
      title: 'Phaidra - Docker',
      baseurl: '<HOST_WITH_OR_WITHOUT_PORT>',
      basepath: '',
      irbaseurl: '',
      api: '<OUTSIDE_HTTP_SCHEME>://<HOST_WITH_OR_WITHOUT_PORT>/api',
      since: '2023-01-01',
      primary: '#008080',
      institution: 'My institution',
      institutionurl: 'https://phaidra.org',
      address: 'My institution | address | here',
      phone: '+00-0-000-0',
      email: 'support email',
      // only uncomment for wildcard purposes
      // cookiedomain: '<HOST_WITH_OR_WITHOUT_PORT>',
      ui: {
        languages: ['eng', 'deu']
      },
      groups: true,
      submit: {
        validationmethod: 'validateNoOefosNoAssoc',
        markmandatorymethod: 'markMandatoryNoOefosNoAssoc'
      }
    }
  }
}
