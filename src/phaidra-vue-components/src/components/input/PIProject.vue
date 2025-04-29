<template>

  <v-row v-if="!hidden">
    <v-col cols="12">

      <v-card class="mb-8">
        <v-card-title class="title font-weight-light white--text">
            <span>{{ $t('Project') }}</span>
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
            <v-row v-show="showName">
              <v-col :cols="multilingual ? 8 : 12">
                <v-text-field
                  :value="name"
                  :label="$t('Title')"
                  v-on:blur="$emit('input-name',$event.target.value)"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                ></v-text-field>
              </v-col>
              <v-col cols="1" v-if="multilingual">
                <v-btn text @click="$refs.langdialogname.open()">
                  <span>
                    ({{ nameLanguage ? nameLanguage : '--' }})
                  </span>
                </v-btn>
                <select-language ref="langdialogname" @language-selected="$emit('input-name-language', $event)"></select-language>
              </v-col>

            </v-row>

            <v-row v-show="showDescription">
              <v-col :cols="multilingual ? 8 : 12">
                <v-text-field
                  :value="description"
                  :label="$t('Description')"
                  v-on:input="$emit('input-description', $event)"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                ></v-text-field>
              </v-col>
              <v-col cols="1" v-if="multilingual">
                <v-btn text @click="$refs.langdialogdesc.open()">
                  <span>
                    ({{ descriptionLanguage ? descriptionLanguage : '--' }})
                  </span>
                </v-btn>
                <select-language ref="langdialogdesc" @language-selected="$emit('input-description-language', $event)"></select-language>
              </v-col>
            </v-row>

            <v-row v-show="showDates">
                <v-col cols="12" :md="6">
                  <template>
                    <v-text-field
                      :value="dateFrom"
                      v-on:blur="$emit('input-date-from',$event.target.value)"
                      :label="$t('Date from')"
                      :rules="[validationrules.date]"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                      :error-messages="dateFromErrorMessages"
                    >
                      <template v-slot:append>
                        <v-fade-transition leave-absolute>
                          <v-menu
                            v-model="dateFromMenu"
                            :close-on-content-click="false"
                            transition="scale-transition"
                            offset-y
                            max-width="290px"
                            min-width="290px"
                          >
                            <template v-slot:activator="{ on, attrs }">
                              <v-icon v-on="on" v-bind="attrs">mdi-calendar</v-icon>
                            </template>
                            <v-date-picker
                              color="primary"
                              :value="dateFrom"
                              :show-current="false"
                              v-model="pickerFromModel"
                              :first-day-of-week="1"
                              :locale="alpha2bcp47($i18n.locale)"
                              v-on:input="dateFromMenu = false; $emit('input-date-from', $event)"
                            ></v-date-picker>
                          </v-menu>
                        </v-fade-transition>
                      </template>
                    </v-text-field>
                  </template>
                </v-col>
                <v-col cols="12" :md="6">
                  <template>
                    <v-text-field
                      :value="dateTo"
                      v-on:blur="$emit('input-date-to',$event.target.value)"
                      :label="$t('Date to')"
                      :rules="[validationrules.date]"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                      :error-messages="dateToErrorMessages"
                    >
                      <template v-slot:append>
                        <v-fade-transition leave-absolute>
                          <v-menu
                            v-model="dateToMenu"
                            :close-on-content-click="false"
                            transition="scale-transition"
                            offset-y
                            max-width="290px"
                            min-width="290px"
                          >
                            <template v-slot:activator="{ on, attrs }">
                              <v-icon v-on="on" v-bind="attrs">mdi-calendar</v-icon>
                            </template>
                            <v-date-picker
                              color="primary"
                              :value="dateTo"
                              :show-current="false"
                              v-model="pickerToModel"
                              :first-day-of-week="1"
                              :locale="alpha2bcp47($i18n.locale)"
                              v-on:input="dateToMenu = false; $emit('input-date-to', $event)"
                            ></v-date-picker>
                          </v-menu>
                        </v-fade-transition>
                      </template>
                    </v-text-field>
                  </template>
                </v-col>
            </v-row>

            <v-row >
              <v-col cols="4" v-show="showAcronym">
                <v-text-field
                  :value="acronym"
                  :label="$t('Acronym')"
                  v-on:blur="$emit('input-acronym',$event.target.value)"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                ></v-text-field>
              </v-col>
              <v-col cols="4">
                <v-text-field
                  :value="code"
                  :label="$t('Code / Identifier')"
                  v-on:blur="$emit('input-code',$event.target.value)"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                ></v-text-field>
              </v-col>
              <v-col cols="4" v-show="showHomepage">
                <v-text-field
                  :value="homepage"
                  :label="$t('Homepage')"
                  v-on:blur="$emit('input-homepage',$event.target.value)"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                ></v-text-field>
              </v-col>
            </v-row>

            <v-row >
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
        </v-row>
        <v-row>
          <v-col cols="6">
            <v-text-field
              :value="funderName"
              :label="$t('Funder name')"
              v-on:blur="$emit('input-funder-name',$event.target.value)"
              :filled="inputStyle==='filled'"
              :outlined="inputStyle==='outlined'"
            ></v-text-field>
          </v-col>
          <v-col cols="1" v-if="multilingual">
            <v-btn text @click="$refs.langdialogfunder.open()">
              <span>
                ({{ funderNameLanguage ? funderNameLanguage : '--' }})
              </span>
            </v-btn>
            <select-language ref="langdialogfunder" @language-selected="$emit('input-funder-name-language', $event)"></select-language>
          </v-col>
          <v-col :cols="multilingual ? 4 : 6">
            <v-row >
              <v-col :cols="6" v-if="!hideIdentifierType && !hideIdentifier">
                <v-autocomplete
                  v-on:input="$emit('input-funder-identifier-type', $event)"
                  :label="$t('Type of funder identifier')"
                  :items="vocabularies[identifierVocabulary].terms"
                  :item-value="'@id'"
                  :value="getTerm(identifierVocabulary, funderIdentifierType)"
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
                  :value="funderIdentifier"
                  :label="$t('Funder identifier')"
                  v-on:blur="$emit('input-funder-identifier',$event.target.value)"
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
import datepickerproperties from '../../mixins/datepickerproperties'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-project',
  mixins: [vocabulary, fieldproperties, validationrules, datepickerproperties],
  components: {
    SelectLanguage
  },
  props: {
    type: {
      type: String
    },
    name: {
      type: String
    },
    acronym: {
      type: String
    },
    nameLanguage: {
      type: String
    },
    funderName: {
      type: String
    },
    funderNameLanguage: {
      type: String
    },
    code: {
      type: String
    },
    identifierType: {
      type: String
    },
    identifier: {
      type: String
    },
    funderIdentifierType: {
      type: String
    },
    funderIdentifier: {
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
    description: {
      type: String
    },
    descriptionLanguage: {
      type: String
    },
    homepage: {
      type: String
    },
    showIds: {
      type: Boolean,
      default: false
    },
    showName: {
      type: Boolean,
      default: true
    },
    showDescription: {
      type: Boolean,
      default: true
    },
    showDates: {
      type: Boolean,
      default: true
    },
    showAcronym: {
      type: Boolean,
      default: true
    },
    showHomepage: {
      type: Boolean,
      default: true
    },
    multilingual: {
      type: Boolean,
      default: true
    },
    dateFrom: String,
    dateTo: String,
    dateFromErrorMessages: Array,
    dateToErrorMessages: Array
  },
  data () {
    return {
      pickerFromModel: new Date().toISOString().substr(0, 10),
      dateFromMenu: false,
      pickerToModel: new Date().toISOString().substr(0, 10),
      dateToMenu: false
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
