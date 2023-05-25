<template>
  <v-row v-if="!hidden">
    <v-col cols="8">
      <v-text-field
        :value="prefLabel"
        :persistent-hint="true"
        :messages="value"
        :label="$t(label)"
        readonly
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
            <v-list-item-title v-if="action.event === 'remove'">{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
  </v-row>
</template>
<script>
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-spatial-readonly',
  mixins: [fieldproperties],
  computed: {
    rdfsLabels: function () {
      var i
      var arr = []
      if (this['rdfs:label']) {
        for (i = 0; i < this['rdfs:label'].length; i++) {
          arr.push(this['rdfs:label'][i]['@value'])
        }
      }
      return arr
    },
    prefLabel: function () {
      var i
      var prefLabel = ''
      // just return any now
      if (this['skos:prefLabel']) {
        for (i = 0; i < this['skos:prefLabel'].length; i++) {
          return this['skos:prefLabel'][i]['@value']
        }
      }
      return prefLabel
    }
  },
  props: {
    'skos:prefLabel': {
      type: Array,
      required: true
    },
    'rdfs:label': {
      type: Array
    },
    value: {
      type: String,
      required: true
    },
    coordinates: {
      type: Array
    },
    label: {
      type: String,
      required: true
    },
    predicate: {
      type: String,
      required: true
    },
    removable: {
      type: Boolean,
      default: true
    }
  }
}
</script>
