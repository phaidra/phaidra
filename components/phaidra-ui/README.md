# phaidra-ui

> User interface using phaidra-api

## Prerequisities

``` bash
# install nodejs
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## Install

``` bash
# install dependencies
git clone git@github.com:phaidra/phaidra-ui.git
cd phaidra-ui
npm install
```

## Configure

/etc/phaidra/phaidra-ui.js
```js
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
      api: 'https://services.myinstance.example.com/api',
      primary: '#000',
      institution: 'My institution',
      institutionurl: 'My institution URL',
      address: 'My institution address',
      phone: '+00-0-000-0',
      email: 'support email'
    }
  }
}
```

## Run (dev server)

```bash
# serve with hot reload at localhost:3000
npm run dev
```

## Build for production

```bash
# build for production and launch server
$ npm run build
$ npm run start

# generate static project
$ npm run generate
```


For detailed explanation on how things work, check out [Nuxt.js docs](https://nuxtjs.org).
