export default defineNuxtPlugin((nuxtApp) => {
  const router = nuxtApp.$router
  const axios = nuxtApp.$axios
  const store = nuxtApp.$store

  if (!router || !axios || !store) return

  router.beforeEach(async () => {
    if (store.state?.user?.token) {
      try {
        await axios.request({
          method: 'GET',
          url: '/keepalive',
          headers: {
            'X-XSRF-TOKEN': store.state.user.token,
          },
        })
      } catch (error) {
        console.log('failed keepalive, logging out ' + error)
        await store.dispatch('logout')
      }
    }
  })
})
