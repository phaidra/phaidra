import Vue from 'vue'
import VueI18n from 'vue-i18n'

// Load JSON translations
import eng from './eng.json'
import deu from './deu.json'
import ita from './ita.json'

Vue.use(VueI18n)

const messages = { eng, deu, ita }

export default new VueI18n({
  locale: 'deu',
  fallbackLocale: 'eng',
  silentTranslationWarn: true,
  messages
})
