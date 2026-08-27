import { useRootStore } from '~/stores/root'
import { useBulkUploadStore } from '~/stores/bulk-upload'
import { useVocabularyStore } from 'phaidra-vue-components/src/stores/vocabulary'
import { useSearchStore } from 'phaidra-vue-components/src/stores/search'
import { useInfoStore } from 'phaidra-vue-components/src/stores/info'

export default defineNuxtPlugin(async (nuxtApp) => {
  const xsrfCookie = useCookie('XSRF-TOKEN')
  const cookies = {
    get (name) {
      return name === 'XSRF-TOKEN' ? xsrfCookie.value : undefined
    },
    set (name, value) {
      if (name === 'XSRF-TOKEN') {
        xsrfCookie.value = value
      }
    },
    remove (name) {
      if (name === 'XSRF-TOKEN') {
        xsrfCookie.value = null
      }
    }
  }
  nuxtApp.$cookies = cookies

  const pinia = nuxtApp.$pinia
  if (!pinia) {
    console.error('Pinia is not available; ensure @pinia/nuxt is registered in nuxt.config modules')
    return
  }
  pinia.use(({ store }) => {
    store.$axios = nuxtApp.$axios
    store.$cookies = cookies
  })

  // Instantiate stores so host-root lookups and SSR hydration work immediately.
  const root = useRootStore(pinia)
  useBulkUploadStore(pinia)
  useVocabularyStore(pinia)
  useSearchStore(pinia)
  useInfoStore(pinia)

  if (import.meta.server) {
    try {
      await root.nuxtServerInit({
        req: nuxtApp.ssrContext?.event?.node?.req,
        token: xsrfCookie.value
      })
    } catch (error) {
      console.warn('nuxtServerInit failed:', error)
    }
  }
})
