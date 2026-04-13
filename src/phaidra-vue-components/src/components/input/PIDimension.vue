<template>
  <v-row v-if="!hidden">
    <v-col cols="2">
      <v-text-field
        :model-value="value"
        @update:model-value="$emit('input-value', $event)"
        :label="$t(label)"
        :variant="fieldVariant"
      ></v-text-field>
    </v-col>
    <v-col cols="2">
      <v-select
        :model-value="getTerm(vocabulary, unit)"
        @update:model-value="$emit('input-unit', $event)"
        :label="$t('Unit')"
        :items="vocabularies[vocabulary].terms"
        item-value="@id"
        :item-title="(item) => skosTermItemTitle(item, vocabulary)"
        :custom-filter="vocabAutocompleteFilter"
        :variant="fieldVariant"
        return-object
        clearable
      >
        <template #item="{ props, item }">
          <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
            <template #title>
              <span v-html="getLocalizedTermLabel(vocabulary, item.raw['@id'])" />
            </template>
            <template v-if="showIds" #subtitle>
              <span v-html="item.raw['@id']" />
            </template>
          </v-list-item>
        </template>
        <template #selection="{ item }">
          <span v-html="getLocalizedTermLabel(vocabulary, (item.raw || item)['@id'])" />
        </template>
      </v-select>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ props: activatorProps }">
          <v-btn v-bind="activatorProps" icon variant="text">
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

export default {
  name: 'p-i-dimension',
  mixins: [vocabulary, fieldproperties],
  props: {
    unit: {
      type: String
    },
    vocabulary: {
      type: String,
      default: 'uncefact'
    },
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
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
</style>
