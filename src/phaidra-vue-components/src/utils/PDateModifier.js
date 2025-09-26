import moment from 'moment'

export default {
  dateModifierFn(val, that) {
    if (!val) return val;
    if (typeof val === 'string') {
      if (val.includes('.') && val.split('.').length > 2) {
        const valYear = val.split('.')[2]
        const valMonth = val.split('.')[1]
        const valDate = val.split('.')[0]
        if (that.$i18n.locale === 'deu') {
          return val
        } else {
          val = `${valYear}-${valMonth}-${valDate}`
          if (that.$i18n.locale === 'eng') {
            val = moment(new Date(val)).format('YYYY-MM-DD')
          }
        }
      }
    }
    var timestamp = Date.parse(val);
    if (isNaN(timestamp)) {
      return val
    }
    if (val.length <= 7) {
      // Return the existing value for the format YYYY or YYYY-MM
      return val
    }
    if (that.$i18n.locale === 'eng') {
      val = moment(new Date(val)).format('YYYY-MM-DD')
    } else {
      val = moment(new Date(val)).format('DD.MM.YYYY')
    }
    return val
  }
}