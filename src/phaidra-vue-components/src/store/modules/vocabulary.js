import Vue from 'vue'
import languages from '../../utils/lang'
import lang3to2map from '../../utils/lang3to2map'
import orgunits from '../../utils/orgunits'
import fieldsLib from '../../utils/fields'
import oefos from '../../utils/oefos'
import thema from '../../utils/thema'
import bic from '../../utils/bic'
import i18n from '../../i18n/i18n'

const lang2to3map = Object.keys(lang3to2map).reduce((ret, key) => {
  ret[lang3to2map[key]] = key
  return ret
}, {})

const ns = 'https://pid.phaidra.org/vocabulary/'

const ot4rt = {
  // image
  'https://pid.phaidra.org/vocabulary/44TN-P1S0': [
    // still image
    ns + '7CAB-P987',
    // still image of physical object
    ns + '4YS3-8T2K',
    // slide (Diapositiv)
    ns + '431H-5YSA',
    // wall chart
    ns + 'QM0R-ZTAA',
    // conference poster
    ns + '7HBP-P9S3',
    // learning object
    ns + 'YA8R-1M0D',
    // map
    ns + 'A52A-CWMM',
    // other
    ns + 'PYRE-RAWJ'
  ],
  // sound
  'https://pid.phaidra.org/vocabulary/8YB5-1M0J': [
    // lecture
    ns + 'F4JN-ZST0',
    // interview
    ns + '8KGA-CH97',
    // musical composition
    ns + 'EWZ9-3MPH',
    // learning object
    ns + 'YA8R-1M0D',
    // other
    ns + 'PYRE-RAWJ'
  ],
  // video
  'https://pid.phaidra.org/vocabulary/B0Y6-GYT8': [
    // film
    ns + 'Y8CC-HY82',
    // lecture
    ns + 'F4JN-ZST0',
    // interview
    ns + '8KGA-CH97',
    // learning object
    ns + 'YA8R-1M0D',
    // other
    ns + 'PYRE-RAWJ'
  ],
  // text
  'https://pid.phaidra.org/vocabulary/69ZZ-2KGX': [
    // text
    ns + '69ZZ-2KGX',
    // book
    ns + '47QB-8QF1',
    // book part
    ns + 'XA52-09WA',
    // conference object
    ns + 'QKDF-E5HA',
    // lecture
    ns + 'F4JN-ZST0',
    // learning object
    ns + 'YA8R-1M0D',
    // letter (correspondence)
    ns + 'GBWA-JJP8',
    // journal article
    ns + 'VKA6-9XTY',
    // newspaper
    ns + 'DCHD-W3GM',
    // magazine
    ns + 'EHPQ-XYA3',
    // preprint
    ns + 'T023-BGTD',
    // report
    ns + 'JMAV-7F3R',
    // data management plan
    ns + 'W2Z3-3YA6',
    // research report
    ns + '7J0J-HC61',
    // technical report
    ns + 'DF69-TVE8',
    // review
    ns + 'JJKV-B1CG',
    // working paper
    ns + '489N-Y6VX',
    // musical notation
    ns + '8A6X-FKB1',
    // project deliverable
    ns + 'T8PK-GADB',
    // other
    ns + 'PYRE-RAWJ'
  ],
  // data
  'https://pid.phaidra.org/vocabulary/7AVS-Y482': [
    // dataset
    ns + 'KW6N-2VTP',
    // learning object
    ns + 'YA8R-1M0D',
    // still image
    ns + '7CAB-P987',
    // still image of physical object
    ns + '4YS3-8T2K',
    // slide (Diapositiv)
    ns + '431H-5YSA',
    // wall chart
    ns + 'QM0R-ZTAA',
    // conference poster
    ns + '7HBP-P9S3',
    // map
    ns + 'A52A-CWMM',
    // interview
    ns + '8KGA-CH97',
    // musical composition
    ns + 'EWZ9-3MPH',
    // moving image
    ns + 'Y8CC-HY82',
    // text
    ns + '69ZZ-2KGX',
    // book
    ns + '47QB-8QF1',
    // book part
    ns + 'XA52-09WA',
    // conference object
    ns + 'QKDF-E5HA',
    // lecture
    ns + 'F4JN-ZST0',
    // letter (correspondence)
    ns + 'GBWA-JJP8',
    // journal article
    ns + 'VKA6-9XTY',
    // newspaper
    ns + 'DCHD-W3GM',
    // magazine
    ns + 'EHPQ-XYA3',
    // preprint
    ns + 'T023-BGTD',
    // report
    ns + 'JMAV-7F3R',
    // data management plan
    ns + 'W2Z3-3YA6',
    // research report
    ns + '7J0J-HC61',
    // technical report
    ns + 'DF69-TVE8',
    // review
    ns + 'JJKV-B1CG',
    // working paper
    ns + '489N-Y6VX',
    // musical notation
    ns + '8A6X-FKB1',
    // project deliverable
    ns + 'T8PK-GADB',
    // other
    ns + 'PYRE-RAWJ'
  ]
}

const vocabularies = {
  'cmodels': {
    terms: [
      { '@id': 'Asset', 'skos:prefLabel': { 'eng': 'Asset', 'deu': '' } },
      { '@id': 'Audio', 'skos:prefLabel': { 'eng': 'Audio', 'deu': '' } },
      { '@id': 'Book', 'skos:prefLabel': { 'eng': 'Book', 'deu': '' } },
      { '@id': 'Collection', 'skos:prefLabel': { 'eng': 'Collection', 'deu': '' } },
      { '@id': 'Container', 'skos:prefLabel': { 'eng': 'Container', 'deu': '' } },
      { '@id': 'PDFDocument', 'skos:prefLabel': { 'eng': 'PDF Document', 'deu': '' } },
      { '@id': 'Page', 'skos:prefLabel': { 'eng': 'Page', 'deu': '' } },
      { '@id': 'Picture', 'skos:prefLabel': { 'eng': 'Picture', 'deu': '' } },
      { '@id': 'Resource', 'skos:prefLabel': { 'eng': 'Resource', 'deu': '' } },
      { '@id': 'Video', 'skos:prefLabel': { 'eng': 'Video', 'deu': '' } }
    ],
    loaded: true
  },
  'relations': {
    terms: [
      { '@id': 'http://purl.org/dc/terms/references', 'skos:prefLabel': { 'eng': 'References', 'deu': 'bezieht sich auf' }, 'skos:notation': ['references'] },
      { '@id': 'http://phaidra.org/XML/V1.0/relations#isBackSideOf', 'skos:prefLabel': { 'eng': 'Is back side of', 'deu': 'ist Rückseite von' }, 'skos:notation': ['isBackSideOf'] },
      { '@id': 'http://phaidra.org/XML/V1.0/relations#isThumbnailFor', 'skos:prefLabel': { 'eng': 'Is thumbnail for', 'deu': 'ist Vorschaubild von' }, 'skos:notation': ['isThumbnailFor'] },
      { '@id': 'http://phaidra.univie.ac.at/XML/V1.0/relations#hasSuccessor', 'skos:prefLabel': { 'eng': 'Is older version of', 'deu': 'ist ältere Version von' }, 'skos:notation': ['hasSuccessor'] },
      { '@id': 'http://phaidra.org/XML/V1.0/relations#isAlternativeFormatOf', 'skos:prefLabel': { 'eng': 'Is alternative format of', 'deu': 'ist alternatives Format von' }, 'skos:notation': ['isAlternativeFormatOf'] },
      { '@id': 'http://phaidra.org/XML/V1.0/relations#isAlternativeVersionOf', 'skos:prefLabel': { 'eng': 'Is alternative version of', 'deu': 'ist alternative Version von' }, 'skos:notation': ['isAlternativeVersionOf'] },
      { '@id': 'info:fedora/fedora-system:def/relations-external#hasCollectionMember', 'skos:prefLabel': { 'eng': 'Has part', 'deu': 'hat Collection Mitglieder' }, 'skos:notation': ['hasCollectionMember'] },
      { '@id': 'http://pcdm.org/models#hasMember', 'skos:prefLabel': { 'eng': 'Has member', 'deu': 'hat Mitglieder' }, 'skos:notation': ['hasMember'] },
      { '@id': 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasTrack', 'skos:prefLabel': { 'eng': 'Has track', 'deu': 'hat Track (zb. Untertitel)' }, 'skos:notation': ['hasTrack'] }
    ],
    loaded: true
  },
  'pool': {
    terms: [
      { '@id': 'Bibliothek', 'skos:prefLabel': { 'eng': 'Library', 'deu': 'Bibliothek' } },
      { '@id': 'Institut für Romanistik', 'skos:prefLabel': { 'eng': 'Institute for Romance Studies', 'deu': 'Institut für Romanistik' } },
      { '@id': 'privat', 'skos:prefLabel': { 'eng': 'private', 'deu': 'privat' } }
    ],
    loaded: true
  },
  'datepredicate': {
    terms: [
      { '@id': 'dcterms:date', 'skos:prefLabel': { 'eng': 'Date', 'deu': 'Datum' } },
      { '@id': 'dcterms:created', 'skos:prefLabel': { 'eng': 'Date created', 'deu': 'Erstellungsdatum' } },
      { '@id': 'dcterms:modified', 'skos:prefLabel': { 'eng': 'Date modified', 'deu': 'Änderungsdatum' } },
      { '@id': 'dcterms:available', 'skos:prefLabel': { 'eng': 'Date available', 'deu': 'Verfügbarkeitsdatum' } },
      { '@id': 'dcterms:issued', 'skos:prefLabel': { 'eng': 'Date issued', 'deu': 'Erscheinungsdatum' } },
      { '@id': 'dcterms:valid', 'skos:prefLabel': { 'eng': 'Date valid', 'deu': 'Gültigkeitsdatum' } },
      { '@id': 'dcterms:dateAccepted', 'skos:prefLabel': { 'eng': 'Date accepted', 'deu': 'Annahmedatum' } },
      { '@id': 'dcterms:dateCopyrighted', 'skos:prefLabel': { 'eng': 'Date copyrighted', 'deu': 'Copyright Datum' } },
      { '@id': 'dcterms:dateSubmitted', 'skos:prefLabel': { 'eng': 'Date submitted', 'deu': 'Datum der Einreichung' } },
      { '@id': 'rdau:P60071', 'skos:prefLabel': { 'eng': 'Date of production', 'deu': 'Produktionsdatum' } },
      { '@id': 'phaidra:dateAccessioned', 'skos:prefLabel': { 'eng': 'Date accessioned', 'deu': 'Eingangsdatum' } },
      { '@id': 'dcterms:temporal', 'skos:prefLabel': { 'eng': 'Temporal coverage', 'deu': 'Zeitliche Abdeckung' } }
    ],
    loaded: true
  },
  'placetype': {
    terms: [
      { '@id': 'schema:Place', 'skos:prefLabel': { 'eng': 'Place', 'deu': 'Ort' } },
      { '@id': 'schema:AdministrativeArea', 'skos:prefLabel': { 'eng': 'AdministrativeArea', 'deu': 'Verwaltungseinheit' } }
    ],
    loaded: true
  },
  'objectidentifiertype': {
    terms: [
      { '@id': 'ids:doi', 'skos:prefLabel': { 'eng': 'DOI' }, 'skos:example': '10.1629/uksg.419' },
      { '@id': 'ids:hdl', 'skos:prefLabel': { 'eng': 'Handle' }, 'skos:example': '11353/10.761200' },
      { '@id': 'ids:urn', 'skos:prefLabel': { 'eng': 'URN' }, 'skos:example': 'urn:nbn:at:at-ubw-21405.98566.193074-2' },
      { '@id': 'ids:uri', 'skos:prefLabel': { 'eng': 'URI' }, 'skos:example': 'https://example.com/path/resource.txt' },
      { '@id': 'ids:isbn', 'skos:prefLabel': { 'eng': 'ISBN' }, 'skos:example': '978-3-16-148410-0' },
      { '@id': 'ids:issn', 'skos:prefLabel': { 'eng': 'ISSN' }, 'skos:example': '1544-9173' },
      { '@id': 'ids:gnd', 'skos:prefLabel': { 'eng': 'GND' }, 'skos:example': '118635808' },
      { '@id': 'phaidra:acnumber', 'skos:prefLabel': { 'eng': 'AC number', 'deu': 'AC Nummer' }, 'skos:example': 'AC13399179' }
    ],
    loaded: true
  },
  'irobjectidentifiertype': {
    terms: [
      { '@id': 'ids:doi', 'skos:prefLabel': { 'eng': 'DOI' }, 'skos:example': '10.1629/uksg.419' },
      { '@id': 'ids:hdl', 'skos:prefLabel': { 'eng': 'Handle' }, 'skos:example': '11353/10.761200' },
      { '@id': 'ids:urn', 'skos:prefLabel': { 'eng': 'URN' }, 'skos:example': 'urn:nbn:at:at-ubw-21405.98566.193074-2' },
      { '@id': 'ids:isbn', 'skos:prefLabel': { 'eng': 'ISBN' }, 'skos:example': '978-3-16-148410-0' },
      { '@id': 'ids:uri', 'skos:prefLabel': { 'eng': 'URI/URL' }, 'skos:example': 'https://example.com/path/resource.txt' }
    ],
    loaded: true
  },
  'irobjectidentifiertypenoisbn': {
    terms: [
      { '@id': 'ids:doi', 'skos:prefLabel': { 'eng': 'DOI' }, 'skos:example': '10.1629/uksg.419' },
      { '@id': 'ids:hdl', 'skos:prefLabel': { 'eng': 'Handle' }, 'skos:example': '11353/10.761200' },
      { '@id': 'ids:urn', 'skos:prefLabel': { 'eng': 'URN' }, 'skos:example': 'urn:nbn:at:at-ubw-21405.98566.193074-2' },
      { '@id': 'ids:uri', 'skos:prefLabel': { 'eng': 'URI/URL' }, 'skos:example': 'https://example.com/path/resource.txt' }
    ],
    loaded: true
  },
  'entityidentifiertype': {
    terms: [
      { '@id': 'ids:orcid', 'skos:prefLabel': { 'eng': 'ORCID' }, 'skos:example': '0000-0002-1825-0097' },
      { '@id': 'ids:gnd', 'skos:prefLabel': { 'eng': 'GND' }, 'skos:example': '118635808' },
      { '@id': 'ids:viaf', 'skos:prefLabel': { 'eng': 'VIAF' }, 'skos:example': '89597697' },
      { '@id': 'ids:wikidata', 'skos:prefLabel': { 'eng': 'Wikidata ID' }, 'skos:example': 'Q129772' },
      { '@id': 'ids:lcnaf', 'skos:prefLabel': { 'eng': 'LCNAF' }, 'skos:example': 'n79021164' },
      { '@id': 'ids:isni', 'skos:prefLabel': { 'eng': 'ISNI' }, 'skos:example': '0000000121174585' },
      { '@id': 'ids:uri', 'skos:prefLabel': { 'eng': 'URI' }, 'skos:example': 'https://authority.example.com/path/resource' }
    ],
    loaded: true
  },
  'citationpredicate': {
    terms: [
      { '@id': 'cito:cites', 'skos:prefLabel': { 'eng': 'Cites', 'deu': 'Verweist auf' } },
      { '@id': 'cito:citesAsDataSource', 'skos:prefLabel': { 'eng': 'Cites as data source', 'deu': 'Verweist auf Dataset' } },
      { '@id': 'cito:isCitedBy', 'skos:prefLabel': { 'eng': 'Is cited by', 'deu': 'Zitiert von' } }
    ],
    loaded: true
  },
  'rolepredicate': {
    terms: [
      { '@id': 'role:oth', 'skos:prefLabel': { 'eng': 'Other', 'deu': 'Andere', 'ita': 'Altro' } },
      { '@id': 'role:abr', 'skos:prefLabel': { 'eng': 'Abridger', 'deu': 'Autor*in von Kurzfassungen', 'ita': 'Abridger' } },
      { '@id': 'role:act', 'skos:prefLabel': { 'eng': 'Actor', 'deu': 'Schauspieler*in', 'ita': 'Attore' } },
      { '@id': 'role:adp', 'skos:prefLabel': { 'eng': 'Adapter', 'deu': 'Bearbeiter*in', 'ita': 'Adattatore' } },
      { '@id': 'role:rcp', 'skos:prefLabel': { 'eng': 'Addressee', 'deu': 'Empfänger*in', 'ita': 'Destinatario' } },
      { '@id': 'role:advisor', 'skos:prefLabel': { 'eng': 'Adviser', 'deu': 'Betreuer*in der Hochschulschrift', 'ita': 'Consigliere' } },
      { '@id': 'role:anl', 'skos:prefLabel': { 'eng': 'Analyst', 'deu': 'Analyst*in ', 'ita': 'Analista' } },
      { '@id': 'role:anm', 'skos:prefLabel': { 'eng': 'Animator', 'deu': 'Animator*in', 'ita': 'Animator' } },
      { '@id': 'role:ann', 'skos:prefLabel': { 'eng': 'Annotator', 'deu': 'Autor*in von Anmerkungen', 'ita': 'Annotatore' } },
      { '@id': 'role:app', 'skos:prefLabel': { 'eng': 'Applicant', 'deu': 'Antragsteller*in', 'ita': 'Applicant' } },
      { '@id': 'role:arc', 'skos:prefLabel': { 'eng': 'Architect', 'deu': 'Architekt*in', 'ita': 'Architetto' } },
      { '@id': 'role:arr', 'skos:prefLabel': { 'eng': 'Arranger', 'deu': 'Arrangeur*in', 'ita': 'Arrangiatore' } },
      { '@id': 'role:acp', 'skos:prefLabel': { 'eng': 'Art copyist', 'deu': 'Kunstkopist*in', 'ita': 'Art copyist' } },
      { '@id': 'role:adi', 'skos:prefLabel': { 'eng': 'Art director', 'deu': 'Szenenbildner*in', 'ita': 'Art director' } },
      { '@id': 'role:art', 'skos:prefLabel': { 'eng': 'Artist', 'deu': 'Künstler*in', 'ita': 'Artista' } },
      { '@id': 'role:ard', 'skos:prefLabel': { 'eng': 'Artistic director', 'deu': 'Intendant', 'ita': 'Direttore artistico' } },
      { '@id': 'role:assessor', 'skos:prefLabel': { 'eng': 'Assessor', 'deu': 'Beurteiler*in der Hochschulschrift', 'ita': 'Assessor' } },
      { '@id': 'role:asg', 'skos:prefLabel': { 'eng': 'Assignee', 'deu': 'Rechtsnachfolger*in', 'ita': 'Assignee' } },
      { '@id': 'role:asn', 'skos:prefLabel': { 'eng': 'Associated name', 'deu': 'Assoziierter Name', 'ita': 'Associated name' } },
      { '@id': 'role:att', 'skos:prefLabel': { 'eng': 'Attributed name', 'deu': 'Zugeschriebene/r Autor*in', 'ita': 'Nome attribuito' } },
      { '@id': 'role:auc', 'skos:prefLabel': { 'eng': 'Auctioneer', 'deu': 'Auktionator*in', 'ita': 'Auctioneer' } },
      { '@id': 'role:aut', 'skos:prefLabel': { 'eng': 'Author', 'deu': 'Autor*in', 'ita': 'Author' } },
      { '@id': 'role:aqt', 'skos:prefLabel': { 'eng': 'Author in quotations or text abstracts', 'deu': 'Autor*in in Zitaten oder Zusammenfassungen', 'ita': 'Author in quotations or text abstracts' } },
      { '@id': 'role:aft', 'skos:prefLabel': { 'eng': 'Author of afterword, colophon, etc.', 'deu': 'Autor*in des Nachworts, Kolophon…', 'ita': 'Author of afterword, colophon, etc.' } },
      { '@id': 'role:aud', 'skos:prefLabel': { 'eng': 'Author of dialog', 'deu': 'Autor*in eines Kommentars', 'ita': 'Autore del dialogo' } },
      { '@id': 'role:aui', 'skos:prefLabel': { 'eng': 'Author of introduction', 'deu': 'Autor*in der Einleitung', 'ita': 'Autore dell\'introduzione' } },
      { '@id': 'role:authorofsubtitles', 'skos:prefLabel': { 'eng': 'Author of subtitles', 'deu': 'Autor*in der Untertitel', 'ita': 'Autore dei sottotitoli' } },
      { '@id': 'role:ato', 'skos:prefLabel': { 'eng': 'Autographer', 'deu': 'Unterzeichnende/r', 'ita': 'Autographer' } },
      { '@id': 'role:ant', 'skos:prefLabel': { 'eng': 'Bibliographic antecedent', 'deu': 'Verfasser*in der literarischen Vorlage', 'ita': 'Antecedente bibliografico' } },
      { '@id': 'role:bnd', 'skos:prefLabel': { 'eng': 'Binder', 'deu': 'Buchbinder*in', 'ita': 'Legatore' } },
      { '@id': 'role:bdd', 'skos:prefLabel': { 'eng': 'Binding designer', 'deu': 'Buchbinde-Designer*in', 'ita': 'Binding designer' } },
      { '@id': 'role:blw', 'skos:prefLabel': { 'eng': 'Blurb writer (missing space)', 'deu': 'Autor*in des Klappentextes', 'ita': 'Blurbwriter' } },
      { '@id': 'role:bkd', 'skos:prefLabel': { 'eng': 'Book designer', 'deu': 'Buchgestalter*in', 'ita': 'Designer del libro' } },
      { '@id': 'role:bkp', 'skos:prefLabel': { 'eng': 'Book producer', 'deu': 'Buchproduzent*in', 'ita': 'Book producer' } },
      { '@id': 'role:bjd', 'skos:prefLabel': { 'eng': 'Bookjacket designer', 'deu': 'Designer*in des Buchumschlages / Schutzumschlages', 'ita': 'Bookjacket designer' } },
      { '@id': 'role:bpd', 'skos:prefLabel': { 'eng': 'Bookplate designer', 'deu': 'Designer*in des Exlibris', 'ita': 'Creatore dell\'ex-libris' } },
      { '@id': 'role:bsl', 'skos:prefLabel': { 'eng': 'Bookseller', 'deu': 'Buchhändler*in', 'ita': 'Bookseller' } },
      { '@id': 'role:brl', 'skos:prefLabel': { 'eng': 'Braille embosser', 'deu': 'Brailledrucker*in', 'ita': 'Braille embosser' } },
      { '@id': 'role:brd', 'skos:prefLabel': { 'eng': 'Broadcaster', 'deu': 'Rundfunkveranstalter*in', 'ita': 'Broadcaster' } },
      { '@id': 'role:cll', 'skos:prefLabel': { 'eng': 'Calligrapher', 'deu': 'Kalligraph*in', 'ita': 'Calligrapher' } },
      { '@id': 'role:ctg', 'skos:prefLabel': { 'eng': 'Cartographer', 'deu': 'Kartograph*in', 'ita': 'Cartografo' } },
      { '@id': 'role:cas', 'skos:prefLabel': { 'eng': 'Caster', 'deu': 'Gießer*in', 'ita': 'Caster' } },
      { '@id': 'role:cns', 'skos:prefLabel': { 'eng': 'Censor', 'deu': 'Zensor*in', 'ita': 'Censor' } },
      { '@id': 'role:chr', 'skos:prefLabel': { 'eng': 'Choreographer', 'deu': 'Choreograph*in', 'ita': 'Coreografo' } },
      { '@id': 'role:cng', 'skos:prefLabel': { 'eng': 'Cinematographer', 'deu': 'Kameramann/frau', 'ita': 'Direttore della fotografia' } },
      { '@id': 'role:cli', 'skos:prefLabel': { 'eng': 'Client', 'deu': 'Auftraggeber*in', 'ita': 'Client' } },
      { '@id': 'role:coadvisor', 'skos:prefLabel': { 'eng': 'Co-Advisor', 'deu': 'Mitbetreuer*in der Hochschulschrift', 'ita': 'Co-Advisor' } },
      { '@id': 'role:cor', 'skos:prefLabel': { 'eng': 'Collection registrar', 'deu': 'Registrar*in', 'ita': 'Collection registrar' } },
      { '@id': 'role:col', 'skos:prefLabel': { 'eng': 'Collector', 'deu': 'Sammler*in', 'ita': 'Collezionista' } },
      { '@id': 'role:clt', 'skos:prefLabel': { 'eng': 'Collotyper', 'deu': 'Lichtdrucker*in', 'ita': 'Collotyper' } },
      { '@id': 'role:clr', 'skos:prefLabel': { 'eng': 'Colorist', 'deu': 'Kolorist*in', 'ita': 'Colorist' } },
      { '@id': 'role:cmm', 'skos:prefLabel': { 'eng': 'Commentator', 'deu': 'Kommentator*in', 'ita': 'Commentator' } },
      { '@id': 'role:cwt', 'skos:prefLabel': { 'eng': 'Commentator for written text', 'deu': 'Kommentator*in eines geschriebenen Textes', 'ita': 'Commentator for written text' } },
      { '@id': 'role:com', 'skos:prefLabel': { 'eng': 'Compiler', 'deu': 'Ersteller*in einer Sammlung', 'ita': 'Compilatore' } },
      { '@id': 'role:cmp', 'skos:prefLabel': { 'eng': 'Composer', 'deu': 'Komponist*in', 'ita': 'Compositore' } },
      { '@id': 'role:cmt', 'skos:prefLabel': { 'eng': 'Compositor', 'deu': 'Schriftsetzer*in', 'ita': 'Compositor' } },
      { '@id': 'role:ccp', 'skos:prefLabel': { 'eng': 'Conceptor', 'deu': 'Konzepter*in', 'ita': 'Conceptor' } },
      { '@id': 'role:cnd', 'skos:prefLabel': { 'eng': 'Conductor', 'deu': 'Dirigent*in', 'ita': 'Direttore d’orchestra' } },
      { '@id': 'role:con', 'skos:prefLabel': { 'eng': 'Conservator', 'deu': 'Konservator*in', 'ita': 'Conservator' } },
      { '@id': 'role:csl', 'skos:prefLabel': { 'eng': 'Consultant', 'deu': 'Fachberater*in', 'ita': 'Consultant' } },
      { '@id': 'role:csp', 'skos:prefLabel': { 'eng': 'Consultant to a project', 'deu': 'Projektberater*in', 'ita': 'Consultant to a project' } },
      { '@id': 'role:ctr', 'skos:prefLabel': { 'eng': 'Contractor', 'deu': 'Vertragspartner*in', 'ita': 'Contractor' } },
      { '@id': 'role:ctb', 'skos:prefLabel': { 'eng': 'Contributor', 'deu': 'Mitwirkende/r', 'ita': 'Contributor' } },
      { '@id': 'role:copista', 'skos:prefLabel': { 'eng': 'Copista', 'deu': 'Copista', 'ita': 'Copista' } },
      { '@id': 'role:cpc', 'skos:prefLabel': { 'eng': 'Copyright claimant', 'deu': 'Anspruchsteller*in auf das Copyright', 'ita': 'Copyright claimant' } },
      { '@id': 'role:cph', 'skos:prefLabel': { 'eng': 'Copyright holder', 'deu': 'Inhaber*in des Copyright', 'ita': 'Copyright holder' } },
      { '@id': 'role:crr', 'skos:prefLabel': { 'eng': 'Corrector', 'deu': 'Korrektor*in', 'ita': 'Corrector' } },
      { '@id': 'role:crp', 'skos:prefLabel': { 'eng': 'Correspondent', 'deu': 'Teilnehmer*in einer Korrespondenz', 'ita': 'Correspondent' } },
      { '@id': 'role:cst', 'skos:prefLabel': { 'eng': 'Costume designer', 'deu': 'Kostümbildner*in', 'ita': 'Costume designer' } },
      { '@id': 'role:cov', 'skos:prefLabel': { 'eng': 'Cover designer', 'deu': 'Designer*in der Hüller / Verpackung', 'ita': 'Cover designer' } },
      { '@id': 'role:cur', 'skos:prefLabel': { 'eng': 'Curator', 'deu': 'Kurator*in', 'ita': 'Curator' } },
      { '@id': 'role:dnc', 'skos:prefLabel': { 'eng': 'Dancer', 'deu': 'Tänzer*in', 'ita': 'Dancer' } },
      { '@id': 'role:dtc', 'skos:prefLabel': { 'eng': 'Data contributor', 'deu': 'Datenlieferant*in', 'ita': 'Data contributor' } },
      { '@id': 'role:dtm', 'skos:prefLabel': { 'eng': 'Data manager', 'deu': 'Datenmanager*in', 'ita': 'Gestore di dati' } },
      { '@id': 'role:dte', 'skos:prefLabel': { 'eng': 'Dedicatee', 'deu': 'Widmungsträger*in', 'ita': 'Dedicatario' } },
      { '@id': 'role:dto', 'skos:prefLabel': { 'eng': 'Dedicator', 'deu': 'Widmende/r', 'ita': 'Dedicante' } },
      { '@id': 'role:dgg', 'skos:prefLabel': { 'eng': 'Degree granting institution', 'deu': 'Verleihende Institution des akademischen Abschlusses', 'ita': 'Istituzione che rilascia il titolo accademico' } },
      { '@id': 'role:dgs', 'skos:prefLabel': { 'eng': 'Degree supervisor', 'deu': 'Betreuer*in der Hochschulschrift', 'ita': 'Degree supervisor' } },
      { '@id': 'role:dln', 'skos:prefLabel': { 'eng': 'Delineator', 'deu': 'Entwurfszeichner*in', 'ita': 'Delineator' } },
      { '@id': 'role:dpc', 'skos:prefLabel': { 'eng': 'Depicted', 'deu': 'Dargestellt / beschrieben', 'ita': 'Depicted' } },
      { '@id': 'role:dpt', 'skos:prefLabel': { 'eng': 'Depositor', 'deu': 'Depositor*in', 'ita': 'Depositor' } },
      { '@id': 'role:dsr', 'skos:prefLabel': { 'eng': 'Designer', 'deu': 'Designer*in', 'ita': 'Designer' } },
      { '@id': 'role:digitiser', 'skos:prefLabel': { 'eng': 'Digitiser', 'deu': 'Digitalisierer*in', 'ita': 'Autore della digitalizzazione' } },
      { '@id': 'role:drt', 'skos:prefLabel': { 'eng': 'Director', 'deu': 'Produktionsleiter*in', 'ita': 'Director' } },
      { '@id': 'role:dis', 'skos:prefLabel': { 'eng': 'Dissertant', 'deu': 'Verfasser*in der Hochschulschrift', 'ita': 'Tesista' } },
      { '@id': 'role:dbp', 'skos:prefLabel': { 'eng': 'Distribution place', 'deu': 'Vertriebsort', 'ita': 'Distribution place' } },
      { '@id': 'role:dst', 'skos:prefLabel': { 'eng': 'Distributor', 'deu': 'Distributor*in', 'ita': 'Distributore' } },
      { '@id': 'role:domainexpert', 'skos:prefLabel': { 'eng': 'Domain Expert', 'deu': 'Fachexpert*in', 'ita': 'Esperto del settore' } },
      { '@id': 'role:dnr', 'skos:prefLabel': { 'eng': 'Donor', 'deu': 'Stifter*in', 'ita': 'Donatore' } },
      { '@id': 'role:drm', 'skos:prefLabel': { 'eng': 'Draftsman', 'deu': 'Technische/r Zeichner*in', 'ita': 'Draftsman' } },
      { '@id': 'role:dub', 'skos:prefLabel': { 'eng': 'Dubious author', 'deu': 'Zweifelhafte Autor*in', 'ita': 'Autore incerto' } },
      { '@id': 'role:edt', 'skos:prefLabel': { 'eng': 'Editor', 'deu': 'Herausgeber*in', 'ita': 'Curatore' } },
      { '@id': 'role:edc', 'skos:prefLabel': { 'eng': 'Editor of compilation', 'deu': 'Herausgeber*in eines Sammelwerks', 'ita': 'Editor of compilation' } },
      { '@id': 'role:edm', 'skos:prefLabel': { 'eng': 'Editor of moving image work', 'deu': 'Filmeditor*in', 'ita': 'Editor of moving image work' } },
      { '@id': 'role:elg', 'skos:prefLabel': { 'eng': 'Electrician', 'deu': 'Lichtechniker*in', 'ita': 'Electrician' } },
      { '@id': 'role:elt', 'skos:prefLabel': { 'eng': 'Electrotyper', 'deu': 'Galvanoplastiker*in', 'ita': 'Electrotyper' } },
      { '@id': 'role:enj', 'skos:prefLabel': { 'eng': 'Enacting jurisdiction', 'deu': 'Verfügende / verordnende Jurisdiktion', 'ita': 'Enacting jurisdiction' } },
      { '@id': 'role:eng', 'skos:prefLabel': { 'eng': 'Engineer', 'deu': 'Ingenieur*in', 'ita': 'Ingegnere' } },
      { '@id': 'role:egr', 'skos:prefLabel': { 'eng': 'Engraver', 'deu': 'Graveur*in', 'ita': 'Incisore' } },
      { '@id': 'role:etr', 'skos:prefLabel': { 'eng': 'Etcher', 'deu': 'Radierer*in', 'ita': 'Acquafortista' } },
      { '@id': 'role:evaluator', 'skos:prefLabel': { 'eng': 'Evaluator', 'deu': 'Evaluator*in', 'ita': 'Valutatore' } },
      { '@id': 'role:exp', 'skos:prefLabel': { 'eng': 'Expert', 'deu': 'Expert*in / Sachverständige/r', 'ita': 'Expert' } },
      { '@id': 'role:fac', 'skos:prefLabel': { 'eng': 'Facsimilist', 'deu': 'Ersteller*in des Faksimile', 'ita': 'Responsabile del facsimile' } },
      { '@id': 'role:fld', 'skos:prefLabel': { 'eng': 'Field director', 'deu': 'Leiter*in der Feldforschung', 'ita': 'Field director' } },
      { '@id': 'role:fmd', 'skos:prefLabel': { 'eng': 'Film director', 'deu': 'Filmregisseur*in', 'ita': 'Film director' } },
      { '@id': 'role:fds', 'skos:prefLabel': { 'eng': 'Film distributor', 'deu': 'Filmverleiher*in', 'ita': 'Film distributor' } },
      { '@id': 'role:flm', 'skos:prefLabel': { 'eng': 'Film editor', 'deu': 'Filmeditor*in', 'ita': 'Responsabile del montaggio' } },
      { '@id': 'role:fmp', 'skos:prefLabel': { 'eng': 'Film producer', 'deu': 'Filmproduzent*in', 'ita': 'Film producer' } },
      { '@id': 'role:fmk', 'skos:prefLabel': { 'eng': 'Filmmaker', 'deu': 'Filmemacher*in', 'ita': 'Filmmaker' } },
      { '@id': 'role:fpy', 'skos:prefLabel': { 'eng': 'First party', 'deu': 'Erste Vertragspartei', 'ita': 'First party' } },
      { '@id': 'role:frg', 'skos:prefLabel': { 'eng': 'Forger', 'deu': 'Fälscher*in', 'ita': 'Forger' } },
      { '@id': 'role:fmo', 'skos:prefLabel': { 'eng': 'Former owner', 'deu': 'Ehemalige/r Eigentümer*in', 'ita': 'Precedente proprietario' } },
      { '@id': 'role:founder', 'skos:prefLabel': { 'eng': 'Founder', 'deu': 'Gründer*in', 'ita': 'Founder' } },
      { '@id': 'role:fon', 'skos:prefLabel': { 'eng': 'Founder', 'deu': 'Gründer*in', 'ita': 'Founder' } },
      { '@id': 'role:fnd', 'skos:prefLabel': { 'eng': 'Funder', 'deu': 'Geldgeber*in', 'ita': 'Funder' } },
      { '@id': 'role:gis', 'skos:prefLabel': { 'eng': 'Geographic information specialist', 'deu': 'Spezialist*in für geografische Informationen', 'ita': 'Field director' } },
      { '@id': 'role:graphicdesigner', 'skos:prefLabel': { 'eng': 'Graphic Designer', 'deu': 'Grafikdesigner*in', 'ita': 'Grafico' } },
      { '@id': 'role:hnr', 'skos:prefLabel': { 'eng': 'Honoree', 'deu': 'Geehrte/r, Jubilar*in', 'ita': 'Onorato' } },
      { '@id': 'role:hst', 'skos:prefLabel': { 'eng': 'Host', 'deu': 'Gastgeber*in', 'ita': 'Host' } },
      { '@id': 'role:his', 'skos:prefLabel': { 'eng': 'Host institution', 'deu': 'Gastgebende Institution', 'ita': 'Host institution' } },
      { '@id': 'role:ilu', 'skos:prefLabel': { 'eng': 'Illuminator', 'deu': 'Buchmaler*in', 'ita': 'Miniatore' } },
      { '@id': 'role:ill', 'skos:prefLabel': { 'eng': 'Illustrator', 'deu': 'Illustrator*in', 'ita': 'Illustratore' } },
      { '@id': 'role:initiator', 'skos:prefLabel': { 'eng': 'Initiator', 'deu': 'Initiator*in', 'ita': 'Iniziatore' } },
      { '@id': 'role:ins', 'skos:prefLabel': { 'eng': 'Inscriber', 'deu': 'Widmende/r', 'ita': 'Inscriber' } },
      { '@id': 'role:itr', 'skos:prefLabel': { 'eng': 'Instrumentalist', 'deu': 'Instrumentalist*in', 'ita': 'Instrumentalist' } },
      { '@id': 'role:interpreter', 'skos:prefLabel': { 'eng': 'Interpreter', 'deu': 'Dolmetscher*in', 'ita': 'Interprete' } },
      { '@id': 'role:ive', 'skos:prefLabel': { 'eng': 'Interviewee', 'deu': 'Interviewpartner*in', 'ita': 'Intervistato' } },
      { '@id': 'role:ivr', 'skos:prefLabel': { 'eng': 'Interviewer', 'deu': 'Interviewer*in', 'ita': 'Intervistatore' } },
      { '@id': 'role:inv', 'skos:prefLabel': { 'eng': 'Inventor', 'deu': 'Erfinder*in', 'ita': 'Inventor' } },
      { '@id': 'role:isb', 'skos:prefLabel': { 'eng': 'Issuing body', 'deu': 'Herausgebende Körperschaft', 'ita': 'Issuing body' } },
      { '@id': 'role:keeperoftheoriginal', 'skos:prefLabel': { 'eng': 'Keeper of the original', 'deu': 'Aufbewahrer*in des Originals', 'ita': 'Affidatario dell\'originale' } },
      { '@id': 'role:lbr', 'skos:prefLabel': { 'eng': 'Laboratory', 'deu': 'Labor', 'ita': 'Laboratory' } },
      { '@id': 'role:ldr', 'skos:prefLabel': { 'eng': 'Laboratory director', 'deu': 'Laborleiter*in', 'ita': 'Laboratory director' } },
      { '@id': 'role:lsa', 'skos:prefLabel': { 'eng': 'Landscape architect', 'deu': 'Landschaftsarchitekt*in', 'ita': 'Landscape architect' } },
      { '@id': 'role:led', 'skos:prefLabel': { 'eng': 'Lead', 'deu': 'Leitung', 'ita': 'Lead' } },
      { '@id': 'role:len', 'skos:prefLabel': { 'eng': 'Lender', 'deu': 'Leihgeber', 'ita': 'Lender' } },
      { '@id': 'role:lbt', 'skos:prefLabel': { 'eng': 'Librettist', 'deu': 'Librettist*in', 'ita': 'Librettista' } },
      { '@id': 'role:lse', 'skos:prefLabel': { 'eng': 'Licensee', 'deu': 'Lizenznehmer*in', 'ita': 'Licensee' } },
      { '@id': 'role:lso', 'skos:prefLabel': { 'eng': 'Licensor', 'deu': 'Lizenzgeber*in', 'ita': 'Licensor' } },
      { '@id': 'role:lgd', 'skos:prefLabel': { 'eng': 'Lighting designer', 'deu': 'Lichtgestalter*in', 'ita': 'Lighting designer' } },
      { '@id': 'role:ltg', 'skos:prefLabel': { 'eng': 'Lithographer', 'deu': 'Lithograph*in', 'ita': 'Litografo' } },
      { '@id': 'role:lyr', 'skos:prefLabel': { 'eng': 'Lyricist', 'deu': 'Liedtexter*in', 'ita': 'Paroliere' } },
      { '@id': 'role:mfp', 'skos:prefLabel': { 'eng': 'Manufacture place', 'deu': 'Herstellungsort', 'ita': 'Manufacture place' } },
      { '@id': 'role:mfr', 'skos:prefLabel': { 'eng': 'Manufacturer', 'deu': 'Hersteller*in', 'ita': 'Manufacturer' } },
      { '@id': 'role:mrb', 'skos:prefLabel': { 'eng': 'Marbler', 'deu': 'Marmorier*in', 'ita': 'Marbler' } },
      { '@id': 'role:mrk', 'skos:prefLabel': { 'eng': 'Markup editor', 'deu': 'Markup-Editor*in', 'ita': 'Markup editor' } },
      { '@id': 'role:med', 'skos:prefLabel': { 'eng': 'Medium', 'deu': 'Medium', 'ita': 'Medium' } },
      { '@id': 'role:mdc', 'skos:prefLabel': { 'eng': 'Metadata contact', 'deu': 'Metadaten-Editor*in', 'ita': 'Metadata contact' } },
      { '@id': 'role:emt', 'skos:prefLabel': { 'eng': 'Metal-engraver', 'deu': 'Metallstecher*in', 'ita': 'Calcografo' } },
      { '@id': 'role:mtk', 'skos:prefLabel': { 'eng': 'Minute taker', 'deu': 'Protokollführer*in', 'ita': 'Minute taker' } },
      { '@id': 'role:mod', 'skos:prefLabel': { 'eng': 'Moderator', 'deu': 'Diskussionsleiter*in', 'ita': 'Moderator' } },
      { '@id': 'role:mon', 'skos:prefLabel': { 'eng': 'Monitor', 'deu': 'Vertragsprüfer*in', 'ita': 'Monitor' } },
      { '@id': 'role:mcp', 'skos:prefLabel': { 'eng': 'Music copyist', 'deu': 'Musikkopist*in', 'ita': 'Music copyist' } },
      { '@id': 'role:msd', 'skos:prefLabel': { 'eng': 'Musical director', 'deu': 'Musikalische/r Leiter*in', 'ita': 'Direttore musicale' } },
      { '@id': 'role:mus', 'skos:prefLabel': { 'eng': 'Musician', 'deu': 'Musiker*in', 'ita': 'Musicista' } },
      { '@id': 'role:nrt', 'skos:prefLabel': { 'eng': 'Narrator', 'deu': 'Erzähler*in', 'ita': 'Narrator' } },
      { '@id': 'role:osp', 'skos:prefLabel': { 'eng': 'Onscreen presenter', 'deu': 'Fernsehmoderator*in', 'ita': 'Onscreen presenter' } },
      { '@id': 'role:opn', 'skos:prefLabel': { 'eng': 'Opponent', 'deu': 'Opponent*in bei akademischen Prüfungen', 'ita': 'Controrelatore' } },
      { '@id': 'role:orm', 'skos:prefLabel': { 'eng': 'Organizer', 'deu': 'Veranstalter*in', 'ita': 'Organizer' } },
      { '@id': 'role:org', 'skos:prefLabel': { 'eng': 'Originator', 'deu': 'Schöpfer*in / Urheber*in ', 'ita': 'Originator' } },
      { '@id': 'role:own', 'skos:prefLabel': { 'eng': 'Owner', 'deu': 'Eigentümer*in', 'ita': 'Proprietario' } },
      { '@id': 'role:pan', 'skos:prefLabel': { 'eng': 'Panelist', 'deu': 'Diskussionsteilnehmer*in', 'ita': 'Panelist' } },
      { '@id': 'role:ppm', 'skos:prefLabel': { 'eng': 'Papermaker', 'deu': 'Papiermacher*in', 'ita': 'Papermaker' } },
      { '@id': 'role:pta', 'skos:prefLabel': { 'eng': 'Patent applicant', 'deu': 'Patentantragsteller*in', 'ita': 'Patent applicant' } },
      { '@id': 'role:pth', 'skos:prefLabel': { 'eng': 'Patent holder', 'deu': 'Patentinhaber*in', 'ita': 'Patent holder' } },
      { '@id': 'role:pat', 'skos:prefLabel': { 'eng': 'Patron', 'deu': 'Schirmherr*in / Förderer*in', 'ita': 'Patron' } },
      { '@id': 'role:pedagogicexpert', 'skos:prefLabel': { 'eng': 'Pedagogic Expert', 'deu': 'Pädagogische/r Expert*in', 'ita': 'Esperto pedagogico' } },
      { '@id': 'role:prf', 'skos:prefLabel': { 'eng': 'Performer', 'deu': 'Performer / Künstler*in', 'ita': 'Performer' } },
      { '@id': 'role:pma', 'skos:prefLabel': { 'eng': 'Permitting agency', 'deu': 'Genehmigungsbehörde', 'ita': 'Permitting agency' } },
      { '@id': 'role:pht', 'skos:prefLabel': { 'eng': 'Photographer', 'deu': 'Fotograf*in', 'ita': 'Fotografo' } },
      { '@id': 'role:plt', 'skos:prefLabel': { 'eng': 'Platemaker', 'deu': 'Druckplattenhersteller*in allgemein', 'ita': 'Platemaker' } },
      { '@id': 'role:pra', 'skos:prefLabel': { 'eng': 'Praeses', 'deu': 'Präses', 'ita': 'Praeses' } },
      { '@id': 'role:pre', 'skos:prefLabel': { 'eng': 'Presenter', 'deu': 'Präsentator*in', 'ita': 'Presenter' } },
      { '@id': 'role:prt', 'skos:prefLabel': { 'eng': 'Printer', 'deu': 'Drucker*in', 'ita': 'Stampatore' } },
      { '@id': 'role:pop', 'skos:prefLabel': { 'eng': 'Printer of plates', 'deu': 'Plattendrucker*in', 'ita': 'Printer of plates' } },
      { '@id': 'role:prm', 'skos:prefLabel': { 'eng': 'Printmaker', 'deu': 'Druckplattenhersteller*in (Tief-, Hoch-, Flachdruck)', 'ita': 'Printmaker' } },
      { '@id': 'role:prc', 'skos:prefLabel': { 'eng': 'Process contact', 'deu': 'Ansprechpartner*in', 'ita': 'Process contact' } },
      { '@id': 'role:pro', 'skos:prefLabel': { 'eng': 'Producer', 'deu': 'Produzent*in', 'ita': 'Produttore' } },
      { '@id': 'role:prn', 'skos:prefLabel': { 'eng': 'Production company', 'deu': 'Produktionsfirma', 'ita': 'Production company' } },
      { '@id': 'role:prp', 'skos:prefLabel': { 'eng': 'Production place', 'deu': 'Produktionsort', 'ita': 'Production place' } },
      { '@id': 'role:prs', 'skos:prefLabel': { 'eng': 'Production designer', 'deu': 'Produktionsdesigner*in', 'ita': 'Production designer' } },
      { '@id': 'role:pmn', 'skos:prefLabel': { 'eng': 'Production manager', 'deu': 'Produktionsmanager*in', 'ita': 'Production manager' } },
      { '@id': 'role:prd', 'skos:prefLabel': { 'eng': 'Production personnel', 'deu': 'Produktionspersonal', 'ita': 'Production personnel' } },
      { '@id': 'role:prg', 'skos:prefLabel': { 'eng': 'Programmer', 'deu': 'Programmierer*in', 'ita': 'Programmer' } },
      { '@id': 'role:pdr', 'skos:prefLabel': { 'eng': 'Project director', 'deu': 'Projektleiter*in', 'ita': 'Project director' } },
      { '@id': 'role:pfr', 'skos:prefLabel': { 'eng': 'Proofreader', 'deu': 'Lektor*in', 'ita': 'Correttore' } },
      { '@id': 'role:prv', 'skos:prefLabel': { 'eng': 'Provider', 'deu': 'Anbieter*in / Lieferant*in', 'ita': 'Provider' } },
      { '@id': 'role:pbl', 'skos:prefLabel': { 'eng': 'Publisher', 'deu': 'Verleger*in', 'ita': 'Editore' } },
      { '@id': 'role:pbd', 'skos:prefLabel': { 'eng': 'Publishing director', 'deu': 'Verlagsleiter*in', 'ita': 'Publishing director' } },
      { '@id': 'role:ppt', 'skos:prefLabel': { 'eng': 'Puppeteer', 'deu': 'Puppenspieler*in', 'ita': 'Puppeteer' } },
      { '@id': 'role:rdd', 'skos:prefLabel': { 'eng': 'Radio director', 'deu': 'Radio-, Hörfunkdirektor*in', 'ita': 'Radio director' } },
      { '@id': 'role:rpc', 'skos:prefLabel': { 'eng': 'Radio producer', 'deu': 'Radioproduzent*in', 'ita': 'Radio producer' } },
      { '@id': 'role:rce', 'skos:prefLabel': { 'eng': 'Recording engineer', 'deu': 'Toningenieur*in', 'ita': 'Tecnico della registrazione' } },
      { '@id': 'role:rcd', 'skos:prefLabel': { 'eng': 'Recordist', 'deu': 'Tonaufnahmetechniker*in', 'ita': 'Recordist' } },
      { '@id': 'role:red', 'skos:prefLabel': { 'eng': 'Redaktor', 'deu': 'Redakteur*in', 'ita': 'Redaktor' } },
      { '@id': 'role:ren', 'skos:prefLabel': { 'eng': 'Renderer', 'deu': 'Reinzeichner*in', 'ita': 'Renderer' } },
      { '@id': 'role:rpt', 'skos:prefLabel': { 'eng': 'Reporter', 'deu': 'Reporter*in / Berichterstatter*in', 'ita': 'Reporter' } },
      { '@id': 'role:rth', 'skos:prefLabel': { 'eng': 'Research team head', 'deu': 'Leiter*in eines Forschungsteams', 'ita': 'Direttore della ricerca' } },
      { '@id': 'role:rtm', 'skos:prefLabel': { 'eng': 'Research team member', 'deu': 'Mitarbeiter*in des Forschungsteams', 'ita': 'Membro di un gruppo di ricerca' } },
      { '@id': 'role:res', 'skos:prefLabel': { 'eng': 'Researcher', 'deu': 'Forscher*in', 'ita': 'Ricercatore' } },
      { '@id': 'role:rsp', 'skos:prefLabel': { 'eng': 'Respondent', 'deu': 'Befragte/r bei akademischer Prüfung', 'ita': 'Respondent' } },
      { '@id': 'role:rst', 'skos:prefLabel': { 'eng': 'Respondent-appellant', 'deu': 'Respondent-appellant', 'ita': 'Respondent-appellant' } },
      { '@id': 'role:rse', 'skos:prefLabel': { 'eng': 'Respondent-appellee', 'deu': 'Respondent-appellee', 'ita': 'Respondent-appellee' } },
      { '@id': 'role:rpy', 'skos:prefLabel': { 'eng': 'Responsible party', 'deu': 'Rechtlich verantwortliche Partei', 'ita': 'Responsible party' } },
      { '@id': 'role:rsg', 'skos:prefLabel': { 'eng': 'Restager', 'deu': 'Wiederaufführung', 'ita': 'Restager' } },
      { '@id': 'role:rsr', 'skos:prefLabel': { 'eng': 'Restorationist', 'deu': 'Restaurator*in', 'ita': 'Restorationist' } },
      { '@id': 'role:rev', 'skos:prefLabel': { 'eng': 'Reviewer', 'deu': 'Kritiker*in', 'ita': 'Recensore' } },
      { '@id': 'role:rbr', 'skos:prefLabel': { 'eng': 'Rubricator', 'deu': 'Rubrikator*in', 'ita': 'Rubricator' } },
      { '@id': 'role:sce', 'skos:prefLabel': { 'eng': 'Scenarist', 'deu': 'Szenarist*in', 'ita': 'Scenografo' } },
      { '@id': 'role:sad', 'skos:prefLabel': { 'eng': 'Scientific advisor', 'deu': 'Wissenschaftliche Berater*in', 'ita': 'Consulente scientifico' } },
      { '@id': 'role:aus', 'skos:prefLabel': { 'eng': 'Screenwriter', 'deu': 'Drehbuchautor*in', 'ita': 'Sceneggiatore' } },
      { '@id': 'role:scr', 'skos:prefLabel': { 'eng': 'Scribe', 'deu': 'Skriptor*in', 'ita': 'Scribe' } },
      { '@id': 'role:scl', 'skos:prefLabel': { 'eng': 'Sculptor', 'deu': 'Bildhauer*in', 'ita': 'Scultore' } },
      { '@id': 'role:spy', 'skos:prefLabel': { 'eng': 'Second party', 'deu': 'Zweite Vertragspartei', 'ita': 'Second party' } },
      { '@id': 'role:sec', 'skos:prefLabel': { 'eng': 'Secretary', 'deu': 'Sekretär*in (Funktion)', 'ita': 'Secretary' } },
      { '@id': 'role:sll', 'skos:prefLabel': { 'eng': 'Seller', 'deu': 'Verkäufer*in', 'ita': 'Seller' } },
      { '@id': 'role:std', 'skos:prefLabel': { 'eng': 'Set designer', 'deu': 'Bühnenbildner*in / Filmarchitekt', 'ita': 'Set designer' } },
      { '@id': 'role:stg', 'skos:prefLabel': { 'eng': 'Setting', 'deu': 'Schauplatz / Handlungsraum', 'ita': 'Setting' } },
      { '@id': 'role:sgn', 'skos:prefLabel': { 'eng': 'Signer', 'deu': 'Unterzeichner*in', 'ita': 'Signer' } },
      { '@id': 'role:sng', 'skos:prefLabel': { 'eng': 'Singer', 'deu': 'Sänger*in', 'ita': 'Cantante' } },
      { '@id': 'role:sds', 'skos:prefLabel': { 'eng': 'Sound designer', 'deu': 'Sounddesigner*in', 'ita': 'Progettista del suono' } },
      { '@id': 'role:spk', 'skos:prefLabel': { 'eng': 'Speaker / Lecturer', 'deu': 'Sprecher*in / Vortragende/r', 'ita': 'Speaker' } },
      { '@id': 'role:spn', 'skos:prefLabel': { 'eng': 'Sponsor', 'deu': 'Sponsor', 'ita': 'Sponsor' } },
      { '@id': 'role:sgd', 'skos:prefLabel': { 'eng': 'Stage director', 'deu': 'Theaterregisseur*in', 'ita': 'Stage director' } },
      { '@id': 'role:stm', 'skos:prefLabel': { 'eng': 'Stage manager', 'deu': 'Inspizient*in / Bühnenmeister*in', 'ita': 'Stage manager' } },
      { '@id': 'role:stn', 'skos:prefLabel': { 'eng': 'Standards body', 'deu': 'Normkomitee', 'ita': 'Standards body' } },
      { '@id': 'role:str', 'skos:prefLabel': { 'eng': 'Stereotyper', 'deu': 'Stereotypieplattenhersteller', 'ita': 'Stereotyper' } },
      { '@id': 'role:stl', 'skos:prefLabel': { 'eng': 'Storyteller', 'deu': 'Geschichtenerzähler', 'ita': 'Storyteller' } },
      { '@id': 'role:sht', 'skos:prefLabel': { 'eng': 'Supporting host', 'deu': 'Unterstützer*in', 'ita': 'Supporting host' } },
      { '@id': 'role:srv', 'skos:prefLabel': { 'eng': 'Surveyor', 'deu': 'Landvermesser*in', 'ita': 'Surveyor' } },
      { '@id': 'role:tch', 'skos:prefLabel': { 'eng': 'Teacher', 'deu': 'Lehrer*in', 'ita': 'Teacher' } },
      { '@id': 'role:tcd', 'skos:prefLabel': { 'eng': 'Technical director', 'deu': 'Technische/r Direktor*in', 'ita': 'Technical director' } },
      { '@id': 'role:technicalinspector', 'skos:prefLabel': { 'eng': 'Technical Inspector', 'deu': 'Technische/r Prüfer*in', 'ita': 'Ispettore tecnico' } },
      { '@id': 'role:technicaltranslator', 'skos:prefLabel': { 'eng': 'Technical Translator', 'deu': 'Technische/r Übersetzer*in', 'ita': 'Traduttore Tecnico' } },
      { '@id': 'role:tld', 'skos:prefLabel': { 'eng': 'Television director', 'deu': 'Fernsehintendant*in', 'ita': 'Television director' } },
      { '@id': 'role:tlp', 'skos:prefLabel': { 'eng': 'Television producer', 'deu': 'Fernsehproduzent*in', 'ita': 'Television producer' } },
      { '@id': 'role:textprocessor', 'skos:prefLabel': { 'eng': 'Text Processor', 'deu': 'Textbearbeiter*in', 'ita': 'Estensore del testo' } },
      { '@id': 'role:ths', 'skos:prefLabel': { 'eng': 'Thesis advisor', 'deu': 'Dissertationsbetreuer*in', 'ita': 'Relatore' } },
      { '@id': 'role:trc', 'skos:prefLabel': { 'eng': 'Transcriber', 'deu': 'Transkriptor*in von Noten', 'ita': 'Transcriber' } },
      { '@id': 'role:trl', 'skos:prefLabel': { 'eng': 'Translator', 'deu': 'Übersetzer*in', 'ita': 'Traduttore' } },
      { '@id': 'role:tyd', 'skos:prefLabel': { 'eng': 'Type designer', 'deu': 'Schriftdesigner*in / Schriftentwerfer*in', 'ita': 'Type designer' } },
      { '@id': 'role:tyg', 'skos:prefLabel': { 'eng': 'Typographer', 'deu': 'Typograph*in', 'ita': 'Tipografo' } },
      { '@id': 'role:uploader', 'skos:prefLabel': { 'eng': 'Uploader', 'deu': 'Uploader', 'ita': 'Uploader' } },
      { '@id': 'role:vdg', 'skos:prefLabel': { 'eng': 'Videographer', 'deu': 'Videofilmer*in', 'ita': 'Videografo' } },
      { '@id': 'role:vac', 'skos:prefLabel': { 'eng': 'Voice actor', 'deu': 'Synchron-, Sprecher*in', 'ita': 'Voice actor' } },
      { '@id': 'role:wit', 'skos:prefLabel': { 'eng': 'Witness', 'deu': 'Zeug*in', 'ita': 'Witness' } },
      { '@id': 'role:wde', 'skos:prefLabel': { 'eng': 'Wood-engraver', 'deu': 'Holzstecher*in', 'ita': 'Xilografo' } },
      { '@id': 'role:wdc', 'skos:prefLabel': { 'eng': 'Woodcutter', 'deu': 'Holzschneider*in', 'ita': 'Woodcutter' } },
      { '@id': 'role:wam', 'skos:prefLabel': { 'eng': 'Writer of accompanying material', 'deu': 'Autor*in von Begleitmaterial', 'ita': 'Autore del materiale allegato' } },
      { '@id': 'role:wac', 'skos:prefLabel': { 'eng': 'Writer of added commentary', 'deu': 'Autor*in von zusätzlichen Kommentaren', 'ita': 'Writer of added commentary' } },
      { '@id': 'role:wal', 'skos:prefLabel': { 'eng': 'Writer of added lyrics', 'deu': 'Autor*in von zusätzlichen Texten zu musikalischen Werken ', 'ita': 'Writer of added lyrics' } },
      { '@id': 'role:wat', 'skos:prefLabel': { 'eng': 'Writer of added text', 'deu': 'Autor*in von zusätzlichen Texten zu nichtextlichen Werken', 'ita': 'Writer of added text' } },
      { '@id': 'role:win', 'skos:prefLabel': { 'eng': 'Writer of introduction', 'deu': 'Autor*in der Einführung', 'ita': 'Writer of introduction' } },
      { '@id': 'role:wpr', 'skos:prefLabel': { 'eng': 'Writer of preface', 'deu': 'Autor*in des Vorwortes', 'ita': 'Writer of preface' } },
      { '@id': 'role:wst', 'skos:prefLabel': { 'eng': 'Writer of supplementary textual content', 'deu': 'Autor*in von ergänzendem Textinhalt', 'ita': 'Writer of supplementary textual content' } }
    ],
    loaded: true
  },
  'irrolepredicate': {
    terms: [
      { '@id': 'role:aut', 'skos:prefLabel': { 'eng': 'Author', 'deu': 'Autor*in', 'ita': 'Author' } },
      { '@id': 'role:edt', 'skos:prefLabel': { 'eng': 'Editor', 'deu': 'Herausgeber*in', 'ita': 'Curatore' } }
    ],
    loaded: true
  },
  'editoronlyrolepredicate': {
    terms: [
      { '@id': 'role:edt', 'skos:prefLabel': { 'eng': 'Editor', 'deu': 'Herausgeber*in', 'ita': 'Curatore' } }
    ],
    loaded: true
  },
  'submitrolepredicate': {
    terms: [
      { '@id': 'role:oth', 'skos:prefLabel': { 'eng': 'Other', 'deu': 'Andere', 'ita': 'Altro' } },
      { '@id': 'role:adp', 'skos:prefLabel': { 'eng': 'Adapter', 'deu': 'Bearbeiter*in', 'ita': 'Adattatore' } },
      { '@id': 'role:arc', 'skos:prefLabel': { 'eng': 'Architect', 'deu': 'Architekt*in', 'ita': 'Architetto' } },
      { '@id': 'role:art', 'skos:prefLabel': { 'eng': 'Artist', 'deu': 'Künstler*in', 'ita': 'Artista' } },
      { '@id': 'role:att', 'skos:prefLabel': { 'eng': 'Attributed name', 'deu': 'Zugeschriebene/r Autor*in', 'ita': 'Nome attribuito' } },
      { '@id': 'role:aut', 'skos:prefLabel': { 'eng': 'Author', 'deu': 'Autor*in', 'ita': 'Author' } },
      { '@id': 'role:chr', 'skos:prefLabel': { 'eng': 'Choreographer', 'deu': 'Choreograph*in', 'ita': 'Coreografo' } },
      { '@id': 'role:col', 'skos:prefLabel': { 'eng': 'Collector', 'deu': 'Sammler*in', 'ita': 'Collezionista' } },
      { '@id': 'role:cmp', 'skos:prefLabel': { 'eng': 'Composer', 'deu': 'Komponist*in', 'ita': 'Compositore' } },
      { '@id': 'role:cnd', 'skos:prefLabel': { 'eng': 'Conductor', 'deu': 'Dirigent*in', 'ita': 'Direttore d’orchestra' } },
      { '@id': 'role:con', 'skos:prefLabel': { 'eng': 'Conservator', 'deu': 'Konservator*in', 'ita': 'Conservator' } },
      { '@id': 'role:dnc', 'skos:prefLabel': { 'eng': 'Dancer', 'deu': 'Tänzer*in', 'ita': 'Dancer' } },
      { '@id': 'role:dtc', 'skos:prefLabel': { 'eng': 'Data contributor', 'deu': 'Datenlieferant*in', 'ita': 'Data contributor' } },
      { '@id': 'role:dgg', 'skos:prefLabel': { 'eng': 'Degree granting institution', 'deu': 'Verleihende Institution des akademischen Abschlusses', 'ita': 'Istituzione che rilascia il titolo accademico' } },
      { '@id': 'role:dgs', 'skos:prefLabel': { 'eng': 'Degree supervisor', 'deu': 'Betreuer*in der Hochschulschrift', 'ita': 'Degree supervisor' } },
      { '@id': 'role:dsr', 'skos:prefLabel': { 'eng': 'Designer', 'deu': 'Designer*in', 'ita': 'Designer' } },
      { '@id': 'role:digitiser', 'skos:prefLabel': { 'eng': 'Digitiser', 'deu': 'Digitalisierer*in', 'ita': 'Autore della digitalizzazione' } },
      { '@id': 'role:dis', 'skos:prefLabel': { 'eng': 'Dissertant', 'deu': 'Verfasser*in der Hochschulschrift', 'ita': 'Tesista' } },
      { '@id': 'role:edt', 'skos:prefLabel': { 'eng': 'Editor', 'deu': 'Herausgeber*in', 'ita': 'Curatore' } },
      { '@id': 'role:fmd', 'skos:prefLabel': { 'eng': 'Film director', 'deu': 'Filmregisseur*in', 'ita': 'Film director' } },
      { '@id': 'role:fon', 'skos:prefLabel': { 'eng': 'Founder', 'deu': 'Gründer*in', 'ita': 'Founder' } },
      { '@id': 'role:fnd', 'skos:prefLabel': { 'eng': 'Funder', 'deu': 'Geldgeber*in', 'ita': 'Funder' } },
      { '@id': 'role:graphicdesigner', 'skos:prefLabel': { 'eng': 'Graphic Designer', 'deu': 'Grafikdesigner*in', 'ita': 'Grafico' } },
      { '@id': 'role:interpreter', 'skos:prefLabel': { 'eng': 'Interpreter', 'deu': 'Dolmetscher*in', 'ita': 'Interprete' } },
      { '@id': 'role:ive', 'skos:prefLabel': { 'eng': 'Interviewee', 'deu': 'Interviewpartner*in', 'ita': 'Intervistato' } },
      { '@id': 'role:ivr', 'skos:prefLabel': { 'eng': 'Interviewer', 'deu': 'Interviewer*in', 'ita': 'Intervistatore' } },
      { '@id': 'role:keeperoftheoriginal', 'skos:prefLabel': { 'eng': 'Keeper of the original', 'deu': 'Aufbewahrer*in des Originals', 'ita': 'Affidatario dell\'originale' } },
      { '@id': 'role:led', 'skos:prefLabel': { 'eng': 'Lead', 'deu': 'Leitung', 'ita': 'Lead' } },
      { '@id': 'role:mfr', 'skos:prefLabel': { 'eng': 'Manufacturer', 'deu': 'Hersteller*in', 'ita': 'Manufacturer' } },
      { '@id': 'role:emt', 'skos:prefLabel': { 'eng': 'Metal-engraver', 'deu': 'Metallstecher*in', 'ita': 'Calcografo' } },
      { '@id': 'role:nrt', 'skos:prefLabel': { 'eng': 'Narrator', 'deu': 'Erzähler*in', 'ita': 'Narrator' } },
      { '@id': 'role:pedagogicexpert', 'skos:prefLabel': { 'eng': 'Pedagogic Expert', 'deu': 'Pädagogische/r Expert*in', 'ita': 'Esperto pedagogico' } },
      { '@id': 'role:pht', 'skos:prefLabel': { 'eng': 'Photographer', 'deu': 'Fotograf*in', 'ita': 'Fotografo' } },
      { '@id': 'role:pro', 'skos:prefLabel': { 'eng': 'Producer', 'deu': 'Produzent*in', 'ita': 'Produttore' } },
      { '@id': 'role:res', 'skos:prefLabel': { 'eng': 'Researcher', 'deu': 'Forscher*in', 'ita': 'Ricercatore' } },
      { '@id': 'role:spk', 'skos:prefLabel': { 'eng': 'Speaker / Lecturer', 'deu': 'Sprecher*in / Vortragende/r', 'ita': 'Speaker' } },
      { '@id': 'role:ths', 'skos:prefLabel': { 'eng': 'Thesis advisor', 'deu': 'Dissertationsbetreuer*in', 'ita': 'Relatore' } },
      { '@id': 'role:trl', 'skos:prefLabel': { 'eng': 'Translator', 'deu': 'Übersetzer*in', 'ita': 'Traduttore' } },
      { '@id': 'role:uploader', 'skos:prefLabel': { 'eng': 'Uploader', 'deu': 'Uploader', 'ita': 'Uploader' } }
    ],
    loaded: true
  },
  'mimetypes': {
    terms: [
      { '@id': 'image/jpeg', 'skos:notation': ['jpeg', 'jpg'], 'skos:prefLabel': { 'eng': 'JPG/JPEG' } },
      { '@id': 'image/tiff', 'skos:notation': ['tiff', 'tif'], 'skos:prefLabel': { 'eng': 'TIFF' } },
      { '@id': 'image/gif', 'skos:notation': ['gif'], 'skos:prefLabel': { 'eng': 'GIF' } },
      { '@id': 'image/png', 'skos:notation': ['png'], 'skos:prefLabel': { 'eng': 'PNG' } },
      { '@id': 'image/x-ms-bmp', 'skos:notation': ['bmp'], 'skos:prefLabel': { 'eng': 'BMP' } },
      { '@id': 'audio/wav', 'skos:notation': ['wav'], 'skos:prefLabel': { 'eng': 'WAVE' } },
      { '@id': 'audio/mpeg', 'skos:notation': ['mp3'], 'skos:prefLabel': { 'eng': 'MP3' } },
      { '@id': 'audio/flac', 'skos:notation': ['flac'], 'skos:prefLabel': { 'eng': 'FLAC' } },
      { '@id': 'audio/ogg', 'skos:notation': ['ogg'], 'skos:prefLabel': { 'eng': 'Ogg' } },
      { '@id': 'video/mpeg', 'skos:notation': ['mpg'], 'skos:prefLabel': { 'eng': 'MPEG' } },
      { '@id': 'video/avi', 'skos:notation': ['avi'], 'skos:prefLabel': { 'eng': 'AVI' } },
      { '@id': 'video/mp4', 'skos:notation': ['mp4'], 'skos:prefLabel': { 'eng': 'MPEG-4' } },
      { '@id': 'video/quicktime', 'skos:notation': ['qt', 'mov'], 'skos:prefLabel': { 'eng': 'Quicktime' } },
      { '@id': 'video/x-matroska', 'skos:notation': ['mkv'], 'skos:prefLabel': { 'eng': 'MKV' } },
      { '@id': 'application/x-iso9660-image', 'skos:notation': ['iso'], 'skos:prefLabel': { 'eng': 'ISO' } },
      { '@id': 'application/octet-stream', 'skos:notation': [], 'skos:prefLabel': { 'eng': 'Data' } },
      { '@id': 'application/pdf', 'skos:notation': ['pdf'], 'skos:prefLabel': { 'eng': 'PDF' } },
      { '@id': 'text/plain', 'skos:notation': ['txt'], 'skos:prefLabel': { 'eng': '.txt' } },
      { '@id': 'text/html', 'skos:notation': ['htm', 'html', 'shtml'], 'skos:prefLabel': { 'eng': 'HTML' } },
      { '@id': 'model/ply', 'skos:notation': ['ply'], 'skos:prefLabel': { 'eng': 'PLY' } },
      { '@id': 'model/nxz', 'skos:notation': ['nxz'], 'skos:prefLabel': { 'eng': 'NXZ' } },
      { '@id': 'application/epub+zip', 'skos:notation': ['.epub'], 'skos:prefLabel': { 'eng': 'EPUB' } },
      { '@id': 'application/msword', 'skos:notation': ['doc'], 'skos:prefLabel': { 'eng': '.doc' } },
      { '@id': 'application/vnd.ms-excel', 'skos:notation': ['xls'], 'skos:prefLabel': { 'eng': '.xls' } },
      { '@id': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'skos:notation': ['docx'], 'skos:prefLabel': { 'eng': '.docx' } },
      { '@id': 'application/vnd.openxmlformats-officedocument.wordprocessingml.template', 'skos:notation': ['dotx'], 'skos:prefLabel': { 'eng': '.dotx' } },
      { '@id': 'application/vnd.ms-word.document.macroEnabled.12', 'skos:notation': ['docm'], 'skos:prefLabel': { 'eng': '.docm' } },
      { '@id': 'application/vnd.ms-word.template.macroEnabled.12', 'skos:notation': ['dotm'], 'skos:prefLabel': { 'eng': '.dotm' } },
      { '@id': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'skos:notation': ['xlsx'], 'skos:prefLabel': { 'eng': '.xlsx' } },
      { '@id': 'application/vnd.openxmlformats-officedocument.spreadsheetml.template', 'skos:notation': ['xltx'], 'skos:prefLabel': { 'eng': '.xltx' } },
      { '@id': 'application/vnd.ms-excel.sheet.macroEnabled.12', 'skos:notation': ['xlsm'], 'skos:prefLabel': { 'eng': '.xlsm' } },
      { '@id': 'application/vnd.ms-excel.template.macroEnabled.12', 'skos:notation': ['xltm'], 'skos:prefLabel': { 'eng': '.xltm' } },
      { '@id': 'application/vnd.ms-excel.addin.macroEnabled.12', 'skos:notation': ['xlam'], 'skos:prefLabel': { 'eng': '.xlam' } },
      { '@id': 'application/vnd.ms-excel.sheet.binary.macroEnabled.12', 'skos:notation': ['xlsb'], 'skos:prefLabel': { 'eng': '.xlsb' } },
      { '@id': 'application/vnd.ms-powerpoint', 'skos:notation': ['ppt'], 'skos:prefLabel': { 'eng': '.ppt' } },
      { '@id': 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'skos:notation': ['pptx'], 'skos:prefLabel': { 'eng': '.pptx' } },
      { '@id': 'application/vnd.openxmlformats-officedocument.presentationml.template', 'skos:notation': ['potx'], 'skos:prefLabel': { 'eng': '.potx' } },
      { '@id': 'application/vnd.openxmlformats-officedocument.presentationml.slideshow', 'skos:notation': ['ppsx'], 'skos:prefLabel': { 'eng': '.ppsx' } },
      { '@id': 'application/vnd.ms-powerpoint.addin.macroEnabled.12', 'skos:notation': ['ppam'], 'skos:prefLabel': { 'eng': '.ppam' } },
      { '@id': 'application/vnd.ms-powerpoint.presentation.macroEnabled.12', 'skos:notation': ['pptm'], 'skos:prefLabel': { 'eng': '.pptm' } },
      { '@id': 'application/vnd.ms-powerpoint.presentation.macroEnabled.12', 'skos:notation': ['potm'], 'skos:prefLabel': { 'eng': '.potm' } },
      { '@id': 'application/vnd.ms-powerpoint.slideshow.macroEnabled.12', 'skos:notation': ['ppsm'], 'skos:prefLabel': { 'eng': '.ppsm' } },
      { '@id': 'application/vnd.oasis.opendocument.text', 'skos:notation': ['odt'], 'skos:prefLabel': { 'eng': '.odt' } },
      { '@id': 'application/vnd.oasis.opendocument.text-template', 'skos:notation': ['ott'], 'skos:prefLabel': { 'eng': '.ott' } },
      { '@id': 'application/vnd.oasis.opendocument.text-web', 'skos:notation': ['oth'], 'skos:prefLabel': { 'eng': '.oth' } },
      { '@id': 'application/vnd.oasis.opendocument.text-master', 'skos:notation': ['odm'], 'skos:prefLabel': { 'eng': '.odm' } },
      { '@id': 'application/vnd.oasis.opendocument.graphics', 'skos:notation': ['odg'], 'skos:prefLabel': { 'eng': '.odg' } },
      { '@id': 'application/vnd.oasis.opendocument.graphics-template', 'skos:notation': ['otg'], 'skos:prefLabel': { 'eng': '.otg' } },
      { '@id': 'application/vnd.oasis.opendocument.presentation', 'skos:notation': ['odp'], 'skos:prefLabel': { 'eng': '.odp' } },
      { '@id': 'application/vnd.oasis.opendocument.presentation-template', 'skos:notation': ['otp'], 'skos:prefLabel': { 'eng': '.otp' } },
      { '@id': 'application/vnd.oasis.opendocument.spreadsheet', 'skos:notation': ['ods'], 'skos:prefLabel': { 'eng': '.ods' } },
      { '@id': 'application/vnd.oasis.opendocument.spreadsheet-template', 'skos:notation': ['ots'], 'skos:prefLabel': { 'eng': '.ots' } },
      { '@id': 'application/vnd.oasis.opendocument.chart', 'skos:notation': ['odc'], 'skos:prefLabel': { 'eng': '.odc' } },
      { '@id': 'application/vnd.oasis.opendocument.formula', 'skos:notation': ['odf'], 'skos:prefLabel': { 'eng': '.odf' } },
      { '@id': 'application/vnd.oasis.opendocument.database', 'skos:notation': ['odb'], 'skos:prefLabel': { 'eng': '.odb' } },
      { '@id': 'application/vnd.oasis.opendocument.image', 'skos:notation': ['odi'], 'skos:prefLabel': { 'eng': '.odi' } },
      { '@id': 'application/x-wacz', 'skos:notation': ['wacz'], 'skos:prefLabel': { 'eng': '.wacz' } }
    ],
    loaded: true
  },
  'licenses': {
    terms: [
      { '@id': 'http://rightsstatements.org/vocab/InC/1.0/', 'skos:notation': ['1'], 'skos:prefLabel': { 'eng': 'All rights reserved', 'deu': 'Alle Rechte vorbehalten' } },
      { '@id': 'http://creativecommons.org/licenses/by/4.0/', 'skos:notation': ['16'], 'skos:prefLabel': { 'eng': 'CC BY 4.0 International' }, 'img': 'cc-by.png' },
      { '@id': 'http://creativecommons.org/licenses/by-nc/4.0/', 'skos:notation': ['17'], 'skos:prefLabel': { 'eng': 'CC BY-NC 4.0 International' }, 'img': 'cc-by-nc.png' },
      { '@id': 'http://creativecommons.org/licenses/by-nc-nd/4.0/', 'skos:notation': ['18'], 'skos:prefLabel': { 'eng': 'CC BY-NC-ND 4.0 International' }, 'img': 'cc-by-nc-nd.png' },
      { '@id': 'http://creativecommons.org/licenses/by-nc-sa/4.0/', 'skos:notation': ['19'], 'skos:prefLabel': { 'eng': 'CC BY-NC-SA 4.0 International' }, 'img': 'cc-by-nc-sa.png' },
      { '@id': 'http://creativecommons.org/licenses/by-nd/4.0/', 'skos:notation': ['20'], 'skos:prefLabel': { 'eng': 'CC BY-ND 4.0 International' }, 'img': 'cc-by-nd.png' },
      { '@id': 'http://creativecommons.org/licenses/by-sa/4.0/', 'skos:notation': ['21'], 'skos:prefLabel': { 'eng': 'CC BY-SA 4.0 International' }, 'img': 'cc-by-sa.png' }
    ],
    loaded: true
  },
  'alllicenses': {
    terms: [
      {
        '@id': 'http://rightsstatements.org/vocab/InC/1.0/',
        'skos:notation': [
          '1'
        ],
        'skos:prefLabel': {
          'eng': 'All rights reserved',
          'deu': 'Alle Rechte vorbehalten'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by/4.0/',
        'skos:notation': [
          '16'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY 4.0 International'
        },
        'img': 'cc-by.png',
        'skos:definition': {
          'eng': 'Attribution 4.0 International (CC BY 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material for any purpose, even commercially.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung 4.0 International\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen und zwar für beliebige Zwecke, sogar kommerziell.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc/4.0/',
        'skos:notation': [
          '17'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC 4.0 International'
        },
        'img': 'cc-by-nc.png',
        'skos:definition': {
          'eng': 'Attribution-NonCommercial 4.0 International (CC BY-NC 4.0 AT)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />The licensee may not use the material for commercial purposes.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung - Nicht-kommerziell 4.0 International\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht für kommerzielle Zwecke nutzen.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-nd/4.0/',
        'skos:notation': [
          '18'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-ND 4.0 International'
        },
        'img': 'cc-by-nc-nd.png',
        'skos:definition': {
          'eng': 'Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format. You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />The licensee may not use the material for commercial purposes.\n<br />\n<br />If the licensee remixes, transforms, or builds upon the material, he may not distribute the modified material.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-nd/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung - Nicht-kommerziell - Keine Bearbeitungen 4.0 International (CC BY-NC-ND 4.0)\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht für kommerzielle Zwecke nutzen.\n<br />\n<br />Wenn der Lizenznehmer Ihren Schutzgegenstand remixt, verändert oder darauf anderweitig direkt aufbaut, darf er die bearbeitete Fassung Ihres Schutzgegenstandes nicht verbreiten.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-nd/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-sa/4.0/',
        'skos:notation': [
          '19'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-SA 4.0 International'
        },
        'img': 'cc-by-nc-sa.png',
        'skos:definition': {
          'eng': 'Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />The licensee may not use the material for commercial purposes.\n<br />\n<br />If the licensee remixes, transforms, or builds upon the material, he must distribute your contributions under the same license as the original.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 4.0 International (CC BY-NC-SA 4.0)\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht für kommerzielle Zwecke nutzen.\n<br />\n<br />Wenn der Lizenznehmer Ihren Schutzgegenstand remixt, verändert oder darauf anderweitig direkt aufbaut, darf Ihre Beiträge nur unter derselben Lizenz wie das Original verbreiten.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nd/4.0/',
        'skos:notation': [
          '20'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-ND 4.0 International'
        },
        'img': 'cc-by-nd.png',
        'skos:definition': {
          'eng': 'Attribution-No Derivatives 4.0 International (CC BY-ND 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, even commercially.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />If the licensee remixes, transforms, or builds upon the material, he may not distribute the modified material.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nd/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung-Keine Bearbeitung 4.0 International (CC BY-ND 4.0)\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten und zwar für beliebige Zwecke, sogar kommerziell.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Wenn der Lizenznehmer Ihren Schutzgegenstand remixt, verändert oder darauf anderweitig direkt aufbaut, darf er die bearbeitete Fassung Ihres Schutzgegenstandes nicht verbreiten.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nd/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-sa/4.0/',
        'skos:notation': [
          '21'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-SA 4.0 International'
        },
        'img': 'cc-by-sa.png',
        'skos:definition': {
          'eng': 'Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material for any purpose, even commercially.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />If the the licensee remixes, transforms, or builds upon the material, he must distribute your contributions under the same license as the original.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung - Weitergabe unter gleichen Bedingungen 4.0 International (CC BY-SA 4.0)\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen und zwar für beliebige Zwecke, sogar kommerziell.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Wenn der Lizenznehmer Ihren Schutzgegenstand remixt, verändert oder darauf anderweitig direkt aufbaut, darf Ihre Beiträge nur unter derselben Lizenz wie das Original verbreiten.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/publicdomain/mark/1.0/',
        'skos:notation': [
          '9'
        ],
        'skos:prefLabel': {
          'eng': 'Public Domain Mark 1.0'
        },
        'img': 'pdm.png',
        'skos:definition': {
          'eng': "The Public Domain brand serves as a unified symbol for goods and services of public domain. Public domain in the context of creative goods exists when a creative good is not subject to any copyright restrictions. This is the case when a creative good does not fulfill the requirements that bind the copyright to a copyrightable work, perhaps because it is not sufficiently personalized or that it can be placed in any copyright work category. Public domain also exists when the term of protection of a work has expired. This usually takes place 70 years after the author's death.<br/>Public domain books can be recycled and used as desired without having to obtain permission from the copyright holder. Therefore, a creative good is marked by a significant responsibility over a public domain. We therefore ask you before you tag a digital good with the public domain brand to first consider very carefully whether the work in question is not actually copyrighted.<br/>The public domain brand is conceived for creative goods for which there are no more rights anywhere in the world over a period of time or for creative goods which have previously been expressly released by their owners in the public domain worldwide. They should not be used if the relevant creative good only bears public domain under a few legal systems, but in others is still protected. Creative Commons does not currently recommend using the public domain brand for creative goods worldwide with varying legal copyright status. If in doubt, you should obtain legal advice if you are unsure whether you want to use the public domain for a specific creative good.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/publicdomain/mark/1.0/\">Long version</a>",
          'deu': 'Die Public Domain Marke dient als einheitliches Symbol zur Kennzeichnung von gemeinfreien Gütern bzw. Leistungen. Gemeinfreiheit im Kontext kreativer Güter liegt dann vor, wenn ein Kreativgut keinerlei urheberrechtlichen Restriktionen unterliegt. Das ist dann der Fall, wenn ein Kreativgut den Anforderungen, die das Urheberrecht an ein schutzfähiges Werk knüpft, nicht genügt, etwa weil es nicht hinreichend individuell ist oder in keine urheberrechtliche Werkkategorie eingeordnet werden kann. Gemeinfreiheit liegt ferner dann vor, wenn die Schutzfrist eines Werks abgelaufen ist. Das erfolgt im Urheberrecht in der Regel 70 Jahre nach dem Tod des Autors.<br/>Gemeinfreie Werke dürfen beliebig verwertet und genutzt werden ohne, dass dazu die Erlaubnis des Rechteinhabers eingeholt werden muss. Daher geht mit der Kennzeichnung eines Kreativgutes als gemeinfrei eine erhebliche Verantwortung einher. Wir bitten Sie daher bevor Sie ein Digitalgut mit der Public Domain Marke versehen, mit äußerster Sorgfalt zu prüfen, ob das betreffende Werk tatsächlich nicht urheberrechtlich geschützt ist.<br/>Die Public Domain Marke ist gedacht für Kreativgüter, für die durch Zeitablauf nirgendwo auf der Welt mehr Schutzrechte bestehen oder die zuvor von ihrem Rechteinhaber ausdrücklich in die weltweite Public Domain entlassen worden sind. Sie sollte nicht verwendet werden, wenn das betreffende Kreativgut nur unter manchen Rechtsordnungen zur Public Domain gehört, also gemeinfrei ist, in anderen dagegen noch geschützt ist. Derzeit empfiehlt Creative Commons es nicht, die Public Domain Marke für Kreativgüter mit weltweit unterschiedlichem urheberrechtlichem Status zu verwenden. Im Zweifel sollten Sie sich Rechtsberatung besorgen, wenn Sie unsicher sind, ob Sie die Public Domain für ein bestimmtes Kreativgut verwenden wollen.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/publicdomain/mark/1.0/">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by/3.0/',
        'skos:notation': [
          '28'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY 3.0 Unported'
        },
        'img': 'cc-by.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br  /><br />Under the following conditions:<br />Attribution. You must give the original author credit.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by/3.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung 3.0 Unported<br /><br />Attribution 3.0 Unported (CC BY 3.0 Unported)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/3.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc/3.0/',
        'skos:notation': [
          '30'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC 3.0 Unported'
        },
        'img': 'cc-by-nc.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc/3.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine kommerzielle Nutzung 3.0 Unported<br /><br />Attribution-NonCommercial 3.0 Unported (CC BY-NC 3.0 Unported)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen. <br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/3.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-nd/3.0/',
        'skos:notation': [
          '33'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-ND 3.0 Unported'
        },
        'img': 'cc-by-nc-nd.png',
        'skos:definition': {
          'eng': "You are free:<br  />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-nd/3.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine kommerzielle Nutzung - Keine Bearbeitungen 3.0 Unported<br /><br />Attribution-NonCommercial-NoDerivs 3.0 Unported (CC BY-NC-ND 3.0 Unported)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-nd/3.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-sa/3.0/',
        'skos:notation': [
          '32'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-SA 3.0 Unported'
        },
        'img': 'cc-by-nc-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine kommerzielle Nutzung - Weitergabe unter gleichen Bedingungen 3.0 Unported<br /><br />Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0 Unported)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihr Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nd/3.0/',
        'skos:notation': [
          '31'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-ND 3.0 Unported'
        },
        'img': 'cc-by-nd.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nd/3.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine Bearbeitungen 3.0 Unported<br /><br />Attribution-NoDerivs 3.0 Unported (CC BY-ND 3.0 Unported)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br>- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br><br>Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br>Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br><br>Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br>Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br>Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nd/3.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-sa/3.0/',
        'skos:notation': [
          '29'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-SA 3.0 Unported'
        },
        'img': 'cc-by-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-sa/3.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Weitergabe unter gleichen Bedingungen 3.0 Unported<br /><br />Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0 Unported)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher  Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/3.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by/3.0/at/',
        'skos:notation': [
          '10'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY 3.0 Austria'
        },
        'img': 'cc-by.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br  /><br />Under the following conditions:<br />Attribution. You must give the original author credit.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by/3.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung 3.0 Österreich<br /><br />Attribution 3.0 Austria (CC BY 3.0 AT)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/3.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc/3.0/at/',
        'skos:notation': [
          '11'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC 3.0 Austria'
        },
        'img': 'cc-by-nc.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc/3.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine kommerzielle Nutzung 3.0 Österreich<br /><br />Attribution-NonCommercial 3.0 Austria (CC BY-NC 3.0 AT)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen. <br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/3.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-nd/3.0/at/',
        'skos:notation': [
          '12'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-ND 3.0 Austria'
        },
        'img': 'cc-by-nc-nd.png',
        'skos:definition': {
          'eng': "You are free:<br  />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-nd/3.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine kommerzielle Nutzung - Keine Bearbeitungen 3.0 Österreich<br /><br />Attribution-NonCommercial-NoDerivs 3.0 Austria (CC BY-NC-ND 3.0 AT)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-nd/3.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-sa/3.0/at/',
        'skos:notation': [
          '13'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-SA 3.0 Austria'
        },
        'img': 'cc-by-nc-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-sa/3.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine kommerzielle Nutzung - Weitergabe unter gleichen Bedingungen 3.0 Österreich<br /><br />Attribution-NonCommercial-ShareAlike 3.0 Austria (CC BY-NC-SA 3.0 AT)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihr Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/3.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nd/3.0/at/',
        'skos:notation': [
          '14'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-ND 3.0 Austria'
        },
        'img': 'cc-by-nd.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nd/3.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Keine Bearbeitungen 3.0 Österreich<br /><br />Attribution-NoDerivs 3.0 Austria (CC BY-ND 3.0 AT)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br>- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br><br>Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br>Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br><br>Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br>Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br>Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nd/3.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-sa/3.0/at/',
        'skos:notation': [
          '15'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-SA 3.0 Austria'
        },
        'img': 'cc-by-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-sa/3.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung - Weitergabe unter gleichen Bedingungen 3.0 Österreich<br /><br />Attribution-ShareAlike 3.0 Austria (CC BY-SA 3.0 AT)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher  Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/3.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by/2.0/',
        'skos:notation': [
          '22'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY 2.0 Generic'
        },
        'img': 'cc-by.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br  /><br />Under the following conditions:<br />Attribution. You must give the original author credit.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by/2.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung 2.0 Generic<br /><br />Attribution 2.0 Generic (by)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/2.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc/2.0/',
        'skos:notation': [
          '24'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC 2.0 Generic'
        },
        'img': 'cc-by-nc.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc/2.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine kommerzielle Nutzung 2.0 Generic<br /><br />Attribution-Noncommercial 2.0 Generic (by-nc)<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen. <br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/2.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-nd/2.0/',
        'skos:notation': [
          '27'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-ND 2.0 Generic'
        },
        'img': 'cc-by-nc-nd.png',
        'skos:definition': {
          'eng': "You are free:<br  />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-nd/2.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine kommerzielle Nutzung-Keine Bearbeitung 2.0 Generic<br /><br />Attribuation-Non commercial-No Derivative Works 2.0 Generic (by-nc-nd) <br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-nd/2.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-sa/2.0/',
        'skos:notation': [
          '26'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-SA 2.0 Generic'
        },
        'img': 'cc-by-nc-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-sa/2.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine kommerzielle Nutzung-Weitergabe unter gleichen Bedingungen 2.0 Generic<br /><br />Attribution-Noncommercial-Share Alike 2.0 Generic (by-nc-sa)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihr Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/2.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nd/2.0/',
        'skos:notation': [
          '25'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-ND 2.0 Generic'
        },
        'img': 'cc-by-nd.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nd/2.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine Bearbeitung 2.0 Generic<br><br>Attribuation-No Derivative Works 2.0 Generic (by-nd)<br><br>Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br>- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br><br>Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br>Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br><br>Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br>Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br>Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nd/2.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-sa/2.0/',
        'skos:notation': [
          '23'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-SA 2.0 Generic'
        },
        'img': 'cc-by-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-sa/2.0/legalcode\">Long version</a>",
          'deu': 'Namensnennung- -Weitergabe unter gleichen Bedingungen 2.0 Generic<br /><br />Attribution-Share Alike 2.0 Generic (by-sa)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher  Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/2.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by/2.0/at/',
        'skos:notation': [
          '2'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY 2.0 Austria'
        },
        'img': 'cc-by.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br  /><br />Under the following conditions:<br />Attribution. You must give the original author credit.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by/2.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung 2.0 Österreich<br /><br />Attribution 2.0 Austria (by)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/2.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc/2.0/at/',
        'skos:notation': [
          '3'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC 2.0 Austria'
        },
        'img': 'cc-by-nc.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights. <br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc/2.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine kommerzielle Nutzung 2.0 Österreich<br /><br />Attribution-Noncommercial 2.0 Austria (by-nc)<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen. <br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/2.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-nd/2.0/at/',
        'skos:notation': [
          '4'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-ND 2.0 Austria'
        },
        'img': 'cc-by-nc-nd.png',
        'skos:definition': {
          'eng': "You are free:<br  />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights. <br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-nd/2.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine kommerzielle Nutzung-Keine Bearbeitung 2.0 Österreich<br /><br />Attribuation-Non commercial-No Derivative Works 2.0 Austria (by-nc-nd) <br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung  dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-nd/2.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-sa/2.0/at/',
        'skos:notation': [
          '5'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-SA 2.0 Austria'
        },
        'img': 'cc-by-nc-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Non-Commercial</b>. You may not use this work for commercial purposes.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights. <br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nc-sa/2.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine kommerzielle Nutzung-Weitergabe unter gleichen Bedingungen 2.0 Österreich<br /><br />Attribution-Noncommercial-Share Alike 2.0 Austria (by-nc-sa)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihr Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht zu kommerziellen Zwecken verwerten.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber Ihre Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/2.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nd/2.0/at/',
        'skos:notation': [
          '6'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-ND 2.0 Austria'
        },
        'img': 'cc-by-nd.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>No Derivative Works</b>. You may not alter, transform, or build upon this work.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights. <br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-nd/2.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung-Keine Bearbeitung 2.0 Österreich<br><br>Attribuation-No Derivative Works 2.0 Austria (by-nd)<br><br>Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher Form zu verwerten, insbesondere<br>- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen.<br><br>Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br>Der Lizenznehmer darf Ihren Schutzgegenstand nicht bearbeiten oder auf andere Weise verändern.<br><br>Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br>Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br>Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nd/2.0/at/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-sa/2.0/at/',
        'skos:notation': [
          '7'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-SA 2.0 Austria'
        },
        'img': 'cc-by-sa.png',
        'skos:definition': {
          'eng': "You are free:<br />to copy, distribute, display, and perform the work<br />to make derivative works<br /><br />Under the following conditions:<br /><b>Attribution</b>. You must give the original author credit.<br /><b>Share Alike</b>. If you alter, transform, or build upon this work, you may distribute the resulting work only under a licence identical to this one.<br /><br />- For any reuse or distribution, you must make clear to others the licence terms of this work.<br />- Any of these conditions can be waived if you get permission from the copyright holder.<br />- Nothing in this licence impairs or restricts the author's moral rights. <br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target=\"_blank\" href=\"http://creativecommons.org/licenses/by-sa/2.0/at/legalcode\">Long version</a>",
          'deu': 'Namensnennung- -Weitergabe unter gleichen Bedingungen 2.0 Österreich<br /><br />Attribution-Share Alike 2.0 Austria(by-sa)<br /><br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in körperlicher oder unkörperlicher  Form zu verwerten, insbesondere<br />- zu vervielfältigen, zu verbreiten, vorzuführen, zu senden und der Öffentlichkeit zur Verfügung zu stellen;<br />- zu bearbeiten und die Bearbeitungen zu verwerten.<br /><br />Der Lizenznehmer muss Ihren Namen in Verbindung mit Ihrem Schutzgegenstand stets in der von Ihnen festgelegten Weise nennen.<br />Wenn der Lizenznehmer Ihren Schutzgegenstand bearbeitet oder in anderer Weise umgestaltet, verändert oder als Grundlage für ein anderes Werk verwendet, darf er das neu entstandene Werk nur unter Verwendung von Lizenzbedingungen weitergeben, die mit denen dieses Lizenzvertrages identisch oder vergleichbar sind.<br /><br />Im Falle einer Verbreitung muss der Lizenznehmer anderen die Lizenzbedingungen, unter welche dieser Schutzgegenstand fällt, mitteilen.<br />Jede der vorgenannten Bedingungen kann aufgehoben werden, sofern Sie als Rechteinhaber die Einwilligung dazu erteilen.<br />Diese Lizenz lässt die Urheberpersönlichkeitsrechte unberührt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/2.0/at/legalcode">Langversion</a>'
        }
      }
    ],
    loaded: true
  },
  'oerlicenses': {
    terms: [
      {
        '@id': 'http://creativecommons.org/licenses/by/4.0/',
        'skos:notation': [
          '16'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY 4.0 International'
        },
        'img': 'cc-by.png',
        'skos:definition': {
          'eng': 'Attribution 4.0 International (CC BY 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material for any purpose, even commercially.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung 4.0 International\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen und zwar für beliebige Zwecke, sogar kommerziell.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-sa/4.0/',
        'skos:notation': [
          '21'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-SA 4.0 International'
        },
        'img': 'cc-by-sa.png',
        'skos:definition': {
          'eng': 'Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material for any purpose, even commercially.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />If the the licensee remixes, transforms, or builds upon the material, he must distribute your contributions under the same license as the original.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung - Weitergabe unter gleichen Bedingungen 4.0 International (CC BY-SA 4.0)\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen und zwar für beliebige Zwecke, sogar kommerziell.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Wenn der Lizenznehmer Ihren Schutzgegenstand remixt, verändert oder darauf anderweitig direkt aufbaut, darf Ihre Beiträge nur unter derselben Lizenz wie das Original verbreiten.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-sa/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc/4.0/',
        'skos:notation': [
          '17'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC 4.0 International'
        },
        'img': 'cc-by-nc.png',
        'skos:definition': {
          'eng': 'Attribution-NonCommercial 4.0 International (CC BY-NC 4.0 AT)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />The licensee may not use the material for commercial purposes.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung - Nicht-kommerziell 4.0 International\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht für kommerzielle Zwecke nutzen.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc/4.0/legalcode">Langversion</a>'
        }
      },
      {
        '@id': 'http://creativecommons.org/licenses/by-nc-sa/4.0/',
        'skos:notation': [
          '19'
        ],
        'skos:prefLabel': {
          'eng': 'CC BY-NC-SA 4.0 International'
        },
        'img': 'cc-by-nc-sa.png',
        'skos:definition': {
          'eng': 'Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)\n<br />\n<br />If you license your content under the terms of this license, you allow every licensee to copy and to redistribute the material in any medium or format, to remix, to transform, and build upon the material.\n<br />\n<br />You cannot revoke these freedoms as long as the licensee follows the license terms.\n<br />\n<br />The licensee must give appropriate credit, provide a link to the license, and indicate if changes were made. The licensee may do so in any reasonable manner, but not in any way that suggests the licensor endorses the licensee or his use.\n<br />\n<br />The licensee may not use the material for commercial purposes.\n<br />\n<br />If the licensee remixes, transforms, or builds upon the material, he must distribute your contributions under the same license as the original.\n<br />\n<br />The licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.<br/><br/>This is a human-readable summary of (and not a substitute for) the licence.<br/>The legal binding text of the licence is available here:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode">Long version</a>',
          'deu': 'Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 4.0 International (CC BY-NC-SA 4.0)\n<br />\n<br />Wenn Sie Ihren Schutzgegenstand unter den Bedingungen dieser Lizenz anbieten, gestatten Sie jedem Lizenznehmer, Ihren Schutzgegenstand in jedwedem Format oder Medium zu vervielfältigen und weiterzuverbreiten. Der Lizenznehmer darf ihren Schutzgegenstand remixen, verändern und darauf aufbauen.\n<br />\n<br />Die hier eingeräumten Freiheiten dürfen nicht widerrufen werden, solange sich der Lizenznehmer an die Lizenzbedingungen hält.\n<br />\n<br />Der Lizenznehmer muss angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade den Lizenznehmer oder seine Nutzung besonders.\n<br />\n<br />Der Lizenznehmer darf Ihren Schutzgegenstand nicht für kommerzielle Zwecke nutzen.\n<br />\n<br />Wenn der Lizenznehmer Ihren Schutzgegenstand remixt, verändert oder darauf anderweitig direkt aufbaut, darf Ihre Beiträge nur unter derselben Lizenz wie das Original verbreiten.\n<br />\n<br />Der Lizenznehmer darf keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.<br/><br/>Dieser Text ist nicht der Text des Lizenzvertrages sondern nur eine unverbindliche Kurzfassung dessen.<br/>Die verbindliche Fassung der ausgewählten Lizenz finden Sie hier:<br/><a target="_blank" href="http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode">Langversion</a>'
        }
      }
    ],
    loaded: true
  },
  'uncefact': {
    terms: [
      { '@id': 'MTR', 'skos:prefLabel': { 'eng': 'm' } },
      { '@id': 'CMT', 'skos:prefLabel': { 'eng': 'cm' } },
      { '@id': 'MMT', 'skos:prefLabel': { 'eng': 'mm' } },
      { '@id': 'GRM', 'skos:prefLabel': { 'eng': 'g' } },
      { '@id': 'KGM', 'skos:prefLabel': { 'eng': 'kg' } }
    ],
    loaded: true
  },
  'uncefactsize': {
    terms: [
      { '@id': 'MTR', 'skos:prefLabel': { 'eng': 'm' } },
      { '@id': 'CMT', 'skos:prefLabel': { 'eng': 'cm' } },
      { '@id': 'MMT', 'skos:prefLabel': { 'eng': 'mm' } }
    ],
    loaded: true
  },
  'uncefactweight': {
    terms: [
      { '@id': 'GRM', 'skos:prefLabel': { 'eng': 'g' } },
      { '@id': 'KGM', 'skos:prefLabel': { 'eng': 'kg' } }
    ],
    loaded: true
  },
  'levelofdescription': {
    terms: [
      { '@id': ns + 'HQ7N-3Q2W', 'skos:prefLabel': { 'eng': 'Digitized object', 'deu': 'Digitalisiertes Objekt' } },
      { '@id': ns + 'TG30-5EM3', 'skos:prefLabel': { 'eng': 'Represented object', 'deu': 'Repräsentiertes Objekt' } }
    ],
    loaded: true
  },
  'carriertype': {
    terms: [
      { '@id': ns + '2FTX-ZPZV', 'skos:prefLabel': { 'eng': 'ADAT' } },
      { '@id': ns + 'A3BG-65F5', 'skos:prefLabel': { 'eng': 'CD' } },
      { '@id': ns + '4CQF-7HHF', 'skos:prefLabel': { 'eng': 'DAT' } },
      { '@id': ns + 'HXSS-NBZ4', 'skos:prefLabel': { 'eng': 'audiocassette', 'deu': 'Audiokassette' } },
      { '@id': ns + 'X627-FCV9', 'skos:prefLabel': { 'eng': 'tape', 'deu': 'Magnetband' } },
      { '@id': ns + 'C36Q-N42M', 'skos:prefLabel': { 'eng': 'lantern slide', 'deu': 'Glasplattendia' } }
    ],
    loaded: true
  },
  'resourcetype': {
    terms: [
      { '@id': ns + '44TN-P1S0', 'skos:prefLabel': { 'eng': 'Image', 'deu': 'Bild' } },
      { '@id': ns + '69ZZ-2KGX', 'skos:prefLabel': { 'eng': 'Text', 'deu': 'Text' } },
      { '@id': ns + 'GXS7-ENXJ', 'skos:prefLabel': { 'eng': 'Collection', 'deu': 'Collection' } },
      { '@id': ns + 'B0Y6-GYT8', 'skos:prefLabel': { 'eng': 'Video', 'deu': 'Video' } },
      { '@id': ns + '7AVS-Y482', 'skos:prefLabel': { 'eng': 'Data', 'deu': 'Daten' } },
      { '@id': ns + '8YB5-1M0J', 'skos:prefLabel': { 'eng': 'Sound', 'deu': 'Audio' } },
      { '@id': ns + '8MY0-BQDQ', 'skos:prefLabel': { 'eng': 'Container', 'deu': 'Container' } },
      { '@id': ns + 'T8GH-F4V8', 'skos:prefLabel': { 'eng': 'Link', 'deu': 'Link' } }
    ],
    loaded: true
  },
  'resourcetypenocontainer': {
    terms: [
      { '@id': ns + '44TN-P1S0', 'skos:prefLabel': { 'eng': 'Image', 'deu': 'Bild' } },
      { '@id': ns + '69ZZ-2KGX', 'skos:prefLabel': { 'eng': 'Text', 'deu': 'Text' } },
      { '@id': ns + 'GXS7-ENXJ', 'skos:prefLabel': { 'eng': 'Collection', 'deu': 'Collection' } },
      { '@id': ns + 'B0Y6-GYT8', 'skos:prefLabel': { 'eng': 'Video', 'deu': 'Video' } },
      { '@id': ns + '7AVS-Y482', 'skos:prefLabel': { 'eng': 'Data', 'deu': 'Daten' } },
      { '@id': ns + '8YB5-1M0J', 'skos:prefLabel': { 'eng': 'Sound', 'deu': 'Audio' } },
      { '@id': ns + 'T8GH-F4V8', 'skos:prefLabel': { 'eng': 'Link', 'deu': 'Link' } }
    ],
    loaded: true
  },
  'genre': {
    terms: [
      { '@id': ns + 'QNV1-N1EC', 'skos:prefLabel': { 'eng': 'action', 'deu': 'Actionfilm' } },
      { '@id': ns + '31DA-295K', 'skos:prefLabel': { 'eng': 'anime', 'deu': 'Anime' } },
      { '@id': ns + 'DB5C-1Y4H', 'skos:prefLabel': { 'eng': 'biographical film', 'deu': 'Anime' } },
      { '@id': ns + 'MKKZ-BH2Q', 'skos:prefLabel': { 'eng': 'discussion', 'deu': 'Diskussion' } },
      { '@id': ns + 'WVGH-KT47', 'skos:prefLabel': { 'eng': 'documentary film', 'deu': 'Diskussion' } },
      { '@id': ns + 'XFDY-E13E', 'skos:prefLabel': { 'eng': 'drama', 'deu': 'Drama' } },
      { '@id': ns + 'GZQE-YK3K', 'skos:prefLabel': { 'eng': 'fantasy film', 'deu': 'Fantasyfilm' } },
      { '@id': ns + 'KM7A-FYPP', 'skos:prefLabel': { 'eng': 'television film', 'deu': 'Fernsehfilm' } },
      { '@id': ns + 'MN1Y-YFCF', 'skos:prefLabel': { 'eng': 'historical film', 'deu': 'Historienfilm' } },
      { '@id': ns + 'G2VQ-GEEK', 'skos:prefLabel': { 'eng': 'horror film', 'deu': 'Horrorfilm' } },
      { '@id': ns + 'GFM4-2J48', 'skos:prefLabel': { 'eng': 'comedy film', 'deu': 'Komödie' } },
      { '@id': ns + 'NQVM-6B2Y', 'skos:prefLabel': { 'eng': 'crime film', 'deu': 'Kriminalfilm' } },
      { '@id': ns + 'BPAJ-NQ8N', 'skos:prefLabel': { 'eng': 'short film', 'deu': 'Kurzfilm' } },
      { '@id': ns + 'AHWA-YKFH', 'skos:prefLabel': { 'eng': 'romance film', 'deu': 'Liebesfilm' } },
      { '@id': ns + '7RZF-5216', 'skos:prefLabel': { 'eng': 'music film', 'deu': 'Musikfilm' } },
      { '@id': ns + 'A1B4-K5MK', 'skos:prefLabel': { 'eng': 'newscast', 'deu': 'Nachrichtensendung' } },
      { '@id': ns + '8QDK-T11S', 'skos:prefLabel': { 'eng': 'opera', 'deu': 'Oper' } },
      { '@id': ns + 'B4R8-Z419', 'skos:prefLabel': { 'eng': 'romance', 'deu': 'romance' } },
      { '@id': ns + 'XZ5S-JEJ5', 'skos:prefLabel': { 'eng': 'satire', 'deu': 'Satire' } },
      { '@id': ns + 'YV6T-SWAF', 'skos:prefLabel': { 'eng': 'science fiction film', 'deu': 'Science-Fiction-Film' } },
      { '@id': ns + 'A8HT-N1QB', 'skos:prefLabel': { 'eng': 'television series', 'deu': 'Fernsehserie' } },
      { '@id': ns + '1VZT-KE1S', 'skos:prefLabel': { 'eng': 'thriller film', 'deu': 'Thriller' } },
      { '@id': ns + 'PCK6-NYPG', 'skos:prefLabel': { 'eng': 'tragicomedy', 'deu': 'Tragikomödie' } },
      { '@id': ns + '2PV5-5V2H', 'skos:prefLabel': { 'eng': 'entertainment', 'deu': 'Unterhaltung' } },
      { '@id': ns + 'G7EY-YXQR', 'skos:prefLabel': { 'eng': 'adventure film', 'deu': 'Abenteuerfilm' } },
      { '@id': ns + 'W2SK-Q08A', 'skos:prefLabel': { 'eng': 'animation film', 'deu': 'Animationsfilm' } },
      { '@id': ns + 'QHJ1-PVEB', 'skos:prefLabel': { 'eng': 'family film', 'deu': 'Familienfilm' } },
      { '@id': ns + 'D8B5-D0YT', 'skos:prefLabel': { 'eng': 'mystery film', 'deu': 'Mysteryfilm' } },
      { '@id': ns + 'R8VJ-TMTB', 'skos:prefLabel': { 'eng': 'war film', 'deu': 'Kriegsfilm' } },
      { '@id': ns + 'WZMQ-2NG6', 'skos:prefLabel': { 'eng': 'western', 'deu': 'Western' } }
    ],
    loaded: true
  },
  'moviegenre': {
    terms: [
      { '@id': ns + 'QNV1-N1EC', 'skos:prefLabel': { 'eng': 'action', 'deu': 'Actionfilm' } },
      { '@id': ns + '31DA-295K', 'skos:prefLabel': { 'eng': 'anime', 'deu': 'Anime' } },
      { '@id': ns + 'DB5C-1Y4H', 'skos:prefLabel': { 'eng': 'biographical film', 'deu': 'Anime' } },
      { '@id': ns + 'MKKZ-BH2Q', 'skos:prefLabel': { 'eng': 'discussion', 'deu': 'Diskussion' } },
      { '@id': ns + 'WVGH-KT47', 'skos:prefLabel': { 'eng': 'documentary film', 'deu': 'Diskussion' } },
      { '@id': ns + 'XFDY-E13E', 'skos:prefLabel': { 'eng': 'drama', 'deu': 'Drama' } },
      { '@id': ns + 'GZQE-YK3K', 'skos:prefLabel': { 'eng': 'fantasy film', 'deu': 'Fantasyfilm' } },
      { '@id': ns + 'KM7A-FYPP', 'skos:prefLabel': { 'eng': 'television film', 'deu': 'Fernsehfilm' } },
      { '@id': ns + 'MN1Y-YFCF', 'skos:prefLabel': { 'eng': 'historical film', 'deu': 'Historienfilm' } },
      { '@id': ns + 'G2VQ-GEEK', 'skos:prefLabel': { 'eng': 'horror film', 'deu': 'Horrorfilm' } },
      { '@id': ns + 'GFM4-2J48', 'skos:prefLabel': { 'eng': 'comedy film', 'deu': 'Komödie' } },
      { '@id': ns + 'NQVM-6B2Y', 'skos:prefLabel': { 'eng': 'crime film', 'deu': 'Kriminalfilm' } },
      { '@id': ns + 'BPAJ-NQ8N', 'skos:prefLabel': { 'eng': 'short film', 'deu': 'Kurzfilm' } },
      { '@id': ns + 'AHWA-YKFH', 'skos:prefLabel': { 'eng': 'romance film', 'deu': 'Liebesfilm' } },
      { '@id': ns + '7RZF-5216', 'skos:prefLabel': { 'eng': 'music film', 'deu': 'Musikfilm' } },
      { '@id': ns + 'A1B4-K5MK', 'skos:prefLabel': { 'eng': 'newscast', 'deu': 'Nachrichtensendung' } },
      { '@id': ns + '8QDK-T11S', 'skos:prefLabel': { 'eng': 'opera', 'deu': 'Oper' } },
      { '@id': ns + 'B4R8-Z419', 'skos:prefLabel': { 'eng': 'romance', 'deu': 'romance' } },
      { '@id': ns + 'XZ5S-JEJ5', 'skos:prefLabel': { 'eng': 'satire', 'deu': 'Satire' } },
      { '@id': ns + 'YV6T-SWAF', 'skos:prefLabel': { 'eng': 'science fiction film', 'deu': 'Science-Fiction-Film' } },
      { '@id': ns + 'A8HT-N1QB', 'skos:prefLabel': { 'eng': 'television series', 'deu': 'Fernsehserie' } },
      { '@id': ns + '1VZT-KE1S', 'skos:prefLabel': { 'eng': 'thriller film', 'deu': 'Thriller' } },
      { '@id': ns + 'PCK6-NYPG', 'skos:prefLabel': { 'eng': 'tragicomedy', 'deu': 'Tragikomödie' } },
      { '@id': ns + '2PV5-5V2H', 'skos:prefLabel': { 'eng': 'entertainment', 'deu': 'Unterhaltung' } },
      { '@id': ns + 'G7EY-YXQR', 'skos:prefLabel': { 'eng': 'adventure film', 'deu': 'Abenteuerfilm' } },
      { '@id': ns + 'W2SK-Q08A', 'skos:prefLabel': { 'eng': 'animation film', 'deu': 'Animationsfilm' } },
      { '@id': ns + 'QHJ1-PVEB', 'skos:prefLabel': { 'eng': 'family film', 'deu': 'Familienfilm' } },
      { '@id': ns + 'D8B5-D0YT', 'skos:prefLabel': { 'eng': 'mystery film', 'deu': 'Mysteryfilm' } },
      { '@id': ns + 'R8VJ-TMTB', 'skos:prefLabel': { 'eng': 'war film', 'deu': 'Kriegsfilm' } },
      { '@id': ns + 'WZMQ-2NG6', 'skos:prefLabel': { 'eng': 'western', 'deu': 'Western' } }
    ],
    loaded: true
  },
  'objecttypeuwm': {
    terms: [
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552257', 'skos:prefLabel': { 'eng': 'Book', 'deu': 'Buch' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556244', 'skos:prefLabel': { 'eng': 'Patent', 'deu': 'Patent' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556237', 'skos:prefLabel': { 'eng': 'Conference Object', 'deu': 'Konferenzveröffentlichung' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552259', 'skos:prefLabel': { 'eng': 'Multimedia', 'deu': 'Multimedia' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552260', 'skos:prefLabel': { 'eng': 'other', 'deu': 'sonstige' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1742', 'skos:prefLabel': { 'eng': 'Dissertation', 'deu': 'Dissertation' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552261', 'skos:prefLabel': { 'eng': 'Lecture series (one person)', 'deu': 'Vortragsserie (eine Person)' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552253', 'skos:prefLabel': { 'eng': 'Article', 'deu': 'Artikel in Zeitschrift' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1743', 'skos:prefLabel': { 'eng': 'Professorial Dissertation', 'deu': 'Habilitationsschrift' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556239', 'skos:prefLabel': { 'eng': 'Working Paper', 'deu': 'Working Paper' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556236', 'skos:prefLabel': { 'eng': 'Review', 'deu': 'Rezension' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556242', 'skos:prefLabel': { 'eng': 'Annotation', 'deu': 'Annotation' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1557090', 'skos:prefLabel': { 'eng': 'Research Data', 'deu': 'Forschungsdaten' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1739', 'skos:prefLabel': { 'eng': 'Master\'s Dissertation', 'deu': 'Masterarbeit' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556235', 'skos:prefLabel': { 'eng': 'Book Part', 'deu': 'Buchkapitel' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1740', 'skos:prefLabel': { 'eng': 'Diploma Dissertation', 'deu': 'Diplomarbeit' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556240', 'skos:prefLabel': { 'eng': 'Preprint', 'deu': 'Preprint' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552258', 'skos:prefLabel': { 'eng': 'Theses', 'deu': 'Hochschulschrift' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1741', 'skos:prefLabel': { 'eng': 'Master\'s (Austria) Dissertation', 'deu': 'Magisterarbeit' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1738', 'skos:prefLabel': { 'eng': 'Baccalaureate Dissertation', 'deu': 'Bakkalaureatsarbeit' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552262', 'skos:prefLabel': { 'eng': 'Lecture', 'deu': 'Vortrag' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1556241', 'skos:prefLabel': { 'eng': 'Report', 'deu': 'Report' } },
      { '@id': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_17/1552263', 'skos:prefLabel': { 'eng': 'Article in collected edition', 'deu': 'Beitrag im Sammelwerk' } }
    ],
    loaded: true
  },
  'objecttype': {
    terms: [
      { '@id': ns + '9E94-E3F8', 'skos:prefLabel': { 'eng': 'Diplomarbeit' } },
      { '@id': ns + 'P2YP-BMND', 'skos:prefLabel': { 'eng': 'Masterarbeit' } },
      { '@id': ns + '1PHE-7VMS', 'skos:prefLabel': { 'eng': 'Dissertation' } },
      { '@id': ns + 'ST05-F6SP', 'skos:prefLabel': { 'eng': 'Magisterarbeit' } },
      { '@id': ns + '9ZSV-CVJH', 'skos:prefLabel': { 'eng': 'Habilitation' } },
      { '@id': ns + 'H1TF-SDX1', 'skos:prefLabel': { 'eng': 'Master-Thesis (ULG)' } },
      { '@id': ns + '985A-GCQJ', 'skos:prefLabel': { 'eng': 'album cover', 'deu': 'Albumcover' } },
      { '@id': ns + 'N35H-PDEE', 'skos:prefLabel': { 'eng': 'annotation', 'deu': 'Anmerkung' } },
      { '@id': ns + '8EBX-CA9X', 'skos:prefLabel': { 'eng': 'annual report', 'deu': 'Jahresbericht' } },
      { '@id': ns + '2WRQ-GSE9', 'skos:prefLabel': { 'eng': 'arrangement (music)', 'deu': 'Arrangement (Musik)' } },
      { '@id': ns + '9J46-2X9E', 'skos:prefLabel': { 'eng': 'atlas', 'deu': 'Atlas' } },
      { '@id': ns + '47QB-8QF1', 'skos:prefLabel': { 'eng': 'book', 'deu': 'Buch' } },
      { '@id': ns + 'XA52-09WA', 'skos:prefLabel': { 'eng': 'book part', 'deu': 'Buchkapitel' } },
      { '@id': ns + 'VP4W-DQ1P', 'skos:prefLabel': { 'eng': 'book review', 'deu': 'Buchrezension' } },
      { '@id': ns + '62RJ-SFV2', 'skos:prefLabel': { 'eng': 'cartographic material', 'deu': 'kartographisches Material' } },
      { '@id': ns + 'QKDF-E5HA', 'skos:prefLabel': { 'eng': 'conference object', 'deu': 'Konferenzveröffentlichung' } },
      { '@id': ns + 'MF25-FDGW', 'skos:prefLabel': { 'eng': 'contribution to journal', 'deu': 'Zeitschriftenbeitrag' } },
      { '@id': ns + 'CEET-8C4S', 'skos:prefLabel': { 'eng': 'cover', 'deu': 'Abdeckung' } },
      { '@id': ns + 'CPVB-YXG6', 'skos:prefLabel': { 'eng': 'cultural artifact', 'deu': 'Kulturartefakt' } },
      { '@id': ns + 'W2Z3-3YA6', 'skos:prefLabel': { 'eng': 'data management plan', 'deu': 'Datenmanagementplan' } },
      { '@id': ns + 'KW6N-2VTP', 'skos:prefLabel': { 'eng': 'dataset', 'deu': 'Dataset' } },
      { '@id': ns + 'A9K1-3WQA', 'skos:prefLabel': { 'eng': 'diary', 'deu': 'Tagebuch' } },
      { '@id': ns + '85QM-7TZ3', 'skos:prefLabel': { 'eng': 'drawing', 'deu': 'Zeichnung' } },
      { '@id': ns + 'QXRQ-Z2PJ', 'skos:prefLabel': { 'eng': 'internal report', 'deu': 'interner Bericht' } },
      { '@id': ns + '8KGA-CH97', 'skos:prefLabel': { 'eng': 'interview', 'deu': 'Interview' } },
      { '@id': ns + 'VKA6-9XTY', 'skos:prefLabel': { 'eng': 'journal article', 'deu': 'Wissenschaftlicher Artikel' } },
      { '@id': ns + 'YA8R-1M0D', 'skos:prefLabel': { 'eng': 'learning object', 'deu': 'Lernobjekt' } },
      { '@id': ns + 'F4JN-ZST0', 'skos:prefLabel': { 'eng': 'lecture', 'deu': 'Vortrag' } },
      { '@id': ns + 'GBWA-JJP8', 'skos:prefLabel': { 'eng': 'letter (correspondence)', 'deu': 'Brief' } },
      { '@id': ns + 'EHPQ-XYA3', 'skos:prefLabel': { 'eng': 'magazine', 'deu': 'Magazin (Zeitschrift)' } },
      { '@id': ns + 'KMRH-NFR9', 'skos:prefLabel': { 'eng': 'manuscript', 'deu': 'Manuskript' } },
      { '@id': ns + 'A52A-CWMM', 'skos:prefLabel': { 'eng': 'map', 'deu': 'Karte' } },
      { '@id': ns + 'MCN9-1NSA', 'skos:prefLabel': { 'eng': 'memorandum', 'deu': 'Memorandum' } },
      { '@id': ns + 'M789-K5E0', 'skos:prefLabel': { 'eng': 'music album', 'deu': 'Musikalbum' } },
      { '@id': ns + 'EWZ9-3MPH', 'skos:prefLabel': { 'eng': 'musical composition', 'deu': 'musikalische Komposition' } },
      { '@id': ns + '8A6X-FKB1', 'skos:prefLabel': { 'eng': 'musical notation', 'deu': 'Musiknotation' } },
      { '@id': ns + '9W35-5Q94', 'skos:prefLabel': { 'eng': 'negative', 'deu': 'Negativ' } },
      { '@id': ns + 'DCHD-W3GM', 'skos:prefLabel': { 'eng': 'newspaper', 'deu': 'Zeitung' } },
      { '@id': ns + 'CJJG-VKRQ', 'skos:prefLabel': { 'eng': 'newspaper article', 'deu': 'Zeitungsartikel' } },
      { '@id': ns + 'PYRE-RAWJ', 'skos:prefLabel': { 'eng': 'other', 'deu': 'sonstige' } },
      { '@id': ns + '6QRG-9GN2', 'skos:prefLabel': { 'eng': 'other type of report', 'deu': 'Sonstiger Bericht' } },
      { '@id': ns + 'WWS3-0ACP', 'skos:prefLabel': { 'eng': 'painting', 'deu': 'Malerei' } },
      { '@id': ns + 'GY3Z-50FT', 'skos:prefLabel': { 'eng': 'periodical', 'deu': 'Periodikum' } },
      { '@id': ns + '7CAB-P987', 'skos:prefLabel': { 'eng': 'photograph', 'deu': 'Fotografie' } },
      { '@id': ns + 'R4W3-ZQ76', 'skos:prefLabel': { 'eng': 'picture', 'deu': 'Bild' } },
      { '@id': ns + 'JF85-NYRJ', 'skos:prefLabel': { 'eng': 'podcast', 'deu': 'Podcast' } },
      { '@id': ns + 'XWWK-533P', 'skos:prefLabel': { 'eng': 'policy report', 'deu': 'politischer Bericht' } },
      { '@id': ns + 'Q4Q5-3554', 'skos:prefLabel': { 'eng': 'postcard', 'deu': 'Postkarte' } },
      { '@id': ns + '6EFK-BRQD', 'skos:prefLabel': { 'eng': 'poster', 'deu': 'Plakat' } },
      { '@id': ns + 'T023-BGTD', 'skos:prefLabel': { 'eng': 'preprint', 'deu': 'Preprint' } },
      { '@id': ns + '7WYH-AZ8C', 'skos:prefLabel': { 'eng': 'print', 'deu': 'druckgraphisches Blatt' } },
      { '@id': ns + 'T8PK-GADB', 'skos:prefLabel': { 'eng': 'project deliverable', 'deu': 'Projektergebnis' } },
      { '@id': ns + 'MZ2Q-R099', 'skos:prefLabel': { 'eng': 'questionnaire', 'deu': 'Fragebogen' } },
      { '@id': ns + 'JMAV-7F3R', 'skos:prefLabel': { 'eng': 'report', 'deu': 'Bericht' } },
      { '@id': ns + 'PHQ7-BGFA', 'skos:prefLabel': { 'eng': 'report part', 'deu': 'Teilbericht' } },
      { '@id': ns + 'APV5-CJSF', 'skos:prefLabel': { 'eng': 'report to funding agency', 'deu': 'Bericht an Fördergeber' } },
      { '@id': ns + '7J0J-HC61', 'skos:prefLabel': { 'eng': 'research report', 'deu': 'Forschungsbericht' } },
      { '@id': ns + 'VM3E-HXE6', 'skos:prefLabel': { 'eng': 'research software', 'deu': 'Forschungssoftware' } },
      { '@id': ns + 'JJKV-B1CG', 'skos:prefLabel': { 'eng': 'review', 'deu': 'Rezension' } },
      { '@id': ns + 'XTVH-3MG3', 'skos:prefLabel': { 'eng': 'score', 'deu': 'Partitur' } },
      { '@id': ns + '21HZ-XP29', 'skos:prefLabel': { 'eng': 'sculpture', 'deu': 'Skulptur' } },
      { '@id': ns + '431H-5YSA', 'skos:prefLabel': { 'eng': 'slide', 'deu': 'Diapositiv' } },
      { '@id': ns + '6KMM-SD3M', 'skos:prefLabel': { 'eng': 'dianegative', 'deu': 'Dianegativ' } },
      { '@id': ns + '622D-CM27', 'skos:prefLabel': { 'eng': 'software', 'deu': 'Software' } },
      { '@id': ns + 'DF69-TVE8', 'skos:prefLabel': { 'eng': 'technical report', 'deu': 'technischer Bericht' } },
      { '@id': ns + '6FG3-514E', 'skos:prefLabel': { 'eng': 'transcript', 'deu': 'Transkript' } },
      { '@id': ns + 'QM0R-ZTAA', 'skos:prefLabel': { 'eng': 'wall chart', 'deu': 'Wandtafel' } },
      { '@id': ns + 'R1WF-V45Y', 'skos:prefLabel': { 'eng': 'website', 'deu': 'Website' } },
      { '@id': ns + '489N-Y6VX', 'skos:prefLabel': { 'eng': 'working paper', 'deu': 'Arbeitspapier' } },
      { '@id': ns + 'HARH-6R3C', 'skos:prefLabel': { 'eng': 'yearbook', 'deu': 'Jahrbuch' } },
      { '@id': ns + 'C36Q-N42M', 'skos:prefLabel': { 'eng': 'lantern slide', 'deu': 'Glasplattendia' } }
    ],
    loaded: true
  },
  'irobjecttype': {
    terms: [
      { '@id': ns + 'VKA6-9XTY', 'skos:prefLabel': { 'eng': 'journal article' }, 'skos:definition': { 'deu': 'Ein Artikel zu einem bestimmten Thema, der im Heft einer Zeitschrift veröffentlicht wurde', 'eng': 'An article on a particular topic and published in a journal issue.' } },
      { '@id': ns + 'T023-BGTD', 'skos:prefLabel': { 'eng': 'preprint' }, 'skos:definition': { 'eng': 'Pre-print describes the first draft of the article - before peer-review, even before any contact with a publisher. This use is common amongst academics for whom the key modification of an article is the peer-review process. Another use of the term pre-print is for the finished article, reviewed and amended, ready and accepted for publication - but separate from the version that is type-set or formatted by the publisher. This use is more common amongst publishers, for whom the final and significant stage of modification to an article is the arrangement of the material for putting to print.' } },
      { '@id': ns + '489N-Y6VX', 'skos:prefLabel': { 'eng': 'working paper' }, 'skos:definition': { 'eng': 'An unpublished paper, usually circulated privately among a small group of peers, to provide information or with a request for comments or editorial improvement.' } },
      { '@id': ns + 'JMAV-7F3R', 'skos:prefLabel': { 'eng': 'report' }, 'skos:definition': { 'deu': 'Ein Bericht ist eine separat veröffentlichte Aufzeichnung von Forschungsergebnissen, noch laufender Forschung oder anderen technischen Ergebnissen, die normalerweise eine Berichtsnummer und manchmal eine von den Fördergebern zugewiesene Projektnummer tragen. Außerdem eine offizielle Aufzeichnung der Aktivitäten eines Ausschusses oder eines Unternehmens, der Bericht einer Regierungsbehörde oder eine Untersuchung durch eine Agentur, ob veröffentlicht oder privat, die normalerweise freiwillig oder unter einem Mandat archiviert oder einer höheren Behörde vorgelegt wird. Im allgemeineren Sinne jede formelle Darstellung von Fakten oder Informationen in Bezug auf ein bestimmtes Ereignis oder Phänomen, die manchmal in regelmäßigen Abständen erfolgt.', 'eng': 'A report is a separately published record of research findings, research still in progress, or other technical findings, usually bearing a report number and sometimes a grant number assigned by the funding agency. Also, an official record of the activities of a committee or corporate entity, the proceedings of a government body, or an investigation by an agency, whether published or private, usually archived or submitted to a higher authority, voluntarily or under mandate. In a more general sense, any formal account of facts or information related to a specific event or phenomenon, sometimes given at regular intervals.' } },
      { '@id': ns + 'JJKV-B1CG', 'skos:prefLabel': { 'eng': 'review' }, 'skos:definition': { 'deu': 'Eine Rezension oder ein Gutachten der veröffentlichten oder gespielten Werke anderer (z. B. Bücher, Filme, Tonaufnahmen, Theater usw.).', 'eng': 'A review of others\' published or performed works (e.g., books, films, sound recordings, theater, etc.).' } },
      { '@id': ns + 'MF25-FDGW', 'skos:prefLabel': { 'eng': 'contribution to journal' }, 'skos:definition': { 'eng': 'A contribution to a journal denotes a work published in a journal. If applicable sub-terms should be chosen.' } },
      { '@id': ns + '47QB-8QF1', 'skos:prefLabel': { 'eng': 'book' }, 'skos:definition': { 'eng': 'Items comprising a collection of leaves of paper, parchment, wood, stiffened textile, ivory, metal tablets, or other flat material, that are blank, written on, or printed, and are strung or bound together in a volume.' } },
      { '@id': ns + 'XA52-09WA', 'skos:prefLabel': { 'eng': 'book part' }, 'skos:definition': { 'eng': 'A defined chapter or section of a book, usually with a separate title or number.' } },
      { '@id': ns + '1PHE-7VMS', 'skos:prefLabel': { 'eng': 'dissertation' }, 'skos:definition': { 'eng': 'dissertation' } },
      { '@id': ns + 'QKDF-E5HA', 'skos:prefLabel': { 'eng': 'conference object' }, 'skos:definition': { 'eng': 'All kind of digital resources contributed to a conference, like conference presentation (slides), conference report, conference lecture, abstracts, demonstrations.' } },
      { '@id': ns + 'F4JN-ZST0', 'skos:prefLabel': { 'eng': 'lecture' }, 'skos:definition': { 'eng': 'Expositions of a given subject delivered before an audience or class, especially for the purposes of instruction.' } },
      { '@id': ns + 'KW6N-2VTP', 'skos:prefLabel': { 'eng': 'dataset' }, 'skos:definition': { 'eng': 'A collection of related facts and data encoded in a defined structure.' } },
      { '@id': ns + 'N35H-PDEE', 'skos:prefLabel': { 'eng': 'annotation' }, 'skos:definition': { 'eng': 'An annotation in the sense of a legal note is a legally explanatory comment on a decision handed down by a court or arbitral tribunal.' } },
      { '@id': ns + 'PYRE-RAWJ', 'skos:prefLabel': { 'eng': 'other' }, 'skos:definition': { 'deu': 'Ein Objekttyp, der in keinem Konzept dieses Vokabulars explizit angesprochen wird.', 'eng': 'An object type not explicitly addressed in any concept in this vocabulary.' } }
    ],
    loaded: true
  },
  'irobjecttypearticle': {
    terms: [
      { '@id': ns + 'VKA6-9XTY', 'skos:prefLabel': { 'eng': 'journal article' }, 'skos:definition': { 'deu': 'Ein Artikel zu einem bestimmten Thema, der im Heft einer Zeitschrift veröffentlicht wurde', 'eng': 'An article on a particular topic and published in a journal issue.' } },
      { '@id': ns + 'JMAV-7F3R', 'skos:prefLabel': { 'eng': 'report' }, 'skos:definition': { 'deu': 'Ein Bericht ist eine separat veröffentlichte Aufzeichnung von Forschungsergebnissen, noch laufender Forschung oder anderen technischen Ergebnissen, die normalerweise eine Berichtsnummer und manchmal eine von den Fördergebern zugewiesene Projektnummer tragen. Außerdem eine offizielle Aufzeichnung der Aktivitäten eines Ausschusses oder eines Unternehmens, der Bericht einer Regierungsbehörde oder eine Untersuchung durch eine Agentur, ob veröffentlicht oder privat, die normalerweise freiwillig oder unter einem Mandat archiviert oder einer höheren Behörde vorgelegt wird. Im allgemeineren Sinne jede formelle Darstellung von Fakten oder Informationen in Bezug auf ein bestimmtes Ereignis oder Phänomen, die manchmal in regelmäßigen Abständen erfolgt.', 'eng': 'A report is a separately published record of research findings, research still in progress, or other technical findings, usually bearing a report number and sometimes a grant number assigned by the funding agency. Also, an official record of the activities of a committee or corporate entity, the proceedings of a government body, or an investigation by an agency, whether published or private, usually archived or submitted to a higher authority, voluntarily or under mandate. In a more general sense, any formal account of facts or information related to a specific event or phenomenon, sometimes given at regular intervals.' } },
      { '@id': ns + 'JJKV-B1CG', 'skos:prefLabel': { 'eng': 'review' }, 'skos:definition': { 'deu': 'Eine Rezension oder ein Gutachten der veröffentlichten oder gespielten Werke anderer (z. B. Bücher, Filme, Tonaufnahmen, Theater usw.).', 'eng': 'A review of others\' published or performed works (e.g., books, films, sound recordings, theater, etc.).' } },
      { '@id': ns + 'PYRE-RAWJ', 'skos:prefLabel': { 'eng': 'other' }, 'skos:definition': { 'deu': 'Ein Objekttyp, der in keinem Konzept dieses Vokabulars explizit angesprochen wird.', 'eng': 'An object type not explicitly addressed in any concept in this vocabulary.' } }
    ],
    loaded: true
  },
  'uniakobjecttypetheses': {
    terms: [
      { '@id': 'http://base.uni-ak.ac.at/vocabulary/diploma', 'skos:prefLabel': { 'eng': 'Diploma', 'deu': 'Diplomarbeit' } },
      { '@id': 'http://base.uni-ak.ac.at/vocabulary/master', 'skos:prefLabel': { 'eng': 'Master', 'deu': 'Masterarbeit' } },
      { '@id': 'http://base.uni-ak.ac.at/vocabulary/bachelor', 'skos:prefLabel': { 'eng': 'Bachelor', 'deu': 'Bachelorarbeit' } },
      { '@id': 'http://base.uni-ak.ac.at/vocabulary/doctoral_programmes', 'skos:prefLabel': { 'eng': 'Doctoral programmes' } },
      { '@id': 'http://base.uni-ak.ac.at/vocabulary/written_component_of_artistic_thesis', 'skos:prefLabel': { 'eng': 'Schriftlicher Teil der künstlerischen Abschlussarbeit', 'deu': 'Written component of artistic Thesis' } }
    ],
    loaded: true
  },
  'oerobjecttype': {
    terms: [
      { '@id': 'https://w3id.org/kim/hcrt/application', 'skos:prefLabel': { 'eng': 'Software Application', 'deu': 'Softwareanwendung' } },
      { '@id': 'https://w3id.org/kim/hcrt/assessment', 'skos:prefLabel': { 'eng': 'Assessment', 'deu': 'Lernkontrolle' } },
      { '@id': 'https://w3id.org/kim/hcrt/audio', 'skos:prefLabel': { 'eng': 'Audio Recording', 'deu': 'Audio' } },
      { '@id': 'https://w3id.org/kim/hcrt/case_study', 'skos:prefLabel': { 'eng': 'Case Study', 'deu': 'Fallstudie' } },
      { '@id': 'https://w3id.org/kim/hcrt/course', 'skos:prefLabel': { 'eng': 'Course', 'deu': 'Kurs' } },
      { '@id': 'https://w3id.org/kim/hcrt/data', 'skos:prefLabel': { 'eng': 'Data', 'deu': 'Daten' } },
      { '@id': 'https://w3id.org/kim/hcrt/diagram', 'skos:prefLabel': { 'eng': 'Diagram', 'deu': 'Grafik' } },
      { '@id': 'https://w3id.org/kim/hcrt/drill_and_practice', 'skos:prefLabel': { 'eng': 'Drill and Practice', 'deu': 'Übung' } },
      { '@id': 'https://w3id.org/kim/hcrt/educational_game', 'skos:prefLabel': { 'eng': 'Game', 'deu': 'Lernspiel' } },
      { '@id': 'https://w3id.org/kim/hcrt/experiment', 'skos:prefLabel': { 'eng': 'Experiment', 'deu': 'Experiment' } },
      { '@id': 'https://w3id.org/kim/hcrt/image', 'skos:prefLabel': { 'eng': 'Image', 'deu': 'Abbildung' } },
      { '@id': 'https://w3id.org/kim/hcrt/index', 'skos:prefLabel': { 'eng': 'Reference Work', 'deu': 'Nachschlagewerk' } },
      { '@id': 'https://w3id.org/kim/hcrt/lesson_plan', 'skos:prefLabel': { 'eng': 'Lesson Plan', 'deu': 'Unterrichtsplanung' } },
      { '@id': 'https://w3id.org/kim/hcrt/map', 'skos:prefLabel': { 'eng': 'Map', 'deu': 'Karte' } },
      { '@id': 'https://w3id.org/kim/hcrt/portal', 'skos:prefLabel': { 'eng': 'Web Portal', 'deu': 'Portal' } },
      { '@id': 'https://w3id.org/kim/hcrt/questionnaire', 'skos:prefLabel': { 'eng': 'Questionnaire', 'deu': 'Fragebogen' } },
      { '@id': 'https://w3id.org/kim/hcrt/script', 'skos:prefLabel': { 'eng': 'Script', 'deu': 'Skript' } },
      { '@id': 'https://w3id.org/kim/hcrt/sheet_music', 'skos:prefLabel': { 'eng': 'Sheet Music', 'deu': 'Musiknoten' } },
      { '@id': 'https://w3id.org/kim/hcrt/simulation', 'skos:prefLabel': { 'eng': 'Simulation', 'deu': 'Simulation' } },
      { '@id': 'https://w3id.org/kim/hcrt/slide', 'skos:prefLabel': { 'eng': 'Presentation', 'deu': 'Präsentation' } },
      { '@id': 'https://w3id.org/kim/hcrt/text', 'skos:prefLabel': { 'eng': 'Text', 'deu': 'Textdokument' } },
      { '@id': 'https://w3id.org/kim/hcrt/textbook', 'skos:prefLabel': { 'eng': 'Textbook', 'deu': 'Lehrbuch' } },
      { '@id': 'https://w3id.org/kim/hcrt/video', 'skos:prefLabel': { 'eng': 'Video', 'deu': 'Video' } },
      { '@id': 'https://w3id.org/kim/hcrt/web_page', 'skos:prefLabel': { 'eng': 'Web Page', 'deu': 'Webseite' } },
      { '@id': 'https://w3id.org/kim/hcrt/worksheet', 'skos:prefLabel': { 'eng': 'Worksheet', 'deu': 'Arbeitsmaterial' } },
      { '@id': 'https://w3id.org/kim/hcrt/other', 'skos:prefLabel': { 'eng': 'Other', 'deu': 'Sonstiges' } },
    ],
    loaded: true
  },
  'accessright': {
    terms: [
      { '@id': ns + 'QW5R-NG4J', 'skos:prefLabel': { 'eng': 'open access' }, 'skos:definition': { 'eng': 'Open access refers to a resource that is immediately and permanently online, and free for all on the Web, without financial and technical barriers.The resource is either stored in the repository or referenced to an external journal or trustworthy archive.' } },
      { '@id': ns + 'AVFC-ZZSZ', 'skos:prefLabel': { 'eng': 'embargoed access' }, 'skos:definition': { 'eng': 'Embargoed access refers to a resource that is metadata only access until released for open access on a certain date. Embargoes can be required by publishers and funders policies, or set by the author (e.g such as in the case of theses and dissertations).' } },
      { '@id': ns + 'KC3K-CCGM', 'skos:prefLabel': { 'eng': 'restricted access' }, 'skos:definition': { 'eng': 'Restricted access refers to a resource that is available in a system but with some type of restriction for full open access. This type of access can occur in a number of different situations. Some examples are described below: The user must log-in to the system in order to access the resource The user must send an email to the author or system administrator to access the resource Access to the resource is restricted to a specific community (e.g. limited to a university community).' } },
      { '@id': ns + 'QNGE-V02H', 'skos:prefLabel': { 'eng': 'metadata only access' }, 'skos:definition': { 'eng': 'Metadata only access refers to a resource in which access is limited to metadata only. The resource itself is described by the metadata, but neither is directly available through the system or platform nor can be referenced to an open access copy in an external journal or trustworthy archive.' } }
    ],
    loaded: true
  },
  'iraccessright': {
    terms: [
      { '@id': ns + 'QW5R-NG4J', 'skos:prefLabel': { 'eng': 'open access' }, 'skos:definition': { 'deu': 'Der Zugriff auf die Ressource wird ohne Einschränkungen angeboten.', 'eng': 'Access to the resource is offered without any restrictions.' } },
      { '@id': ns + 'AVFC-ZZSZ', 'skos:prefLabel': { 'eng': 'embargoed access' }, 'skos:definition': { 'deu': 'Auf die Ressource kann erst zu einem bestimmten Zeitpunkt zugegriffen werden, an dem sie für die Öffentlichkeit freigegeben wird. Um eine Kopie kann per E-Mail angefragt werden.', 'eng': 'The resource cannot be accessed until a given date on which it will be released for open access. A copy can be requested via e-mail.' } },
      { '@id': ns + 'KC3K-CCGM', 'skos:prefLabel': { 'eng': 'restricted access' }, 'skos:definition': { 'deu': 'Der Zugang zu Volltexten und Materialien ist auf Personen oder Personengruppen beschränkt, die mit der Universität verbunden sind. Detaillierte Regelungen dazu können mit uns vereinbart werden. Um eine Kopie kann per E-Mail angefragt werden.', 'eng': 'Access to full texts and materials is restricted to persons or groups of persons affiliated with the University that we can specify as per your instructions. Others may request a copy via e-mail.' } },
      { '@id': ns + 'QNGE-V02H', 'skos:prefLabel': { 'eng': 'metadata only access' }, 'skos:definition': { 'deu': 'Der Zugriff auf Volltexte und Materialien ist Ihnen vorbehalten.', 'eng': 'Access to full texts and materials is restricted to you.' } }
    ],
    loaded: true
  },
  'versiontypes': {
    terms: [
      { '@id': ns + 'TV31-080M', 'skos:notation': ['AO'], 'skos:prefLabel': { 'eng': 'author\'s original' }, 'skos:definition': { 'deu': 'Die Version eines Textes, deren Qualität Autor*innen für ausreichend befinden, um ihn einem förmlichen Peer Review-Prozess unterziehen zu lassen. Autor*innen übernehmen die volle Verantwortung für den Text. Kann eine Versionsnummer oder einen Datumsstempel haben. Inhalt und Layout werden von den Autor*innen festgelegt.', 'eng': 'Any version of a resource that is considered by the author to be of sufficient quality to be submitted for formal peer review by a second party. The author accepts full responsibility for the resource . May have a version number or date stamp. Content and layout as set out by the author.' } },
      { '@id': ns + 'JTD4-R26P', 'skos:notation': ['SMUR'], 'skos:prefLabel': { 'eng': 'submitted manuscript under review' }, 'skos:definition': { 'deu': 'Die Version eines Textes, die bereits einer förmlichen Begutachtung seitens eines allgemein anerkannten Publikationsorgans unterzogen wird. Dieses erkennt seine Verantwortung an, für eine objektive Fachbegutachtung zu sorgen, den Autor*innen ein Feedback zu geben und letztendlich die Eignung des Textes für die Veröffentlichung entweder mit  „akzeptiert“ oder „abgelehnt“ zu beurteilen. Kann eine Versionsnummer oder einen Datumsstempel haben. Inhalt und Layout entsprechen den Einreichungsanforderungen des Herausgebers.', 'eng': 'Any version of a resource that is under formal review managed by a socially recognized publishing entity. The entity recognizes its responsibility to provide objective expert review and feedback to the author, and, ultimately, to pass judgment on the fitness of the resource for publication with an “accept” or “reject” decision. May have a version number or date stamp. Content and layout follow publisher’s submission requirements.' } },
      { '@id': ns + 'PHXV-R6B3', 'skos:notation': ['AM'], 'skos:prefLabel': { 'eng': 'accepted version' }, 'skos:definition': { 'deu': 'Die Version eines Textes, die zur Veröffentlichung angenommen wurde. Eine zweite Partei übernimmt die dauerhafte Verantwortung für den Text. Inhalt und Layout entsprechen den Einreichungsanforderungen des Herausgebers.', 'eng': 'The version of a resource that has been accepted for publication. A second party takes permanent responsibility for the resource. Content and layout follow publisher’s submission requirements.' } },
      { '@id': ns + '83ZP-CPP2', 'skos:notation': ['P'], 'skos:prefLabel': { 'eng': 'proof' }, 'skos:definition': { 'deu': 'Die Version eines Textes, die im Rahmen des Veröffentlichungsprozesses erstellt wird. Dies umfasst das korrekturgelesene Manuskript, Korrekturabzüge (d. h. eine gesetzte Version ohne endgültigen Seitenumbruch), Korrekturbögen und überarbeitete Druckfahnen. Einige dieser Versionen können im Wesentlichen dem internen Bearbeitungsablauf vorbehalten sein, andere werden jedoch üblicherweise freigegeben (z. B. an Autor*innen gesendet) und können daher öffentlich werden, obwohl sie dafür nicht autorisiert sind. Der Inhalt wurde gegenüber dem angenommenen Manuskript (Accepted Manuscript) geändert. Layout ist das des Herausgebers.', 'eng': 'A version of a resource that is created as part of the publication process. This includes the copy-edited manuscript, galley proofs (i.e., a typeset version that has not been made up into pages), page proofs, and revised proofs. Some of these versions may remain essentially internal process versions, but others are commonly released from the internal environment (e.g., proofs are sent to authors) and may thus become public, even though they are not authorized to be so. Content has been changed from Accepted Manuscript; layout is the publisher’s.' } },
      { '@id': ns + 'PMR8-3C8D', 'skos:notation': ['VoR'], 'skos:prefLabel': { 'eng': 'version of record (published version)' }, 'skos:definition': { 'deu': 'Die fertige (publizierte) Version eines Textes, die von einer als Herausgeber fungierenden Organisation zur Verfügung gestellt und formell und definitiv als "veröffentlicht" deklariert wurde. Dies schließt eine "vorab" veröffentlichte Version, die förmlich als veröffentlicht bezeichnet ist, auch schon vor der Erstellung eines Zeitschriftenbandes bzw. -heftes und der Zuweisung zugehöriger Metadaten ein, sofern sie über (einen) permanente(n) Identifikator(en) zitierbar ist. Dies schließt keine "Vorab-Version" ein, die noch nicht durch Prozesse „fixiert“ wurde, die noch angewendet werden müssen, wie z. B. das Editieren, Korrekturlesen, Layout und Satz.', 'eng': 'A fixed version of a resource that has been made available by any organization that acts as a publisher by formally and exclusively declaring the resource “published”. This includes any “early release” resource that is formally identified as being published even before the compilation of a volume issue and assignment of associated metadata, as long as it is citable via some permanent identifier(s). This does not include any “early release” resource that has not yet been “fixed” by processes that are still to be applied, such as copy-editing, proof corrections, layout, and typesetting.' } },
      { '@id': ns + 'MT1G-APSB', 'skos:notation': ['CVoR'], 'skos:prefLabel': { 'eng': 'corrected version of record' }, 'skos:definition': { 'deu': 'Eine Version der "publizierten Version" eines Textes, in der Fehler in der "publizierten Version" korrigiert wurden ["Errata" oder "Corrigenda"]. Es kann sich um Fehler von Autor*innen, Herausgeber*innen oder andere Fehler handeln, die im Lauf der Bearbeitung entstanden sind.', 'eng': 'A version of the Version of Record of a resource that has been updated or enhanced by the provision of supplementary material.' } },
      { '@id': ns + 'SSQW-AP1S', 'skos:notation': ['EVoR'], 'skos:prefLabel': { 'eng': 'enhanced version of record' }, 'skos:definition': { 'deu': 'Eine Version der "publizierten Version" eines Textes, die durch Hinzufügen von ergänzendem und/oder zusätzlichem Material auf den aktuellen Stand gebracht bzw. erweitert wurde.', 'eng': 'A version of the Version of Record of a resource that has been updated or enhanced by the provision of supplementary material.' } },
      { '@id': ns + 'KZB5-0F5G', 'skos:notation': ['NA'], 'skos:prefLabel': { 'eng': 'not applicable (or unknown)' }, 'skos:definition': { 'deu': 'Nicht anwendbar (oder unbekannt).', 'eng': 'Not Applicable (or Unknown).' } }
    ],
    loaded: true
  },
  'irfunders': {
    terms: [
      { '@id': ns + 'N3C4-ZVR0', 'skos:prefLabel': { 'eng': 'Austrian Science Fund (FWF)', 'deu': 'Fonds zur Förderung der wissenschaftlichen Forschung (FWF)' } },
      { '@id': ns + 'EYN2-KEW2', 'skos:prefLabel': { 'eng': 'Ministry of Education, Science and Research (BMBWF)', 'deu': 'Bundesministerium für Bildung, Wissenschaft und Forschung (BMBWF)' } },
      { '@id': ns + '74ZM-RFR6', 'skos:prefLabel': { 'eng': 'European Science Foundation (ESF)', 'deu': 'Europäische Wissenschaftsstiftung (ESF)' } },
      { '@id': ns + 'RDY6-W6C3', 'skos:prefLabel': { 'eng': 'European Union (all programmes)', 'deu': 'Europäische Union (alle Programme)' } },
      { '@id': ns + 'APPY-SKP2', 'skos:prefLabel': { 'eng': 'Jubiläumsfonds der Österreichischen Nationalbank', 'deu': 'Jubiläumsfonds der Österreichischen Nationalbank' } },
      { '@id': ns + 'TF8A-AS8X', 'skos:prefLabel': { 'eng': 'Austrian Academy of Sciences (ÖAW)', 'deu': 'Österreichische Akademie der Wissenschaften (ÖAW)' } },
      { '@id': ns + 'RX5K-E2KX', 'skos:prefLabel': { 'eng': 'Austrian Research Promotion Agency (FFG)', 'deu': 'Österreichische Forschungsförderungsgesellschaft mbH (FFG)' } },
      { '@id': ns + 'RESE-5QGF', 'skos:prefLabel': { 'eng': 'Österreichische Forschungsgemeinschaft (ÖFG)', 'deu': 'Österreichische Forschungsgemeinschaft (ÖFG)' } },
      { '@id': ns + 'SN0W-4T4J', 'skos:prefLabel': { 'eng': 'Agency for Education and Internationalisation (OeAD)', 'deu': 'Österreichischer Austauschdienst (OeAD)' } },
      { '@id': ns + 'S9R7-X1M2', 'skos:prefLabel': { 'eng': 'National Fund of the Republic of Austria for Victims of National Socialism', 'deu': 'Österreichischer Nationalfonds für Opfer des Nationalsozialismus' } },
      { '@id': ns + 'X4EX-JK51', 'skos:prefLabel': { 'eng': 'University of Vienna', 'deu': 'Universität Wien' } },
      { '@id': ns + 'XMYF-893X', 'skos:prefLabel': { 'eng': 'Vienna Science and Technology Fund (WWTF)', 'deu': 'Wiener Wissenschafts-, Forschungs- und Technologiefonds (WWTF)' } },
      { '@id': ns + '6HPQ-MTZV', 'skos:prefLabel': { 'eng': 'Zukunftsfonds der Republik Österreich', 'deu': 'Zukunftsfonds der Republik Österreich' } },
      { '@id': 'other', 'skos:prefLabel': { 'eng': 'Other', 'deu': 'Andere' } }
    ],
    loaded: true
  },
  'funders': {
    terms: [
      { '@id': ns + 'N3C4-ZVR0', 'skos:prefLabel': { 'eng': 'Austrian Science Fund (FWF)' } },
      { '@id': ns + 'EYN2-KEW2', 'skos:prefLabel': { 'eng': 'Bundesministerium für Bildung, Wissenschaft und Forschung (BMBWF)' } },
      { '@id': ns + '74ZM-RFR6', 'skos:prefLabel': { 'eng': 'European Science Foundation (ESF)' } },
      { '@id': ns + 'RDY6-W6C3', 'skos:prefLabel': { 'eng': 'European Union (all programmes)' } },
      { '@id': ns + 'APPY-SKP2', 'skos:prefLabel': { 'eng': 'Jubiläumsfonds der Österreichischen Nationalbank' } },
      { '@id': ns + 'TF8A-AS8X', 'skos:prefLabel': { 'eng': 'Österreichische Akademie der Wissenschaften (ÖAW)' } },
      { '@id': ns + 'RX5K-E2KX', 'skos:prefLabel': { 'eng': 'Österreichische Forschungsförderungsgesellschaft mbH (FFG)' } },
      { '@id': ns + 'RESE-5QGF', 'skos:prefLabel': { 'eng': 'Österreichische Forschungsgemeinschaft (ÖFG)' } },
      { '@id': ns + 'SN0W-4T4J', 'skos:prefLabel': { 'eng': 'Österreichischer Austauschdienst (OeAD)' } },
      { '@id': ns + 'S9R7-X1M2', 'skos:prefLabel': { 'eng': 'Österreichischer Nationalfonds für Opfer des Nationalsozialismus' } },
      { '@id': ns + 'X4EX-JK51', 'skos:prefLabel': { 'eng': 'University of Vienna' } },
      { '@id': ns + 'XMYF-893X', 'skos:prefLabel': { 'eng': 'Vienna Science and Technology Fund (WWTF)' } },
      { '@id': ns + '6HPQ-MTZV', 'skos:prefLabel': { 'eng': 'Zukunftsfonds der Republik Österreich' } }
    ],
    loaded: true
  },
  'technique': {
    terms: [
      { '@id': ns + 'NZ42-TTZT', 'skos:prefLabel': { 'eng': 'black-and-white photography', 'deu': 'Schwarz-Weiß-Fotografie' } },
      { '@id': ns + 'DC1W-JWNP', 'skos:prefLabel': { 'eng': 'color photography', 'deu': 'Farb-Fotografie' } },
      { '@id': ns + '431H-5YSA', 'skos:prefLabel': { 'eng': 'slide', 'deu': 'Diapositiv' } },
      { '@id': ns + 'VZ88-24TF', 'skos:prefLabel': { 'eng': 'black-and-white slide', 'deu': 'Schwarz-Weiß-Dia' } },
      { '@id': ns + '96PV-FFAT', 'skos:prefLabel': { 'eng': 'color slide', 'deu': 'Farb-Dia' } },
      { '@id': ns + 'AH0S-F3BV', 'skos:prefLabel': { 'eng': 'black-and-white film', 'deu': 'Schwarz-Weiß-Film' } },
      { '@id': ns + 'K818-FSM5', 'skos:prefLabel': { 'eng': 'color film', 'deu': 'Farb-Film' } },
      { '@id': ns + '748F-SQW9', 'skos:prefLabel': { 'eng': 'silent film', 'deu': 'Stummfilm' } },
      { '@id': ns + '1K09-VXQ4', 'skos:prefLabel': { 'eng': 'sound film', 'deu': 'Tonfilm' } }
    ],
    loaded: true
  },
  'material': {
    terms: [
      { '@id': ns + 'C36Q-N42M', 'skos:prefLabel': { 'eng': 'lantern slide', 'deu': 'Glasplattendia' } },
      { '@id': ns + '431H-5YSA', 'skos:prefLabel': { 'eng': 'slide', 'deu': 'Diapositiv' } },
      { '@id': ns + '6KMM-SD3M', 'skos:prefLabel': { 'eng': 'dianegative', 'deu': 'Dianegativ' } },
      { '@id': ns + 'NWNQ-GW5N', 'skos:prefLabel': { 'eng': 'Dianegativ mit Deckglas', 'deu': 'Dianegativ mit Deckglas' } },
      { '@id': ns + '5418-GWAY', 'skos:prefLabel': { 'eng': 'Diapositiv mit Deckglas', 'deu': 'Diapositiv mit Deckglas' } },
      { '@id': ns + 'HV4N-RC72', 'skos:prefLabel': { 'eng': 'Diapositiv mit Deckglas, dazwischen Folie', 'deu': 'Diapositiv mit Deckglas, dazwischen Folie' } },
      { '@id': ns + 'NQF1-2T8V', 'skos:prefLabel': { 'eng': 'Diapositiv mit Deckglas, Zeichnung auf Papier', 'deu': 'Diapositiv mit Deckglas, Zeichnung auf Papier' } },
      { '@id': ns + '45E3-JTA6', 'skos:prefLabel': { 'eng': 'Diapositiv mit Deckglas, Zeichnung auf Glas', 'deu': 'Diapositiv mit Deckglas, Zeichnung auf Glas' } },
      { '@id': ns + '440Z-1BPF', 'skos:prefLabel': { 'eng': 'Diapositiv mit Zeichnung auf Glas', 'deu': 'Diapositiv mit Zeichnung auf Glas' } },
      { '@id': ns + '2ESS-0GPG', 'skos:prefLabel': { 'eng': 'Diapositiv mit Folie', 'deu': 'Diapositiv mit Folie' } },
      { '@id': ns + '7AS5-4Q5Q', 'skos:prefLabel': { 'eng': 'Diapositiv mit Zeichnung auf Papier', 'deu': 'Diapositiv mit Zeichnung auf Papier' } }
    ],
    loaded: true
  },
  'reproduction': {
    terms: [
      { '@id': ns + 'AYRE-RQAS', 'skos:prefLabel': { 'eng': 'original', 'deu': 'Original' } },
      { '@id': ns + 'BD33-7WA2', 'skos:prefLabel': { 'eng': 'copy', 'deu': 'Kopie' } }
    ],
    loaded: true
  },
  'audience': {
    terms: [
      { '@id': ns + 'TEPR-J4EZ', 'skos:prefLabel': { 'eng': 'FSK ab 0 freigegeben' } },
      { '@id': ns + '7ANY-9744', 'skos:prefLabel': { 'eng': 'FSK ab 6 freigegeben' } },
      { '@id': ns + '4DQY-TNPT', 'skos:prefLabel': { 'eng': 'FSK ab 12 freigegeben' } },
      { '@id': ns + 'HSDH-MD0J', 'skos:prefLabel': { 'eng': 'FSK ab 16 freigegeben' } },
      { '@id': ns + 'F2VP-9Z07', 'skos:prefLabel': { 'eng': 'FSK ab 18 freigegeben' } },
      { '@id': ns + 'C2TK-3DTQ', 'skos:prefLabel': { 'eng': 'Freigegeben gemäß §14 JuSchG FSK' } }
    ],
    loaded: true
  },
  'regionalencoding': {
    terms: [
      { '@id': ns + 'AR9M-B9J4', 'skos:prefLabel': { 'eng': '1' } },
      { '@id': ns + '6Z5R-XEG2', 'skos:prefLabel': { 'eng': '2' } },
      { '@id': ns + '2YZZ-TX6M', 'skos:prefLabel': { 'eng': '3' } },
      { '@id': ns + '36BC-K989', 'skos:prefLabel': { 'eng': '4' } },
      { '@id': ns + 'ADS3-D2RC', 'skos:prefLabel': { 'eng': '5' } },
      { '@id': ns + '9NQT-YAJ4', 'skos:prefLabel': { 'eng': '6' } },
      { '@id': ns + 'QN10-XAKZ', 'skos:prefLabel': { 'eng': '7' } },
      { '@id': ns + 'KE1K-8NT7', 'skos:prefLabel': { 'eng': '8' } },
      { '@id': ns + 'GSVQ-6H7P', 'skos:prefLabel': { 'eng': 'A/1' } },
      { '@id': ns + '149W-4F0N', 'skos:prefLabel': { 'eng': 'B/2' } },
      { '@id': ns + 'VHCV-2WY3', 'skos:prefLabel': { 'eng': 'C/3' } },
      { '@id': ns + '3MQF-RDQQ', 'skos:prefLabel': { 'eng': 'region free' } }
    ],
    loaded: true
  },
  'dceformat': {
    terms: [
      { '@id': ns + 'J6JG-69V6', 'skos:prefLabel': { 'eng': '3gp' } },
      { '@id': ns + '3F67-KMTM', 'skos:prefLabel': { 'eng': 'AAC+' } },
      { '@id': ns + '7A81-FXCX', 'skos:prefLabel': { 'eng': 'Barco Auro' } },
      { '@id': ns + 'FRJJ-4376', 'skos:prefLabel': { 'eng': 'DTS' } },
      { '@id': ns + 'EHF7-FEAP', 'skos:prefLabel': { 'eng': 'DTS 96/24' } },
      { '@id': ns + 'T5SX-Z04Y', 'skos:prefLabel': { 'eng': 'DTS Discrete 5.1' } },
      { '@id': ns + '9FGJ-Z8DH', 'skos:prefLabel': { 'eng': 'DTS ES Discrete 6.1' } },
      { '@id': ns + 'ESQT-3YY5', 'skos:prefLabel': { 'eng': 'DTS ES Matrix 6.1' } },
      { '@id': ns + '348K-MZZ6', 'skos:prefLabel': { 'eng': 'DTS HD' } },
      { '@id': ns + 'EN75-Q4HC', 'skos:prefLabel': { 'eng': 'DTS NEO:6' } },
      { '@id': ns + 'T7Q0-M2FS', 'skos:prefLabel': { 'eng': 'DTS++' } },
      { '@id': ns + '28X4-0935', 'skos:prefLabel': { 'eng': 'DTS:X' } },
      { '@id': ns + '3W6M-5MP3', 'skos:prefLabel': { 'eng': 'Datasat' } },
      { '@id': ns + 'MCQ6-HPAH', 'skos:prefLabel': { 'eng': 'Digital Surround 7.1' } },
      { '@id': ns + '8T8J-936P', 'skos:prefLabel': { 'eng': 'Dolby Atmos' } },
      { '@id': ns + '9SHY-VVN6', 'skos:prefLabel': { 'eng': 'Dolby Digital' } },
      { '@id': ns + '61PF-1NEJ', 'skos:prefLabel': { 'eng': 'Dolby Digital 5.1' } },
      { '@id': ns + 'GHEV-3W1J', 'skos:prefLabel': { 'eng': 'Dolby Digital EX' } },
      { '@id': ns + 'VN51-WRAF', 'skos:prefLabel': { 'eng': 'Dolby Digital Plus' } },
      { '@id': ns + '8RFW-88Q3', 'skos:prefLabel': { 'eng': 'Dolby Pro Logic II' } },
      { '@id': ns + '55WB-XQ4P', 'skos:prefLabel': { 'eng': 'Dolby SR-D' } },
      { '@id': ns + '2JPY-C523', 'skos:prefLabel': { 'eng': 'Dolby SR-D-EX' } },
      { '@id': ns + 'XZNA-QKBP', 'skos:prefLabel': { 'eng': 'Dolby Stereo' } },
      { '@id': ns + 'W56N-VX1X', 'skos:prefLabel': { 'eng': 'Dolby Surround' } },
      { '@id': ns + 'DCZS-VZ7X', 'skos:prefLabel': { 'eng': 'Dolby TrueHD' } },
      { '@id': ns + 'SDE9-JMJJ', 'skos:prefLabel': { 'eng': 'Dolby-SR' } },
      { '@id': ns + '1DE8-XDG2', 'skos:prefLabel': { 'eng': 'MPEG-4 ALS' } },
      { '@id': ns + 'K9BD-K8GP', 'skos:prefLabel': { 'eng': 'Mono' } },
      { '@id': ns + '2BCB-S1B5', 'skos:prefLabel': { 'eng': 'SDDS' } },
      { '@id': ns + '7FMD-95WA', 'skos:prefLabel': { 'eng': 'Stereo' } },
      { '@id': ns + 'KCDR-Q08F', 'skos:prefLabel': { 'eng': 'Stereo 2.0' } },
      { '@id': ns + 'DBKT-3BQ3', 'skos:prefLabel': { 'eng': 'Surround 5.1' } },
      { '@id': ns + 'G1KV-MAFP', 'skos:prefLabel': { 'eng': 'VCD' } },
      { '@id': ns + 'RQK2-8156', 'skos:prefLabel': { 'eng': 'aif' } },
      { '@id': ns + '52G8-44YX', 'skos:prefLabel': { 'eng': 'ape' } },
      { '@id': ns + 'C5G1-JQQZ', 'skos:prefLabel': { 'eng': 'asf' } },
      { '@id': ns + 'AFZ7-4AY9', 'skos:prefLabel': { 'eng': 'au' } },
      { '@id': ns + 'KF60-K40F', 'skos:prefLabel': { 'eng': 'avi' } },
      { '@id': ns + '44YA-6HGK', 'skos:prefLabel': { 'eng': 'divx' } },
      { '@id': ns + 'GDTY-V9H4', 'skos:prefLabel': { 'eng': 'dv' } },
      { '@id': ns + 'GW3R-K19G', 'skos:prefLabel': { 'eng': 'evo' } },
      { '@id': ns + 'D3GB-MPSY', 'skos:prefLabel': { 'eng': 'fla' } },
      { '@id': ns + 'E2EJ-277K', 'skos:prefLabel': { 'eng': 'flac' } },
      { '@id': ns + '29PG-5AKN', 'skos:prefLabel': { 'eng': 'flv' } },
      { '@id': ns + '2CRY-PD3C', 'skos:prefLabel': { 'eng': 'ggf' } },
      { '@id': ns + 'KPT0-47XA', 'skos:prefLabel': { 'eng': 'm2ts' } },
      { '@id': ns + 'YK2W-SAFC', 'skos:prefLabel': { 'eng': 'm4a' } },
      { '@id': ns + 'S9PM-AGHF', 'skos:prefLabel': { 'eng': 'mac' } },
      { '@id': ns + '9594-QH49', 'skos:prefLabel': { 'eng': 'mka' } },
      { '@id': ns + 'RRWW-7W5N', 'skos:prefLabel': { 'eng': 'mkv' } },
      { '@id': ns + '15DS-TAGX', 'skos:prefLabel': { 'eng': 'mp3' } },
      { '@id': ns + 'F487-H20C', 'skos:prefLabel': { 'eng': 'mp3HD' } },
      { '@id': ns + 'AFA0-APVK', 'skos:prefLabel': { 'eng': 'mpeg' } },
      { '@id': ns + 'DT3X-PH6D', 'skos:prefLabel': { 'eng': 'mpeg-1' } },
      { '@id': ns + 'B008-MRZD', 'skos:prefLabel': { 'eng': 'mpeg-2' } },
      { '@id': ns + 'PQ4H-JT2Y', 'skos:prefLabel': { 'eng': 'mpeg-4' } },
      { '@id': ns + '26M9-M5MR', 'skos:prefLabel': { 'eng': 'mpg' } },
      { '@id': ns + 'NZKM-SH76', 'skos:prefLabel': { 'eng': 'mts' } },
      { '@id': ns + 'T59Z-PCFE', 'skos:prefLabel': { 'eng': 'mxf' } },
      { '@id': ns + 'TR4G-6P0B', 'skos:prefLabel': { 'eng': 'ogg' } },
      { '@id': ns + '7ZVE-WQQ2', 'skos:prefLabel': { 'eng': 'ra' } },
      { '@id': ns + 'J5QX-S86N', 'skos:prefLabel': { 'eng': 'ram' } },
      { '@id': ns + 'P66F-9ERB', 'skos:prefLabel': { 'eng': 'rm' } },
      { '@id': ns + 'BJDK-FC30', 'skos:prefLabel': { 'eng': 'snd' } },
      { '@id': ns + 'N0QE-B24V', 'skos:prefLabel': { 'eng': 'vob' } },
      { '@id': ns + 'X2ZR-7C1F', 'skos:prefLabel': { 'eng': 'voc' } },
      { '@id': ns + 'QYGZ-K8W4', 'skos:prefLabel': { 'eng': 'wav' } },
      { '@id': ns + '6S1H-S5GF', 'skos:prefLabel': { 'eng': 'webm' } },
      { '@id': ns + '783J-J5PD', 'skos:prefLabel': { 'eng': 'wma' } },
      { '@id': ns + '7B2N-07A7', 'skos:prefLabel': { 'eng': 'wmv' } },
      { '@id': ns + 'VTY6-58WQ', 'skos:prefLabel': { 'eng': 'xvid' } }
    ],
    loaded: true
  },
  'lang_vocab': {
    terms: [
      { '@id': ns + 'KJ67-VB82', 'skos:prefLabel': { 'eng': 'Castilian', 'deu': 'Kastilisch' } },
      { '@id': ns + 'MKXZ-SARM', 'skos:prefLabel': { 'eng': 'Lebanese', 'deu': 'Libanesisch-Arabisch' } }
    ],
    loaded: true
  },
  'lang': {
    terms: [],
    sorted: { deu: [], eng: [] },
    loaded: false
  },
  'orgunits': {
    terms: [],
    tree: [],
    loaded: false,
    linked: false,
    sorted: ''
  },
  'oefos': {
    terms: [],
    tree: [],
    loaded: false,
    sorted: ''
  },
  'thema': {
    terms: [],
    tree: [],
    loaded: false,
    sorted: ''
  },
  'bic': {
    terms: [],
    tree: [],
    loaded: false,
    sorted: ''
  }
}

export const state = () => ({
  vocabularies: vocabularies,
  fields: fieldsLib.getEditableFields()
})

const mutations = {
  sortOrgUnits(state, locale) {
    if (state.vocabularies['orgunits'].sorted !== locale) {
      if (state.vocabularies['orgunits']['terms']) {
        if (state.vocabularies['orgunits']['terms'][0]) {
          if (state.vocabularies['orgunits']['terms'][0]['phaidra:unitOrdinal']) {
            if (state.vocabularies['orgunits']['terms'][0]['phaidra:groupOrdinal']) {
              // if there are groups, sort groups first, then units within groups...
              let groups = []
              for (let u of state.vocabularies['orgunits']['terms']) {
                if (u['phaidra:orgGroupOrdinal']) {
                  if (!Array.isArray(groups[u['phaidra:orgGroupOrdinal']])) {
                    groups[u['phaidra:orgGroupOrdinal']] = []
                  }
                  groups[u['phaidra:orgGroupOrdinal']].push(u)
                }
              }
              let groupedUnits = []
              for (let g of groups) {
                if (g) {
                  g.sort(function (a, b) {
                    return a['phaidra:unitOrdinal'] - b['phaidra:unitOrdinal']
                  })
                  groupedUnits.push(g)
                }
              }
              state.vocabularies['orgunits']['terms'] = groupedUnits
            } else {
              // ... otherwise sort units only
              state.vocabularies['orgunits']['terms'].sort(function (a, b) {
                return a['phaidra:unitOrdinal'] - b['phaidra:unitOrdinal']
              })
            }
          } else {
            state.vocabularies['orgunits']['terms'].sort(function (a, b) {
              if ((a['skos:prefLabel'][locale]) && (b['skos:prefLabel'][locale])) {
                return a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale)
              }
              return 0
            })
          }
        }
      }
      orgunits.sortOrgUnitsTree(state.vocabularies['orgunits']['tree'], locale)
      state.vocabularies['orgunits'].sorted = locale
    }
  },
  setOrgUnits(state, data) {
    if (state.vocabularies['orgunits']['loaded'] === false) {
      state.vocabularies['orgunits']['tree'] = data.tree
      state.vocabularies['orgunits']['terms'] = data.terms
      state.vocabularies['orgunits']['loaded'] = true
    }
  },
  sortRoles(state, locale) {
    state.vocabularies['rolepredicate']['terms'].sort(function (a, b) {
      return a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale)
    })
    state.vocabularies['submitrolepredicate']['terms'].sort(function (a, b) {
      return a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale)
    })
  },
  sortObjectTypes(state, locale) {
    state.vocabularies['objecttype']['terms'].sort(function (a, b) {
      return a['skos:prefLabel'][locale] ? a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale) : 1
    })
  },
  sortOERObjectTypes(state, locale) {
    state.vocabularies['oerobjecttype']['terms'].sort(function (a, b) {
      return a['skos:prefLabel'][locale] ? a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale) : 1
    })
  },
  setOefos(state, data) {
    if (state.vocabularies['oefos']['loaded'] === false) {
      state.vocabularies['oefos']['tree'] = data.tree
      state.vocabularies['oefos']['terms'] = data.terms
      state.vocabularies['oefos']['loaded'] = true
    }
  },
  sortOefos(state, locale) {
    if (state.vocabularies['oefos'].sorted !== locale) {
      if (state.vocabularies['oefos']['terms']) {
        if (state.vocabularies['oefos']['terms'][0]) {
          state.vocabularies['oefos']['terms'].sort(function (a, b) {
            return a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale)
          })
        }
      }
      if (state.vocabularies['oefos']['tree']) {
        oefos.sortOefosTree(state.vocabularies['oefos']['tree'], locale)
      }
      state.vocabularies['oefos'].sorted = locale
    }
  },
  setThema(state, data) {
    if (state.vocabularies['thema']['loaded'] === false) {
      state.vocabularies['thema']['tree'] = data.tree
      state.vocabularies['thema']['terms'] = data.terms
      state.vocabularies['thema']['loaded'] = true
    }
  },
  setBic(state, data) {
    if (state.vocabularies['bic']['loaded'] === false) {
      state.vocabularies['bic']['tree'] = data.tree
      state.vocabularies['bic']['terms'] = data.terms
      state.vocabularies['bic']['loaded'] = true
    }
  },
  sortFields(state, locale) {
    i18n.locale = locale
    if (state.fields) {
      state.fields.sort(function (a, b) {
        return i18n.t(a.fieldname).localeCompare(i18n.t(b.fieldname), locale)
      })
    }
  },
  setLangTerms(state, data) {
    if (state.vocabularies['lang']['loaded'] === false) {
      state.vocabularies['lang']['terms'] = data
      state.vocabularies['lang']['loaded'] = true
    }
  },
  disableVocabularyTerms(state, vocandterms) {
    if (state.vocabularies[vocandterms.vocabulary]) {
      for (let t of state.vocabularies[vocandterms.vocabulary].terms) {
        for (let termid of vocandterms.termids) {
          if (t['@id'] === termid) {
            t.disabled = true
          }
        }
      }
    }
  },
  enableAllVocabularyTerms(state, vocabulary) {
    if (state.vocabularies[vocabulary]) {
      for (let t of state.vocabularies[vocabulary].terms) {
        t.disabled = false
      }
    }
  },
  loadVocabulary(state, payload) {
    let id = payload.id
    let data = payload.data

    let terms = []

    for (let lab of data.results.bindings) {
      // TODO: remove replace once pid. is exported to triplestore instead of vocab.
      let id = lab.id.value.replace('vocab.phaidra.org', 'pid.phaidra.org')
      let lang = lang2to3map[lab.label['xml:lang']]
      let found = false
      for (let term of terms) {
        if (term['@id'] === id) {
          term['skos:prefLabel'][lang] = lab.label.value
          found = true
          break
        }
      }
      if (!found) {
        let term = {
          '@id': id,
          'skos:prefLabel': {}
        }
        term['skos:prefLabel'][lang] = lab.label.value
        terms.push(term)
      }
    }
    Vue.set(state.vocabularies, id, {
      terms: terms,
      loaded: true
    })
  }
}

const actions = {
  sortFields({ commit }, locale) {
    commit('sortFields', locale)
  },
  sortRoles({ commit }, locale) {
    commit('sortRoles', locale)
  },
  sortObjectTypes({ commit }, locale) {
    commit('sortObjectTypes', locale)
    commit('sortOERObjectTypes', locale)
  },
  loadLanguages({ commit, state }, locale) {
    if (state.vocabularies['lang']['terms'].length < 1) {
      let langterms = languages.get_lang()
      langterms.sort((a, b) => a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale))
      commit('setLangTerms', langterms)
    }
  },
  async loadOrgUnits({ commit, rootState, state }, locale) {
    if (state.vocabularies['orgunits']['loaded'] === false) {
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/directory/org_get_units'
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          commit('setAlerts', response.data.alerts, { root: true })
        }
        let terms = []
        orgunits.getOrgUnitsTerms(terms, response.data.units, null)
        commit('setOrgUnits', { tree: response.data.units, terms: terms, locale: locale })
        commit('sortOrgUnits', locale)
      } catch (error) {
        console.log(error)
        commit('setAlerts', [{ type: 'danger', msg: 'Failed to fetch org units: ' + error }], { root: true })
      }
    } else {
      if (state.vocabularies['orgunits']['locale'] !== locale) {
        commit('sortOrgUnits', locale)
      }
    }
  },
  async loadOefos({ commit, rootState, state }, locale) {
    if (state.vocabularies['oefos']['loaded'] === false) {
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/vocabulary?uri=oefos2012'
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          commit('setAlerts', response.data.alerts)
        }
        let terms = []
        oefos.getOefosTerms(terms, response.data.vocabulary, null)
        commit('setOefos', { tree: response.data.vocabulary, terms: terms, locale: locale })
        commit('sortOefos', locale)
      } catch (error) {
        console.log(error)
        commit('setAlerts', [{ type: 'danger', msg: 'Failed to fetch oefos: ' + error }])
      }
    } else {
      if (state.vocabularies['oefos']['locale'] !== locale) {
        commit('sortOefos', locale)
      }
    }
  },
  async loadThema({ commit, rootState, state }, locale) {
    if (state.vocabularies['thema']['loaded'] === false) {
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/vocabulary?uri=thema'
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          commit('setAlerts', response.data.alerts)
        }
        let terms = []
        thema.getThemaTerms(terms, response.data.vocabulary, null)
        commit('setThema', { tree: response.data.vocabulary, terms: terms, locale: locale })
        console.log(terms)
      } catch (error) {
        console.log(error)
        commit('setAlerts', [{ type: 'danger', msg: 'Failed to fetch thema: ' + error }])
      }
    }
  },
  async loadBic({ commit, rootState, state }, locale) {
    if (state.vocabularies['bic']['loaded'] === false) {
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/vocabulary?uri=bic'
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          commit('setAlerts', response.data.alerts)
        }
        let terms = []
        bic.getBicTerms(terms, response.data.vocabulary, null)
        commit('setBic', { tree: response.data.vocabulary, terms: terms, locale: locale })
        console.log(terms)
      } catch (error) {
        console.log(error)
        commit('setAlerts', [{ type: 'danger', msg: 'Failed to fetch BIC: ' + error }])
      }
    }
  },
  async loadVocabulary({ commit, state, rootState }, vocabId) {
    if (state.vocabularies[vocabId]) {
      if (state.vocabularies[vocabId].loaded) {
        return
      }
    }
    try {
      var raw = 'PREFIX v: <' + rootState.appconfig.apis.vocserver.ns + '> PREFIX : <' + rootState.appconfig.apis.vocserver.ns + 'schema#> PREFIX skos: <http://www.w3.org/2004/02/skos/core#> SELECT ?id ?label ?exp WHERE { graph ?g { ?id v:memberOf  v:' + vocabId + ' . ?id skos:prefLabel ?label . OPTIONAL { ?id :expires ?exp . } } }'
      let response = await this.$axios.request({
        method: 'POST',
        url: rootState.appconfig.apis.vocserver.url + rootState.appconfig.apis.vocserver.dataset + '/query',
        headers: { 'Content-Type': 'application/sparql-query' },
        data: raw
      })
      if (response.data && response.data.results && response.data.results.bindings) {
        commit('loadVocabulary', { id: vocabId, data: response.data })
      } else {
        console.log('Failed to fetch vocabulary ' + vocabId)
        commit('setAlerts', [{ type: 'danger', msg: 'Failed to fetch vocabulary ' + vocabId }])
      }
    } catch (error) {
      console.log(error)
      commit('setAlerts', [{ type: 'danger', msg: 'Failed to fetch vocabulary ' + vocabId + ': ' + error }])
    }
  }
}

const getters = {
  getLocalizedTermLabel: (state) => (voc, id, lang) => {
    let terms = state.vocabularies[voc].terms
    for (let i = 0; i < terms.length; i++) {
      if (terms[i]['@id'] === id) {
        return terms[i]['skos:prefLabel'][lang] ? terms[i]['skos:prefLabel'][lang] : terms[i]['skos:prefLabel']['eng'] ? terms[i]['skos:prefLabel']['eng'] : terms[i]['skos:prefLabel']['deu']
      }
    }
  },
  getLocalizedTermLabelByNotation: (state) => (voc, notation, lang) => {
    let terms = state.vocabularies[voc].terms
    for (let i = 0; i < terms.length; i++) {
      if (Array.isArray(terms[i]['skos:notation'])) {
        for (let n of terms[i]['skos:notation']) {
          if (n === notation) {
            return terms[i]['skos:prefLabel'][lang] ? terms[i]['skos:prefLabel'][lang] : terms[i]['skos:prefLabel']['eng'] ? terms[i]['skos:prefLabel']['eng'] : terms[i]['skos:prefLabel']['deu']
          }
        }
      } else {
        if (terms[i]['skos:notation'] === notation) {
          return terms[i]['skos:prefLabel'][lang] ? terms[i]['skos:prefLabel'][lang] : terms[i]['skos:prefLabel']['eng'] ? terms[i]['skos:prefLabel']['eng'] : terms[i]['skos:prefLabel']['deu']
        }
      }
    }
  },
  getTerm: (state) => (voc, id) => {
    let terms = state.vocabularies[voc].terms
    for (let i = 0; i < terms.length; i++) {
      if (terms[i]['@id'] === id) {
        return terms[i]
      }
    }
  },
  getTermProperty: (state) => (voc, id, prop) => {
    let terms = state.vocabularies[voc].terms
    for (let i = 0; i < terms.length; i++) {
      if (terms[i]['@id'] === id) {
        return terms[i][prop]
      }
    }
  },
  getObjectTypeForResourceType: (state) => (rtId, locale) => {
    let arr = []
    let other = null
    if (rtId !== ns + 'GXS7-ENXJ') {
      for (let otId of ot4rt[rtId]) {
        for (let term of state.vocabularies['objecttype'].terms) {
          if (term['@id'] === otId) {
            if (term['@id'] === ns + 'PYRE-RAWJ') {
              other = term
            } else {
              arr.push(term)
            }
          }
        }
      }
    }
    arr.sort(function (a, b) {
      return a['skos:prefLabel'][locale] ? a['skos:prefLabel'][locale].localeCompare(b['skos:prefLabel'][locale], locale) : 1
    })
    if (other) {
      arr.push(other)
    }
    return arr
  }
}

export default {
  state,
  mutations,
  actions,
  getters
}
