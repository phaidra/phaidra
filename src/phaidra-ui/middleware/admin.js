import { useRootStore } from '~/stores/root'

export default defineNuxtRouteMiddleware(() => {
  const { $pinia } = useNuxtApp()
  const store = useRootStore($pinia)

  if (!store.user?.isadmin) {
    return navigateTo('/')
  }
})
