import { useRootStore } from '~/stores/root'

export default defineNuxtPlugin((nuxtApp) => {
  const router = nuxtApp.$router
  const axios = nuxtApp.$axios

  if (!router || !axios) return

  router.beforeEach(async () => {
    const store = useRootStore(nuxtApp.$pinia)
    if (store.user?.token) {
      try {
        await axios.request({
          method: 'GET',
          url: '/keepalive',
          headers: {
            'X-XSRF-TOKEN': store.user.token,
          },
        })
      } catch (error) {
        console.log('failed keepalive, logging out ' + error)
        await store.logout()
      }
    }
  })
})
