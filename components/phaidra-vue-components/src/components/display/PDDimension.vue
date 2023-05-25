<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12"><span v-for="(v, i) in o['schema:value']" :key="'v'+i">{{ v }}</span>&nbsp;<span v-for="(v, i) in o['schema:unitCode']" :key="'u'+i">{{ getLocalizedTermLabel('uncefact', v) }}</span></v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-dimension',
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
