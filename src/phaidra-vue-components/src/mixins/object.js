export default {
  methods: {
    getObjectTitle(doc) {
      return doc[`dc_title_${this.$i18n.locale}`] ? doc[`dc_title_${this.$i18n.locale}`][0] : doc.dc_title ? doc.dc_title[0] : doc.pid
    }
  }
}