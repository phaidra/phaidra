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
        const id = typeof value === 'string' ? value : value['@id']
        if (!id) return
        return this.$store.getters['vocabulary/getTerm'](vocabulary, id)
      }
    },
    /** Plain title string for v-select/v-autocomplete item-title (Vuetify 3) */
    skosTermItemTitle (item, voc) {
      const raw = item?.raw !== undefined ? item.raw : item
      if (!raw || !raw['@id'] || !voc) return ''
      const s = this.getLocalizedTermLabel(voc, raw['@id'])
      return typeof s === 'string' ? s.replace(/<[^>]+>/g, '') : String(s || '')
    },
    /** SKOS label plus notation (Thema, OEFOS, BIC-style lists) */
    skosTermItemTitleWithNotation (item, voc) {
      const base = this.skosTermItemTitle(item, voc)
      const raw = item?.raw !== undefined ? item.raw : item
      if (!raw || !raw['@id']) return base
      const not = raw['skos:notation'] && raw['skos:notation'][0]
      return not ? `${base} - ${not}` : base
    },
    /** orgunits list rows (flat or grouped with divider/header) */
    orgunitItemTitle (item) {
      const raw = item?.raw !== undefined ? item.raw : item
      if (!raw) return ''
      if (raw.header != null && !raw['@id']) return String(raw.header)
      if (raw.divider) return ''
      if (!raw['@id']) return ''
      const s = this.getLocalizedTermLabel('orgunits', raw['@id'])
      return typeof s === 'string' ? s.replace(/<[^>]+>/g, '') : String(s || '')
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
    /** Vuetify 3 v-autocomplete customFilter: return match index or -1 */
    vocabAutocompleteFilter (_value, query, item) {
      const raw = item?.raw ?? item
      if (!raw || !raw['@id']) return -1
      return this.autocompleteFilter(raw, String(query ?? '')) ? 0 : -1
    },
    vocabAutocompleteFilterWithNotation (_value, query, item) {
      const raw = item?.raw ?? item
      if (!raw || !raw['@id']) return -1
      return this.autocompleteFilterWithNotation(raw, String(query ?? '')) ? 0 : -1
    },
    /** For grouped orgunits lists: { divider }, { header } rows + SKOS terms */
    orgunitsAutocompleteFilter (_value, query, item) {
      const raw = item?.raw ?? item
      if (!raw) return -1
      if (raw.divider || (raw.header != null && !raw['@id'])) {
        return String(query ?? '').length ? -1 : 0
      }
      if (!raw['@id']) return -1
      return this.autocompleteFilterInfix(raw, String(query ?? '')) ? 0 : -1
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
        case 'ids:issn':
          return 'http://issn.org/resource/ISSN/' + value
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
    },
    /** Vuetify 3 v-treeview `item-title` (function) for SKOS JSON-LD nodes with prefLabel + @id */
    skosVTreeItemTitle (item) {
      const i = item?.raw !== undefined ? item.raw : item
      if (!i) return ''
      const pl = i['skos:prefLabel']
      if (pl) {
        const loc = this.$i18n.locale
        const t = pl[loc] || pl.eng || pl.deu || Object.values(pl).find(Boolean)
        if (t) return String(t)
      }
      return i['@id'] != null ? String(i['@id']) : ''
    },
    /** Shared lazy-tree helpers for large vocab trees (Vuetify `load-children`). */
    prepareLazyTreeNode (node, childrenKey = 'children', lazyKey = '__lazyChildren') {
      if (!node || typeof node !== 'object') return
      const originalChildren = Array.isArray(node[childrenKey]) ? node[childrenKey] : []
      node[lazyKey] = originalChildren
      node[childrenKey] = originalChildren.length > 0 ? [] : undefined
    },
    prepareLazyTree (roots, childrenKey = 'children', lazyKey = '__lazyChildren') {
      if (!Array.isArray(roots)) return
      for (const node of roots) {
        this.prepareLazyTreeNode(node, childrenKey, lazyKey)
      }
    },
    loadLazyTreeChildren (node, childrenKey = 'children', lazyKey = '__lazyChildren') {
      if (!node || typeof node !== 'object') return
      const lazyChildren = node[lazyKey]
      if (!Array.isArray(lazyChildren) || lazyChildren.length === 0) return
      this.prepareLazyTree(lazyChildren, childrenKey, lazyKey)
      node[childrenKey] = lazyChildren
      node[lazyKey] = []
    }
  }
}
