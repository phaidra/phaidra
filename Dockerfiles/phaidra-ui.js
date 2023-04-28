export default {
  defaultinstance: 'myinstance.example.com',
  global: {
    title: 'phaidra-ui',
    showinstanceswitch: 0,
    enablelogin: 1,
    enabledelete: 1,
    suggesters: {
      gnd: 'https://ws.gbv.de/suggest/gnd/',
      geonames: 'https://ws.gbv.de/suggest/geonames/'
    },
    search: {
      selectionlimit: 5000
    },
    apis: {
      doi: {
        baseurl: 'doi.org',
        accept: 'application/vnd.citationstyles.csl+json',
        citationstyles: 'https://citation.crosscite.org/styles/'
      },
      sherparomeo: {
        url: 'https://v2.sherpa.ac.uk/cgi/retrieve',
        key: 'xxx'
      },
      vocserver: {
        ns: 'https://vocab.phaidra.org/vocabulary/',
        url: 'https://vocab.phaidra.org/fuseki/',
        dataset: 'vocab'
      }
    }
  },
  instances: {
    'myinstance.example.com': {
      title: 'Phaidra - myinstance',
      baseurl: 'myinstance.example.com',
      basepath: '',
      irbaseurl: 'myirinstance.example.com',
      fedora: 'https://fedora.myinstance.example.com/fedora',
      api: 'https://services.myinstance.example.com/api',
      solr: 'https://myinstance.example.com/search/solr/phaidra',
      primary: '#000',
      institution: 'My institution',
      institutionurl: 'My institution URL',
      address: 'My institution address',
      phone: '+00-0-000-0',
      email: 'support email'
    }
  }
}
