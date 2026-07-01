import { createI18n } from 'vue-i18n'
import eng from '~/locales/eng.json'
import deu from '~/locales/deu.json'
import ita from '~/locales/ita.json'

export default defineNuxtPlugin((nuxtApp) => {
  const defaultLocale = useRuntimeConfig().public?.defaultLocale || 'eng'
  const messages = { eng, deu, ita }

  let locale = defaultLocale
  if (import.meta.client) {
    const stored = localStorage.getItem('locale')
    if (stored && messages[stored]) {
      locale = stored
    } else {
      localStorage.setItem('locale', defaultLocale)
    }
  }

  const i18n = createI18n({
    legacy: true,
    globalInjection: true,
    locale,
    fallbackLocale: 'eng',
    messages,
    silentTranslationWarn: true,
    silentFallbackWarn: true
  })

  nuxtApp.vueApp.use(i18n)
  nuxtApp.$i18n = i18n

  const localePath = (to) => {
    if (typeof to === 'string') return to.startsWith('/') ? to : `/${to}`
    if (to && typeof to === 'object') {
      const raw = to.path || '/'
      const path = raw.startsWith('/') ? raw : `/${raw}`
      // Return a full location when present so Vue Router keeps query/hash/params (not just path).
      if (to.query != null || to.hash || to.params != null || to.name != null) {
        return { ...to, path }
      }
      return path
    }
    return '/'
  }
  const localeLocation = (to) => to
  const switchLocalePath = () => {
    const route = useRoute()
    return route?.fullPath || '/'
  }

  nuxtApp.vueApp.config.globalProperties.$localePath = localePath
  nuxtApp.vueApp.config.globalProperties.localePath = localePath
  nuxtApp.vueApp.config.globalProperties.$localeLocation = localeLocation
  nuxtApp.vueApp.config.globalProperties.localeLocation = localeLocation
  nuxtApp.vueApp.config.globalProperties.$switchLocalePath = switchLocalePath
  nuxtApp.vueApp.config.globalProperties.switchLocalePath = switchLocalePath

  nuxtApp.provide('localePath', localePath)
  nuxtApp.provide('localeLocation', localeLocation)
  nuxtApp.provide('switchLocalePath', switchLocalePath)
})

