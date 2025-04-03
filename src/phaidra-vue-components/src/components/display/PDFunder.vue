<template>
  <span>
    <v-row>
      <template v-for="(l, i) in o['skos:prefLabel']">
        <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right" :key="'fl'+i">{{ $t('Funder') }}<template v-if="showLang && l['@language']"> ({{ l['@language'] }})</template></v-col>
        <v-col class="valuefield" :md="valueColMd" cols="12" :key="'fv'+i">
          <template v-if="o['skos:exactMatch']">
            <a :href="o['skos:exactMatch']" target="_blank">{{ l['@value'] }}</a>
          </template>
          <template v-else>
            {{ l['@value'] }}
          </template>
        </v-col>
      </template>
    </v-row>
  </span>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-funder',
  mixins: [displayproperties],
  props: {
    o: {
      type: Object,
      required: true
    }
  }
}
</script>
