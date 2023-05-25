<template>
  <div v-if="!hidden">
    <v-alert :value="errorMessages.length > 0" dismissible type="error" transition="slide-y-transition">
      <span v-for="(em, i) in errorMessages" :key="'em'+i">{{ em }}<br/></span>
    </v-alert>
    <v-card outlined class="mt-4 mb-8">
      <v-card-title v-if="showLabel" class="title font-weight-light ">
      {{ $t('edm:hasType') }}&nbsp;*
      </v-card-title>
      <v-card-text class="mt-4">
        <v-row no-gutters>
          <v-col cols="12" :md="terms.length <= 6 ? 12 : 6" v-for="(term, i) in terms" :key="'ot'+i">
            <v-checkbox class="mt-0 check" v-model="checkboxes[term['@id']]" @click.capture="$emit('input', checkboxes)" :label="getLocalizedTermLabel(vocabulary, term['@id'])" :true-value="term['@id']"></v-checkbox>
            <v-spacer></v-spacer>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-object-type',
  mixins: [vocabulary, fieldproperties],
  props: {
    label: {
      type: String,
      required: true
    },
    showLabel: {
      type: Boolean,
      default: true
    },
    vocabulary: {
      type: String,
      required: true
    },
    resourceType: {
      type: String
    },
    errorMessages: {
      type: Array
    }
  },
  watch: {
    resourceType (val) {
      this.checkboxes = {}
    }
  },
  computed: {
    terms: function () {
      return this.resourceType ? this.$store.getters['vocabulary/getObjectTypeForResourceType'](this.resourceType, this.$i18n.locale) : this.vocabularies[this.vocabulary].terms
    }
  },
  data () {
    return {
      checkboxes: {}
    }
  },
  mounted: function () {
    this.$store.getters['vocabulary/getObjectTypeForResourceType'](this.resourceType, this.$i18n.locale)
  }
}
</script>

<style scoped>
.check {
  min-width: 220px;
}
</style>
