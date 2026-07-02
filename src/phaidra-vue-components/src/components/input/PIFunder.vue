<template>

  <v-row v-if="!hidden">
    <v-col cols="4">
      <v-text-field
        :model-value="name"
        :label="$t('Funder name')"
        @update:model-value="$emit('input-name', $event)"
        :variant="fieldVariant"
      ></v-text-field>
    </v-col>
    <v-col cols="2">
      <v-btn variant="text" @click="$refs.langdialog.open()">
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
            :no-data-text="$t('No data available')"
            @update:model-value="$emit('input-identifier-type', $event)"
            :label="$t('Type of funder identifier')"
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
                  <span v-html="getLocalizedTermLabel(identifierVocabulary, internalItem.raw['@id'])" />
                </template>
              </v-list-item>
            </template>
            <template #selection="{ internalItem }">
              <span v-html="getLocalizedTermLabel(identifierVocabulary, (internalItem.raw || internalItem)['@id'])" />
            </template>
          </v-autocomplete>
        </v-col>
        <v-col :cols="!hideIdentifierType ? 6 : 12" v-if="!hideIdentifier">
          <v-text-field
            :model-value="identifier"
            :label="$t('Funder identifier')"
            @update:model-value="$emit('input-identifier', $event)"
            :variant="fieldVariant"
          ></v-text-field>
        </v-col>
      </v-row>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ props: activatorProps }">
          <v-icon-btn v-bind="activatorProps" variant="text" icon="mdi-dots-vertical" />
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
