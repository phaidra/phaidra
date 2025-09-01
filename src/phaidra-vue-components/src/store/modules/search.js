import Vue from 'vue'

export const state = () => ({
  facetQueries: [
    {
      label: 'Access',
      field: 'datastreams',
      id: 'datastreams',
      exclusive: true,
      resetable: true,
      show: false,
      queries: [
        {
          id: 'restricted',
          query: '(isrestricted:1 OR datastreams:POLICY)',
          label: 'Restricted'
        },
        {
          id: 'unrestricted',
          query: '-isrestricted:1 AND -datastreams:POLICY',
          label: 'Unrestricted'
        }
      ]
    },
    {
      label: 'Type',
      field: 'resourcetype',
      id: 'resourcetype',
      resetable: true,
      show: true,
      queries: [
        {
          id: 'image',
          query: 'resourcetype:image',
          label: 'Image'
        },
        {
          id: 'book',
          query: 'resourcetype:book',
          label: 'Book'
        },
        // {
        //   id: 'article',
        //   query: 'resourcetype:journalarticle',
        //   label: 'Article'
        // },
        {
          id: 'text',
          query: 'resourcetype:text',
          label: 'Text'
        },
        {
          id: 'educationalresource',
          query: 'oer:true',
          label: 'Educational resource'
        },
        {
          id: 'openeducationalresource',
          query: 'oer:true AND (dc_license:"CC BY 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by\\/4.0\\/ OR "CC BY-SA 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-sa\\/4.0\\/ OR "CC BY-NC 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-nc\\/4.0\\/ OR "CC BY-NC-SA 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-nc-sa\\/4.0\\/)',
          label: 'Open educational resource'
        },
        {
          id: 'collection',
          query: 'resourcetype:collection',
          label: 'Collection'
        },
        {
          id: 'video',
          query: 'resourcetype:video',
          label: 'Video'
        },
        {
          id: 'other',
          query: 'resourcetype:other',
          label: 'Data'
        },
        {
          id: 'dataset',
          query: 'resourcetype:dataset',
          label: 'Container'
        },
        {
          id: 'map',
          query: 'resourcetype:map',
          label: 'Map'
        },
        {
          id: 'resource',
          query: 'resourcetype:interactiveresource',
          label: 'Resource'
        },
        {
          id: 'sound',
          query: 'resourcetype:sound',
          label: 'Sound'
        }
      ]
    },
    {
      label: 'Size',
      field: 'tsize',
      id: 'size',
      show: false,
      resetable: true,
      queries: [
        {
          id: 'less10',
          query: 'tsize:[0 TO 10485760}',
          label: 'less 10MB'
        },
        {
          id: '10to50',
          query: 'tsize:[10485760 TO 52428800]',
          label: '10MB - 50MB'
        },
        {
          id: '50to100',
          query: 'tsize:{52428800 TO 104857600]',
          label: '50MB - 100MB'
        },
        {
          id: '100to200',
          query: 'tsize:{104857600 TO 209715200]',
          label: '100MB - 200MB'
        },
        {
          id: '200to500',
          query: 'tsize:{209715200 TO 524288000]',
          label: '200MB - 500MB'
        },
        {
          id: '500to1000',
          query: 'tsize:{524288000 TO 1073741824]',
          label: '500MB - 1GB'
        },
        {
          id: 'more1000',
          query: 'tsize:{1073741824 TO *]',
          label: 'more 1GB'
        }
      ]
    },
    {
      label: 'License',
      field: 'dc_license',
      id: 'license',
      show: false,
      resetable: true,
      queries: [
        {
          id: 'all-rights-reserved',
          query: '(dc_license:"All rights reserved" OR dc_license:http\\:\\/\\/rightsstatements.org\\/vocab\\/InC\\/1.0\\/)',
          label: 'All rights reserved'
        },
        {
          id: 'gplv3',
          query: 'dc_license:"GPLv3"',
          label: 'GPLv3'
        },
        {
          id: 'pdm',
          query: '(dc_license:"Public Domain Mark" OR dc_license:http\\:\\/\\/creativecommons.org\\/publicdomain\\/mark\\/1.0\\/)',
          label: 'Public Domain Mark'
        },
        {
          id: 'mit',
          query: '(dc_license:"MIT" OR dc_license:https\\:\\/\\/opensource.org\\/license\\/mit\\/)',
          label: 'MIT'
        },
        {
          id: 'cc-by',
          query: '(dc_license:"CC BY 2.0 AT" OR dc_license:"CC BY 2.0 Generic" OR dc_license:"CC BY 3.0 AT" OR dc_license:"CC BY 3.0 Unported" OR dc_license:"CC BY 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by\\/*)',
          label: 'CC BY'
        },
        {
          id: 'cc-by-sa',
          query: '(dc_license:"CC BY-SA 2.0 AT" OR dc_license:"CC BY-SA 2.0 Generic" OR dc_license:"CC BY-SA 3.0 AT" OR dc_license:"CC BY-SA 3.0 Unported" OR dc_license:"CC BY-SA 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-sa\\/*)',
          label: 'CC BY-SA'
        },
        {
          id: 'cc-by-nc',
          query: '(dc_license:"CC BY-NC 2.0 AT" OR dc_license:"CC BY-NC 2.0 Generic" OR dc_license:"CC BY-NC 3.0 AT" OR dc_license:"CC BY-NC 3.0 Unported" OR dc_license:"CC BY-NC 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-nc\\/*)',
          label: 'CC BY-NC'
        },
        {
          id: 'cc-by-nd',
          query: '(dc_license:"CC BY-ND 2.0 AT" OR dc_license:"CC BY-ND 2.0 Generic" OR dc_license:"CC BY-ND 3.0 AT" OR dc_license:"CC BY-ND 3.0 Unported" OR dc_license:"CC BY-ND 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-nd\\/*)',
          label: 'CC BY-ND'
        },
        {
          id: 'cc-by-nc-sa',
          query: '(dc_license:"CC BY-NC-SA 2.0 AT" OR dc_license:"CC BY-NC-SA 2.0 Generic" OR dc_license:"CC BY-NC-SA 3.0 AT" OR dc_license:"CC BY-NC-SA 3.0 Unported" OR dc_license:"CC BY-NC-SA 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-nc-sa\\/*)',
          label: 'CC BY-NC-SA'
        },
        {
          id: 'cc-by-nc-nd',
          query: '(dc_license:"CC BY-NC-ND 2.0 AT" OR dc_license:"CC BY-NC-ND 2.0 Generic" OR dc_license:"CC BY-NC-ND 3.0 AT" OR dc_license:"CC BY-NC-ND 3.0 Unported" OR dc_license:"CC BY-NC-ND 4.0 International" OR dc_license:http\\:\\/\\/creativecommons.org\\/licenses\\/by-nc-nd\\/*)',
          label: 'CC BY-NC-ND'
        }
      ]
    }
  ]
})

const mutations = {
  setFacetQueries (state, facetQueries) {
    // console.log('setting facet queries')
    // console.log(facetQueries)
    Vue.set(state, 'facetQueries', facetQueries)
  }
}

export default {
  state,
  mutations
}
