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
    },
    hasInactiveObjects () {
      return !!useRootStore().hasInactiveObjects
    },
    canManageInactiveObjects () {
      return !!useRootStore().canManageInactiveObjects
    },
    isInactiveObjectsAdmin () {
      return !!(this.user.isadmin || useRootStore().isInactiveObjectsAdmin)
    },
    showInactiveObjectsNav () {
      // Admin always: the list starts empty and is the only place to register.
      // Curators and owners only when they have rows (approval / own inactive).
      return this.isInactiveObjectsAdmin || this.hasInactiveObjects
    },
    inactiveObjectsNavLabel () {
      return (this.isInactiveObjectsAdmin || this.canManageInactiveObjects) ? 'Inactive objects' : 'My inactive objects'
    }
  }
}
