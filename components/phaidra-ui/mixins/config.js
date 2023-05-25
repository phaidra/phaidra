export const config = {
  computed: {
    appconfig () {
      return this.$store.state.config.global
    },
    instanceconfig () {
      return this.$store.state.instanceconfig
    }
  }
}
