export function buildDateFacet () {
  let months31 = [1, 3, 5, 7, 8, 10, 12]
  let months30 = [4, 6, 9, 11]
  let startYear = 2008
  let currYear = new Date().getFullYear()
  let yearsFacet = {
    label: 'Upload date',
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

export function buildAccessibilityFacet () {
  return {
    label: 'Accessibility',
    field: 'accessibility',
    id: 'a11y',
    queries: []
  }
}

function facetQueryKey (q) {
  return q.countQuery || q.query
}

export function updateFacetQueries (facetQueriesSolr, facetQueries) {
  if (facetQueriesSolr) {
    Object.keys(facetQueriesSolr).forEach(function (key) {
      for (let i = 0; i < facetQueries.length; i++) {
        for (let j = 0; j < facetQueries[i].queries.length; j++) {
          if (facetQueryKey(facetQueries[i].queries[j]) === key) {
            const updatedQuery = { ...facetQueries[i].queries[j], count: facetQueriesSolr[key] }
            facetQueries[i].queries[j] = updatedQuery
          }
          if (facetQueries[i].queries[j].childFacet) {
            let lvl1 = facetQueries[i].queries[j].childFacet
            for (let k = 0; k < lvl1.queries.length; k++) {
              if (facetQueryKey(lvl1.queries[k]) === key) {
                const updatedLvl1Query = { ...lvl1.queries[k], count: facetQueriesSolr[key] }
                lvl1.queries[k] = updatedLvl1Query
              }
              if (lvl1.queries[k].childFacet) {
                let lvl2 = lvl1.queries[k].childFacet
                for (let l = 0; l < lvl2.queries.length; l++) {
                  if (facetQueryKey(lvl2.queries[l]) === key) {
                    const updatedLvl2Query = { ...lvl2.queries[l], count: facetQueriesSolr[key] }
                    lvl2.queries[l] = updatedLvl2Query
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
        f.queries[i].active = false
      }
    }
  }
}

export function deactivateFacetQueries (f) {
  if(f.selectedRadioValue){
    delete f.selectedRadioValue
  }
  for (var i = 0; i < f.queries.length; i++) {
    f.queries[i].active = false
    f.queries[i].excluded = false
    if (f.queries[i].childFacet) {
      var lvl1 = f.queries[i].childFacet
      for (var j = 0; j < lvl1.queries.length; j++) {
        lvl1.queries[j].active = false
        lvl1.queries[j].excluded = false
        if (lvl1.queries[j].childFacet) {
          var lvl2 = lvl1.queries[j].childFacet
          for (var k = 0; k < lvl2.queries.length; k++) {
            lvl2.queries[k].active = false
            lvl2.queries[k].excluded = false
          }
        }
      }
    }
  }
}

export function hasSelectedFacetQuery (queries) {
  if (!queries) {
    return false
  }
  return queries.some(q => q.active || q.excluded || hasSelectedFacetQuery(q.childFacet && q.childFacet.queries))
}

const uwmObjectTypePrefix = 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/'
const uwmObjectTypes = {
  '47QB-8QF1': ['1552257'],
  'QKDF-E5HA': ['1556237'],
  'PYRE-RAWJ': ['1552260'],
  '1PHE-7VMS': ['1742'],
  'MF25-FDGW': ['1552253'],
  '9ZSV-CVJH': ['1743'],
  '489N-Y6VX': ['1556239'],
  'JJKV-B1CG': ['1556236'],
  'N35H-PDEE': ['1556242'],
  'KW6N-2VTP': ['1557090'],
  'P2YP-BMND': ['1739'],
  'XA52-09WA': ['1556235'],
  '9E94-E3F8': ['1740'],
  'T023-BGTD': ['1556240'],
  '62DN-RZ7V': ['1552258'],
  'ST05-F6SP': ['1741'],
  'Z3K6-SWVD': ['1738'],
  'F4JN-ZST0': ['1552262'],
  'JMAV-7F3R': ['1556241'],
  'YA8R-1M0D': ['1562801']
}

const uwmVoc24Prefixes = [
  'http://phaidra.univie.ac.at/XML/metadata/histkult/V1.0/voc_24/',
  'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/voc_24/'
]
const uwmObjectTypesVoc24 = {
  '47QB-8QF1': ['1557194'],
  'PYRE-RAWJ': ['1557206'],
  'MF25-FDGW': ['1557192'],
  '3VKA-1FW2': ['1557192'],
  'XA52-09WA': ['1557193'],
  'QM0R-ZTAA': ['1557151'],
  'Q4Q5-3554': ['1557152'],
  'WWS3-0ACP': ['1557153'],
  '85QM-7TZ3': ['1557154'],
  '7CAB-P987': ['1557155'],
  'R4W3-ZQ76': ['1557156'],
  '6EFK-BRQD': ['1557157'],
  '7WYH-AZ8C': ['1557158'],
  '431H-5YSA': ['1557162'],
  '9W35-5Q94': ['1557163'],
  '9J46-2X9E': ['1557174'],
  'A52A-CWMM': ['1557175'],
  'XTVH-3MG3': ['1557185'],
  'KMRH-NFR9': ['1557195'],
  'GY3Z-50FT': ['1557196'],
  'GBWA-JJP8': ['1562632'],
  'C36Q-N42M': ['1552077']
}

export function buildObjectTypeFacet (parent, terms, labelOf) {
  return {
    queries: terms.map(term => {
      const id = term['@id'].substring(term['@id'].lastIndexOf('/') + 1)
      const ids = [term['@id']]
        .concat((uwmObjectTypes[id] || []).map(uwmId => uwmObjectTypePrefix + uwmId))
        .concat((uwmObjectTypesVoc24[id] || []).flatMap(uwmId => uwmVoc24Prefixes.map(prefix => prefix + uwmId)))
      const objectTypeQuery = 'object_type_id:(' + ids.map(v => '"' + v + '"').join(' OR ') + ')'
      return {
        id: parent.id + '.' + id,
        label: labelOf(term['@id']),
        query: objectTypeQuery,
        countQuery: '(' + parent.query + ') AND (' + objectTypeQuery + ')'
      }
    })
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
