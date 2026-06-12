<template>
  <v-card>
    <v-card-title class="title font-weight-light white--text">{{ $t('Help') }}</v-card-title>
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
export default {
  name: 'p-help',
  props: {
    url: {
      type: String
    }
  },
  computed: {
    instanceconfig: function () {
      return this.$root.$store.state.instanceconfig
    }
  },
  data() {
    return {
      loading: false
    }
  }
}
</script>
