<template>
  <v-container>
    <h1 class="d-sr-only">{{$t('Login')}}</h1>
    <v-row v-show="showtou" justify="center">
      <v-col>
        <v-card tile>
          <v-card-title class="title font-weight-light text-white">{{ $t('Terms of use') }}</v-card-title>
          <v-card-text style="max-height: 500px; white-space: pre-wrap;" class="overflow-y-auto mt-4">{{ tou }}</v-card-text>
          <v-divider class="mt-4"></v-divider>
          <v-card-actions class="pa-4">
            <v-checkbox v-model="touCheckbox" :disabled="loading" color="primary" :label="$t('I agree to the terms of use.')"></v-checkbox>
            <v-spacer></v-spacer>
            <v-btn @click="agree" :disabled="loading || !touCheckbox" :loading="loading" color="primary" variant="elevated">{{ $t('Continue') }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    <v-row v-show="!showtou" justify="center">
      <v-col md="4">
        <v-form v-model="valid">
          <v-card>
            <v-card-title class="title font-weight-light text-white">{{ $t('Login') }}</v-card-title>
            <v-card-text>
              <v-row justify="center" class="mt-4">
                <v-col cols="10">
                  <v-text-field
	                  :disabled="loading"
	                  :label="$t('Username')"
	                  v-model="credentials.username"
	                  required
	                  variant="filled"
	                  :placeholder="' '"
	                  :autocomplete="'username'"
	                  @keydown.enter.prevent="login"
	                  ></v-text-field>
	                  <v-text-field
	                  :disabled="loading"
	                  :label="$t('Password')"
	                  v-model="credentials.password"
	                  required
	                  variant="filled"
	                  :placeholder="' '"
	                  :append-inner-icon="passVisibility ? 'mdi-eye' : 'mdi-eye-off'"
	                  @click:append-inner="toggleVisibility"
	                  :type="passVisibility ? 'password' : 'text'"
	                  :autocomplete="'current-password'"
	                  @keydown.enter.prevent="login"
	                  ></v-text-field>
                </v-col>
              </v-row>
            </v-card-text>
            <v-divider class="mt-4"></v-divider>
            <v-card-actions class="pa-4">
              <v-spacer></v-spacer>
              <v-btn @click="login" :disabled="loading" :loading="loading" color="primary" variant="elevated">{{ $t('Login') }}</v-btn>
            </v-card-actions>
          </v-card>
        </v-form>
      </v-col>
    </v-row>
  </v-container>

</template>

<script>
import { context } from '../mixins/context'
import { config } from '../mixins/config'

export default {
  mixins: [ context, config ],
  setup() {
    const nuxtApp = useNuxtApp()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: this.documentTitle(t('Login'))
      }
    })
  },
  data () {
    return {
      passVisibility: true,
      credentials: {
        username: '',
        password: ''
      },
      valid: false,
      loading: false,
      showtou: false,
      tou: '',
      touCheckbox: false,
      touAgreed: false,
      touVersion: 0
    }
  },
  watch: {
    '$i18n.locale': {
      handler() {
        this.getTermsOfUse()
      }
    }
  },
  methods: {
    async agree () {
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
        // Proceed with login after agreeing to terms
        await this.$store.dispatch('login', this.credentials)
        if (this.signedin) {
          this.$router.push(this.localeLocation({path: localStorage.getItem('redirect') || '/'}))
        }
      } catch (error) {
        console.log(error)
        const alerts = error.response?.data?.alerts
        if (alerts?.length > 0) {
          this.$store.commit('setAlerts', alerts)
        }
      } finally {
        this.loading = false
      }
    },
    async getTermsOfUse () {
      let url = "/termsofuse";
      if (this.$i18n.locale === 'deu') {
        url = url + '?lang=de'
      }
      if (this.$i18n.locale === 'ita') {
        url = url + '?lang=it'
      }
      let toures = await this.$axios.get(url)
      if (toures.data.alerts && toures.data.alerts.length > 0) {
        this.$store.commit('setAlerts', toures.data.alerts)
      }
      this.tou = toures.data.terms
      this.touVersion = toures.data.version
    },
    async login () {
      this.loading = true
      try {
        let response = await this.$axios.get('/termsofuse/getagreed?lang=' + this.$i18n.locale.substring(0, 2),
          {
            headers: {
              'Authorization': 'Basic ' + btoa(this.credentials.username + ':' + this.credentials.password)
            }
          }
        )
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (!response.data.agreed) {
          await this.getTermsOfUse()
          this.showtou = true
          return
        } else {
          await this.$store.dispatch('login', this.credentials)
          if (this.signedin) {
            this.$router.push(this.localeLocation({path: localStorage.getItem('redirect') || '/'}))
          }
        }
      } catch (error) {
        console.log(error)
        const alerts = error.response?.data?.alerts
        if (alerts?.length > 0) {
          this.$store.commit('setAlerts', alerts)
        }
      } finally {
        this.loading = false
      }
    },
    toggleVisibility: function () {
      this.passVisibility = !this.passVisibility
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

