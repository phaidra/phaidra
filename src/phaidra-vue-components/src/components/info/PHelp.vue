<template>
  <v-card class="my-8">
    <v-card-title class="text-title-large font-weight-light text-white">{{ $t('Help') }}</v-card-title>
    <v-card-text class="mt-4">
      <div v-if="$i18n.locale === 'deu'">
        <p><nuxt-link :to="'/metadata-fields-help'" target="_blank">Beschreibung aller vorhandenen Metadatenfelder</nuxt-link></p>
      </div>
      <div v-else>
        <p><nuxt-link :to="'/metadata-fields-help'" target="_blank">Description of all existing metadata fields</nuxt-link></p>
      </div>
    </v-card-text>
  </v-card>
</template>

<script>
import { useHostRootStore as useRootStore } from '../../stores/host-root'
import phaidraNavigation from '../../mixins/phaidraNavigation'

export default {
  name: 'p-help',
  mixins: [phaidraNavigation],
  props: {
    url: {
      type: String
    }
  },
  computed: {
    instanceconfig: function () {
      return useRootStore().instanceconfig
    }
  },
  data() {
    return {
      loading: false
    }
  }
}
</script>
