<template>
  <v-row v-if="!hidden">
    <v-col cols="2">
      <v-text-field
        :value="value"
        v-on:blur="$emit('input-value',$event.target.value)"
        :label="$t(label)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="2">
      <v-select
        v-on:blur="$emit('input-unit',$event.target.value)"
        :label="$t('Unit')"
        :items="vocabularies[vocabulary].terms"
        :item-value="'@id'"
        :value="getTerm(vocabulary, unit)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel(vocabulary, item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel(vocabulary, item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-select>
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
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-dimension',
  mixins: [vocabulary, fieldproperties],
  props: {
    unit: {
      type: String
    },
    vocabulary: {
      type: String,
      default: 'uncefact'
    },
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    showIds: {
      type: Boolean,
      default: false
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
