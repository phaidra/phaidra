const LOCALE_KEY = 'locale'
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
    maxAge: 60 * 60 * 24 * 365,
    sameSite: 'lax',
    path: '/'
  })

  const resolveLocale = (candidate) => {
    if (candidate && availableLocales.includes(candidate)) {
      return candidate
    }
    return availableLocales.includes(defaultLocale) ? defaultLocale : 'eng'
  }

  let locale = resolveLocale(localeCookie.value)

  if (import.meta.client) {
    locale = resolveLocale(
      localStorage.getItem(LOCALE_KEY) || localeCookie.value
    )
    localStorage.setItem(LOCALE_KEY, locale)
  }

  if (localeCookie.value !== locale) {
    localeCookie.value = locale
  }

  if (i18n?.global) {
    i18n.global.locale = locale
  }
})
