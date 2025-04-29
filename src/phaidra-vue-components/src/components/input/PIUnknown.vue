<template>
  <v-row v-if="!hidden">
    <v-col cols="12" md="10">
      <v-col class="primary--text" cols="3">{{ label }}</v-col>
      {{jsonld}}
    </v-col>
    <v-col cols="12" md="1" v-if="actions.length">
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
  name: 'p-i-unknown',
  mixins: [fieldproperties],
  props: {
    jsonld: {
      type: Object
    },
    label: {
      type: String,
      required: true
    }
  }
}
</script>
