<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}<template v-if="showLang && o['@language']"> ({{ o['@language'] }})</template></v-col>
    <v-col :md="valueColMd" cols="12">{{ o['@value'] || o }}</v-col>
  </v-row>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-lang-value',
  mixins: [displayproperties],
  props: {
    o: {
      type: [Object, String],
      required: true
    },
    p: {
      type: String
    }
  }
}
</script>
