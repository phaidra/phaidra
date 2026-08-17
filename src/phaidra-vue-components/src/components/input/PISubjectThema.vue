<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-row>
        <v-col cols="10">
          <v-autocomplete
            :model-value="getTerm('thema', value)"
            :required="required"
            @update:model-value="handleInput($event)"
            :rules="required ? [ v => !!v || $t('Required')] : []"
            :items="vocabularies['thema'].terms"
            item-value="@id"
            :item-title="themaItemTitle"
            :loading="loading"
            :custom-filter="vocabAutocompleteFilter"
            hide-no-data
            :label="$t(label)"
            :variant="fieldVariant"
            return-object
            clearable
            :disabled="disabled"
            :hint="path"
            persistent-hint
            :error-messages="errorMessages"
          >
            <template #item="{ props, internalItem }">
              <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
                <template #title>
                  <span v-html="`${getLocalizedTermLabel('thema', internalItem.raw['@id']) + ' - ' + internalItem.raw['skos:notation'][0]}`" />
                </template>
                <template v-if="showIds" #subtitle>
                  <span v-html="internalItem.raw['@id']" />
                </template>
              </v-list-item>
            </template>
            <template #selection="{ internalItem }">
              <span v-html="`${getLocalizedTermLabel('thema', (internalItem.raw || internalItem)['@id']) + ' - ' + (internalItem.raw || internalItem)['skos:notation'][0]}`" />
            </template>
            <template #append>
              <v-icon @click="$refs.thematreedialog.open()">mdi-file-tree</v-icon>
            </template>
          </v-autocomplete>
        </v-col>
        <v-col cols="1" v-if="actions.length">
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
        <thema-tree-dialog ref="thematreedialog" @term-selected="handleInput($event)"></thema-tree-dialog>
      </v-row>
      <v-row v-if="dividerbottom">
        <v-divider class="mt-2 mb-6"></v-divider>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'
import { vocabulary } from '../../mixins/vocabulary'
import ThemaTreeDialog from '../select/ThemaTreeDialog'

export default {
  name: 'p-i-subject-thema',
  mixins: [fieldproperties, vocabulary],
  components: {
    ThemaTreeDialog
  },
  emits: ['input', 'resolve', 'configure', 'add', 'remove', 'add-clear', 'up', 'down'],
  methods: {
    themaItemTitle (item) {
      const raw = item?.raw !== undefined ? item.raw : item
      if (!raw || !raw['skos:prefLabel']) return ''
      const pl = raw['skos:prefLabel']
      const label = pl[this.$i18n.locale] || pl.eng || pl.deu || ''
      const notation = raw['skos:notation']?.[0]
      return notation != null ? `${label} - ${notation}` : label
    },
    handleInput: function (term) {
      if (term) {
        this.path = ''
        let pathArr = []
        let pathLabels = []
        let pathLabelsDeu = []
        let pathLabelsEng = []
        if (term) {
          if (!term.hasOwnProperty('@id')) {
            term = this.getTerm('thema', term)
          }
          this.getThemaPath(term, this.vocabularies['thema'].tree, pathArr)
          for (let i = pathArr.length; i--; i === 0) {
            pathLabels.push(pathArr[i]['skos:notation'][0] + '. ' + (pathArr[i]['skos:prefLabel'][this.$i18n.locale] || pathArr[i]['skos:prefLabel']['eng']))
            pathLabelsDeu.push(pathArr[i]['skos:prefLabel']['deu'] + ' (' + pathArr[i]['skos:notation'][0] + ')')
            pathLabelsEng.push(pathArr[i]['skos:prefLabel']['eng'] + ' (' + pathArr[i]['skos:notation'][0] + ')')
          }
          this.path = pathLabels.join(' -- ')
        }
        this.$emit('input', term['@id'])
        this.$emit('resolve', { '@id': term['@id'], 'skos:prefLabel': term['skos:prefLabel'], 'rdfs:label': { 'deu': 'Thema Klassifizierung -- ' + pathLabelsDeu.join(' -- '), 'eng': 'Thema Subject Codes -- ' + pathLabelsEng.join(' -- ') }, 'skos:notation': term['skos:notation'] })
      } else {
        this.path = ''
        this.$emit('input', null)
        this.$emit('resolve', null)
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
      if (!this.vocabularies['thema'].loaded) {
        this.$store.dispatch('vocabulary/loadThema', this.$i18n.locale)
      }
      // emit input to set skos:prefLabel in parent
      if (this.value) {
        this.handleInput(this.value)
      }
    })
  }
}
</script>
