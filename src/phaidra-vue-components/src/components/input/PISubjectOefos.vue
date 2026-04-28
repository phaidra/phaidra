<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-row>
        <v-col cols="10">
          <v-autocomplete
            :model-value="getTerm('oefos', value)"
            :required="required"
            @update:model-value="handleInput($event)"
            :rules="required ? [ v => !!v || $t('Required')] : []"
            :items="vocabularies['oefos'].terms"
            item-value="@id"
            :item-title="(item) => skosTermItemTitleWithNotation(item, 'oefos')"
            :loading="loading"
            :custom-filter="vocabAutocompleteFilter"
            hide-no-data
            :label="$t(label)"
            :variant="fieldVariant"
            return-object
            clearable
            :disabled="disabled"
            :messages="path"
            :error-messages="errorMessages"
          >
            <template #item="{ props, internalItem }">
              <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
                <template #title>
                  <span v-html="`${getLocalizedTermLabel('oefos', internalItem.raw['@id']) + ' - ' + internalItem.raw['skos:notation'][0]}`" />
                </template>
                <template v-if="showIds" #subtitle>
                  <span v-html="internalItem.raw['@id']" />
                </template>
              </v-list-item>
            </template>
            <template #selection="{ internalItem }">
              <span v-html="`${getLocalizedTermLabel('oefos', (internalItem.raw || internalItem)['@id']) + ' - ' + (internalItem.raw || internalItem)['skos:notation'][0]}`" />
            </template>
            <template #append-inner>
              <v-icon @click="$refs.oefostreedialog.open()">mdi-file-tree</v-icon>
            </template>
          </v-autocomplete>
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
        <oefos-tree-dialog ref="oefostreedialog" @term-selected="handleInput($event)"></oefos-tree-dialog>
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
import OefosTreeDialog from '../select/OefosTreeDialog'

export default {
  name: 'p-i-subject-oefos',
  mixins: [fieldproperties, vocabulary],
  components: {
    OefosTreeDialog
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
            term = this.getTerm('oefos', term)
          }
          this.getOefosPath(term, this.vocabularies['oefos'].tree, pathArr)
          for (let i = pathArr.length; i--; i === 0) {
            pathLabels.push(pathArr[i]['skos:notation'][0] + '. ' + (pathArr[i]['skos:prefLabel'][this.$i18n.locale] || pathArr[i]['skos:prefLabel']['eng']))
            pathLabelsDeu.push(pathArr[i]['skos:prefLabel']['deu'] + ' (' + pathArr[i]['skos:notation'][0] + ')')
            pathLabelsEng.push(pathArr[i]['skos:prefLabel']['eng'] + ' (' + pathArr[i]['skos:notation'][0] + ')')
          }
          this.path = pathLabels.join(' -- ')
        }
        this.$emit('input', term['@id'])
        this.$emit('resolve', { '@id': term['@id'], 'skos:prefLabel': term['skos:prefLabel'], 'rdfs:label': { 'deu': 'ÖFOS 2012 -- ' + pathLabelsDeu.join(' -- '), 'eng': 'ÖFOS 2012 -- ' + pathLabelsEng.join(' -- ') }, 'skos:notation': term['skos:notation'] })
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
    this.$nextTick(async function () {
      if (!this.vocabularies['oefos'].loaded) {
        await this.$store.dispatch('vocabulary/loadOefos', this.$i18n.locale)
      }
      // emit input to set skos:prefLabel in parent
      if (this.value) {
        this.handleInput(this.value)
      }
    })
  }
}
</script>
