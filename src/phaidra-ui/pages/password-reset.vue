<template>
  <v-container fluid>
    <v-row justify="center">
      <v-col cols="12" md="5">
        <v-card>
          <v-card-title class="text-title-large font-weight-light text-white">{{ $t('Reset password') }}</v-card-title>
          <v-card-text class="pt-6">
            <p class="mb-4">{{ $t('Password must be at least 12 characters long and contain at least 3 character types: lowercase, uppercase, number, or special character.') }}</p>
            <v-text-field
              v-model="password"
              :label="$t('New password')"
              type="password"
              autocomplete="new-password"
              hint="Minimum 12 characters and at least 3 character types"
              persistent-hint
              :disabled="loading || complete"
            />
            <v-text-field
              v-model="confirmation"
              :label="$t('Confirm new password')"
              type="password"
              autocomplete="new-password"
              :disabled="loading || complete"
              @keydown.enter.prevent="resetPassword"
            />
            <v-alert v-if="complete" type="success" variant="tonal">{{ $t('Your password has been reset.') }}</v-alert>
          </v-card-text>
          <v-card-actions>
            <v-btn variant="text" to="/login">{{ $t('Back to login') }}</v-btn>
            <v-spacer />
            <v-btn color="primary" :loading="loading" :disabled="!canSubmit" @click="resetPassword">{{ $t('Reset password') }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { useRootStore } from '~/stores/root'
import { config, useDocumentTitle } from '../mixins/config'

export default {
  mixins: [config],
  setup () {
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    const t = nuxtApp.$i18n?.global?.t || nuxtApp.$i18n?.t || ((value) => value)
    useHead(() => ({ title: documentTitle(t('Reset password')) }))
  },
  data () {
    return { password: '', confirmation: '', loading: false, complete: false }
  },
  computed: {
    canSubmit () {
      return !this.complete && this.$route.query.token && this.password.length > 0 && this.password === this.confirmation
    }
  },
  methods: {
    clearReturnPath () {
      try {
        localStorage.removeItem('redirect')
      } catch (_) {}
    },
    async resetPassword () {
      if (!this.canSubmit) return
      this.loading = true
      try {
        const response = await this.$axios.post('/password-reset/confirm', {
          token: this.$route.query.token,
          password: this.password
        })
        if (response.data.alerts?.length) useRootStore().setAlerts(response.data.alerts)
        this.complete = true
        this.clearReturnPath()
      } catch (error) {
        const alerts = error.response?.data?.alerts
        useRootStore().setAlerts(alerts?.length ? alerts : [{ type: 'error', msg: this.$t('The password reset link is invalid or expired.') }])
      } finally {
        this.loading = false
      }
    }
  }
}
</script>
