<template>
  <v-row v-if="!hidden">
    <v-col cols="5">
      <v-autocomplete
        v-on:input="$emit('input-place-type', $event)"
        :label="$t('Type of place')"
        :items="vocabularies['placetype'].terms"
        :item-value="'@id'"
        :value="getTerm('placetype', type)"
        :filter="autocompleteFilter"
        :disabled="disabletype"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('placetype', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('placetype', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="4">
      <v-text-field v-if="!multiline"
        :value="value"
        v-on:input="$emit('input', $event)"
        :label="$t(label)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
      <v-textarea v-if="multiline"
        :value="value"
        v-on:input="$emit('input', $event)"
        :label="$t(label)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-textarea>
    </v-col>
    <v-col cols="2" v-if="multilingual">
      <v-autocomplete
        :value="getTerm('lang', language)"
        v-on:input="$emit('input-language', $event )"
        :items="vocabularies['lang'].terms"
        :item-value="'@id'"
        :filter="autocompleteFilter"
        hide-no-data
        :label="$t('Language')"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('lang', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('lang', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on }">
          <v-btn v-on="on" icon>
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
  name: 'p-i-text-field',
  mixins: [vocabulary, fieldproperties],
  props: {
    value: {
      type: String,
      required: true
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
      this.loading = !this.vocabularies['placetype'].loaded
      // emit input to set skos:prefLabel in parent
      if (this.type) {
        this.$emit('input-place-type', this.getTerm('placetype', this.type))
      }
    })
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
