<template>
  <div class="mb-8" v-if="!hidden">
    <v-row>
      <v-col cols="12">
        <v-btn-toggle
          background-color='white-text'
          active-class='primary white--text'
          v-model="toggleResourcetypeModel"
          mandatory
          @change="$emit('input', getTerm('resourcetype', resourceTypes[$event]))"
        >
          <v-btn v-show="resourceTypes.includes('https://pid.phaidra.org/vocabulary/44TN-P1S0')"><v-icon :color="value === 'https://pid.phaidra.org/vocabulary/44TN-P1S0' ? 'white' : 'grey'">mdi-image</v-icon><span class="ml-2">{{ $t('Picture') }}</span></v-btn>
          <v-btn v-show="resourceTypes.includes('https://pid.phaidra.org/vocabulary/8YB5-1M0J')"><v-icon :color="value === 'https://pid.phaidra.org/vocabulary/8YB5-1M0J' ? 'white' : 'grey'">mdi-volume-high</v-icon><span class="ml-2">{{ $t('Audio') }}</span></v-btn>
          <v-btn v-show="resourceTypes.includes('https://pid.phaidra.org/vocabulary/B0Y6-GYT8')"><v-icon :color="value === 'https://pid.phaidra.org/vocabulary/B0Y6-GYT8' ? 'white' : 'grey'">mdi-video</v-icon><span class="ml-2">{{ $t('Video') }}</span></v-btn>
          <v-btn v-show="resourceTypes.includes('https://pid.phaidra.org/vocabulary/69ZZ-2KGX')"><v-icon :color="value === 'https://pid.phaidra.org/vocabulary/69ZZ-2KGX' ? 'white' : 'grey'">mdi-file-document</v-icon><span class="ml-2">{{ $t('PDF Document') }}</span></v-btn>
          <v-btn v-show="resourceTypes.includes('https://pid.phaidra.org/vocabulary/7AVS-Y482')"><v-icon :color="value === 'https://pid.phaidra.org/vocabulary/7AVS-Y482' ? 'white' : 'grey'">mdi-file</v-icon><span class="ml-2">{{ $t('Other documents / Data') }}</span></v-btn>
          <v-btn v-show="resourceTypes.includes('https://pid.phaidra.org/vocabulary/GXS7-ENXJ')"><v-icon :color="value === 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ' ? 'white' : 'grey'">mdi-folder-open</v-icon><span class="ml-2">{{ $t('Collection') }}</span></v-btn>
          <v-btn v-show="resourceTypes.includes('https://pid.phaidra.org/vocabulary/T8GH-F4V8')"><v-icon :color="value === 'https://pid.phaidra.org/vocabulary/T8GH-F4V8' ? 'white' : 'grey'">mdi-link</v-icon><span class="ml-2">{{ $t('Link') }}</span></v-btn>
        </v-btn-toggle>
      </v-col>
    </v-row>
    <v-row v-if="!hidden && formats" class="ml-1">
      <span v-if="formats.recommended && formats.recommended.length > 0">{{ $t('Recommended formats') }}: <a v-for="(f, i) in formats.recommended" :key="'fr' + i" :href="f.url" target="_blank">{{f.label}}<span v-if="i < (formats.recommended.length -1)">, </span></a></span>
      <span v-else-if="formats.supported && formats.supported.length > 0">{{ $t('Other supported formats') }}: <a v-for="(f, i) in formats.supported" :key="'fs' + i" :href="f.url" target="_blank">{{f.label}}<span v-if="i < (formats.supported.length - 1)">, </span></a></span>
      <template v-else-if="formats.info">
      <v-col cols="10" class="pa-0">
        <v-alert dense outlined type="info" color="secondary" icon="mdi-information-outline">{{ $t(formats.info) }}</v-alert>
    </v-col>
      </template>
    </v-row>
  </div>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-resource-type',
  mixins: [vocabulary, fieldproperties],
  props: {
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    resourceTypes: {
      type: Array,
      required: false,
      default: () => [ 
        'https://pid.phaidra.org/vocabulary/44TN-P1S0',
        'https://pid.phaidra.org/vocabulary/8YB5-1M0J',
        'https://pid.phaidra.org/vocabulary/B0Y6-GYT8',
        'https://pid.phaidra.org/vocabulary/69ZZ-2KGX',
        'https://pid.phaidra.org/vocabulary/7AVS-Y482',
        'https://pid.phaidra.org/vocabulary/GXS7-ENXJ',
        'https://pid.phaidra.org/vocabulary/T8GH-F4V8'
      ]
    },
  },
  computed: {
    formats: function () {
      return this.vocabularies['formatsInfo'].terms[this.resourceTypes[this.toggleResourcetypeModel]]
    }
  },
  data () {
    return {
      toggleResourcetypeModel: 0
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      // emit input to set skos:prefLabel in parent
      if (this.value) {
        for (let term of this.vocabularies['resourcetype'].terms) {
          if (term['@id'] === this.value) {
            this.$emit('input', term)
          }
        }
      }
    })
  }
}
</script>
