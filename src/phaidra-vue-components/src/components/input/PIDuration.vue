<template>
  <v-row v-if="!hidden">
    <v-col cols="3" v-if="!hideHours">
      <v-text-field
        v-model="hours"
        :rules="[v => (!v || (parseInt(v, 10) >= 0)) || 'Must be a non negative integer']"
        type="number"
        :label="$t('Duration')"
        :suffix="$t('hours')"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="3" v-if="!hideMinutes">
      <v-text-field
        v-model="minutes"
        :rules="[v => (!v || (parseInt(v, 10) >= 0)) || 'Must be a non negative integer']"
        type="number"
        :label="$t('Duration')"
        :suffix="$t('minutes')"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="3" v-if="!hideSeconds">
      <v-text-field
        v-model="seconds"
        :rules="[v => (!v || (parseInt(v, 10) >= 0)) || 'Must be a non negative integer']"
        type="number"
        :label="$t('Duration')"
        :suffix="$t('seconds')"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on }">
          <v-btn v-on="on" icon>
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-duration',
  mixins: [fieldproperties],
  props: {
    value: {
      type: String
    },
    hideHours: {
      type: Boolean
    },
    hideMinutes: {
      type: Boolean
    },
    hideSeconds: {
      type: Boolean
    },
    label: {
      type: String,
      required: true
    }
  },
  watch: {
    hours: function () {
      this.$emit('input', this.duration)
    },
    minutes: function () {
      this.$emit('input', this.duration)
    },
    seconds: function () {
      this.$emit('input', this.duration)
    }
  },
  computed: {
    duration: {
      get: function () {
        return 'PT' + this.hours + 'H' + this.minutes + 'M' + this.seconds + 'S'
      },
      set: function () {
        let m = this.value.match(/PT(\d+)H(\d+)M(\d+)S/)
        if (m) {
          this.hours = m[1]
          this.minutes = m[2]
          this.seconds = m[3]
        }
      }
    }
  },
  data () {
    return {
      hours: 0,
      minutes: 0,
      seconds: 0
    }
  },
  mounted: function () {
    this.duration = this.value
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
