export default {
  defaultinstance: 'phaidra-docker.example.com',
  global: {
    title: 'Phaidra Docker',
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
    'phaidra-docker.example.com': {
      title: 'Phaidra - Docker',
      baseurl: 'phaidra-docker.example.com',
      basepath: '',
      irbaseurl: '',
      fedora: 'http://fedora/fcrepo:8080',
      api: 'http://phaidra-api:3000',
      solr: 'http://solr/phaidra:8983',
      primary: '#dd4814',
      institution: 'University of Vienna',
      institutionurl: 'https://univie.ac.at',
      address: 'My institution address',
      phone: '+00-0-000-0',
      email: 'support email'
    }
  }
}
