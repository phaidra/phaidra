<template>
  <v-container fluid>
    <v-row justify="center">
      <v-col cols="12" md="5">
        <v-card>
          <v-card-title class="text-title-large font-weight-light text-white">{{ $t('Forgot your password?') }}</v-card-title>
          <v-card-text class="pt-6">
            <p class="mb-4">{{ $t('Enter your username or email address. If a unique matching local account exists, a password reset link will be sent.') }}</p>
            <v-text-field
              v-model="identifier"
              :label="$t('Username or email')"
              autocomplete="username"
              :disabled="loading || sent"
              @keydown.enter.prevent="requestReset"
            />
            <v-alert v-if="sent" type="success" variant="tonal">
              {{ $t('If a unique matching local account exists, a password reset link has been sent.') }}
            </v-alert>
          </v-card-text>
          <v-card-actions>
            <v-btn variant="text" to="/login">{{ $t('Back to login') }}</v-btn>
            <v-spacer />
            <v-btn color="primary" :loading="loading" :disabled="!identifier || sent" @click="requestReset">{{ $t('Send password reset') }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { config, useDocumentTitle } from '../mixins/config'

export default {
  mixins: [config],
  setup () {
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    const t = nuxtApp.$i18n?.global?.t || nuxtApp.$i18n?.t || ((value) => value)
    useHead(() => ({ title: documentTitle(t('Forgot your password?')) }))
  },
  data () {
    return { identifier: '', loading: false, sent: false }
  },
  methods: {
    async requestReset () {
      if (!this.identifier) return
      this.loading = true
      try {
        await this.$axios.post('/password-reset/request', { identifier: this.identifier })
        this.sent = true
      } catch (_) {
        this.sent = true
      } finally {
        this.loading = false
      }
    }
  }
}
</script>
