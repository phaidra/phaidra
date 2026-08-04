import moment from 'moment'

function formatBytes (bytes, precision) {
  if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) return '-'
  if (typeof precision === 'undefined') precision = 1
  const units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB']
  const number = Math.floor(Math.log(bytes) / Math.log(1024))
  return (
    (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) +
    ' ' +
    units[number]
  )
}

function formatGigabytes (bytes, precision) {
  if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) return '-'
  if (typeof precision === 'undefined') precision = 1
  const n = parseFloat(bytes)
  if (isNaN(n) || !isFinite(n)) return '-'
  return (n / Math.pow(1024, 3)).toFixed(precision) + ' GB'
}

export default defineNuxtPlugin((nuxtApp) => {
  const g = nuxtApp.vueApp.config.globalProperties
  g.$filterDate = (value) => (value ? moment(String(value)).format('DD.MM.YYYY') : '')
  g.$filterDateTime = (value) => (value ? moment(String(value)).format('DD.MM.YYYY hh:mm:ss') : '')
  g.$filterDateTimeUtc = (value) => (value ? moment.utc(String(value)).format('DD.MM.YYYY HH:mm:ss') : '')
  g.$filterUnixTime = (value) => (value ? moment.unix(String(value)).format('DD.MM.YYYY hh:mm:ss') : '')
  g.$filterBytes = formatBytes
  g.$filterGigabytes = formatGigabytes
  g.$filterTruncate = (text, length, clamp) => {
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
})
