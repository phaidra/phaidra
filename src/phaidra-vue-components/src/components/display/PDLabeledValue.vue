<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">{{ resolve(p, o) }} <span class="secondary--text">[{{o}}]</span></v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-labeled-value',
  mixins: [vocabulary, displayproperties],
  props: {
    o: {
      type: String,
      required: true
    },
    p: {
      type: String
    }
  },
  methods: {
    resolve: function (p, v) {
      var vocabulary = ''
      switch (p) {
        case 'dcterms:language':
        case 'schema:subtitleLanguage':
          vocabulary = 'lang'
          break

        case 'ebucore:hasMimeType':
          vocabulary = 'mimetypes'
          break

        default:
          // console.error('p-d-uri resolve: unrecognized predicate ', p, v)
      }

      return this.getLocalizedTermLabel(vocabulary, v)
    }
  }
}
</script>
