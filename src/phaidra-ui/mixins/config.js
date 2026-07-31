export const config = {
  computed: {
    appconfig () {
      return this.$store.state.config.global
    },
    instanceconfig () {
      return this.$store.state.instanceconfig
    },
    documentTitleSuffix () {
      const title = this.$t(this.instanceconfig.title)
      const institution = this.instanceconfig.institution
        ? this.$t(this.instanceconfig.institution)
        : ''
      if (!institution || institution === title) {
        return title
      }
      return title + ' - ' + institution
    }
  },
  methods: {
    documentTitle (pageTitle) {
      if (pageTitle) {
        return pageTitle + ' - ' + this.documentTitleSuffix
      }
      return this.documentTitleSuffix
    }
  }
}
