import fields from './fields'
import vocabularystore from '../store/modules/vocabulary'

export default {
  json2components: function (jsonld, options, vocabularies) {
    var components = []

    // all dce:subjects in the same language are handled by 1 component
    let keywords = {}
    Object.entries(jsonld).forEach(([key, value]) => {
      if (key === 'dce:subject') {
        for (let v of value) {
          if (v['@type'] === 'skos:Concept') {
            for (let pl of v['skos:prefLabel']) {
              let lang = pl['@language'] ? pl['@language'] : 'xxx'
              if (!keywords[lang]) {
                keywords[lang] = []
              }
              keywords[lang].push(pl['@value'])
            }
          }
        }
      }
    })
    Object.entries(keywords).forEach(([key, value]) => {
      let f = fields.getField('keyword')
      if (key !== 'xxx') {
        f.language = key
      }
      f.value = value
      components.push(f)
    })

    Object.entries(jsonld).forEach(([key, values]) => {
      if (key !== '@type') {
        for (let obj of values) {
          let f
          switch (key) {
            // rdam:P30004
            case 'rdam:P30004':
              f = fields.getField('alternate-identifier')
              f.type = obj['@type']
              f.value = obj['@value']
              components.push(f)
              break

            // dcterms:type
            case 'dcterms:type':
              f = fields.getField('resource-type')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // edm:hasType
            case 'edm:hasType':
              f = fields.getField('object-type')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // schema:genre
            case 'schema:genre':
              f = fields.getField('genre')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            case 'schema:accessMode':
              f = fields.getField('access-mode')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            case 'schema:accessibilityFeature':
              f = fields.getField('accessibility-feature')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            case 'schema:accessibilityControl':
              f = fields.getField('accessibility-control')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            case 'schema:accessibilityHazard':
              f = fields.getField('accessibility-hazard')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // oaire:version
            case 'oaire:version':
              f = fields.getField('version-type')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // dcterms:accessRights
            case 'dcterms:accessRights':
              f = fields.getField('access-right')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // dce:title
            case 'dce:title':
              if ((obj['@type'] === 'bf:Title') || (obj['@type'] === 'bf:ParallelTitle')) {
                f = fields.getField('title')
                f.type = obj['@type']
                if (obj['bf:mainTitle']) {
                  for (let title of obj['bf:mainTitle']) {
                    f.title = title['@value']
                    f.language = title['@language'] ? title['@language'] : 'eng'
                  }
                }
                if (obj['bf:subtitle']) {
                  for (let subtitle of obj['bf:subtitle']) {
                    f.subtitle = subtitle['@value']
                  }
                }
                components.push(f)
              }
              break

            // bf:note
            case 'bf:note':
              switch (obj['@type']) {
                case 'bf:Note':
                  f = fields.getField('description')
                  break
                case 'bf:Summary':
                  f = fields.getField('abstract')
                  break
                case 'phaidra:Remark':
                  f = fields.getField('note')
                  break
                case 'phaidra:DigitizationNote':
                  f = fields.getField('digitization-note')
                  break
                case 'arm:ConditionAssessment':
                case 'phaidra:ConditionNote':
                  f = fields.getField('condition-note')
                  break
                case 'phaidra:ReproductionNote':
                  f = fields.getField('reproduction-note')
                  break
              }

              for (let prefLabel of obj['skos:prefLabel']) {
                f.value = prefLabel['@value']
                f.language = prefLabel['@language'] ? prefLabel['@language'] : ''
              }
              components.push(f)
              break

            // bf:tableOfContents
            case 'bf:tableOfContents':
              f = fields.getField('table-of-contents')
              for (let prefLabel of obj['skos:prefLabel']) {
                f.value = prefLabel['@value']
                f.language = prefLabel['@language'] ? prefLabel['@language'] : ''
              }
              components.push(f)
              break

            // dcterms:language
            case 'dcterms:language':
              f = fields.getField('language')
              if (obj['skos:exactMatch']) {
                f.vocabulary = 'lang_vocab'
                for (let v of obj['skos:exactMatch']) {
                  f.value = v
                }
              } else {
                f.value = obj
              }
              components.push(f)
              break

            // schema:subtitleLanguage
            case 'schema:subtitleLanguage':
              f = fields.getField('subtitle-language')
              f.value = obj
              if (obj['skos:exactMatch']) {
                f.vocabulary = 'lang_vocab'
              }
              components.push(f)
              break

            // dce:subject
            case 'dce:subject':
              // noop - we handled this already
              break

            // dcterms:subject
            case 'dcterms:subject':
              if (obj['@type'] === 'skos:Concept') {
                f = fields.getField('vocab-ext-readonly')
                f['skos:exactMatch'] = obj['skos:exactMatch']
                f['skos:prefLabel'] = obj['skos:prefLabel']
                f['rdfs:label'] = obj['rdfs:label']
                if (obj['skos:exactMatch']) {
                  for (let v of obj['skos:exactMatch']) {
                    f.value = v
                  }
                }
                if (obj['skos:notation']) {
                  f['skos:notation'] = []
                  for (let v of obj['skos:notation']) {
                    f['skos:notation'].push(v)
                  }
                }
                f.predicate = key
                f.dividertop = true
                components.push(f)
                if (obj['skos:exactMatch']) {
                  for (let v of obj['skos:exactMatch']) {
                    let newField
                    if (v.startsWith('oefos2012')) {
                      f.label = 'Subject (ÖFOS)'
                      newField = fields.getField('oefos-subject')
                      newField.dividerbottom = true
                      newField.label = 'Subject (ÖFOS)'
                      components.push(newField)
                    }
                    if (v.startsWith('thema')) {
                      f.label = 'Subject (Thema)'
                      newField = fields.getField('thema-subject')
                      newField.dividerbottom = true
                      newField.label = 'Subject (Thema)'
                      components.push(newField)
                    }
                    if (v.startsWith('bic')) {
                      f.label = 'Subject (BIC)'
                      newField = fields.getField('bic-subject')
                      newField.dividerbottom = true
                      newField.label = 'Subject (BIC)'
                      components.push(newField)
                    }
                    if (v.startsWith('http://d-nb.info/gnd') || v.startsWith('https://d-nb.info/gnd')) {
                      f.label = 'Subject (GND)'
                      newField = fields.getField('gnd-subject')
                      newField.dividerbottom = true
                      newField.label = 'Subject (GND)'
                      components.push(newField)
                    }
                    if (v.startsWith('http://uri.gbv.de/terminology/bk') || v.startsWith('https://uri.gbv.de/terminology/bk')) {
                      f.label = 'Basisklassifikation'
                      newField = fields.getField('bk-subject')
                      newField.dividerbottom = true
                      newField.label = 'Basisklassifikation'
                      components.push(newField)
                    }
                  }
                }
              } else {
                if (obj['@type'] === 'phaidra:Subject') {
                  // ignore, handled elsewhere
                }
              }
              break

            case 'rdau:P60193':
              f = fields.getField('series')
              if (obj['dce:title']) {
                for (let t of obj['dce:title']) {
                  if (t['bf:mainTitle']) {
                    for (let mt of t['bf:mainTitle']) {
                      if (mt['@value']) {
                        f.title = mt['@value']
                      }
                      if (mt['@language']) {
                        f.titleLanguage = mt['@language']
                      }
                    }
                  }
                }
              }
              if (obj['bibo:volume']) {
                for (let v of obj['bibo:volume']) {
                  f.volume = v
                }
              }
              if (obj['bibo:issue']) {
                for (let v of obj['bibo:issue']) {
                  f.issue = v
                }
              }
              if (obj['dcterms:issued']) {
                for (let v of obj['dcterms:issued']) {
                  f.issued = v
                }
              }
              if (obj['ids:issn']) {
                for (let v of obj['ids:issn']) {
                  f.issn = v
                }
              }
              if (obj['skos:exactMatch']) {
                for (let v of obj['skos:exactMatch']) {
                  if (v['@type']) {
                    f.identifierType = v['@type']
                    f.identifier = v['@value']
                  } else {
                    f.identifier = v
                  }
                }
              }
              Object.entries(jsonld).forEach(([key1, value1]) => {
                if (key1 === 'schema:pageStart') {
                  for (let ps of value1) {
                    f.pageStart = ps
                  }
                }
                if (key1 === 'schema:pageEnd') {
                  for (let pe of value1) {
                    f.pageEnd = pe
                  }
                }
              })
              components.push(f)
              break

            case 'rdau:P60101':
              f = fields.getField('contained-in')
              if (obj['dce:title']) {
                for (let t of obj['dce:title']) {
                  if (t['bf:mainTitle']) {
                    for (let mt of t['bf:mainTitle']) {
                      if (mt['@value']) {
                        f.title = mt['@value']
                      }
                      if (mt['@language']) {
                        f.titleLanguage = mt['@language']
                      }
                    }
                  }
                  if (t['bf:subtitle']) {
                    for (let st of t['bf:subtitle']) {
                      if (st['@value']) {
                        f.subtitle = st['@value']
                      }
                    }
                  }
                }
              }
              if (obj['ids:isbn']) {
                for (let v of obj['ids:isbn']) {
                  f.isbn = v
                }
              }
              if (obj['skos:exactMatch']) {
                for (let v of obj['skos:exactMatch']) {
                  if (v['@type']) {
                    f.identifierType = v['@type']
                    f.identifier = v['@value']
                    f.hideIdentifier = false
                  } else {
                    f.identifier = v
                  }
                }
              }
              f.roles = []
              Object.entries(obj).forEach(([key, value]) => {
                if (key.startsWith('role')) {
                  let roleidx = 0
                  for (let role of value) {
                    roleidx++
                    let entity = {
                      id: 'contained-in-role-' + roleidx,
                      role: key,
                      ordergroup: 'contained-in-role'
                    }
                    if (role['schema:name']) {
                      for (let name of role['schema:name']) {
                        entity.name = name['@value']
                      }
                    }
                    if (role['schema:familyName']) {
                      for (let lastname of role['schema:familyName']) {
                        entity.lastname = lastname['@value']
                      }
                    }
                    if (role['schema:givenName']) {
                      for (let firstname of role['schema:givenName']) {
                        entity.firstname = firstname['@value']
                      }
                    }
                    f.roles.push(entity)
                  }
                }
              })
              Object.entries(jsonld).forEach(([key1, value1]) => {
                if (key1 === 'schema:pageStart') {
                  for (let ps of value1) {
                    f.pageStart = ps
                  }
                }
                if (key1 === 'schema:pageEnd') {
                  for (let pe of value1) {
                    f.pageEnd = pe
                  }
                }
              })
              if (obj['rdau:P60193']) {
                if (obj['rdau:P60193'].length > 0) {
                  let serIdx = 0
                  f.series = []
                  for (let series of obj['rdau:P60193']) {
                    serIdx++
                    let s = {
                      id: 'contained-in-series-' + serIdx,
                      seriesTitle: '',
                      seriesTitleLanguage: '',
                      seriesVolume: '',
                      seriesIssue: '',
                      seriesIssued: '',
                      seriesIssn: '',
                      seriesIdentifier: '',
                      seriesIdentifierType: '',
                      multiplicable: false,
                      multiplicableCleared: true,
                      removable: serIdx > 0
                    }
                    if (series['dce:title']) {
                      for (let t of series['dce:title']) {
                        if (t['bf:mainTitle']) {
                          for (let mt of t['bf:mainTitle']) {
                            if (mt['@value']) {
                              s.seriesTitle = mt['@value']
                            }
                            if (mt['@language']) {
                              s.seriesTitleLanguage = mt['@language']
                            }
                          }
                        }
                      }
                    }
                    if (series['bibo:volume']) {
                      for (let v of series['bibo:volume']) {
                        s.seriesVolume = v
                      }
                    }
                    if (series['bibo:issue']) {
                      for (let v of series['bibo:issue']) {
                        s.seriesIssue = v
                      }
                    }
                    if (series['dcterms:issued']) {
                      for (let v of series['dcterms:issued']) {
                        s.seriesIssued = v
                      }
                    }
                    if (series['ids:issn']) {
                      for (let v of series['ids:issn']) {
                        s.seriesIssn = v
                      }
                    }
                    if (series['skos:exactMatch']) {
                      for (let v of series['skos:exactMatch']) {
                        if (v['@value']) {
                          s.seriesIdentifierType = v['@type']
                          s.seriesIdentifier = v['@value']
                          f.hideSeriesIdentifier = false
                        } else {
                          s.seriesIdentifier = v
                        }
                      }
                    }
                    f.series.push(s)
                  }
                }
              }
              if (obj['bf:provisionActivity']) {
                for (let prov of obj['bf:provisionActivity']) {
                  if (prov['bf:agent']) {
                    for (let pub of prov['bf:agent']) {
                      if (pub['skos:exactMatch']) {
                        for (let id of pub['skos:exactMatch']) {
                          if (id.startsWith('https://pid.phaidra.org/')) {
                            f.publisherType = 'select'
                            f.publisherOrgUnit = id
                          } else {
                            f.publisherType = 'other'
                            if (pub['schema:name']) {
                              for (let name of pub['schema:name']) {
                                f.publisherName = name['@value']
                              }
                            }
                          }
                        }
                      } else {
                        if (pub['schema:name']) {
                          f.publisherType = 'other'
                          if (pub['schema:name']) {
                            for (let name of pub['schema:name']) {
                              f.publisherName = name['@value']
                            }
                          }
                        }
                      }
                    }
                  }
                  if (prov['bf:place']) {
                    for (let pl of prov['bf:place']) {
                      if (pl['skos:prefLabel']) {
                        for (let pllab of pl['skos:prefLabel']) {
                          f.publishingPlace = pllab['@value']
                        }
                      }
                    }
                  }
                  if (prov['bf:date']) {
                    for (let pdate of prov['bf:date']) {
                      f.publishingDate = pdate
                    }
                  }
                }
              }
              components.push(f)
              break

            // dcterms:temporal
            case 'dcterms:temporal':
              f = fields.getField('temporal-coverage')
              f.value = obj['@value']
              f.language = obj['@language'] ? obj['@language'] : 'eng'
              components.push(f)
              break

            // spatial
            case 'dcterms:spatial':
            case 'vra:placeOfCreation':
            case 'vra:placeOfRepository':
            case 'vra:placeOfSite':
              let fieldidprefix
              switch (key) {
                case 'dcterms:spatial':
                  fieldidprefix = 'spatial'
                  break
                case 'vra:placeOfCreation':
                  fieldidprefix = 'place-of-creation'
                  break
                case 'vra:placeOfRepository':
                  fieldidprefix = 'place-of-repository'
                  break
                case 'vra:placeOfSite':
                  fieldidprefix = 'place-of-site'
                  break
              }
              if (((obj['@type'] === 'schema:Place') || (obj['@type'] === 'schema:AdministrativeArea')) && !(obj['skos:exactMatch'])) {
                // freetext
                f = fields.getField(fieldidprefix + '-text')
                f.type = obj['@type']
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                  f.language = pl['@language'] ? pl['@language'] : 'eng'
                }
                components.push(f)
              } else {
                if (((obj['@type'] === 'schema:Place') || (obj['@type'] === 'schema:AdministrativeArea')) && obj['skos:exactMatch']) {
                  f = fields.getField('spatial-readonly')
                  if (obj['skos:exactMatch']) {
                    for (let v of obj['skos:exactMatch']) {
                      f.value = v
                    }
                  }
                  f['skos:prefLabel'] = obj['skos:prefLabel']
                  f['rdfs:label'] = obj['rdfs:label']
                  f.coordinates = obj['schema:geo']
                  f.predicate = key
                  f.type = obj['@type']
                  f.label = key
                  components.push(f)
                  if (f.value.startsWith('http://www.geonames.org') || f.value.startsWith('https://www.geonames.org')) {
                    f = fields.getField(fieldidprefix + '-geonames')
                    f.predicate = key
                    f.type = obj['@type']
                    components.push(f)
                  }
                }
              }
              break

            // dce:format
            case 'dce:format':
              f = fields.getField('dce-format-vocab')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // rdau:P60048
            case 'rdau:P60048':
              f = fields.getField('carrier-type')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // phaidra:levelOfDescription
            case 'phaidra:levelOfDescription':
              f = fields.getField('level-of-description')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // edm:rights
            case 'edm:rights':
              f = fields.getField('license')
              f.vocabulary = 'alllicenses'
              f.value = obj
              components.push(f)
              break

            // dce:rights
            case 'dce:rights':
              f = fields.getField('rights')
              f.value = obj['@value']
              f.language = obj['@language'] ? obj['@language'] : 'eng'
              components.push(f)
              break

            // bf:provisionActivity
            case 'bf:provisionActivity':
              f = fields.getField('bf-publication')
              if (obj['bf:agent']) {
                for (let pub of obj['bf:agent']) {
                  if (pub['skos:exactMatch']) {
                    for (let id of pub['skos:exactMatch']) {
                      if (id.startsWith('https://pid.phaidra.org/')) {
                        f.publisherType = 'select'
                        f.publisherOrgUnit = id
                      } else {
                        f.publisherType = 'other'
                        if (pub['schema:name']) {
                          for (let name of pub['schema:name']) {
                            f.publisherName = name['@value']
                          }
                        }
                      }
                    }
                  } else {
                    if (pub['schema:name']) {
                      f.publisherType = 'other'
                      if (pub['schema:name']) {
                        for (let name of pub['schema:name']) {
                          f.publisherName = name['@value']
                        }
                      }
                    }
                  }
                }
              }
              if (obj['bf:place']) {
                for (let pl of obj['bf:place']) {
                  if (pl['skos:prefLabel']) {
                    for (let pllab of pl['skos:prefLabel']) {
                      f.publishingPlace = pllab['@value']
                    }
                  }
                }
              }
              if (obj['bf:date']) {
                for (let pdate of obj['bf:date']) {
                  f.publishingDate = pdate
                }
              }
              components.push(f)
              break

            // citation
            case 'cito:cites':
            case 'cito:isCitedBy':
            case 'cito:citesAsDataSource':
              f = fields.getField('citation')
              f.type = key
              for (let prefLabel of obj['skos:prefLabel']) {
                f.citation = prefLabel['@value']
                f.citationLanguage = prefLabel['@language'] ? prefLabel['@language'] : ''
              }
              for (let em of obj['skos:exactMatch']) {
                f.identifier = em
              }
              components.push(f)
              break

            case 'bf:instanceOf':
              f = fields.getField('instance-of')
              if (obj['dce:title']) {
                for (let t of obj['dce:title']) {
                  if (t['bf:mainTitle']) {
                    for (let mt of t['bf:mainTitle']) {
                      if (mt['@value']) {
                        f.title = mt['@value']
                      }
                      if (mt['@language']) {
                        f.titleLanguage = mt['@language']
                      }
                    }
                    if (t['bf:subtitle']) {
                      for (let st of t['bf:subtitle']) {
                        if (st['@value']) {
                          f.subtitle = st['@value']
                        }
                      }
                    }
                  }
                }
              }
              if (obj['skos:exactMatch']) {
                for (let id of obj['skos:exactMatch']) {
                  f.identifierType = id['@type']
                  f.identifierText = id['@value']
                }
              }
              components.push(f)
              break

            // rdau:P60227
            case 'rdau:P60227':
              f = fields.getField('movieadaptation')
              if (obj['dce:title']) {
                for (let t of obj['dce:title']) {
                  if (t['bf:mainTitle']) {
                    for (let mt of t['bf:mainTitle']) {
                      if (mt['@value']) {
                        f.title = mt['@value']
                      }
                      if (mt['@language']) {
                        f.titleLanguage = mt['@language']
                      }
                    }
                    if (t['bf:subtitle']) {
                      for (let st of t['bf:subtitle']) {
                        if (st['@value']) {
                          f.subtitle = st['@value']
                        }
                      }
                    }
                  }
                }
              }
              for (let [pred, o] of Object.entries(obj)) {
                if (pred.startsWith('role')) {
                  for (let role of o) {
                    if (role['@type'] === 'schema:Person') {
                      f.role = pred
                      if (role['schema:name']) {
                        for (let name of role['schema:name']) {
                          f.name = name['@value']
                          f.showname = true
                        }
                      }
                      if (role['schema:familyName']) {
                        for (let lastname of role['schema:familyName']) {
                          f.lastname = lastname['@value']
                        }
                      }
                      if (role['schema:givenName']) {
                        for (let firstname of role['schema:givenName']) {
                          f.firstname = firstname['@value']
                        }
                      }
                    }
                  }
                }
              }
              components.push(f)
              break

            // frapo:hasFundingAgency
            case 'frapo:hasFundingAgency':
              if (obj['@type'] === 'frapo:FundingAgency') {
                f = fields.getField('funder')
                if (obj['skos:prefLabel']) {
                  for (let pl of obj['skos:prefLabel']) {
                    f.name = pl['@value']
                    f.nameLanguage = pl['@language'] ? pl['@language'] : 'eng'
                  }
                }
                if (obj['skos:exactMatch']) {
                  for (let v of obj['skos:exactMatch']) {
                    if (v['@value']) {
                      obj.identifierType = v['@type']
                      obj.identifier = v['@value']
                    } else {
                      obj.identifier = v
                    }
                  }
                }
                components.push(f)
              }
              break

            // frapo:isOutputOf
            case 'frapo:isOutputOf':
              if (obj['@type'] === 'foaf:Project') {
                f = fields.getField('project')
                if (obj['skos:prefLabel']) {
                  for (let pl of obj['skos:prefLabel']) {
                    f.name = pl['@value']
                    f.nameLanguage = pl['@language'] ? pl['@language'] : 'eng'
                  }
                }
                if (obj['frapo:hasAcronym']) {
                  for (let ac of obj['frapo:hasAcronym']) {
                    f.acronym = ac
                  }
                }
                if (obj['rdfs:comment']) {
                  for (let c of obj['rdfs:comment']) {
                    f.description = c['@value']
                    f.descriptionLanguage = c['@language'] ? c['@language'] : 'eng'
                  }
                }
                if (obj['frapo:hasProjectIdentifier']) {
                  for (let v of obj['frapo:hasProjectIdentifier']) {
                    f.code = v
                  }
                }
                if (obj['skos:exactMatch']) {
                  for (let v of obj['skos:exactMatch']) {
                    if (v['@value']) {
                      f.identifierType = v['@type']
                      f.identifier = v['@value']
                    } else {
                      f.identifier = v
                    }
                  }
                }
                if (obj['foaf:homepage']) {
                  for (let hp of obj['foaf:homepage']) {
                    f.homepage = hp
                  }
                }
                if (obj['frapo:hasStartDate']) {
                  for (let sd of obj['frapo:hasStartDate']) {
                    f.dateFrom = sd
                  }
                }
                if (obj['frapo:hasEndDate']) {
                  for (let ed of obj['frapo:hasEndDate']) {
                    f.dateTo = ed
                  }
                }
                if (obj['frapo:hasFundingAgency']) {
                  for (let funder of obj['frapo:hasFundingAgency']) {
                    if (funder['skos:prefLabel']) {
                      for (let pl of funder['skos:prefLabel']) {
                        f.funderName = pl['@value']
                        f.funderNameLanguage = pl['@language'] ? pl['@language'] : 'eng'
                      }
                    }
                    if (funder['skos:exactMatch']) {
                      for (let v of funder['skos:exactMatch']) {
                        if (v['@value']) {
                          f.funderIdentifierType = v['@type']
                          f.funderIdentifier = v['@value']
                        } else {
                          f.funderIdentifier = v
                        }
                      }
                    }
                  }
                }
                components.push(f)
              } else {
                if (obj['@type'] === 'aiiso:Programme') {
                  let isSelect = false
                  let id = ''
                  if (obj['skos:exactMatch']) {
                    for (let em of obj['skos:exactMatch']) {
                      id = em
                      // preffer vocabulary passed via param, since when this runs in UI
                      // the vocabularies might habe been updated dynamically from config
                      if (!vocabularies) {
                        // if not passed, use the static one imported from vocabulary store js file
                        vocabularies = vocabularystore.state.vocabularies
                      }
                      if (vocabularies) {
                        // if the identifier comes from a $store vocabulary, create selectbox
                        Object.entries(vocabularies).forEach(([vocId, vocab]) => {
                          if (vocId === 'studyplans') {
                            for (let term of vocab.terms) {
                              if (em === term['@id']) {
                                isSelect = true
                              }
                            }
                          }
                        })
                      }
                    }
                  }
                  if (isSelect) {
                    f = fields.getField('study-plan-select')
                    f.value = id
                    components.push(f)
                  } else {
                    f = fields.getField('study-plan')
                    if (obj['skos:prefLabel']) {
                      for (let pl of obj['skos:prefLabel']) {
                        f.name = pl['@value']
                        f.nameLanguage = pl['@language'] ? pl['@language'] : 'eng'
                      }
                    }
                    if (obj['skos:notation']) {
                      for (let n of obj['skos:notation']) {
                        f.notation = n
                      }
                    }
                    if (obj['skos:exactMatch']) {
                      for (let n of obj['skos:exactMatch']) {
                        f.identifier = n
                      }
                    }
                    components.push(f)
                  }
                }
              }
              break

            // ebucore:hasRelatedEvent'
            case 'ebucore:hasRelatedEvent':
              if (obj['@type'] === 'ebucore:Event') {
                f = fields.getField('event')
                if (obj['skos:prefLabel']) {
                  for (let pl of obj['skos:prefLabel']) {
                    f.name = pl['@value']
                    f.nameLanguage = pl['@language'] ? pl['@language'] : 'eng'
                  }
                }
                if (obj['rdfs:comment']) {
                  for (let c of obj['rdfs:comment']) {
                    f.description = c['@value']
                    f.descriptionLanguage = c['@language'] ? c['@language'] : 'eng'
                  }
                }
                if (obj['ebucore:eventStartDateTime']) {
                  for (let sd of obj['ebucore:eventStartDateTime']) {
                    f.dateFrom = sd
                  }
                }
                if (obj['ebucore:eventEndDateTime']) {
                  for (let ed of obj['ebucore:eventEndDateTime']) {
                    f.dateTo = ed
                  }
                }
                if (obj['ebucore:hasEventRelatedLocation']) {
                  for (let pl of obj['ebucore:hasEventRelatedLocation']) {
                    if (pl['skos:prefLabel']) {
                      for (let pllab of pl['skos:prefLabel']) {
                        f.place = pllab['@value']
                      }
                    }
                  }
                }
                if (obj['skos:exactMatch']) {
                  for (let id of obj['skos:exactMatch']) {
                    f.identifierType = id['@type']
                    f.identifierText = id['@value']
                  }
                }
                components.push(f)
              }
              break

            // rdax:P00009
            case 'rdax:P00009':
              f = fields.getField('association')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // dcterms:provenance
            case 'dcterms:provenance':
              if (obj['@type'] === 'dcterms:ProvenanceStatement') {
                f = fields.getField('provenance')
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                  f.language = pl['@language'] ? pl['@language'] : 'eng'
                }
                components.push(f)
              }
              break

            // schema:numberOfPages
            case 'schema:numberOfPages':
              f = fields.getField('number-of-pages')
              f.label = key
              f.value = obj
              components.push(f)
              break

            // bf:soundCharacteristic
            case 'bf:soundCharacteristic':
              f = fields.getField('sound-characteristic')
              f.label = key
              f.value = obj
              components.push(f)
              break

            // bf:supplementaryContent
            case 'bf:supplementaryContent':
              f = fields.getField('supplementary-content')
              for (let pl of obj['skos:prefLabel']) {
                f.value = pl['@value']
                f.language = pl['@language'] ? pl['@language'] : 'eng'
              }
              components.push(f)
              break

            // bf:awards
            case 'bf:awards':
              f = fields.getField('award')
              for (let pl of obj['skos:prefLabel']) {
                f.value = pl['@value']
                f.language = pl['@language'] ? pl['@language'] : 'eng'
              }
              components.push(f)
              break

            // rdau:P60059
            case 'rdau:P60059':
              f = fields.getField('regional-encoding')
              for (let em of obj['skos:exactMatch']) {
                f.value = em
              }
              components.push(f)
              break

            // ebucore:filename
            case 'ebucore:filename':
              f = fields.getField('filename')
              f.predicate = key
              f.label = key
              f.value = obj
              components.push(f)
              break

            // ebucore:hasMimeType
            case 'ebucore:hasMimeType':
              f = fields.getField('mime-type')
              f.value = obj
              components.push(f)
              break

            // opaque:cco_accessionNumber
            case 'opaque:cco_accessionNumber':
              f = fields.getField('accession-number')
              f.value = obj
              components.push(f)
              break

            // bf:shelfMark
            case 'bf:shelfMark':
              f = fields.getField('shelf-mark')
              f.value = obj
              components.push(f)
              break

            // bf:physicalLocation
            case 'bf:physicalLocation':
              f = fields.getField('physical-location')
              f.value = obj['@value']
              f.language = obj['@language'] ? obj['@language'] : 'eng'
              components.push(f)
              break

            // rdau:P60550
            case 'rdau:P60550':
              f = fields.getField('extent')
              f.value = obj['@value']
              f.language = obj['@language'] ? obj['@language'] : 'eng'
              components.push(f)
              break

            // bibo:issue
            case 'bibo:issue':
              f = fields.getField('issue')
              f.value = obj
              components.push(f)
              break

            // bibo:volume
            case 'bibo:volume':
              f = fields.getField('volume')
              f.value = obj
              components.push(f)
              break

            // vra:hasInscription
            case 'vra:hasInscription':
              if (obj['@type'] === 'vra:Inscription') {
                f = fields.getField('inscription')
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                  f.language = pl['@language'] ? pl['@language'] : 'eng'
                }
                components.push(f)
              }
              break

            // bf:scale
            case 'bf:scale':
              if (obj['@type'] === 'bf:Scale') {
                f = fields.getField('scale')
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                }
                components.push(f)
              }
              break

            // rdfs:seeAlso
            case 'rdfs:seeAlso':
              if (obj['@type'] === 'schema:URL') {
                f = fields.getField('see-also')
                if (obj['skos:prefLabel']) {
                  for (let pl of obj['skos:prefLabel']) {
                    f.title = pl['@value']
                    f.titleLanguage = pl['@language'] ? pl['@language'] : 'eng'
                  }
                }
                if (obj['schema:url']) {
                  for (let url of obj['schema:url']) {
                    f.url = url
                  }
                }
                components.push(f)
              }
              break

            // vra:material
            case 'vra:material':
              if (obj['@type'] === 'vra:Material' && !(obj['skos:exactMatch'])) {
                f = fields.getField('material-text')
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                  f.language = pl['@language'] ? pl['@language'] : 'eng'
                }
                components.push(f)
              } else {
                // vra:material - vocab
                if (obj['@type'] === 'vra:Material' && (obj['skos:exactMatch'])) {
                  f = fields.getField('material-vocab')
                  for (let em of obj['skos:exactMatch']) {
                    f.value = em
                  }
                  components.push(f)
                }
              }
              break

            // vra:hasTechnique
            case 'vra:hasTechnique':
              if (obj['@type'] === 'vra:Technique' && !(obj['skos:exactMatch'])) {
                f = fields.getField('technique-text')
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                  f.language = pl['@language'] ? pl['@language'] : 'eng'
                }
                components.push(f)
              } else {
                // vra:hasTechnique - vocab
                if (obj['@type'] === 'vra:Technique' && (obj['skos:exactMatch'])) {
                  f = fields.getField('technique-vocab')
                  for (let em of obj['skos:exactMatch']) {
                    f.value = em
                  }
                  components.push(f)
                }
              }
              break

            // dcterms:audience
            case 'dcterms:audience':
              if (obj['@type'] === 'dcterms:audience' && !(obj['skos:exactMatch'])) {
                f = fields.getField('audience')
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                  f.language = pl['@language'] ? pl['@language'] : 'eng'
                }
                components.push(f)
              } else {
                // dcterms:audience - select
                if (obj['@type'] === 'dcterms:audience' && (obj['skos:exactMatch'])) {
                  f = fields.getField('audience-vocab')
                  for (let em of obj['skos:exactMatch']) {
                    f.value = em
                  }
                  components.push(f)
                }
              }
              break

            // schema:width
            case 'schema:width':
              if (obj['@type'] === 'schema:QuantitativeValue') {
                f = fields.getField('width')
                for (let c of obj['schema:unitCode']) {
                  f.unit = c
                }
                for (let v of obj['schema:value']) {
                  f.value = v
                }
                components.push(f)
              }
              break

            // schema:height
            case 'schema:height':
              if (obj['@type'] === 'schema:QuantitativeValue') {
                f = fields.getField('height')
                for (let c of obj['schema:unitCode']) {
                  f.unit = c
                }
                for (let v of obj['schema:value']) {
                  f.value = v
                }
                components.push(f)
              }
              break

            // schema:depth
            case 'schema:depth':
              if (obj['@type'] === 'schema:QuantitativeValue') {
                f = fields.getField('depth')
                for (let c of obj['schema:unitCode']) {
                  f.unit = c
                }
                for (let v of obj['schema:value']) {
                  f.value = v
                }
                components.push(f)
              }
              break

            // vra:diameter
            case 'vra:diameter':
              if (obj['@type'] === 'schema:QuantitativeValue') {
                f = fields.getField('diameter')
                for (let c of obj['schema:unitCode']) {
                  f.unit = c
                }
                for (let v of obj['schema:value']) {
                  f.value = v
                }
                components.push(f)
              }
              break

            // dates
            case 'dcterms:date':
            case 'dcterms:created':
            case 'dcterms:modified':
            case 'dcterms:available':
            case 'dcterms:issued':
            case 'dcterms:valid':
            case 'dcterms:dateAccepted':
            case 'dcterms:dateCopyrighted':
            case 'dcterms:dateSubmitted':
            case 'rdau:P60071':
            case 'phaidra:dateAccessioned':
            case 'phaidra:dateApprobation':
              if (typeof obj === 'string') {
                f = fields.getField('date-edtf')
                f.type = key
                f.value = obj
                components.push(f)
              } else {
                f = fields.getField('date-edmtimespan')
                f.type = key
                for (let pl of obj['skos:prefLabel']) {
                  f.value = pl['@value']
                  f.language = pl['@language'] ? pl['@language'] : ''
                }
                if (obj['skos:exactMatch']) {
                  for (let id of obj['skos:exactMatch']) {
                    f.identifierType = id['@type']
                    f.identifier = id['@value']
                  }
                }
                components.push(f)
              }
              break

            // schema:duration
            case 'schema:duration':
              f = fields.getField('duration')
              f.value = obj
              components.push(f)
              break

            // phaidra:systemTag
            case 'phaidra:systemTag':
              f = fields.getField('system-tag')
              f.value = obj
              components.push(f)
              break

            // pages, handled insisde rdau:P60193 or rdau:P60101
            case 'schema:pageStart':
            case 'schema:pageEnd':
              // noop
              break

            default:

              // role
              if (key.startsWith('role')) {
                let role = obj
                if (options && options['role'] && options['role']['component'] && (options['role']['component'] === 'p-entity')) {
                  f = fields.getField('role')
                } else {
                  f = fields.getField('role-extended')
                }
                f.role = key
                f.type = role['@type']
                if (role['@type'] === 'schema:Person') {
                  if (role['schema:name']) {
                    for (let name of role['schema:name']) {
                      f.name = name['@value']
                      f.showname = true
                    }
                  }
                  if (role['schema:familyName']) {
                    for (let lastname of role['schema:familyName']) {
                      f.lastname = lastname['@value']
                    }
                  }
                  if (role['schema:givenName']) {
                    for (let firstname of role['schema:givenName']) {
                      f.firstname = firstname['@value']
                    }
                  }
                  if (role['skos:exactMatch']) {
                    for (let id of role['skos:exactMatch']) {
                      f.identifierType = id['@type']
                      f.identifierText = id['@value']
                    }
                  }
                  if (role['schema:affiliation']) {
                    for (let af of role['schema:affiliation']) {
                      if (af['skos:exactMatch']) {
                        for (let id of af['skos:exactMatch']) {
                          if (id.startsWith('https://pid.phaidra.org/')) {
                            f.affiliationType = 'select'
                            f.affiliation = id
                          } else {
                            if (id.startsWith('https://ror.org/')) {
                              f.affiliationType = 'ror'
                              f.affiliation = id
                              for (let name of af['schema:name']) {
                                f.affiliationRorName = name['@value']
                              }
                            } else {
                              f.affiliationType = 'other'
                              if (af['schema:name']) {
                                for (let name of af['schema:name']) {
                                  f.affiliationText = name['@value']
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (af['schema:name']) {
                          f.affiliationType = 'other'
                          for (let name of af['schema:name']) {
                            f.affiliationText = name['@value']
                          }
                        }
                      }
                    }
                  }
                }
                if (role['@type'] === 'schema:Organization') {
                  if (role['skos:exactMatch']) {
                    for (let id of role['skos:exactMatch']) {
                      if (typeof id !== 'object') {
                        if (id.startsWith('https://pid.phaidra.org/')) {
                          f.organizationType = 'select'
                          f.organization = id
                        } else {
                          if (id.startsWith('https://ror.org/')) {
                            f.organizationType = 'ror'
                            f.organization = id
                            for (let name of role['schema:name']) {
                              f.organizationRorName = name['@value']
                            }
                          } else {
                            f.organizationType = 'other'
                            f.identifierText = id
                            if (role['schema:name']) {
                              for (let name of role['schema:name']) {
                                f.organizationText = name['@value']
                              }
                            }
                          }
                        }
                      } else {
                        f.organizationType = 'other'
                        f.identifierType = id['@type']
                        f.identifierText = id['@value']
                        if (role['schema:name']) {
                          for (let name of role['schema:name']) {
                            f.organizationText = name['@value']
                          }
                        }
                      }
                    }
                  } else {
                    if (role['schema:name']) {
                      for (let name of role['schema:name']) {
                        f.organizationType = 'other'
                        f.organizationText = name['@value']
                      }
                    }
                  }
                }
                components.push(f)
              } else {
                // unknown predicate
                f = fields.getField('unknown')
                f.jsonld = obj
                f.predicate = key
                f.label = key
                components.push(f)
              }
              break
          }
        }
      }
    })

    return components
  },
  getOrderedComponents: function (components) {
    var predicateOrder = fields.getPredicateOrder()
    var ordered = []
    var i
    var j
    for (i = 0; i < predicateOrder.length; i++) {
      for (j = 0; j < components.length; j++) {
        if (components[j].predicate === predicateOrder[i]) {
          ordered.push(components[j])
        }
      }
    }
    for (j = 0; j < components.length; j++) {
      if (components[j].component === 'p-unknown') {
        ordered.push(components[j])
      }
    }
    return ordered
  },
  json2form: function (jsonld, options, vocabularies) {
    var levels = {
      digital: {
        components: []
      }
    }

    levels.digital.components = this.json2components(jsonld, options, vocabularies)

    Object.entries(jsonld).forEach(([key, value]) => {
      if (key === 'dcterms:subject') {
        levels['subject'] = []
        for (let v of value) {
          if (v['@type'] === 'phaidra:Subject') {
            var subcomp = this.json2components(v, options, vocabularies)
            if (subcomp.length > 0) {
              levels.subject.push({ components: subcomp })
            }
          }
        }
      }
    })

    var form = {
      sections: []
    }

    var digitalFields = this.getOrderedComponents(levels.digital.components)

    form.sections.push(
      {
        title: 'General metadata',
        id: 1,
        fields: digitalFields
      }
    )

    if (levels['subject']) {
      for (let i = 0; i < levels.subject.length; i++) {
        var subjectFields = this.getOrderedComponents(levels.subject[i].components)
        form.sections.push(
          {
            title: 'SUBJECT_SECTION',
            type: 'phaidra:Subject',
            id: 'subject-' + i,
            fields: subjectFields
          }
        )
      }
    }

    return form
  },
  get_json_dce_title (type, title, subtitle, language) {
    var h = {
      '@type': type,
      'bf:mainTitle': [
        {
          '@value': title
        }
      ]
    }
    if (language) {
      h['bf:mainTitle'][0]['@language'] = language
    }
    if (subtitle) {
      h['bf:subtitle'] = [
        {
          '@value': subtitle
        }
      ]
      if (language) {
        h['bf:subtitle'][0]['@language'] = language
      }
    }
    return h
  },
  get_json_object (preflabels, rdfslabels, type, identifiers) {
    var h = {}

    if (type) {
      h['@type'] = type
    }

    if (preflabels) {
      if (preflabels.length > 0) {
        h['skos:prefLabel'] = []
        for (let pl of preflabels) {
          if (pl.hasOwnProperty('@value')) {
            if (pl['@value']) {
              let l = {
                '@value': pl['@value']
              }
              if (pl.hasOwnProperty('@language')) {
                if (pl['@language']) {
                  l['@language'] = pl['@language']
                }
              }
              h['skos:prefLabel'].push(l)
            }
          }
        }
      }
    }

    if (rdfslabels) {
      if (rdfslabels.length > 0) {
        h['rdfs:label'] = []
        for (var i = 0; i < rdfslabels.length; i++) {
          h['rdfs:label'].push(rdfslabels[i])
        }
      }
    }

    if (identifiers) {
      if (identifiers.length > 0) {
        h['skos:exactMatch'] = identifiers
      }
    }
    return h
  },
  get_json_concept (preflabels, rdfslabels, type, identifiers, notations) {
    var h = {}

    if (type) {
      h['@type'] = type
    }

    if (preflabels) {
      if (preflabels.length > 0) {
        h['skos:prefLabel'] = []
        for (var j = 0; j < preflabels.length; j++) {
          h['skos:prefLabel'].push(preflabels[j])
        }
      }
    }

    if (rdfslabels) {
      if (rdfslabels.length > 0) {
        h['rdfs:label'] = []
        for (var i = 0; i < rdfslabels.length; i++) {
          h['rdfs:label'].push(rdfslabels[i])
        }
      }
    }

    if (identifiers) {
      if (identifiers.length > 0) {
        h['skos:exactMatch'] = identifiers
      }
    }

    if (notations) {
      if (notations.length > 0) {
        h['skos:notation'] = notations
      }
    }
    return h
  },
  get_json_spatial (rdfslabels, preflabels, coordinates, type, identifiers) {
    var h = {}

    if (type) {
      h['@type'] = type
    }

    if (preflabels) {
      if (preflabels.length > 0) {
        h['skos:prefLabel'] = []
        for (var i = 0; i < preflabels.length; i++) {
          h['skos:prefLabel'].push(preflabels[i])
        }
      }
    }

    if (rdfslabels) {
      if (rdfslabels.length > 0) {
        h['rdfs:label'] = []
        for (var j = 0; j < rdfslabels.length; j++) {
          h['rdfs:label'].push(rdfslabels[j])
        }
      }
    }

    if (identifiers) {
      if (identifiers.length > 0) {
        h['skos:exactMatch'] = identifiers
      }
    }

    if (coordinates) {
      if (coordinates.length > 0) {
        h['schema:geo'] = coordinates
      }
    }

    return h
  },
  get_json_valueobject (value, language) {
    var h = {
      '@value': value
    }

    if (language) {
      h['@language'] = language
    }

    return h
  },
  get_json_quantitativevalue (value, unitCode) {
    var h = {
      '@type': 'schema:QuantitativeValue',
      'schema:unitCode': [
        unitCode
      ],
      'schema:value': [
        value
      ]
    }

    return h
  },
  get_json_role (f) {
    var h = {
      '@type': f.type
    }
    if (f.type === 'schema:Person') {
      if (f.firstname) {
        h['schema:givenName'] = [
          {
            '@value': f.firstname
          }
        ]
      }
      if (f.lastname) {
        h['schema:familyName'] = [
          {
            '@value': f.lastname
          }
        ]
      }
      if (f.name) {
        h['schema:name'] = [
          {
            '@value': f.name
          }
        ]
      }
      if (f.identifierText) {
        h['skos:exactMatch'] = [
          {
            '@type': f.identifierType,
            '@value': f.identifierText
          }
        ]
      }
      if (f.affiliation || f.affiliationText) {
        let a = {
          '@type': 'schema:Organization'
        }
        if (f.affiliationType === 'select') {
          a['schema:name'] = f.affiliationSelectedName
          a['skos:exactMatch'] = [ f.affiliation ]
        }
        if (f.affiliationType === 'ror') {
          a['schema:name'] = f.affiliationSelectedName
          a['skos:exactMatch'] = [ f.affiliation ]
        }
        if (f.affiliationType === 'other') {
          a['schema:name'] = [
            {
              '@value': f.affiliationText
            }
          ]
        }
        if (
          (f.affiliationType === 'select' && f.affiliationSelectedName) ||
          (f.affiliationType === 'ror' && f.affiliationSelectedName) ||
          (f.affiliationType === 'other' && f.affiliationText)
        ) {
          h['schema:affiliation'] = [ a ]
        }
      }
    }
    if (f.type === 'schema:Organization') {
      if (f.organizationType === 'select') {
        h['schema:name'] = f.organizationSelectedName
        h['skos:exactMatch'] = [ f.organization ]
      } else {
        if (f.organizationType === 'ror') {
          h['schema:name'] = f.organizationSelectedName
          h['skos:exactMatch'] = [ f.organization ]
        } else {
          if (f.organizationText) {
            h['schema:name'] = [
              {
                '@value': f.organizationText
              }
            ]
          }
          if (f.identifierText) {
            if (f.identifierType) {
              h['skos:exactMatch'] = [ { '@type': f.identifierType, '@value': f.identifierText } ]
            } else {
              h['skos:exactMatch'] = [ f.identifierText ]
            }
          }
        }
      }
    }
    return h
  },
  get_json_event (e) {
    var h = {
      '@type': 'ebucore:Event'
    }
    if (e.name) {
      h['skos:prefLabel'] = [
        {
          '@value': e.name
        }
      ]
      if (e.nameLanguage) {
        h['skos:prefLabel'][0]['@language'] = e.nameLanguage
      }
    }
    if (e.description) {
      h['rdfs:comment'] = [
        {
          '@value': e.description
        }
      ]
      if (e.descriptionLanguage) {
        h['rdfs:comment'][0]['@language'] = e.descriptionLanguage
      }
    }
    if (e.dateFrom) {
      h['ebucore:eventStartDateTime'] = [ e.dateFrom ]
    }
    if (e.dateTo) {
      h['ebucore:eventEndDateTime'] = [ e.dateTo ]
    }
    if (e.place) {
      h['ebucore:hasEventRelatedLocation'] = [
        {
          '@type': 'schema:Place',
          'skos:prefLabel': [
            {
              '@value': e.place
            }
          ]
        }
      ]
    }
    if (e.identifierText) {
      if (e.identifierType) {
        h['skos:exactMatch'] = [ { '@type': e.identifierType, '@value': e.identifierText } ]
      } else {
        h['skos:exactMatch'] = [ e.identifierText ]
      }
    }
    return h
  },
  get_json_project (name, acronym, nameLanguage, description, descriptionLanguage, code, identifier, identifierType, homepage, dateFrom, dateTo, funderObject) {
    var h = {
      '@type': 'foaf:Project'
    }
    if (name) {
      h['skos:prefLabel'] = [
        {
          '@value': name
        }
      ]
      if (nameLanguage) {
        h['skos:prefLabel'][0]['@language'] = nameLanguage
      }
    }
    if (description) {
      h['rdfs:comment'] = [
        {
          '@value': description
        }
      ]
      if (descriptionLanguage) {
        h['rdfs:comment'][0]['@language'] = descriptionLanguage
      }
    }
    if (code) {
      h['frapo:hasProjectIdentifier'] = [ code ]
    }
    if (identifier) {
      if (identifierType) {
        h['skos:exactMatch'] = [ { '@type': identifierType, '@value': identifier } ]
      } else {
        h['skos:exactMatch'] = [ identifier ]
      }
    }
    if (dateFrom) {
      h['frapo:hasStartDate'] = [ dateFrom ]
    }
    if (dateTo) {
      h['frapo:hasEndDate'] = [ dateTo ]
    }
    if (acronym) {
      h['frapo:hasAcronym'] = [
        acronym
      ]
    }
    if (homepage) {
      h['foaf:homepage'] = [
        homepage
      ]
    }
    if (funderObject) {
      h['frapo:hasFundingAgency'] = [
        funderObject
      ]
    }
    return h
  },
  get_json_series (type, title, titleLanguage, volume, issue, issued, issn, identifier, idnetifierType) {
    var h = {
      '@type': type
    }
    if (title) {
      let tit = {
        '@type': 'bf:Title',
        'bf:mainTitle': [
          {
            '@value': title
          }
        ]
      }
      if (titleLanguage) {
        tit['bf:mainTitle'][0]['@language'] = titleLanguage
      }
      h['dce:title'] = [ tit ]
    }
    if (volume) {
      h['bibo:volume'] = [ volume ]
    }
    if (issue) {
      h['bibo:issue'] = [ issue ]
    }
    if (issued) {
      h['dcterms:issued'] = [ issued ]
    }
    if (issn) {
      h['ids:issn'] = [ issn ]
    }
    if (identifier) {
      h['skos:exactMatch'] = [
        {
          '@type': idnetifierType,
          '@value': identifier
        }
      ]
    }
    return h
  },
  get_json_contained_in (f) {
    var h = {
      '@type': f.type
    }
    if (f.title) {
      let tit = {
        '@type': 'bf:Title',
        'bf:mainTitle': [
          {
            '@value': f.title
          }
        ]
      }
      if (f.titleLanguage) {
        tit['bf:mainTitle'][0]['@language'] = f.titleLanguage
      }
      if (f.subtitle) {
        tit['bf:subtitle'] = [
          {
            '@value': f.subtitle
          }
        ]
        if (f.titleLanguage) {
          tit['bf:subtitle'][0]['@language'] = f.titleLanguage
        }
      }
      h['dce:title'] = [ tit ]
    }
    if (f.roles) {
      if (f.roles.length > 0) {
        for (let role of f.roles) {
          if (role.role && (role.firstname || role.lastname || role.name)) {
            let entity = {
              '@type': 'schema:Person'
            }
            if (role.name) {
              entity['schema:name'] = [
                {
                  '@value': role.name
                }
              ]
            }
            if (role.firstname) {
              entity['schema:givenName'] = [
                {
                  '@value': role.firstname
                }
              ]
            }
            if (role.lastname) {
              entity['schema:familyName'] = [
                {
                  '@value': role.lastname
                }
              ]
            }
            if (!h[role.role]) {
              h[role.role] = []
            }
            h[role.role].push(entity)
          }
        }
      }
    }
    if (f.isbn) {
      h['ids:isbn'] = [ f.isbn ]
    }
    if (f.identifier) {
      if (f.identifierType) {
        h['skos:exactMatch'] = [ { '@type': f.identifierType, '@value': f.identifier } ]
      } else {
        h['skos:exactMatch'] = [ f.identifier ]
      }
    }
    if (f.series) {
      if (f.series.length > 0) {
        h['rdau:P60193'] = []
        for (let s of f.series) {
          if (s.seriesTitle || s.seriesVolume || s.seriesIssue || s.seriesIssued || s.seriesIssn || s.seriesIdentifier) {
            let series = {
              '@type': s.seriesType
            }
            if (s.seriesTitle) {
              let tit = {
                '@type': 'bf:Title',
                'bf:mainTitle': [
                  {
                    '@value': s.seriesTitle
                  }
                ]
              }
              if (s.seriesTitleLanguage) {
                tit['bf:mainTitle'][0]['@language'] = s.seriesTitleLanguage
              }
              series['dce:title'] = [ tit ]
            }
            if (s.seriesVolume) {
              series['bibo:volume'] = [ s.seriesVolume ]
            }
            if (s.seriesIssue) {
              series['bibo:issue'] = [ s.seriesIssue ]
            }
            if (s.seriesIssued) {
              series['dcterms:issued'] = [ s.seriesIssued ]
            }
            if (s.seriesIssn) {
              series['ids:issn'] = [ s.seriesIssn ]
            }
            if (s.seriesIdentifier) {
              series['skos:exactMatch'] = [
                {
                  '@type': s.seriesIdentifierType,
                  '@value': s.seriesIdentifier
                }
              ]
            }
            h['rdau:P60193'].push(series)
          }
        }
      }
    }
    if (f.publisherName || f.publishingPlace || f.publishingDate || f.publisherOrgUnit) {
      h['bf:provisionActivity'] = [ this.get_json_bf_publication(f) ]
    }
    return h
  },
  get_json_instance_of (i) {
    var h = {
      '@type': i.type
    }
    if (i.title) {
      let tit = {
        '@type': 'bf:Title',
        'bf:mainTitle': [
          {
            '@value': i.title
          }
        ]
      }
      if (i.titleLanguage) {
        tit['bf:mainTitle'][0]['@language'] = i.titleLanguage
      }
      if (i.subtitle) {
        tit['bf:subtitle'] = [
          {
            '@value': i.subtitle
          }
        ]
        if (i.titleLanguage) {
          tit['bf:subtitle'][0]['@language'] = i.titleLanguage
        }
      }
      h['dce:title'] = [ tit ]
    }
    if (i.identifierText) {
      if (i.identifierType) {
        h['skos:exactMatch'] = [ { '@type': i.identifierType, '@value': i.identifierText } ]
      } else {
        h['skos:exactMatch'] = [ i.identifierText ]
      }
    }
    return h
  },
  get_json_adaptation (type, title, subtitle, titleLanguage, role, name, firstname, lastname) {
    var h = {
      '@type': type
    }
    if (title) {
      let tit = {
        '@type': 'bf:Title',
        'bf:mainTitle': [
          {
            '@value': title
          }
        ]
      }
      if (titleLanguage) {
        tit['bf:mainTitle'][0]['@language'] = titleLanguage
      }
      if (subtitle) {
        tit['bf:subtitle'] = [
          {
            '@value': subtitle
          }
        ]
        if (titleLanguage) {
          tit['bf:subtitle'][0]['@language'] = titleLanguage
        }
      }
      h['dce:title'] = [ tit ]
    }
    if (firstname || lastname || name) {
      let r = {
        '@type': 'schema:Person'
      }
      if (firstname) {
        r['schema:givenName'] = [
          {
            '@value': firstname
          }
        ]
      }
      if (lastname) {
        r['schema:familyName'] = [
          {
            '@value': lastname
          }
        ]
      }
      if (name) {
        r['schema:name'] = [
          {
            '@value': name
          }
        ]
      }
      h[role] = [r]
    }
    return h
  },
  get_json_bf_publication (f) {
    var h = {
      '@type': 'bf:Publication'
    }
    let pa = {
      '@type': 'schema:Organization',
      'schema:name': []
    }
    if (f.publisherType === 'select') {
      pa['schema:name'] = f.publisherSelectedName
      pa['skos:exactMatch'] = [ f.publisherOrgUnit ]
    }
    if (f.publisherType === 'other') {
      pa['schema:name'] = [
        {
          '@value': f.publisherName
        }
      ]
    }
    if (
      (f.publisherType === 'select' && (f.publisherSelectedName || f.publisherOrgUnit)) ||
      (f.publisherType === 'other' && f.publisherName)
    ) {
      h['bf:agent'] = [ pa ]
    }
    if (f.publishingPlace) {
      let pp = {
        '@type': 'schema:Place',
        'skos:prefLabel': [
          {
            '@value': f.publishingPlace
          }
        ]
      }
      h['bf:place'] = [ pp ]
    }
    if (f.publishingDate) {
      h['bf:date'] = [ f.publishingDate ]
    }

    return h
  },
  get_json_study_plan (name, nameLanguage, prefLabels, notations, identifiers) {
    var h = {
      '@type': 'aiiso:Programme'
    }
    if (name) {
      h['skos:prefLabel'] = [
        {
          '@value': name
        }
      ]
      if (nameLanguage) {
        h['skos:prefLabel'][0]['@language'] = nameLanguage
      }
    } else {
      if (prefLabels) {
        if (prefLabels.length > 0) {
          h['skos:prefLabel'] = []
          for (var i = 0; i < prefLabels.length; i++) {
            h['skos:prefLabel'].push(prefLabels[i])
          }
        }
      }
    }
    if (notations) {
      if (notations.length > 0) {
        h['skos:notation'] = notations
      }
    }
    if (identifiers) {
      if (identifiers.length > 0) {
        h['skos:exactMatch'] = identifiers
      }
    }
    return h
  },
  get_json_funder (name, nameLanguage, identifier, identifierType) {
    var h = {
      '@type': 'frapo:FundingAgency'
    }
    if (name) {
      h['skos:prefLabel'] = [
        {
          '@value': name
        }
      ]
      if (nameLanguage) {
        h['skos:prefLabel'][0]['@language'] = nameLanguage
      }
    }
    if (identifier) {
      if (identifierType) {
        h['skos:exactMatch'] = [ { '@type': identifierType, '@value': identifier } ]
      } else {
        h['skos:exactMatch'] = [ identifier ]
      }
    }
    return h
  },
  get_json_see_also (url, title, titleLanguage) {
    var h = {
      '@type': 'schema:URL'
    }
    if (title) {
      h['skos:prefLabel'] = [
        {
          '@value': title
        }
      ]
      if (titleLanguage) {
        h['skos:prefLabel'][0]['@language'] = titleLanguage
      }
    }
    if (url) {
      h['schema:url'] = [ url ]
    }
    return h
  },
  get_json_edm_timespan (value, type, language, identifier, identifierType) {
    var h = {
      '@type': 'edm:TimeSpan'
    }
    if (value) {
      h['skos:prefLabel'] = [
        {
          '@value': value
        }
      ]
      if (language) {
        h['skos:prefLabel'][0]['@language'] = language
      }
    }
    if (identifier) {
      if (identifierType) {
        h['skos:exactMatch'] = [ { '@type': identifierType, '@value': identifier } ]
      } else {
        h['skos:exactMatch'] = [ identifier ]
      }
    }
    return h
  },
  get_json_identifier (type, value) {
    return {
      '@type': type,
      '@value': value
    }
  },
  validate_object (object) {
    if (!object['@type']) {
      // console.error('JSON-LD validation: missing @type attribute', object)
      return false
    }
    return true
  },
  push_object (jsonld, predicate, object) {
    if (this.validate_object(object)) {
      if (!jsonld[predicate]) {
        jsonld[predicate] = []
      }
      jsonld[predicate].push(object)
    }
  },
  push_literal (jsonld, predicate, value) {
    if (!jsonld[predicate]) {
      jsonld[predicate] = []
    }
    jsonld[predicate].push(value)
  },
  push_value (jsonld, predicate, valueobject) {
    if (!jsonld[predicate]) {
      jsonld[predicate] = []
    }
    jsonld[predicate].push(valueobject)
  },
  containerForm2json (formData) {
    var jsonlds = {}
    jsonlds['container'] = {}

    for (var i = 0; i < formData.sections.length; i++) {
      var s = formData.sections[i]
      var jsonldid = 'container'
      if (s.type === 'accessrights') {
        // handled in PIForm
        continue
      }
      if (s.type === 'member') {
        jsonldid = 'member_' + s.id
        jsonlds[jsonldid] = {}
      }
      if (s.type === 'phaidra:Subject') {
        jsonldid = 'subject-' + i
        jsonlds[jsonldid] = {
          '@type': 'phaidra:Subject'
        }
      }
      // this should be more recursive - member can also have subject metadata
      this.fields2json(jsonlds[jsonldid], s)
    }

    Object.keys(jsonlds).forEach(function (key) {
      if (key.startsWith('subject-')) {
        if (Object.keys(jsonlds[key]).length > 1) {
          if (!jsonlds['container']['dcterms:subject']) {
            jsonlds['container']['dcterms:subject'] = []
          }
          jsonlds['container']['dcterms:subject'].push(jsonlds[key])
        }
        delete jsonlds[key]
      }
    })

    return jsonlds
  },
  form2json (formData) {
    var i

    var jsonlds = {}

    for (i = 0; i < formData.sections.length; i++) {
      var s = formData.sections[i]
      var jsonldid
      if (s.type === 'accessrights') {
        // handled in PIForm
        continue
      }
      if (s.type === 'phaidra:Subject') {
        jsonldid = 'subject-' + i
        jsonlds[jsonldid] = {
          '@type': 'phaidra:Subject'
        }
        this.fields2json(jsonlds[jsonldid], s)
      } else {
        this.fields2json(jsonlds, s)
      }
    }

    Object.keys(jsonlds).forEach(function (key) {
      if (key.startsWith('subject-')) {
        if (Object.keys(jsonlds[key]).length > 1) {
          if (!jsonlds['dcterms:subject']) {
            jsonlds['dcterms:subject'] = []
          }
          jsonlds['dcterms:subject'].push(jsonlds[key])
        }
        delete jsonlds[key]
      }
    })
    jsonlds = JSON.parse(JSON.stringify(jsonlds, this.trimStrings))
    return jsonlds
  },
  trimStrings (key, value) {
    if (typeof value === 'string') {
      return value.trim()
    }
    return value
  },
  fields2json (jsonld, formData) {
    for (var j = 0; j < formData.fields.length; j++) {
      var f = formData.fields[j]

      switch (f.predicate) {
        case 'rdam:P30004':
          if (f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_identifier(f.type, f.value))
          }
          break

        case 'dce:title':
          if (f.title) {
            this.push_object(jsonld, f.predicate, this.get_json_dce_title(f.type, f.title, f.subtitle, f.language))
          }
          break

        case 'bf:note':
        case 'bf:tableOfContents':
        case 'bf:scale':
        case 'dcterms:temporal':
          if (f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, f.type))
          }
          break

        case 'dcterms:language':
          if (f.value) {
            if (f.value.startsWith('https://pid.phaidra.org/')) {
              this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, 'skos:Concept', [f.value]))
            } else {
              this.push_literal(jsonld, f.predicate, f.value)
            }
          }
          break

        case 'schema:subtitleLanguage':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          break

        case 'edm:hasType':
          if (f.hasOwnProperty('selectedTerms') && Array.isArray(f.selectedTerms) && (f.selectedTerms.length > 0)) {
            for (let t of f.selectedTerms) {
              this.push_object(jsonld, f.predicate, this.get_json_object(t['skos:prefLabel'], null, 'skos:Concept', [t.value]))
            }
          } else {
            this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, 'skos:Concept', [f.value]))
          }
          break

        case 'dcterms:type':
        case 'schema:genre':
        case 'schema:accessMode':
        case 'schema:accessibilityFeature':
        case 'schema:accessibilityControl':
        case 'schema:accessibilityHazard':
        case 'oaire:version':
        case 'dcterms:accessRights':
        case 'rdau:P60059':
        case 'rdau:P60048':
        case 'phaidra:levelOfDescription':
          if (f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, 'skos:Concept', [f.value]))
          }
          break

        case 'rdax:P00009':
          if (f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, f.type, [f.value]))
          }
          break

        case 'bf:supplementaryContent':
        case 'bf:awards':
        case 'dcterms:audience':
          if (f.value) {
            if (f.component === 'p-select' && f.value) {
              this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, 'skos:Concept', [ f.value ]))
            } else {
              this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, f.type))
            }
          }
          break

        case 'role':
          if (f.role && (f.firstname || f.lastname || f.name || f.organizationSelectedName || f.organization || f.organizationText || f.identifierText)) {
            this.push_object(jsonld, f.role, this.get_json_role(f))
          }
          break

        case 'edm:rights':
        case 'bibo:issue':
        case 'bibo:volume':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          break

        case 'dce:rights':
        case 'rdau:P60550':
        case 'bf:physicalLocation':
          if (f.value) {
            this.push_value(jsonld, f.predicate, this.get_json_valueobject(f.value, f.language))
          }
          break

        case 'dce:subject':
          if (f.value) {
            for (let kw of f.value) {
              this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': kw, '@language': f.language }], null, 'skos:Concept'))
            }
          }
          break

        case 'dcterms:subject':
          if ((f.type === 'skos:Concept') && f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_concept(f['skos:prefLabel'], f['rdfs:label'], 'skos:Concept', [f.value], f['skos:notation'] ? f['skos:notation'] : null))
          }
          break

        case 'rdau:P60193':
          if (f.title || f.volume || f.issue || f.issued || f.issn || f.identifier) {
            this.push_object(jsonld, f.predicate, this.get_json_series(f.type, f.title, f.titleLanguage, f.volume, f.issue, f.issued, f.issn, f.identifier, f.identifierType))
          }
          if (f.pageStart) {
            this.push_literal(jsonld, 'schema:pageStart', f.pageStart)
          }
          if (f.pageEnd) {
            this.push_literal(jsonld, 'schema:pageEnd', f.pageEnd)
          }
          break

        case 'rdau:P60101':
          if (f.title || f.identifier || f.volume || ((f.roles.length > 0) && (f.roles[0].firstname || f.roles[0].lastname || f.roles[0].name || f.roles[0].organizationSelectedName || f.roles[0].identifierText)) || f.isbn || f.series[0].seriesTitle || f.series[0].seriesIdentifier || f.series[0].seriesVolume || f.series[0].seriesIssue || f.series[0].seriesIssued || f.series[0].seriesIssn || f.publisherName || f.publishingPlace || f.publishingDate || f.publisherOrgUnit) {
            this.push_object(jsonld, f.predicate, this.get_json_contained_in(f))
          }
          if (f.pageStart) {
            this.push_literal(jsonld, 'schema:pageStart', f.pageStart)
          }
          if (f.pageEnd) {
            this.push_literal(jsonld, 'schema:pageEnd', f.pageEnd)
          }
          break

        case 'bf:instanceOf':
          if (f.title || f.identifierText) {
            this.push_object(jsonld, f.predicate, this.get_json_instance_of(f))
          }
          break

        case 'rdau:P60227':
          if (f.title || f.name || f.firstname || f.lastname) {
            this.push_object(jsonld, f.predicate, this.get_json_adaptation(f.type, f.title, f.subtitle, f.titleLanguage, f.role, f.name, f.firstname, f.lastname))
          }
          break

        case 'bf:provisionActivity':
          if (f.publisherName || f.publishingPlace || f.publishingDate || f.publisherOrgUnit) {
            this.push_object(jsonld, f.predicate, this.get_json_bf_publication(f))
          }
          break

        case 'citation':
          if (f.citation || f.identifier) {
            this.push_object(jsonld, f.type, this.get_json_object([{ '@value': f.citation, '@language': f.citationLanguage }], null, 'rdfs:Resource', [ f.identifier ]))
          }
          break

        case 'ebucore:hasRelatedEvent':
          if (f.name || f.identifierText) {
            this.push_object(jsonld, f.predicate, this.get_json_event(f))
          }
          break

        case 'frapo:isOutputOf':
          if (f.type === 'aiiso:Programme') {
            if (f.component === 'p-select') {
              if (f.value) {
                this.push_object(jsonld, f.predicate, this.get_json_concept(f['skos:prefLabel'], f['rdfs:label'], 'aiiso:Programme', [f.value], f['skos:notation'] ? f['skos:notation'] : null))
              }
            } else {
              // study plan
              if (f.name || f.notation || f['skos:prefLabel']) {
                this.push_object(jsonld, f.predicate, this.get_json_study_plan(f.name, f.nameLanguage, f['skos:prefLabel'], [f.notation], [f.identifier]))
              }
            }
          } else {
            // project
            if (f.type === 'foaf:Project') {
              if (f.name || f.acronym || f.code || f.identifier || f.description || f.homepage || f.funderName || f.funderIdentifier) {
                this.push_object(jsonld, f.predicate, this.get_json_project(f.name, f.acronym, f.nameLanguage, f.description, f.descriptionLanguage, f.code, f.identifier, f.identifierType, f.homepage, f.dateFrom, f.dateTo, this.get_json_funder(f.funderName, f.funderNameLanguage, f.funderIdentifier, f.funderIdentifierType)))
              }
            }
          }
          break

        case 'frapo:hasFundingAgency':
          if (f.name || f.identifier) {
            this.push_object(jsonld, f.predicate, this.get_json_funder(f.name, f.nameLanguage, f.identifier, f.identifierType))
          }
          break

        case 'opaque:cco_accessionNumber':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          break

        case 'bf:shelfMark':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          break

        case 'vra:hasInscription':
          if (f.component === 'p-select' && f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object(null, null, 'vra:Inscription', f.value))
          } else {
            if (f.value) {
              this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, 'vra:Inscription'))
            }
          }
          break

        case 'vra:material':
          if (f.component === 'p-select' && f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, 'vra:Material', [ f.value ]))
          } else {
            if (f.value) {
              this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, 'vra:Material'))
            }
          }
          break

        case 'dce:format':
          if (f.component === 'p-select' && f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, 'skos:Concept', [ f.value ]))
          } else {
            if (f.value) {
              this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, 'skos:Concept'))
            }
          }
          break

        case 'vra:hasTechnique':
          if (f.component === 'p-select' && f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], null, 'vra:Technique', [ f.value ]))
          } else {
            if (f.component === 'p-vocab-ext-readonly') {
              this.push_object(jsonld, f.predicate, this.get_json_object(f['skos:prefLabel'], f['rdfs:label'], 'vra:Technique', f['skos:exactMatch']))
            } else {
              if (f.value) {
                this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, 'vra:Technique'))
              }
            }
          }
          break

        case 'schema:width':
        case 'schema:height':
        case 'schema:depth':
        case 'schema:weight':
        case 'vra:diameter':
          if (f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_quantitativevalue(f.value, f.unit))
          }
          break

        case 'schema:duration':
        case 'phaidra:systemTag':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          break

        case 'rdfs:seeAlso':
          if (f.url || f.title) {
            this.push_object(jsonld, f.predicate, this.get_json_see_also(f.url, f.title, f.titleLanguage))
          }
          break

        case 'date':
        case 'dcterms:date':
        case 'dcterms:created':
        case 'dcterms:modified':
        case 'dcterms:available':
        case 'dcterms:issued':
        case 'dcterms:valid':
        case 'dcterms:dateAccepted':
        case 'dcterms:dateCopyrighted':
        case 'dcterms:dateSubmitted':
        case 'phaidra:dateAccessioned':
        case 'phaidra:dateApprobation':
          if (f.component === 'p-date-edmtimespan' && (f.value || f.identifier)) {
            this.push_object(jsonld, f.type, this.get_json_edm_timespan(f.value, f.type, f.language, f.identifier, f.identifierType))
          } else {
            if (f.value) {
              this.push_literal(jsonld, f.type, f.value)
            }
          }
          break

        case 'dcterms:provenance':
          if (f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, 'dcterms:ProvenanceStatement'))
          }
          break

        case 'dcterms:spatial':
        case 'vra:placeOfCreation':
        case 'vra:placeOfRepository':
        case 'vra:placeOfSite':
          if (((f.component === 'p-spatial-geonames') || (f.component === 'p-spatial-geonames-search') || (f.component === 'p-spatial-readonly')) && f.value) {
            this.push_object(jsonld, f.predicate, this.get_json_spatial(f['rdfs:label'], f['skos:prefLabel'], f.coordinates, f.type, [f.value]))
          } else {
            if (f.value) {
              this.push_object(jsonld, f.predicate, this.get_json_object([{ '@value': f.value, '@language': f.language }], null, f.type))
            }
          }
          break

        case 'schema:numberOfPages':
        case 'bf:soundCharacteristic':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          break

        case 'ebucore:filename':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          if (f.mimetype) {
            this.push_literal(jsonld, 'ebucore:hasMimeType', f.mimetype)
          }
          break

        case 'ebucore:hasMimeType':
          if (f.value) {
            this.push_literal(jsonld, f.predicate, f.value)
          }
          break

        default:
          if (f.value) {
            jsonld[f.predicate] = f.value
          }
          break
      }
    }
    return jsonld
  }
}
