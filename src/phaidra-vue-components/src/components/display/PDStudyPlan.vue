<template>
  <span>
    <template v-for="(l, i) in (o['skos:prefLabel'] || [])" :key="'pl'+i">
      <v-row v-if="l && l['@language'] === displaylang">
        <v-col :md="labelColMd" cols="12" class="pdlabel text-secondary font-weight-bold text-md-right" >{{ $t('Study plan') }}</v-col>
        <v-col :md="valueColMd" cols="12">
          <a v-if="o['skos:exactMatch']" :href="o['skos:exactMatch'][0]" target="_blank"><v-row no-gutters class="valuefield" >{{ l['@value'] }}</v-row></a>
          <v-row v-else no-gutters class="valuefield" >{{ l['@value'] }}</v-row>
          <template v-for="(id, j) in o['skos:notation']" :key="'notation'+j">
            <v-row v-if="id" no-gutters class="text-secondary cols">[{{ id }}]</v-row>
          </template>
        </v-col>
      </v-row>
    </template>
  </span>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-study-plan',
  mixins: [displayproperties],
  props: {
    o: {
      type: Object,
      required: true
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
        if (!label) continue
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
