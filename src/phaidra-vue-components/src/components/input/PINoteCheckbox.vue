<template>
  <v-row>
    <v-col cols="12">
      <v-checkbox class="mt-0 check" v-model="checkbox" @click.capture="$emit('input', note)" :label="label"></v-checkbox>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-note-checkbox',
  mixins: [vocabulary, fieldproperties],
  props: {
    note: {
      type: String,
      required: true
    },
    errorMessages: {
      type: Array
    },
    language: {
      type: String
    },
    label: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      checkbox: false
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
