export const vocabulary = {
  computed: {
    vocabularies: function () {
      return this.$store.state.vocabulary.vocabularies
    }
  },
  methods: {
    getLocalizedTermLabel: function (vocabulary, value) {
      if (vocabulary && value) {
        return this.$store.getters['vocabulary/getLocalizedTermLabel'](vocabulary, value, this.$i18n.locale)
      }
    },
    getLocalizedTermLabelByNotation: function (vocabulary, notation) {
      if (vocabulary && notation) {
        return this.$store.getters['vocabulary/getLocalizedTermLabelByNotation'](vocabulary, notation, this.$i18n.locale)
      }
    },
    getTerm: function (vocabulary, value) {
      if (vocabulary && value) {
        return this.$store.getters['vocabulary/getTerm'](vocabulary, value)
      }
    },
    getTermProperty: function (vocabulary, id, property) {
      if (vocabulary && id && property) {
        return this.$store.getters['vocabulary/getTermProperty'](vocabulary, id, property)
      }
    },
    autocompleteFilter: function (item, queryText) {
      const lab = item['skos:prefLabel'][this.$i18n.locale] ? item['skos:prefLabel'][this.$i18n.locale].toLowerCase() : item['skos:prefLabel']['eng'].toLowerCase()
      const query = queryText.toLowerCase()
      return lab.startsWith(query)
    },
    autocompleteFilterWithNotation: function (item, queryText) {
      const lab = item['skos:prefLabel'][this.$i18n.locale] ? item['skos:prefLabel'][this.$i18n.locale].toLowerCase() : item['skos:prefLabel']['eng'].toLowerCase()
      const notation = item['skos:notation'] ? item['skos:notation'][0] : null
      const query = queryText.toLowerCase()
      return notation ? lab.startsWith(query) || notation.startsWith(query) : lab.startsWith(query)
    },
    autocompleteFilterInfix: function (item, queryText) {
      const lab = item['skos:prefLabel'][this.$i18n.locale] ? item['skos:prefLabel'][this.$i18n.locale].toLowerCase() : item['skos:prefLabel']['eng'].toLowerCase()
      const query = queryText.toLowerCase()
      return lab.indexOf(query) > -1
    },
    getLocalizedValue: function (values) {
      for (let v of values) {
        if (v['@language'] === this.$i18n.locale) {
          return v['@value']
        }
      }
      for (let v of values) {
        if (v['@language'] === 'eng') {
          return v['@value']
        }
      }
      for (let v of values) {
        return v['@value']
      }
    },
    getLocalizedDefinition: function (vocabulary, value) {
      if (vocabulary && value) {
        let item = this.$store.getters['vocabulary/getTerm'](vocabulary, value)
        if (item['skos:definition']) {
          return item['skos:definition'][this.$i18n.locale] ? item['skos:definition'][this.$i18n.locale] : item['skos:definition']['eng']
        } else {
          return false
        }
      }
    },
    getIDResolverURL: function (exactMatch) {
      let type = exactMatch['@type']
      let value = exactMatch['@value']
      switch (type) {
        case 'ids:doi':
          return 'https://doi.org/' + value
        case 'ids:handle':
          return 'https://hdl.handle.net/' + value
        case 'ids:hdl':
          return 'https://hdl.handle.net/' + value
        case 'phaidra:acnumber':
          return 'https://permalink.obvsg.at/' + value
        case 'ids:urn':
          return value.includes('nbn:at:') ? 'https://resolver.obvsg.at/' + value : 'https://nbn-resolving.org/' + value
        case 'ids:orcid':
          return 'https://orcid.org/' + value
        case 'ids:gnd':
          return 'https://d-nb.info/gnd/' + value
        case 'ids:viaf':
          return 'https://viaf.org/viaf/' + value
        case 'ids:wikidata':
          return 'https://wikidata.org/wiki/' + value
        case 'ids:lcnaf':
          return 'https://lccn.loc.gov/' + value
        case 'ids:isni':
          return 'https://isni.org/isni/' + value
        case 'ids:uri':
          return value
      }
    },
    getOrgPath: function (term, subunits, path) {
      if (term) {
        for (let u of subunits) {
          if (u['@id'] === term['@id']) {
            path.push(u)
            return true
          } else {
            if (u.hasOwnProperty('subunits')) {
              if (Array.isArray(u.subunits)) {
                if (u.subunits.length > 0) {
                  if (this.getOrgPath(term, u.subunits, path)) {
                    path.push(u)
                    return true
                  }
                }
              }
            }
          }
        }
      }
    },
    getOefosPath: function (term, children, path) {
      if (term) {
        for (let t of children) {
          if (t['@id'] === term['@id']) {
            path.push(t)
            return true
          } else {
            if (t.hasOwnProperty('children')) {
              if (Array.isArray(t.children)) {
                if (t.children.length > 0) {
                  if (this.getOefosPath(term, t.children, path)) {
                    path.push(t)
                    return true
                  }
                }
              }
            }
          }
        }
      }
    },
    getThemaPath: function (term, children, path) {
      if (term) {
        for (let t of children) {
          if (t['@id'] === term['@id']) {
            path.push(t)
            return true
          } else {
            if (t.hasOwnProperty('children')) {
              if (Array.isArray(t.children)) {
                if (t.children.length > 0) {
                  if (this.getThemaPath(term, t.children, path)) {
                    path.push(t)
                    return true
                  }
                }
              }
            }
          }
        }
      }
    },
    getBicPath: function (term, children, path) {
      if (term) {
        for (let t of children) {
          if (t['@id'] === term['@id']) {
            path.push(t)
            return true
          } else {
            if (t.hasOwnProperty('children')) {
              if (Array.isArray(t.children)) {
                if (t.children.length > 0) {
                  if (this.getBicPath(term, t.children, path)) {
                    path.push(t)
                    return true
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
