import crypto from 'crypto'
import path from 'path'
import { fileURLToPath } from 'url'
import { defineNuxtConfig } from 'nuxt/config'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const hmrClientPort = Number(process.env.PHAIDRA_HOSTPORT || 8899)
const viteUsePolling = (process.env.VITE_USE_POLLING || 'true') === 'true'
const viteWatchInterval = Number(process.env.VITE_WATCH_INTERVAL || 250)
const phaidraVueComponentsRoot = path.resolve(__dirname, '../phaidra-vue-components')
const vuetifyFocusTrapShimPath = path.resolve(__dirname, 'shims/vuetify-focusTrap.js')
const envOrigin = `${process.env.OUTSIDE_HTTP_SCHEME || 'http'}://${process.env.PHAIDRA_HOSTNAME || 'localhost'}${process.env.PHAIDRA_PORTSTUB || ':'}${process.env.PHAIDRA_HOSTPORT || '8899'}`
const publicApiBaseURL = process.env.PHAIDRA_API_BASE_URL || `${envOrigin}/api`
const internalApiHost = process.env.PHAIDRA_API_INTERNAL_HOST || process.env.PHAIDRA_API_HOST || 'api'
const internalApiPort = process.env.PHAIDRA_API_INTERNAL_PORT || process.env.PHAIDRA_API_PORT || '3000'
// Internal API service URL used by SSR inside Docker network.
// Keep it without "/api" because the api container serves routes at root (e.g. /object/:pid/info).
const fallbackInternalApiBaseURL = `http://${internalApiHost}:${internalApiPort}`
let apiBaseURL = process.env.PHAIDRA_API_BASE_URL_INTERNAL || ''

if (!apiBaseURL) {
  // PHAIDRA_API_BASE_URL can point to browser/public host (localhost:8899).
  // For SSR inside Docker, localhost points to UI container itself, so force internal API service URL.
  if (process.env.PHAIDRA_API_BASE_URL) {
    try {
      const parsed = new URL(process.env.PHAIDRA_API_BASE_URL)
      if (!['localhost', '127.0.0.1', '::1'].includes(parsed.hostname)) {
        apiBaseURL = process.env.PHAIDRA_API_BASE_URL
      }
    } catch (_) { }
  }
  if (!apiBaseURL) {
    apiBaseURL = fallbackInternalApiBaseURL
  }
}
const publicBaseURL = process.env.PHAIDRA_BASE_URL || publicApiBaseURL.replace(/\/api\/?$/, '')

/** Redirect Vuetify's internal focusTrap module to `shims/vuetify-focusTrap.js` (SSR-safe teardown). */
function vuetifyFocusTrapSsrShim() {
  const shimPath = path.resolve(__dirname, 'shims/vuetify-focusTrap.js')
  return {
    name: 'vuetify-focus-trap-ssr-shim',
    enforce: 'pre',
    resolveId(id) {
      const normalized = id.split(path.sep).join('/')
      if (normalized.includes('focusTrap')) {
        return shimPath
      }
      return undefined
    }
  }
}

export default defineNuxtConfig({
  // Keep Nuxt 3 folder layout while running on Nuxt 4.
  srcDir: '.',
  dir: {
    app: 'app',
    public: 'static'
  },
  alias: {
    'vuetify/lib/composables/focusTrap': vuetifyFocusTrapShimPath,
    'vuetify/lib/composables/focusTrap.js': vuetifyFocusTrapShimPath
  },

  runtimeConfig: {
    apiBaseURL,
    public: {
      primaryColor: process.env.PHAIDRA_PRIMARY_COLOR,
      defaultTheme: process.env.PHAIDRA_DEFAULT_THEME,
      darkPrimaryColor: process.env.PHAIDRA_DARK_PRIMARY_COLOR,
      baseURL: publicBaseURL,
      apiBaseURL: publicApiBaseURL,
      axios: {
        browserBaseURL: publicApiBaseURL
      },
      defaultLocale: process.env.PHAIDRA_DEFAULT_LANGUAGE || 'eng',
      cookieDomain: process.env.COOKIE_DOMAIN || process.env.PHAIDRA_HOSTNAME
    }
  },

  plugins: [
    { src: '~/plugins/axios' },
    { src: '~/plugins/vuex-store.js' },
    { src: '~/plugins/moment-formatters.js' },
    { src: '~/plugins/i18n.js' },
    { src: '~/plugins/locale-persistence.js' },
    { src: '~/plugins/svg-icon' },
    { src: '~/plugins/before-each.js' },
    { src: '~/plugins/after-each.js' },
    { src: '~/plugins/lodash.js' },
    { src: '~/plugins/vuetify.js' },
    { src: '~/plugins/phaidra-vue-components' },
    { src: '~/plugins/bulk-upload-persistence.client.js' },
    { src: '~/plugins/vuetify-runtime-components.js' }
  ],

  components: [
    { path: '~/components', level: 1 }
  ],

  modules: [],

  i18n: {
    langDir: 'locales/',
    locales: [
      {
        name: 'English',
        code: 'eng',
        iso: 'en',
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
    resolve: {
      alias: {
        'phaidra-vue-components': phaidraVueComponentsRoot
      },
      dedupe: ['vue', 'vue-router', 'vue-i18n', 'vuetify', 'vuex']
    },
    optimizeDeps: {
      exclude: ['phaidra-vue-components'],
      include: [
        '@vue/compiler-dom',
        '@vue/devtools-core',
        '@vue/devtools-kit',
        'axios',
        'moment',
        'vuex',
        'vue-i18n',
        'lodash',
        'qs',
        'papaparse',
        'autolinker',
        'maska/vue',
        'leaflet',
        '@vue-leaflet/vue-leaflet',
        'file-saver',
        'vue-draggable-next'
      ]
    },
    server: {
      hmr: {
        clientPort: hmrClientPort
      },
      watch: {
        usePolling: viteUsePolling,
        interval: viteWatchInterval
      },
      fs: {
        allow: [__dirname, phaidraVueComponentsRoot]
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
  crypto.createHash('md4')
} catch (e) {
  const origCreateHash = crypto.createHash
  crypto.createHash = (alg, opts) => {
    return origCreateHash(alg === 'md4' ? 'md5' : alg, opts)
  }
}
