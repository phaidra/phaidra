export default {
  defaultinstance: 'default',
  global: {
    title: 'Phaidra Docker',
    showinstanceswitch: 0,
    enablelogin: 1,
    showdeletebutton: 1,
    // Custom HTTP response headers applied to all instances
    // customResponseHeaders: {
    //   'X-Frame-Options': 'SAMEORIGIN',
    //   'X-Content-Type-Options': 'nosniff'
    // },
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
        baseurl: 'api.ror.org/v1'
      },
      sherparomeo: {
        url: 'https://v2.sherpa.ac.uk/romeo/api/search',
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
      title: 'PHAIDRA',
      institution: 'My institution',
      institutionurl: 'https://phaidra.org',
      address: 'My institution | address | here',
      phone: '+00-0-000-0',
      email: 'support email',
      since: '2023-01-01',
      // only uncomment for wildcard purposes
      // cookiedomain: '<HOST_WITH_OR_WITHOUT_PORT>',
      languages: 'eng,deu',
      // Custom HTTP response headers for specific instance. Useful for preventing search engines from indexing sandbox/test instances.
      // customResponseHeaders: {
      //   'X-Robots-Tag': 'noindex, nofollow'
      // }
    }
  }
}
