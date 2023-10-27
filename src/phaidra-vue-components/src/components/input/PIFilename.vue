<template>
  <v-row v-if="!hidden">
    <v-col cols="8">
      <v-text-field
        :value="value"
        :label="$t('Filename')"
        v-on:blur="$emit('input-value',$event.target.value)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
  </v-row>
</template>
<script>
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-filename',
  mixins: [fieldproperties],
  props: {
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    }
  }
}
</script>
