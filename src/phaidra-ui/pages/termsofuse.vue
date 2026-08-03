<template>
  <v-container fluid class="pa-0">
    <h1 class="d-sr-only">{{$t('Terms of use')}}</h1>
    <v-row no-gutters>
      <v-col>
        <v-card tile>
          <v-card-title class="text-title-large font-weight-light text-white">{{
            $t("Terms of use")
          }}</v-card-title>
          <v-card-text class="text-body-1 mt-4" style="white-space: pre-wrap">{{ tou }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { config, useDocumentTitle } from "../mixins/config";

export default {
  mixins: [config],
  setup() {
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: documentTitle(t('Terms of use'))
      }
    })
  },
  data() {
    return {
      loading: false,
      tou: "",
    };
  },
  watch: {
     '$i18n.locale': {
        handler() {
          this.loadTermsOfUse(this.$i18n.locale);
        }
     }
  },
  created: async function () {
    this.loadTermsOfUse();
  },
  methods: {
    loadTermsOfUse: async function (locale = null) {
      try {
        let url = "/termsofuse";
        const cookieLocale = locale || this.$cookies.get("locale") || this.$i18n.locale;
        console.log("cookieLocale", cookieLocale);
        if (cookieLocale === 'deu') {
          url = url + '?lang=de'
        }
        if (cookieLocale === 'ita') {
          url = url + '?lang=it'
        }
        let toures = await this.$axios.get(url);
        if (toures.data.alerts && toures.data.alerts.length > 0) {
          this.$store.commit("setAlerts", toures.data.alerts);
        }
        this.tou = toures.data.terms;
      } catch (err) {
        if (err?.response?.data?.alerts?.length > 0) {
          this.$store.commit("setAlerts", err.response.data.alerts);
          return;
        }
        const msg = err?.message || 'Error getting terms of use';
        this.$store.commit("setAlerts", [{ type: 'error', msg }]);
      }
    }
  },
};
</script>
