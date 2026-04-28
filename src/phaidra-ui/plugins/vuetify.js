import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

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
    VToolbar: {
      density: 'compact'
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
    }
  },
  })

  nuxtApp.vueApp.use(vuetify)
})
