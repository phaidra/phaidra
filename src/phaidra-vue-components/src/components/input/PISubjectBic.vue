<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-row>
        <v-col cols="10">
          <v-autocomplete
            :value="getTerm('bic', value)"
            :required="required"
            v-on:input="handleInput($event)"
            :rules="required ? [ v => !!v || 'Required'] : []"
            :items="vocabularies['bic'].terms"
            :item-value="'@id'"
            :loading="loading"
            :filter="autocompleteFilterWithNotation"
            hide-no-data
            :label="$t(label)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
            return-object
            clearable
            :disabled="disabled"
            :messages="path"
            :error-messages="errorMessages"
          >
            <template slot="item" slot-scope="{ item }">
              <v-list-item-content two-line>
                <v-list-item-title  v-html="`${getLocalizedTermLabel('bic', item['@id']) + ' - ' + item['skos:notation'][0]}`"></v-list-item-title>
                <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
              </v-list-item-content>
            </template>
            <template slot="selection" slot-scope="{ item }">
              <v-list-item-content>
                <v-list-item-title v-html="`${getLocalizedTermLabel('bic', item['@id']) + ' - ' + item['skos:notation'][0]}`"></v-list-item-title>
              </v-list-item-content>
            </template>
            <template v-slot:append-outer>
              <v-icon @click="$refs.bictreedialog.open()">mdi-file-tree</v-icon>
            </template>
          </v-autocomplete>
        </v-col>
        <v-col cols="1" v-if="actions.length">
          <v-menu open-on-hover bottom offset-y>
            <template v-slot:activator="{ on, attrs }">
              <v-btn v-on="on" v-bind="attrs" icon>
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
        <bic-tree-dialog ref="bictreedialog" @term-selected="handleInput($event)"></bic-tree-dialog>
      </v-row>
      <v-row>
        <v-divider v-if="dividerbottom" class="mt-2 mb-6"></v-divider>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'
import { vocabulary } from '../../mixins/vocabulary'
import BicTreeDialog from '../select/BicTreeDialog'

export default {
  name: 'p-i-subject-bic',
  mixins: [fieldproperties, vocabulary],
  components: {
    BicTreeDialog
  },
  methods: {
    handleInput: function (term) {
      if (term) {
        this.path = ''
        let pathArr = []
        let pathLabels = []
        let pathLabelsDeu = []
        let pathLabelsEng = []
        if (term) {
          if (!term.hasOwnProperty('@id')) {
            term = this.getTerm('bic', term)
          }
          this.getBicPath(term, this.vocabularies['bic'].tree, pathArr)
          for (let i = pathArr.length; i--; i === 0) {
            pathLabels.push(pathArr[i]['skos:notation'][0] + '. ' + pathArr[i]['skos:prefLabel'][this.$i18n.locale])
            if(pathArr[i]['skos:prefLabel']['deu']) {
              pathLabelsDeu.push(pathArr[i]['skos:prefLabel']['deu'] + ' (' + pathArr[i]['skos:notation'][0] + ')')
            }
            if(pathArr[i]['skos:prefLabel']['eng']) {
              pathLabelsEng.push(pathArr[i]['skos:prefLabel']['eng'] + ' (' + pathArr[i]['skos:notation'][0] + ')')
            }
          }
          this.path = pathLabels.join(' -- ')
        }
        this.$emit('input', term['@id'])
        let rdfsLabelObj = {}
        if(pathLabelsDeu && pathLabelsDeu.length){
          rdfsLabelObj['deu'] = 'BIC Klassifizierung -- ' + pathLabelsDeu.join(' -- ')
        }
        if(pathLabelsEng && pathLabelsEng.length){
          rdfsLabelObj['eng'] = 'Bic Subject Codes -- ' + pathLabelsEng.join(' -- ')
        }
        this.$emit('resolve', {
          '@id': term['@id'],
          'skos:prefLabel': term['skos:prefLabel'],
          'rdfs:label': rdfsLabelObj,
          'skos:notation': term['skos:notation']
        })
      } else {
        this.$emit('input', null)
      }
    }
  },
  props: {
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    errorMessages: {
      type: Array
    },
    required: {
      type: Boolean
    },
    disabled: {
      type: Boolean,
      default: false
    },
    showIds: {
      type: Boolean,
      default: false
    },
    dividerbottom: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      loading: false,
      path: ''
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      if (!this.vocabularies['bic'].loaded) {
        this.$store.dispatch('vocabulary/loadBic', this.$i18n.locale)
      }
      // emit input to set skos:prefLabel in parent
      if (this.value) {
        this.handleInput(this.value)
      }
    })
  }
}
</script>
