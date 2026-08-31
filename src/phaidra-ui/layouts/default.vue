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
                <p-breadcrumbs
                  v-if="$route.path === '/' ? !instanceconfig.hideBreadcrumbsOnHomepage : true"
                  :items="breadcrumbs"
                ></p-breadcrumbs>

                <client-only>
                <template v-for="(alert, i) in alerts" :key="'altsnack' + i">
                  <v-snackbar class="font-weight-regular" top color="success"
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
                        closable
                        class="app-alert"
                        transition="slide-y-transition"
                      >
                        {{ $t(alert.msg) }}
                        <template #close>
                          <v-icon-btn
                            variant="text"
                            icon="mdi-close"
                            :aria-label="$t('Close')"
                            @click="dismiss(alert)"
                          />
                        </template>
                      </v-alert>
                    </v-col>
                  </v-row>
                </template>
                </client-only>

                <v-row no-gutters>
                  <v-col>
                    <slot />
                  </v-col>
                </v-row>
              </v-col>
            </v-row>
          </v-main>
          <v-footer :padless="true" color="transparent">
            <ExtFooter></ExtFooter>
          </v-footer>
        </v-col>
      </v-row>
    </v-container>
    <ClientOnly>
      <CookieBanner />
    </ClientOnly>
  </v-app>
</template>

<script>
import { useRootStore } from '~/stores/root'
import { useVocabularyStore } from 'phaidra-vue-components/src/stores/vocabulary'
import { useSearchStore } from 'phaidra-vue-components/src/stores/search'
import { config } from "../mixins/config";
import { context } from "../mixins/context";
import FaviconMixin from '../mixins/favicon'
import CookieBanner from '../components/CookieBanner.vue'
import moment from "moment";
import { encodeUtf8ToBase64 } from '@/utils/encode-base64'
import { applyI18nOverrides, applyInfoBannerMessage } from '@/utils/i18n-overrides'
import "@/assets/css/material-icons.css";

export default {
  setup() {
    const nuxtApp = useNuxtApp()
    const runtime = useRuntimeConfig()

    useHead(() => {
      const instanceconfig = useRootStore(nuxtApp.$pinia)?.instanceconfig || {}

      const currentLocale = nuxtApp.$i18n?.locale || 'eng'

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
      const cmsCss = (instanceconfig.cms_css || '').trim()
      const style = cmsCss
        ? [{ id: 'instance-cms-css', children: cmsCss }]
        : []

      return {
        htmlAttrs: { lang },
        title,
        meta,
        script,
        style
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
        lang: this.$i18n.locale === 'deu' ? 'de' : this.$i18n.locale === 'ita' ? 'it' : 'en'
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
    },
    '$route.path'(to, from) {
      if (to !== from) {
        useRootStore().clearAlerts()
      }
    }
  },
  methods: {
    dismiss: function (alert) {
      useRootStore().clearAlert(alert);
    },
    loadInstanceConfigToStore: async function () {
      this.loading = true
      try {
        useRootStore().setInstanceConfigCookieDomain(this.$config?.public?.cookieDomain);
        let settingResponse = await this.$axios.get("/config/public");
        const publicConfig = settingResponse?.data?.public_config
        if (publicConfig) {
          if (publicConfig?.faviconText) {
            this.setFavIconText(publicConfig.faviconText)
          }
          const dataI18n = publicConfig?.data_i18n && typeof publicConfig.data_i18n === 'object'
            ? publicConfig.data_i18n
            : {}
          await useRootStore().setInstanceConfig({ ...publicConfig, data_i18n: dataI18n });
          useVocabularyStore().setInstanceConfig(publicConfig);
          if (publicConfig?.data_facetqueries?.length > 0) {
            useSearchStore().setFacetQueries(publicConfig.data_facetqueries)
          }

          // Do not overwrite API-provided values with undefined runtime config.
          if (publicConfig.baseurl) {
            useRootStore().setInstanceConfigBaseUrl(publicConfig.baseurl);
          } else if (this.$config?.public?.baseURL) {
            useRootStore().setInstanceConfigBaseUrl(this.$config?.public?.baseURL);
          }
          if (publicConfig.api) {
            useRootStore().setInstanceConfigApiBaseUrl(publicConfig.api);
          } else if (this.$config?.public?.apiBaseURL) {
            useRootStore().setInstanceConfigApiBaseUrl(this.$config?.public?.apiBaseURL);
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
      applyI18nOverrides(this.$i18n, useRootStore().instanceconfig?.data_i18n)
      applyInfoBannerMessage(this.$i18n, this.instanceconfig?.infoBannerMessage)
    },
    refreshBreadcrumbs() {
      const localePath = this.$localePath || ((path) => path)
      useRootStore().updateBreadcrumbs({
        to: this.$route,
        from: this.$route,
        localePath
      })
    },
    setFavIconText(svgText) {
      const base64Svg = encodeUtf8ToBase64(svgText)
      this.faviconUrl = `data:image/svg+xml;base64,${base64Svg}`
    }
  },
  async serverPrefetch() {
    if (!this.hasLoadedInstanceConfig) {
      await this.loadInstanceConfigToStore()
    }
    this.applyRuntimeOverrides()
  },
  async mounted() {
    if (!this.hasLoadedInstanceConfig) {
      await this.loadInstanceConfigToStore()
    }
    this.applyRuntimeOverrides()
    if (!this.signedin) {
      let token = window.localStorage.getItem("XSRF-TOKEN")
      if (token) {
        useRootStore().setToken(token)
        useRootStore().getLoginData()
      }
    }
  },
  computed: {
    prettyInstanceconfig: function () {
      return JSON.stringify(this.instanceconfig, null, 2)
    },
    showAlerts: function () {
      if (useRootStore().alerts.length > 0) {
        let onlySuccess = true;
        for (let a of useRootStore().alerts) {
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
        return useRootStore().snackbar;
      },
      set: function (newValue) {
        if (!newValue) {
          useRootStore().hideSnackbar();
        }
      },
    },
    breadcrumbs() {
      return useRootStore().breadcrumbs;
    },
    alerts() {
      return useRootStore().alerts;
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
.v-application a {
    cursor: pointer;
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

.v-application a:not(.v-btn):not([class*='text-']),
.v-overlay-container a:not(.v-btn):not([class*='text-']) {
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

.header .v-toolbar__content .v-btn,
.header .v-toolbar-items .v-btn {
  margin-left: 1px;
  box-shadow: none !important;
  height: calc(var(--v-btn-height) - 4px) !important;
  min-height: calc(var(--v-btn-height) - 4px) !important;
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


.v-toolbar__items .v-btn {
  margin-left: 1px;
}

.ph-button-bg {
  background-color: rgb(var(--v-theme-cardtitlebg)) !important;
  border-color: rgb(var(--v-theme-cardtitlebg)) !important;
}

.ph-button-bg-dark {
  background-color: #272727;
  border-color: #272727;
}

.ph-button-bg-active {
  background-color: rgb(var(--v-theme-primary)) !important;
  border-color: rgb(var(--v-theme-primary)) !important;
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

.v-input--indent-details .v-input__details {
    margin-bottom: 8px;
}
h1, h2, h3, h4, h5, h6 {
  padding: 0;
  margin: 0;
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

.v-application .px-4 {
    padding-right: 16px !important;
    padding-left: 16px !important;
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

.app-alert :deep(.v-alert__prepend),
.app-alert :deep(.v-alert__close),
.app-alert :deep(.v-alert__content) {
  align-self: center;
}
</style>
