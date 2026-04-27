import PhaidraVueComponents from 'phaidra-vue-components/src/components/index.js'
import { NuxtLink } from '#components'

/**
 * Registers phaidra-vue-components globally (Vue 3).
 * Uses the package src entry so `npm link` works without running `build-bundle` in the library.
 * For production you can switch to `import PhaidraVueComponents from 'phaidra-vue-components'`
 * after `npm run build-bundle` there (see library NUXT.md).
 */
export default defineNuxtPlugin((nuxtApp) => {
  // Temporary isolation switch for runtime debugging.
  if (process.env.PHAIDRA_DISABLE_PVC === '1') return

  if (!nuxtApp?.vueApp?.use) {
    console.error('[phaidra-vue-components plugin] nuxtApp.vueApp.use is unavailable')
    return
  }
  if (!PhaidraVueComponents) {
    console.error('[phaidra-vue-components plugin] imported plugin is undefined')
    return
  }
  nuxtApp.vueApp.use(PhaidraVueComponents)

  const g = nuxtApp.vueApp.config.globalProperties
  const localePathFn =
    typeof g.$localePath === 'function'
      ? (to) => g.$localePath(to)
      : (to) => {
          if (typeof to === 'string') return to.startsWith('/') ? to : `/${to}`
          if (to && typeof to === 'object') return to.path || '/'
          return '/'
        }

  nuxtApp.vueApp.provide('phaidraLink', NuxtLink)
  nuxtApp.vueApp.provide('phaidraLocalePath', localePathFn)
})
