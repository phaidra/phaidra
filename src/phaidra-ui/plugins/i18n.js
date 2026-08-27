import { createI18n } from 'vue-i18n'
import { LOCALE_KEY, PREFERENCE_MAX_AGE, syncLocalStorage } from '~/utils/preference-storage'
import { cloneLocaleMessages, applyI18nOverrides, applyInfoBannerMessage } from '~/utils/i18n-overrides'
import { useRootStore } from '~/stores/root'

export default defineNuxtPlugin((nuxtApp) => {
  const defaultLocale = useRuntimeConfig().public?.defaultLocale || 'eng'
  const messages = cloneLocaleMessages()
  const availableLocales = Object.keys(messages)

  const localeCookie = useCookie(LOCALE_KEY, {
    default: () => defaultLocale,
    maxAge: PREFERENCE_MAX_AGE,
    sameSite: 'lax',
    path: '/'
  })

  let locale = localeCookie.value
  if (!availableLocales.includes(locale)) {
    locale = availableLocales.includes(defaultLocale) ? defaultLocale : 'eng'
  }
  if (localeCookie.value !== locale) {
    localeCookie.value = locale
  }
  syncLocalStorage(LOCALE_KEY, locale)

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

  const instanceconfig = nuxtApp.$pinia ? useRootStore(nuxtApp.$pinia).instanceconfig : null
  if (instanceconfig) {
    applyI18nOverrides(i18n, instanceconfig.data_i18n)
    applyInfoBannerMessage(i18n, instanceconfig.infoBannerMessage)
  }

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
