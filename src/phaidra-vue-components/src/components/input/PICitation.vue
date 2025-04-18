<template>
  <v-row v-if="!hidden">
    <v-col cols="2">
      <v-autocomplete
        v-on:input="$emit('input-citation-type', $event)"
        :label="$t('Citation type')"
        :items="vocabularies['citationpredicate'].terms"
        :item-value="'@id'"
        :value="getTerm('citationpredicate', type)"
        :filter="autocompleteFilter"
        :disabled="disabletype"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('citationpredicate', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('citationpredicate', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="4">
      <v-text-field
        :value="citation"
        v-on:input="$emit('input-citation', $event)"
        :label="$t(citationLabel)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"      
        append-outer-icon="mdi-magnify"
        @click:append-outer="$refs.yarmselect.open()"
      ></v-text-field>
    </v-col>
    <v-col cols="2">
      <v-btn text @click="$refs.langdialog.open()">
        <span>
          ({{ citationLanguage ? citationLanguage : '--' }})
        </span>
      </v-btn>
      <select-language ref="langdialog" @language-selected="$emit('input-citation-language', $event)"></select-language>
    </v-col>
    <v-col cols="3">
      <v-text-field
        :value="identifier"
        v-on:input="$emit('input-identifier', $event)"
        :label="$t(identifierLabel)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
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
    <yarm-ref ref="yarmselect" @input-citation="$emit('input-citation', $event)" @input-identifier="$emit('input-identifier', $event)"></yarm-ref>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'
import YarmRef from '../select/YarmRef'

export default {
  name: 'p-i-citation',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage,
    YarmRef
  },
  props: {
    citation: {
      type: String
    },
    citationLanguage: {
      type: String
    },
    identifier: {
      type: String
    },
    type: {
      type: String
    },
    citationLabel: {
      type: String,
      required: true
    },
    identifierLabel: {
      type: String,
      required: true
    },
    required: {
      type: Boolean
    },
    disabletype: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  mounted: function () {    
    this.$nextTick(function () {
      this.loading = !this.vocabularies['citationpredicate'].loaded
      // emit input to set skos:prefLabel in parent
      if (this.type) {
        this.$emit('input-citation-type', this.getTerm('citationpredicate', this.type))
      }
    })
  }
}
</script>
