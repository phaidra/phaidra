import { StringDateAdapter } from 'vuetify/date/adapters/string'
import { de, en, it } from 'vuetify/locale'
import { watch } from 'vue'

const DATE_LOCALE_BY_VUETIFY = {
  en: 'en-GB',
  de: 'de-AT',
  it: 'it-IT',
}

export function getPhaidraLocale (i18n) {
  return i18n?.global?.locale ?? 'eng'
}

export function phaidraToVuetifyLocale (locale) {
  switch (locale) {
    case 'deu': return 'de'
    case 'ita': return 'it'
    default: return 'en'
  }
}

// StringDateAdapter does not forward locale updates to its inner adapter.
class LocalizedStringDateAdapter extends StringDateAdapter {
  get locale () {
    return this.base.locale
  }

  set locale (value) {
    this.base.locale = value
  }
}

export function createVuetifyI18nOptions (i18n) {
  return {
    locale: {
      locale: phaidraToVuetifyLocale(getPhaidraLocale(i18n)),
      fallback: 'en',
      messages: { en, de, it },
    },
    date: {
      adapter: LocalizedStringDateAdapter,
      locale: DATE_LOCALE_BY_VUETIFY,
    },
  }
}

export function syncVuetifyLocaleWithI18n (vuetify, i18n) {
  if (!i18n?.global) {
    return
  }

  watch(() => i18n.global.locale, () => {
    vuetify.locale.current.value = phaidraToVuetifyLocale(getPhaidraLocale(i18n))
  })
}
