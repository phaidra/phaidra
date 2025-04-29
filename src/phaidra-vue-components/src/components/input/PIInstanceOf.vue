<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8">
        <v-card-title class="title font-weight-light white--text">
            <span>{{ $t(label) }}</span>
            <v-spacer></v-spacer>
            <v-menu open-on-hover bottom offset-y v-if="actions.length">
              <template v-slot:activator="{ on, attrs }">
                <v-btn v-on="on" v-bind="attrs" icon dark>
                  <v-icon dark>mdi-dots-vertical</v-icon>
                </v-btn>
              </template>
              <v-list>
                <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
                  <v-list-item-title>{{ action.title }}</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row>
            <v-col>
              <v-row >
                <v-col cols="6">
                  <v-text-field
                    :value="title"
                    :label="$t('Title')"
                    v-on:blur="$emit('input-title',$event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
                <v-col cols="6">
                  <v-text-field
                    :value="subtitle"
                    :label="$t('Subtitle')"
                    v-on:blur="$emit('input-subtitle',$event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
                <v-col cols="2">
                  <v-btn text @click="$refs.langdialog.open()">
                    <span>
                      ({{ titleLanguage ? titleLanguage : '--' }})
                    </span>
                  </v-btn>
                  <select-language ref="langdialog" @language-selected="$emit('input-title-language', $event)"></select-language>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" md="6">
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
                <v-col cols="12" md="6" >
                  <v-text-field
                    :value="identifierText"
                    :label="identifierLabel ? identifierLabel : $t('Identifier')"
                    v-on:blur="$emit('input-identifier', $event.target.value)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierType ? [validationrules[getIdentifierRuleName(identifierType)]] : [validationrules['noop']]"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-instance-of',
  mixins: [vocabulary, fieldproperties, validationrules],
  components: {
    SelectLanguage
  },
  props: {
    type: {
      type: String
    },
    label: {
      type: String
    },
    title: {
      type: String
    },
    subtitle: {
      type: String
    },
    titleLanguage: {
      type: String
    },
    identifierType: String,
    identifierText: String,
    identifierLabel: String,
    identifierVocabulary: {
      type: String,
      default: 'objectidentifiertype'
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    identifierTypePlaceholder: function () {
      for (let i of this.vocabularies[this.identifierVocabulary].terms) {
        if (i['@id'] === this.identifierType) {
          return i['skos:example']
        }
      }
      return ''
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
