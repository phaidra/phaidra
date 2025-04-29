<template>
  <v-row v-if="!hidden">
    <v-col :cols="actions.length ? 10 : 12">
      <v-text-field
        :value="value"
        v-on:blur="$emit('input-value',$event.target.value)"
        :label="$t(label)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on, attrs }">
          <v-btn v-on="on" v-bind="attrs" icon>
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
  name: 'p-i-literal',
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

<style scoped>
.v-btn {
  margin: 0;
}
</style>
