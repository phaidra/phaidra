// facetLabels: {
//   datastreams: 'Access',
//   resourcetype: 'Resource type',
//   dc_license: 'License',
//   tcreated: 'Created',
//   tsize: 'Size'
// },
// resourcetypeLabels: {
//   image: 'Image',
//   book: 'Book',
//   journalarticle: 'Journal article',
//   text: 'Text',
//   collection: 'Collection',
//   video: 'Video',
//   other: 'Other',
//   dataset: 'Dataset',
//   map: 'Map',
//   interactiveresource: 'Resource',
//   sound: 'Sound'
// },
export const marcRoles = {
  'initiator': 'Initiator',
  'evaluator': 'Evaluator',
  'technicalinspector': 'Technical inspector',
  'textprocessor': 'Textprocessor',
  'pedagogicexpert': 'Pedagogic expert',
  'interpreter': 'Interpreter',
  'digitiser': 'Digitiser',
  'keeperoftheoriginal': 'Keeper of the original',
  'adviser': 'Adviser',
  'degreegrantor': 'Degree grantor',
  'uploader': 'Uploader',
  'dtc': 'Data contributor',
  // 'aut': 'Author', has a separate input field
  'pbl': 'Publisher',
  'edt': 'Editor',
  'dsr': 'Designer',
  'trl': 'Translator',
  'exp': 'Expert',
  'oth': 'Other',
  'art': 'Artist',
  'dnr': 'Donor',
  'pht': 'Photographer',
  'jud': 'Judge',
  'prf': 'Performer',
  'wde': 'Wood engraver',
  'rce': 'Recording engineer',
  'sce': 'Scenarist',
  'ths': 'Thesis advisor',
  'sds': 'Sound designer',
  'lyr': 'Lyricist',
  'ilu': 'Illuminator',
  'eng': 'Engineer',
  'cnd': 'Conductor',
  'dto': 'Dedicator',
  'opn': 'Opponent',
  'cmp': 'Composer',
  'ctg': 'Cartographer',
  'dub': 'Dubious author',
  'wam': 'Writer of accompanying material',
  'arc': 'Architect',
  'vdg': 'Videographer',
  'scl': 'Sculptor',
  'aus': 'Screenwriter',
  'own': 'Owner',
  'fmo': 'Former owner',
  'mus': 'Musician',
  'ive': 'Interviewee',
  'ill': 'Illustrator',
  'cng': 'Cinematographer',
  'dte': 'Dedicatee',
  'sad': 'Scientific advisor',
  'mte': 'Metal-engraver',
  'arr': 'Arranger',
  'etr': 'Etcher',
  'dis': 'Dissertant',
  'prt': 'Printer',
  'flm': 'Film editor',
  'rev': 'Reviewer',
  'pro': 'Producer',
  'att': 'Attributed name',
  'lbt': 'Librettist',
  'ivr': 'Interviewer',
  'egr': 'Engraver',
  'msd': 'Musical director',
  'ard': 'Artistic director',
  'chr': 'Choreographer',
  'com': 'Compiler',
  'sng': 'Singer',
  'act': 'Actor',
  'adp': 'Adapter'
}

export function getMarcRoleLabel (r) {
  // if possible, return label directly
  if (marcRoles[r]) return marcRoles[r]

  // try to use the last element for lookup, e.g. from 'bib_roles_pers_uploader'
  // extracts 'Uploader'
  let splitted = r.split('_')
  if (splitted.length) {
    let last = splitted[splitted.length - 1]
    return marcRoles[last] || r
  }
}
