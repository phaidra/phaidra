export default defineNuxtPlugin((nuxtApp) => {
  // If a real store is already registered, never override/provide fallback.
  if (nuxtApp.vueApp.config.globalProperties.$store) {
    return
  }

  const subscribers = []
  const fallbackStore = {
    state: {
      alerts: [],
      snackbar: false,
      breadcrumbs: [],
      user: {},
      config: { global: {} },
      instanceconfig: {},
      loading: false,
      vocabulary: {
        vocabularies: {
          cmodels: { terms: [] }
        }
      }
    },
    getters: {},
    commit: (type, payload) => {
      subscribers.forEach((fn) => {
        try {
          fn({ type, payload }, fallbackStore.state)
        } catch (_) {}
      })
    },
    dispatch: async () => {},
    subscribe: (fn) => {
      if (typeof fn !== 'function') return () => {}
      subscribers.push(fn)
      return () => {
        const i = subscribers.indexOf(fn)
        if (i !== -1) subscribers.splice(i, 1)
      }
    },
    watch: () => () => {},
    replaceState: (nextState) => {
      if (nextState && typeof nextState === 'object') {
        fallbackStore.state = { ...fallbackStore.state, ...nextState }
      }
    }
  }

  nuxtApp.vueApp.config.globalProperties.$store = fallbackStore
  nuxtApp.provide('store', fallbackStore)
})
