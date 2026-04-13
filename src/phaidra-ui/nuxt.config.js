import crypto from 'crypto'
import path from 'path'
import { fileURLToPath } from 'url'
import { defineNuxtConfig } from 'nuxt/config'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const hmrClientPort = Number(process.env.PHAIDRA_HOSTPORT || 8899)

/** Redirect Vuetify's internal focusTrap module to `shims/vuetify-focusTrap.js` (SSR-safe teardown). */
function vuetifyFocusTrapSsrShim () {
  const shimPath = path.resolve(__dirname, 'shims/vuetify-focusTrap.js')
  return {
    name: 'vuetify-focus-trap-ssr-shim',
    enforce: 'pre',
    resolveId (id) {
      const normalized = id.split(path.sep).join('/')
      if (normalized.includes('/vuetify/lib/composables/focusTrap.js')) {
        return shimPath
      }
      return undefined
    }
  }
}

export default defineNuxtConfig({
 dir: {
    public: 'static'
 },

 // Nuxt 3: use runtimeConfig (publicRuntimeConfig alone is not applied)
 runtimeConfig: {
   apiBaseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api',
   public: {
     primaryColor: process.env.PHAIDRA_PRIMARY_COLOR,
     defaultTheme: process.env.PHAIDRA_DEFAULT_THEME,
     darkPrimaryColor: process.env.PHAIDRA_DARK_PRIMARY_COLOR,
     baseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT,
     apiBaseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api',
     axios: {
       browserBaseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api'
     },
     defaultLocale: process.env.PHAIDRA_DEFAULT_LANGUAGE || 'eng',
     cookieDomain: process.env.COOKIE_DOMAIN || process.env.PHAIDRA_HOSTNAME
   }
 },

 // render: { csp: true },
 // Global page headers: https://go.nuxtjs.dev/config-head
 // head: {
 //   title: 'phaidra-ui-nuxt',
 //   htmlAttrs: {
 //     lang: 'en'
 //   },
 //   meta: [
 //     { charset: 'utf-8' },
 //     { name: 'viewport', content: 'width=device-width, initial-scale=1' },
 //     { name: 'theme-color', content: config.instances[config.defaultinstance]['primary'] },
 //     { hid: 'description', name: 'description', content: '' }
 //   ],
 //   link: [
 //     { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
 //   ]
 // },

 // Global CSS: https://go.nuxtjs.dev/config-css
 // css: [
 //   '~/assets/css/d3NetworkCustom.css'
 // ],

 // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
 plugins: [
   { src: '~/plugins/axios' },
   { src: '~/plugins/vuex-store.js' },
   { src: '~/plugins/moment-formatters.js' },
  { src: '~/plugins/i18n.js' },
   { src: '~/plugins/svg-icon' },
   { src: '~/plugins/before-each.js' },
   { src: '~/plugins/after-each.js' },
   { src: '~/plugins/vue-meta.js' },
   { src: '~/plugins/lodash.js' },
  { src: '~/plugins/vuetify.js' },
   { src: '~/plugins/phaidra-vue-components' },
   { src: '~/plugins/bulk-upload-persistence.js', mode: 'client' },
   { src: '~/plugins/vuetify-runtime-components.js' }
 ],

 // Auto import components: https://go.nuxtjs.dev/config-components
 components: [
   { path: '~/components', level: 1 },
 ],

 middleware: ['auth'],
 serverMiddleware: ['~/server-middleware/redirect'],

 // Modules: https://go.nuxtjs.dev/config-modules
 modules: [],

 markdownit: {
   preset: 'default',
   linkify: true,
   breaks: true,
   runtime: true
 },

 axios: {
   baseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api', // Used as fallback if no runtime config is provided
 },

 publicRuntimeConfig: {
   primaryColor: process.env.PHAIDRA_PRIMARY_COLOR,
   defaultTheme: process.env.PHAIDRA_DEFAULT_THEME,
   darkPrimaryColor: process.env.PHAIDRA_DARK_PRIMARY_COLOR,
   baseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT,
   apiBaseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api',
   axios: {
     browserBaseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api'
   },
   defaultLocale: process.env.PHAIDRA_DEFAULT_LANGUAGE
 },

 // axios: {
 //     baseURL: 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000', // Used as fallback if no runtime config is provided
 // },
 // publicRuntimeConfig: {
 //   primaryColor: process.env.PHAIDRA_PRIMARY_COLOR,
 //   baseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT,
 //   apiBaseURL: 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000',
 //   axios: {
 //     browserBaseURL: 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000'
 //   },
 //   defaultLocale: process.env.PHAIDRA_DEFAULT_LANGUAGE
 // },
 vuetify: {
   customVariables: ['~/assets/variables.scss'],
   // Nuxt 2-era flag; Vuetify 3 registration is in plugins/vuetify.js (all components via namespace import).
   treeShake: true,
   optionsPath: './vuetify.options.js'
 },

 privateRuntimeConfig: {
   axios: {
     baseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api'
   }
 },

 // sentry: {
 //   dsn: config?.global?.monitor?.sentry?.dsn
 // },
 i18n: {
   langDir: 'locales/',
   locales: [
     {
       name: 'English',
       code: 'eng',
       iso: 'en', // keep 2-letters, used for browser language detection
       file: 'eng.json'
     },
     {
       name: 'Deutsch',
       code: 'deu',
       iso: 'de',
       file: 'deu.json'
     },
     {
       name: 'Italiano',
       code: 'ita',
       iso: 'it',
       file: 'ita.json'
     }
   ],
   strategy: 'no_prefix',
   fallbackLocale: 'eng',
   defaultLocale: 'eng',
   vueI18n: {
     silentTranslationWarn: true,
     silentFallbackWarn: true
   },
   detectBrowserLanguage: false
 },

build: {
  transpile: ['vuetify', 'phaidra-vue-components']
},
vite: {
  plugins: [vuetifyFocusTrapSsrShim()],
  server: {
    hmr: {
      // Prevent fallback to `localhost:undefined` in proxied dev setup.
      clientPort: hmrClientPort
    }
  },
  ssr: {
    noExternal: ['vuetify', 'phaidra-vue-components']
  }
},
 compatibilityDate: '2026-03-24'
})

/**
 * The MD4 algorithm is not available anymore in Node.js 17+ (because of library SSL 3).
 * In that case, silently replace MD4 by the MD5 algorithm.
 */
try {
  crypto.createHash('md4');
} catch (e) {
  console.warn('Crypto "MD4" is not supported anymore by this Node.js version');
  const origCreateHash = crypto.createHash;
  crypto.createHash = (alg, opts) => {
    return origCreateHash(alg === 'md4' ? 'md5' : alg, opts);
  };
}