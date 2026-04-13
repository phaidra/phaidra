<template>
  <span>
    <template>
      <v-row v-for="(mt, i) in o['bf:mainTitle']" :key="'mt'+i">
        <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">
          {{ $t(o['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template>
        </v-col>
        <v-col :md="valueColMd" cols="12">
            <v-row no-gutters class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('dce:title') }">{{ mt['@value'] }}</v-row>
            <template v-for="(st, si) in o['bf:subtitle']" :key="'stv' + i + '-' + si">
              <v-row no-gutters class="valuefield">{{ st['@value'] }}</v-row>
            </template>
        </v-col>
      </v-row>
    </template>
  </span>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-title',
  mixins: [displayproperties],
  props: {
    o: {
      type: Object,
      required: true
    }
  }
}
</script>
