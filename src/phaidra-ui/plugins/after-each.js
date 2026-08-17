import { useRootStore } from '~/stores/root'

export default defineNuxtPlugin((nuxtApp) => {
  const router = nuxtApp.$router

  if (!router) return

  router.afterEach((to, from) => {
    if (import.meta.client && to.path !== '/login') {
      localStorage.setItem('redirect', to.fullPath)
    }

    const localePath = nuxtApp.$localePath || ((path) => path)
    useRootStore(nuxtApp.$pinia).updateBreadcrumbs({ to, from, localePath })
  })
})
