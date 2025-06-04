import Vue from 'vue'

export function buildDateFacet () {
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
            const updatedQuery = { ...facetQueries[i].queries[j], count: facetQueriesSolr[key] }
            Vue.set(facetQueries[i].queries, j, updatedQuery)
          }
          if (facetQueries[i].queries[j].childFacet) {
            let lvl1 = facetQueries[i].queries[j].childFacet
            for (let k = 0; k < lvl1.queries.length; k++) {
              if (lvl1.queries[k].query === key) {
                const updatedLvl1Query = { ...lvl1.queries[k], count: facetQueriesSolr[key] }
                Vue.set(lvl1.queries, k, updatedLvl1Query)
              }
              if (lvl1.queries[k].childFacet) {
                let lvl2 = lvl1.queries[k].childFacet
                for (let l = 0; l < lvl2.queries.length; l++) {
                  if (lvl2.queries[l].query === key) {
                    const updatedLvl2Query = { ...lvl2.queries[l], count: facetQueriesSolr[key] }
                    Vue.set(lvl2.queries, l, updatedLvl2Query)
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
