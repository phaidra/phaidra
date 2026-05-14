<template>
  <v-row v-if="!hidden">
    <v-col cols="4" v-if="showtype">
      <v-autocomplete
        :no-data-text="$t('No data available')"
        @update:model-value="$emit('input-association-type', $event)"
        :label="$t('Type')"
        :items="vocabularies['orgtypes'].terms"
        item-value="@id"
        :item-title="(item) => skosTermItemTitle(item, 'orgtypes')"
        :model-value="getTerm('orgtypes', type)"
        :custom-filter="vocabAutocompleteFilter"
        :variant="fieldVariant"
        return-object
        clearable
      >
        <template #item="{ props, internalItem }">
          <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
            <template #title>
              <span v-html="`${getLocalizedTermLabel('orgtypes', internalItem.raw['@id'])}`" />
            </template>
            <template v-if="showIds" #subtitle>
              <span v-html="internalItem.raw['@id']" />
            </template>
          </v-list-item>
        </template>
        <template #selection="{ internalItem }">
          <span v-html="`${getLocalizedTermLabel('orgtypes', (internalItem.raw || internalItem)['@id'])}`" />
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="12" :md="multilingual ? (actions.length ? 6 : 8) : (actions.length ? 8 : 10)">
      <v-text-field v-if="!multiline"
        :model-value="value"
        @update:model-value="$emit('input',$event)"
        :label="$t(label)"
        :required="required"
        :rules="required ? [ v => !!v || $t('Required')] : []"
        :variant="fieldVariant"
        :error-messages="errorMessages"
      ></v-text-field>
      <v-textarea v-if="multiline"
        :model-value="value"
        @update:model-value="$emit('input',$event)"
        :label="$t(label)"
        :required="required"
        :rules="required ? [ v => !!v || $t('Required')] : []"
        :variant="fieldVariant"
        :error-messages="errorMessages"
      ></v-textarea>
    </v-col>
    <v-col cols="12" md="2" v-if="multilingual || actions.length">
      <v-row>
        <v-col v-if="multilingual" cols="6">
          <v-btn variant="text" @click="$refs.langdialog.open()">
            <span>
              ({{ language ? language : '--' }})
            </span>
          </v-btn>
        </v-col>
        <v-col cols="6" v-if="actions.length">
          <v-menu location="bottom end" close-on-content-click>
            <template #activator="{ props: menuActivatorProps }">
              <v-btn icon v-bind="menuActivatorProps">
                <v-icon>mdi-dots-vertical</v-icon>
              </v-btn>
            </template>
            <v-list density="compact">
              <v-list-item
                v-for="(action, i) in actions"
                :key="i"
                @click="$emit(action.event, $event)"
              >
                <v-list-item-title>{{ action.title }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
        </v-col>
      </v-row>

      <select-language ref="langdialog" :showReset="allowLanguageCancel && language ? true : false" @language-selected="$emit('input-language', $event)"></select-language>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-association-text',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
  emits: ['input', 'input-association-type', 'input-language', 'add', 'remove', 'configure', 'add-clear', 'up', 'down'],
  props: {
    value: {
      type: String,
      required: true
    },
    errorMessages: {
      type: Array
    },
    type: {
      type: String
    },
    language: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    required: {
      type: Boolean
    },
    multiline: {
      type: Boolean
    },
    multilingual: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    },
    allowLanguageCancel: {
      type: Boolean,
      default: false
    },
    showtype: {
      type: Boolean,
      required: true,
      default: true
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
