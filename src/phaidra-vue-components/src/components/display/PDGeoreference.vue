<template>
  <v-row v-if="o['skos:prefLabel']">
    <v-col class="pdlabel secondary--text font-weight-bold text-md-right" :md="labelColMd" cols="12">{{ $t(p) }}<template v-if="o['@type'] !== 'schema:Place'"> ({{ $t(o['@type']) }})</template><template v-for="(l) in o['skos:prefLabel']"><template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></template></v-col>
    <v-col :md="valueColMd" cols="12">
        <v-row no-gutters class="valuefield" v-for="(l, i) in o['skos:prefLabel']" :key="'gplv'+i">
          <a v-if="o['skos:exactMatch']" target="_blank" :href="o['skos:exactMatch'][0]">{{ l['@value'] }}</a>
          <template v-else>{{ l['@value'] }}</template>
        </v-row>
        <template v-if="o['rdfs:label']">
          <v-row no-gutters class="secondary--text valuefield" v-for="(l, i) in o['rdfs:label']" :key="'gl'+i">[{{ l['@value'] }}]</v-row>
        </template>
    </v-col>
  </v-row>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-georeference',
  mixins: [displayproperties],
  props: {
    o: {
      type: Object,
      required: true
    },
    p: {
      type: String
    }
  }
}
</script>
