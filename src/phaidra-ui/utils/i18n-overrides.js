import eng from '~/locales/eng.json'
import deu from '~/locales/deu.json'
import ita from '~/locales/ita.json'

const BASE_MESSAGES = { eng, deu, ita }

function cloneMessages (messages) {
  return JSON.parse(JSON.stringify(messages))
}

export function cloneLocaleMessages () {
  return {
    eng: cloneMessages(BASE_MESSAGES.eng),
    deu: cloneMessages(BASE_MESSAGES.deu),
    ita: cloneMessages(BASE_MESSAGES.ita)
  }
}

function getI18nTarget (i18n) {
  return i18n?.global || i18n
}

export function applyI18nOverrides (i18n, dataI18n) {
  const target = getI18nTarget(i18n)
  if (!target || typeof target.setLocaleMessage !== 'function') return

  Object.keys(BASE_MESSAGES).forEach((lang) => {
    target.setLocaleMessage(lang, cloneMessages(BASE_MESSAGES[lang]))
  })

  if (!dataI18n || typeof dataI18n !== 'object') return

  Object.entries(dataI18n).forEach(([lang, messages]) => {
    if (messages && typeof messages === 'object' && typeof target.mergeLocaleMessage === 'function') {
      target.mergeLocaleMessage(lang, messages)
    }
  })
}

export function applyInfoBannerMessage (i18n, message) {
  if (!message) return
  const target = getI18nTarget(i18n)
  if (!target || typeof target.mergeLocaleMessage !== 'function') return
  target.mergeLocaleMessage('eng', { 'Info banner message': message })
}
