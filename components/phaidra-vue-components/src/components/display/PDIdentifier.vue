<template>
  <v-row>
    <v-col v-if="o.hasOwnProperty('@type')" :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ getLocalizedTermLabel('objectidentifiertype', o['@type']) }}</v-col>
    <v-col v-else :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t(p) }}</v-col>
    <v-col v-if="getIDResolverURL(o)" :md="valueColMd" cols="12"><a :href="getIDResolverURL(o)" target="_blank">{{ o['@value'] }}</a></v-col>
    <v-col v-else :md="valueColMd" cols="12">{{ o['@value'] }}</v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-identifier',
  mixins: [vocabulary, displayproperties],
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
