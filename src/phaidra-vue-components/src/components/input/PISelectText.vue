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
    <v-col cols="12" md="2" v-if="multilingual || actions.length">
      <v-row>
        <v-col v-if="multilingual" cols="6">
          <v-btn text @click="$refs.langdialog.open()">
            <span class="grey--text text--darken-1">
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

      <select-language ref="langdialog" @language-selected="$emit('input-language', $event)"></select-language>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-select-text',
  mixins: [vocabulary, fieldproperties],
  components: {
    SelectLanguage
  },
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
