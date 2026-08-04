import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'
import '~/assets/css/vuetify-overrides.css'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { aliases as mdiAliases, mdi } from 'vuetify/iconsets/mdi'
import { createVuetifyI18nOptions, syncVuetifyLocaleWithI18n } from '~/utils/vuetify-locale'
import { THEME_KEY, PREFERENCE_MAX_AGE, normalizeTheme, syncLocalStorage } from '~/utils/preference-storage'

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig()

  const primaryColor = config.public.primaryColor || '#1976D2'
  const darkPrimaryColor = config.public.darkPrimaryColor || primaryColor
  const envDefaultTheme = config.public.defaultTheme === 'dark' ? 'dark' : 'light'
  const themeCookie = useCookie(THEME_KEY, {
    default: () => envDefaultTheme,
    maxAge: PREFERENCE_MAX_AGE,
    sameSite: 'lax',
    path: '/'
  })

  const defaultTheme = normalizeTheme(themeCookie.value, envDefaultTheme)
  if (themeCookie.value !== defaultTheme) {
    themeCookie.value = defaultTheme
  }
  syncLocalStorage(THEME_KEY, defaultTheme)

  const vuetify = createVuetify({
    ssr: true,
    components: {
      ...components,
    },
    directives,
    ...createVuetifyI18nOptions(nuxtApp.$i18n),
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
    VIconBtn: {
      variant: 'text'
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
      density: 'compact',
      color: 'primary',
      hideDetails: 'auto'
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
  })

  nuxtApp.vueApp.use(vuetify)
  nuxtApp.$vuetify = vuetify
  syncVuetifyLocaleWithI18n(vuetify, nuxtApp.$i18n)
})
