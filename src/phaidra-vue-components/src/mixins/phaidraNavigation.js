import { RouterLink } from 'vue-router'

/**
 * Inject link component and locale-aware path helper from the host app.
 * Demo: main.js provides RouterLink + identity phaidraLocalePath.
 * Nuxt 3: provide NuxtLink (or RouterLink) and a wrapper around useLocalePath().
 */
export default {
  inject: {
    phaidraLink: { from: 'phaidraLink', default: null },
    phaidraLocalePath: {
      from: 'phaidraLocalePath',
      default: () => (path) => path
    }
  },
  computed: {
    PhaidraLink () {
      return this.phaidraLink || RouterLink
    }
  },
  methods: {
    phaidraLocalePathFn (path) {
      const fn = this.phaidraLocalePath
      return typeof fn === 'function' ? fn(path) : path
    },
    detailRouteTo (pid) {
      return this.phaidraLocalePathFn(`/detail/${pid}`)
    }
  }
}
