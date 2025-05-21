<template>
  <v-row v-if="!hidden">
    <v-col cols="4" v-if="showtype">
      <v-autocomplete
        v-on:input="$emit('input-association-type', $event)"
        :label="$t('Type')"
        :items="vocabularies['orgtypes'].terms"
        :item-value="'@id'"
        :value="getTerm('orgtypes', type)"
        :filter="autocompleteFilter"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('orgtypes', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('orgtypes', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="12" :md="multilingual ? (actions.length ? 6 : 8) : (actions.length ? 8 : 10)">
      <v-text-field v-if="!multiline"
        :value="value"
        v-on:blur="$emit('input',$event.target.value)"
        :label="$t(label)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        :error-messages="errorMessages"
      ></v-text-field>
      <v-textarea v-if="multiline"
        :value="value"
        v-on:blur="$emit('input',$event.target.value)"
        :label="$t(label)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        :error-messages="errorMessages"
      ></v-textarea>
    </v-col>
    <v-col cols="12" md="2" v-if="multilingual || actions.length">
      <v-row>
        <v-col v-if="multilingual" cols="6">
          <v-btn text @click="$refs.langdialog.open()">
            <span>
              ({{ language ? language : '--' }})
            </span>
          </v-btn>
        </v-col>
        <v-col cols="6" v-if="actions.length">
          <v-btn icon @click="showMenu">
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </v-col>
      </v-row>

      <v-menu :position-x="menux" :position-y="menuy" absolute offset-y v-model="showMenuModel">
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>

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
