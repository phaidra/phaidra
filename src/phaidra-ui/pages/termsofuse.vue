<template>
  <v-container>
    <h1 class="d-sr-only">{{$t('Terms of use')}}</h1>
    <v-row justify="center">
      <v-col>
        <v-card tile>
          <v-card-title class="title font-weight-light white--text">{{
            $t("Terms of use")
          }}</v-card-title>
          <v-card-text class="mt-4" style="white-space: pre-wrap">{{ tou }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { config } from "../mixins/config";

export default {
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.$t('Terms of use') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
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
        console.log("err", err);
        let data = [
          {
            type: 'error',
            msg: err
          }
        ]
        this.$store.commit("setAlerts", data);
      }
    }
  },
};
</script>
