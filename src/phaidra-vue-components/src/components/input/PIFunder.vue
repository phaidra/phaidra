<template>

  <v-row v-if="!hidden">
    <v-col cols="4">
      <v-text-field
        :value="name"
        :label="$t('Funder name')"
        v-on:blur="$emit('input-name',$event.target.value)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="2">
      <v-btn text @click="$refs.langdialog.open()">
        <span>
          ({{ nameLanguage ? nameLanguage : '--' }})
        </span>
      </v-btn>
      <select-language ref="langdialog" @language-selected="$emit('input-name-language', $event)"></select-language>
    </v-col>
    <v-col cols="4">
      <v-row>
        <v-col :cols="6" v-if="!hideIdentifierType && !hideIdentifier">
          <v-autocomplete
            v-on:input="$emit('input-identifier-type', $event)"
            :label="$t('Type of funder identifier')"
            :items="vocabularies[identifierVocabulary].terms"
            :item-value="'@id'"
            :value="getTerm(identifierVocabulary, identifierType)"
            :filter="autocompleteFilter"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
            return-object
            clearable
          >
            <template slot="item" slot-scope="{ item }">
              <v-list-item-content two-line>
                <v-list-item-title  v-html="`${getLocalizedTermLabel(identifierVocabulary, item['@id'])}`"></v-list-item-title>
              </v-list-item-content>
            </template>
            <template slot="selection" slot-scope="{ item }">
              <v-list-item-content>
                <v-list-item-title v-html="`${getLocalizedTermLabel(identifierVocabulary, item['@id'])}`"></v-list-item-title>
              </v-list-item-content>
            </template>
          </v-autocomplete>
        </v-col>
        <v-col :cols="!hideIdentifierType ? 6 : 12" v-if="!hideIdentifier">
          <v-text-field
            :value="identifier"
            :label="$t('Funder identifier')"
            v-on:blur="$emit('input-identifier',$event.target.value)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
          ></v-text-field>
        </v-col>
      </v-row>
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
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-funder',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  props: {
    name: {
      type: String
    },
    nameLanguage: {
      type: String
    },
    identifierType: {
      type: String
    },
    identifier: {
      type: String
    },
    hideIdentifier: {
      type: Boolean
    },
    hideIdentifierType: {
      type: Boolean,
      default: false
    },
    identifierVocabulary: {
      type: String,
      default: 'identifiertype'
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
.vertical-center {
 align-items: center;
}
</style>
