import config from './config/phaidra-ui'
const path = require('path')

export default {
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
    { src: '~/plugins/svg-icon' },
    { src: '~/plugins/before-each.js' },
    { src: '~/plugins/after-each.js' },
    { src: '~/plugins/vue-meta.js' },
    { src: '~/plugins/lodash.js' },
    { src: '~/plugins/vuetify.js', mode: 'client' },
    { src: '~/plugins/phaidra-vue-components' }
  ],

  // Auto import components: https://go.nuxtjs.dev/config-components
  components: [
    { path: '~/custom-components', level: 0 },
    { path: '~/components', level: 1 },
  ],

  middleware: ['auth'],

  serverMiddleware: ['~/server-middleware/redirect'],

  // Modules for dev and build (recommended): https://go.nuxtjs.dev/config-modules
  buildModules: [
    // https://go.nuxtjs.dev/vuetify
    '@nuxtjs/vuetify'
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: [
    'nuxt-i18n',
    '@nuxtjs/axios',
    '@nuxt/http',
    ['cookie-universal-nuxt', { alias: 'cookies' }],
    '@nuxtjs/sentry',
    'nuxt-helmet'
  ],
  axios: {
    baseURL: 'http://api:3000', // Used as fallback if no runtime config is provided
  },
  publicRuntimeConfig: {
    primaryColor: process.env.PHAIDRA_PRIMARY_COLOR,
    baseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT,
    apiBaseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api',
    axios: {
      browserBaseURL: process.env.OUTSIDE_HTTP_SCHEME + '://' + process.env.PHAIDRA_HOSTNAME + process.env.PHAIDRA_PORTSTUB + process.env.PHAIDRA_HOSTPORT + '/api'
    }
  },
  vuetify: {
    customVariables: ['~/assets/variables.scss'],
    optionsPath: './vuetify.options.js'
  },
  privateRuntimeConfig: {
    axios: {
      baseURL: 'http://api:3000'
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
        file: 'eng'
      },
      {
        name: 'Deutsch',
        code: 'deu',
        iso: 'de',
        file: 'deu'
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

  alias: {
    vue: path.resolve(path.join(__dirname, 'node_modules', 'vue')),
    vuetify: path.resolve(path.join(__dirname, 'node_modules', 'vuetify'))
  },

  // Build Configuration: https://go.nuxtjs.dev/config-build
  build: {
    extend(config, { isDev, isClient }) {
      config.node = {
        fs: 'empty'
      }
      config.resolve.alias.vue = "vue/dist/vue.esm.js"
    },
    transpile: ['phaidra-vue-components', 'vuetify/lib']
  }
}
