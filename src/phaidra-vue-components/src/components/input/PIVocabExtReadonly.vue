<template>
  <v-row v-if="!hidden">
    <v-col cols="8">
      <v-text-field
        :value="prefLabel"
        :persistent-hint="true"
        :messages="messages"
        :label="$t(label)"
        readonly
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      >
        <template v-slot:message="{ message, key }">
          <span v-html="message"></span>
        </template>
      </v-text-field>
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
  name: 'p-i-vocab-ext-readonly',
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
      if (this['skos:prefLabel']) {
        for (let lab of this['skos:prefLabel']) {
          if (lab['@language'] === this.$i18n.locale) {
            return lab['@value']
          }
        }
        return this['skos:prefLabel'][0]['@value']
      }
      return ''
    },
    anchor: function () {
      if (this['skos:exactMatch'][0].startsWith('http')) {
        return '<a href="' + this['skos:exactMatch'][0] + '" target="_blank">' + this.prefLabel + '</a>'
      } else {
        return this.prefLabel
      }
    },
    notation: function () {
      if (this['skos:notation']) {
        for (let n of this['skos:notation']) {
          return n
        }
      }
      return false
    },
    messages: function () {
      let ret
      if (this['skos:exactMatch']) {
        ret = (this.notation ? ' Notation: ' + this.notation + '  - ' : '') + this.anchor
      }
      return ret
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
    'skos:exactMatch': {
      type: Array,
      required: true
    },
    'skos:notation': {
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
