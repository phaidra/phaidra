import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { aliases as mdiAliases, mdi } from 'vuetify/iconsets/mdi'
import { StringDateAdapter } from 'vuetify/date/adapters/string'

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig()
  const themeCookie = useCookie('theme')

  const primaryColor = config.public.primaryColor || '#1976D2'
  const darkPrimaryColor = config.public.darkPrimaryColor || primaryColor
  let defaultTheme = config.public.defaultTheme === 'dark' ? 'dark' : 'light'
  if (themeCookie.value === 'dark' || themeCookie.value === 'light') {
    defaultTheme = themeCookie.value
  }

  const vuetify = createVuetify({
    ssr: true,
    components,
    directives,
    icons: {
      defaultSet: 'mdi',
      aliases: {
        ...mdiAliases,
        error: 'mdi-alert',
      },
      sets: {
        mdi,
      },
    },
    theme: {
      defaultTheme,
      themes: {
        light: {
          dark: false,
          colors: {
            primary: primaryColor,
            secondary: '#616161',
            error: '#dd4814',
            cardtitlebg: '#757575',
            btnred: '#E91916',
            'ph-button-bg': '#757575',
            'ph-button-bg-dark': '#272727'
          }
        },
        dark: {
          dark: true,
          colors: {
            primary: darkPrimaryColor,
            secondary: '#e2e2e2',
            error: '#dd4814',
            cardtitlebg: '#000000',
            btnred: '#E91916',
            'ph-button-bg': '#757575',
            'ph-button-bg-dark': '#272727'
          }
        }
      }
    },
    defaults: {
    VBtn: {
      variant: 'flat'
    },
    VTextField: {
      density: 'comfortable',
      variant: 'underlined'
    },
    VSelect: {
      density: 'comfortable'
    },
    VAutocomplete: {
      density: 'comfortable'
    },
    VToolbar: {
      density: 'compact',
      VBtn: {
        variant: 'elevated'
      }
    },
    VPagination: {
      activeColor: 'primary',
      elevation: 1,
      size: 'small',
    },
    VCardActions: {
      VBtn: {
        variant: 'flat'
      }
    },
    VCheckbox: {
      density: 'compact'
    },
    VRow: {
      density: 'compact'
    },
    VSwitch: {
      color: 'primary',
    },
    VAlert: {
      VBtn: {
        variant: 'text'
      }
    },
    VTable: {
      VBtn: {
        variant: 'text'
      }
    }
  },
    date: {
      adapter: StringDateAdapter,
    },

  })

  nuxtApp.vueApp.use(vuetify)
})
