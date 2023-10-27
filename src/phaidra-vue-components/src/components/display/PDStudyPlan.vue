<template>
  <span>
    <v-row v-for="(l, i) in o['skos:prefLabel']" v-if="l['@language'] === displaylang" :key="'pl'+i">
      <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right" >{{ $t('Study plan') }}</v-col>
      <v-col :md="valueColMd" cols="12">
        <a v-if="o['skos:exactMatch']" :href="o['skos:exactMatch'][0]" target="_blank"><v-row no-gutters class="valuefield" >{{ l['@value'] }}</v-row></a>
        <v-row v-else no-gutters class="valuefield" >{{ l['@value'] }}</v-row>
        <template v-for="(id, i) in o['skos:notation']">
          <v-row v-if="id" no-gutters class="grey--text cols"  :key="'notation'+i">[{{ id }}]</v-row>
        </template>
      </v-col>
    </v-row>
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
