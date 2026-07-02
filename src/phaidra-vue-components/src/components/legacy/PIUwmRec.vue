<template>
  <v-container fluid>
    <v-row v-for="(ch, i) in children" :key="ch.xmlname+i">
      <template v-if="skip(ch)"></template>
      <template v-else-if="ch.input_type === 'static'">
        <v-col>
          <v-row>
            <v-col>
              <v-text-field
                v-model="ch.ui_value"
                :label="ch.labels[alpha2locale]"
                :readonly="true"
                variant="filled"
                :disabled="disabled"
              ></v-text-field>
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'input_text'">
        <v-col v-if="(ch.datatype === 'ClassificationSource') && (ch.vocabularies)" cols="12">
          <v-select
            :loading="clsLoading"
            :disabled="disabled"
            v-model="ch.ui_value"
            :items="vocabularySelectItems(ch.vocabularies[0].terms)"
            item-title="text"
            item-value="value"
            :label="ch.labels[alpha2locale]"
            :error-messages="ch.errorMessages"
            @update:model-value="selectHandler(ch, $event)"
            variant="filled"
            clearable
          ></v-select>
        </v-col>
        <v-col v-else-if="(ch.datatype === 'Taxon') && (ch.vocabularies)" cols="12">
          <v-select
            :loading="clsLoading"
            :disabled="disabled"
            v-model="ch.ui_value"
            :items="vocabularySelectItems(ch.vocabularies[0].terms)"
            item-title="text"
            item-value="value"
            :label="ch.labels[alpha2locale]"
            :error-messages="ch.errorMessages"
            @update:model-value="selectHandler(ch, $event)"
            variant="filled"
            clearable
          ></v-select>
        </v-col>
        <template v-else>
          <v-col :cols="ch.cardinality !== 1 ? 10 : 12">
            <v-row>
              <v-col>
                <v-text-field
                  v-model="ch.ui_value"
                  :disabled="disabled"
                  :label="ch.labels[alpha2locale]"
                  :error-messages="ch.errorMessages"
                  variant="filled"
                  :readonly="readOnly(ch)"
                ></v-text-field>
              </v-col>
            </v-row>
          </v-col>
          <v-col v-if="ch.cardinality !== 1" cols="2">
            <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
            <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
          </v-col>
        </template>
      </template>
      <template v-else-if="ch.input_type === 'input_text_lang'">
        <v-col :cols="ch.cardinality !== 1 ? 10 : 12">
          <v-row>
            <v-col cols="12" md="10">
              <v-text-field
                v-model="ch.ui_value"
                :disabled="disabled"
                :label="ch.labels[alpha2locale]"
                :error-messages="ch.errorMessages"
                variant="filled"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="2">
              <v-select
                v-model="ch.value_lang"
                :disabled="disabled"
                :items="languages"
                item-title="text"
                item-value="value"
                :label="$t('Language')"
                :error-messages="ch.langErrorMessages"
                variant="filled"
                clearable
              ></v-select>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'input_textarea_lang'">
        <v-col :cols="ch.cardinality !== 1 ? 10 : 12">
          <v-row>
            <v-col cols="12" md="10">
              <v-textarea
                v-model="ch.ui_value"
                :disabled="disabled"
                :label="ch.labels[alpha2locale]"
                variant="filled"
                :error-messages="ch.errorMessages"
              ></v-textarea>
            </v-col>
            <v-col cols="12" md="2">
              <v-select
                v-model="ch.value_lang"
                :disabled="disabled"
                :items="languages"
                item-title="text"
                item-value="value"
                :error-messages="ch.langErrorMessages"
                :label="$t('Language')"
                variant="filled"
                clearable
              ></v-select>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'select'">
        <v-col :cols="((ch.cardinality !== 1) || (ch.xmlname === 'faculty') || (ch.xmlname === 'spl')) ? 10 : 12">
          <v-row>
            <v-col cols="12">
              <v-select
                :loading="(ch.xmlname === 'faculty') ? orgLoading : (ch.xmlname === 'spl') ? splLoading : false"
                v-model="ch.ui_value"
                :disabled="disabled || (ch.disabled === true) || (ch.disabled === '1') || (ch.disabled === 1)"
                :items="vocabularySelectItems(ch.vocabularies[0].terms)"
                item-title="text"
                item-value="value"
                :label="ch.labels[alpha2locale]"
                :error-messages="ch.errorMessages"
                @update:model-value="selectHandler(ch, $event)"
                variant="filled"
                clearable
              ></v-select>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="(ch.cardinality !== 1) || (ch.xmlname === 'spl')" cols="2">
          <v-row>
            <v-col>
              <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'language_select'">
         <v-col :cols="ch.cardinality !== 1 ? 10 : 12">
            <v-row>
              <v-col cols="12">
                <v-select
                  v-model="ch.ui_value"
                  :disabled="disabled"
                  :items="languages"
                  item-title="text"
                  item-value="value"
                  :error-messages="ch.errorMessages"
                  :label="ch.labels[alpha2locale]"
                  variant="filled"
                  clearable
                >
                </v-select>
              </v-col>
            </v-row>
         </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'input_datetime'">
        <v-col :cols="ch.cardinality !== 1 ? 10 : 12">
          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model="ch.ui_value"
                :disabled="disabled"
                :label="ch.labels[alpha2locale]"
                :error-messages="ch.errorMessages"
                :hint="$t('Format YYYY-MM-DD')"
                variant="filled"
                :rules="[validationrules.date]"
              ></v-text-field>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'input_duration'">
        <v-col :cols="ch.cardinality !== 1 ? 10 : 12">
          <v-row>
            <v-col cols="12">
              <p-i-duration
                :value="ch.ui_value"
                :disabled="disabled"
                v-on:input="ch.ui_value=$event"
                :label="ch.labels[alpha2locale]"
                :error-messages="ch.errorMessages"
                :input-style="'filled'"
              ></p-i-duration>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'select_yesno'">
        <v-col :cols="ch.cardinality !== 1 ? 10 : 12">
          <v-row>
            <v-col cols="12">
              <v-checkbox
                v-model="ch.ui_value"
                :disabled="disabled"
                :false-value="'no'"
                :true-value="'yes'"
                :error-messages="ch.errorMessages"
                :label="ch.labels[alpha2locale]"
              ></v-checkbox>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-icon-btn @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="ch.removable" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'node'">
        <v-card class="ma-3" :width="'100%'">
          <v-card-title class="font-weight-light text-white">
            <span>{{ ch.labels[alpha2locale] }}</span>
            <v-spacer></v-spacer>
            <template v-if="ch.cardinality !== 1">
              <v-icon-btn theme="dark" variant="text" color="white" @click="$emit('add-field', ch)" icon="mdi-plus" />
              <v-icon-btn v-if="canRemoveNode(ch, parent)" theme="dark" variant="text" color="white" @click="$emit('remove-field', ch)" icon="mdi-minus" />
            </template>
          </v-card-title>
          <v-divider></v-divider>
          <v-card-text>
            <template v-if="ch.children">
              <p-i-uwm-rec :children="ch.children" :parent="ch" @update-parent="$forceUpdate()" @add-field="$emit('add-field', $event)" @remove-field="$emit('remove-field', $event)"></p-i-uwm-rec>
            </template>
          </v-card-text>
        </v-card>
      </template>
      <v-alert v-else density="compact" type="error" :model-value="true">Unknown field type {{ch.xmlname}} {{ch.input_type}}</v-alert>
    </v-row>
  </v-container>
</template>

<script>
import qs from 'qs'
import PIDuration from '../input/PIDuration'
import lang3to2map from '../../utils/lang3to2map'
import { validationrules } from '../../mixins/validationrules'

export default {
  name: 'p-i-uwm-rec',
  mixins: [ validationrules ],
  components: {
    PIDuration
  },
  props: {
    parent: {
      type: Object
    },
    children: {
      type: Array
    },
    classifications: {
      type: Array
    },
    disabled: {
      type: Boolean
    }
  },
  computed: {
    alpha2locale: function () {
      switch (this.$i18n.locale) {
        case 'eng': return 'en'
        case 'deu': return 'de'
        case 'ita': return 'it'
        default: return 'en'
      }
    },
    languages: function () {
      let arr = []
      const langTerms = this.$store.state.vocabulary.vocabularies['lang']?.terms
      if (!langTerms) {
        return arr
      }
      for (let term of langTerms) {
        if (lang3to2map[term['@id']]) {
           if (term['skos:prefLabel'][this.$i18n.locale]) {
            arr.push({
              text: term['skos:prefLabel'][this.$i18n.locale],
              value: lang3to2map[term['@id']]
            })
          }
        }
      }
      return arr
    }
  },
  data () {
    return {
      loading: false,
      orgLoading: false,
      splLoading: false,
      clsLoading: false
    }
  },
  methods: {
    vocabularySelectItems: function (terms) {
      if (!Array.isArray(terms)) {
        return []
      }
      return terms.map(term => ({
        ...term,
        text: this.termLabel(term, terms),
        value: term.uri
      }))
    },
    termLabel: function (item, terms) {
      let term = item?.raw ?? item
      if (typeof term === 'string' && Array.isArray(terms)) {
        term = terms.find(t => t.uri === term || t.value === term)
      }
      if (!term || !term.labels) {
        if (typeof item === 'string') {
          return item
        }
        if (typeof term === 'string') {
          return term
        }
        return term?.uri || term?.value || ''
      }
      const labels = term.labels
      const raw = labels[this.alpha2locale]
        || labels[this.$i18n.locale]
        || labels.en || labels.eng
        || labels.de || labels.deu
        || labels.it || labels.ita
        || Object.values(labels).find(v => typeof v === 'string')
      if (typeof raw === 'string') {
        return raw
      }
      if (raw && typeof raw === 'object' && raw['@value']) {
        return raw['@value']
      }
      return term.uri || term.value || ''
    },
    entityHasData: function (entity) {
      if (!entity || !entity.children) {
        return false
      }
      for (let ch of entity.children) {
        if (ch.xmlname !== 'type' && ch.ui_value) {
          return true
        }
      }
      return false
    },
    nodeDataOrder: function (node) {
      if (node.attributes) {
        for (let attr of node.attributes) {
          if (attr.xmlname === 'data_order') {
            return parseInt(attr.ui_value, 10) || 0
          }
        }
      }
      return parseInt(node.data_order, 10) || 0
    },
    canRemoveNode: function (ch, parent) {
      if (ch.removable) {
        return true
      }
      if (!parent || !parent.children || ch.cardinality === 1) {
        return false
      }
      let siblings = parent.children.filter(c => c.xmlname === ch.xmlname)
      if (siblings.length <= 1) {
        return false
      }
      if (ch.xmlname === 'entity' && parent.xmlname === 'contribute') {
        if (!this.entityHasData(ch)) {
          return true
        }
        let filled = siblings.filter(c => this.entityHasData(c))
        return filled.length <= 2 && this.nodeDataOrder(ch) > 0
      }
      if (ch.xmlname === 'contribute' && parent.xmlname === 'lifecycle') {
        let role = ch.children && ch.children.find(c => c.xmlname === 'role')
        let hasEntity = ch.children && ch.children.some(c => c.xmlname === 'entity' && this.entityHasData(c))
        return !(role && role.ui_value && hasEntity)
      }
      return false
    },
    _getTermChildren: async function (uri) {
      if(!uri) return;
      this.clsLoading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/terms/children',
          params: {
            uri: uri
          },
          paramsSerializer: params => {
            return qs.stringify(params, { arrayFormat: 'repeat' })
          }
        })
        this.$forceUpdate()
        return response.data.terms
      } catch (error) {
        console.error(error)
      } finally {
        this.clsLoading = false
      }
    },
    loadClassifications: async function (node) {
      let termChildren = await this._getTermChildren('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification')
      node['vocabularies'] = [
        {
          'terms': termChildren
        }
      ]
      this.$forceUpdate()
    },
    loadSiblings: async function (node) {
      let prevNode = null
      for (let ch of this.children) {
        if (ch.ui_value === node.ui_value) {
          break
        } else {
          prevNode = ch
        }
      }
      if (prevNode) {
        let termChildren = await this._getTermChildren(prevNode.ui_value)
        node['vocabularies'] = [
          {
            'terms': termChildren
          }
        ]
        this.$forceUpdate()
      }
    },
    loadNextTermSelect: async function (node) {
      if ((node.datatype === 'ClassificationSource') || (node.datatype === 'Taxon')) {
        let prevNode = null
        let nrPrevNodes = 0
        for (let ch of this.children) {
          if (ch.ui_value === node.ui_value) {
            break
          } else {
            nrPrevNodes++
            prevNode = ch
          }
        }
        if (prevNode) {
          this.children.length = nrPrevNodes + 1
          let termChildren = await this._getTermChildren(node.ui_value)
          if (termChildren && termChildren.length && termChildren.length > 0) {
            this.children.push(
              {
                'labels': {
                  'de': 'Pfad',
                  'en': 'Path',
                  'it': 'Percorso',
                  'sr': 'putanja'
                },
                'datatype': 'Taxon',
                'field_order': 9999,
                'input_type': 'input_text',
                'ordered': 1,
                'data_order': nrPrevNodes, // source (cls node) is also counted, so no +1
                'ui_value': '',
                'value_lang': '',
                'xmlname': 'taxon',
                'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification',
                'vocabularies': [
                  {
                    'terms': termChildren
                  }
                ]
              }
            )
          }
          this.$forceUpdate()
        } else {
          this.children.length = 1
          let termChildren = await this._getTermChildren(node.ui_value)
          if (termChildren && termChildren.length && termChildren.length > 0) {
            this.children.push(
              {
                'labels': {
                  'de': 'Pfad',
                  'en': 'Path',
                  'it': 'Percorso',
                  'sr': 'putanja'
                },
                'datatype': 'Taxon',
                'field_order': 9999,
                'input_type': 'input_text',
                'ordered': 1,
                'data_order': 0,
                'ui_value': '',
                'value_lang': '',
                'xmlname': 'taxon',
                'xmlns': 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification',
                'vocabularies': [
                  {
                    'terms': termChildren
                  }
                ]
              }
            )
          }
          this.$forceUpdate()
        }
      }
    },
    selectHandler: async function (node, event) {
      if (node.xmlname === 'faculty') {
        this.orgLoading = true
        try {
          if (!node.ui_value) {
            for (let ch of this.children) {
              if (ch.xmlname === 'department') {
                ch.ui_value = ''
                ch.vocabularies[0].terms = []
              }
            }
            return
          }
          let response = await this.$axios.request({
            method: 'GET',
            url: '/directory/org_get_units',
            params: {
              parent_id: node.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/', ''),
              values_namespace: 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_department/'
            }
          })
          for (let ch of this.children) {
            if (ch.xmlname === 'department') {
              ch.ui_value = ''
              ch.vocabularies[0].terms = response.data.terms || []
            }
          }
        } catch (error) {
          console.error(error)
        } finally {
          this.orgLoading = false
        }
        return
      }
      this.loadNextTermSelect(node)
    },
    skip: function (node) {
      if (node.hidden) {
        return true
      } else {
        switch (node.xmlns) {
          case 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0':
            switch (node.xmlname) {
              case 'version':
              case 'status':
              case 'requirement':
              case 'cost':
              case 'copyright':
              case 'purpose':
              case 'identifier':
              case 'upload_date':
                return true
              default:
                return false
            }
          case 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/entity':
            switch (node.xmlname) {
              case 'type':
                return true
              default:
                return false
            }
          case 'http://phaidra.univie.ac.at/XML/metadata/provenience/V1.0/entity':
            switch (node.xmlname) {
              case 'type':
                return true
              default:
                return false
            }
          case 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/classification':
            switch (node.xmlname) {
              case 'description':
              case 'keyword':
                return true
              default:
                return false
            }
          default:
            return false
        }
      }
    },
    readOnly: function (node) {
      if (node.disabled) {
        return true
      } else {
        switch (node.xmlns) {
          case 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0':
            switch (node.xmlname) {
              case 'location':
              case 'size':
                return true
              default:
                return false
            }
          default:
            return false
        }
      }
    }
  },
  mounted: async function () {
    console.log('PIUwmRec mounted')
    let lastClsChild
    for (let ch of this.children) {
      if (ch.datatype === 'ClassificationSource') {
        lastClsChild = ch
        await this.loadClassifications(ch)
      }
      if (ch.datatype === 'Taxon') {
        lastClsChild = ch
        await this.loadSiblings(ch)
      }
    }
    if (lastClsChild) {
      await this.loadNextTermSelect(lastClsChild)
    }
  }
}
</script>
