<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card variant="outlined" class="mb-8">
        <v-card-title class="text-h6 font-weight-light text-white">
            <span>{{ $t(label) }}</span>
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
                <v-col cols="6">
                  <v-text-field
                    :model-value="title"
                    :label="$t('Title')"
                    @update:model-value="$emit('input-title', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="6">
                  <v-text-field
                    :model-value="subtitle"
                    :label="$t('Subtitle')"
                    @update:model-value="$emit('input-subtitle', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="2">
                  <v-btn variant="text" @click="$refs.langdialog.open()">
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
