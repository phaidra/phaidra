import Vue from 'vue'

export const facetQueries = [
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
        query: 'isrestricted:1 OR datastreams:POLICY',
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
        query: 'dc_license:"All rights reserved"',
        label: 'All rights reserved'
      },
      {
        id: 'gplv3',
        query: 'dc_license:"GPLv3"',
        label: 'GPLv3'
      },
      {
        id: 'pdm',
        query: 'dc_license:"Public Domain Mark"',
        label: 'Public Domain Mark'
      },
      {
        id: 'cc-by',
        query: '(dc_license:"CC BY 2.0 AT" OR dc_license:"CC BY 2.0 Generic" OR dc_license:"CC BY 3.0 AT" OR dc_license:"CC BY 3.0 Unported" OR dc_license:"CC BY 4.0 International" OR dc_license:http\\://creativecommons.org/licenses/by/*)',
        label: 'CC BY'
      },
      {
        id: 'cc-by-sa',
        query: '(dc_license:"CC BY-SA 2.0 AT" OR dc_license:"CC BY-SA 2.0 Generic" OR dc_license:"CC BY-SA 3.0 AT" OR dc_license:"CC BY-SA 3.0 Unported" OR dc_license:"CC BY-SA 4.0 International" OR dc_license:http\\://creativecommons.org/licenses/by-sa/*)',
        label: 'CC BY-SA'
      },
      {
        id: 'cc-by-nc',
        query: '(dc_license:"CC BY-NC 2.0 AT" OR dc_license:"CC BY-NC 2.0 Generic" OR dc_license:"CC BY-NC 3.0 AT" OR dc_license:"CC BY-NC 3.0 Unported" OR dc_license:"CC BY-NC 4.0 International" OR dc_license:http\\://creativecommons.org/licenses/by/*)',
        label: 'CC BY-NC'
      },
      {
        id: 'cc-by-nd',
        query: '(dc_license:"CC BY-ND 2.0 AT" OR dc_license:"CC BY-ND 2.0 Generic" OR dc_license:"CC BY-ND 3.0 AT" OR dc_license:"CC BY-ND 3.0 Unported" OR dc_license:"CC BY-ND 4.0 International" OR dc_license:http\\://creativecommons.org/licenses/by-nd/*)',
        label: 'CC BY-ND'
      },
      {
        id: 'cc-by-nc-sa',
        query: '(dc_license:"CC BY-NC-SA 2.0 AT" OR dc_license:"CC BY-NC-SA 2.0 Generic" OR dc_license:"CC BY-NC-SA 3.0 AT" OR dc_license:"CC BY-NC-SA 3.0 Unported" OR dc_license:"CC BY-NC-SA 4.0 International" OR dc_license:http\\://creativecommons.org/licenses/by-nc-sa/*)',
        label: 'CC BY-NC-SA'
      },
      {
        id: 'cc-by-nc-nd',
        query: '(dc_license:"CC BY-NC-ND 2.0 AT" OR dc_license:"CC BY-NC-ND 2.0 Generic" OR dc_license:"CC BY-NC-ND 3.0 AT" OR dc_license:"CC BY-NC-ND 3.0 Unported" OR dc_license:"CC BY-NC-ND 4.0 International" OR dc_license:http\\://creativecommons.org/licenses/by-nc-nd/*)',
        label: 'CC BY-NC-ND'
      }
    ]
  }
]

function buildDateFacet () {
  let months31 = [1, 3, 5, 7, 8, 10, 12]
  let months30 = [4, 6, 9, 11]
  let startYear = 2008
  let currYear = new Date().getFullYear()
  let yearsFacet = {
    label: 'Date',
    field: 'tcreated',
    id: 'created',
    show: false,
    resetable: true,
    queries: []
  }

  for (let year = startYear; year <= currYear; year++) {
    let monthsFacet = {
      label: 'Months of ' + year,
      field: 'tcreated',
      resetable: true,
      id: 'months-' + year,
      queries: []
    }

    for (let month = 1; month <= 12; month++) {
      let daysOfMonth
      if (months30.indexOf(month) > -1) {
        daysOfMonth = 30
      } else {
        if (months31.indexOf(month) > -1) {
          daysOfMonth = 31
        } else {
          let isLeap = ((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0)
          if (isLeap) {
            daysOfMonth = 29
          } else {
            daysOfMonth = 28
          }
        }
      }

      let daysFacet = {
        label: 'Days of ' + month + '.' + year,
        field: 'tcreated',
        resetable: true,
        id: 'days-' + year + '-' + month,
        queries: []
      }

      for (let day = 1; day <= daysOfMonth; day++) {
        if (day < 10) {
          day = '0' + day
        }
        daysFacet.queries.push({
          query: 'tcreated:[' + year + '-' + month + '-' + day + 'T00:00:00Z TO ' + year + '-' + month + '-' + day + 'T23:59:59Z]',
          id: year + '-' + month + '-' + day,
          label: day + '.' + month + '.' + year
        })
      }

      monthsFacet.queries.push({
        query: 'tcreated:[' + year + '-' + month + '-01T00:00:00Z TO ' + year + '-' + month + '-' + daysOfMonth + 'T23:59:59Z]',
        id: year + '-' + month,
        label: month + '.' + year,
        childFacet: daysFacet
      })
    }

    yearsFacet.queries.push({
      query: 'tcreated:[' + year + '-01-01T00:00:00Z TO ' + year + '-12-31T23:59:59Z]',
      id: year,
      label: year,
      childFacet: monthsFacet
    })
  }

  return yearsFacet
}

export function updateFacetQueries (facetQueriesSolr, facetQueries) {
  // called by the `search` function
  if (facetQueriesSolr) {
    Object.keys(facetQueriesSolr).forEach(function (key) {
      for (let i = 0; i < facetQueries.length; i++) {
        for (let j = 0; j < facetQueries[i].queries.length; j++) {
          if (facetQueries[i].queries[j].query === key) {
            Vue.set(facetQueries[i].queries[j], 'count', facetQueriesSolr[key])
          }
          if (facetQueries[i].queries[j].childFacet) {
            let lvl1 = facetQueries[i].queries[j].childFacet
            for (let k = 0; k < lvl1.queries.length; k++) {
              if (lvl1.queries[k].query === key) {
                Vue.set(lvl1.queries[k], 'count', facetQueriesSolr[key])
              }
              if (lvl1.queries[k].childFacet) {
                let lvl2 = lvl1.queries[k].childFacet
                for (let l = 0; l < lvl2.queries.length; l++) {
                  if (lvl2.queries[l].query === key) {
                    Vue.set(lvl2.queries[l], 'count', facetQueriesSolr[key])
                  }
                }
              }
            }
          }
        }
      }
    })
  }
}

export function toggleFacet (q, f) {
  Vue.set(q, 'active', !q.active)

  if (f.exclusive) {
    for (let i = 0; i < f.queries.length; i++) {
      if (f.queries[i] !== q) {
        Vue.set(f.queries[i], 'active', false)
      }
    }
  }
}

export function deactivateFacetQueries (f) {
  for (var i = 0; i < f.queries.length; i++) {
    Vue.set(f.queries[i], 'active', false)
    if (f.queries[i].childFacet) {
      var lvl1 = f.queries[i].childFacet
      for (var j = 0; j < lvl1.queries.length; j++) {
        Vue.set(lvl1.queries[j], 'active', false)
        if (lvl1.queries[j].childFacet) {
          var lvl2 = lvl1.queries[j].childFacet
          for (var k = 0; k < lvl2.queries.length; k++) {
            Vue.set(lvl2.queries[k], 'active', false)
          }
        }
      }
    }
  }
}

export function showFacet (f) {
  Vue.set(f, 'show', !f.show)

  if (!f.show) {
    // when hiding facet, remove it's filters
    deactivateFacetQueries(f)
  }
}

export const persAuthors = {
  field: 'bib_roles_pers_aut',
  label: 'Author',
  values: []
}

export const corpAuthors = {
  field: 'bib_roles_corp_aut',
  label: 'Author',
  values: []
}

facetQueries.push(buildDateFacet())
