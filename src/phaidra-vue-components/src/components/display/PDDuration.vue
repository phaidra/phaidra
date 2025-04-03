<template>
  <v-row>
    <v-col :md="labelColMd" cols="12" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(p) }}</v-col>
    <v-col :md="valueColMd" cols="12"><template v-if="duration.hours > 0">{{ duration.hours }} {{$t('hours') + ' '}}</template> <template v-if="duration.minutes > 0">{{ duration.minutes }} {{$t('minutes') + ' '}}</template> <template v-if="duration.seconds > 0">{{ duration.seconds }} {{$t('seconds')}}</template></v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { displayproperties } from '../../mixins/displayproperties'

export default {
  name: 'p-d-duration',
  mixins: [vocabulary, displayproperties],
  props: {
    o: {
      type: String,
      required: true
    },
    p: {
      type: String
    }
  },
  computed: {
    duration: function () {
      let m = this.o.match(/PT(\d+)H(\d+)M(\d+)S/)
      if (m) {
        return {
          hours: m[1],
          minutes: m[2],
          seconds: m[3]
        }
      }
      return null
    }
  }
}
</script>
