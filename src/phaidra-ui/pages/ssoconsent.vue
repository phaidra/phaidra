<template>
  <v-container>
    <v-row justify="center">
      <v-col>
        <v-card tile>
          <v-card-title class="title font-weight-light grey white--text">{{ $t('Terms of use') }}</v-card-title>
          <v-card-text style="max-height: 500px; white-space: pre-wrap;" class="overflow-y-auto">{{ tou }}</v-card-text>
          <v-divider class="mt-5"></v-divider>
          <v-card-actions>
            <v-checkbox v-model="touCheckbox" @click="agree" :disabled="loading" :loading="loading" color="primary" :label="$t('I agree to the terms of use.')"></v-checkbox>
            <v-spacer></v-spacer>
            <v-btn @click="login" :disabled="loading || !touAgreed" :loading="loading" color="primary" raised>{{ $t('Continue') }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>

</template>

<script>
import { context } from '../mixins/context'
import { config } from '../mixins/config'

export default {
  mixins: [ context, config ],
  data () {
    return {
      loading: false,
      tou: '',
      touCheckbox: false,
      touAgreed: false,
      touVersion: 0
    }
  },
  methods: {
    async agree () {
      if (this.touCheckbox) {
        this.loading = true
        try {
          let response = await this.$axios.post('/termsofuse/agree/' + this.touVersion, undefined,
            {
              headers: {
                'Authorization': 'Basic ' + btoa(this.credentials.username + ':' + this.credentials.password)
              }
            }
          )
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
          this.touAgreed = true
        } catch (error) {
          console.log(error)
          this.$store.commit('setAlerts', [ { type: 'error', msg: error } ])
        } finally {
          this.loading = false
        }
      }
    },
    async login () {
      window.location.href = '/login&target=' + encodeURIComponent(instanceconfig.api + '&consentversion=' + this.touVersion)
    }
  },
  created: async function () {
    try {
      let url = "/termsofuse";
      if (this.$i18n.locale === 'deu') {
        url = url + '?lang=de'
      }
      if (this.$i18n.locale === 'ita') {
        url = url + '?lang=it'
      }
      let toures = await this.$axios.get(url);
      if (toures.data.alerts && toures.data.alerts.length > 0) {
        this.$store.commit("setAlerts", toures.data.alerts);
      }
      this.tou = toures.data.terms;
      this.touVersion = toures.data.version;
    } catch (err) {
      console.log("err", err);
      this.$store.commit("setAlerts", [
        {
          type: 'error',
          msg: err
        }
      ]);
    }
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      vm.showtou = false
    })
  },
  beforeRouteUpdate: async function (to, from, next) {
    this.showtou = false
    next()
  }
}
</script>

