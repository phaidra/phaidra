import { useRootStore } from '~/stores/root'

export default defineNuxtRouteMiddleware(async (to) => {
  const { $pinia } = useNuxtApp()
  const store = useRootStore($pinia)

  // Keep old behavior, but restore persisted token on hard refresh.
  if (!store.user?.token) {
    let token = useCookie('XSRF-TOKEN').value
    if (!token && import.meta.client) {
      try {
        token = localStorage.getItem('XSRF-TOKEN')
      } catch (_) {}
    }
    if (token) {
      store.setToken(token)
    }
  }

  // Rehydrate full user profile (isadmin, firstname, lastname, ...)
  // so header/admin menu is correct after hard refresh.
  if (store.user?.token && !store.user?.username) {
    try {
      await store.getLoginData()
    } catch (_) {}
  }

  if (!store.user?.token) {
    if (import.meta.client) {
      try {
        localStorage.setItem('redirect', to.fullPath)
      } catch (_) {}
    }
    return navigateTo('/login')
  }
})
