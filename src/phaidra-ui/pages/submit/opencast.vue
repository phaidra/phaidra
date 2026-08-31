<template>
  <v-container fluid class="py-6">
    <v-row justify="center">
      <v-col cols="12" md="10" lg="8">
        <h1 class="text-h5 font-weight-light mb-4">
          {{ $t('OpenCast submit title') }}
        </h1>

        <v-alert
          type="warning"
          variant="tonal"
          prominent
          border="start"
          class="mb-6"
        >
          {{ $t('OpenCast submit access rights notice') }}
        </v-alert>

        <v-row>
          <v-col cols="12" md="6">
            <v-card variant="outlined" class="h-100 d-flex flex-column">
              <v-card-title class="text-title-large font-weight-light">
                {{ $t('OpenCast submit as usual object') }}
              </v-card-title>
              <v-card-text class="flex-grow-1">
                {{ $t('OpenCast submit as usual object help') }}
              </v-card-text>
              <v-card-actions>
                <v-btn
                  color="primary"
                  variant="elevated"
                  block
                  @click="goToUpload"
                >
                  {{ $t('Continue') }}
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-col>

          <v-col cols="12" md="6">
            <v-card variant="outlined" class="h-100 d-flex flex-column">
              <v-card-title class="text-title-large font-weight-light">
                {{ $t('OpenCast submit as OER') }}
              </v-card-title>
              <v-card-text class="flex-grow-1">
                {{ $t('OpenCast submit as OER help') }}
              </v-card-text>
              <v-card-actions>
                <v-btn
                  color="primary"
                  variant="elevated"
                  block
                  @click="goToOer"
                >
                  {{ $t('Continue') }}
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { context } from '../../mixins/context'
import { useDocumentTitle } from '../../mixins/config'

export default {
  layout: 'main',
  mixins: [context],
  setup () {
    definePageMeta({
      middleware: 'auth'
    })
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: documentTitle(t('OpenCast submit title'))
      }
    })
  },
  methods: {
    goToUpload () {
      this.$router.push(this.localeLocation({
        path: '/submit/upload',
        query: { ...this.$route.query }
      }))
    },
    goToOer () {
      this.$router.push(this.localeLocation({
        path: '/submit/oer',
        query: { ...this.$route.query }
      }))
    }
  }
}
</script>
