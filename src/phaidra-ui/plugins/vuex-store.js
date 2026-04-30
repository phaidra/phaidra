import { createStore } from 'vuex'
import * as root from '~/store/index'
import search from '~/store/search'
import vocabulary from '~/store/vocabulary'
import info from '~/store/info'
import * as bulkUpload from '~/store/bulk-upload'

const normalizeModule = (mod) => {
  const m = mod?.default || mod || {}
  const stateFactory = typeof m.state === 'function'
    ? m.state
    : () => ({ ...(m.state || {}) })

  return {
    namespaced: true,
    state: stateFactory,
    mutations: m.mutations || {},
    actions: m.actions || {},
    getters: m.getters || {}
  }
}

export default defineNuxtPlugin((nuxtApp) => {
  const rootActions = {
    ...(root.actions || {}),
    // Keep Nuxt 2 behavior: dispatch('setInstanceConfig', payload) always works.
    setInstanceConfig({ commit }, cfg) {
      commit('setInstanceConfig', cfg)
    }
  }

  const store = createStore({
    state: typeof root.state === 'function' ? root.state : () => ({}),
    mutations: root.mutations || {},
    actions: rootActions,
    getters: {},
    modules: {
      search: normalizeModule(search),
      vocabulary: normalizeModule(vocabulary),
      info: normalizeModule(info),
      'bulk-upload': normalizeModule(bulkUpload)
    }
  })

  // Explicit SSR <-> client hydration for custom Vuex store in Nuxt 4.
  if (import.meta.server) {
    nuxtApp.hooks.hook('app:rendered', () => {
      nuxtApp.payload.vuex = store.state
    })
  }
  if (import.meta.client && nuxtApp.payload?.vuex) {
    store.replaceState({
      ...store.state,
      ...nuxtApp.payload.vuex
    })
  }

  // Nuxt 2 injected $axios/$cookies onto the store for actions/mutations; restore for Vuex 4.
  store.$axios = nuxtApp.$axios
  store.$cookies = nuxtApp.$cookies || {
    get: () => {},
    set: () => {},
    remove: () => {}
  }

  nuxtApp.vueApp.use(store)
  nuxtApp.vueApp.config.globalProperties.$store = store
  nuxtApp.$store = store
  nuxtApp.provide('store', store)
})
