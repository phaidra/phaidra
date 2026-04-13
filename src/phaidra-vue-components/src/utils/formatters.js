import moment from 'moment'

export function unixtime (value) {
  if (value) {
    return moment.unix(String(value)).format('DD.MM.YYYY hh:mm:ss')
  }
  return ''
}

export function formatDate (value) {
  if (value) {
    return moment(String(value)).format('DD.MM.YYYY')
  }
  return ''
}

export function datetime (value) {
  if (value) {
    return moment(String(value)).format('DD.MM.YYYY hh:mm:ss')
  }
  return ''
}

export function datetimeutc (value) {
  if (value) {
    return moment.utc(String(value)).format('DD.MM.YYYY hh:mm:ss')
  }
  return ''
}

export function bytes (b, precision) {
  if (isNaN(parseFloat(b)) || !isFinite(b)) return '-'
  if (typeof precision === 'undefined') precision = 1
  const units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB']
  const number = Math.floor(Math.log(b) / Math.log(1024))
  return (b / Math.pow(1024, Math.floor(number))).toFixed(precision) + ' ' + units[number]
}

export function truncate (text, length, clamp) {
  clamp = clamp || '...'
  length = length || 30
  if (!text || text.length <= length) return text || ''

  let tcText = text.slice(0, length - clamp.length)
  let last = tcText.length - 1

  while (last > 0 && tcText[last] !== ' ' && tcText[last] !== clamp[0]) last -= 1

  last = last || length - clamp.length

  tcText = tcText.slice(0, last)

  return tcText + clamp
}

export function registerFormatters (app) {
  const g = app.config.globalProperties
  g.$unixtime = unixtime
  g.$date = formatDate
  g.$datetime = datetime
  g.$datetimeutc = datetimeutc
  g.$bytes = bytes
  g.$truncate = truncate
}
