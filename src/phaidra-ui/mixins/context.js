import PBreadcrumbs from '@/components/PBreadcrumbs'
import { useRootStore } from '~/stores/root'

export const context = {
  components: {
    PBreadcrumbs
  },
  computed: {
    signedin () {
      return useRootStore().user?.token ? 1 : 0
    },
    user () {
      return useRootStore().user || {}
    }
  }
}
