<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12" v-if="isEdmTimeSpan" >
      <v-row v-for="(l, i) in o['skos:prefLabel']" :key="'prl'+i">
        <v-col :md="valueColMd" cols="12" v-if="o['skos:exactMatch']">
          <a class="valuefield" :href="getIDResolverURL(o['skos:exactMatch'][0])" target="_blank">{{ l['@value'] }}</a>
        </v-col>
        <v-col v-else :md="valueColMd" cols="12">
          {{ l['@value'] }}
        </v-col>
      </v-row>
    </v-col>
    <v-col v-else :md="valueColMd" cols="12">{{ checkAndUpdateField(o) }}</v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'
import PDateModifier from '../../utils/PDateModifier'

export default {
  name: 'p-d-date',
  mixins: [vocabulary, displayproperties],
  props: {
    o: {
      type: [String, Object],
      required: true
    },
    p: {
      type: String
    }
  },
  computed: {
    displaylang: function () {
      let lang
      let somelang
      for (let label of this.o['skos:prefLabel']) {
        somelang = label['@language']
        if (label['@language'] === this.$i18n.locale) {
          lang = this.$i18n.locale
        }
      }
      return lang || somelang
    },
    isEdmTimeSpan: function () {
      if (typeof this.o === 'object' && (this.o !== null)) {
        return this.o['@type'] === 'edm:TimeSpan'
      } 
      return false
    }
  },
  methods: {
    checkAndUpdateField(val) {
      return PDateModifier.dateModifierFn(val, this)
    },
  }
}
</script>
