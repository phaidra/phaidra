import moment from 'moment'

const DOI_PATTERN = '\\b10\\.(?:97[89]\\.\\d{2,8}\\/\\d{1,7}|\\d{4,9}\\/\\S+)'
const DOI_GLOBAL_PATTERN = new RegExp(DOI_PATTERN, 'g')
const DOI_SINGLE_PATTERN = new RegExp(DOI_PATTERN)
const DOI_PATTERN_ONLY = '^10\\.(?:97[89]\\.\\d{2,8}\\/\\d{1,7}|\\d{4,9}\\/\\S+)'
const DOI_VALID_ENDING = /(?:\w|\(.+\)|2-#)$/

function extract (str) {
  const matches = String(str).toLowerCase().match(DOI_GLOBAL_PATTERN)
  if (!matches) {
    return []
  }
  return matches.map(stripPunctuation).filter(Boolean)
}

function extractOne (str) {
  const match = String(str).toLowerCase().match(DOI_SINGLE_PATTERN)
  if (!match) {
    return
  }
  return stripPunctuation(match[0])
}

function stripPunctuation (doi) {
  if (DOI_VALID_ENDING.test(doi)) {
    return doi
  }
  return extractOne(doi.replace(/\W$/, ''))
}

export const validationrules = {
  methods: {
    getIdentifierRuleName: function (type) {
      switch (type) {
        case 'ids:isbn':
          return 'isbn'
        case 'ids:doi':
          return 'doi'
        case 'ids:hdl':
          return 'hdl'
        case 'ids:urn':
          return 'urn'
        case 'ids:gnd':
          return 'gnd'
        case 'ids:orcid':
          return 'orcid'
        case 'ids:viaf':
          return 'viaf'
        case 'ids:wikidata':
          return 'wikidata'
        case 'phaidra:acnumber':
          return 'acnumber'
        default:
          return 'noop'
      }
    },
    generateOrcidCheckDigit: function (baseDigits) {
      let total = 0
      for (let i = 0; i < baseDigits.length; i++) {
        const digit = parseInt(baseDigits.charAt(i), 10)
        total = (total + digit) * 2
      }
      const remainder = total % 11
      const result = (12 - remainder) % 11
      return result === 10 ? 'X' : result
    },
    isValidHandle: function (str) {
      return true
    },
    isValidURN: function (str) {
      return true
    },
    isValidACNumber: function (str) {
      return true
    },
    isValidORCID: function (str) {
      var regexORCID = /^(\d{4})-(\d{4})-(\d{4})-(\d{3}[0-9X])$/
      console.log('orcid format: ' + (regexORCID.test(str) ? 'ok' : 'wrong'))
      const lastDigit = str.slice(-1)
      const baseDigits = str.slice(0, -1).replace(/\D/g, '')
      if (baseDigits.length !== 15) {
        return false
      }
      const generatedCheckDigit = this.generateOrcidCheckDigit(baseDigits).toString()
      console.log('orcid check digit: ' + (generatedCheckDigit === lastDigit ? 'ok' : 'wrong'))
      return regexORCID.test(str) && (generatedCheckDigit === lastDigit)
    },
    isValidGND: function (str) {
      return true
    },
    isValidISBN: function (str) {
      return true
    },
    isValidVIAF: function (str) {
      return true
    },
    isValidWikidata: function (str) {
      return true
    },
    isValidDOI: function (str) {
      return String(str).toLowerCase().match(DOI_PATTERN_ONLY) !== null
    },
    extractDOI: function (doistr) {
      return extract(doistr)
    },
    isValidDuration: function (durationString) {
      return moment.duration(durationString).isValid()
    },
    isValidDate: function (dateString) {
      // First check for the pattern
      var regexDate = /^(\d{4})(-\d{1,2})?(-\d{1,2})?$/

      if (!regexDate.test(dateString)) {
        return false
      }

      var m = dateString.match(regexDate)

      var year = parseInt(m[1], 10)

      if (m[2]) {
        var month = parseInt(m[2].substring(1), 10)
        // Check the ranges of month
        if (month) {
          if (month === 0 || month > 12) {
            return false
          }
        }
      }

      if (m[3]) {
        var day = parseInt(m[3].substring(1), 10)

        if (day) {
          var monthLength = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

          // Adjust for leap years
          if (year % 400 === 0 || (year % 100 !== 0 && year % 4 === 0)) {
            monthLength[1] = 29
          }

          // Check the range of the day
          return day > 0 && day <= monthLength[month - 1]
        }
      }

      return true
    }
  },
  data () {
    return {
      validationrules: {
        noop: value => { return true },
        required: value => !!value || 'Required',
        date: value => {
          return typeof value === 'undefined' || value === '' || this.isValidDate(value) || 'Invalid date'
        },
        duration: value => {
          return typeof value === 'undefined' || value === '' || this.isValidDuration(value) || 'Invalid duration'
        },
        isbn: value => {
          return typeof value === 'undefined' || value === '' || this.isValidISBN(value) || 'Invalid ISBN'
        },
        doi: value => {
          return typeof value === 'undefined' || value === '' || this.isValidDOI(value) || 'Invalid DOI'
        },
        hdl: value => {
          return typeof value === 'undefined' || value === '' || this.isValidHandle(value) || 'Invalid Handle identifier'
        },
        urn: value => {
          return typeof value === 'undefined' || value === '' || this.isValidURN(value) || 'Invalid URN'
        },
        acnumber: value => {
          return typeof value === 'undefined' || value === '' || this.isValidACNumber(value) || 'Invalid AC-number'
        },
        orcid: value => {
          return typeof value === 'undefined' || value === '' || this.isValidORCID(value) || 'Invalid ORCID'
        },
        gnd: value => {
          return typeof value === 'undefined' || value === '' || this.isValidGND(value) || 'Invalid GND identifier'
        },
        viaf: value => {
          return typeof value === 'undefined' || value === '' || this.isValidVIAF(value) || 'Invalid VIAF identifier'
        },
        wikidata: value => {
          return typeof value === 'undefined' || value === '' || this.isValidWikidata(value) || 'Invalid Wikidata identifier'
        }
      }
    }
  }
}
