export default {
  defaultinstance: 'phaidra-docker.example.com',
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
    'phaidra-docker.example.com': {
      title: 'Phaidra - Docker',
      baseurl: 'phaidra-docker.example.com',
      basepath: '',
      irbaseurl: '',
      fedora: 'http://fedora:8080/fcrepo',
      api: 'http://localhost:3003',
      solr: 'http://localhost:3003/search',
      since: '2023-01-01',
      primary: '#008080',
      institution: 'My institution',
      institutionurl: 'https://phaidra.org',
      address: 'My institution | address | here',
      phone: '+00-0-000-0',
      email: 'support email',
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
