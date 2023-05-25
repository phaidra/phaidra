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
                outlined
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
            :items="ch.vocabularies[0].terms"
            :item-value="'uri'"
            :label="ch.labels[alpha2locale]"
            :error-messages="ch.errorMessages"
            @change="selectHandler(ch, $event)"
            outlined
          >
            <template v-slot:item="{ item, index }">
              <span>{{ item.labels[alpha2locale] }}</span>
            </template>
            <template v-slot:selection="{ item, index }">
              <span>{{ item.labels[alpha2locale] }}</span>
            </template>
          </v-select>
        </v-col>
        <v-col v-else-if="(ch.datatype === 'Taxon') && (ch.vocabularies)" cols="12">
          <v-select
            :loading="clsLoading"
            :disabled="disabled"
            v-model="ch.ui_value"
            :items="ch.vocabularies[0].terms"
            :item-value="'uri'"
            :label="ch.labels[alpha2locale]"
            :error-messages="ch.errorMessages"
            @change="selectHandler(ch, $event)"
            outlined
          >
            <template v-slot:item="{ item, index }">
              <span>{{ item.labels[alpha2locale] }}</span>
            </template>
            <template v-slot:selection="{ item, index }">
              <span>{{ item.labels[alpha2locale] }}</span>
            </template>
          </v-select>
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
                  outlined
                  :readonly="readOnly(ch)"
                ></v-text-field>
              </v-col>
            </v-row>
          </v-col>
          <v-col v-if="ch.cardinality !== 1" cols="2">
            <v-btn icon @click="$emit('add-field', ch)">
              <v-icon>mdi-plus</v-icon>
            </v-btn>
            <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
              <v-icon>mdi-minus</v-icon>
            </v-btn>
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
                outlined
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="2">
              <v-select
                v-model="ch.value_lang"
                :disabled="disabled"
                :items="languages"
                :label="$t('Language')"
                :error-messages="ch.langErrorMessages"
                outlined
              ></v-select>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-btn icon @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
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
                :error-messages="ch.errorMessages"
                outlined
              ></v-textarea>
            </v-col>
            <v-col cols="12" md="2">
              <v-select
                v-model="ch.value_lang"
                :disabled="disabled"
                :items="languages"
                :error-messages="ch.langErrorMessages"
                :label="$t('Language')"
                outlined
              ></v-select>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-btn icon @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
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
                :items="ch.vocabularies[0].terms"
                :item-value="'uri'"
                :label="ch.labels[alpha2locale]"
                :error-messages="ch.errorMessages"
                @change="selectHandler(ch, $event)"
                outlined
              >
                <template v-slot:item="{ item, index }">
                  <span>{{ item.labels[alpha2locale] }}</span>
                </template>
                <template v-slot:selection="{ item, index }">
                  <span>{{ item.labels[alpha2locale] }}</span>
                </template>
              </v-select>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="(ch.cardinality !== 1) || (ch.xmlname === 'faculty') || (ch.xmlname === 'spl')" cols="2">
          <v-row>
            <v-col>
              <v-btn icon @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
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
                  :error-messages="ch.errorMessages"
                  :label="ch.labels[alpha2locale]"
                  outlined
                >
                </v-select>
              </v-col>
            </v-row>
         </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-btn icon @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
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
                :hint="'Format YYYY-MM-DD'"
                :rules="[validationrules.date]"
                outlined
              ></v-text-field>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-btn icon @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
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
                :input-style="'outlined'"
              ></p-i-duration>
            </v-col>
          </v-row>
        </v-col>
        <v-col v-if="ch.cardinality !== 1" cols="2">
          <v-row>
            <v-col>
              <v-btn icon @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
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
              <v-btn icon @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
            </v-col>
          </v-row>
        </v-col>
      </template>
      <template v-else-if="ch.input_type === 'node'">
        <v-card class="ma-3" :width="'100%'">
          <v-card-title class="font-weight-light grey white--text">
            <span>{{ ch.labels[alpha2locale] }}</span>
            <v-spacer></v-spacer>
            <template v-if="ch.cardinality !== 1">
              <v-btn icon dark @click="$emit('add-field', ch)">
                <v-icon>mdi-plus</v-icon>
              </v-btn>
              <v-btn v-if="ch.removable" icon dark @click="$emit('remove-field', ch)">
                <v-icon>mdi-minus</v-icon>
              </v-btn>
            </template>
          </v-card-title>
          <v-divider></v-divider>
          <v-card-text>
            <template v-if="ch.children">
              <p-i-uwm-rec :children="ch.children" :parent="ch" @update-parent="$forceUpdate()" @add-field="$emit('add-field', $event)" @remove-field="$emit('remove-field', $event)"></p-i-uwm-rec>
            </template>
          </v-card-text>
          <v-divider v-if="ch.xmlname === 'curriculum'"></v-divider>
          <v-card-actions v-if="ch.xmlname === 'curriculum'">
            <span>{{ studyName(ch) }}</span>
          </v-card-actions>
        </v-card>
      </template>
      <v-alert v-else dense type="error" :value="true">Unknown field type {{ch.xmlname}} {{ch.input_type}}</v-alert>
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
      for (let term of this.$store.state.vocabulary.vocabularies['lang'].terms) {
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
    _getTermChildren: async function (uri) {
      this.clsLoading = true
      try {
        let response = await this.$http.request({
          method: 'GET',
          url: this.$store.state.instanceconfig.api + '/terms/children',
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
    studyName: function (node) {
      if (node.study_name) {
        if (node.study_name[this.alpha2locale]) {
          return node.study_name[this.alpha2locale]
        } else {
          Object.entries(node.study_name).forEach(([key, value]) => {
            return value
          })
        }
      }
    },
    getStudyNameHashId: function (node) {
      let hashId = ''
      for (let ch of node.children) {
        if (ch.xmlname === 'spl') {
          let spl = ch.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/', '')
          hashId = hashId === '' ? spl : hashId + '_' + spl
        }
        if (ch.xmlname === 'kennzahl') {
          let kennzahl = ch.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_kennzahl/', '')
          hashId = hashId === '' ? kennzahl : hashId + '_' + kennzahl
        }
      }
      return hashId
    },
    getStudyName: async function (node) {
      let spl = ''
      let ids = []
      let hashId = ''
      for (let ch of node.children) {
        if (ch.xmlname === 'spl') {
          spl = ch.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/', '')
          hashId = hashId === '' ? spl : hashId + '_' + spl
        }
        if (ch.xmlname === 'kennzahl') {
          let kennzahl = ch.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_kennzahl/', '')
          ids.push(kennzahl)
          hashId = hashId === '' ? kennzahl : hashId + '_' + kennzahl
        }
      }
      let response = await this.$http.request({
        method: 'GET',
        url: this.$store.state.instanceconfig.api + '/directory/get_study_name',
        params: {
          spl: spl,
          ids: ids
        },
        paramsSerializer: params => {
          return qs.stringify(params, { arrayFormat: 'repeat' })
        }
      })
      node.study_name = response.data.study_name
      this.$emit('update-parent')
    },
    selectHandler: async function (node, event) {
      if (node.xmlname === 'faculty') {
        this.orgLoading = true
        try {
          let response = await this.$http.request({
            method: 'GET',
            url: this.$store.state.instanceconfig.api + '/directory/get_org_units',
            params: {
              parent_id: node.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_faculty/', ''),
              values_namespace: 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_department/'
            }
          })
          for (let ch of this.children) {
            if (ch.xmlname === 'department') {
              ch.ui_value = ''
              ch.vocabularies[0].terms = response.data.terms
            }
          }
        } catch (error) {
          console.error(error)
        } finally {
          this.orgLoading = false
        }
      }
      if (node.xmlname === 'spl') {
        this.splLoading = true
        try {
          let spl = node.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/', '')
          let response = await this.$http.request({
            method: 'GET',
            url: this.$store.state.instanceconfig.api + '/directory/get_study',
            params: {
              spl: spl,
              values_namespace: 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_kennzahl/'
            }
          })
          for (let ch of this.children) {
            // set up first kennzahl
            if (ch.xmlname === 'kennzahl') {
              ch.ui_value = ''
              ch.vocabularies[0].terms = response.data.terms
              break
            }
          }
          // remove all other kennzahls
          this.children.length = 2
          this.getStudyName(this.parent)
        } catch (error) {
          console.error(error)
        } finally {
          this.splLoading = false
        }
      }
      if (node.xmlname === 'kennzahl') {
        let trimLength = 0
        let spl = ''
        let ids = []
        let i = 0
        let nodeClone = {}
        for (let ch of this.children) {
          i++
          if (ch.xmlname === 'spl') {
            spl = ch.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_spl/', '')
          } else {
            ids.push(ch.ui_value.replace('http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_kennzahl/', ''))
            if (ch.ui_value === event) {
              trimLength = i
              nodeClone = JSON.parse(JSON.stringify(ch))
              break
            }
          }
        }
        this.children.length = trimLength
        let response = await this.$http.request({
          method: 'GET',
          url: this.$store.state.instanceconfig.api + '/directory/get_study',
          params: {
            spl: spl,
            ids: ids,
            values_namespace: 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/organization/voc_kennzahl/'
          },
          paramsSerializer: params => {
            return qs.stringify(params, { arrayFormat: 'repeat' })
          }
        })
        if (response.data.terms && response.data.terms.length && response.data.terms.length > 0) {
          nodeClone.ui_value = ''
          nodeClone.data_order = parseInt(nodeClone.data_order) + 1
          nodeClone.vocabularies[0].terms = response.data.terms
          this.children.push(nodeClone)
        }
        this.getStudyName(this.parent)
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
