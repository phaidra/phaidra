<template>
  <v-app>
    <v-container class="px-4 px-md-0" fluid>
      <v-row no-gutters>
        <v-col>
          <header>
            <a href="#main-content" class="skip-link d-sr-only-focusable">{{ $t("Skip to main content") }}</a>
            <ExtHeader></ExtHeader>
          </header>
          <v-main id="main-content">
            <v-row>
              <v-col cols="12" md="10" offset-md="1" class="content">
                <client-only>
                  <p-breadcrumbs :items="breadcrumbs"
                    v-if="$route.path === '/' ? !instanceconfig.hideBreadcrumbsOnHomepage : true"></p-breadcrumbs>
                </client-only>

                <template v-for="(alert, i) in alerts">
                  <v-snackbar :key="'altsnack' + i" class="font-weight-regular" top color="success"
                    v-if="alert.type === 'success'" v-model="showSnackbar">
                    <span v-if="alert.key && alert.params">{{ $t(alert.key, alert.params) }}</span>
                    <span v-else>{{ $t(alert.msg) }}</span>
                    <template #actions>
                      <v-btn variant="text" @click="dismiss(alert)">OK</v-btn>
                    </template>
                  </v-snackbar>
                </template>

                <template v-if="showAlerts">
                  <v-row justify="center" v-for="(alert, i) in alerts" :key="'alert' + i">
                    <v-col cols="12">
                      <v-alert
                        v-if="alert.type !== 'success' && alert.msg"
                        :type="alert.type === 'danger' ? 'error' : alert.type"
                        :model-value="true"
                        transition="slide-y-transition"
                      >
                        <v-row align="center">
                          <v-col class="grow">{{ $t(alert.msg) }}</v-col>
                          <v-col class="shrink">
                            <v-btn icon @click="dismiss(alert)"
                              ><v-icon>mdi-close</v-icon></v-btn
                            >
                          </v-col>
                        </v-row>
                      </v-alert>
                    </v-col>
                  </v-row>
                </template>

                <transition name="fade" mode="out-in">
                  <v-row no-gutters>
                    <v-col>
                      <slot />
                    </v-col>
                  </v-row>
                </transition>
              </v-col>
            </v-row>
          </v-main>
          <v-footer :padless="true" color="transparent">
            <ExtFooter></ExtFooter>
          </v-footer>
        </v-col>
      </v-row>
    </v-container>
    <client-only>
      <CookieBanner></CookieBanner>
    </client-only>
  </v-app>
</template>

<script>
import { config } from "../mixins/config";
import { context } from "../mixins/context";
import FaviconMixin from '../mixins/favicon'
import CookieBanner from '../components/CookieBanner.vue'
import moment from "moment";
import "@/assets/css/material-icons.css";

export default {
  setup() {
    const nuxtApp = useNuxtApp()
    const runtime = useRuntimeConfig()

    useHead(() => {
      const store = nuxtApp.$store
      const instanceconfig = store?.state?.instanceconfig || {}

      // Detect locale during SSR from cookies, similar to theme detection.
      let currentLocale = nuxtApp.$i18n?.locale || 'eng'
      if (import.meta.server) {
        const ssrCookie = nuxtApp.$cookies?.get('locale')
        if (ssrCookie) currentLocale = ssrCookie
      }

      const lang = currentLocale === 'deu' ? 'de' : currentLocale === 'ita' ? 'it' : 'en'
      const titlePart = nuxtApp.$i18n?.t ? nuxtApp.$i18n.t(instanceconfig.title) : (instanceconfig.title || '')
      const institutionPart = nuxtApp.$i18n?.t ? nuxtApp.$i18n.t(instanceconfig.institution) : (instanceconfig.institution || '')
      const title = `${titlePart} - ${institutionPart}`.trim()

      const dark = nuxtApp.$vuetify?.theme?.global?.current?.value?.dark
      const themeColor = dark ? runtime.public.darkPrimaryColor : runtime.public.primaryColor

      const meta = [
        { charset: 'utf-8' },
        { name: 'Generator', content: 'PHAIDRA' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'theme-color', content: themeColor }
      ]

      if (instanceconfig.googlesiteverificationcode) {
        meta.push({
          name: 'google-site-verification',
          content: instanceconfig.googlesiteverificationcode
        })
      }

      const script = []
      if (instanceconfig.customJavaScript && instanceconfig.customJavaScript.trim()) {
        let scriptContent = instanceconfig.customJavaScript.trim()
        scriptContent = scriptContent.replace(/<script[^>]*>/gi, '').replace(/<\/script>/gi, '')
        script.push({
          type: 'text/javascript',
          children: scriptContent
        })
      }

      return {
        htmlAttrs: { lang },
        title,
        meta,
        script
      }
    })
  },
  components: {
    CookieBanner
  },
  mixins: [config, context, FaviconMixin],
  data() {
    return {
      loading: false,
      hasLoadedInstanceConfig: false,
      i18n_override: {},
      faviconUrl: ``
    }
  },
  metaInfo() {
    // Detect locale during SSR from cookies, similar to theme detection
    let currentLocale = this.$i18n.locale;
    if (process.server) {
      // During SSR, try to get locale from cookies
      const ssrCookie = this.$cookies?.get('locale');
      if (ssrCookie) {
        currentLocale = ssrCookie;
      }
    }

    let metaInfo = {
      htmlAttrs: {
        lang: currentLocale === 'deu' ? 'de' : currentLocale === 'ita' ? 'it' : 'en'
      },
      title: this.documentTitle(),
      meta: [
        { charset: 'utf-8' },
        { name: 'Generator', content: 'PHAIDRA' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'theme-color', content: this.$vuetify?.theme?.global?.current?.value?.dark ? this.$config?.public?.darkPrimaryColor : this.$config?.public?.primaryColor }
      ],
      script: []
    };
    if (this.instanceconfig.googlesiteverificationcode) {
      metaInfo.meta.push({
        name: 'google-site-verification',
        content: this.instanceconfig.googlesiteverificationcode
      })
    }

    if (this.instanceconfig.customJavaScript && this.instanceconfig.customJavaScript.trim()) {
      let scriptContent = this.instanceconfig.customJavaScript.trim();
      scriptContent = scriptContent.replace(/<script[^>]*>/gi, '').replace(/<\/script>/gi, '');

      metaInfo.script.push({
        type: 'text/javascript',
        innerHTML: scriptContent,
        body: false
      })
      metaInfo.__dangerouslyDisableSanitizers = ['script']
    }

    return metaInfo;
  },
  watch: {
    faviconUrl(val) {
      this.updateFavicon(val)
    }
  },
  methods: {
    dismiss: function (alert) {
      this.$store.commit("clearAlert", alert);
    },
    loadInstanceConfigToStore: async function () {
      this.loading = true
      try {
        this.$store.commit("setInstanceConfigCookieDomain", this.$config?.public?.cookieDomain);
        let settingResponse = await this.$axios.get("/config/public");
        const publicConfig = settingResponse?.data?.public_config
        if (publicConfig) {
          if (publicConfig?.faviconText) {
            this.setFavIconText(publicConfig.faviconText)
          }
          await this.$store.dispatch("setInstanceConfig", publicConfig);
          this.$store.dispatch("vocabulary/setInstanceConfig", publicConfig);
          this.mergeInfoBannerMessage(publicConfig?.infoBannerMessage)
          if (publicConfig?.data_i18n) {
            this.i18n_override = publicConfig.data_i18n
          }
          if (publicConfig?.data_facetqueries?.length > 0) {
            this.$store.commit("search/setFacetQueries", publicConfig.data_facetqueries)
          }

          // Do not overwrite API-provided values with undefined runtime config.
          if (publicConfig.baseurl) {
            this.$store.commit("setInstanceConfigBaseUrl", publicConfig.baseurl);
          } else if (this.$config?.public?.baseURL) {
            this.$store.commit("setInstanceConfigBaseUrl", this.$config?.public?.baseURL);
          }
          if (publicConfig.api) {
            this.$store.commit("setInstanceConfigApiBaseUrl", publicConfig.api);
          } else if (this.$config?.public?.apiBaseURL) {
            this.$store.commit("setInstanceConfigApiBaseUrl", this.$config?.public?.apiBaseURL);
          }
          this.refreshBreadcrumbs()
          this.hasLoadedInstanceConfig = true
        }
      } catch (error) {
        const status = error?.response?.status
        if (status === 404) {
          // API can be temporarily unavailable during local dev startup.
          // Keep defaults and avoid noisy stack traces in terminal logs.
          console.warn('Could not load /config/public (404), using defaults for now.')
        } else {
          console.warn('Could not load /config/public:', error?.message || error)
        }
      } finally {
        this.loading = false;
      }
      return true
    },
    applyRuntimeOverrides() {
      if (process.client && this.instanceconfig.cms_css && this.instanceconfig.cms_css !== '') {
        const style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = this.instanceconfig.cms_css;
        document.head.appendChild(style);
      }

      Object.entries(this.i18n_override).forEach(([lang, messages]) => {
        this.$i18n.mergeLocaleMessage(lang, messages)
      })
    },
    refreshBreadcrumbs() {
      const localePath = this.$localePath || ((path) => path)
      this.$store.commit('updateBreadcrumbs', {
        to: this.$route,
        from: this.$route,
        localePath
      })
    },
    setFavIconText(svgText) {
      const base64Svg = Buffer.from(svgText).toString('base64')
      this.faviconUrl = `data:image/svg+xml;base64,${base64Svg}`
    },
    mergeInfoBannerMessage(message) {
      if (message) {
        this.$i18n.mergeLocaleMessage('eng', { 'Info banner message': message })
      }
    }
  },
  async serverPrefetch() {
    if (!this.hasLoadedInstanceConfig) {
      await this.loadInstanceConfigToStore()
    }

    Object.entries(this.i18n_override).forEach(([lang, messages]) => {
      this.$i18n.mergeLocaleMessage(lang, messages)
    }
    )
    this.applyRuntimeOverrides()
  },
  async mounted() {
    if (!this.hasLoadedInstanceConfig) {
      await this.loadInstanceConfigToStore()
    }
    this.mergeInfoBannerMessage(this.instanceconfig?.infoBannerMessage)
    this.applyRuntimeOverrides()
    if (!this.signedin) {
      let token = window.localStorage.getItem("XSRF-TOKEN")
      if (token) {
        this.$store.commit('setToken', token)
        this.$store.dispatch('getLoginData')
      }
    }
  },
  computed: {
    cmsCss() {
      return this.instanceconfig?.cms_css?.trim() || ''
    },
    prettyInstanceconfig: function () {
      return JSON.stringify(this.instanceconfig, null, 2)
    },
    showAlerts: function () {
      if (this.$store.state.alerts.length > 0) {
        let onlySuccess = true;
        for (let a of this.$store.state.alerts) {
          if (a.type !== "success") {
            onlySuccess = false;
          }
        }
        return !onlySuccess;
      }
      return false;
    },
    showSnackbar: {
      get: function () {
        return this.$store.state.snackbar;
      },
      set: function (newValue) {
        if (!newValue) {
          this.$store.commit("hideSnackbar");
        }
      },
    },
    breadcrumbs() {
      return this.$store.state.breadcrumbs;
    },
    alerts() {
      return this.$store.state.alerts;
    },
  }
};
</script>
<style lang="sass">
@require '../stylus/main'
</style>

<style>
.no-padding {
  padding: 0px;
}

.svg-icon {
  display: inline-block;
  width: 16px;
  height: 16px;
  color: inherit;
  vertical-align: middle;
  fill: none;
  stroke: currentColor;
}

.svg-fill {
  fill: currentColor;
  stroke: none;
}

.svg-up {
  transform: rotate(0deg);
}

.svg-right {
  transform: rotate(90deg);
}

.svg-down {
  transform: rotate(180deg);
}

.svg-left {
  transform: rotate(-90deg);
}

.ie-fixMinHeight {
  display: flex;
}

html,
body {
  height: 100%;
}

section {
  overflow: auto;
}

a {
  text-underline-offset: .25rem;
  text-decoration-skip-ink: none;
  text-decoration-thickness: 1px !important;
}

.v-main a {
  text-decoration: underline;
}

.v-main .breadcrumbs-container a:not(:hover) {
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

a.v-btn,
a {
  text-decoration: none;
}

.v-application a:not(.v-btn) {
  color: rgb(var(--v-theme-primary));
}

.logo {
  height: auto;
  width: auto;
  max-width: 250px;
  max-height: 150px;
}

address {
  font-style: normal;
}

.v-align-top {
  vertical-align: top;
}

.v-theme--light .v-card > .v-card-title,
.v-theme--dark .v-card > .v-card-title {
  background-color: rgb(var(--v-theme-cardtitlebg));
}

.lang-icon {
  margin-left: 5px;
}

.displayname {
  vertical-align: top;
  display: inline-block;
  margin-top: 10px;
}

.ph-button {
  color: white !important;
  box-sizing: border-box;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
  position: relative;
  outline: 0;
  border: 0;
  border-radius: 0px;
  display: inline-block;
  -ms-flex-align: center;
  align-items: center;
  padding: 0 6px;
  margin: 6px 1px 6px 0px;
  height: 30px;
  line-height: 30px;
  min-height: 30px;
  white-space: nowrap;
  min-width: 88px;
  text-align: center;
  font-weight: 300;
  font-size: 14px;
  font-style: inherit;
  font-variant: inherit;
  font-family: inherit;
  text-decoration: none;
  cursor: pointer;
  overflow: hidden;
  letter-spacing: 0.01em;
  font-weight: 400;
}

.ph-button:hover {
  background-color: #267ab3;
  text-decoration: none;
  color: white;
  font-weight: 400;
}


.header .ph-button:focus {
  background-color: rgb(var(--v-theme-primary)) !important;
  border-color: rgb(var(--v-theme-primary)) !important;
}

.header .ph-button {
  background-color: rgb(var(--v-theme-cardtitlebg)) !important;
  border-color: rgb(var(--v-theme-cardtitlebg)) !important;
}

.header {
  box-shadow: 48px 0 0 0 white, -48px 0 0 0 white,
    0 8px 40px -6px rgba(70, 70, 70, 0.4);
  background-color: white;
  z-index: 1;
}

.v-theme--dark .header {
  box-shadow: 48px 0 0 0 #121212, -48px 0 0 0 #121212,
    0 8px 40px -6px rgba(70, 70, 70, 0.4);
  background-color: #121212;
}

.header .v-toolbar__content .v-btn {
  margin-left: 1px;
}

.header .ph-button-bg {
  background-color: rgb(var(--v-theme-cardtitlebg)) !important;
  border-color: rgb(var(--v-theme-cardtitlebg)) !important;
}

.header .ph-button-bg-dark {
  background-color: #272727;
  border-color: #272727;
}

/* Active route buttons are marked with v-btn--active; force nav active color over base bg classes */
.header .ph-button-bg-active,
.header .v-btn.v-btn--active {
  background-color: rgb(var(--v-theme-primary)) !important;
  border-color: rgb(var(--v-theme-primary)) !important;
}

#quicklinks-button {
  background-color: #1a74b0;
  text-decoration: none;
  color: white;
  margin-top: 0px;
  width: 263px;
}

#quicklinks-button:hover {
  color: white;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.1s;
}
.fade-enter-from,
.fade-enter,
.fade-leave-to {
  opacity: 0;
}

.select-instance {
  max-width: 300px;
}

.border-left {
  border-left: 1px solid;
  border-color: rgba(0, 0, 0, 0.12);
}

.v-theme--dark .border-left {
  border-left: 1px solid;
  border-color: rgba(255, 255, 255, 0.25);
}

.v-application .v-btn {
  text-transform: none;
}
/*.v-application .v-tab {
  text-transform: none;
  font-weight: 300;
}*/

.univie-grey {
  color: #7b7b7b;
}

.jsonld-border-left {
  border-left: 1px solid;
  border-color: rgba(0, 0, 0, 0.12);
}

.v-theme--dark .jsonld-border-left {
  border-left: 1px solid;
  border-color: rgba(255, 255, 255, 0.25);
}

.v-application .pointer-disabled {
  pointer-events: none;
}

.ph-button:focus {
  background-color: rgb(var(--v-theme-primary)) !important;
  border-color: rgb(var(--v-theme-primary)) !important;
}

.ph-button {
  background-color: rgb(var(--v-theme-cardtitlebg))!important;
  border-color: rgb(var(--v-theme-cardtitlebg))!important;
}

.theme--dark .header {
  box-shadow: 48px 0 0 0 #121212, -48px 0 0 0 #121212,
    0 8px 40px -6px rgba(70, 70, 70, 0.4);
  background-color: #121212;
}

.v-toolbar__items .v-btn {
  margin-left: 1px;
}

.ph-button-bg {
  background-color: rgb(var(--v-theme-cardtitlebg)) !important;
  border-color: rgb(var(--v-theme-cardtitlebg)) !important;
  height: calc(var(--v-btn-height) - 4px) !important;
}

.ph-button-bg-dark {
  background-color: #272727;
  border-color: #272727;
}

.ph-button-bg-active {
  background-color: rgb(var(--v-theme-primary)) !important;
  border-color: rgb(var(--v-theme-primary)) !important;
  height: calc(var(--v-btn-height) - 4px) !important;
}
.v-toolbar__content,
.v-toolbar__extension {
  padding: 0px 16px;
}
/* .v-theme--light.v-btn.v-btn--icon {
    color: rgba(0, 0, 0, 0.54);
} */

/* .v-theme--light .v-card > .v-card-text,
.v-theme--light .v-card > .v-card-subtitle {
  color: rgba(0, 0, 0, 0.6);
} */
.v-application ul, .v-application ol {
  padding-left: 24px;
}

</style>

<style scoped>
.top-margin-lang {
  margin-top: 0px;
}

.content {
  min-height: 800px;
}

.v-container {
  padding: 0px;
}

.no-height-inherit {
  height: unset;
}

.personicon {
  align-self: center;
}

.float-right {
  float: right;
}

.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
}
</style>
