/**
 * Vuetify 3 setup for the standalone Vite demo app only.
 * Nuxt 3 hosts should register Vuetify themselves and must not import this file.
 */
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import '@mdi/font/css/materialdesignicons.css'

export default createVuetify({
  components: {
    ...components,
  },
  directives,
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          /** Phaidra / legacy V2 look (orange segment controls, section headers). Default V3 primary is blue (#1867C0). */
          primary: '#D84315',
          'primary-darken-1': '#BF360C'
        }
      }
    }
  },
  icons: {
    defaultSet: 'mdi'
  }
})
