<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right" >{{ $t(p) }}<template v-if="showLang && language"> ({{ language }})</template></v-col>
    <v-col :md="valueColMd" cols="12">
      <v-chip :key="'kw' + language + i" v-for="(kw, i) in keywords" class="mr-2 mb-2 pointer-disabled">{{kw}}</v-chip>
    </v-col>
  </v-row>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-keyword',
  mixins: [displayproperties],
  props: {
    language: {
      type: String
    },
    keywords: {
      type: Array,
      required: true
    },
    p: {
      type: String
    }
  }
}
</script>
