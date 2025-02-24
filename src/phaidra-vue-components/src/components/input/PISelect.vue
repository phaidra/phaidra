<template>
  <v-col cols="12" v-if="!hidden">
    <v-row>
      <v-col :cols="(actions.length ? 10 : 12)">
        <!---->
        <v-autocomplete
          :value="getTerm(vocabulary, value)"
          :background-color="backgroundColor ? backgroundColor : undefined"
          v-on:input="$emit('input', $event)"
          :rules="required ? [ v => !!v || 'Required'] : []"
          :items="loadedTerms"
          :item-value="'@id'"
          :loading="loading"
          :filter="autocompleteFilter"
          hide-no-data
          :height="7"
          :label="$t(label)"
          :filled="inputStyle==='filled'"
          :outlined="inputStyle==='outlined'"
          return-object
          clearable
          :readonly="readonly"
          :disabled="disabled || readonly"
          :hint="hint"
          :persistent-hint="hint ? true : false"
          :error-messages="errorMessages"
        >
          <!-- the attr binds the 'disabled' property of the vocabulary term (if defined) to the item component -->
          <template slot="item" slot-scope="{ attr, item }">
            <v-list-item-content two-line>
              <v-list-item-title  v-html="`${getLocalizedTermLabel(vocabulary, item['@id'])}`"></v-list-item-title>
              <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
            </v-list-item-content>
          </template>
          <template slot="selection" slot-scope="{ item }">
            <v-list-item-content>
              <v-list-item-title v-html="`${getLocalizedTermLabel(vocabulary, item['@id'])}`"></v-list-item-title>
            </v-list-item-content>
          </template>
        </v-autocomplete>
      </v-col>
      <v-col cols="2" v-if="actions.length">
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
    <v-slide-y-transition hide-on-leave>
      <v-row no-gutters v-if="showValueDefinition" v-show="value && getLocalizedDefinition(vocabulary, value)" :class=" hint ? 'mt-2 mb-6' : 'mb-6'">
        <v-col cols="10">
          <v-row class="px-4">
            <p v-html="getLocalizedDefinition(vocabulary, value)"></p>
          </v-row>
        </v-col>
      </v-row>
    </v-slide-y-transition>
    <v-slide-y-transition hide-on-leave>
      <v-row no-gutters v-show="showDisclaimer && isCCLicense" :class=" hint ? 'mt-2 mb-6' : 'mb-6'">
        <v-col cols="10">
          <v-row class="px-4">
            <p v-html="$t('LICENSE_DISCLAIMER', { institution: $t($store.state.instanceconfig.institution) })"></p>
          </v-row>
        </v-col>
      </v-row>
    </v-slide-y-transition>
  </v-col>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-select',
  mixins: [vocabulary, fieldproperties],
  props: {
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    required: {
      type: Boolean
    },
    vocabulary: {
      type: String,
      required: true
    },
    disabled: {
      type: Boolean,
      default: false
    },
    showValueDefinition: {
      type: Boolean,
      default: false
    },
    hint: {
      type: String
    },
    errorMessages: {
      type: Array
    },
    showIds: {
      type: Boolean,
      default: false
    },
    showDisclaimer: {
      type: Boolean,
      default: true
    },
    readonly: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    loadedTerms: function () {
      if (this.vocabularies[this.vocabulary]) {
        return this.vocabularies[this.vocabulary].loaded ? this.vocabularies[this.vocabulary].terms : []
      }
      return []
    },
    isCCLicense: function () {
      return this.value?.startsWith('http://creativecommons.org/licenses') || this.value?.startsWith('https://opensource.org/license')
    }
  },
  data () {
    return {
      loading: false,
      terms: []
    }
  },
  mounted: function () {
    this.$nextTick(async function () {
      if (this.vocabulary) {
        if (this.vocabularies[vocabulary]) {
          if (this.vocabularies[vocabulary].loaded) {
            // emit input to set skos:prefLabel in parent
            if (this.value) {
              for (let term of this.vocabularies[this.vocabulary].terms) {
                if (term['@id'] === this.value) {
                  this.$emit('input', term)
                }
              }
            }
          }
        } else {
          await this.$store.dispatch('vocabulary/loadVocabulary', this.vocabulary)
          // emit input to set skos:prefLabel in parent
          if (this.value) {
            for (let term of this.vocabularies[this.vocabulary].terms) {
              if (term['@id'] === this.value) {
                this.$emit('input', term)
              }
            }
          }
        }
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
