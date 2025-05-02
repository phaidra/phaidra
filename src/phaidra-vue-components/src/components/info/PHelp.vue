<template>
  <v-card class="my-8">
    <v-card-title class="title font-weight-light white--text">{{ $t('Help') }}</v-card-title>
    <v-card-text class="mt-4">
      <div v-if="$i18n.locale === 'deu'">
        <p><nuxt-link :to="'/metadata-fields-help'" target="_blank">Beschreibung aller vorhandenen Metadatenfelder</nuxt-link></p>
        <template v-if="instanceconfig.baseurl.includes('univie.ac.at')">
          <p>Weiterführende Links:</p>
          <p><a href="https://datamanagement.univie.ac.at/ueber-phaidra-services/downloads-und-anleitungen/" target="_blank">PHAIDRA User Guide und Anleitungen</a></p>
          <p><a href="https://rdm.univie.ac.at/de/fdm-policy-und-faq/" target="_blank">Forschungsdaten Policy an der Universität Wien</a></p>
          <p><a href="https://doi-service.univie.ac.at/" target="_blank">DOI Service der Universität Wien</a></p>
        </template>
      </div>
      <div v-else>
        <p><nuxt-link :to="'/metadata-fields-help'" target="_blank">Description of all existing metadata fields</nuxt-link></p>
        <template v-if="instanceconfig.baseurl.includes('univie.ac.at')">
          <p>Related Links:</p>
          <p><a href="https://datamanagement.univie.ac.at/en/about-phaidra/downloads/" target="_blank">PHAIDRA User Guide and Manuals</a></p>
          <p><a href="https://rdm.univie.ac.at/rdm-policy-and-faq/" target="_blank">RDM Policy at University of Vienna</a></p>
          <p><a href="https://doi-service.univie.ac.at/en/" target="_blank">DOI service of the University of Vienna</a></p>
        </template>
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
  data () {
    return {
      loading: false
    }
  }
}
</script>
