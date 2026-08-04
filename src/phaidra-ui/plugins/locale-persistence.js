import { LOCALE_KEY, PREFERENCE_MAX_AGE, syncLocalStorage } from '~/utils/preference-storage'

const FALLBACK_LOCALES = ['eng', 'deu', 'ita']

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig()
  const defaultLocale = config.public?.defaultLocale || 'eng'
  const i18n = nuxtApp.$i18n
  const availableLocales = i18n?.global?.availableLocales?.length
    ? i18n.global.availableLocales
    : FALLBACK_LOCALES

  const localeCookie = useCookie(LOCALE_KEY, {
    default: () => defaultLocale,
    maxAge: PREFERENCE_MAX_AGE,
    sameSite: 'lax',
    path: '/'
  })

  const resolveLocale = (candidate) => {
    if (candidate && availableLocales.includes(candidate)) {
      return candidate
    }
    return availableLocales.includes(defaultLocale) ? defaultLocale : 'eng'
  }

  const locale = resolveLocale(localeCookie.value)

  if (localeCookie.value !== locale) {
    localeCookie.value = locale
  }

  if (i18n?.global && i18n.global.locale !== locale) {
    i18n.global.locale = locale
  }

  syncLocalStorage(LOCALE_KEY, locale)
})
