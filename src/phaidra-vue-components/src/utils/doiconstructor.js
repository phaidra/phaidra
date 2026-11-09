const normalizeOrcid = (orcid) => {
  if (!orcid) return orcid
  // Remove all common ORCID URL prefixes and return just the ID
  return orcid.replace(/^https?:\/\/(www\.)?orcid\.org\//i, '').trim()
}

export const normalizeLicenseUrl = (licUrl) => {
  if (!licUrl) return null
  let modifiedUrl = licUrl.replace(/^https/, 'http').replace(/\/$/, '')
  if (modifiedUrl.endsWith('/legalcode')) {
    modifiedUrl = modifiedUrl.slice(0, -'/legalcode'.length)
  }
  return modifiedUrl + '/'
}

export const isCreativeCommonsLicense = (license) => {
  return typeof license === 'string' && /creativecommons\.org\/licenses/.test(license)
}

export const cleanCrossrefAbstract = (abstract) => {
  if (!abstract) return null
  return abstract
    .replace(/<jats:p>/g, '')
    .replace(/<\/jats:p>/g, '')
    .replace(/^Abstract\.\s*/i, '')
    .trim()
}

export const setDoiAbstract = (doiImportData, abstractItems, license) => {
  if (!abstractItems?.length) return
  doiImportData.descriptions = abstractItems
  doiImportData.abstractWillImport = isCreativeCommonsLicense(license)
}

export const constructDataCite = (dataciteData, that) => {
  let doiImportData = {
    title: '',
    dateIssued: '',
    authors: [],
    publicationType: '',
    publisher: '',
    journalTitle: '',
    journalISSN: '',
    journalVolume: '',
    journalIssue: '',
    pageStart: '',
    pageEnd: '',
    licenceLabel: '',
    descriptions: []
  }
  if (dataciteData?.data?.attributes?.titles?.length) {
    doiImportData.title = dataciteData.data.attributes.titles[0].title
  }
  if (dataciteData?.data?.attributes?.publicationYear) {
    doiImportData.dateIssued = dataciteData?.data?.attributes?.publicationYear.toString()
  }
  if (dataciteData?.data?.attributes?.creators) {
    let authors = dataciteData?.data?.attributes?.creators
    if (authors.length > 0) {
      for (let author of authors) {
        if (author['givenName'] || author['familyName']) {
          let auth = {
            type: 'schema:Person',
            firstname: author['givenName'] ? author['givenName'].replace(/\s\s+/g, ' ').trim() : '',
            lastname: author['familyName'] ? author['familyName'].replace(/\s\s+/g, ' ').trim() : ''
          }
          if (author['affiliation']) {
            if (Array.isArray(author['affiliation'])) {
              auth.affiliation = []
              for (let af of author['affiliation']) {
                auth.affiliation.push(af['name'])
              }
            }
          }
          if (author['ORCID']) {
            auth.orcid = normalizeOrcid(author['ORCID'])
          }
          doiImportData.authors.push(auth)
        } else if (author['name']) {
          let auth = {
            type: 'schema:Organization',
            name: author['name']
          }
          doiImportData.authors.push(auth)
        }
      }
    }
  }
  if (dataciteData?.data?.attributes?.language) {
    if(dataciteData.data.attributes.language.length === 3) {
      doiImportData.language = dataciteData.data.attributes.language
    } else if (that.lang2to3map[dataciteData.data.attributes.language]) {
      doiImportData.language = that.lang2to3map[dataciteData.data.attributes.language]
    }
  }
  if (dataciteData?.data?.attributes?.types?.citeproc) {
    const dataciteType = dataciteData.data.attributes.types.citeproc;
    switch (dataciteType) {
      case 'article':
      case 'journal-article':
      case 'article-journal':
        doiImportData.publicationType = 'article'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/VKA6-9XTY'
        break
      case 'report':
        doiImportData.publicationType = 'report'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/JMAV-7F3R'
        break
      case 'book':
      case 'monograph':
      case 'reference-book':
      case 'edited-book':
        doiImportData.publicationType = 'book'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/47QB-8QF1'
        break
      case 'book-chapter':
      case 'book-part':
      case 'book-section':
        doiImportData.publicationType = 'book_part'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/XA52-09WA'
        break
      case 'dissertation':
        doiImportData.publicationType = 'doctoral_thesis'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/1PHE-7VMS'
        break
      case 'proceedings-article':
      case 'proceedings':
        doiImportData.publicationType = 'conference_object'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/QKDF-E5HA'
        break
      case 'dataset':
        doiImportData.publicationType = 'research_data'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/KW6N-2VTP'
        break
      case 'other':
      case 'standard':
      case 'standard-series':
      case 'book-entry':
      case 'book-series':
      case 'book-set':
      case 'book-track':
      case 'component':
      case 'journal-issue':
      case 'journal-volume':
      case 'journal':
      case 'report-series':
        doiImportData.publicationType = 'other'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/PYRE-RAWJ'
        break
      default:
        doiImportData.publicationType = 'other'
        doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/PYRE-RAWJ'
    }
  }
  if (dataciteData?.data?.attributes?.publisher) {
    doiImportData.publisher = that.$_.unescape(dataciteData.data.attributes.publisher.replace(/\s\s+/g, ' ').trim())
  }
  if (dataciteData?.data?.attributes?.subjects) {
    if (Array.isArray(dataciteData.data.attributes.subjects)) {
      doiImportData.keywords = []
      for (let kw of dataciteData.data.attributes.subjects) {
        doiImportData.keywords.push(kw.subject)
      }
    }
  }
  if (dataciteData?.data?.attributes?.container?.title) {
    doiImportData.journalTitle = that.$_.unescape(dataciteData?.data?.attributes?.container?.title.replace(/\s\s+/g, ' ').trim())
  }
  if (dataciteData?.data?.attributes?.container?.firstPage) {
    doiImportData.pageStart = dataciteData.data.attributes.container.firstPage
  }
  if (dataciteData?.data?.attributes?.container?.lastPage) {
    doiImportData.pageEnd = dataciteData.data.attributes.container.lastPage
  }
  if (dataciteData?.data?.attributes?.container?.volume) {
    doiImportData.journalVolume = dataciteData.data.attributes.container.volume
  }
  if (dataciteData?.data?.attributes?.rightsList?.length) {
    const licenseIndex = dataciteData.data.attributes.rightsList.findIndex(x => x.schemeUri && x.schemeUri.includes('/licenses/'))
    const accessRightsIndex = dataciteData.data.attributes.rightsList.findIndex(x => x.rightsUri && x.rightsUri.includes('/access_right/'))
    if(licenseIndex >= 0){
      let licUrl = dataciteData.data.attributes.rightsList[licenseIndex].rightsUri
      if(licUrl){
        const finalUrl = normalizeLicenseUrl(licUrl)
        const licTerm = that.getTerm('alllicenses', finalUrl)
        if (licTerm) {
          doiImportData.licenceLabel = licTerm && licTerm['skos:prefLabel'] && licTerm['skos:prefLabel']['eng'] ? licTerm['skos:prefLabel']['eng'] : 'N/A'
          doiImportData.license = finalUrl
        }
      }
    }
    if(accessRightsIndex >= 0){
      let rightsName = dataciteData.data.attributes.rightsList[accessRightsIndex].rights
      switch (rightsName) {
        case 'open access':
          doiImportData.accessrights = 'https://pid.phaidra.org/vocabulary/QW5R-NG4J'
          doiImportData.accessrightsLabel = 'open access'
          break;
        case 'embargoed access':
          doiImportData.accessrights = 'https://pid.phaidra.org/vocabulary/AVFC-ZZSZ'
          doiImportData.accessrightsLabel = 'embargoed access'
          break;
        case 'restricted access':
          doiImportData.accessrights = 'https://pid.phaidra.org/vocabulary/KC3K-CCGM'
          doiImportData.accessrightsLabel = 'restricted access'
          break;
        case 'metadata only access':
          doiImportData.accessrights = 'https://pid.phaidra.org/vocabulary/QNGE-V02H'
          doiImportData.accessrightsLabel = 'metadata only access'
          break;

        default:
          break;
      }
    }
  }
  if (dataciteData?.data?.attributes?.descriptions?.length) {
    const abstractItems = dataciteData.data.attributes.descriptions
      .filter(x => x.descriptionType === 'Abstract' && x.description)
      .map(x => ({
        description: x.description,
        lang: x.lang ? x.lang.length === 3 ? x.lang : that.lang2to3map[x.lang] : null
      }))
    setDoiAbstract(doiImportData, abstractItems, doiImportData?.license)
  }
  return doiImportData
}

export const constructCrossref = (crossrefData, that) => {
  const trimText = (value) => {
    if (typeof value !== 'string') return ''
    return value.replace(/\s\s+/g, ' ').trim()
  }

  const firstOrValue = (value) => {
    if (Array.isArray(value)) {
      return value.length > 0 ? value[0] : null
    }
    return value
  }

  const doiImportData = {
    title: '',
    dateIssued: '',
    authors: [],
    publicationType: '',
    publisher: '',
    journalTitle: '',
    journalISSN: '',
    journalVolume: '',
    journalIssue: '',
    pageStart: '',
    pageEnd: '',
    descriptions: []
  }

  const title = trimText(firstOrValue(crossrefData?.title))
  if (title) doiImportData.title = title

  const subtitle = trimText(firstOrValue(crossrefData?.subtitle))
  if (subtitle) doiImportData.subtitle = subtitle

  const issuedYear = crossrefData?.issued?.['date-parts']?.[0]?.[0]
  if (issuedYear) {
    doiImportData.dateIssued = issuedYear.toString()
  }

  if (crossrefData?.language) {
    if (crossrefData.language.length === 3) {
      doiImportData.language = crossrefData.language
    } else if (that?.lang2to3map?.[crossrefData.language]) {
      doiImportData.language = that.lang2to3map[crossrefData.language]
    }
  }

  if (Array.isArray(crossrefData?.author)) {
    for (const author of crossrefData.author) {
      if (author?.given || author?.family) {
        const auth = {
          type: 'schema:Person',
          firstname: author.given ? trimText(author.given) : '',
          lastname: author.family ? trimText(author.family) : ''
        }
        if (Array.isArray(author.affiliation)) {
          auth.affiliation = []
          for (const af of author.affiliation) {
            auth.affiliation.push(af.name)
          }
        }
        if (author.ORCID) {
          auth.orcid = normalizeOrcid(author.ORCID)
        }
        doiImportData.authors.push(auth)
      }
      if (author?.name) {
        doiImportData.authors.push({
          type: 'schema:Organization',
          name: author.name
        })
      }
    }
  }

  if (Array.isArray(crossrefData?.subject)) {
    doiImportData.keywords = []
    for (const kw of crossrefData.subject) {
      doiImportData.keywords.push(kw)
    }
  }

  // https://github.com/citation-style-language/schema/blob/master/csl-types.rnc
  // https://wiki.univie.ac.at/display/IR/Mapping+CrossRef-Erscheinungsformen
  switch (crossrefData?.type) {
    case 'article':
    case 'journal-article':
    case 'article-journal':
      doiImportData.publicationType = 'article'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/VKA6-9XTY'
      break
    case 'report':
      doiImportData.publicationType = 'report'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/JMAV-7F3R'
      break
    case 'book':
    case 'monograph':
    case 'reference-book':
    case 'edited-book':
      doiImportData.publicationType = 'book'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/47QB-8QF1'
      break
    case 'book-chapter':
    case 'book-part':
    case 'book-section':
      doiImportData.publicationType = 'book_part'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/XA52-09WA'
      break
    case 'dissertation':
      doiImportData.publicationType = 'doctoral_thesis'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/1PHE-7VMS'
      break
    case 'proceedings-article':
    case 'proceedings':
      doiImportData.publicationType = 'conference_object'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/QKDF-E5HA'
      break
    case 'dataset':
      doiImportData.publicationType = 'research_data'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/KW6N-2VTP'
      break
    case 'other':
    case 'standard':
    case 'standard-series':
    case 'book-entry':
    case 'book-series':
    case 'book-set':
    case 'book-track':
    case 'component':
    case 'journal-issue':
    case 'journal-volume':
    case 'journal':
    case 'report-series':
      doiImportData.publicationType = 'other'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/PYRE-RAWJ'
      break
    default:
      doiImportData.publicationType = 'other'
      doiImportData.publicationTypeId = 'https://pid.phaidra.org/vocabulary/PYRE-RAWJ'
  }

  const publisher = trimText(firstOrValue(crossrefData?.publisher))
  if (publisher) doiImportData.publisher = publisher

  const journalTitle = trimText(firstOrValue(crossrefData?.['container-title']))
  if (journalTitle) doiImportData.journalTitle = journalTitle

  const journalISSN = trimText(firstOrValue(crossrefData?.ISSN))
  if (journalISSN) doiImportData.journalISSN = journalISSN

  const isbn = trimText(firstOrValue(crossrefData?.ISBN))
  if (isbn) doiImportData.ISBN = isbn

  const volume = trimText(crossrefData?.volume)
  if (volume) doiImportData.journalVolume = volume

  const issue = trimText(crossrefData?.issue)
  if (issue) doiImportData.journalIssue = issue

  if (crossrefData?.page) {
    const page = crossrefData.page.split('-')
    const regexnum = new RegExp('^[0-9]+$')
    const startpage = page[0]
    if (regexnum.test(startpage)) {
      doiImportData.pageStart = startpage
    }
    if (page.length > 1) {
      const endpage = page[1]
      if (regexnum.test(endpage)) {
        doiImportData.pageEnd = endpage
      }
    }
  }

  if (Array.isArray(crossrefData?.license)) {
    for (const lic of crossrefData.license) {
      if (lic?.URL) {
        const normalizedUrl = normalizeLicenseUrl(lic.URL)
        if (that?.getLocalizedTermLabel?.('alllicenses', normalizedUrl)) {
          doiImportData.license = normalizedUrl
        }
      }
    }
  }

  if (crossrefData?.abstract) {
    const abstractText = cleanCrossrefAbstract(crossrefData.abstract)
    if (abstractText) {
      setDoiAbstract(
        doiImportData,
        [{ description: abstractText }],
        doiImportData?.license
      )
    }
  }

  return doiImportData
}
