export default defineNuxtRouteMiddleware(async (to) => {
  const store = useNuxtApp().$store
  if (!store) return

  // Keep old behavior, but restore persisted token on hard refresh.
  if (!store.state?.user?.token) {
    let token = useCookie('XSRF-TOKEN').value
    if (!token && import.meta.client) {
      try {
        token = localStorage.getItem('XSRF-TOKEN')
      } catch (_) {}
    }
    if (token) {
      store.commit('setToken', token)
    }
  }

  // Rehydrate full user profile (isadmin, firstname, lastname, ...)
  // so header/admin menu is correct after hard refresh.
  if (store.state?.user?.token && !store.state?.user?.username) {
    try {
      await store.dispatch('getLoginData')
    } catch (_) {}
  }

  if (!store.state?.user?.token) {
    if (import.meta.client) {
      try {
        localStorage.setItem('redirect', to.fullPath)
      } catch (_) {}
    }
    return navigateTo('/login')
  }
})
