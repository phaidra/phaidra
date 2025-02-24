export default {
  defaultinstance: 'default',
  global: {
    title: 'Phaidra Docker',
    showinstanceswitch: 0,
    enablelogin: 1,
    showdeletebutton: 1,
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
        citationstyles: 'https://citation.doi.org/styles/'
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
      dante: {
        search: 'https://api.dante.gbv.de/search',
        resolve: 'https://api.dante.gbv.de/data',
        limit: 50
      },
      yarm: {
        baseurl: 'yarm.phaidra.org'
      }
    },
    monitor: {
      sentry: {
        dsn: ''
      }
    }
  },
  instances: {
    'default': {
      title: 'Phaidra - Docker',
      institution: 'My institution',
      institutionurl: 'https://phaidra.org',
      address: 'My institution | address | here',
      phone: '+00-0-000-0',
      email: 'support email',
      since: '2023-01-01',
      // only uncomment for wildcard purposes
      // cookiedomain: '<HOST_WITH_OR_WITHOUT_PORT>',
      languages: 'eng,deu'
    }
  }
}
