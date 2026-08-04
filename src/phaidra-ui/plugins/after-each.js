export default defineNuxtPlugin((nuxtApp) => {
  const router = nuxtApp.$router
  const store = nuxtApp.$store

  if (!router || !store) return

  router.afterEach((to, from) => {
    if (process.client && to.path !== '/login') {
      localStorage.setItem('redirect', to.fullPath)
    }

    const localePath = nuxtApp.$localePath || ((path) => path)
    store.commit('updateBreadcrumbs', { to, from, localePath })
  })
})
