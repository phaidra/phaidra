<template>
  <v-app>
    <v-container class="px-4" fluid v-if="!loading">
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
                  <p-breadcrumbs :items="breadcrumbs" v-if="$route.path === '/' ? !instanceconfig.hideBreadcrumbsOnHomepage : true"></p-breadcrumbs>
                </client-only>

                <template v-for="(alert, i) in alerts">
                  <v-snackbar
                    :key="'altsnack' + i"
                    class="font-weight-regular"
                    top
                    color="success"
                    v-if="alert.type === 'success'"
                    v-model="showSnackbar"
                  >
                    <span v-if="alert.key && alert.params">{{ $t(alert.key, alert.params) }}</span>
                    <span v-else>{{ $t(alert.msg) }}</span>
                    <v-btn dark text @click.native="dismiss(alert)">OK</v-btn>
                  </v-snackbar>
                </template>

                <template v-if="showAlerts">
                  <v-row
                    justify="center"
                    v-for="(alert, i) in alerts"
                    :key="'alert' + i"
                  >
                    <v-col cols="12">
                      <v-alert
                        v-if="alert.type !== 'success'"
                        :type="alert.type === 'danger' ? 'error' : alert.type"
                        :value="true"
                        transition="slide-y-transition"
                      >
                        <v-row align="center">
                          <v-col class="grow">{{ $t(alert.msg) }}</v-col>
                          <v-col class="shrink">
                            <v-btn icon @click.native="dismiss(alert)"
                              ><v-icon>mdi-close</v-icon></v-btn
                            >
                          </v-col>
                        </v-row>
                      </v-alert>
                    </v-col>
                  </v-row>
                </template>

                <transition name="fade" mode="out-in">
                  <v-col>
                    <Nuxt/>
                  </v-col>
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
  </v-app>
</template>

<script>
import "@/compiled-icons/material-social-person";
import "@/compiled-icons/univie-right";
import "@/compiled-icons/univie-sprache";
import { config } from "../mixins/config";
import { context } from "../mixins/context";
import FaviconMixin from '../mixins/favicon'
import Vue from "vue";
import moment from "moment";
import "@/assets/css/material-icons.css";

export default {
  mixins: [config, context, FaviconMixin],
  data() {
    return {
      loading: true,
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
      title: this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
      meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { name: 'theme-color', content: this.$vuetify.theme.dark ? this.$config.darkPrimaryColor : this.$config.primaryColor }
      ]
    };
    if (this.instanceconfig.googlesiteverificationcode) {
      metaInfo.meta.push({
        name: 'google-site-verification', 
        content: this.instanceconfig.googlesiteverificationcode
      })
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
    loadInstanceConfigToStore: async function() {
      this.loading = true
      try {
        let settingResponse = await this.$axios.get("/config/public");
        if(settingResponse?.data?.public_config){
          if(settingResponse?.data?.public_config?.faviconText){
            this.setFavIconText(settingResponse?.data?.public_config?.faviconText)
          }
          this.$store.dispatch("setInstanceConfig", settingResponse?.data?.public_config);
          this.$store.dispatch("vocabulary/setInstanceConfig", settingResponse?.data?.public_config);
          if (settingResponse?.data?.public_config?.data_i18n) {
            this.i18n_override = settingResponse?.data?.public_config?.data_i18n
          }
          if (settingResponse?.data?.public_config?.data_facetqueries) {
            if (settingResponse?.data?.public_config?.data_facetqueries) {
              if (settingResponse?.data?.public_config?.data_facetqueries.length > 0) {
                this.$store.commit("search/setFacetQueries", settingResponse?.data?.public_config?.data_facetqueries)
              }
            }
          }
        }
        this.$store.commit("setInstanceConfigBaseUrl", this.$config.baseURL);
        this.$store.commit("setInstanceConfigApiBaseUrl", this.$config.apiBaseURL);
      } catch (error) {
        console.error(error)
      } finally {
        this.loading = false;
      }
      return true
    },
    setFavIconText(svgText) {
      const base64Svg = Buffer.from(svgText).toString('base64')
      this.faviconUrl = `data:image/svg+xml;base64,${base64Svg}`
    }
  },
  mounted() {
    if (this.instanceconfig.cms_css && this.instanceconfig.cms_css !== '') {
      const style = document.createElement('style');
      style.type = 'text/css';
      style.innerHTML = this.instanceconfig.cms_css;
      document.head.appendChild(style);
    }

    Object.entries(this.i18n_override).forEach(([lang, messages]) => {
        this.$i18n.mergeLocaleMessage(lang, messages)
      }
    )
    if (!this.signedin) {
      let token = window.localStorage.getItem("XSRF-TOKEN")
      if (token) {
        this.$store.commit('setToken', token)
        this.$store.dispatch('getLoginData')
      }
    }
  },
  async fetch() {
    await this.loadInstanceConfigToStore()
  },
  computed: {
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
  },
  created: function () {
    Vue.filter("datetime", function (value) {
      if (value) {
        return moment(String(value)).format("DD.MM.YYYY hh:mm:ss");
      }
    });
    Vue.filter('datetimeutc', function (value) {
      if (value) {
        return moment.utc(String(value)).format('DD.MM.YYYY hh:mm:ss')
      }
    })
    Vue.filter("date", function (value) {
      if (value) {
        return moment(String(value)).format("DD.MM.YYYY");
      }
    });
    Vue.filter("unixtime", function (value) {
      if (value) {
        return moment.unix(String(value)).format("DD.MM.YYYY hh:mm:ss");
      }
    });

    Vue.filter("bytes", function (bytes, precision) {
      if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) return "-";
      if (typeof precision === "undefined") precision = 1;
      var units = ["bytes", "kB", "MB", "GB", "TB", "PB"];
      var number = Math.floor(Math.log(bytes) / Math.log(1024));
      return (
        (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) +
        " " +
        units[number]
      );
    });

    Vue.filter("truncate", function (text, length, clamp) {
      clamp = clamp || "...";
      length = length || 30;

      if (text.length <= length) return text;

      var tcText = text.slice(0, length - clamp.length);
      var last = tcText.length - 1;

      while (last > 0 && tcText[last] !== " " && tcText[last] !== clamp[0])
        last -= 1;

      // Fix for case when text does not have any space
      last = last || length - clamp.length;

      tcText = tcText.slice(0, last);

      return tcText + clamp;
    });
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

a.v-btn, a {
  text-decoration: none;
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

.theme--light.v-card > .v-card__title,
.theme--dark.v-card > .v-card__title {
  background-color: var(--v-cardtitlebg-base);
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
  background-color: var(--v-primary-base) !important;
  border-color: var(--v-primary-base) !important;
}

.header .ph-button {
  background-color: var(--v-cardtitlebg-base)!important;
  border-color: var(--v-cardtitlebg-base)!important;
}

.header {
  box-shadow: 48px 0 0 0 white, -48px 0 0 0 white,
    0 8px 40px -6px rgba(70, 70, 70, 0.4);
  background-color: white;
  z-index: 1;
}

.theme--dark .header {
  box-shadow: 48px 0 0 0 #121212, -48px 0 0 0 #121212,
  0 8px 40px -6px rgba(70, 70, 70, 0.4);
  background-color: #121212;
}

.header .v-toolbar__items .v-btn {
  margin-left: 1px;
}

.header .ph-button-bg {
  background-color: var(--v-cardtitlebg-base) !important;
  border-color: var(--v-cardtitlebg-base) !important;
}

.header .ph-button-bg-dark {
  background-color: #272727;
  border-color: #272727;
}

.header .ph-button-bg-active {
  background-color: var(--v-primary-base) !important;
  border-color: var(--v-primary-base) !important;
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

.theme--dark .border-left {
  border-left: 1px solid;
  border-color: rgba(255, 255, 255, 0.25);
}

#app .v-btn {
  text-transform: none;
}
#app .v-tabs__div {
  text-transform: none;
  font-weight: 300;
}

.univie-grey {
  color: #7b7b7b;
}

.jsonld-border-left {
  border-left: 1px solid;
  border-color: rgba(0, 0, 0, 0.12);
}

.theme--dark .jsonld-border-left {
  border-left: 1px solid;
  border-color: rgba(255, 255, 255, 0.25);
}
.v-application .pointer-disabled {
  pointer-events: none;
}
</style>

<style scoped>
.top-margin-lang {
  margin-top: 0px;
}

.content {
  min-height: 800px;
}

.container {
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
