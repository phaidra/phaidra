<template>
    <v-row v-if="!hidden">
      <v-col cols="2" v-if="!hideType">
        <v-autocomplete
          v-on:input="$emit('input-date-type', $event)"
          :label="$t('Type of date')"
          :items="vocabularies['datepredicate'].terms"
          :item-value="'@id'"
          :value="getTerm('datepredicate', type)"
          :filter="autocompleteFilter"
          :filled="inputStyle==='filled'"
          :outlined="inputStyle==='outlined'"
          return-object
          clearable
          :error-messages="typeErrorMessages"
        >
          <template slot="item" slot-scope="{ item }">
            <v-list-item-content two-line>
              <v-list-item-title  v-html="`${getLocalizedTermLabel('datepredicate', item['@id'])}`"></v-list-item-title>
              <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
            </v-list-item-content>
          </template>
          <template slot="selection" slot-scope="{ item }">
            <v-list-item-content>
              <v-list-item-title v-html="`${getLocalizedTermLabel('datepredicate', item['@id'])}`"></v-list-item-title>
            </v-list-item-content>
          </template>
        </v-autocomplete>
    </v-col>
    <v-col cols="2">
      <v-text-field
        :value="value"
        :label="$t('Date')"
        v-on:blur="$emit('input-date', $event.target.value)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="1">
      <v-btn text @click="$refs.langdialog.open()">
        <span class="grey--text text--darken-1">
          ({{ language ? language : '--' }})
        </span>
      </v-btn>
      <select-language ref="langdialog" @language-selected="$emit('input-language', $event)"></select-language>
    </v-col>
    <v-col cols="4">
      <v-row>
        <v-col :cols="6" v-if="!hideIdentifierType && !hideIdentifier">
          <v-autocomplete
            v-on:input="$emit('input-identifier-type', $event)"
            :label="$t('Type of identifier')"
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
            :label="$t('Identifier')"
            v-on:blur="$emit('input-identifier',$event.target.value)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
          ></v-text-field>
        </v-col>
      </v-row>
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
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-date-edmtimespan',
  components: {
    SelectLanguage
  },
  mixins: [vocabulary, fieldproperties, validationrules],
  props: {
    value: {
      type: String
    },
    dateLabel: {
      type: String
    },
    type: {
      type: String
    },
    hideType: {
      type: Boolean
    },
    required: {
      type: Boolean
    },
    valueErrorMessages: {
      type: Array
    },
    typeErrorMessages: {
      type: Array
    },
    showIds: {
      type: Boolean,
      default: false
    },
    language: {
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
    }
  },
  data () {
    return {
      pickerModel: new Date().toISOString().substr(0, 10),
      dateMenu: false
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      this.loading = !this.vocabularies['datepredicate'].loaded
      // emit input to set skos:prefLabel in parent
      if (this.type) {
        this.$emit('input-date-type', this.getTerm('datepredicate', this.type))
      }
    })
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
