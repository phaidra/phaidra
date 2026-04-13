import { createI18n } from 'vue-i18n'

import eng from './eng.json'
import deu from './deu.json'
import ita from './ita.json'

const messages = { eng, deu, ita }

const i18n = createI18n({
  legacy: true,
  globalInjection: true,
  locale: 'deu',
  fallbackLocale: 'eng',
  silentTranslationWarn: true,
  silentFallbackWarn: true,
  messages
})

/** Programmatic locale updates from Vuex modules (outside components). */
export function setGlobalLocale (locale) {
  const loc = i18n.global.locale
  if (loc && typeof loc === 'object' && 'value' in loc) {
    loc.value = locale
  } else {
    i18n.global.locale = locale
  }
}

export function globalT (key, ...args) {
  return i18n.global.t(key, ...args)
}

export default i18n
