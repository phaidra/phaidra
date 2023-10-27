<template>
  <span>
    <template>
      <v-row v-for="(mt, i) in o['bf:mainTitle']" :key="'mt'+i">
        <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">
          {{ $t(o['@type']) }}<template v-if="showLang && mt['@language']"> ({{ mt['@language'] }})</template>
        </v-col>
        <v-col :md="valueColMd" cols="12">
            <v-row no-gutters class="valuefield" :class="{ 'font-weight-regular': boldLabelFields.includes('dce:title') }">{{ mt['@value'] }}</v-row>
            <template v-for="(st, i) in o['bf:subtitle']">
              <v-row no-gutters class="valuefield" :key="'stv'+i">{{ st['@value'] }}</v-row>
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
