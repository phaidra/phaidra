<template>
  <div>
    <h1 class="d-sr-only">{{ $t('OpenCast submit title') }}</h1>
    <v-card class="my-8">
      <v-card-title class="text-title-large font-weight-light text-white">
        {{ $t('OpenCast submit title') }}
      </v-card-title>
      <v-card-text class="mt-4">
        <v-alert
          color="primary"
          variant="outlined"
          icon="mdi-alert"
          class="opencast-notice"
        >
          <div class="opencast-notice__title text-primary font-weight-medium">
            {{ $t('Important notice') }}
          </div>
          <div class="opencast-notice__text">{{ $t('OpenCast submit access rights notice') }}</div>
        </v-alert>

        <v-row
          v-if="hasDeepLinkSummary"
          no-gutters
          justify="center"
          class="mt-8 mb-8"
        >
          <v-col cols="12" md="7">
            <v-card>
              <v-card-title class="text-title-large font-weight-light text-white">
                {{ $t('OpenCast submit metadata summary') }}
              </v-card-title>
              <v-card-text>
                <v-container>
                  <v-row
                    v-for="(mpid, index) in deepLinkSummary.mpids"
                    :key="'mpid-' + mpid"
                  >
                    <v-col
                      v-if="index === 0"
                      md="2"
                      cols="12"
                      class="font-weight-bold text-right"
                    >
                      {{ $t('OpenCast submit mpid') }}
                    </v-col>
                    <v-col v-else md="2" cols="12"></v-col>
                    <v-col md="10" cols="12">{{ mpid }}</v-col>
                  </v-row>
                  <v-row v-if="deepLinkSummary.title">
                    <v-col md="2" cols="12" class="font-weight-bold text-right">
                      {{ $t('Title') }}
                    </v-col>
                    <v-col md="10" cols="12">{{ deepLinkSummary.title }}</v-col>
                  </v-row>
                  <v-row v-if="deepLinkSummary.language">
                    <v-col md="2" cols="12" class="font-weight-bold text-right">
                      {{ $t('Language') }}
                    </v-col>
                    <v-col md="10" cols="12">{{ formatLanguage(deepLinkSummary.language) }}</v-col>
                  </v-row>
                  <v-row v-if="deepLinkSummary.datecreated">
                    <v-col md="2" cols="12" class="font-weight-bold text-right">
                      {{ $t('dcterms:created') }}
                    </v-col>
                    <v-col md="10" cols="12">{{ deepLinkSummary.datecreated }}</v-col>
                  </v-row>
                  <v-row
                    v-for="(contributor, index) in deepLinkSummary.contributors"
                    :key="'contributor-' + index"
                  >
                    <v-col
                      v-if="index === 0"
                      md="2"
                      cols="12"
                      class="font-weight-bold text-right"
                    >
                      {{ $t('OpenCast submit contributor') }}
                    </v-col>
                    <v-col v-else md="2" cols="12"></v-col>
                    <v-col md="10" cols="12">
                      <span class="font-weight-regular">{{ formatContributorSummary(contributor) }}</span>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <v-row class="my-6" justify="start">
          <div class="d-flex flex-row ml-3">
            <v-btn
              color="primary"
              variant="elevated"
              prepend-icon="mdi-plus-circle"
              @click="goToUpload"
            >
              {{ $t('OpenCast submit as usual object') }}
            </v-btn>
          </div>
          <div class="d-flex flex-row pt-3 ml-3 ml-md-6">
            <span>{{ $t('OpenCast submit as usual object help') }}</span>
          </div>
        </v-row>
        <v-divider class="my-2"></v-divider>

        <v-row class="my-6" justify="start">
          <div class="d-flex flex-row ml-3">
            <v-btn
              color="primary"
              variant="elevated"
              prepend-icon="mdi-plus-circle"
              @click="goToOer"
            >
              {{ $t('OpenCast submit as OER') }}
            </v-btn>
          </div>
          <div class="d-flex flex-row pt-3 ml-3 ml-md-6">
            <span>{{ $t('OpenCast submit as OER help') }}</span>
          </div>
        </v-row>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
import { context } from '../../mixins/context'
import { useDocumentTitle } from '../../mixins/config'
import { vocabulary } from 'phaidra-vue-components/src/mixins/vocabulary'
import {
  buildSubmitDeepLinkSummary,
  formatContributorName,
  hasSubmitDeepLinkSummary,
  RESOURCE_TYPE_VIDEO
} from '../../utils/submitDeepLinkParams'

export default {
  layout: 'main',
  mixins: [context, vocabulary],
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
  computed: {
    deepLinkSummary () {
      return buildSubmitDeepLinkSummary(this.$route.query)
    },
    hasDeepLinkSummary () {
      return hasSubmitDeepLinkSummary(this.deepLinkSummary)
    }
  },
  methods: {
    formatLanguage (code) {
      return this.getLocalizedTermLabelByNotation('lang', code) ||
        this.getLocalizedTermLabel('lang', code) ||
        code
    },
    formatContributorSummary (contributor) {
      const name = formatContributorName(contributor.fields)
      const roleLabel = this.getLocalizedTermLabel('rolepredicate', contributor.role) || contributor.role
      if (name) {
        return `${name} (${roleLabel})`
      }
      return roleLabel
    },
    goToUpload () {
      const query = { ...this.$route.query }
      if (!query.rt) {
        query.rt = RESOURCE_TYPE_VIDEO
      }
      this.$router.push(this.localeLocation({
        path: '/submit/upload',
        query
      }))
    },
    goToOer () {
      const query = { ...this.$route.query }
      if (!query.rt) {
        query.rt = RESOURCE_TYPE_VIDEO
      }
      this.$router.push(this.localeLocation({
        path: '/submit/oer',
        query
      }))
    }
  }
}
</script>

<style scoped>
.opencast-notice__title {
  font-size: 0.875rem;
  letter-spacing: 0.0892857143em;
  margin-bottom: 12px;
}

.opencast-notice__text {
  color: rgba(0, 0, 0, 0.87);
}
</style>
