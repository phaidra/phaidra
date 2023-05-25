<template>
  <v-row v-if="!hidden">
    <v-col cols="3">
      <v-autocomplete
        :value="getTerm(vocabulary, selectvalue)"
        :required="required"
        v-on:input="updateLocation('select', $event)"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :items="vocabularies[vocabulary].terms"
        :item-value="'@id'"
        :filter="autocompleteFilter"
        hide-no-data
        :label="$t(selectlabel)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
      >
        <template slot="item" slot-scope="{ item }">
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
    <v-col cols="4">
      <v-text-field
        :value="textvalue"
        v-on:input="updateLocation('text', $event)"
        :label="$t(label)"
        :required="required"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
      ></v-text-field>
    </v-col>
    <v-col cols="3" v-if="multilingual">
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
  name: 'p-i-select-text',
  mixins: [vocabulary, fieldproperties],
  props: {
    textvalue: {
      type: String
    },
    language: {
      type: String
    },
    selectvalue: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    selectlabel: {
      type: String,
      required: true
    },
    selectdisabled: {
      type: Boolean,
      default: false
    },
    vocabulary: {
      type: String,
      required: true
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
    }
  },
  data () {
    return {
      location: '',
      svalue: '',
      tvalue: ''
    }
  },
  methods: {
    updateLocation: function (source, value) {
      this.location = ''
      if (source === 'select') {
        if (value) {
          this.svalue = value['@id']
          this.$emit('input-select', this.svalue)
        } else {
          this.svalue = ''
        }
      }
      if (source === 'text') {
        if (value) {
          this.tvalue = value
          this.$emit('input-text', this.tvalue)
        }
      }
      if (this.svalue) {
        this.location = this.svalue
      }
      if (this.tvalue) {
        if (this.location !== '') {
          this.location = this.location + '; '
        }
        this.location = this.location + this.tvalue
      }
      this.$emit('input', this.location)
    }
  },
  mounted: function () {
    if (this.selectvalue) {
      this.location = this.selectvalue
    }
    if (this.value) {
      this.location = this.location + '; ' + this.value
    }
    this.$emit('input', this.location)
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
