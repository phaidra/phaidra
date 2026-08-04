<template>
  <v-row v-if="!hidden">
    <v-col cols="12" md="5" v-if="showType">
      <v-autocomplete
        :no-data-text="$t('No data available')"
        @update:model-value="$emit('input-identifier-type', $event)"
        :label="$t('Type of identifier')"
        :items="vocabularies[vocabulary].terms"
        item-value="@id"
        :item-title="(item) => skosTermItemTitle(item, vocabulary)"
        :model-value="getTerm(vocabulary, type)"
        :custom-filter="vocabAutocompleteFilter"
        :disabled="disabletype"
        :variant="fieldVariant"
        return-object
        clearable
      >
        <template #item="{ props, internalItem }">
          <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
            <template #title>
              <span v-html="getLocalizedTermLabel(vocabulary, internalItem.raw['@id'])" />
            </template>
            <template v-if="showIds" #subtitle>
              <span v-html="internalItem.raw['@id']" />
            </template>
          </v-list-item>
        </template>
        <template #selection="{ internalItem }">
          <span v-html="getLocalizedTermLabel(vocabulary, (internalItem.raw || internalItem)['@id'])" />
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="12" :md="showType ? (actions.length ? 5 : 7) : (actions.length ? 10 : 12) ">
      <v-text-field
        :model-value="value"
        @update:model-value="$emit('input-identifier', $event)"
        :label="$t(identifierLabel ? identifierLabel : 'Identifier')"
        :placeholder="placeholder(type)"
        :required="required"
        :rules="[validationrules[getIdentifierRuleName(type)]]"
        :variant="fieldVariant"
        :error-messages="valueErrorMessages"
      ></v-text-field>
    </v-col>
    <template v-if="actions.length">
      <template v-if="addOnly">
        <v-col cols="1" class="mt-3">
          <v-icon-btn @click="$emit('add-clear', $event)" icon="mdi-plus" />
        </v-col>
      </template>
      <template v-else-if="removeOnly">
        <v-col cols="1" class="mt-3">
          <v-icon @click="$emit('remove', $event)">mdi-minus</v-icon>
        </v-col>
      </template>
      <v-col cols="1" v-else-if="actions.length">
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
    </template>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'

export default {
  name: 'p-i-alternate-identifier',
  mixins: [vocabulary, fieldproperties, validationrules],
  props: {
    value: {
      type: String,
      required: true
    },
    type: {
      type: String
    },
    identifierLabel: {
      type: String
    },
    valueErrorMessages: {
      type: Array
    },
    vocabulary: {
      type: String,
      default: 'objectidentifiertype'
    },
    required: {
      type: Boolean
    },
    disabletype: {
      type: Boolean
    },
    showType: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    placeholder: function (type) {
      for (let i of this.vocabularies[this.vocabulary].terms) {
        if (i['@id'] === type) {
          return i['skos:example']
        }
      }
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      this.loading = !this.vocabularies[this.vocabulary].loaded
    })
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
