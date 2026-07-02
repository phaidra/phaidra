<template>

  <v-row v-if="!hidden">
    <v-col cols="12">

      <v-card :variant="showHeader ? 'outlined' : 'flat'" class="mb-8">
        <template v-if="showHeader">
          <v-card-title class="title font-weight-light text-white">
              <span>{{ $t('Project') }}</span>
              <v-spacer></v-spacer>
              <v-menu open-on-hover bottom offset-y v-if="actions.length">
                <template v-slot:activator="{ props: activatorProps }">
                  <v-icon-btn v-bind="activatorProps" variant="text" color="white" icon="mdi-dots-vertical" />
                </template>
                <v-list>
                  <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
                    <v-list-item-title>{{ action.title }}</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
          </v-card-title>
          <v-divider></v-divider>
        </template>
        <v-card-text class="mt-4">

        <v-row>
          <v-col>
            <v-row v-show="showName">
              <v-col :cols="multilingual ? 8 : 12">
                <v-text-field
                  :model-value="name"
                  :label="$t('Title')"
                  @update:model-value="$emit('input-name', $event)"
                  :variant="fieldVariant"
                ></v-text-field>
              </v-col>
              <v-col cols="1" v-if="multilingual">
                <v-btn variant="text" @click="$refs.langdialogname.open()">
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
                  :model-value="description"
                  :label="$t('Description')"
                  @update:model-value="$emit('input-description', $event)"
                  :variant="fieldVariant"
                ></v-text-field>
              </v-col>
              <v-col cols="1" v-if="multilingual">
                <v-btn variant="text" @click="$refs.langdialogdesc.open()">
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
                      :model-value="dateFrom"
                      @update:model-value="$emit('input-date-from', $event)"
                      :label="$t('Date from')"
                      :rules="[validationrules.date]"
                      :variant="fieldVariant"
                      :error-messages="dateFromErrorMessages"
                    >
                      <template v-slot:append-inner>
                        <v-menu
                          v-model="dateFromMenu"
                          :close-on-content-click="false"
                          transition="scale-transition"
                          offset-y
                          max-width="290px"
                          min-width="290px"
                        >
                          <template v-slot:activator="{ props: activatorProps }">
                            <v-icon v-bind="activatorProps">mdi-calendar</v-icon>
                          </template>
                          <v-date-picker
                            color="primary"
                            :show-current="false"
                            v-model="pickerFromModel"
                            :first-day-of-week="1"
                            :locale="alpha2bcp47($i18n.locale)"
                            @update:model-value="dateFromMenu = false; $emit('input-date-from', $event)"
                          ></v-date-picker>
                        </v-menu>
                      </template>
                    </v-text-field>
                  </template>
                </v-col>
                <v-col cols="12" :md="6">
                  <template>
                    <v-text-field
                      :model-value="dateTo"
                      @update:model-value="$emit('input-date-to', $event)"
                      :label="$t('Date to')"
                      :rules="[validationrules.date]"
                      :variant="fieldVariant"
                      :error-messages="dateToErrorMessages"
                    >
                      <template v-slot:append-inner>
                        <v-menu
                          v-model="dateToMenu"
                          :close-on-content-click="false"
                          transition="scale-transition"
                          offset-y
                          max-width="290px"
                          min-width="290px"
                        >
                          <template v-slot:activator="{ props: activatorProps }">
                            <v-icon v-bind="activatorProps">mdi-calendar</v-icon>
                          </template>
                          <v-date-picker
                            color="primary"
                            :show-current="false"
                            v-model="pickerToModel"
                            :first-day-of-week="1"
                            :locale="alpha2bcp47($i18n.locale)"
                            @update:model-value="dateToMenu = false; $emit('input-date-to', $event)"
                          ></v-date-picker>
                        </v-menu>
                      </template>
                    </v-text-field>
                  </template>
                </v-col>
            </v-row>

            <v-row >
              <v-col cols="4" v-show="showAcronym">
                <v-text-field
                  :model-value="acronym"
                  :label="$t('Acronym')"
                  @update:model-value="$emit('input-acronym', $event)"
                  :variant="fieldVariant"
                ></v-text-field>
              </v-col>
              <v-col cols="4">
                <v-text-field
                  :model-value="code"
                  :label="$t('Code / Identifier')"
                  @update:model-value="$emit('input-code', $event)"
                  :variant="fieldVariant"
                ></v-text-field>
              </v-col>
              <v-col cols="4" v-show="showHomepage">
                <v-text-field
                  :model-value="homepage"
                  :label="$t('Homepage')"
                  @update:model-value="$emit('input-homepage', $event)"
                  :variant="fieldVariant"
                ></v-text-field>
              </v-col>
            </v-row>

            <v-row >
              <v-col :cols="6" v-if="!hideIdentifierType && !hideIdentifier">
                <v-autocomplete
                  :no-data-text="$t('No data available')"
                  @update:model-value="$emit('input-identifier-type', $event)"
                  :label="$t('Type of identifier')"
                  :items="vocabularies[identifierVocabulary].terms"
                  item-value="@id"
                  :item-title="(item) => skosTermItemTitle(item, identifierVocabulary)"
                  :model-value="getTerm(identifierVocabulary, identifierType)"
                  :custom-filter="vocabAutocompleteFilter"
                  :variant="fieldVariant"
                  return-object
                  clearable
                >
                  <template #item="{ props, internalItem }">
                    <v-list-item v-bind="props" lines="one">
                      <template #title>
                        <span v-html="`${getLocalizedTermLabel(identifierVocabulary, internalItem.raw['@id'])}`" />
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ internalItem }">
                    <span v-html="`${getLocalizedTermLabel(identifierVocabulary, (internalItem.raw || internalItem)['@id'])}`" />
                  </template>
                </v-autocomplete>
              </v-col>
              <v-col :cols="!hideIdentifierType ? 6 : 12" v-if="!hideIdentifier">
                <v-text-field
                  :model-value="identifier"
                  :label="$t('Identifier')"
                  @update:model-value="$emit('input-identifier', $event)"
                  :variant="fieldVariant"
                ></v-text-field>
              </v-col>
            </v-row>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="2">
            <v-radio-group v-model="funderRadio" class="mt-0" @change="$emit('change-funder-type', $event)">
              <v-radio color="primary" :label="$t('Funder name')" :value="'name'"></v-radio>
              <v-radio color="primary" :label="'ROR'" :value="'ror'"></v-radio>
            </v-radio-group>
          </v-col>

          <v-col cols="12" md="10" v-if="funderRadio === 'name'">
            <v-row>
              <v-col cols="6">
                <v-text-field
                  :model-value="funderName"
                  :label="$t('Funder name')"
                  @update:model-value="$emit('input-funder-name', $event)"
                  :variant="fieldVariant"
                ></v-text-field>
              </v-col>

              <v-col cols="1" v-if="multilingual">
                <v-btn variant="text" @click="$refs.langdialogfunder.open()">
                  <span>({{ funderNameLanguage ? funderNameLanguage : '--' }})</span>
                </v-btn>
                <select-language ref="langdialogfunder" @language-selected="$emit('input-funder-name-language', $event)"></select-language>
              </v-col>

              <v-col :cols="multilingual ? 5 : 6">
                <v-row>
                  <v-col :cols="6" v-if="!hideIdentifierType && !hideIdentifier">
                    <v-autocomplete
                      @update:model-value="$emit('input-funder-identifier-type', $event)"
                      :label="$t('Type of funder identifier')"
                      :items="vocabularies[identifierVocabulary].terms"
                      item-value="@id"
                      :item-title="(item) => skosTermItemTitle(item, identifierVocabulary)"
                      :model-value="getTerm(identifierVocabulary, funderIdentifierType)"
                      :custom-filter="vocabAutocompleteFilter"
                      :variant="fieldVariant"
                      return-object
                      clearable
                    >
                      <template #item="{ props, internalItem }">
                        <v-list-item v-bind="props" lines="one">
                          <template #title>
                            <span v-html="`${getLocalizedTermLabel(identifierVocabulary, internalItem.raw['@id'])}`" />
                          </template>
                        </v-list-item>
                      </template>
                      <template #selection="{ internalItem }">
                        <span v-html="`${getLocalizedTermLabel(identifierVocabulary, (internalItem.raw || internalItem)['@id'])}`" />
                      </template>
                    </v-autocomplete>
                  </v-col>
                  <v-col :cols="!hideIdentifierType ? 6 : 12" v-if="!hideIdentifier">
                    <v-text-field
                      :model-value="funderIdentifier"
                      :label="$t('Funder identifier')"
                      @update:model-value="$emit('input-funder-identifier', $event)"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                </v-row>
              </v-col>
            </v-row>
          </v-col>

          <v-col cols="12" md="10" v-if="funderRadio === 'ror'">
            <ror-search v-on:resolve="$emit('input-funder-ror',$event)" :value="funderRor" :text="funderRorName" :errorMessages="funderRorErrorMessages"></ror-search>
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
import RorSearch from '../select/RorSearch'

export default {
  name: 'p-i-project',
  mixins: [vocabulary, fieldproperties, validationrules, datepickerproperties],
  components: {
    SelectLanguage,
    RorSearch
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
    funderRor: {
      type: String
    },
    funderRorName: {
      type: String
    },
    funderType: {
      type: String
    },
    funderRorErrorMessages: {
      type: Array
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
    dateToErrorMessages: Array,
    showHeader: {
      type: Boolean,
      default: true
    }
  },
  data () {
    return {
      pickerFromModel: new Date().toISOString().substr(0, 10),
      dateFromMenu: false,
      pickerToModel: new Date().toISOString().substr(0, 10),
      dateToMenu: false,
      funderRadio: this.funderType || 'name'
    }
  },
  watch: {
    funderType: function (newVal) {
      if (newVal) {
        this.funderRadio = newVal
      }
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
