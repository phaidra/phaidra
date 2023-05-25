import Vue from 'vue'
import VueI18n from 'vue-i18n'
import eng from './eng'
import deu from './deu'
import ita from './ita'

Vue.use(VueI18n)
const messages = { eng: eng, deu: deu, ita: ita }
export default new VueI18n({
  locale: 'deu',
  fallbackLocale: 'eng',
  silentTranslationWarn: true,
  messages
})
