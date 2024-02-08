<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel primary--text text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12">{{ checkAndUpdateField(o) }}</v-col>
  </v-row>
</template>

<script>
import { displayproperties } from '../../mixins/displayproperties'
import PDateModifier from '../../utils/PDateModifier'

export default {
  name: 'p-d-date',
  mixins: [displayproperties],
  props: {
    o: {
      type: String,
      required: true
    },
    p: {
      type: String
    }
  },
  methods: {
    checkAndUpdateField(val) {
      return PDateModifier.dateModifierFn(val, this)
    },
  }
}
</script>
