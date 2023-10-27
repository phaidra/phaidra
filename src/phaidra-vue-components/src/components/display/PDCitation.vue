<template>
  <span>
    <v-row v-for="(pl, i) in o['skos:prefLabel']" :key="'cit'+i">
      <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t(p) }}<template v-if="showLang && pl['@language']"> ({{ pl['@language'] }})</template></v-col>
      <v-col :md="valueColMd" cols="12">
        <v-row no-gutters class="valuefield">{{ pl['@value'] }}<template v-for="(identifier, idi) in o['skos:exactMatch']"><template v-if="identifier.startsWith('http')"> <a :href="identifier" :key="'idk'+idi" target="_blank" :title="identifier">{{ identifier }}</a></template><template v-else> ({{ identifier }})</template></template></v-row>
      </v-col>
    </v-row>
  </span>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-citation',
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
