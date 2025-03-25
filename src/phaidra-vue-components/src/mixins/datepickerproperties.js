export default {
  methods: {
    alpha2bcp47(locale) {
      switch (locale) {
        case 'eng': return 'en-GB'
        case 'deu': return 'de-AT'
        case 'ita': return 'it-IT'
        default: return 'en-GB'
      }
    }
  }
}
