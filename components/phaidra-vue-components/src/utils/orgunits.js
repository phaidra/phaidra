export default {
  getOrgUnitsTerms (orgunits, units, parent) {
    for (let u of units) {
      let clone = JSON.parse(JSON.stringify(u))
      clone['subunits'] = null
      orgunits.push(clone)
      // can't do this with SSR
      // TypeError: Converting circular structure to JSON at JSON.stringify (<anonymous>)
      // u.parent = parent
      if (u['subunits']) {
        if (u.subunits.length > 0) {
          this.getOrgUnitsTerms(orgunits, u.subunits, u)
        }
      }
    }
  },
  sortOrgUnitsTree (units, locale) {
    if (Array.isArray(units)) {
      if (units[0]) {
        if (units[0]['phaidra:unitOrdinal']) {
          units.sort(function (a, b) {
            return a['phaidra:unitOrdinal'] - b['phaidra:unitOrdinal']
          })
        } else {
          units.sort(function (a, b) {
            return a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale)
          })
        }
      }
    }
    for (let u of units) {
      if (u['subunits']) {
        this.sortOrgUnitsTree(u['subunits'], locale)
      }
    }
  }
}
