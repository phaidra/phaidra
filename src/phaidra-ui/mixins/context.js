import PBreadcrumbs from '@/components/PBreadcrumbs'

export const context = {
  components: {
    PBreadcrumbs
  },
  computed: {
    signedin () {
      return this.$store.state.user.token ? 1 : 0
    },
    user () {
      return this.$store.state.user
    }
  }
}
