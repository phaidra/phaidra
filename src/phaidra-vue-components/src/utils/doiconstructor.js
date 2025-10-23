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
            auth.orcid = author['ORCID'].replace('http://orcid.org/', '')
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
    doiImportData.journalVolume = dataciteData.data.attributes.container.lastPage
  }
  if (dataciteData?.data?.attributes?.rightsList?.length) {
    const licenseIndex = dataciteData.data.attributes.rightsList.findIndex(x => x.schemeUri && x.schemeUri.includes('/licenses/'))
    const accessRightsIndex = dataciteData.data.attributes.rightsList.findIndex(x => x.rightsUri && x.rightsUri.includes('/access_right/'))
    if(licenseIndex >= 0){
      let licUrl = dataciteData.data.attributes.rightsList[licenseIndex].rightsUri
      if(licUrl){
        const modifiedUrl = licUrl.replace(/^https/, "http");
        // Remove the last word from the path
        const pathArray = modifiedUrl.split("/");
        pathArray.pop(); // Remove the last element
        const finalUrl = pathArray.join("/") + '/';
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
  if (dataciteData?.data?.attributes?.descriptions?.length && doiImportData.license.includes('http://creativecommons.org/licenses')) {
    doiImportData.descriptions = dataciteData.data.attributes.descriptions.map(x => x.descriptionType === 'Abstract' ? {
      ...x,
      lang: x.lang ? x.lang.length === 3 ? x.lang : that.lang2to3map[x.lang] : null
    } : null).filter(x => x !== null)
  }
  return doiImportData
}
