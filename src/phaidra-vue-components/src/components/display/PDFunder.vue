<template>
  <span>
    <v-row v-for="(l, i) in o['skos:prefLabel']" :key="'fl'+i">
      <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('Funder') }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
      <v-col class="valuefield" :md="valueColMd" cols="12">
        <template v-if="o['skos:exactMatch']">
          <template v-if="Array.isArray(o['skos:exactMatch'])">
            <span v-for="(match, mi) in o['skos:exactMatch']" :key="'fvm'+mi">
              <a v-if="match && match['@value']" :href="getIDResolverURL(match)" target="_blank">{{ l['@value'] }}</a>
              <a v-else :href="match" target="_blank">{{ l['@value'] }}</a>
            </span>
          </template>
          <template v-else-if="o['skos:exactMatch']['@value']">
            <a :href="getIDResolverURL(o['skos:exactMatch'])" target="_blank">{{ l['@value'] }}</a>
          </template>
          <template v-else><a :href="o['skos:exactMatch']" target="_blank">{{ l['@value'] }}</a></template>
        </template>
        <template v-else>{{ l['@value'] }}</template>
      </v-col>
    </v-row>
  </span>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'p-d-funder',
  mixins: [displayproperties, vocabulary],
  props: {
    o: {
      type: Object,
      required: true
    }
  }
}
</script>
