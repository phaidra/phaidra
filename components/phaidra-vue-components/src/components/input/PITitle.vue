<template>
  <v-row v-if="!hidden">
    <v-col cols="12" :md="hideSubtitle ? ( multilingual ? 8 : (actions.length ? 10 : 12) ) : ( multilingual ? 4 : (actions.length ? 6 : 8) )">
      <v-text-field
        :value="title"
        :label="$t( titleLabel ? titleLabel : type )"
        v-on:blur="$emit('input-title',$event.target.value)"
        :background-color="titleBackgroundColor ? titleBackgroundColor : undefined"
        :error-messages="titleErrorMessages"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="12" md="4" v-if="!hideSubtitle">
      <v-text-field
        :value="subtitle"
        :label="$t( subtitleLabel ? subtitleLabel : 'Subtitle' )"
        v-on:blur="$emit('input-subtitle',$event.target.value)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="12" :md="actions.length ? 2 : 4" v-if="multilingual">
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
  name: 'p-i-title',
  mixins: [vocabulary, fieldproperties],
  props: {
    title: {
      type: String
    },
    titleErrorMessages: {
      type: Array
    },
    titleLabel: {
      type: String
    },
    type: {
      type: String
    },
    subtitle: {
      type: String
    },
    subtitleLabel: {
      type: String
    },
    hideSubtitle: {
      type: Boolean
    },
    language: {
      type: String
    },
    required: {
      type: Boolean
    },
    multilingual: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    },
    titleBackgroundColor: {
      type: String,
      default: undefined
    }
  },
  data () {
    return {
      datepicker: false,
      selectedDate: ''
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
