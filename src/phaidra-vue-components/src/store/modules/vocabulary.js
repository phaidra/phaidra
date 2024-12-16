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
    // website
    ns + 'R1WF-V45Y',
    // 3D model
    ns + 'T6C3-46S4',
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
      { '@id': 'dcterms:temporal', 'skos:prefLabel': { 'eng': 'Temporal coverage', 'deu': 'Zeitliche Abdeckung' } },
      { '@id': 'phaidra:dateApprobation', 'skos:prefLabel': { 'eng': 'Approbation date', 'deu': 'Approbationsdatum' } }
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
  'identifiertype': {
    terms: [
      { '@id': 'ids:orcid', 'skos:prefLabel': { 'eng': 'ORCID' }, 'skos:example': '0000-0002-1825-0097' },
      { '@id': 'ids:gnd', 'skos:prefLabel': { 'eng': 'GND' }, 'skos:example': '118635808' },
      { '@id': 'ids:viaf', 'skos:prefLabel': { 'eng': 'VIAF' }, 'skos:example': '89597697' },
      { '@id': 'ids:wikidata', 'skos:prefLabel': { 'eng': 'Wikidata ID' }, 'skos:example': 'Q129772' },
      { '@id': 'ids:lcnaf', 'skos:prefLabel': { 'eng': 'LCNAF' }, 'skos:example': 'n79021164' },
      { '@id': 'ids:isni', 'skos:prefLabel': { 'eng': 'ISNI' }, 'skos:example': '0000000121174585' },
      { '@id': 'ids:uri', 'skos:prefLabel': { 'eng': 'URI' }, 'skos:example': 'https://authority.example.com/path/resource' },
      { '@id': 'ids:doi', 'skos:prefLabel': { 'eng': 'DOI' }, 'skos:example': '10.1629/uksg.419' },
      { '@id': 'ids:hdl', 'skos:prefLabel': { 'eng': 'Handle' }, 'skos:example': '11353/10.761200' },
      { '@id': 'ids:urn', 'skos:prefLabel': { 'eng': 'URN' }, 'skos:example': 'urn:nbn:at:at-ubw-21405.98566.193074-2' },
      { '@id': 'ids:isbn', 'skos:prefLabel': { 'eng': 'ISBN' }, 'skos:example': '978-3-16-148410-0' },
      { '@id': 'ids:issn', 'skos:prefLabel': { 'eng': 'ISSN' }, 'skos:example': '1544-9173' },
      { '@id': 'phaidra:acnumber', 'skos:prefLabel': { 'eng': 'AC number', 'deu': 'AC Nummer' }, 'skos:example': 'AC13399179' }
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
  'irprojectid': {
    terms: [
      { '@id': 'ids:doi', 'skos:prefLabel': { 'eng': 'DOI' }, 'skos:example': '10.1629/uksg.419' },
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
      { '@id': 'role:oth', 'skos:prefLabel': { 'eng': 'Other', 'deu': 'Andere', 'ita': 'Altro' }, 'skos:definition': { 'eng': 'A role that has no equivalent in the MARC list.', 'deu': 'Eine Rolle, die keine Entsprechung in der MARC-Liste hat.' } },
      { '@id': 'role:abr', 'skos:prefLabel': { 'eng': 'Abridger', 'deu': 'Autor*in von Kurzfassungen', 'ita': 'Abridger' }, 'skos:definition': { 'eng': 'A person, family, or organization contributing to a resource by shortening or condensing the original work but leaving the nature and content of the original work substantially unchanged. For substantial modifications that result in the creation of a new work, see author.', 'deu': 'Eine Person, Familie oder Organisation, die einen Beitrag zu einer Ressource leistet, indem sie das ursprüngliche Werk kürzt oder zusammenfasst, aber die Art und den Inhalt des ursprünglichen Werks im Wesentlichen unverändert lässt. Für wesentliche Änderungen, die zur Schaffung eines neuen Werks führen, siehe Autor.' } },
      { '@id': 'role:act', 'skos:prefLabel': { 'eng': 'Actor', 'deu': 'Schauspieler*in', 'ita': 'Attore' }, 'skos:definition': {  'eng': 'A performer contributing to an expression of a work by acting as a cast member or player in a musical or dramatic presentation, etc.',  'deu': 'Ein*e Darsteller*in, der bzw. die zum Ausdruck eines Werks beiträgt, indem er bzw. sie als Darsteller*in oder Spieler*in in einer musikalischen oder dramatischen Aufführung usw. auftritt.' } },
      { '@id': 'role:adp', 'skos:prefLabel': { 'eng': 'Adapter', 'deu': 'Bearbeiter*in', 'ita': 'Adattatore' }, 'skos:definition': {  'eng': 'A person or organization who 1) reworks a musical composition, usually for a different medium, or 2) rewrites novels or stories for motion pictures or other audiovisual medium.',  'deu': 'Eine Person oder Organisation, die 1) eine Musikkomposition überarbeitet, in der Regel für ein anderes Medium, oder 2) Romane oder Geschichten für Filme oder andere audiovisuelle Medien umschreibt.' } },
      { '@id': 'role:rcp', 'skos:prefLabel': { 'eng': 'Addressee', 'deu': 'Empfänger*in', 'ita': 'Destinatario' }, 'skos:definition': {  'eng': 'A person, family, or organization to whom the correspondence in a work is addressed.',  'deu': 'Eine Person, Familie oder Organisation, an die die Korrespondenz in einem Werk gerichtet ist.' } },
      { '@id': 'role:advisor', 'skos:prefLabel': { 'eng': 'Adviser', 'deu': 'Betreuer*in der Hochschulschrift', 'ita': 'Consigliere' }, 'skos:definition': {'eng': 'A person under whose supervision a degree candidate develops and presents a university thesis.', 'deu': 'Eine Person, unter deren Aufsicht ein*e Kandidat*in eine Hochschulschrift erarbeitet und vorlegt.' } },
      { '@id': 'role:anl', 'skos:prefLabel': { 'eng': 'Analyst', 'deu': 'Analyst*in ', 'ita': 'Analista' }, 'skos:definition': {  'eng': 'A person or organization that reviews, examines and interprets data or information in a specific area.',  'deu': 'Eine Person oder Organisation, die Daten oder Informationen in einem bestimmten Bereich überprüft, untersucht und interpretiert.' } },
      { '@id': 'role:anm', 'skos:prefLabel': { 'eng': 'Animator', 'deu': 'Animator*in', 'ita': 'Animator' }, 'skos:definition': {  'eng': 'A person contributing to a moving image work or computer program by giving apparent movement to inanimate objects or drawings. For the creator of the drawings that are animated, see artist.',  'deu': 'Eine Person, die zu einem Bewegtbildwerk oder Computerprogramm beiträgt, indem sie unbelebten Objekten oder Zeichnungen scheinbare Bewegung verleiht. Für den bzw. die Schöpfer*in der Zeichnungen, die animiert werden, siehe Künstler.' } },
      { '@id': 'role:ann', 'skos:prefLabel': { 'eng': 'Annotator', 'deu': 'Autor*in von Anmerkungen', 'ita': 'Annotatore' }, 'skos:definition': {  'eng': 'A person who makes manuscript annotations on an item.',  'deu': 'Eine Person, die handschriftliche Anmerkungen zu einem Gegenstand macht.' } },
      { '@id': 'role:app', 'skos:prefLabel': { 'eng': 'Applicant', 'deu': 'Antragsteller*in', 'ita': 'Applicant' }, 'skos:definition': {  'eng': 'A person or organization responsible for the submission of an application or who is named as eligible for the results of the processing of the application (e.g., bestowing of rights, reward, title, position).',  'deu': 'Eine Person oder Organisation, die für die Einreichung eines Antrags verantwortlich ist oder die für die Ergebnisse der Antragsbearbeitung (z. B. Verleihung von Rechten, Belohnung, Titel, Position) als berechtigt benannt wird.' } },
      { '@id': 'role:arc', 'skos:prefLabel': { 'eng': 'Architect', 'deu': 'Architekt*in', 'ita': 'Architetto' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating an architectural design, including a pictorial representation intended to show how a building, etc., will look when completed. It also oversees the construction of structures.',  'deu': 'Eine Person, eine Familie oder eine Organisation, die für die Erstellung eines architektonischen Entwurfs verantwortlich ist, einschließlich einer bildlichen Darstellung, die zeigen soll, wie ein Gebäude usw. nach seiner Fertigstellung aussehen wird. Sie beaufsichtigt auch den Bau von Bauwerken.' } },
      { '@id': 'role:arr', 'skos:prefLabel': { 'eng': 'Arranger', 'deu': 'Arrangeur*in', 'ita': 'Arrangiatore' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a musical work by rewriting the composition for a medium of performance different from that for which the work was originally intended, or modifying the work for the same medium of performance, etc., such that the musical substance of the original composition remains essentially unchanged. For extensive modification that effectively results in the creation of a new musical work, see composer.',  'deu': 'Eine Person, Familie oder Organisation, die einen Beitrag zu einem Musikwerk leistet, indem sie die Komposition für ein anderes Aufführungsmedium umschreibt als das, für das das Werk ursprünglich bestimmt war, oder das Werk für dasselbe Aufführungsmedium verändert usw., sodass die musikalische Substanz der ursprünglichen Komposition im Wesentlichen unverändert bleibt. Für umfangreiche Änderungen, die tatsächlich zur Schaffung eines neuen Musikwerks führen, siehe Komponist*in.' } },
      { '@id': 'role:acp', 'skos:prefLabel': { 'eng': 'Art copyist', 'deu': 'Kunstkopist*in', 'ita': 'Art copyist' }, 'skos:definition': {  'eng': 'A person (e.g., a painter or sculptor) who makes copies of works of visual art.',  'deu': 'Eine Person (z. B. ein*e Maler*in oder Bildhauer*in), die Kopien von Werken der bildenden Kunst anfertigt.' } },
      { '@id': 'role:adi', 'skos:prefLabel': { 'eng': 'Art director', 'deu': 'Szenenbildner*in', 'ita': 'Art director' }, 'skos:definition': {  'eng': 'A person contributing to a motion picture or television production by overseeing the artists and craftspeople who build the sets.',  'deu': 'Eine Person, die an einer Film- oder Fernsehproduktion mitwirkt, indem sie die Künstler*innen und Handwerker*innen beaufsichtigt, die die Kulissen bauen.' } },
      { '@id': 'role:art', 'skos:prefLabel': { 'eng': 'Artist', 'deu': 'Künstler*in', 'ita': 'Artista' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a work by conceiving, and implementing, an original graphic design, drawing, painting, etc. For book illustrators, prefer Illustrator [ill].',  'deu': 'Eine Person, Familie oder Organisation, die für die Schaffung eines Werks verantwortlich ist, indem sie ein originelles grafisches Design, eine Zeichnung, ein Gemälde usw. entwirft und umsetzt. Für Buchillustrator*innen ist Illustrator*in [ill] vorzuziehen.' } },
      { '@id': 'role:ard', 'skos:prefLabel': { 'eng': 'Artistic director', 'deu': 'Intendant', 'ita': 'Direttore artistico' }, 'skos:definition': {  'eng': 'A person responsible for controlling the development of the artistic style of an entire production, including the choice of works to be presented and selection of senior production staff.',  'deu': 'Eine Person, die für die Kontrolle der Entwicklung des künstlerischen Stils einer gesamten Produktion verantwortlich ist, einschließlich der Auswahl der zu präsentierenden Werke und der Auswahl des leitenden Produktionspersonals.' } },
      { '@id': 'role:assessor', 'skos:prefLabel': { 'eng': 'Assessor', 'deu': 'Beurteiler*in der Hochschulschrift', 'ita': 'Assessor' }, 'skos:definition': { 'eng': 'A person who assesses a university thesis.', 'deu': 'Eine Person, die eine Hochschulschrift beurteilt.' } },
      { '@id': 'role:asg', 'skos:prefLabel': { 'eng': 'Assignee', 'deu': 'Rechtsnachfolger*in', 'ita': 'Assignee' }, 'skos:definition': {  'eng': 'A person or organization to whom a license for printing or publishing has been transferred.',  'deu': 'Eine Person oder Organisation, der eine Lizenz für Druck oder Veröffentlichung übertragen wurde.' } },
      { '@id': 'role:asn', 'skos:prefLabel': { 'eng': 'Associated name', 'deu': 'Assoziierter Name', 'ita': 'Associated name' }, 'skos:definition': {  'eng': 'A person or organization associated with or found in an item or collection, which cannot be determined to be that of a Former owner [fmo] or other designated relationship indicative of provenance.',  'deu': 'Eine Person oder Organisation, die mit einem Gegenstand oder einer Sammlung in Verbindung gebracht wird oder in dieser zu finden ist, ohne dass ein*e frühere*r Eigentümer*in [fmo] oder eine andere ausgewiesene Beziehung, die auf die Provenienz hinweist, festgestellt werden kann.' } },
      { '@id': 'role:att', 'skos:prefLabel': { 'eng': 'Attributed name', 'deu': 'Zugeschriebene/r Autor*in', 'ita': 'Nome attribuito' }, 'skos:definition': {  'eng': 'An author, artist, etc., relating him/her to a resource for which there is or once was substantial authority for designating that person as author, creator, etc. of the work.',  'deu': 'Ein*e Autor*in, Künstler*in usw., der bzw. die mit einer Quelle in Verbindung gebracht wird, für die es eine wesentliche Berechtigung gibt oder gab, diese Person als Autor*in, Schöpfer*in usw. des Werks zu bezeichnen.' } },
      { '@id': 'role:auc', 'skos:prefLabel': { 'eng': 'Auctioneer', 'deu': 'Auktionator*in', 'ita': 'Auctioneer' }, 'skos:definition': {  'eng': 'A person or organization in charge of the estimation and public auctioning of goods, particularly books, artistic works, etc.',  'deu': 'Eine Person oder Organisation, die mit der Schätzung und öffentlichen Versteigerung von Gütern, insbesondere von Büchern, Kunstwerken usw., beauftragt ist.' } },
      { '@id': 'role:aut', 'skos:prefLabel': { 'eng': 'Author', 'deu': 'Autor*in', 'ita': 'Author' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a work that is primarily textual in content, regardless of media type (e.g., printed text, spoken word, electronic text, tactile text) or genre (e.g., poems, novels, screenplays, blogs). Use also for persons, etc., creating a new work by paraphrasing, rewriting, or adapting works by another creator such that the modification has substantially changed the nature and content of the original or changed the medium of expression.',  'deu': 'Eine Person, Familie oder Organisation, die für die Schaffung eines Werks verantwortlich ist, das hauptsächlich textlichen Inhalt hat, unabhängig von der Art des Mediums (z. B. gedruckter Text, gesprochener Text, elektronischer Text, taktiler Text) oder dem Genre (z. B. Gedichte, Romane, Drehbücher, Blogs). Verwenden Sie den Begriff auch für Personen usw., die ein neues Werk schaffen, indem sie Werke eines anderen Schöpfers bzw. einer anderen Schöpferin paraphrasieren, umschreiben oder adaptieren, so dass die Modifikation die Art und den Inhalt des Originals wesentlich verändert oder das Ausdrucksmedium verändert hat.' } },
      { '@id': 'role:aqt', 'skos:prefLabel': { 'eng': 'Author in quotations or text abstracts', 'deu': 'Autor*in in Zitaten oder Zusammenfassungen', 'ita': 'Author in quotations or text abstracts' }, 'skos:definition': {  'eng': 'A person or organization whose work is largely quoted or extracted in works to which he or she did not contribute directly. Such quotations are found particularly in exhibition catalogs, collections of photographs, etc.',  'deu': 'Eine Person oder Organisation, deren Arbeit in Werken, zu denen sie nicht direkt beigetragen hat, weitgehend zitiert oder entnommen wird. Solche Zitate finden sich insbesondere in Ausstellungskatalogen, Fotosammlungen usw.' } },
      { '@id': 'role:aft', 'skos:prefLabel': { 'eng': 'Author of afterword, colophon, etc.', 'deu': 'Autor*in des Nachworts, Kolophon…', 'ita': 'Author of afterword, colophon, etc.' }, 'skos:definition': {  'eng': 'A person or organization responsible for an afterword, postface, colophon, etc. but who is not the chief author of a work.',  'deu': 'Eine Person oder Organisation, die für ein Nachwort, Nachwort, Kolophon usw. verantwortlich ist, aber nicht der bzw. die Hauptautor*in eines Werks ist.' } },
      { '@id': 'role:aud', 'skos:prefLabel': { 'eng': 'Author of dialog', 'deu': 'Autor*in eines Kommentars', 'ita': 'Autore del dialogo' }, 'skos:definition': {  'eng': 'A person or organization responsible for the dialog or spoken commentary for a screenplay or sound recording.',  'deu': 'Eine Person oder Organisation, die für den Dialog oder den gesprochenen Kommentar eines Drehbuchs oder einer Tonaufnahme verantwortlich ist.' } },
      { '@id': 'role:aui', 'skos:prefLabel': { 'eng': 'Author of introduction', 'deu': 'Autor*in der Einleitung', 'ita': 'Autore dell\'introduzione' }, 'skos:definition': {  'eng': 'A person or organization responsible for an introduction, preface, foreword, or other critical introductory matter, but who is not the chief author.',  'deu': 'Eine Person oder Organisation, die für eine Einleitung, ein Vorwort, ein Vorwort oder einen anderen kritischen einleitenden Teil verantwortlich ist, aber nicht der bzw. die Hauptautor*in ist.' } },
      { '@id': 'role:authorofsubtitles', 'skos:prefLabel': { 'eng': 'Author of subtitles', 'deu': 'Autor*in der Untertitel', 'ita': 'Autore dei sottotitoli' }, 'skos:definition': { 'eng': 'A person or organisation responsible for creating the captions of a film, television programm or video recording.', 'deu': 'Eine Person oder Organisation, die für die Erstellung der Untertitel eines Films, einer Fernsehsendung oder einer Videoaufnahme verantwortlich ist.' } },
      { '@id': 'role:ato', 'skos:prefLabel': { 'eng': 'Autographer', 'deu': 'Unterzeichnende/r', 'ita': 'Autographer' }, 'skos:definition': { 'eng': 'A person whose manuscript signature appears on an item.',  'deu': 'Eine Person, deren handschriftliche Unterschrift auf einem Gegenstand erscheint.' } },
      { '@id': 'role:ant', 'skos:prefLabel': { 'eng': 'Bibliographic antecedent', 'deu': 'Verfasser*in der literarischen Vorlage', 'ita': 'Antecedente bibliografico' }, 'skos:definition': {  'eng': 'A person or organization responsible for a resource upon which the resource represented by the bibliographic description is based. This may be appropriate for adaptations, sequels, continuations, indexes, etc.',  'deu': 'Eine Person oder Organisation, die für eine Ressource verantwortlich ist, auf der die durch die bibliografische Beschreibung dargestellte Ressource basiert. Dies kann bei Adaptionen, Fortsetzungen, Indexen usw. angebracht sein.' } },
      { '@id': 'role:bnd', 'skos:prefLabel': { 'eng': 'Binder', 'deu': 'Buchbinder*in', 'ita': 'Legatore' }, 'skos:definition': {  'eng': 'A person who binds an item.',  'deu': 'Eine Person, die einen Gegenstand bindet.' } },
      { '@id': 'role:bdd', 'skos:prefLabel': { 'eng': 'Binding designer', 'deu': 'Buchbinde-Designer*in', 'ita': 'Binding designer' }, 'skos:definition': {  'eng': 'A person or organization responsible for the binding design of a book, including the type of binding, the type of materials used, and any decorative aspects of the binding.',  'deu': 'Eine Person oder Organisation, die für die Gestaltung des Einbands eines Buches verantwortlich ist, einschließlich der Art des Einbands, der verwendeten Materialien und aller dekorativen Aspekte des Einbands.' } },
      { '@id': 'role:blw', 'skos:prefLabel': { 'eng': 'Blurb writer (missing space)', 'deu': 'Autor*in des Klappentextes', 'ita': 'Blurbwriter' }, 'skos:definition': {  'eng': 'A person or organization responsible for writing a commendation or testimonial for a work, which appears on or within the publication itself, frequently on the back or dust jacket of print publications or on advertising material for all media.',  'deu': 'Eine Person oder Organisation, die für das Verfassen einer lobenden Erwähnung oder eines Zeugnisses für ein Werk verantwortlich ist, das auf oder in der Publikation selbst erscheint, häufig auf der Rückseite oder dem Schutzumschlag von Printpublikationen oder auf Werbematerial für alle Medien.' } },
      { '@id': 'role:bkd', 'skos:prefLabel': { 'eng': 'Book designer', 'deu': 'Buchgestalter*in', 'ita': 'Designer del libro' }, 'skos:definition': {  'eng': 'A person or organization involved in manufacturing a manifestation by being responsible for the entire graphic design of a book, including arrangement of type and illustration, choice of materials, and process used.',  'deu': 'A person or organization involved in manufacturing a manifestation by being responsible for the entire graphic design of a book, including arrangement of type and illustration, choice of materials, and process used.' } },
      { '@id': 'role:bkp', 'skos:prefLabel': { 'eng': 'Book producer', 'deu': 'Buchproduzent*in', 'ita': 'Book producer' }, 'skos:definition': {  'eng': 'A person or organization responsible for the production of books and other print media.',  'deu': 'Eine Person oder Organisation, die für die Produktion von Büchern und anderen Printmedien verantwortlich ist.' } },
      { '@id': 'role:bjd', 'skos:prefLabel': { 'eng': 'Bookjacket designer', 'deu': 'Designer*in des Buchumschlages / Schutzumschlages', 'ita': 'Bookjacket designer' }, 'skos:definition': {  'eng': 'A person or organization responsible for the design of flexible covers designed for or published with a book, including the type of materials used, and any decorative aspects of the bookjacket.',  'deu': 'Eine Person oder Organisation, die für die Gestaltung flexibler Einbände verantwortlich ist, die für ein Buch entworfen oder mit diesem veröffentlicht werden, einschließlich der Art der verwendeten Materialien und aller dekorativen Aspekte des Buchumschlags.' } },
      { '@id': 'role:bpd', 'skos:prefLabel': { 'eng': 'Bookplate designer', 'deu': 'Designer*in des Exlibris', 'ita': 'Creatore dell\'ex-libris' }, 'skos:definition': {  'eng': 'A person or organization responsible for the design of a book owner\'s identification label that is most commonly pasted to the inside front cover of a book.',  'deu': 'Eine Person oder Organisation, die für die Gestaltung des Kennzeichnungsetiketts eines Buchbesitzers bzw. einer Buchbesitzerin verantwortlich ist, das in der Regel auf die Innenseite des vorderen Buchdeckels geklebt wird.' } },
      { '@id': 'role:bsl', 'skos:prefLabel': { 'eng': 'Bookseller', 'deu': 'Buchhändler*in', 'ita': 'Bookseller' }, 'skos:definition': {  'eng': 'A person or organization who makes books and other bibliographic materials available for purchase. Interest in the materials is primarily lucrative.',  'deu': 'Eine Person oder Organisation, die Bücher und andere bibliografische Materialien zum Kauf anbietet. Das Interesse an diesen Materialien ist in erster Linie lukrativ.' } },
      { '@id': 'role:brl', 'skos:prefLabel': { 'eng': 'Braille embosser', 'deu': 'Brailledrucker*in', 'ita': 'Braille embosser' }, 'skos:definition': {  'eng': 'A person, family, or organization involved in manufacturing a resource by embossing Braille cells using a stylus, special embossing printer, or other device.',  'deu': 'Eine Person, Familie oder Organisation, die an der Herstellung eines Hilfsmittels beteiligt ist, indem sie Braille-Zellen mit einem Stift, einem speziellen Prägedrucker oder einem anderen Gerät prägt.' } },
      { '@id': 'role:brd', 'skos:prefLabel': { 'eng': 'Broadcaster', 'deu': 'Rundfunkveranstalter*in', 'ita': 'Broadcaster' }, 'skos:definition': {  'eng': 'A person, family, or organization involved in broadcasting a resource to an audience via radio, television, webcast, etc.',  'deu': 'Eine Person, Familie oder Organisation, die eine Ressource über Radio, Fernsehen, Webcast usw. an ein Publikum sendet.' } },
      { '@id': 'role:cll', 'skos:prefLabel': { 'eng': 'Calligrapher', 'deu': 'Kalligraph*in', 'ita': 'Calligrapher' }, 'skos:definition': {  'eng': 'A person or organization who writes in an artistic hand, usually as a copyist and or engrosser.',  'deu': 'Eine Person oder Organisation, die mit einer künstlerischen Handschrift schreibt, in der Regel als Kopist*in und/oder Engrosschreiber*in.' } },
      { '@id': 'role:ctg', 'skos:prefLabel': { 'eng': 'Cartographer', 'deu': 'Kartograph*in', 'ita': 'Cartografo' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a map, atlas, globe, or other cartographic work.',  'deu': 'Eine Person, Familie oder Organisation, die für die Erstellung einer Karte, eines Atlanten, eines Globus oder eines anderen kartografischen Werks verantwortlich ist.' } },
      { '@id': 'role:cas', 'skos:prefLabel': { 'eng': 'Caster', 'deu': 'Gießer*in', 'ita': 'Caster' }, 'skos:definition': {  'eng': 'A person, family, or organization involved in manufacturing a resource by pouring a liquid or molten substance into a mold and leaving it to solidify to take the shape of the mold.',  'deu': 'Eine Person, Familie oder Organisation, die an der Herstellung einer Ressource beteiligt ist, indem sie eine flüssige oder geschmolzene Substanz in eine Form gießt und sie erstarren lässt, damit sie die Form der Form annimmt.' } },
      { '@id': 'role:cns', 'skos:prefLabel': { 'eng': 'Censor', 'deu': 'Zensor*in', 'ita': 'Censor' }, 'skos:definition': {  'eng': 'A person or organization who examines bibliographic resources for the purpose of suppressing parts deemed objectionable on moral, political, military, or other grounds.',  'deu': 'Eine Person oder Organisation, die bibliografische Ressourcen mit dem Ziel prüft, Teile zu unterdrücken, die aus moralischen, politischen, militärischen oder anderen Gründen als anstößig gelten.' } },
      { '@id': 'role:chr', 'skos:prefLabel': { 'eng': 'Choreographer', 'deu': 'Choreograph*in', 'ita': 'Coreografo' }, 'skos:definition': {  'eng': 'A person responsible for creating or contributing to a work of movement.',  'deu': 'Eine Person, die für die Schaffung eines Werks der Bewegung verantwortlich ist oder zu diesem beiträgt.' } },
      { '@id': 'role:cng', 'skos:prefLabel': { 'eng': 'Cinematographer', 'deu': 'Kameramann/frau', 'ita': 'Direttore della fotografia' }, 'skos:definition': {  'eng': 'A person in charge of photographing a motion picture, who plans the technical aspets of lighting and photographing of scenes, and often assists the director in the choice of angles, camera setups, and lighting moods. He or she may also supervise the further processing of filmed material up to the completion of the work print. Cinematographer is also referred to as director of photography. Do not confuse with videographer.',  'deu': 'Eine Person, die für das Fotografieren eines Films verantwortlich ist, die die technischen Aspekte der Beleuchtung und des Fotografierens von Szenen plant und oft den bzw. die Regisseur*in bei der Wahl von Winkeln, Kameraeinstellungen und Lichtstimmungen unterstützt. Er oder sie kann auch die Weiterverarbeitung des gefilmten Materials bis zur Fertigstellung der Filmkopie beaufsichtigen. Der Kameramann bzw. die Kamerafrau wird auch als Director of Photography bezeichnet. Nicht zu verwechseln mit Videofilmer*in.' } },
      { '@id': 'role:cli', 'skos:prefLabel': { 'eng': 'Client', 'deu': 'Auftraggeber*in', 'ita': 'Client' }, 'skos:definition': {  'eng': 'A person or organization for whom another person or organization is acting.',  'deu': 'Eine Person oder Organisation, für die eine andere Person oder Organisation tätig ist.' } },
      { '@id': 'role:coadvisor', 'skos:prefLabel': { 'eng': 'Co-Advisor', 'deu': 'Mitbetreuer*in der Hochschulschrift', 'ita': 'Co-Advisor' }, 'skos:definition': { 'eng': 'A person or organisation who shares advising responsibilities with another advisor or organisation for a university thesis or project.', 'deu': 'Eine Person oder Organisation, die gemeinsam mit einer anderen Person oder Organisation für die Betreuung einer Hochschulschrift oder eines Forschungsprojekts zuständig ist.' } },
      { '@id': 'role:cor', 'skos:prefLabel': { 'eng': 'Collection registrar', 'deu': 'Registrar*in', 'ita': 'Collection registrar' }, 'skos:definition': {  'eng': 'A curator who lists or inventories the items in an aggregate work such as a collection of items or works.',  'deu': 'Ein*e Kurator*in, der die Gegenstände in einem Gesamtwerk wie einer Sammlung von Gegenständen oder Werken auflistet oder inventarisiert.' } },
      { '@id': 'role:col', 'skos:prefLabel': { 'eng': 'Collector', 'deu': 'Sammler*in', 'ita': 'Collezionista' }, 'skos:definition': {  'eng': 'A curator who brings together items from various sources that are then arranged, described, and cataloged as a collection. A collector is neither the creator of the material nor a person to whom manuscripts in the collection may have been addressed.',  'deu': 'Ein*e Kurator*in, der bzw. die Objekte aus verschiedenen Quellen zusammenführt, die dann als Sammlung geordnet, beschrieben und katalogisiert werden. Ein*e Sammler*in ist weder der bzw. die Schöpfer*in des Materials noch eine Person, an die die Manuskripte in der Sammlung möglicherweise adressiert waren.' } },
      { '@id': 'role:clt', 'skos:prefLabel': { 'eng': 'Collotyper', 'deu': 'Lichtdrucker*in', 'ita': 'Collotyper' }, 'skos:definition': {  'eng': 'A person, family, or organization involved in manufacturing a manifestation of photographic prints from film or other colloid that has ink-receptive and ink-repellent surfaces.',  'deu': 'Eine Person, Familie oder Organisation, die sich mit der Herstellung von fotografischen Abzügen aus Filmen oder anderen Kolloiden beschäftigt, die farbannehmende und farbabweisende Oberflächen haben.' } },
      { '@id': 'role:clr', 'skos:prefLabel': { 'eng': 'Colorist', 'deu': 'Kolorist*in', 'ita': 'Colorist' }, 'skos:definition': {  'eng': 'A person or organization responsible for applying color to drawings, prints, photographs, maps, moving images, etc.',  'deu': 'Eine Person oder Organisation, die für das Aufbringen von Farbe auf Zeichnungen, Drucke, Fotos, Karten, bewegte Bilder usw. verantwortlich ist.' } },
      { '@id': 'role:cmm', 'skos:prefLabel': { 'eng': 'Commentator', 'deu': 'Kommentator*in', 'ita': 'Commentator' }, 'skos:definition': {  'eng': 'A performer contributing to a work by providing interpretation, analysis, or a discussion of the subject matter on a recording, film, or other audiovisual medium.',  'deu': 'Ein*e ausübende*r Künstler*in, der bzw. die einen Beitrag zu einem Werk leistet, indem er bzw. sie eine Interpretation, Analyse oder Diskussion des Themas auf einer Aufnahme, einem Film oder einem anderen audiovisuellen Medium liefert.' } },
      { '@id': 'role:cwt', 'skos:prefLabel': { 'eng': 'Commentator for written text', 'deu': 'Kommentator*in eines geschriebenen Textes', 'ita': 'Commentator for written text' }, 'skos:definition': {  'eng': 'A person or organization responsible for the commentary or explanatory notes about a text. For the writer of manuscript annotations in a printed book, use Annotator.',  'deu': 'Eine Person oder Organisation, die für Kommentare oder Erläuterungen zu einem Text verantwortlich ist. Für den bzw. die Verfasser*in von handschriftlichen Anmerkungen in einem gedruckten Buch, verwenden Sie Annotator*in.' } },
      { '@id': 'role:com', 'skos:prefLabel': { 'eng': 'Compiler', 'deu': 'Ersteller*in einer Sammlung', 'ita': 'Compilatore' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a new work (e.g., a bibliography, a directory) through the act of compilation, e.g., selecting, arranging, aggregating, and editing data, information, etc.',  'deu': 'Eine Person, Familie oder Organisation, die für die Erstellung eines neuen Werks (z. B. einer Bibliografie, eines Verzeichnisses) verantwortlich ist, indem sie Daten, Informationen usw. auswählt, ordnet, zusammenstellt und bearbeitet.' } },
      { '@id': 'role:cmp', 'skos:prefLabel': { 'eng': 'Composer', 'deu': 'Komponist*in', 'ita': 'Compositore' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating or contributing to a musical resource by adding music to a work that originally lacked it or supplements it.',  'deu': 'Eine Person, Familie oder Organisation, die dafür verantwortlich ist, eine musikalische Ressource zu schaffen oder zu ihr beizutragen, indem sie Musik zu einem Werk hinzufügt, in dem sie ursprünglich fehlte oder die es ergänzt.' } },
      { '@id': 'role:cmt', 'skos:prefLabel': { 'eng': 'Compositor', 'deu': 'Schriftsetzer*in', 'ita': 'Compositor' }, 'skos:definition': {  'eng': 'A person or organization responsible for the creation of metal slug, or molds made of other materials, used to produce the text and images in printed matter.',  'deu': 'Eine Person oder Organisation, die für die Herstellung von Metallformen oder Formen aus anderen Materialien verantwortlich ist, die für die Produktion von Text und Bildern in Druckerzeugnissen verwendet werden.' } },
      { '@id': 'role:ccp', 'skos:prefLabel': { 'eng': 'Conceptor', 'deu': 'Konzepter*in', 'ita': 'Conceptor' }, 'skos:definition': {  'eng': 'A person or organization responsible for the original idea on which a work is based, this includes the scientific author of an audio-visual item and the conceptor of an advertisement.',  'deu': 'Eine Person oder Organisation, die für die ursprüngliche Idee, auf der ein Werk basiert, verantwortlich ist; dies schließt den bzw. die wissenschaftliche*n Autor*in eines audiovisuellen Werks und den bzw. die Verfasser*in eines Werbekonzepts ein.' } },
      { '@id': 'role:cnd', 'skos:prefLabel': { 'eng': 'Conductor', 'deu': 'Dirigent*in', 'ita': 'Direttore d’orchestra' }, 'skos:definition': {  'eng': 'A performer contributing to a musical resource by leading a performing group (orchestra, chorus, opera, etc.) in a musical or dramatic presentation, etc.',  'deu': 'Ein*e Künstler*in, der bzw. die zu einer musikalischen Ressource beiträgt, indem er bzw. sie eine ausführende Gruppe (Orchester, Chor, Oper usw.) bei einer musikalischen oder dramatischen Darbietung usw. leitet.' } },
      { '@id': 'role:con', 'skos:prefLabel': { 'eng': 'Conservator', 'deu': 'Konservator*in', 'ita': 'Conservator' }, 'skos:definition': {  'eng': 'A person or organization responsible for documenting, preserving, or treating printed or manuscript material, works of art, artifacts, or other media.',  'deu': 'Eine Person oder Organisation, die für die Dokumentation, Bewahrung oder Bearbeitung von gedrucktem oder handschriftlichem Material, Kunstwerken, Artefakten oder anderen Medien verantwortlich ist.' } },
      { '@id': 'role:csl', 'skos:prefLabel': { 'eng': 'Consultant', 'deu': 'Fachberater*in', 'ita': 'Consultant' }, 'skos:definition': {  'eng': 'A person or organization relevant to a resource, who is called upon for professional advice or services in a specialized field of knowledge or training.',  'deu': 'Eine Person oder Organisation, die für eine Ressource relevant ist und die um professionellen Rat oder Dienstleistungen in einem speziellen Wissens- oder Ausbildungsbereich gebeten wird.' } },
      { '@id': 'role:csp', 'skos:prefLabel': { 'eng': 'Consultant to a project', 'deu': 'Projektberater*in', 'ita': 'Consultant to a project' }, 'skos:definition': {  'eng': 'A person or organization relevant to a resource, who is engaged specifically to provide an intellectual overview of a strategic or operational task and by analysis, specification, or instruction, to create or propose a cost-effective course of action or solution.',  'deu': 'Eine Person oder Organisation, die für eine Ressource relevant ist und speziell damit beauftragt wird, einen intellektuellen Überblick über eine strategische oder operative Aufgabe zu geben und durch Analyse, Spezifizierung oder Anweisung eine kosteneffektive Vorgehensweise oder Lösung zu entwickeln oder vorzuschlagen.' } },
      { '@id': 'role:ctr', 'skos:prefLabel': { 'eng': 'Contractor', 'deu': 'Vertragspartner*in', 'ita': 'Contractor' }, 'skos:definition': {  'eng': 'A person or organization relevant to a resource, who enters into a contract with another person or organization to perform a specific task.',  'deu': 'Eine für eine Ressource relevante Person oder Organisation, die mit einer anderen Person oder Organisation einen Vertrag über die Durchführung einer bestimmten Aufgabe abschließt.' } },
      { '@id': 'role:ctb', 'skos:prefLabel': { 'eng': 'Contributor', 'deu': 'Mitwirkende/r', 'ita': 'Contributor' }, 'skos:definition': {  'eng': 'A person, family or organization responsible for making contributions to the resource. This includes those whose work has been contributed to a larger work, such as an anthology, serial publication, or other compilation of individual works. If a more specific role is available, prefer that, e.g. editor, compiler, illustrator.',  'deu': 'Eine Person, Familie oder Organisation, die für die Beiträge zur Ressource verantwortlich ist. Dies schließt diejenigen ein, deren Arbeit zu einem größeren Werk beigetragen wurde, wie z. B. einem Sammelband, einer fortlaufenden Publikation oder einer anderen Zusammenstellung von Einzelwerken. Wenn eine spezifischere Rolle verfügbar ist, geben Sie diese an, z. B. Herausgeber*in, Kompilator*in, Illustrator*in.' } },
      { '@id': 'role:copista', 'skos:prefLabel': { 'eng': 'Copista', 'deu': 'Copista', 'ita': 'Copista' } },
      { '@id': 'role:cpc', 'skos:prefLabel': { 'eng': 'Copyright claimant', 'deu': 'Anspruchsteller*in auf das Copyright', 'ita': 'Copyright claimant' }, 'skos:definition': {  'eng': 'A person or organization listed as a copyright owner at the time of registration. Copyright can be granted or later transferred to another person or organization, at which time the claimant becomes the copyright holder.',  'deu': 'Eine Person oder Organisation, die zum Zeitpunkt der Registrierung als Urheberrechtsinhaber*in aufgeführt ist. Das Urheberrecht kann gewährt oder später an eine andere Person oder Organisation übertragen werden, wobei der bzw. die Antragsteller*in zu dem bzw. Inhaber*in des Urheberrechts wird.' } },
      { '@id': 'role:cph', 'skos:prefLabel': { 'eng': 'Copyright holder', 'deu': 'Inhaber*in des Copyright', 'ita': 'Copyright holder' }, 'skos:definition': {  'eng': 'A person or organization to whom copy and legal rights have been granted or transferred for the intellectual content of a work. The copyright holder, although not necessarily the creator of the work, usually has the exclusive right to benefit financially from the sale and use of the work to which the associated copyright protection applies.',  'deu': 'Eine Person oder Organisation, der die Urheber- und Nutzungsrechte für den geistigen Inhalt eines Werks gewährt oder übertragen wurden. Der bzw. Urheberrechtsinhaber*in ist zwar nicht unbedingt der bzw. die Schöpfer*in des Werks, hat aber in der Regel das ausschließliche Recht, aus dem Verkauf und der Nutzung des Werks, für das der entsprechende Urheberrechtsschutz gilt, finanziell zu profitieren.' } },
      { '@id': 'role:crr', 'skos:prefLabel': { 'eng': 'Corrector', 'deu': 'Korrektor*in', 'ita': 'Corrector' }, 'skos:definition': {  'eng': 'A person or organization who is a corrector of manuscripts, such as the scriptorium official who corrected the work of a scribe. For printed matter, use Proofreader.',  'deu': 'Eine Person oder Organisation, die Manuskripte korrigiert, z. B. ein Skriptoriumsbeamter bzw. eine Skriptoriumsbeamtin, der bzw. die die Arbeit eines Schreibers bzw. einer Schreiberin korrigiert. Für Drucksachen verwenden Sie Korrekturleser*in.' } },
      { '@id': 'role:crp', 'skos:prefLabel': { 'eng': 'Correspondent', 'deu': 'Teilnehmer*in einer Korrespondenz', 'ita': 'Correspondent' }, 'skos:definition': {  'eng': 'A person or organization who was either the writer or recipient of a letter or other communication.',  'deu': 'Eine Person oder Organisation, die entweder der bzw. Verfasser*in oder der bzw. die Empfänger*in eines Briefes oder einer anderen Mitteilung war.' } },
      { '@id': 'role:cst', 'skos:prefLabel': { 'eng': 'Costume designer', 'deu': 'Kostümbildner*in', 'ita': 'Costume designer' }, 'skos:definition': {  'eng': 'A person, family, or organization that designs the costumes for a moving image production or for a musical or dramatic presentation or entertainment.',  'deu': 'Eine Person, Familie oder Organisation, die die Kostüme für eine Bewegtbildproduktion oder für eine musikalische oder dramatische Präsentation oder Unterhaltung entwirft.' } },
      { '@id': 'role:cov', 'skos:prefLabel': { 'eng': 'Cover designer', 'deu': 'Designer*in der Hüller / Verpackung', 'ita': 'Cover designer' }, 'skos:definition': {  'eng': 'A person or organization responsible for the graphic design of a book cover, album cover, slipcase, box, container, etc. For a person or organization responsible for the graphic design of an entire book, use Book designer; for book jackets, use Bookjacket designer.',  'deu': 'Eine Person oder Organisation, die für die grafische Gestaltung eines Bucheinbands, eines Albumcovers, eines Schubers, einer Schachtel, einer Verpackung usw. verantwortlich ist. Für eine Person oder Organisation, die für die grafische Gestaltung eines ganzen Buches verantwortlich ist, verwenden Sie Buchgestalter*in; für Buchumschläge verwenden Sie Designer*in des Buchumschlages / Schutzumschlages.' } },
      { '@id': 'role:cur', 'skos:prefLabel': { 'eng': 'Curator', 'deu': 'Kurator*in', 'ita': 'Curator' }, 'skos:definition': {  'eng': 'A person, family, or organization conceiving, aggregating, and/or organizing an exhibition, collection, or other item.',  'deu': 'Eine Person, Familie oder Organisation, die eine Ausstellung, Sammlung oder ein anderes Objekt konzipiert, zusammenstellt und/oder organisiert.' } },
      { '@id': 'role:dnc', 'skos:prefLabel': { 'eng': 'Dancer', 'deu': 'Tänzer*in', 'ita': 'Dancer' }, 'skos:definition': {  'eng': 'A performer who dances in a musical, dramatic, etc., presentation.',  'deu': 'Ein*e Darsteller*in, der bzw. die in einer musikalischen, dramatischen usw. Präsentation tanzt.' } },
      { '@id': 'role:dtc', 'skos:prefLabel': { 'eng': 'Data contributor', 'deu': 'Datenlieferant*in', 'ita': 'Data contributor' }, 'skos:definition': {  'eng': 'A person or organization that submits data for inclusion in a database or other collection of data.',  'deu': 'Eine Person oder Organisation, die Daten zur Aufnahme in eine Datenbank oder eine andere Datensammlung einreicht.' } },
      { '@id': 'role:dtm', 'skos:prefLabel': { 'eng': 'Data manager', 'deu': 'Datenmanager*in', 'ita': 'Gestore di dati' }, 'skos:definition': {  'eng': 'A person or organization responsible for managing databases or other data sources.',  'deu': 'Eine Person oder Organisation, die für die Verwaltung von Datenbanken oder anderen Datenquellen zuständig ist.' } },
      { '@id': 'role:dte', 'skos:prefLabel': { 'eng': 'Dedicatee', 'deu': 'Widmungsträger*in', 'ita': 'Dedicatario' }, 'skos:definition': {  'eng': 'A person, family, or organization to whom a resource is dedicated.',  'deu': 'Eine Person, Familie oder Organisation, der eine Ressource gewidmet ist.' } },
      { '@id': 'role:dto', 'skos:prefLabel': { 'eng': 'Dedicator', 'deu': 'Widmende/r', 'ita': 'Dedicante' }, 'skos:definition': {  'eng': 'A person who writes a dedication, which may be a formal statement or in epistolary or verse form.',  'deu': 'Eine Person, die eine Widmung schreibt, die eine förmliche Erklärung oder in Briefform oder in Versen abgefasst sein kann.' } },
      { '@id': 'role:dgg', 'skos:prefLabel': { 'eng': 'Degree granting institution', 'deu': 'Verleihende Institution des akademischen Abschlusses', 'ita': 'Istituzione che rilascia il titolo accademico' }, 'skos:definition': {  'eng': 'A organization granting an academic degree.',  'deu': 'Eine Organisation, die einen akademischen Grad verleiht.' } },
      { '@id': 'role:dgs', 'skos:prefLabel': { 'eng': 'Degree supervisor', 'deu': 'Betreuer*in der Hochschulschrift', 'ita': 'Degree supervisor' }, 'skos:definition': {  'eng': 'A person overseeing a higher level academic degree.',  'deu': 'Eine Person, die für einen höheren akademischen Grad verantwortlich ist.' } },
      { '@id': 'role:dln', 'skos:prefLabel': { 'eng': 'Delineator', 'deu': 'Entwurfszeichner*in', 'ita': 'Delineator' }, 'skos:definition': {  'eng': 'A person or organization executing technical drawings from others\' designs.',  'deu': 'Eine Person oder Organisation, die technische Zeichnungen nach Entwürfen anderer ausführt.' } },
      { '@id': 'role:dpc', 'skos:prefLabel': { 'eng': 'Depicted', 'deu': 'Dargestellt / beschrieben', 'ita': 'Depicted' }, 'skos:definition': {  'eng': 'An entity depicted or portrayed in a work, particularly in a work of art.',  'deu': 'Ein Wesen, das in einem Werk, insbesondere in einem Kunstwerk, dargestellt wird.' } },
      { '@id': 'role:dpt', 'skos:prefLabel': { 'eng': 'Depositor', 'deu': 'Depositor*in', 'ita': 'Depositor' }, 'skos:definition': {  'eng': 'A current owner of an item who deposited the item into the custody of another person, family, or organization, while still retaining ownership.',  'deu': 'Ein*e derzeitige*r Eigentümer*in eines Gegenstands, der bzw. die den Gegenstand in die Obhut einer anderen Person, Familie oder Organisation gegeben hat, wobei er bzw. sie weiterhin Eigentümer*in bleibt.' } },
      { '@id': 'role:dsr', 'skos:prefLabel': { 'eng': 'Designer', 'deu': 'Designer*in', 'ita': 'Designer' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a design for an object.',  'deu': 'Eine Person, Familie oder Organisation, die für den Entwurf eines Objekts verantwortlich ist.' } },
      { '@id': 'role:digitiser', 'skos:prefLabel': { 'eng': 'Digitiser', 'deu': 'Digitalisierer*in', 'ita': 'Autore della digitalizzazione' }, 'skos:definition': { 'eng': 'A person or organisation responsible for converting physical materials into digital format.', 'deu': 'Eine Person oder Organisation, die für die Umwandlung von physischem Material in ein digitales Format verantwortlich ist.' } },
      { '@id': 'role:drt', 'skos:prefLabel': { 'eng': 'Director', 'deu': 'Produktionsleiter*in', 'ita': 'Director' }, 'skos:definition': {  'eng': 'A person responsible for the general management and supervision of a filmed performance, a radio or television program, etc.',  'deu': 'Eine Person, die für die allgemeine Leitung und Überwachung einer gefilmten Aufführung, einer Radio- oder Fernsehsendung usw. verantwortlich ist.' } },
      { '@id': 'role:dis', 'skos:prefLabel': { 'eng': 'Dissertant', 'deu': 'Verfasser*in der Hochschulschrift', 'ita': 'Tesista' }, 'skos:definition': {  'eng': 'A person who presents a thesis for a university or higher-level educational degree.',  'deu': 'Eine Person, die eine Abschlussarbeit für eine Universität oder einen höheren Bildungsabschluss vorlegt.' } },
      { '@id': 'role:dbp', 'skos:prefLabel': { 'eng': 'Distribution place', 'deu': 'Vertriebsort', 'ita': 'Distribution place' }, 'skos:definition': {  'eng': 'A place from which a resource, e.g., a serial, is distributed.',  'deu': 'Ein Ort, von dem aus eine Ressource, z. B. eine Serie, verteilt wird.' } },
      { '@id': 'role:dst', 'skos:prefLabel': { 'eng': 'Distributor', 'deu': 'Distributor*in', 'ita': 'Distributore' }, 'skos:definition': {  'eng': 'A person, family or organisation that distributes a resource.',  'deu': 'Eine Person, Familie oder Organisation, die eine Ressource verteilt.' } },
      { '@id': 'role:domainexpert', 'skos:prefLabel': { 'eng': 'Domain Expert', 'deu': 'Fachexpert*in', 'ita': 'Esperto del settore' }, 'skos:definition': { 'eng': 'A person or organisation who contributes specialised knowledge and expertise in a specific subject area to scientific work.', 'deu': 'Eine Person oder Organisation, die spezialisiertes Wissen und Fachkenntnisse in einem bestimmten Themengebiet in die wissenschaftliche Arbeit einbringt.' } },
      { '@id': 'role:dnr', 'skos:prefLabel': { 'eng': 'Donor', 'deu': 'Stifter*in', 'ita': 'Donatore' }, 'skos:definition': {  'eng': 'A former owner of an item who donated that item to another owner.',  'deu': 'Ein*e ehemalige*r Besitzer*in eines Gegenstandes, der bzw. die diesen Gegenstand einem anderen Besitzer bzw. einer anderen Besitzerin geschenkt hat.' } },
      { '@id': 'role:drm', 'skos:prefLabel': { 'eng': 'Draftsman', 'deu': 'Technische/r Zeichner*in', 'ita': 'Draftsman' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by an architect, inventor, etc., by making detailed plans or drawings for buildings, ships, aircraft, machines, objects, etc.',  'deu': 'Eine Person, Familie oder Organisation, die zu einer Ressource eines Architekten, Erfinders usw. beiträgt, indem sie detaillierte Pläne oder Zeichnungen für Gebäude, Schiffe, Flugzeuge, Maschinen, Gegenstände usw. anfertigt.' } },
      { '@id': 'role:dub', 'skos:prefLabel': { 'eng': 'Dubious author', 'deu': 'Zweifelhafte Autor*in', 'ita': 'Autore incerto' }, 'skos:definition': {  'eng': 'A person or organization to which authorship has been dubiously or incorrectly ascribed.',  'deu': 'Eine Person oder Organisation, der die Urheberschaft zweifelhaft oder fälschlicherweise zugeschrieben wurde.' } },
      { '@id': 'role:edt', 'skos:prefLabel': { 'eng': 'Editor', 'deu': 'Herausgeber*in', 'ita': 'Curatore' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by revising or elucidating the content, e.g., adding an introduction, notes, or other critical matter. An editor may also prepare a resource for production, publication, or distribution. For major revisions, adaptations, etc., that substantially change the nature and content of the original work, resulting in a new work, see author.',  'deu': 'Eine Person, Familie oder Organisation, die zu einer Ressource beiträgt, indem sie den Inhalt überarbeitet oder erläutert, z. B. durch Hinzufügen einer Einleitung, von Anmerkungen oder anderen kritischen Informationen. Ein*e Herausgeber*in kann auch eine Ressource für die Produktion, Veröffentlichung oder Verteilung vorbereiten. Für größere Überarbeitungen, Anpassungen usw., die die Art und den Inhalt des ursprünglichen Werks wesentlich verändern und zu einem neuen Werk führen, siehe Autor*in.' } },
      { '@id': 'role:edc', 'skos:prefLabel': { 'eng': 'Editor of compilation', 'deu': 'Herausgeber*in eines Sammelwerks', 'ita': 'Editor of compilation' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a collective or aggregate work by selecting and putting together works, or parts of works, by one or more creators. For compilations of data, information, etc., that result in new works, see compiler.',  'deu': 'Eine Person, Familie oder Organisation, die zu einem kollektiven oder aggregierten Werk beiträgt, indem sie Werke oder Teile von Werken von einem oder mehreren Urhebern bzw. von einer oder mehreren Urheberinnen auswählt und zusammenstellt. Für Zusammenstellungen von Daten, Informationen usw., die zu neuen Werken führen, siehe Ersteller*in einer Sammlung.' } },
      { '@id': 'role:edm', 'skos:prefLabel': { 'eng': 'Editor of moving image work', 'deu': 'Filmeditor*in', 'ita': 'Editor of moving image work' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for assembling, arranging, and trimming film, video, or other moving image formats, including both visual and audio aspects.',  'deu': 'Eine Person, Familie oder Organisation, die für das Zusammenstellen, Arrangieren und Schneiden von Film-, Video- oder anderen Bewegtbildformaten verantwortlich ist, einschließlich visueller und akustischer Aspekte.' } },
      { '@id': 'role:elg', 'skos:prefLabel': { 'eng': 'Electrician', 'deu': 'Lichtechniker*in', 'ita': 'Electrician' }, 'skos:definition': {  'eng': 'A person responsible for setting up a lighting rig and focusing the lights for a production, and running the lighting at a performance.',  'deu': 'A person responsible for setting up a lighting rig and focusing the lights for a production, and running the lighting at a performance.' } },
      { '@id': 'role:elt', 'skos:prefLabel': { 'eng': 'Electrotyper', 'deu': 'Galvanoplastiker*in', 'ita': 'Electrotyper' }, 'skos:definition': {  'eng': 'A person or organization who creates a duplicate printing surface by pressure molding and electrodepositing of metal that is then backed up with lead for printing.',  'deu': 'Eine Person oder Organisation, die durch Druckformung und galvanische Abscheidung von Metall eine doppelte Druckoberfläche herstellt, die dann für den Druck mit Blei hinterlegt wird.' } },
      { '@id': 'role:enj', 'skos:prefLabel': { 'eng': 'Enacting jurisdiction', 'deu': 'Verfügende / verordnende Jurisdiktion', 'ita': 'Enacting jurisdiction' }, 'skos:definition': {  'eng': 'A jurisdiction enacting a law, regulation, constitution, court rule, etc.',  'deu': 'Eine Gerichtsbarkeit, die ein Gesetz, eine Verordnung, eine Verfassung, eine Gerichtsregel usw. erlässt.' } },
      { '@id': 'role:eng', 'skos:prefLabel': { 'eng': 'Engineer', 'deu': 'Ingenieur*in', 'ita': 'Ingegnere' }, 'skos:definition': {  'eng': 'A person or organization that is responsible for technical planning and design, particularly with construction.',  'deu': 'Eine Person oder Organisation, die für die technische Planung und Gestaltung, insbesondere beim Bau, verantwortlich ist.' } },
      { '@id': 'role:egr', 'skos:prefLabel': { 'eng': 'Engraver', 'deu': 'Graveur*in', 'ita': 'Incisore' }, 'skos:definition': {  'eng': 'A person or organization who cuts letters, figures, etc. on a surface, such as a wooden or metal plate used for printing.',  'deu': 'Eine Person oder Organisation, die Buchstaben, Zahlen usw. in eine Oberfläche schneidet, z. B. in eine Holz- oder Metallplatte, die zum Drucken verwendet wird.' } },
      { '@id': 'role:etr', 'skos:prefLabel': { 'eng': 'Etcher', 'deu': 'Radierer*in', 'ita': 'Acquafortista' }, 'skos:definition': {  'eng': 'A person or organization who produces text or images for printing by subjecting metal, glass, or some other surface to acid or the corrosive action of some other substance.',  'deu': 'Eine Person oder Organisation, die Text oder Bilder für den Druck herstellt, indem sie Metall, Glas oder eine andere Oberfläche einer Säure oder der korrosiven Wirkung einer anderen Substanz aussetzt.' } },
      { '@id': 'role:evaluator', 'skos:prefLabel': { 'eng': 'Evaluator', 'deu': 'Evaluator*in', 'ita': 'Valutatore' }, 'skos:definition': { 'eng': 'A person or organisation responsible for assessing and appraising the quality, relevance, and significance of materials or content within a given context.', 'deu': 'Eine Person oder Organisation, die für die Bewertung und Beurteilung der Qualität, Relevanz und Bedeutung von Materialien oder Inhalten innerhalb eines bestimmten Kontexts verantwortlich ist.' } },
      { '@id': 'role:exp', 'skos:prefLabel': { 'eng': 'Expert', 'deu': 'Expert*in / Sachverständige/r', 'ita': 'Expert' }, 'skos:definition': {  'eng': 'A person or organization in charge of the description and appraisal of the value of goods, particularly rare items, works of art, etc.',  'deu': 'Eine Person oder Organisation, die mit der Beschreibung und Schätzung des Wertes von Waren, insbesondere von seltenen Gegenständen, Kunstwerken usw. beauftragt ist.' } },
      { '@id': 'role:fac', 'skos:prefLabel': { 'eng': 'Facsimilist', 'deu': 'Ersteller*in des Faksimile', 'ita': 'Responsabile del facsimile' }, 'skos:definition': {  'eng': 'A person or organization that executed the facsimile.',  'deu': 'Eine Person oder Organisation, die das Faksimile erstellt hat.' } },
      { '@id': 'role:fld', 'skos:prefLabel': { 'eng': 'Field director', 'deu': 'Leiter*in der Feldforschung', 'ita': 'Field director' }, 'skos:definition': {  'eng': 'A person or organization that manages or supervises the work done to collect raw data or do research in an actual setting or environment (typically applies to the natural and social sciences).',  'deu': 'Eine Person oder Organisation, die die Arbeit zur Sammlung von Rohdaten oder zur Durchführung von Forschungsarbeiten in einem konkreten Umfeld leitet oder beaufsichtigt (gilt in der Regel für die Natur- und Sozialwissenschaften).' } },
      { '@id': 'role:fmd', 'skos:prefLabel': { 'eng': 'Film director', 'deu': 'Filmregisseur*in', 'ita': 'Film director' }, 'skos:definition': {  'eng': 'A director responsible for the general management and supervision of a filmed performance.',  'deu': 'Ein*e Regisseur*in, der bzw. die für die allgemeine Verwaltung und Überwachung einer Filmvorführung verantwortlich ist.' } },
      { '@id': 'role:fds', 'skos:prefLabel': { 'eng': 'Film distributor', 'deu': 'Filmverleiher*in', 'ita': 'Film distributor' }, 'skos:definition': {  'eng': 'A person, family, or organization involved in distributing a moving image resource to theatres or other distribution channels.',  'deu': 'Eine Person, Familie oder Organisation, die an der Verteilung eines Bewegtbildmaterials an Kinos oder andere Vertriebskanäle beteiligt ist.' } },
      { '@id': 'role:flm', 'skos:prefLabel': { 'eng': 'Film editor', 'deu': 'Filmeditor*in', 'ita': 'Responsabile del montaggio' }, 'skos:definition': {  'eng': 'A person who, following the script and in creative cooperation with the Director, selects, arranges, and assembles the filmed material, controls the synchronization of picture and sound, and participates in other post-production tasks such as sound mixing and visual effects processing. Today, picture editing is often performed digitally.',  'deu': 'Eine Person, die nach dem Drehbuch und in kreativer Zusammenarbeit mit dem Regisseur das gefilmte Material auswählt, arrangiert und zusammenfügt, die Synchronisation von Bild und Ton kontrolliert und an anderen Postproduktionsaufgaben wie der Tonmischung und der Bearbeitung visueller Effekte beteiligt ist. Heutzutage wird die Bildbearbeitung häufig digital durchgeführt.' } },
      { '@id': 'role:fmp', 'skos:prefLabel': { 'eng': 'Film producer', 'deu': 'Filmproduzent*in', 'ita': 'Film producer' }, 'skos:definition': {  'eng': 'A producer responsible for most of the business aspects of a film.',  'deu': 'Ein*e Produzent*in, der bzw. die für die meisten geschäftlichen Aspekte eines Films verantwortlich ist.' } },
      { '@id': 'role:fmk', 'skos:prefLabel': { 'eng': 'Filmmaker', 'deu': 'Filmemacher*in', 'ita': 'Filmmaker' }, 'skos:definition': {  'eng': 'A person, family or organization responsible for creating an independent or personal film. A filmmaker is individually responsible for the conception and execution of all aspects of the film.',  'deu': 'Eine Person, Familie oder Organisation, die für die Herstellung eines unabhängigen oder persönlichen Films verantwortlich ist. Ein*e Filmemacher*in ist individuell für die Konzeption und Ausführung aller Aspekte des Films verantwortlich.' } },
      { '@id': 'role:fpy', 'skos:prefLabel': { 'eng': 'First party', 'deu': 'Erste Vertragspartei', 'ita': 'First party' }, 'skos:definition': {  'eng': 'A person or organization who is identified as the only party or the party of the first party. In the case of transfer of rights, this is the assignor, transferor, licensor, grantor, etc. Multiple parties can be named jointly as the first party.',  'deu': 'Eine Person oder Organisation, die als einzige Vertragspartei oder als die Partei der ersten Vertragspartei identifiziert wird. Bei der Übertragung von Rechten ist dies der bzw. die Zedent*in, der bzw. die Übertragende, der bzw. die Lizenzgeber*in, der bzw. die Gewährende usw. Mehrere Parteien können gemeinsam als erste Vertragspartei benannt werden.' } },
      { '@id': 'role:frg', 'skos:prefLabel': { 'eng': 'Forger', 'deu': 'Fälscher*in', 'ita': 'Forger' }, 'skos:definition': {  'eng': 'A person or organization who makes or imitates something of value or importance, especially with the intent to defraud.',  'deu': 'Eine Person oder Organisation, die etwas von Wert oder Bedeutung herstellt oder nachahmt, insbesondere in der Absicht, zu betrügen.' } },
      { '@id': 'role:fmo', 'skos:prefLabel': { 'eng': 'Former owner', 'deu': 'Ehemalige/r Eigentümer*in', 'ita': 'Precedente proprietario' }, 'skos:definition': {  'eng': 'A person, family, or organization formerly having legal possession of an item.',  'deu': 'Eine Person, Familie oder Organisation, die früher rechtmäßig im Besitz eines Gegenstandes war.' } },
      { '@id': 'role:fon', 'skos:prefLabel': { 'eng': 'Founder', 'deu': 'Gründer*in', 'ita': 'Founder' }, 'skos:definition': { 'eng': 'A person or organisation who played a significant role in initiating, establishing, or creating a particular entity, project, or endeavor.', 'deu': 'Eine Person oder Organisation, die eine bedeutende Rolle bei der Initiierung, Gründung oder Schaffung einer bestimmten Entität, eines Projekts oder einer Unternehmung gespielt hat.' } },
      { '@id': 'role:fnd', 'skos:prefLabel': { 'eng': 'Funder', 'deu': 'Geldgeber*in', 'ita': 'Funder' }, 'skos:definition': {  'eng': 'A person or organization that furnished financial support for the production of the work.',  'deu': 'Eine Person oder Organisation, die die Produktion des Werks finanziell unterstützt hat.' } },
      { '@id': 'role:gis', 'skos:prefLabel': { 'eng': 'Geographic information specialist', 'deu': 'Spezialist*in für geografische Informationen', 'ita': 'Field director' }, 'skos:definition': {  'eng': 'A person responsible for geographic information system (GIS) development and integration with global positioning system data.',  'deu': 'Eine Person, die für die Entwicklung von geografischen Informationssystemen (GIS) und die Integration mit Daten des globalen Positionierungssystems verantwortlich ist.' } },
      { '@id': 'role:graphicdesigner', 'skos:prefLabel': { 'eng': 'Graphic Designer', 'deu': 'Grafikdesigner*in', 'ita': 'Grafico' }, 'skos:definition': { 'eng': 'A person or organisation responsible for creating visual concepts, graphics, and layouts.', 'deu': 'Eine Person oder Organisation, die für das Erstellen visueller Konzepte, Grafiken und Layouts zuständig ist.' } },
      { '@id': 'role:hnr', 'skos:prefLabel': { 'eng': 'Honoree', 'deu': 'Geehrte/r, Jubilar*in', 'ita': 'Onorato' }, 'skos:definition': {  'eng': 'A person, family, or organization honored by a work or item (e.g., the honoree of a festschrift, a person to whom a copy is presented).',  'deu': 'Eine Person, Familie oder Organisation, die durch ein Werk oder einen Gegenstand geehrt wird (z. B. der bzw. die Preisträger*in einer Festschrift, eine Person, der ein Exemplar überreicht wird).' } },
      { '@id': 'role:hst', 'skos:prefLabel': { 'eng': 'Host', 'deu': 'Gastgeber*in', 'ita': 'Host' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by leading a program (often broadcast) that includes other guests, performers, etc. (e.g., talk show host).',  'deu': 'Ein*e Künstler*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie ein (oft ausgestrahltes) Programm leitet, zu dem auch andere Gäste, Künstler*innen usw. gehören (z. B. ein*e Talkshow-Moderator*in).' } },
      { '@id': 'role:his', 'skos:prefLabel': { 'eng': 'Host institution', 'deu': 'Gastgebende Institution', 'ita': 'Host institution' }, 'skos:definition': {  'eng': 'An organization hosting the event, exhibit, conference, etc., which gave rise to a resource, but having little or no responsibility for the content of the resource.',  'deu': 'Eine Organisation, die das Ereignis, die Ausstellung, die Konferenz usw. veranstaltet, aus der eine Ressource hervorgegangen ist, die aber keine oder nur eine geringe Verantwortung für den Inhalt der Ressource trägt.' } },
      { '@id': 'role:ilu', 'skos:prefLabel': { 'eng': 'Illuminator', 'deu': 'Buchmaler*in', 'ita': 'Miniatore' }, 'skos:definition': {  'eng': 'A person providing decoration to a specific item using precious metals or color, often with elaborate designs and motifs.',  'deu': 'Eine Person, die einen bestimmten Gegenstand mit Edelmetallen oder Farbe verziert, oft mit aufwendigen Mustern und Motiven.' } },
      { '@id': 'role:ill', 'skos:prefLabel': { 'eng': 'Illustrator', 'deu': 'Illustrator*in', 'ita': 'Illustratore' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by supplementing the primary content with drawings, diagrams, photographs, etc. If the work is primarily the artistic content created by this entity, use artist or photographer.',  'deu': 'Eine Person, Familie oder Organisation, die einen Beitrag zu einer Ressource leistet, indem sie den primären Inhalt durch Zeichnungen, Diagramme, Fotos usw. ergänzt. Handelt es sich bei dem Werk in erster Linie um den künstlerischen Inhalt, der von dieser Person geschaffen wurde, verwenden Sie Künstler*in oder Fotograf*in.' } },
      { '@id': 'role:initiator', 'skos:prefLabel': { 'eng': 'Initiator', 'deu': 'Initiator*in', 'ita': 'Iniziatore' }, 'skos:definition': { 'eng': 'A person or organisation who takes the first steps or leads the effort in starting or launching a particular project, initiative, or action.', 'deu': 'Eine Person oder Organisation, die die ersten Schritte unternimmt oder die Anstrengungen leitet, um ein bestimmtes Projekt, eine Initiative oder eine Handlung zu starten oder zu lancieren.' } },
      { '@id': 'role:ins', 'skos:prefLabel': { 'eng': 'Inscriber', 'deu': 'Widmende/r', 'ita': 'Inscriber' }, 'skos:definition': {  'eng': 'A person who has written a statement of dedication or gift.',  'deu': 'Eine Person, die eine Widmungs- oder Schenkungserklärung verfasst hat.' } },
      { '@id': 'role:itr', 'skos:prefLabel': { 'eng': 'Instrumentalist', 'deu': 'Instrumentalist*in', 'ita': 'Instrumentalist' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by playing a musical instrument.',  'deu': 'Ein*e Künstler*in, der bzw. die durch das Spielen eines Musikinstruments zu einer Ressource beiträgt.' } },
      { '@id': 'role:interpreter', 'skos:prefLabel': { 'eng': 'Interpreter', 'deu': 'Dolmetscher*in', 'ita': 'Interprete' }, 'skos:definition': { 'eng': 'A person who translates spoken or signed language from one language to another (in real-time settings or for recorded or delayed communication).', 'deu': 'Eine Person, die gesprochene oder gebärdete Sprache von einer Sprache in eine andere übersetzt (in Echtzeit oder für aufgezeichnete oder verzögerte Kommunikation).' } },
      { '@id': 'role:ive', 'skos:prefLabel': { 'eng': 'Interviewee', 'deu': 'Interviewpartner*in', 'ita': 'Intervistato' }, 'skos:definition': {  'eng': 'A person, family or organization responsible for creating or contributing to a resource by responding to an interviewer, usually a reporter, pollster, or some other information gathering agent.',  'deu': 'Eine Person, Familie oder Organisation, die dafür verantwortlich ist, eine Ressource zu erstellen oder zu ihr beizutragen, indem sie einem Interviewer bzw. einer Interviewerin, in der Regel einem Reporter bzw. einer Reporterin, einem Meinungsforscher bzw. einer Meinungsforscherin oder einem anderen Informationsbeschaffer bzw. einer anderen Informationsbeschafferin, antwortet.' } },
      { '@id': 'role:ivr', 'skos:prefLabel': { 'eng': 'Interviewer', 'deu': 'Interviewer*in', 'ita': 'Intervistatore' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating or contributing to a resource by acting as an interviewer, reporter, pollster, or some other information gathering agent.',  'deu': 'Eine Person, Familie oder Organisation, die für die Erstellung oder den Beitrag zu einer Ressource verantwortlich ist, indem sie als Interviewer*in, Reporter*in, Meinungsforscher*in oder sonstige*r Informationsbeschaffer*in fungiert.' } },
      { '@id': 'role:inv', 'skos:prefLabel': { 'eng': 'Inventor', 'deu': 'Erfinder*in', 'ita': 'Inventor' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a new device or process.',  'deu': 'Eine Person, Familie oder Organisation, die für die Entwicklung eines neuen Geräts oder Verfahrens verantwortlich ist.' } },
      { '@id': 'role:isb', 'skos:prefLabel': { 'eng': 'Issuing body', 'deu': 'Herausgebende Körperschaft', 'ita': 'Issuing body' }, 'skos:definition': {  'eng': 'A person, family or organization issuing a work, such as an official organ of the body.',  'deu': 'Eine Person, Familie oder Organisation, die ein Werk herausgibt, z. B. ein offizielles Organ der Körperschaft.' } },
      { '@id': 'role:keeperoftheoriginal', 'skos:prefLabel': { 'eng': 'Keeper of the original', 'deu': 'Aufbewahrer*in des Originals', 'ita': 'Affidatario dell\'originale' }, 'skos:definition': { 'eng': 'A person or organisation who is entrusted with the custody of the original physical material from which a digital copy has been made.', 'deu': 'Eine Person oder Organisation, die mit der Aufbewahrung des physischen Originalmaterials betraut ist, von dem eine digitale Kopien erstellt wurde.' } },
      { '@id': 'role:lbr', 'skos:prefLabel': { 'eng': 'Laboratory', 'deu': 'Labor', 'ita': 'Laboratory' }, 'skos:definition': {  'eng': 'An organization that provides scientific analyses of material samples.',  'deu': 'Eine Organisation, die wissenschaftliche Analysen von Materialproben durchführt.' } },
      { '@id': 'role:ldr', 'skos:prefLabel': { 'eng': 'Laboratory director', 'deu': 'Laborleiter*in', 'ita': 'Laboratory director' }, 'skos:definition': {  'eng': 'A person or organization that manages or supervises work done in a controlled setting or environment.',  'deu': 'Eine Person oder Organisation, die die Arbeit in einem kontrollierten Umfeld leitet oder beaufsichtigt.' } },
      { '@id': 'role:lsa', 'skos:prefLabel': { 'eng': 'Landscape architect', 'deu': 'Landschaftsarchitekt*in', 'ita': 'Landscape architect' }, 'skos:definition': {  'eng': 'An architect responsible for creating landscape works. This work involves coordinating the arrangement of existing and proposed land features and structures.',  'deu': 'Ein*e Architekt*in, der bzw. die für die Gestaltung von Landschaftswerken verantwortlich ist. Diese Arbeit umfasst die Koordinierung der Anordnung von bestehenden und geplanten Landschaftselementen und Strukturen.' } },
      { '@id': 'role:led', 'skos:prefLabel': { 'eng': 'Lead', 'deu': 'Leitung', 'ita': 'Lead' }, 'skos:definition': {  'eng': 'A person or organization that takes primary responsibility for a particular activity or endeavor. May be combined with another relator term or code to show the greater importance this person or organization has regarding that particular role. If more than one relator is assigned to a heading, use the Lead relator only if it applies to all the relators.',  'deu': 'Eine Person oder Organisation, die die Hauptverantwortung für eine bestimmte Aktivität oder ein bestimmtes Unterfangen trägt. Kann mit einem anderen Beauftragtenbegriff oder -code kombiniert werden, um die größere Bedeutung dieser Person oder Organisation in Bezug auf diese spezielle Rolle zu verdeutlichen. Wenn einer Rubrik mehr als ein Verantwortlicher bzw. eine Verantwortliche zugeordnet ist, verwenden Sie den Begriff "Hauptverantwortliche*r" nur, wenn er auf alle Verantwortlichen zutrifft.' } },
      { '@id': 'role:len', 'skos:prefLabel': { 'eng': 'Lender', 'deu': 'Leihgeber', 'ita': 'Lender' }, 'skos:definition': {  'eng': 'A person or organization permitting the temporary use of a book, manuscript, etc., such as for photocopying or microfilming.',  'deu': 'Eine Person oder Organisation, die die vorübergehende Nutzung eines Buches, Manuskripts usw. gestattet, z. B. zum Fotokopieren oder Mikroverfilmen.' } },
      { '@id': 'role:lbt', 'skos:prefLabel': { 'eng': 'Librettist', 'deu': 'Librettist*in', 'ita': 'Librettista' }, 'skos:definition': {  'eng': 'An author of a libretto of an opera or other stage work, or an oratorio.',  'deu': 'Ein*e Autor*in eines Librettos einer Oper oder eines anderen Bühnenwerks oder eines Oratoriums.' } },
      { '@id': 'role:lse', 'skos:prefLabel': { 'eng': 'Licensee', 'deu': 'Lizenznehmer*in', 'ita': 'Licensee' }, 'skos:definition': {  'eng': 'A person or organization who is an original recipient of the right to print or publish.',  'deu': 'Eine Person oder Organisation, die das ursprüngliche Druck- oder Veröffentlichungsrecht erhalten hat.' } },
      { '@id': 'role:lso', 'skos:prefLabel': { 'eng': 'Licensor', 'deu': 'Lizenzgeber*in', 'ita': 'Licensor' }, 'skos:definition': {  'eng': 'A person or organization who is a signer of the license, imprimatur, etc.',  'deu': 'Eine Person oder Organisation, die eine Lizenz, ein Imprimatur usw. unterzeichnet.' } },
      { '@id': 'role:lgd', 'skos:prefLabel': { 'eng': 'Lighting designer', 'deu': 'Lichtgestalter*in', 'ita': 'Lighting designer' }, 'skos:definition': {  'eng': 'A person or organization who designs the lighting scheme for a theatrical presentation, entertainment, motion picture, etc.',  'deu': 'Eine Person oder Organisation, die das Beleuchtungsschema für eine Theatervorstellung, ein Unterhaltungsprogramm, einen Film usw. entwirft.' } },
      { '@id': 'role:ltg', 'skos:prefLabel': { 'eng': 'Lithographer', 'deu': 'Lithograph*in', 'ita': 'Litografo' }, 'skos:definition': {  'eng': 'A person or organization who prepares the stone or plate for lithographic printing, including a graphic artist creating a design directly on the surface from which printing will be done.',  'deu': 'Eine Person oder Organisation, die den Stein oder die Platte für den lithografischen Druck vorbereitet, einschließlich eines Grafikers bzw. einer Grafikerin, der bzw. die einen Entwurf direkt auf der Oberfläche erstellt, von der gedruckt werden soll.' } },
      { '@id': 'role:lyr', 'skos:prefLabel': { 'eng': 'Lyricist', 'deu': 'Liedtexter*in', 'ita': 'Paroliere' }, 'skos:definition': {  'eng': 'An author of the words of a non-dramatic musical work (e.g. the text of a song), except for oratorios.',  'deu': 'Ein*e Autor*in des Textes eines nicht-dramatischen Musikwerkes (z. B. des Textes eines Liedes), außer bei Oratorien.' } },
      { '@id': 'role:mfp', 'skos:prefLabel': { 'eng': 'Manufacture place', 'deu': 'Herstellungsort', 'ita': 'Manufacture place' }, 'skos:definition': {  'eng': 'The place of manufacture (e.g., printing, duplicating, casting, etc.) of a resource in a published form.',  'deu': 'Der Ort der Herstellung (z. B. Druck, Vervielfältigung, Gießen usw.) einer Ressource in einer veröffentlichten Form.' } },
      { '@id': 'role:mfr', 'skos:prefLabel': { 'eng': 'Manufacturer', 'deu': 'Hersteller*in', 'ita': 'Manufacturer' }, 'skos:definition': {  'eng': 'A person or organization responsible for printing, duplicating, casting, etc. a resource.',  'deu': 'Eine Person oder Organisation, die für das Drucken, Vervielfältigen, Gießen usw. einer Ressource verantwortlich ist.' } },
      { '@id': 'role:mrb', 'skos:prefLabel': { 'eng': 'Marbler', 'deu': 'Marmorier*in', 'ita': 'Marbler' }, 'skos:definition': {  'eng': 'The entity responsible for marbling paper, cloth, leather, etc. used in construction of a resource.',  'deu': 'Die Einheit, die für die Marmorierung von Papier, Stoff, Leder usw. zuständig ist, die für den Bau einer Ressource verwendet werden.' } },
      { '@id': 'role:mrk', 'skos:prefLabel': { 'eng': 'Markup editor', 'deu': 'Markup-Editor*in', 'ita': 'Markup editor' }, 'skos:definition': {  'eng': 'A person or organization performing the coding of SGML, HTML, or XML markup of metadata, text, etc.',  'deu': 'Eine Person oder Organisation, die die Kodierung von SGML-, HTML- oder XML-Auszeichnungen von Metadaten, Text usw. vornimmt.' } },
      { '@id': 'role:med', 'skos:prefLabel': { 'eng': 'Medium', 'deu': 'Medium', 'ita': 'Medium' }, 'skos:definition': {  'eng': 'A person held to be a channel of communication between the earthly world and a world of spirits.',  'deu': 'Eine Person, die als Kommunikationskanal zwischen der irdischen Welt und der Welt der Geister gilt.' } },
      { '@id': 'role:mdc', 'skos:prefLabel': { 'eng': 'Metadata contact', 'deu': 'Metadaten-Editor*in', 'ita': 'Metadata contact' }, 'skos:definition': {  'eng': 'A person or organization primarily responsible for compiling and maintaining the original description of a metadata set (e.g., geospatial metadata set).',  'deu': 'Eine Person oder Organisation, die in erster Linie für die Zusammenstellung und Pflege der ursprünglichen Beschreibung eines Metadatensatzes (z. B. eines Geodatensatzes) verantwortlich ist.' } },
      { '@id': 'role:emt', 'skos:prefLabel': { 'eng': 'Metal-engraver', 'deu': 'Metallstecher*in', 'ita': 'Calcografo' }, 'skos:definition': {  'eng': 'An engraver responsible for decorations, illustrations, letters, etc. cut on a metal surface for printing or decoration.',  'deu': 'Ein Graveur, der für Verzierungen, Illustrationen, Buchstaben usw. verantwortlich ist, die zu Druck- oder Dekorationszwecken in eine Metalloberfläche geschnitten werden.' } },
      { '@id': 'role:mtk', 'skos:prefLabel': { 'eng': 'Minute taker', 'deu': 'Protokollführer*in', 'ita': 'Minute taker' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for recording the minutes of a meeting.',  'deu': 'Eine Person, Familie oder Organisation, die für die Aufzeichnung des Protokolls einer Sitzung verantwortlich ist.' } },
      { '@id': 'role:mod', 'skos:prefLabel': { 'eng': 'Moderator', 'deu': 'Diskussionsleiter*in', 'ita': 'Moderator' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by leading a program (often broadcast) where topics are discussed, usually with participation of experts in fields related to the discussion.',  'deu': 'Ein*e Künstler*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie eine (häufig ausgestrahlte) Sendung leitet, in der Themen erörtert werden, in der Regel unter Beteiligung von Expert*innen aus den mit der Diskussion verbundenen Bereichen.' } },
      { '@id': 'role:mon', 'skos:prefLabel': { 'eng': 'Monitor', 'deu': 'Vertragsprüfer*in', 'ita': 'Monitor' }, 'skos:definition': {  'eng': 'A person or organization that supervises compliance with the contract and is responsible for the report and controls its distribution. Sometimes referred to as the grantee, or controlling agency.',  'deu': 'A person or organization that supervises compliance with the contract and is responsible for the report and controls its distribution. Sometimes referred to as the grantee, or controlling agency.' } },
      { '@id': 'role:mcp', 'skos:prefLabel': { 'eng': 'Music copyist', 'deu': 'Musikkopist*in', 'ita': 'Music copyist' }, 'skos:definition': {  'eng': 'A person who transcribes or copies musical notation.',  'deu': 'Eine Person oder Organisation, die die Einhaltung des Vertrags überwacht, für den Bericht verantwortlich ist und dessen Verteilung kontrolliert. Wird manchmal auch als Zuschussempfänger*in oder Kontrollstelle bezeichnet.' } },
      { '@id': 'role:msd', 'skos:prefLabel': { 'eng': 'Musical director', 'deu': 'Musikalische/r Leiter*in', 'ita': 'Direttore musicale' }, 'skos:definition': {  'eng': 'A person who coordinates the activities of the composer, the sound editor, and sound mixers for a moving image production or for a musical or dramatic presentation or entertainment.',  'deu': 'Eine Person, die die Aktivitäten des Komponisten bzw. der Komponistin, des Tonmeisters bzw. der Tonmeisterin und der Tonmischer*innen für eine Bewegtbildproduktion oder für eine musikalische oder dramatische Präsentation oder Unterhaltung koordiniert.' } },
      { '@id': 'role:mus', 'skos:prefLabel': { 'eng': 'Musician', 'deu': 'Musiker*in', 'ita': 'Musicista' }, 'skos:definition': {  'eng': 'A person or organization who performs music or contributes to the musical content of a work when it is not possible or desirable to identify the function more precisely.',  'deu': 'Eine Person oder Organisation, die Musik ausführt oder zum musikalischen Inhalt eines Werkes beiträgt, wenn es nicht möglich oder wünschenswert ist, die Funktion genauer zu bestimmen.' } },
      { '@id': 'role:nrt', 'skos:prefLabel': { 'eng': 'Narrator', 'deu': 'Erzähler*in', 'ita': 'Narrator' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by reading or speaking in order to give an account of an act, occurrence, course of events, etc.',  'deu': 'Ein Darsteller, der zu einer Ressource beiträgt, indem er etwas vorliest oder spricht, um einen Bericht über eine Handlung, ein Ereignis, einen Ablauf usw. zu geben.' } },
      { '@id': 'role:osp', 'skos:prefLabel': { 'eng': 'Onscreen presenter', 'deu': 'Fernsehmoderator*in', 'ita': 'Onscreen presenter' }, 'skos:definition': {  'eng': 'A performer contributing to an expression of a work by appearing on screen in nonfiction moving image materials or introductions to fiction moving image materials to provide contextual or background information. Use when another term (e.g., narrator, host) is either not applicable or not desired.',  'deu': 'Ein*e Darsteller*in, der bzw. die zum Ausdruck eines Werks beiträgt, indem er bzw. sie auf der Leinwand in nicht-fiktionalem Bewegtbildmaterial oder in Einführungen zu fiktionalem Bewegtbildmaterial erscheint, um Kontext- oder Hintergrundinformationen zu liefern. Zu verwenden, wenn ein anderer Begriff (z. B. Erzähler*in, Moderator*in) entweder nicht anwendbar oder nicht erwünscht ist.' } },
      { '@id': 'role:opn', 'skos:prefLabel': { 'eng': 'Opponent', 'deu': 'Opponent*in bei akademischen Prüfungen', 'ita': 'Controrelatore' }, 'skos:definition': {  'eng': 'A person or organization responsible for opposing a thesis or dissertation.',  'deu': 'Eine Person oder Organisation, die für die Ablehnung einer These oder Dissertation verantwortlich ist.' } },
      { '@id': 'role:orm', 'skos:prefLabel': { 'eng': 'Organizer', 'deu': 'Veranstalter*in', 'ita': 'Organizer' }, 'skos:definition': {  'eng': 'A person, family, or organization organizing the exhibit, event, conference, etc., which gave rise to a resource.',  'deu': 'Eine Person, Familie oder Organisation, die die Ausstellung, Veranstaltung, Konferenz usw. organisiert, aus der eine Ressource hervorgegangen ist.' } },
      { '@id': 'role:org', 'skos:prefLabel': { 'eng': 'Originator', 'deu': 'Schöpfer*in / Urheber*in ', 'ita': 'Originator' }, 'skos:definition': {  'eng': 'A person or organization performing the work, i.e., the name of a person or organization associated with the intellectual content of the work. This category does not include the publisher or personal affiliation, or sponsor except where it is also the corporate author.',  'deu': 'Eine Person oder Organisation, die das Werk ausführt, d. h. der Name einer Person oder Organisation, die mit dem geistigen Inhalt des Werks verbunden ist. Diese Kategorie umfasst nicht den Herausgeber bzw. die Herausgeber*in oder die persönliche Zugehörigkeit oder den Sponsor bzw. die Sponsorin, es sei denn, es handelt sich auch um den mitwirkenden Autor bzw. die mitwirkende Autorin.' } },
      { '@id': 'role:own', 'skos:prefLabel': { 'eng': 'Owner', 'deu': 'Eigentümer*in', 'ita': 'Proprietario' }, 'skos:definition': {  'eng': 'A person, family, or organization that currently owns an item or collection, i.e.has legal possession of a resource.',  'deu': 'Eine Person, Familie oder Organisation, die derzeit Eigentümer*in eines Gegenstands oder einer Sammlung ist, d. h. rechtlich im Besitz einer Ressource ist.' } },
      { '@id': 'role:pan', 'skos:prefLabel': { 'eng': 'Panelist', 'deu': 'Diskussionsteilnehmer*in', 'ita': 'Panelist' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by participating in a program (often broadcast) where topics are discussed, usually with participation of experts in fields related to the discussion.',  'deu': 'Ein*e Künstler*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie an einer (oft ausgestrahlten) Sendung teilnimmt, in der Themen diskutiert werden, in der Regel unter Beteiligung von Expert*innen auf den mit der Diskussion verbundenen Gebieten.' } },
      { '@id': 'role:ppm', 'skos:prefLabel': { 'eng': 'Papermaker', 'deu': 'Papiermacher*in', 'ita': 'Papermaker' }, 'skos:definition': {  'eng': 'A person or organization responsible for the production of paper, usually from wood, cloth, or other fibrous material.',  'deu': 'Eine Person oder Organisation, die für die Herstellung von Papier verantwortlich ist, in der Regel aus Holz, Stoff oder anderen Fasermaterialien.' } },
      { '@id': 'role:pta', 'skos:prefLabel': { 'eng': 'Patent applicant', 'deu': 'Patentantragsteller*in', 'ita': 'Patent applicant' }, 'skos:definition': {  'eng': 'A person or organization that applied for a patent.',  'deu': 'Eine Person oder Organisation, die ein Patent angemeldet hat.' } },
      { '@id': 'role:pth', 'skos:prefLabel': { 'eng': 'Patent holder', 'deu': 'Patentinhaber*in', 'ita': 'Patent holder' }, 'skos:definition': {  'eng': 'A person or organization that was granted the patent referred to by the item.',  'deu': 'Eine Person oder Organisation, der das Patent, auf das sich der Eintrag bezieht, erteilt wurde.' } },
      { '@id': 'role:pat', 'skos:prefLabel': { 'eng': 'Patron', 'deu': 'Schirmherr*in / Förderer*in', 'ita': 'Patron' }, 'skos:definition': {  'eng': 'A person or organization responsible for commissioning a work. Usually a patron uses his or her means or influence to support the work of artists, writers, etc. This includes those who commission and pay for individual works.',  'deu': 'Eine Person oder Organisation, die ein Werk in Auftrag gibt. Normalerweise setzt ein*e Mäzen*in seine bzw. ihre Mittel oder seinen bzw. ihren Einfluss ein, um die Arbeit von Künstler*innen, Schriftsteller*innen usw. zu unterstützen. Dazu gehören auch diejenigen, die einzelne Werke in Auftrag geben und dafür bezahlen.' } },
      { '@id': 'role:pedagogicexpert', 'skos:prefLabel': { 'eng': 'Pedagogic Expert', 'deu': 'Pädagogische/r Expert*in', 'ita': 'Esperto pedagogico' }, 'skos:definition': { 'eng': 'A person or organisation who contributes specialized knowledge and expertise in pedagogy to scientific work.', 'deu': 'Eine Person oder Organisation, die Fachwissen und pädagogische Kompetenz in die wissenschaftliche Arbeit einbringt.' } },
      { '@id': 'role:prf', 'skos:prefLabel': { 'eng': 'Performer', 'deu': 'Performer / Künstler*in', 'ita': 'Performer' }, 'skos:definition': {  'eng': 'A person contributing to a resource by performing music, acting, dancing, speaking, etc., often in a musical or dramatic presentation, etc. If specific codes are used, Performer is used for a person whose principal skill is not known or specified.',  'deu': 'Eine Person, die zu einer Ressource beiträgt, indem sie Musik macht, schauspielert, tanzt, spricht usw., oft in einer musikalischen oder dramatischen Präsentation usw. Wenn spezifische Codes verwendet werden, wird Performer / Künstler*in für eine Person verwendet, deren Hauptfertigkeit nicht bekannt oder angegeben ist.' } },
      { '@id': 'role:pma', 'skos:prefLabel': { 'eng': 'Permitting agency', 'deu': 'Genehmigungsbehörde', 'ita': 'Permitting agency' }, 'skos:definition': {  'eng': 'An organization (usually a government agency) that issues permits under which work is accomplished.',  'deu': 'Eine Organisation (in der Regel eine Regierungsbehörde), die Genehmigungen erteilt, auf deren Grundlage Arbeiten durchgeführt werden.' } },
      { '@id': 'role:pht', 'skos:prefLabel': { 'eng': 'Photographer', 'deu': 'Fotograf*in', 'ita': 'Fotografo' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a photographic work.',  'deu': 'Eine Person, Familie oder Organisation, die für die Erstellung eines fotografischen Werks verantwortlich ist.' } },
      { '@id': 'role:plt', 'skos:prefLabel': { 'eng': 'Platemaker', 'deu': 'Druckplattenhersteller*in allgemein', 'ita': 'Platemaker' }, 'skos:definition': {  'eng': 'A person, family, or organization involved in manufacturing a manifestation by preparing plates used in the production of printed images and/or text.',  'deu': 'Eine Person, Familie oder Organisation, die an der Herstellung einer Manifestation beteiligt ist, indem sie Druckplatten für die Produktion von gedruckten Bildern und/oder Texten vorbereitet.' } },
      { '@id': 'role:pra', 'skos:prefLabel': { 'eng': 'Praeses', 'deu': 'Präses', 'ita': 'Praeses' }, 'skos:definition': {  'eng': 'A person who is the faculty moderator of an academic disputation, normally proposing a thesis and participating in the ensuing disputation.',  'deu': 'Eine Person, die als Moderator*in einer akademischen Disputation fungiert, normalerweise eine These vorschlägt und an der anschließenden Disputation teilnimmt.' } },
      { '@id': 'role:pre', 'skos:prefLabel': { 'eng': 'Presenter', 'deu': 'Präsentator*in', 'ita': 'Presenter' }, 'skos:definition': {  'eng': 'A person or organization mentioned in an “X presents” credit for moving image materials and who is associated with production, finance, or distribution in some way. A vanity credit; in early years, normally the head of a studio.',  'deu': 'Eine Person oder Organisation, die in einer "X präsentiert"-Nennung für Bewegtbildmaterial erwähnt wird und die in irgendeiner Weise mit der Produktion, der Finanzierung oder dem Vertrieb verbunden ist. Eine Eitelkeitsnennung; in den Anfangsjahren normalerweise der Leiter bzw. die Leiterin eines Studios.' } },
      { '@id': 'role:prt', 'skos:prefLabel': { 'eng': 'Printer', 'deu': 'Drucker*in', 'ita': 'Stampatore' }, 'skos:definition': {  'eng': 'A person, family, or organization involved in manufacturing a manifestation of printed text, notated music, etc., from type or plates, such as a book, newspaper, magazine, broadside, score, etc.',  'deu': 'Eine Person, Familie oder Organisation, die an der Herstellung von gedrucktem Text, notierter Musik usw. aus Schrift oder Platten beteiligt ist, wie z. B. ein Buch, eine Zeitung, eine Zeitschrift, eine Breitseite, eine Partitur usw.' } },
      { '@id': 'role:pop', 'skos:prefLabel': { 'eng': 'Printer of plates', 'deu': 'Plattendrucker*in', 'ita': 'Printer of plates' }, 'skos:definition': {  'eng': 'A person or organization who prints illustrations from plates.',  'deu': 'Eine Person oder Organisation, die Illustrationen von Platten druckt.' } },
      { '@id': 'role:prm', 'skos:prefLabel': { 'eng': 'Printmaker', 'deu': 'Druckplattenhersteller*in (Tief-, Hoch-, Flachdruck)', 'ita': 'Printmaker' }, 'skos:definition': {  'eng': 'A person or organization who makes a relief, intaglio, or planographic printing surface.',  'deu': 'Eine Person oder Organisation, die eine Relief-, Tiefdruck- oder Flachdruckoberfläche herstellt.' } },
      { '@id': 'role:prc', 'skos:prefLabel': { 'eng': 'Process contact', 'deu': 'Ansprechpartner*in', 'ita': 'Process contact' }, 'skos:definition': {  'eng': 'A person or organization primarily responsible for performing or initiating a process, such as is done with the collection of metadata sets.',  'deu': 'Eine Person oder Organisation, die in erster Linie für die Durchführung oder Initiierung eines Prozesses verantwortlich ist, wie z. B. bei der Sammlung von Metadatensätzen.' } },
      { '@id': 'role:pro', 'skos:prefLabel': { 'eng': 'Producer', 'deu': 'Produzent*in', 'ita': 'Produttore' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for most of the business aspects of a production for screen, audio recording, television, webcast, etc. The producer is generally responsible for fund raising, managing the production, hiring key personnel, arranging for distributors, etc.',  'deu': 'Eine Person, Familie oder Organisation, die für die meisten geschäftlichen Aspekte einer Produktion für Leinwand, Tonaufnahme, Fernsehen, Webcast usw. verantwortlich ist. Der Produzent bzw. die Produzentin ist in der Regel für die Mittelbeschaffung, das Management der Produktion, die Einstellung von Schlüsselpersonal, die Vermittlung von Verleiher*innen usw. verantwortlich.' } },
      { '@id': 'role:prn', 'skos:prefLabel': { 'eng': 'Production company', 'deu': 'Produktionsfirma', 'ita': 'Production company' }, 'skos:definition': {  'eng': 'An organization that is responsible for financial, technical, and organizational management of a production for stage, screen, audio recording, television, webcast, etc.',  'deu': 'Eine Organisation, die für das finanzielle, technische und organisatorische Management einer Produktion für Bühne, Leinwand, Tonaufnahme, Fernsehen, Webcast usw. verantwortlich ist.' } },
      { '@id': 'role:prp', 'skos:prefLabel': { 'eng': 'Production place', 'deu': 'Produktionsort', 'ita': 'Production place' }, 'skos:definition': {  'eng': 'The place of production (e.g., inscription, fabrication, construction, etc.) of a resource in an unpublished form.',  'deu': 'Der Ort, an dem eine Ressource in unveröffentlichter Form hergestellt wurde (z. B. Eintragung, Herstellung, Konstruktion usw.).' } },
      { '@id': 'role:prs', 'skos:prefLabel': { 'eng': 'Production designer', 'deu': 'Produktionsdesigner*in', 'ita': 'Production designer' }, 'skos:definition': {  'eng': 'A person or organization responsible for designing the overall visual appearance of a moving image production.',  'deu': 'Eine Person oder Organisation, die für die Gestaltung des gesamten visuellen Erscheinungsbildes einer Bewegtbildproduktion verantwortlich ist.' } },
      { '@id': 'role:pmn', 'skos:prefLabel': { 'eng': 'Production manager', 'deu': 'Produktionsmanager*in', 'ita': 'Production manager' }, 'skos:definition': {  'eng': 'A person responsible for all technical and business matters in a production.',  'deu': 'Eine Person, die für alle technischen und geschäftlichen Angelegenheiten einer Produktion verantwortlich ist.' } },
      { '@id': 'role:prd', 'skos:prefLabel': { 'eng': 'Production personnel', 'deu': 'Produktionspersonal', 'ita': 'Production personnel' }, 'skos:definition': {  'eng': 'A person or organization associated with the production (props, lighting, special effects, etc.) of a musical or dramatic presentation or entertainment.',  'deu': 'Eine Person oder Organisation, die an der Produktion (Requisiten, Beleuchtung, Spezialeffekte usw.) einer musikalischen oder dramatischen Darbietung oder Unterhaltung beteiligt ist.' } },
      { '@id': 'role:prg', 'skos:prefLabel': { 'eng': 'Programmer', 'deu': 'Programmierer*in', 'ita': 'Programmer' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a computer program.',  'deu': 'Eine Person, Familie oder Organisation, die für die Erstellung eines Computerprogramms verantwortlich ist.' } },
      { '@id': 'role:pdr', 'skos:prefLabel': { 'eng': 'Project director', 'deu': 'Projektleiter*in', 'ita': 'Project director' }, 'skos:definition': {  'eng': 'A person or organization with primary responsibility for all essential aspects of a project, has overall responsibility for managing projects, or provides overall direction to a project manager.',  'deu': 'Eine Person oder Organisation, die die Hauptverantwortung für alle wesentlichen Aspekte eines Projekts trägt, die Gesamtverantwortung für das Management von Projekten hat oder einem Projektmanager bzw. einer Projektmanagerin die Gesamtleitung überträgt.' } },
      { '@id': 'role:pfr', 'skos:prefLabel': { 'eng': 'Proofreader', 'deu': 'Lektor*in', 'ita': 'Correttore' }, 'skos:definition': {  'eng': 'A person who corrects printed matter. For manuscripts, use Corrector [crr].',  'deu': 'Eine Person, die Drucksachen korrigiert. Für Manuskripte verwenden Sie Korrektor*in.' } },
      { '@id': 'role:prv', 'skos:prefLabel': { 'eng': 'Provider', 'deu': 'Anbieter*in / Lieferant*in', 'ita': 'Provider' }, 'skos:definition': {  'eng': 'A person or organization who produces, publishes, manufactures, or distributes a resource if specific codes are not desired (e.g. [mfr], [pbl]).',  'deu': 'Eine Person oder Organisation, die eine Ressource produziert, veröffentlicht, herstellt oder vertreibt, wenn keine spezifischen Bezeichnungen gewünscht sind (z. B. Hersteller*in, Verleger*in).' } },
      { '@id': 'role:pbl', 'skos:prefLabel': { 'eng': 'Publisher', 'deu': 'Verleger*in', 'ita': 'Editore' }, 'skos:definition': {  'eng': 'A person or organization responsible for publishing, releasing, or issuing a resource.',  'deu': 'Eine Person oder Organisation, die für die Veröffentlichung, Freigabe oder Herausgabe einer Ressource verantwortlich ist.' } },
      { '@id': 'role:pbd', 'skos:prefLabel': { 'eng': 'Publishing director', 'deu': 'Verlagsleiter*in', 'ita': 'Publishing director' }, 'skos:definition': {  'eng': 'A person or organization who presides over the elaboration of a collective work to ensure its coherence or continuity. This includes editors-in-chief, literary editors, editors of series, etc.',  'deu': 'Eine Person oder Organisation, die bei der Ausarbeitung eines kollektiven Werks den Vorsitz führt, um dessen Kohärenz oder Kontinuität zu gewährleisten. Dazu gehören Chefredakteur*innen, literarische Redakteur*innen, Redakteur*innen von Serien usw.' } },
      { '@id': 'role:ppt', 'skos:prefLabel': { 'eng': 'Puppeteer', 'deu': 'Puppenspieler*in', 'ita': 'Puppeteer' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by manipulating, controlling, or directing puppets or marionettes in a moving image production or a musical or dramatic presentation or entertainment.',  'deu': 'Ein*e Darsteller*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie Puppen oder Marionetten in einer Bewegtbildproduktion oder einer musikalischen oder dramatischen Präsentation oder Unterhaltung manipuliert, kontrolliert oder anleitet.' } },
      { '@id': 'role:rdd', 'skos:prefLabel': { 'eng': 'Radio director', 'deu': 'Radio-, Hörfunkdirektor*in', 'ita': 'Radio director' }, 'skos:definition': {  'eng': 'A director responsible for the general management and supervision of a radio program.',  'deu': 'Ein*e Regisseur*in, der bzw. die für die allgemeine Verwaltung und Überwachung eines Radioprogramms verantwortlich ist.' } },
      { '@id': 'role:rpc', 'skos:prefLabel': { 'eng': 'Radio producer', 'deu': 'Radioproduzent*in', 'ita': 'Radio producer' }, 'skos:definition': {  'eng': 'A producer responsible for most of the business aspects of a radio program.',  'deu': 'Ein*e Produzent*in, der bzw. die für die meisten geschäftlichen Aspekte eines Radioprogramms verantwortlich ist.' } },
      { '@id': 'role:rce', 'skos:prefLabel': { 'eng': 'Recording engineer', 'deu': 'Toningenieur*in', 'ita': 'Tecnico della registrazione' }, 'skos:definition': {  'eng': 'A person contributing to a resource by supervising the technical aspects of a sound or video recording session.',  'deu': 'Eine Person, die einen Beitrag zu einer Ressource leistet, indem sie die technischen Aspekte einer Ton- oder Videoaufnahme überwacht.' } },
      { '@id': 'role:rcd', 'skos:prefLabel': { 'eng': 'Recordist', 'deu': 'Tonaufnahmetechniker*in', 'ita': 'Recordist' }, 'skos:definition': {  'eng': 'A person or organization who uses a recording device to capture sounds and/or video during a recording session, including field recordings of natural sounds, folkloric events, music, etc.',  'deu': 'Eine Person oder Organisation, die ein Aufnahmegerät verwendet, um während einer Aufnahmesitzung Töne und/oder Videos aufzunehmen, einschließlich Feldaufnahmen von Naturgeräuschen, folkloristischen Veranstaltungen, Musik usw.' } },
      { '@id': 'role:red', 'skos:prefLabel': { 'eng': 'Redaktor', 'deu': 'Redakteur*in', 'ita': 'Redaktor' }, 'skos:definition': {  'eng': 'A person or organization who writes or develops the framework for an item without being intellectually responsible for its content.',  'deu': 'Eine Person oder Organisation, die den Rahmen für einen Artikel schreibt oder entwickelt, ohne für dessen Inhalt intellektuell verantwortlich zu sein.' } },
      { '@id': 'role:ren', 'skos:prefLabel': { 'eng': 'Renderer', 'deu': 'Reinzeichner*in', 'ita': 'Renderer' }, 'skos:definition': {  'eng': 'A person or organization who prepares drawings of architectural designs (i.e., renderings) in accurate, representational perspective to show what the project will look like when completed.',  'deu': 'Eine  Person oder Organisation, die Zeichnungen von architektonischen Entwürfen (d.h. Renderings) in genauer, repräsentativer Perspektive anfertigt, um zu zeigen, wie das Projekt nach seiner Fertigstellung aussehen wird.' } },
      { '@id': 'role:rpt', 'skos:prefLabel': { 'eng': 'Reporter', 'deu': 'Reporter*in / Berichterstatter*in', 'ita': 'Reporter' }, 'skos:definition': {  'eng': 'A person or organization who writes or presents reports of news or current events on air or in print.',  'deu': 'Eine Person oder Organisation, die Berichte über Nachrichten oder aktuelle Ereignisse im Fernsehen oder in gedruckter Form verfasst oder präsentiert.' } },
      { '@id': 'role:rth', 'skos:prefLabel': { 'eng': 'Research team head', 'deu': 'Leiter*in eines Forschungsteams', 'ita': 'Direttore della ricerca' }, 'skos:definition': {  'eng': 'A person who directed or managed a research project.',  'deu': 'Eine Person, die ein Forschungsprojekt leitet oder verwaltet.' } },
      { '@id': 'role:rtm', 'skos:prefLabel': { 'eng': 'Research team member', 'deu': 'Mitarbeiter*in des Forschungsteams', 'ita': 'Membro di un gruppo di ricerca' }, 'skos:definition': {  'eng': 'A person who participated in a research project but whose role did not involve direction or management of it.',  'deu': 'Eine Person, die an einem Forschungsprojekt mitgewirkt hat, deren Rolle jedoch nicht in der Leitung oder Verwaltung des Projekts bestand.' } },
      { '@id': 'role:res', 'skos:prefLabel': { 'eng': 'Researcher', 'deu': 'Forscher*in', 'ita': 'Ricercatore' }, 'skos:definition': {  'eng': 'A person or organization responsible for performing research.',  'deu': 'Eine Person oder Organisation, die für die Durchführung von Forschungsarbeiten verantwortlich ist.' } },
      { '@id': 'role:rsp', 'skos:prefLabel': { 'eng': 'Respondent', 'deu': 'Befragte/r bei akademischer Prüfung', 'ita': 'Respondent' }, 'skos:definition': {  'eng': 'A person or organization who makes an answer to the courts pursuant to an application for redress (usually in an equity proceeding) or a candidate for a degree who defends or opposes a thesis provided by the praeses in an academic disputation.',  'deu': 'Eine Person oder Organisation, die sich aufgrund eines Antrags auf Wiedergutmachung (in der Regel in einem Billigkeitsverfahren) an die Gerichte wendet, oder ein*e Kandidat*in, der bzw. die in einer akademischen Disputation eine vom Präses vorgelegte These verteidigt oder ablehnt.' } },
      { '@id': 'role:rst', 'skos:prefLabel': { 'eng': 'Respondent-appellant', 'deu': 'Respondent-appellant', 'ita': 'Respondent-appellant' }, 'skos:definition': {  'eng': 'A respondent who takes an appeal from one court or jurisdiction to another to reverse the judgment, usually in an equity proceeding.',  'deu': 'Ein*e Beklagte*r, der bzw. die bei einem anderen Gericht oder einer anderen Gerichtsbarkeit Berufung einlegt, um das Urteil aufzuheben, in der Regel im Rahmen eines Billigkeitsverfahrens.' } },
      { '@id': 'role:rse', 'skos:prefLabel': { 'eng': 'Respondent-appellee', 'deu': 'Respondent-appellee', 'ita': 'Respondent-appellee' }, 'skos:definition': {  'eng': 'A respondent against whom an appeal is taken from one court or jurisdiction to another to reverse the judgment, usually in an equity proceeding.',  'deu': 'Ein*e Beklagte*r, gegen den bzw. die von einem Gericht oder einer Gerichtsbarkeit an ein anderes Gericht Berufung eingelegt wird, um das Urteil aufzuheben, in der Regel in einem Billigkeitsverfahren.' } },
      { '@id': 'role:rpy', 'skos:prefLabel': { 'eng': 'Responsible party', 'deu': 'Rechtlich verantwortliche Partei', 'ita': 'Responsible party' }, 'skos:definition': {  'eng': 'A person or organization legally responsible for the content of the published material.',  'deu': 'Eine Person oder Organisation, die rechtlich für den Inhalt des veröffentlichten Materials verantwortlich ist.' } },
      { '@id': 'role:rsg', 'skos:prefLabel': { 'eng': 'Restager', 'deu': 'Wiederaufführung', 'ita': 'Restager' }, 'skos:definition': {  'eng': 'A person or organization, other than the original choreographer or director, responsible for restaging a choreographic or dramatic work and who contributes minimal new content.',  'deu': 'Eine Person oder Organisation, die nicht der bzw. die ursprüngliche Choreograf*in oder Regisseur*in ist und die für die Neuinszenierung eines choreografischen oder dramatischen Werks verantwortlich ist und nur einen minimalen neuen Inhalt beiträgt.' } },
      { '@id': 'role:rsr', 'skos:prefLabel': { 'eng': 'Restorationist', 'deu': 'Restaurator*in', 'ita': 'Restorationist' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for the set of technical, editorial, and intellectual procedures aimed at compensating for the degradation of an item by bringing it back to a state as close as possible to its original condition.',  'deu': 'Eine Person, Familie oder Organisation, die für die Gesamtheit der technischen, redaktionellen und intellektuellen Verfahren verantwortlich ist, die darauf abzielen, die Verschlechterung eines Gegenstands auszugleichen, indem sie ihn in einen Zustand zurückversetzen, der seinem ursprünglichen Zustand so nahe wie möglich kommt.' } },
      { '@id': 'role:rev', 'skos:prefLabel': { 'eng': 'Reviewer', 'deu': 'Kritiker*in', 'ita': 'Recensore' }, 'skos:definition': {  'eng': 'A person or organization responsible for the review of a book, motion picture, performance, etc.',  'deu': 'Eine Person oder Organisation, die für die Rezension eines Buches, eines Films, einer Aufführung usw. verantwortlich ist.' } },
      { '@id': 'role:rbr', 'skos:prefLabel': { 'eng': 'Rubricator', 'deu': 'Rubrikator*in', 'ita': 'Rubricator' }, 'skos:definition': {  'eng': 'A person or organization responsible for parts of a work, often headings or opening parts of a manuscript, that appear in a distinctive color, usually red.',  'deu': 'Eine Person oder Organisation, die für Teile eines Werks verantwortlich ist, oft Überschriften oder einleitende Teile eines Manuskripts, die in einer charakteristischen Farbe, meist rot, erscheinen.' } },
      { '@id': 'role:sce', 'skos:prefLabel': { 'eng': 'Scenarist', 'deu': 'Szenarist*in', 'ita': 'Scenografo' }, 'skos:definition': {  'eng': 'A person or organization who is the author of a motion picture screenplay, generally the person who wrote the scenarios for a motion picture during the silent era.',  'deu': 'Eine Person oder Organisation, die ein Drehbuch für einen Kinofilm verfasst hat, im Allgemeinen die Person, die in der Stummfilmzeit die Drehbücher für einen Kinofilm geschrieben hat.' } },
      { '@id': 'role:sad', 'skos:prefLabel': { 'eng': 'Scientific advisor', 'deu': 'Wissenschaftliche Berater*in', 'ita': 'Consulente scientifico' }, 'skos:definition': {  'eng': 'A person or organization who brings scientific, pedagogical, or historical competence to the conception and realization on a work, particularly in the case of audio-visual items.',  'deu': 'Eine Person oder Organisation, die wissenschaftliche, pädagogische oder historische Kompetenz in die Konzeption und Realisierung eines Werkes einbringt, insbesondere im Falle von audiovisuellen Werken.' } },
      { '@id': 'role:aus', 'skos:prefLabel': { 'eng': 'Screenwriter', 'deu': 'Drehbuchautor*in', 'ita': 'Sceneggiatore' }, 'skos:definition': {  'eng': 'An author of a screenplay, script, or scene.',  'deu': 'Ein*e Autor*in eines Drehbuchs, Skripts oder einer Szene.' } },
      { '@id': 'role:scr', 'skos:prefLabel': { 'eng': 'Scribe', 'deu': 'Skriptor*in', 'ita': 'Scribe' }, 'skos:definition': {  'eng': 'A person who is an amanuensis and for a writer of manuscripts proper. For a person who makes pen-facsimiles, use Facsimilist [fac].',  'deu': 'Eine Person, die ein Amanuensis ist, und für einen Schreiber von Manuskripten im eigentlichen Sinne. Für eine Person, die Stift-Faksimiles anfertigt, verwenden Sie Ersteller*in des Faksimile.' } },
      { '@id': 'role:scl', 'skos:prefLabel': { 'eng': 'Sculptor', 'deu': 'Bildhauer*in', 'ita': 'Scultore' }, 'skos:definition': {  'eng': 'An artist responsible for creating a three-dimensional work by modeling, carving, or similar technique.',  'deu': 'Ein*e Künstler*in, der bzw. die ein dreidimensionales Werk durch Modellieren, Schnitzen oder eine ähnliche Technik schafft.' } },
      { '@id': 'role:spy', 'skos:prefLabel': { 'eng': 'Second party', 'deu': 'Zweite Vertragspartei', 'ita': 'Second party' }, 'skos:definition': {  'eng': 'A person or organization who is identified as the party of the second part. In the case of transfer of right, this is the assignee, transferee, licensee, grantee, etc. Multiple parties can be named jointly as the second party.', 'deu': 'Eine Person oder Organisation, die als die Vertragspartei des zweiten Teils identifiziert wird. Bei der Übertragung von Rechten ist dies der bzw. die Abtretungsempfänger*in, der bzw. die Übernehmer*in, der bzw. die Lizenznehmer*in, der bzw. die Begünstigte, usw. Mehrere Parteien können gemeinsam als zweite Vertragspartei benannt werden.' } },
      { '@id': 'role:sec', 'skos:prefLabel': { 'eng': 'Secretary', 'deu': 'Sekretär*in (Funktion)', 'ita': 'Secretary' }, 'skos:definition': {  'eng': 'A person or organization who is a recorder, redactor, or other person responsible for expressing the views of a organization.',  'deu': 'Eine Person oder Organisation, die als Protokollant, Redakteur oder sonstiger Verantwortlicher für den Ausdruck der Ansichten einer Organisation fungiert.' } },
      { '@id': 'role:sll', 'skos:prefLabel': { 'eng': 'Seller', 'deu': 'Verkäufer*in', 'ita': 'Seller' }, 'skos:definition': {  'eng': 'A former owner of an item who sold that item to another owner.',  'deu': 'Ein*e ehemalige*r Eigentümer*in eines Gegenstandes, der bzw. die diesen Gegenstand an eine*n andere*n Eigentümer*in verkauft hat.' } },
      { '@id': 'role:std', 'skos:prefLabel': { 'eng': 'Set designer', 'deu': 'Bühnenbildner*in / Filmarchitekt', 'ita': 'Set designer' }, 'skos:definition': {  'eng': 'A person who translates the rough sketches of the art director into actual architectural structures for a theatrical presentation, entertainment, motion picture, etc. Set designers draw the detailed guides and specifications for building the set.',  'deu': 'Eine Person, die die groben Skizzen des künstlerischen Leiters bzw. der künstlerischen Leiterin in tatsächliche architektonische Strukturen für eine Theatervorstellung, Unterhaltung, einen Film usw. umsetzt. Bühnenbildner*innen zeichnen die detaillierten Anleitungen und Spezifikationen für den Bau des Bühnenbilds.' } },
      { '@id': 'role:stg', 'skos:prefLabel': { 'eng': 'Setting', 'deu': 'Schauplatz / Handlungsraum', 'ita': 'Setting' }, 'skos:definition': {  'eng': 'An entity in which the activity or plot of a work takes place, e.g. a geographic place, a time period, a building, an event.',  'deu': 'Eine Einheit, in der sich die Handlung eines Werks abspielt, z. B. ein geografischer Ort, eine Zeitspanne, ein Gebäude, ein Ereignis.' } },
      { '@id': 'role:sgn', 'skos:prefLabel': { 'eng': 'Signer', 'deu': 'Unterzeichner*in', 'ita': 'Signer' }, 'skos:definition': {  'eng': 'A person whose signature appears without a presentation or other statement indicative of provenance. When there is a presentation statement, use Inscriber [ins].',  'deu': 'Eine Person, deren Unterschrift ohne eine Präsentation oder einen anderen Hinweis auf die Herkunft erscheint. Wenn es eine Präsentationserklärung gibt, verwenden Sie Widmende/r.' } },
      { '@id': 'role:sng', 'skos:prefLabel': { 'eng': 'Singer', 'deu': 'Sänger*in', 'ita': 'Cantante' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by using his/her/their voice, with or without instrumental accompaniment, to produce music. A singer\'s performance may or may not include actual words.',  'deu': 'Ein*e Künstler*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie seine bzw. ihre Stimme mit oder ohne Instrumentalbegleitung einsetzt, um Musik zu produzieren. Die Darbietung eines Sängers bzw. einer Sängerin kann, muss aber nicht unbedingt Worte enthalten.' } },
      { '@id': 'role:sds', 'skos:prefLabel': { 'eng': 'Sound designer', 'deu': 'Sounddesigner*in', 'ita': 'Progettista del suono' }, 'skos:definition': {  'eng': 'A person who produces and reproduces the sound score (both live and recorded), the installation of microphones, the setting of sound levels, and the coordination of sources of sound for a production.',  'deu': 'Eine Person, die den Soundtrack (sowohl live als auch aufgenommen) produziert und reproduziert, die Mikrofone installiert, die Lautstärke einstellt und die Tonquellen für eine Produktion koordiniert.' } },
      { '@id': 'role:spk', 'skos:prefLabel': { 'eng': 'Speaker / Lecturer', 'deu': 'Sprecher*in / Vortragende/r', 'ita': 'Speaker' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by speaking words, such as a lecture, speech, etc.',  'deu': 'Ein*e Darsteller*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. die Worte spricht, z. B. bei einem Vortrag, einer Rede usw.' } },
      { '@id': 'role:spn', 'skos:prefLabel': { 'eng': 'Sponsor', 'deu': 'Sponsor', 'ita': 'Sponsor' }, 'skos:definition': {  'eng': 'A person, family, or organization sponsoring some aspect of a resource, e.g., funding research, sponsoring an event.',  'deu': 'Eine Person, Familie oder Organisation, die einen bestimmten Aspekt einer Ressource sponsert, z. B. die Finanzierung von Forschungsarbeiten oder das Sponsoring einer Veranstaltung.' } },
      { '@id': 'role:sgd', 'skos:prefLabel': { 'eng': 'Stage director', 'deu': 'Theaterregisseur*in', 'ita': 'Stage director' }, 'skos:definition': {  'eng': 'A person or organization contributing to a stage resource through the overall management and supervision of a performance.',  'deu': 'Eine Person oder Organisation, die durch das Gesamtmanagement und die Aufsicht über eine Aufführung zu einer Bühnenressource beiträgt.' } },
      { '@id': 'role:stm', 'skos:prefLabel': { 'eng': 'Stage manager', 'deu': 'Inspizient*in / Bühnenmeister*in', 'ita': 'Stage manager' }, 'skos:definition': {  'eng': 'A person who is in charge of everything that occurs on a performance stage, and who acts as chief of all crews and assistant to a director during rehearsals.',  'deu': 'Eine Person, die für alles verantwortlich ist, was auf einer Aufführungsbühne passiert, und die als Chef*in aller Crews und Assistent*in eines Regisseurs bzw. einer Regisseurin während der Proben fungiert.' } },
      { '@id': 'role:stn', 'skos:prefLabel': { 'eng': 'Standards body', 'deu': 'Normkomitee', 'ita': 'Standards body' }, 'skos:definition': {  'eng': 'An organization responsible for the development or enforcement of a standard.',  'deu': 'Eine Organisation, die für die Entwicklung oder Durchsetzung einer Norm verantwortlich ist.' } },
      { '@id': 'role:str', 'skos:prefLabel': { 'eng': 'Stereotyper', 'deu': 'Stereotypieplattenhersteller', 'ita': 'Stereotyper' }, 'skos:definition': {  'eng': 'A person or organization who creates a new plate for printing by molding or copying another printing surface.',  'deu': 'Eine Person oder Organisation, die eine neue Druckplatte durch Abformen oder Kopieren einer anderen Druckoberfläche herstellt.' } },
      { '@id': 'role:stl', 'skos:prefLabel': { 'eng': 'Storyteller', 'deu': 'Geschichtenerzähler', 'ita': 'Storyteller' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by relaying a creator\'s original story with dramatic or theatrical interpretation.',  'deu': 'Ein*e Darsteller*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie die Originalgeschichte eines Schöpfers bzw. einer Schöpferin mit einer dramatischen oder theatralischen Interpretation wiedergibt.' } },
      { '@id': 'role:sht', 'skos:prefLabel': { 'eng': 'Supporting host', 'deu': 'Unterstützer*in', 'ita': 'Supporting host' }, 'skos:definition': {  'eng': 'A person or organization that supports (by allocating facilities, staff, or other resources) a project, program, meeting, event, data objects, material culture objects, or other entities capable of support.',  'deu': 'Eine Person oder Organisation, die ein Projekt, ein Programm, ein Treffen, eine Veranstaltung, Datenobjekte, materielle Kulturgüter oder andere unterstützungsfähige Einheiten unterstützt (durch Bereitstellung von Einrichtungen, Personal oder anderen Ressourcen).' } },
      { '@id': 'role:srv', 'skos:prefLabel': { 'eng': 'Surveyor', 'deu': 'Landvermesser*in', 'ita': 'Surveyor' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a cartographic resource by providing measurements or dimensional relationships for the geographic area represented.',  'deu': 'Eine Person, Familie oder Organisation, die einen Beitrag zu einer kartografischen Ressource leistet, indem sie Maße oder Maßverhältnisse für das dargestellte geografische Gebiet bereitstellt.' } },
      { '@id': 'role:tch', 'skos:prefLabel': { 'eng': 'Teacher', 'deu': 'Lehrer*in', 'ita': 'Teacher' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by giving instruction or providing a demonstration.',  'deu': 'Ein*e Darsteller*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie Anweisungen gibt oder eine Demonstration anbietet.' } },
      { '@id': 'role:tcd', 'skos:prefLabel': { 'eng': 'Technical director', 'deu': 'Technische/r Direktor*in', 'ita': 'Technical director' }, 'skos:definition': {  'eng': 'A person who is ultimately in charge of scenery, props, lights and sound for a production.',  'deu': 'Eine Person, die letztendlich für Bühnenbild, Requisiten, Licht und Ton bei einer Produktion verantwortlich ist.' } },
      { '@id': 'role:technicalinspector', 'skos:prefLabel': { 'eng': 'Technical Inspector', 'deu': 'Technische/r Prüfer*in', 'ita': 'Ispettore tecnico' }, 'skos:definition': { 'eng': 'A person or organisation who has checked the metadata of an object after it has been uploaded to the repository.', 'deu': 'Eine Person oder Organisation, die die Metadaten eines Objekts nach dessen Upload ins Repositorium überprüft hat.' } },
      { '@id': 'role:technicaltranslator', 'skos:prefLabel': { 'eng': 'Technical Translator', 'deu': 'Technische/r Übersetzer*in', 'ita': 'Traduttore Tecnico' }, 'skos:definition': { 'eng': 'A person or organisation who is responsible for archiving and publishing a digital object in the repository.', 'deu': 'Eine Person oder Organisation, die für die Archivierung und Veröffentlichung eines digitalen Objekts im Repositorium zuständig ist.' } },
      { '@id': 'role:tld', 'skos:prefLabel': { 'eng': 'Television director', 'deu': 'Fernsehintendant*in', 'ita': 'Television director' }, 'skos:definition': {  'eng': 'A director responsible for the general management and supervision of a television program.',  'deu': 'Eine Regisseur*in, der bzw. die für die allgemeine Verwaltung und Überwachung eines Fernsehprogramms verantwortlich ist.' } },
      { '@id': 'role:tlp', 'skos:prefLabel': { 'eng': 'Television producer', 'deu': 'Fernsehproduzent*in', 'ita': 'Television producer' }, 'skos:definition': {  'eng': 'A producer responsible for most of the business aspects of a television program.',  'deu': 'Eine Produzent*in, der bzw. die für die meisten geschäftlichen Aspekte eines Fernsehprogramms verantwortlich ist.' } },
      { '@id': 'role:textprocessor', 'skos:prefLabel': { 'eng': 'Text Processor', 'deu': 'Textbearbeiter*in', 'ita': 'Estensore del testo' }, 'skos:definition': { 'eng': 'A person or organisation responsible for processing text in a document.', 'deu': 'Eine Person oder Organisation, die für die Bearbeitung von Text in einem Dokument verantwortlich ist.' } },
      { '@id': 'role:ths', 'skos:prefLabel': { 'eng': 'Thesis advisor', 'deu': 'Dissertationsbetreuer*in', 'ita': 'Relatore' }, 'skos:definition': {  'eng': 'A person under whose supervision a degree candidate develops and presents a thesis, mémoire, or text of a dissertation.',  'deu': 'Eine Person, unter deren Aufsicht ein*e Kandidat*in eine Dissertation, ein Mémoire oder einen Dissertationstext erarbeitet und vorlegt.' } },
      { '@id': 'role:trc', 'skos:prefLabel': { 'eng': 'Transcriber', 'deu': 'Transkriptor*in von Noten', 'ita': 'Transcriber' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by changing it from one system of notation to another. For a work transcribed for a different instrument or performing group, see Arranger [arr]. For makers of pen-facsimiles, use Facsimilist [fac].',  'deu': 'Eine Person, Familie oder Organisation, die zu einer Ressource beiträgt, indem sie sie von einem Notationssystem in ein anderes umwandelt. Für ein Werk, das für ein anderes Instrument oder eine andere Ausführungsgruppe transkribiert wurde, siehe Arrangeur*in. Für Hersteller*innen von Stift-Faksimiles verwenden Sie Ersteller*in des Faksimile.' } },
      { '@id': 'role:trl', 'skos:prefLabel': { 'eng': 'Translator', 'deu': 'Übersetzer*in', 'ita': 'Traduttore' }, 'skos:definition': {  'eng': 'A person or organization who renders a text from one language into another, or from an older form of a language into the modern form.',  'deu': 'Eine Person oder Organisation, die einen Text von einer Sprache in eine andere oder von einer älteren Form einer Sprache in die moderne Form überträgt.' } },
      { '@id': 'role:tyd', 'skos:prefLabel': { 'eng': 'Type designer', 'deu': 'Schriftdesigner*in / Schriftentwerfer*in', 'ita': 'Type designer' }, 'skos:definition': {  'eng': 'A person or organization who designs the type face used in a particular item.',  'deu': 'Eine Person oder Organisation, die das für einen bestimmten Artikel verwendete Schriftbild entwirft.' } },
      { '@id': 'role:tyg', 'skos:prefLabel': { 'eng': 'Typographer', 'deu': 'Typograph*in', 'ita': 'Tipografo' }, 'skos:definition': {  'eng': 'A person or organization primarily responsible for choice and arrangement of type used in an item. If the typographer is also responsible for other aspects of the graphic design of a book (e.g., Book designer [bkd]), codes for both functions may be needed.',  'deu': 'Eine Person oder Organisation, die in erster Linie für die Auswahl und Anordnung der in einem Artikel verwendeten Schrift verantwortlich ist. Wenn der bzw. die Typograf*in auch für andere Aspekte der grafischen Gestaltung eines Buches verantwortlich ist (z. B. Buchgestalter*in), können Codes für beide Funktionen erforderlich sein.' } },
      { '@id': 'role:uploader', 'skos:prefLabel': { 'eng': 'Uploader', 'deu': 'Uploader', 'ita': 'Uploader' }, 'skos:definition': { 'eng': 'A person or organisation responsible for uploading a digital object into the repository.', 'deu': 'Eine Person oder Organisation, die für das Hochladen eines digitalen Objekts in das Repositorium verantwortlich ist.' } },
      { '@id': 'role:vdg', 'skos:prefLabel': { 'eng': 'Videographer', 'deu': 'Videofilmer*in', 'ita': 'Videografo' }, 'skos:definition': {  'eng': 'A person in charge of a video production, e.g. the video recording of a stage production as opposed to a commercial motion picture. The videographer may be the camera operator or may supervise one or more camera operators. Do not confuse with cinematographer.',  'deu': 'Eine Person, die für eine Videoproduktion verantwortlich ist, z. B. für die Videoaufzeichnung einer Bühnenproduktion im Gegensatz zu einem kommerziellen Kinofilm. Der bzw. die Videofilmer*in kann der Kameramann bzw. die Kamerafrau sein oder einen oder mehrere Kameramänner bzw. Kamerafrauen beaufsichtigen. Nicht zu verwechseln mit dem Kameramann bzw. der Kamerafrau.' } },
      { '@id': 'role:vac', 'skos:prefLabel': { 'eng': 'Voice actor', 'deu': 'Synchron-, Sprecher*in', 'ita': 'Voice actor' }, 'skos:definition': {  'eng': 'An actor contributing to a resource by providing the voice for characters in radio and audio productions and for animated characters in moving image works, as well as by providing voice overs in radio and television commercials, dubbed resources, etc.',  'deu': 'Ein*e Schauspieler*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. sie die Stimme für Charaktere in Radio- und Audioproduktionen und für animierte Charaktere in Bewegtbildwerken zur Verfügung stellt, sowie durch die Bereitstellung von Voice-Overs in Radio- und Fernsehwerbung, synchronisierten Ressourcen usw.' } },
      { '@id': 'role:wit', 'skos:prefLabel': { 'eng': 'Witness', 'deu': 'Zeug*in', 'ita': 'Witness' }, 'skos:definition': {  'eng': 'Use for a person who verifies the truthfulness of an event or action.',  'deu': 'Verwendung für eine Person, die den Wahrheitsgehalt eines Ereignisses oder einer Handlung prüft.' } },
      { '@id': 'role:wde', 'skos:prefLabel': { 'eng': 'Wood-engraver', 'deu': 'Holzstecher*in', 'ita': 'Xilografo' }, 'skos:definition': {  'eng': 'A person or organization who makes prints by cutting the image in relief on the end-grain of a wood block.',  'deu': 'Eine Person oder Organisation, die Drucke herstellt, indem sie das Bild als Relief in die Hirnholzmaserung eines Holzblocks schneidet.' } },
      { '@id': 'role:wdc', 'skos:prefLabel': { 'eng': 'Woodcutter', 'deu': 'Holzschneider*in', 'ita': 'Woodcutter' }, 'skos:definition': {  'eng': 'A person or organization who makes prints by cutting the image in relief on the plank side of a wood block.',  'deu': 'Eine Person oder Organisation, die Drucke herstellt, indem sie das Bild als Relief auf die Plankseite eines Holzblocks schneidet.' } },
      { '@id': 'role:wam', 'skos:prefLabel': { 'eng': 'Writer of accompanying material', 'deu': 'Autor*in von Begleitmaterial', 'ita': 'Autore del materiale allegato' }, 'skos:definition': {  'eng': 'A person or organization who writes significant material which accompanies a sound recording or other audiovisual material.',  'deu': 'Eine Person oder Organisation, die aussagekräftiges Begleitmaterial zu einer Tonaufnahme oder einem anderen audiovisuellen Material schreibt.' } },
      { '@id': 'role:wac', 'skos:prefLabel': { 'eng': 'Writer of added commentary', 'deu': 'Autor*in von zusätzlichen Kommentaren', 'ita': 'Writer of added commentary' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to an expression of a work by providing an interpretation or critical explanation of the original work.',  'deu': 'Eine Person, Familie oder Organisation, die zu einem Werk beiträgt, indem sie eine Interpretation oder kritische Erläuterung des Originalwerkes liefert.' } },
      { '@id': 'role:wal', 'skos:prefLabel': { 'eng': 'Writer of added lyrics', 'deu': 'Autor*in von zusätzlichen Texten zu musikalischen Werken ', 'ita': 'Writer of added lyrics' }, 'skos:definition': {  'eng': 'A writer of words added to an expression of a musical work. For lyric writing in collaboration with a composer to form an original work, see lyricist.',  'deu': 'Ein*e Textdichter*in, der bzw. die einen Ausdruck eines Musikwerks ergänzt. Für das Verfassen von Texten in Zusammenarbeit mit einem Komponisten bzw. einer Komponistin, um ein Originalwerk zu schaffen, siehe Lyriker*in.' } },
      { '@id': 'role:wat', 'skos:prefLabel': { 'eng': 'Writer of added text', 'deu': 'Autor*in von zusätzlichen Texten zu nichtextlichen Werken', 'ita': 'Writer of added text' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a non-textual resource by providing text for the non-textual work (e.g., writing captions for photographs, descriptions of maps).',  'deu': 'Eine Person, Familie oder Organisation, die zu einer nicht-textuellen Ressource beiträgt, indem sie Text für das nicht-textuelle Werk bereitstellt (z. B. das Schreiben von Bildunterschriften für Fotos, Beschreibungen von Karten).' } },
      { '@id': 'role:win', 'skos:prefLabel': { 'eng': 'Writer of introduction', 'deu': 'Autor*in der Einführung', 'ita': 'Writer of introduction' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by providing an introduction to the original work.',  'deu': 'Eine Person, Familie oder Organisation, die einen Beitrag zu einer Ressource leistet, indem sie eine Einführung in das Originalwerk liefert.' } },
      { '@id': 'role:wpr', 'skos:prefLabel': { 'eng': 'Writer of preface', 'deu': 'Autor*in des Vorwortes', 'ita': 'Writer of preface' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by providing a preface to the original work.',  'deu': 'Eine Person, Familie oder Organisation, die einen Beitrag zu einer Ressource leistet, indem sie ein Vorwort zum Originalwerk liefert.' } },
      { '@id': 'role:wst', 'skos:prefLabel': { 'eng': 'Writer of supplementary textual content', 'deu': 'Autor*in von ergänzendem Textinhalt', 'ita': 'Writer of supplementary textual content' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by providing supplementary textual content (e.g., an introduction, a preface) to the original work.',  'deu': 'Eine Person, Familie oder Organisation, die einen Beitrag zu einer Ressource leistet, indem sie ergänzende Textinhalte (z. B. eine Einleitung, ein Vorwort) zum Originalwerk bereitstellt.' } }
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
      { '@id': 'role:oth', 'skos:prefLabel': { 'eng': 'Other', 'deu': 'Andere', 'ita': 'Altro' }, 'skos:definition': { 'eng': 'A role that has no equivalent in the MARC list.', 'deu': 'Eine Rolle, die keine Entsprechung in der MARC-Liste hat.' } },
      { '@id': 'role:adp', 'skos:prefLabel': { 'eng': 'Adapter', 'deu': 'Bearbeiter*in', 'ita': 'Adattatore' }, 'skos:definition': {  'eng': 'A person or organization who 1) reworks a musical composition, usually for a different medium, or 2) rewrites novels or stories for motion pictures or other audiovisual medium.',  'deu': 'Eine Person oder Organisation, die 1) eine Musikkomposition überarbeitet, in der Regel für ein anderes Medium, oder 2) Romane oder Geschichten für Filme oder andere audiovisuelle Medien umschreibt.' } },
      { '@id': 'role:arc', 'skos:prefLabel': { 'eng': 'Architect', 'deu': 'Architekt*in', 'ita': 'Architetto' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating an architectural design, including a pictorial representation intended to show how a building, etc., will look when completed. It also oversees the construction of structures.',  'deu': 'Eine Person, eine Familie oder eine Organisation, die für die Erstellung eines architektonischen Entwurfs verantwortlich ist, einschließlich einer bildlichen Darstellung, die zeigen soll, wie ein Gebäude usw. nach seiner Fertigstellung aussehen wird. Sie beaufsichtigt auch den Bau von Bauwerken.' } },
      { '@id': 'role:art', 'skos:prefLabel': { 'eng': 'Artist', 'deu': 'Künstler*in', 'ita': 'Artista' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a work by conceiving, and implementing, an original graphic design, drawing, painting, etc. For book illustrators, prefer Illustrator [ill].',  'deu': 'Eine Person, Familie oder Organisation, die für die Schaffung eines Werks verantwortlich ist, indem sie ein originelles grafisches Design, eine Zeichnung, ein Gemälde usw. entwirft und umsetzt. Für Buchillustrator*innen ist Illustrator*in [ill] vorzuziehen.' } },
      { '@id': 'role:att', 'skos:prefLabel': { 'eng': 'Attributed name', 'deu': 'Zugeschriebene/r Autor*in', 'ita': 'Nome attribuito' }, 'skos:definition': {  'eng': 'An author, artist, etc., relating him/her to a resource for which there is or once was substantial authority for designating that person as author, creator, etc. of the work.',  'deu': 'Ein*e Autor*in, Künstler*in usw., der bzw. die mit einer Quelle in Verbindung gebracht wird, für die es eine wesentliche Berechtigung gibt oder gab, diese Person als Autor*in, Schöpfer*in usw. des Werks zu bezeichnen.' } },
      { '@id': 'role:aut', 'skos:prefLabel': { 'eng': 'Author', 'deu': 'Autor*in', 'ita': 'Author' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a work that is primarily textual in content, regardless of media type (e.g., printed text, spoken word, electronic text, tactile text) or genre (e.g., poems, novels, screenplays, blogs). Use also for persons, etc., creating a new work by paraphrasing, rewriting, or adapting works by another creator such that the modification has substantially changed the nature and content of the original or changed the medium of expression.',  'deu': 'Eine Person, Familie oder Organisation, die für die Schaffung eines Werks verantwortlich ist, das hauptsächlich textlichen Inhalt hat, unabhängig von der Art des Mediums (z. B. gedruckter Text, gesprochener Text, elektronischer Text, taktiler Text) oder dem Genre (z. B. Gedichte, Romane, Drehbücher, Blogs). Verwenden Sie den Begriff auch für Personen usw., die ein neues Werk schaffen, indem sie Werke eines anderen Schöpfers bzw. einer anderen Schöpferin paraphrasieren, umschreiben oder adaptieren, so dass die Modifikation die Art und den Inhalt des Originals wesentlich verändert oder das Ausdrucksmedium verändert hat.' } },
      { '@id': 'role:chr', 'skos:prefLabel': { 'eng': 'Choreographer', 'deu': 'Choreograph*in', 'ita': 'Coreografo' }, 'skos:definition': {  'eng': 'A person responsible for creating or contributing to a work of movement.',  'deu': 'Eine Person, die für die Schaffung eines Werks der Bewegung verantwortlich ist oder zu diesem beiträgt.' } },
      { '@id': 'role:col', 'skos:prefLabel': { 'eng': 'Collector', 'deu': 'Sammler*in', 'ita': 'Collezionista' }, 'skos:definition': {  'eng': 'A curator who brings together items from various sources that are then arranged, described, and cataloged as a collection. A collector is neither the creator of the material nor a person to whom manuscripts in the collection may have been addressed.',  'deu': 'Ein*e Kurator*in, der bzw. die Objekte aus verschiedenen Quellen zusammenführt, die dann als Sammlung geordnet, beschrieben und katalogisiert werden. Ein*e Sammler*in ist weder der bzw. die Schöpfer*in des Materials noch eine Person, an die die Manuskripte in der Sammlung möglicherweise adressiert waren.' } },
      { '@id': 'role:cmp', 'skos:prefLabel': { 'eng': 'Composer', 'deu': 'Komponist*in', 'ita': 'Compositore' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating or contributing to a musical resource by adding music to a work that originally lacked it or supplements it.',  'deu': 'Eine Person, Familie oder Organisation, die dafür verantwortlich ist, eine musikalische Ressource zu schaffen oder zu ihr beizutragen, indem sie Musik zu einem Werk hinzufügt, in dem sie ursprünglich fehlte oder die es ergänzt.' } },
      { '@id': 'role:cnd', 'skos:prefLabel': { 'eng': 'Conductor', 'deu': 'Dirigent*in', 'ita': 'Direttore d’orchestra' }, 'skos:definition': {  'eng': 'A performer contributing to a musical resource by leading a performing group (orchestra, chorus, opera, etc.) in a musical or dramatic presentation, etc.',  'deu': 'Ein*e Künstler*in, der bzw. die zu einer musikalischen Ressource beiträgt, indem er bzw. sie eine ausführende Gruppe (Orchester, Chor, Oper usw.) bei einer musikalischen oder dramatischen Darbietung usw. leitet.' } },
      { '@id': 'role:con', 'skos:prefLabel': { 'eng': 'Conservator', 'deu': 'Konservator*in', 'ita': 'Conservator' }, 'skos:definition': {  'eng': 'A person or organization responsible for documenting, preserving, or treating printed or manuscript material, works of art, artifacts, or other media.',  'deu': 'Eine Person oder Organisation, die für die Dokumentation, Bewahrung oder Bearbeitung von gedrucktem oder handschriftlichem Material, Kunstwerken, Artefakten oder anderen Medien verantwortlich ist.' } },
      { '@id': 'role:dnc', 'skos:prefLabel': { 'eng': 'Dancer', 'deu': 'Tänzer*in', 'ita': 'Dancer' }, 'skos:definition': {  'eng': 'A performer who dances in a musical, dramatic, etc., presentation.',  'deu': 'Ein*e Darsteller*in, der bzw. die in einer musikalischen, dramatischen usw. Präsentation tanzt.' } },
      { '@id': 'role:dtc', 'skos:prefLabel': { 'eng': 'Data contributor', 'deu': 'Datenlieferant*in', 'ita': 'Data contributor' }, 'skos:definition': {  'eng': 'A person or organization that submits data for inclusion in a database or other collection of data.',  'deu': 'Eine Person oder Organisation, die Daten zur Aufnahme in eine Datenbank oder eine andere Datensammlung einreicht.' } },
      { '@id': 'role:dgg', 'skos:prefLabel': { 'eng': 'Degree granting institution', 'deu': 'Verleihende Institution des akademischen Abschlusses', 'ita': 'Istituzione che rilascia il titolo accademico' }, 'skos:definition': {  'eng': 'A organization granting an academic degree.',  'deu': 'Eine Organisation, die einen akademischen Grad verleiht.' } },
      { '@id': 'role:dgs', 'skos:prefLabel': { 'eng': 'Degree supervisor', 'deu': 'Betreuer*in der Hochschulschrift', 'ita': 'Degree supervisor' }, 'skos:definition': {  'eng': 'A person overseeing a higher level academic degree.',  'deu': 'Eine Person, die für einen höheren akademischen Grad verantwortlich ist.' } },
      { '@id': 'role:dsr', 'skos:prefLabel': { 'eng': 'Designer', 'deu': 'Designer*in', 'ita': 'Designer' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a design for an object.',  'deu': 'Eine Person, Familie oder Organisation, die für den Entwurf eines Objekts verantwortlich ist.' } },
      { '@id': 'role:digitiser', 'skos:prefLabel': { 'eng': 'Digitiser', 'deu': 'Digitalisierer*in', 'ita': 'Autore della digitalizzazione' }, 'skos:definition': { 'eng': 'A person or organisation responsible for converting physical materials into digital format.', 'deu': 'Eine Person oder Organisation, die für die Umwandlung von physischem Material in ein digitales Format verantwortlich ist.' } },
      { '@id': 'role:dis', 'skos:prefLabel': { 'eng': 'Dissertant', 'deu': 'Verfasser*in der Hochschulschrift', 'ita': 'Tesista' }, 'skos:definition': {  'eng': 'A person who presents a thesis for a university or higher-level educational degree.',  'deu': 'Eine Person, die eine Abschlussarbeit für eine Universität oder einen höheren Bildungsabschluss vorlegt.' } },
      { '@id': 'role:edt', 'skos:prefLabel': { 'eng': 'Editor', 'deu': 'Herausgeber*in', 'ita': 'Curatore' }, 'skos:definition': {  'eng': 'A person, family, or organization contributing to a resource by revising or elucidating the content, e.g., adding an introduction, notes, or other critical matter. An editor may also prepare a resource for production, publication, or distribution. For major revisions, adaptations, etc., that substantially change the nature and content of the original work, resulting in a new work, see author.',  'deu': 'Eine Person, Familie oder Organisation, die zu einer Ressource beiträgt, indem sie den Inhalt überarbeitet oder erläutert, z. B. durch Hinzufügen einer Einleitung, von Anmerkungen oder anderen kritischen Informationen. Ein*e Herausgeber*in kann auch eine Ressource für die Produktion, Veröffentlichung oder Verteilung vorbereiten. Für größere Überarbeitungen, Anpassungen usw., die die Art und den Inhalt des ursprünglichen Werks wesentlich verändern und zu einem neuen Werk führen, siehe Autor*in.' } },
      { '@id': 'role:fmd', 'skos:prefLabel': { 'eng': 'Film director', 'deu': 'Filmregisseur*in', 'ita': 'Film director' }, 'skos:definition': {  'eng': 'A director responsible for the general management and supervision of a filmed performance.',  'deu': 'Ein*e Regisseur*in, der bzw. die für die allgemeine Verwaltung und Überwachung einer Filmvorführung verantwortlich ist.' } },
      { '@id': 'role:fon', 'skos:prefLabel': { 'eng': 'Founder', 'deu': 'Gründer*in', 'ita': 'Founder' }, 'skos:definition': { 'eng': 'A person or organisation who played a significant role in initiating, establishing, or creating a particular entity, project, or endeavor.', 'deu': 'Eine Person oder Organisation, die eine bedeutende Rolle bei der Initiierung, Gründung oder Schaffung einer bestimmten Entität, eines Projekts oder einer Unternehmung gespielt hat.' } },
      { '@id': 'role:fnd', 'skos:prefLabel': { 'eng': 'Funder', 'deu': 'Geldgeber*in', 'ita': 'Funder' }, 'skos:definition': {  'eng': 'A person or organization that furnished financial support for the production of the work.',  'deu': 'Eine Person oder Organisation, die die Produktion des Werks finanziell unterstützt hat.' } },
      { '@id': 'role:graphicdesigner', 'skos:prefLabel': { 'eng': 'Graphic Designer', 'deu': 'Grafikdesigner*in', 'ita': 'Grafico' }, 'skos:definition': { 'eng': 'A person or organisation responsible for creating visual concepts, graphics, and layouts.', 'deu': 'Eine Person oder Organisation, die für das Erstellen visueller Konzepte, Grafiken und Layouts zuständig ist.' } },
      { '@id': 'role:interpreter', 'skos:prefLabel': { 'eng': 'Interpreter', 'deu': 'Dolmetscher*in', 'ita': 'Interprete' }, 'skos:definition': { 'eng': 'A person who translates spoken or signed language from one language to another (in real-time settings or for recorded or delayed communication).', 'deu': 'Eine Person, die gesprochene oder gebärdete Sprache von einer Sprache in eine andere übersetzt (in Echtzeit oder für aufgezeichnete oder verzögerte Kommunikation).' } },
      { '@id': 'role:ive', 'skos:prefLabel': { 'eng': 'Interviewee', 'deu': 'Interviewpartner*in', 'ita': 'Intervistato' }, 'skos:definition': {  'eng': 'A person, family or organization responsible for creating or contributing to a resource by responding to an interviewer, usually a reporter, pollster, or some other information gathering agent.',  'deu': 'Eine Person, Familie oder Organisation, die dafür verantwortlich ist, eine Ressource zu erstellen oder zu ihr beizutragen, indem sie einem Interviewer bzw. einer Interviewerin, in der Regel einem Reporter bzw. einer Reporterin, einem Meinungsforscher bzw. einer Meinungsforscherin oder einem anderen Informationsbeschaffer bzw. einer anderen Informationsbeschafferin, antwortet.' } },
      { '@id': 'role:ivr', 'skos:prefLabel': { 'eng': 'Interviewer', 'deu': 'Interviewer*in', 'ita': 'Intervistatore' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating or contributing to a resource by acting as an interviewer, reporter, pollster, or some other information gathering agent.',  'deu': 'Eine Person, Familie oder Organisation, die für die Erstellung oder den Beitrag zu einer Ressource verantwortlich ist, indem sie als Interviewer*in, Reporter*in, Meinungsforscher*in oder sonstige*r Informationsbeschaffer*in fungiert.' } },
      { '@id': 'role:keeperoftheoriginal', 'skos:prefLabel': { 'eng': 'Keeper of the original', 'deu': 'Aufbewahrer*in des Originals', 'ita': 'Affidatario dell\'originale' }, 'skos:definition': { 'eng': 'A person or organisation who is entrusted with the custody of the original physical material from which a digital copy has been made.', 'deu': 'Eine Person oder Organisation, die mit der Aufbewahrung des physischen Originalmaterials betraut ist, von dem eine digitale Kopien erstellt wurde.' } },
      { '@id': 'role:led', 'skos:prefLabel': { 'eng': 'Lead', 'deu': 'Leitung', 'ita': 'Lead' }, 'skos:definition': {  'eng': 'A person or organization that takes primary responsibility for a particular activity or endeavor. May be combined with another relator term or code to show the greater importance this person or organization has regarding that particular role. If more than one relator is assigned to a heading, use the Lead relator only if it applies to all the relators.',  'deu': 'Eine Person oder Organisation, die die Hauptverantwortung für eine bestimmte Aktivität oder ein bestimmtes Unterfangen trägt. Kann mit einem anderen Beauftragtenbegriff oder -code kombiniert werden, um die größere Bedeutung dieser Person oder Organisation in Bezug auf diese spezielle Rolle zu verdeutlichen. Wenn einer Rubrik mehr als ein Verantwortlicher bzw. eine Verantwortliche zugeordnet ist, verwenden Sie den Begriff "Hauptverantwortliche*r" nur, wenn er auf alle Verantwortlichen zutrifft.' } },
      { '@id': 'role:mfr', 'skos:prefLabel': { 'eng': 'Manufacturer', 'deu': 'Hersteller*in', 'ita': 'Manufacturer' }, 'skos:definition': {  'eng': 'A person or organization responsible for printing, duplicating, casting, etc. a resource.',  'deu': 'Eine Person oder Organisation, die für das Drucken, Vervielfältigen, Gießen usw. einer Ressource verantwortlich ist.' } },
      { '@id': 'role:emt', 'skos:prefLabel': { 'eng': 'Metal-engraver', 'deu': 'Metallstecher*in', 'ita': 'Calcografo' }, 'skos:definition': {  'eng': 'An engraver responsible for decorations, illustrations, letters, etc. cut on a metal surface for printing or decoration.',  'deu': 'Ein Graveur, der für Verzierungen, Illustrationen, Buchstaben usw. verantwortlich ist, die zu Druck- oder Dekorationszwecken in eine Metalloberfläche geschnitten werden.' } },
      { '@id': 'role:nrt', 'skos:prefLabel': { 'eng': 'Narrator', 'deu': 'Erzähler*in', 'ita': 'Narrator' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by reading or speaking in order to give an account of an act, occurrence, course of events, etc.',  'deu': 'Ein Darsteller, der zu einer Ressource beiträgt, indem er etwas vorliest oder spricht, um einen Bericht über eine Handlung, ein Ereignis, einen Ablauf usw. zu geben.' } },
      { '@id': 'role:pedagogicexpert', 'skos:prefLabel': { 'eng': 'Pedagogic Expert', 'deu': 'Pädagogische/r Expert*in', 'ita': 'Esperto pedagogico' }, 'skos:definition': { 'eng': 'A person or organisation who contributes specialized knowledge and expertise in pedagogy to scientific work.', 'deu': 'Eine Person oder Organisation, die Fachwissen und pädagogische Kompetenz in die wissenschaftliche Arbeit einbringt.' } },
      { '@id': 'role:pht', 'skos:prefLabel': { 'eng': 'Photographer', 'deu': 'Fotograf*in', 'ita': 'Fotografo' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for creating a photographic work.',  'deu': 'Eine Person, Familie oder Organisation, die für die Erstellung eines fotografischen Werks verantwortlich ist.' } },
      { '@id': 'role:pro', 'skos:prefLabel': { 'eng': 'Producer', 'deu': 'Produzent*in', 'ita': 'Produttore' }, 'skos:definition': {  'eng': 'A person, family, or organization responsible for most of the business aspects of a production for screen, audio recording, television, webcast, etc. The producer is generally responsible for fund raising, managing the production, hiring key personnel, arranging for distributors, etc.',  'deu': 'Eine Person, Familie oder Organisation, die für die meisten geschäftlichen Aspekte einer Produktion für Leinwand, Tonaufnahme, Fernsehen, Webcast usw. verantwortlich ist. Der Produzent bzw. die Produzentin ist in der Regel für die Mittelbeschaffung, das Management der Produktion, die Einstellung von Schlüsselpersonal, die Vermittlung von Verleiher*innen usw. verantwortlich.' } },
      { '@id': 'role:res', 'skos:prefLabel': { 'eng': 'Researcher', 'deu': 'Forscher*in', 'ita': 'Ricercatore' }, 'skos:definition': {  'eng': 'A person or organization responsible for performing research.',  'deu': 'Eine Person oder Organisation, die für die Durchführung von Forschungsarbeiten verantwortlich ist.' } },
      { '@id': 'role:spk', 'skos:prefLabel': { 'eng': 'Speaker / Lecturer', 'deu': 'Sprecher*in / Vortragende/r', 'ita': 'Speaker' }, 'skos:definition': {  'eng': 'A performer contributing to a resource by speaking words, such as a lecture, speech, etc.',  'deu': 'Ein*e Darsteller*in, der bzw. die zu einer Ressource beiträgt, indem er bzw. die Worte spricht, z. B. bei einem Vortrag, einer Rede usw.' } },
      { '@id': 'role:ths', 'skos:prefLabel': { 'eng': 'Thesis advisor', 'deu': 'Dissertationsbetreuer*in', 'ita': 'Relatore' }, 'skos:definition': {  'eng': 'A person under whose supervision a degree candidate develops and presents a thesis, mémoire, or text of a dissertation.',  'deu': 'Eine Person, unter deren Aufsicht ein*e Kandidat*in eine Dissertation, ein Mémoire oder einen Dissertationstext erarbeitet und vorlegt.' } },
      { '@id': 'role:trl', 'skos:prefLabel': { 'eng': 'Translator', 'deu': 'Übersetzer*in', 'ita': 'Traduttore' }, 'skos:definition': {  'eng': 'A person or organization who renders a text from one language into another, or from an older form of a language into the modern form.',  'deu': 'Eine Person oder Organisation, die einen Text von einer Sprache in eine andere oder von einer älteren Form einer Sprache in die moderne Form überträgt.' } },
      { '@id': 'role:uploader', 'skos:prefLabel': { 'eng': 'Uploader', 'deu': 'Uploader', 'ita': 'Uploader' }, 'skos:definition': { 'eng': 'A person or organisation responsible for uploading a digital object into the repository.', 'deu': 'Eine Person oder Organisation, die für das Hochladen eines digitalen Objekts in das Repositorium verantwortlich ist.' } }
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
  'accessibilityControl': {
    terms: [
      { '@id': 'fullKeyboardControl', 'skos:prefLabel': { 'eng': 'fullKeyboardControl', 'deu': 'Keyboardsteuerung' }, 'skos:definition': { 'eng': 'Users can fully control the resource through keyboard input.', 'deu': 'Die Benutzer:innen können die Ressource vollständig über Tastatureingaben steuern.' } },
      { '@id': 'fullMouseControl', 'skos:prefLabel': { 'eng': 'fullMouseControl', 'deu': 'Maussteuerung' }, 'skos:definition': { 'eng': 'Users can fully control the resource through mouse input.', 'deu': 'Die Benutzer:innen können die Ressource vollständig durch Mauseingabe steuern.' } },
      { '@id': 'fullSwitchControl', 'skos:prefLabel': { 'eng': 'fullSwitchControl', 'deu': 'Schaltersteuerung' }, 'skos:definition': { 'eng': 'Users can fully control the resource through switch input.', 'deu': 'Die Benutzer:innen können die Ressource durch Schaltereingabe vollständig steuern.' } },
      { '@id': 'fullTouchControl', 'skos:prefLabel': { 'eng': 'fullTouchControl', 'deu': 'Touch-Steuerung' }, 'skos:definition': { 'eng': 'Users can fully control the resource through touch input.', 'deu': 'Die Benutzer:innen können die Ressource vollständig durch Berührung steuern.' } },
      { '@id': 'fullVideoControl', 'skos:prefLabel': { 'eng': 'fullVideoControl', 'deu': 'Videosteuerung' }, 'skos:definition': { 'eng': 'Users can fully control the resource through video input.', 'deu': 'Users can fully control the resource through video input.' } },
      { '@id': 'fullVoiceControl', 'skos:prefLabel': { 'eng': 'fullVoiceControl', 'deu': 'Sprachsteuerung' }, 'skos:definition': { 'eng': 'Users can fully control the resource through voice input.', 'deu': 'Die Benutzer:innen können die Ressource vollständig durch Sprache steuern.' } },
      { '@id': 'none', 'skos:prefLabel': { 'eng': 'none', 'deu': 'Keine' }, 'skos:definition': { 'eng': 'Indicates that the resource does not contain any accessibility features. The none value must not be set with any other feature value.', 'deu': 'Die Ressource enthält keine Zugänglichkeitsmerkmale. Der Wert "Keine" darf nicht zusammen mit einem anderen Merkmalswert gesetzt werden.' } }
    ],
    loaded: true
  },
  'accessMode': {
    terms: [
      { '@id': 'auditory', 'skos:prefLabel': { 'eng': 'auditory', 'deu': 'Akustisch' }, 'skos:definition': { 'eng': 'Indicates that the resource contains information encoded in auditory form.', 'deu': 'Zeigt an, dass die Ressource in akustischer Form kodierte Informationen enthält.' } },
      { '@id': 'chartOnVisual', 'skos:prefLabel': { 'eng': 'chartOnVisual', 'deu': 'Tabelle visuell kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains charts encoded in visual form.', 'deu': 'Zeigt an, dass die Ressource Tabellen enthält, die in visueller Form kodiert sind.' } },
      { '@id': 'chemOnVisual', 'skos:prefLabel': { 'eng': 'chemOnVisual', 'deu': 'Chemische Gleichungen visuell kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains chemical equations encoded in visual form.', 'deu': 'Zeigt an, dass die Ressource in visueller Form kodierte chemische Gleichungen enthält.' } },
      { '@id': 'colorDependent', 'skos:prefLabel': { 'eng': 'colorDependent', 'deu': 'Farbwahrnehmung erforderlich' }, 'skos:definition': { 'eng': 'Indicates that the resource contains information encoded such that color perception is necessary.', 'deu': 'Zeigt an, dass die Ressource Informationen enthält, die so kodiert sind, dass eine Farbwahrnehmung erforderlich ist.' } },
      { '@id': 'diagramOnVisual', 'skos:prefLabel': { 'eng': 'diagramOnVisual', 'deu': 'Diagramm visuell kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains diagrams encoded in visual form.', 'deu': 'Zeigt an, dass die Ressource Diagramme enthält, die in visueller Form kodiert sind.' } },
      { '@id': 'mathOnVisual', 'skos:prefLabel': { 'eng': 'mathOnVisual', 'deu': 'Matehamtische Formeln visuell kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains mathematical notations encoded in visual form.', 'deu': 'Zeigt an, dass die Ressource in visueller Form kodierte mathematische Formeln enthält.' } },
      { '@id': 'musicOnVisual', 'skos:prefLabel': { 'eng': 'musicOnVisual', 'deu': 'Musikalische Notation visuell kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains musical notation encoded in visual form.', 'deu': 'Zeigt an, dass die Ressource in visueller Form kodierte musikalische Notation enthält.' } },
      { '@id': 'textOnVisual', 'skos:prefLabel': { 'eng': 'textOnVisual', 'deu': 'Text in visueller Form kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains text encoded in visual form.', 'deu': 'Zeigt an, dass die Ressource in visueller Form kodierten Text enthält.' } },
      { '@id': 'textual', 'skos:prefLabel': { 'eng': 'textual', 'deu': 'Informationen in Textform kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains information encoded in textual form.', 'deu': 'Zeigt an, dass die Ressource Informationen enthält, die in Textform kodiert sind.' } },
      { '@id': 'visual', 'skos:prefLabel': { 'eng': 'visual', 'deu': 'Informationen visuell kodiert' }, 'skos:definition': { 'eng': 'Indicates that the resource contains information encoded in visual form.', 'deu': 'Zeigt an, dass die Ressource in visueller Form kodierte Informationen enthält.' } },
      { '@id': 'none', 'skos:prefLabel': { 'eng': 'none', 'deu': 'Keine' }, 'skos:definition': { 'eng': 'Indicates that the resource does not contain any accessibility features. The none value must not be set with any other feature value.', 'deu': 'Die Ressource enthält keine Zugänglichkeitsmerkmale. Der Wert "Keine" darf nicht zusammen mit einem anderen Merkmalswert gesetzt werden.' } }
    ],
    loaded: true
  },
  'accessibilityHazard': {
    terms: [
      { '@id': 'flashing', 'skos:prefLabel': { 'eng': 'flashing', 'deu': 'Blinken' }, 'skos:definition': { 'eng': 'Indicates that the resource presents a flashing hazard for photosensitive persons.', 'deu': 'Zeigt an, dass die Ressource eine blinkende Gefahr für lichtempfindliche Personen darstellt.' } },
      { '@id': 'noFlashingHazard', 'skos:prefLabel': { 'eng': 'noFlashingHazard', 'deu': 'Keine Blinkgefahr' }, 'skos:definition': { 'eng': 'Indicates that the resource does not present a flashing hazard.', 'deu': 'Zeigt an, dass die Ressource keine blinkende Gefahr darstellt.' } },
      { '@id': 'motionSimulation', 'skos:prefLabel': { 'eng': 'motionSimulation', 'deu': 'Bewegungssimulation' }, 'skos:definition': { 'eng': 'Indicates that the resource contains instances of motion simulation that may affect some individuals. Some examples of motion simulation include video games with a first-person perspective and CSS-controlled backgrounds that move when a user scrolls a page.', 'deu': 'Zeigt an, dass die Ressource Instanzen der Bewegungssimulation enthält, die einige Personen betreffen können. Einige Beispiele für Bewegungssimulationen sind Videospiele mit Ego-Perspektive und CSS-gesteuerte Hintergründe, die sich bewegen, wenn ein Benutzer eine Seite scrollt.' } },
      { '@id': 'noMotionSimulationHazard', 'skos:prefLabel': { 'eng': 'noMotionSimulationHazard', 'deu': 'Keine Bewegungssimulation' }, 'skos:definition': { 'eng': 'Indicates that the resource does not contain instances of motion simulation.', 'deu': 'Zeigt an, dass die Ressource keine Instanzen der Bewegungssimulation enthält.' } },
      { '@id': 'sound', 'skos:prefLabel': { 'eng': 'sound', 'deu': 'Geräusche' }, 'skos:definition': { 'eng': 'Indicates that the resource contains auditory sounds that may affect some individuals.', 'deu': 'Zeigt an, dass die Ressource Geräusche enthält, die einige Personen beeinträchtigen können.' } },
      { '@id': 'noSoundHazard', 'skos:prefLabel': { 'eng': 'noSoundHazard', 'deu': 'Keine Geräusche' }, 'skos:definition': { 'eng': 'Indicates that the resource does not contain auditory hazards.', 'deu': 'Zeigt an, dass die Ressource keine Gefahren für das Gehör enthält.' } },
      { '@id': 'none', 'skos:prefLabel': { 'eng': 'none', 'deu': 'Keine' }, 'skos:definition': { 'eng': 'Indicates that the resource does not contain any accessibility features. The none value must not be set with any other feature value.', 'deu': 'Die Ressource enthält keine Zugänglichkeitsmerkmale. Der Wert "Keine" darf nicht zusammen mit einem anderen Merkmalswert gesetzt werden.' } }
    ],
    loaded: true
  },
  'accessibilityFeature': {
    terms: [
      { '@id': 'annotations', 'skos:prefLabel': { 'eng': 'annotations', 'deu': 'Anmerkungen' }, 'skos:definition': { 'eng': 'The resource includes annotations from the author, instructor and/or others.', 'deu': 'Die Ressource enthält Anmerkungen des/der Autors/Autorin, des Ausbilders und/oder anderer Personen.' } },
      { '@id': 'ARIA', 'skos:prefLabel': { 'eng': 'ARIA', 'deu': 'ARIA' }, 'skos:definition': { 'eng': 'Indicates the resource includes ARIA roles to organize and improve the structure and navigation.', 'deu': 'Zeigt an, dass die Ressource ARIA-Rollen zur Organisation und Verbesserung der Struktur und Navigation enthält.' } },
      { '@id': 'bookmarks', 'skos:prefLabel': { 'eng': 'bookmarks', 'deu': 'Lesezeichen' }, 'skos:definition': { 'eng': 'The work includes bookmarks to facilitate navigation to key points.', 'deu': 'Das Werk enthält Lesezeichen, um die Navigation zu wichtigen Punkten zu erleichtern.' } },
      { '@id': 'index', 'skos:prefLabel': { 'eng': 'index', 'deu': 'Index' }, 'skos:definition': { 'eng': 'The resource includes an index to the content.', 'deu': 'Die Ressource enthält einen Index für den Inhalt.' } },
      { '@id': 'pageBreakMarkers', 'skos:prefLabel': { 'eng': 'pageBreakMarkers', 'deu': 'Seitenumbruch ' }, 'skos:definition': { 'eng': 'The resource includes static page markers, such as those identified by the doc-pagebreak role [DPUB-ARIA-1.0]. This value is most commonly used with ebooks for which there is a statically paginated equivalent, such as a print edition, but it is not required that the page markers correspond to another work. The markers may exist solely to facilitate navigation in purely digital works.', 'deu': 'Die Ressource enthält statische Seitenmarkierungen, wie z. B. solche, die durch die Rolle doc-pagebreak [DPUB-ARIA-1.0] gekennzeichnet sind. Dieser Wert wird am häufigsten bei E-Books verwendet, für die es eine statisch paginierte Entsprechung gibt, z. B. eine gedruckte Ausgabe, aber es ist nicht erforderlich, dass die Seitenmarkierungen einem anderen Werk entsprechen. Die Markierungen können lediglich dazu dienen, die Navigation in rein digitalen Werken zu erleichtern.' } },
      { '@id': 'pageNavigation', 'skos:prefLabel': { 'eng': 'pageNavigation', 'deu': 'Seitennavigation' }, 'skos:definition': { 'eng': 'The resource includes a means of navigating to static page break locations.', 'deu': 'Die Ressource enthält eine Möglichkeit zu statischen Seitenumbrüchen zu navigieren.' } },
      { '@id': 'readingOrder', 'skos:prefLabel': { 'eng': 'readingOrder', 'deu': 'Lesereihenfolge' }, 'skos:definition': { 'eng': 'The reading order of the content is clearly defined in the markup (e.g., figures, sidebars and other secondary content has been marked up to allow it to be skipped automatically and/or manually escaped from.', 'deu': 'Die Lesereihenfolge des Inhalts ist im Markup klar definiert (z. B. wurden Abbildungen, Seitenleisten und andere sekundäre Inhalte so gekennzeichnet, dass sie automatisch übersprungen und/oder manuell übergangen werden können).' } },
      { '@id': 'structuralNavigation', 'skos:prefLabel': { 'eng': 'structuralNavigation', 'deu': 'Dokumentenhierarchie' }, 'skos:definition': { 'eng': 'The use of headings in the resource fully and accurately reflects the document hierarchy, allowing navigation by assistive technologies.', 'deu': 'Die Verwendung von Überschriften in der Ressource spiegelt die Dokumenthierarchie vollständig und genau wider und ermöglicht die Navigation mit Hilfe von Hilfsmitteln.' } },
      { '@id': 'tableOfContents', 'skos:prefLabel': { 'eng': 'tableOfContents', 'deu': 'Verlinktes Inhaltsverzeichnis' }, 'skos:definition': { 'eng': 'The resource includes a table of contents that provides links to the major sections of the content.', 'deu': 'Die Ressource enthält ein Inhaltsverzeichnis, das Links zu den wichtigsten Abschnitten des Inhalts enthält.' } },
      { '@id': 'taggedPDF', 'skos:prefLabel': { 'eng': 'taggedPDF', 'deu': 'Getaggtes PDF' }, 'skos:definition': { 'eng': 'The contents of the PDF have been tagged to permit access by assistive technologies.', 'deu': 'Der Inhalt der PDF-Datei wurde mit Tags versehen, um den Zugriff durch unterstützende Technologien zu ermöglichen.' } },
      { '@id': 'alternativeText', 'skos:prefLabel': { 'eng': 'alternativeText', 'deu': 'Alternativtext' }, 'skos:definition': { 'eng': 'Alternative text is provided for visual content (e.g., via the [HTML] alt attribute).', 'deu': 'Für visuelle Inhalte wird ein Alternativtext bereitgestellt (z. B. über das [HTML]-Attribut alt).' } },
      { '@id': 'audioDescription', 'skos:prefLabel': { 'eng': 'audioDescription', 'deu': 'Audiobeschreibung' }, 'skos:definition': { 'eng': 'Audio descriptions are available (e.g., via an [HTML] track element with its kind attribute set to "descriptions").', 'deu': 'Audiobeschreibungen sind verfügbar (z. B. über ein [HTML]-Track-Element, dessen kind-Attribut auf "descriptions" gesetzt ist).' } },
      { '@id': 'closedCaptions', 'skos:prefLabel': { 'eng': 'closedCaptions', 'deu': 'Geschlossene Untertitel' }, 'skos:definition': { 'eng': 'Indicates that synchronized closed captions are available for audio and video content. Closed captions are defined separately from the video, allowing users to control whether they are rendered or not, unlike open captions.', 'deu': 'Zeigt an, dass synchronisierte Untertitel für Audio- und Videoinhalte verfügbar sind. Geschlossene Untertitel werden getrennt vom Video definiert, so dass Benutzer:innen im Gegensatz zu offenen Untertiteln steuern können, ob sie gerendert werden oder nicht.' } },
      { '@id': 'describedMath', 'skos:prefLabel': { 'eng': 'describedMath', 'deu': 'Mathematischen Gleichungen mit Textbeschreibung' }, 'skos:definition': { 'eng': 'Textual descriptions of math equations are included, whether in the alt attribute for image-based equations, using the alttext attribute for [MathML] equations, or by other means', 'deu': 'Textliche Beschreibungen von mathematischen Gleichungen sind enthalten, entweder im alt-Attribut für bildbasierte Gleichungen, unter Verwendung des alttext-Attributs für [MathML]-Gleichungen oder auf andere Weise.' } },
      { '@id': 'longDescription', 'skos:prefLabel': { 'eng': 'longDescription', 'deu': 'Visuelle Inhalte mit Textbeschreibung' }, 'skos:definition': { 'eng': 'Descriptions are provided for image-based visual content and/or complex structures such as tables, mathematics, diagrams, and charts.', 'deu': 'Beschreibungen werden für bildbasierte visuelle Inhalte und/oder komplexe Strukturen wie Tabellen, mathematische Darstellungen, Diagramme und Tabellen bereitgestellt.' } },
      { '@id': 'openCaptions', 'skos:prefLabel': { 'eng': 'openCaptions', 'deu': 'Offene Untertitel' }, 'skos:definition': { 'eng': 'Indicates that synchronized open captions are available for audio and video content. Open captions are part of the video stream and cannot be turned off by the user, unlike closed captions.', 'deu': 'Zeigt an, dass synchronisierte offene Untertitel für Audio- und Videoinhalte verfügbar sind. Offene Untertitel sind Teil des Videostroms und können im Gegensatz zu geschlossenen Untertiteln nicht vom Benutzer ausgeschaltet werden.' } },
      { '@id': 'rubyAnnotations', 'skos:prefLabel': { 'eng': 'rubyAnnotations', 'deu': 'rubyAnnotations' }, 'skos:definition': { 'eng': 'rubyAnnotations', 'deu': 'rubyAnnotations' } },
      { '@id': 'signLanguage', 'skos:prefLabel': { 'eng': 'signLanguage', 'deu': 'Gebärdensprache' }, 'skos:definition': { 'eng': 'Sign language interpretation is available for audio and video content.', 'deu': 'Für Audio- und Videoinhalte steht eine Gebärdensprachdolmetschung zur Verfügung.' } },
      { '@id': 'transcript', 'skos:prefLabel': { 'eng': 'transcript', 'deu': 'Abschrift' }, 'skos:definition': { 'eng': 'Indicates that a transcript of the audio content is available.', 'deu': 'Zeigt an, dass eine Abschrift des Audioinhalts verfügbar ist.' } },
      { '@id': 'displayTransformability', 'skos:prefLabel': { 'eng': 'displayTransformability', 'deu': 'Steuerbare Anzeigeeigenschaften' }, 'skos:definition': { 'eng': 'Display properties are controllable by the user. This property can be set, for example, if custom CSS style sheets can be applied to the content to control the appearance. It can also be used to indicate that styling in document formats like Word and PDF can be modified.', 'deu': 'Die Anzeigeeigenschaften sind durch Benutzer:innen steuerbar. Diese Eigenschaft kann z. B. festgelegt werden, wenn benutzerdefinierte CSS-Stilvorlagen auf den Inhalt angewendet werden können, um das Aussehen zu steuern. Sie kann auch verwendet werden, um anzuzeigen, dass das Styling in Dokumentformaten wie Word und PDF geändert werden kann.' } },
      { '@id': 'synchronizedAudioText', 'skos:prefLabel': { 'eng': 'synchronizedAudioText', 'deu': 'Wiedergabe von Text und Ton' }, 'skos:definition': { 'eng': 'Describes a resource that offers both audio and text, with information that allows them to be rendered simultaneously. The granularity of the synchronization is not specified. This term is not recommended when the only material that is synchronized is the document headings.', 'deu': 'Beschreibt eine Ressource, die sowohl Audio als auch Text anbietet, mit Informationen, die es ermöglichen, beide gleichzeitig wiederzugeben. Die Granularität der Synchronisation ist nicht spezifiziert. Dieser Begriff wird nicht empfohlen, wenn das einzige Material, das synchronisiert wird, die Dokumentüberschriften sind.' } },
      { '@id': 'timingControl', 'skos:prefLabel': { 'eng': 'timingControl', 'deu': 'Zeitsteuerung' }, 'skos:definition': { 'eng': 'For content with timed interaction, this value indicates that the user can control the timing to meet their needs (e.g., pause and reset).', 'deu': 'Bei Inhalten mit zeitgesteuerter Interaktion zeigt dieser Wert an, dass Benutzer:innen den Zeitablauf nach seinen Bedürfnissen steuern kann (z. B. Anhalten und Zurücksetzen).' } },
      { '@id': 'unlocked', 'skos:prefLabel': { 'eng': 'unlocked', 'deu': 'Freie Nutzung' }, 'skos:definition': { 'eng': 'No digital rights management or other content restriction protocols have been applied to the resource.', 'deu': 'Es wurden keine Protokolle zur Verwaltung digitaler Rechte oder anderer Inhaltsbeschränkungen auf die Ressource angewendet.' } },
      { '@id': 'ChemML', 'skos:prefLabel': { 'eng': 'ChemML', 'deu': 'ChemML' }, 'skos:definition': { 'eng': 'Identifies that chemical information is encoded using the ChemML markup language.', 'deu': 'Gibt an, dass die chemischen Informationen mit der Auszeichnungssprache ChemML kodiert sind.' } },
      { '@id': 'latex', 'skos:prefLabel': { 'eng': 'latex', 'deu': 'Mathematische Gleichungen und Formeln in LaTeX' }, 'skos:definition': { 'eng': 'Identifies that mathematical equations and formulas are encoded in the LaTeX typesetting system.', 'deu': 'Kennzeichnet, dass mathematische Gleichungen und Formeln im LaTeX-Satzsystem kodiert sind.' } },
      { '@id': 'MathML', 'skos:prefLabel': { 'eng': 'MathML', 'deu': 'MathML' }, 'skos:definition': { 'eng': 'Identifies that mathematical equations and formulas are encoded in [MathML].', 'deu': 'Gibt an, dass mathematische Gleichungen und Formeln in [MathML] kodiert sind.' } },
      { '@id': 'ttsMarkup', 'skos:prefLabel': { 'eng': 'ttsMarkup', 'deu': 'Optimiertes Text to Speech' }, 'skos:definition': { 'eng': 'One or more of [SSML], [Pronunciation-Lexicon], and [CSS3-Speech] properties has been used to enhance text-to-speech playback quality.', 'deu': 'Eine oder mehrere der Eigenschaften [SSML], [Pronunciation-Lexicon] und [CSS3-Speech] wurden verwendet, um die Qualität der Text-to-Speech-Wiedergabe zu verbessern.' } },
      { '@id': 'highContrastAudio', 'skos:prefLabel': { 'eng': 'highContrastAudio', 'deu': 'Audio mit optimalem Kontrast' }, 'skos:definition': { 'eng': 'Audio content with speech in the foreground meets the contrast thresholds set out in WCAG Success Criteria.', 'deu': 'Audioinhalte mit Sprache im Vordergrund erfüllen die in den WCAG-Erfolgskriterien festgelegten Kontrastschwellenwerte.' } },
      { '@id': 'highContrastDisplay', 'skos:prefLabel': { 'eng': 'highContrastDisplay', 'deu': 'Inhalt mit optimalem visuellen Kontrast' }, 'skos:definition': { 'eng': 'Content meets the visual contrast threshold set out in WCAG Success Criteria 1.4.6.', 'deu': 'Der Inhalt erfüllt den Schwellenwert für den visuellen Kontrast, der in den WCAG-Erfolgskriterien 1.4.6 festgelegt ist.' } },
      { '@id': 'none', 'skos:prefLabel': { 'eng': 'none', 'deu': 'Keine' }, 'skos:definition': { 'eng': 'Indicates that the resource does not contain any accessibility features. The none value must not be set with any other feature value.', 'deu': 'Die Ressource enthält keine Zugänglichkeitsmerkmale. Der Wert "Keine" darf nicht zusammen mit einem anderen Merkmalswert gesetzt werden.' } }
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
      { '@id': ns + 'Z3K6-SWVD', 'skos:prefLabel': { 'eng': 'Bachelor theses', 'deu': 'Bachelorarbeit' } },
      { '@id': ns + '9E94-E3F8', 'skos:prefLabel': { 'eng': 'Diplomarbeit', 'deu': 'Diplomarbeit' } },
      { '@id': ns + 'P2YP-BMND', 'skos:prefLabel': { 'eng': 'Master theses', 'deu': 'Masterarbeit' } },
      { '@id': ns + '1PHE-7VMS', 'skos:prefLabel': { 'eng': 'Dissertation', 'deu': 'Dissertation' } },
      { '@id': ns + 'ST05-F6SP', 'skos:prefLabel': { 'eng': 'Magisterarbeit', 'deu': 'Magisterarbeit' } },
      { '@id': ns + '9ZSV-CVJH', 'skos:prefLabel': { 'eng': 'Habilitation', 'deu': 'Habilitation' } },
      { '@id': ns + 'H1TF-SDX1', 'skos:prefLabel': { 'eng': 'Master-Thesis (ULG)', 'deu': 'Master-Theses (ULG)' } },
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
      { '@id': ns + 'QTXN-YBJ3', 'skos:prefLabel': { 'eng': 'web application', 'deu': 'Web-Anwendung' } },
      { '@id': ns + 'T6C3-46S4', 'skos:prefLabel': { 'eng': '3D model', 'deu': '3D Model' } },
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
      { '@id': 'http://base.uni-ak.ac.at/vocabulary/written_component_of_artistic_thesis', 'skos:prefLabel': { 'eng': 'Written component of artistic Thesis', 'deu': 'Schriftlicher Teil der künstlerischen Abschlussarbeit' } }
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
  'oeraudience': {
    terms: [
      { '@id': ns + '7RSE-DD9C', 'skos:prefLabel': { 'eng': 'Primary School', 'deu': 'Primarstufe' } },
      { '@id': ns + 'KNB1-BJBV', 'skos:prefLabel': { 'eng': 'Primary School Level I', 'deu': 'Primarstufe GS I' } },
      { '@id': ns + 'PYJ6-HQ52', 'skos:prefLabel': { 'eng': 'Primary School Level II', 'deu': 'Primarstufe GS II' } },
      { '@id': ns + 'N26X-38N8', 'skos:prefLabel': { 'eng': 'Secondary School', 'deu': 'Sekundarstufe' } },
      { '@id': ns + 'G6X5-JRMG', 'skos:prefLabel': { 'eng': 'Secondary School lower sec.', 'deu': 'Sekundarstufe Sek I' } },
      { '@id': ns + 'NTNX-9GPN', 'skos:prefLabel': { 'eng': 'Secondary School higher sec.', 'deu': 'Sekundarstufe Sek II' } },
      { '@id': ns + '2W2J-XQNW', 'skos:prefLabel': { 'eng': 'Adult Education / Higher Education', 'deu': 'Erwachsenenbildung/Hochschule' } },
      { '@id': ns + 'CGD1-16CQ', 'skos:prefLabel': { 'eng': 'general educational resource', 'deu': 'Allgemeine Bildungsressource' } },
      { '@id': ns + 'GZWD-CGJ0', 'skos:prefLabel': { 'eng': 'miscellaneous educational resource', 'deu': 'Sonstige Bildungsressource' } }
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
  setInstanceConfig(state, instanceconfig) {
    if (instanceconfig.hasOwnProperty('data_vocabularies')) {
      for (let vocid of Object.keys(instanceconfig.data_vocabularies)) {
        Vue.set(state.vocabularies, vocid, instanceconfig.data_vocabularies[vocid])
        state.vocabularies[vocid].loaded = true
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
  setInstanceConfig({ commit }, config) {
    commit('setInstanceConfig', config)
  },
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
