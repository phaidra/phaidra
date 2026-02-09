<template>
  <span>
    <v-row v-for="(l, i) in o['skos:prefLabel']" v-if="o['skos:prefLabel'] && l['@language'] === displaylang" :key="'prl'+i">
      <v-col :md="labelColMd" cols="12" v-if="p==='bf:note'" class="pdlabel secondary--text font-weight-bold text-md-right" >{{ $t(o['@type']) }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
      <v-col :md="labelColMd" cols="12" v-else class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
      <v-col :md="valueColMd" cols="12" v-if="o['schema:url']"><a class="valuefield" :href="o['schema:url'][0]" target="_blank">{{ l['@value'] || o['schema:url'][0] }}</a></v-col>
      <v-col class="valuefield" :md="valueColMd" cols="12" v-else>{{ l['@value'] }}</v-col>
    </v-row>
    <v-row v-if="!o['skos:prefLabel'] && o['schema:url']" :key="'url-only'">
      <v-col :md="labelColMd" cols="12" v-if="p==='bf:note'" class="pdlabel secondary--text font-weight-bold text-md-right" >{{ $t(o['@type']) }}</v-col>
      <v-col :md="labelColMd" cols="12" v-else class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
      <v-col :md="valueColMd" cols="12"><a class="valuefield" :href="o['schema:url'][0]" target="_blank">{{ o['schema:url'][0] }}</a></v-col>
    </v-row>
  </span>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-see-also',
  mixins: [displayproperties],
  props: {
    o: {
      type: Object,
      required: true
    },
    p: {
      type: String
    }
  },
  computed: {
    displaylang: function () {
      if (!this.o['skos:prefLabel'] || !Array.isArray(this.o['skos:prefLabel'])) {
        return null
      }
      let lang
      let somelang
      for (let label of this.o['skos:prefLabel']) {
        somelang = label['@language']
        if (label['@language'] === this.$i18n.locale) {
          lang = this.$i18n.locale
        }
      }
      return lang || somelang
    }
  }
}
</script>
