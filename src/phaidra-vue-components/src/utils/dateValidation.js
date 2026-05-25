export function daysInMonth (year, month) {
  const months31 = [1, 3, 5, 7, 8, 10, 12]
  const months30 = [4, 6, 9, 11]
  if (months31.includes(month)) {
    return 31
  }
  if (months30.includes(month)) {
    return 30
  }
  const isLeap = (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)
  return isLeap ? 29 : 28
}

export function isValidCalendarMonth (month) {
  return month >= 1 && month <= 12
}

export function isValidEdtfSeason (season) {
  return season >= 21 && season <= 24
}

export function isValidYearMonthOrSeason (mm) {
  const n = parseInt(mm, 10)
  if (Number.isNaN(n)) {
    return false
  }
  return isValidCalendarMonth(n) || isValidEdtfSeason(n)
}

export function isValidCalendarDay (year, month, day) {
  if (!isValidCalendarMonth(month)) {
    return false
  }
  return day >= 1 && day <= daysInMonth(year, month)
}

function parseYear (yearStr) {
  if (!/^\d{4}$/.test(yearStr)) {
    return null
  }
  const year = parseInt(yearStr, 10)
  return Number.isNaN(year) ? null : year
}

function validateYearMonth (yearStr, mm) {
  const year = parseYear(yearStr)
  if (year === null) {
    return false
  }
  return isValidYearMonthOrSeason(mm)
}

function validateYearMonthDay (yearStr, mm, dd) {
  const year = parseYear(yearStr)
  if (year === null) {
    return false
  }
  const month = parseInt(mm, 10)
  const day = parseInt(dd, 10)
  if (Number.isNaN(month) || Number.isNaN(day)) {
    return false
  }
  return isValidCalendarDay(year, month, day)
}

function validateYearMonthOnly (yearStr, mm) {
  const year = parseYear(yearStr)
  if (year === null) {
    return false
  }
  const month = parseInt(mm, 10)
  if (Number.isNaN(month)) {
    return false
  }
  return isValidCalendarMonth(month)
}

const EDTF_RULES = [
  { pattern: /^(\d{4})-(\d{2})-(\d{2})~(\d{2})$/, validate: (m) => validateYearMonthDay(m[1], m[2], m[3]) },
  { pattern: /^(\d{4})-(\d{2})~(\d{2})$/, validate: (m) => validateYearMonth(m[1], m[2]) },
  { pattern: /^(\d{4})-(\d{2})-(\d{2})\?$/, validate: (m) => validateYearMonthDay(m[1], m[2], m[3]) },
  { pattern: /^(\d{4})-(\d{2})\?$/, validate: (m) => validateYearMonth(m[1], m[2]) },
  { pattern: /^(\d{4})\?$/, validate: (m) => parseYear(m[1]) !== null },
  { pattern: /^(\d{4})-(\d{2})-(\d{2})%$/, validate: (m) => validateYearMonthDay(m[1], m[2], m[3]) },
  { pattern: /^(\d{4})-(\d{2})%$/, validate: (m) => validateYearMonth(m[1], m[2]) },
  { pattern: /^(\d{4})%$/, validate: (m) => parseYear(m[1]) !== null },
  { pattern: /^(\d{4})-(\d{2})-XX$/, validate: (m) => validateYearMonthOnly(m[1], m[2]) },
  { pattern: /^(\d{4})-XX-XX$/, validate: (m) => parseYear(m[1]) !== null },
  { pattern: /^(\d{4})-XX$/, validate: (m) => parseYear(m[1]) !== null },
  { pattern: /^(\d{4})-(\d{2})-(\d{2})$/, validate: (m) => validateYearMonthDay(m[1], m[2], m[3]) },
  { pattern: /^(\d{4})-(\d{2})$/, validate: (m) => validateYearMonth(m[1], m[2]) },
  { pattern: /^(\d{4})\/(\d{4})$/, validate: (m) => parseYear(m[1]) !== null && parseYear(m[2]) !== null },
  { pattern: /^(\d{4})~$/, validate: (m) => parseYear(m[1]) !== null },
  { pattern: /^(\d{4})$/, validate: (m) => parseYear(m[1]) !== null },
  { pattern: /^(\d{3})X$/, validate: () => true },
  { pattern: /^(\d{2})XX$/, validate: () => true }
]

/**
 * @param {string} dateString
 * @returns {boolean|null} true/false if EDTF-shaped, null if not an EDTF pattern
 */
export function validateEdtfDate (dateString) {
  for (const rule of EDTF_RULES) {
    const m = dateString.match(rule.pattern)
    if (m) {
      return rule.validate(m)
    }
  }
  return null
}

/**
 * ISO-like YYYY, YYYY-MM, YYYY-MM-DD (also used when EDTF patterns do not match).
 */
export function validateIsoLikeDate (dateString) {
  const regexDate = /^(\d{4})(-\d{1,2})?(-\d{1,2})?$/
  const m = dateString.match(regexDate)
  if (!m) {
    return false
  }

  const year = parseInt(m[1], 10)
  if (Number.isNaN(year)) {
    return false
  }

  if (m[2]) {
    const month = parseInt(m[2].substring(1), 10)
    if (!isValidCalendarMonth(month)) {
      return false
    }
    if (m[3]) {
      const day = parseInt(m[3].substring(1), 10)
      return isValidCalendarDay(year, month, day)
    }
    return true
  }

  return true
}

/**
 * @param {string} dateString
 * @returns {boolean}
 */
export function isValidDateValue (dateString) {
  if (typeof dateString !== 'string' || dateString === '') {
    return true
  }
  const trimmed = dateString.trim()
  const edtf = validateEdtfDate(trimmed)
  if (edtf !== null) {
    return edtf
  }
  return validateIsoLikeDate(trimmed)
}
