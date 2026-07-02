<template>

  <v-row v-if="!hidden">
    <v-col cols="12">

      <v-card variant="outlined" class="mb-8">
        <v-card-title class="title font-weight-light text-white">
            <span>{{ $t('Event') }}</span>
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
        <v-card-text class="mt-4">
          <v-row>
            <v-col>
              <v-row >
                <v-col cols="10">
                  <v-text-field
                    :model-value="name"
                    :label="$t('Name')"
                    @update:model-value="$emit('input-name', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="2">
                  <v-btn variant="text" @click="$refs.langdialogname.open()">
                    <span>
                      ({{ nameLanguage ? nameLanguage : '--' }})
                    </span>
                  </v-btn>
                  <select-language ref="langdialogname" @language-selected="$emit('input-name-language', $event)"></select-language>
                </v-col>

              </v-row>

              <v-row >
                <v-col cols="10">
                  <v-text-field
                    :model-value="description"
                    :label="$t('Description')"
                    @update:model-value="$emit('input-description', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="2">
                  <v-btn variant="text" @click="$refs.langdialogdescription.open()">
                    <span>
                      ({{ descriptionLanguage ? descriptionLanguage : '--' }})
                    </span>
                  </v-btn>
                  <select-language ref="langdialogdescription" @language-selected="$emit('input-description-language', $event)"></select-language>
                </v-col>

              </v-row>

              <v-row>
                <v-col cols="12" :md="4">
                  <v-text-field
                    :model-value="place"
                    @update:model-value="$emit('input-place', $event)"
                    :label="$t(placeLabel ? placeLabel : 'Place')"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="12" :md="4">
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
                <v-col cols="12" :md="4">
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
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12" md="6">
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
            <v-col cols="12" md="6" >
              <v-text-field
                :model-value="identifierText"
                :label="identifierLabel ? identifierLabel : $t('Identifier')"
                @update:model-value="$emit('input-identifier', $event)"
                :placeholder="identifierTypePlaceholder"
                :rules="identifierType ? [validationrules[getIdentifierRuleName(identifierType)]] : [validationrules['noop']]"
                :variant="fieldVariant"
              ></v-text-field>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import datepickerproperties from '../../mixins/datepickerproperties'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-event',
  mixins: [vocabulary, fieldproperties, validationrules, datepickerproperties],
  components: {
    SelectLanguage
  },
  props: {
    name: String,
    nameLanguage: String,
    place: String,
    placeLabel: String,
    identifierType: String,
    identifierText: String,
    identifierLabel: String,
    description: String,
    descriptionLanguage: String,
    dateFrom: String,
    dateTo: String,
    dateFromErrorMessages: Array,
    dateToErrorMessages: Array,
    identifierVocabulary: {
      type: String,
      default: 'entityidentifiertype'
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
