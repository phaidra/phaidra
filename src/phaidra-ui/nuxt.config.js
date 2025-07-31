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
    { src: '~/plugins/phaidra-vue-components' },
    { src: '~/plugins/bulk-upload-persistence.js', mode: 'client' },
    { src: '~/plugins/vuetify-runtime-components.js' }
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
    'nuxt-helmet',
    '@nuxtjs/markdownit'
  ],

  markdownit: {
    preset: 'default',
    linkify: true,
    breaks: true,
    runtime: true
  },
  axios: {
    baseURL: 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000', // Used as fallback if no runtime config is provided
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
    customVariables: ['~/assets/variables.scss'], // Only works if treeshake is enabled
    treeShake: true, // If enabled, Vuetify components used in runtime templates need to be imported in the plugins/vuetify-runtime-components.js file
    optionsPath: './vuetify.options.js'
  },
  privateRuntimeConfig: {
    axios: {
      baseURL: 'http://' + process.env.PHAIDRA_API_HOST_INTERNAL + ':3000'
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
      config.module.rules.push(
        {
          test: /\.mjs$/,
          include: /node_modules/,
          type: "javascript/auto"
        }
      )
    },
    transpile: ['phaidra-vue-components', 'vuetify/lib']
  }
}

const crypto = require('crypto');

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