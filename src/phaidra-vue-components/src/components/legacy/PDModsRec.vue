<template>
  <v-col>
    <v-row v-for="(ch, i) in orderedChildren" :key="ch.xmlname+i">
      <template v-if="isEmpty(ch)"></template>
      <template v-else-if="ch.xmlname === 'name'">
        <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ getNameRole(ch) }}</v-col>
        <v-col cols="12" md="10" class="wiv">{{ getNameName(ch) }}</v-col>
      </template>
      <template v-else-if="ch.xmlname === 'originInfo'">
        <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('PUBLISHER_VERLAG') }}</v-col>
        <v-col cols="12" md="10">{{ getOriginInfoPublisher(ch) }}<span v-if="getOriginInfoPublisher(ch) && (getOriginInfoPlace(ch) || getOriginInfoDate(ch))">,&nbsp;</span>{{ getOriginInfoPlace(ch) }}<span v-if="(getOriginInfoPublisher(ch) || getOriginInfoPlace(ch)) && getOriginInfoPlace(ch)">,&nbsp;</span>{{ getOriginInfoDate(ch) }}</v-col>
      </template>
      <template v-else-if="ch.input_type === 'input_text'">
        <template v-if="ch.xmlname === 'languageTerm'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(getLabel(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ getLanguageLabel(ch) }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'title'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(getLabel(ch)) }}</v-col>
          <v-col cols="12" md="10" class="wiv">{{ ch.ui_value }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'accessCondition'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(getLabel(ch)) }}</v-col>
          <v-col v-if="ch.ui_value.startsWith('http')" cols="12" md="10" class="wiv"><a :href="ch.ui_value" target="_blank">{{ getLocalizedTermLabel('alllicenses', ch.ui_value) }}</a></v-col>
          <v-col v-else cols="12" md="10" class="wiv">{{ ch.ui_value }}</v-col>
        </template>
        <template v-else>
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(getLabel(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ ch.ui_value }}</v-col>
        </template>
      </template>
      <template v-else-if="ch.input_type === 'select'">
        <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(getLabel(ch)) }}</v-col>
        <v-col cols="12" md="10">{{ ch.ui_value }}</v-col>
      </template>
      <template v-else-if="ch.input_type === 'input_datetime'">
        <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(getLabel(ch)) }}</v-col>
        <v-col cols="12" md="10">{{ ch.ui_value }}</v-col>
      </template>
      <template v-else-if="ch.input_type === 'node'">
        <template v-if="(ch.xmlname === 'recordInfo') || (ch.xmlname === 'relatedItem')">
          <v-card outlined class="ma-3" :width="'100%'">
            <v-card-text>
              <div class="overline mb-4">{{ $t(getNodeLabel(ch)) }}</div>
              <v-container class="py-0">
                <p-d-mods-rec v-if="ch.children" :children="ch.children" :path="nodePath(ch)"></p-d-mods-rec>
              </v-container>
            </v-card-text>
          </v-card>
        </template>
        <template v-else>
          <v-container class="py-0">
            <p-d-mods-rec v-if="ch.children" :children="ch.children" :path="nodePath(ch)"></p-d-mods-rec>
          </v-container>
        </template>
      </template>
      <v-alert v-else dense type="error" :value="true">Unknown field type {{ch.xmlname}} {{ch.input_type}}</v-alert>
    </v-row>
  </v-col>
</template>

<script>
import { validationrules } from '../../mixins/validationrules'
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'p-d-mods-rec',
  mixins: [ validationrules, vocabulary ],
  props: {
    children: {
      type: Array
    },
    path: {
      type: String,
      default: 'mods'
    }
  },
  computed: {
    orderedChildren: function () {
      let orderedChildren = []
      if (this.children) {
        let otherNodes = []
        let titleInfos = []
        let names = []
        let licenses = []
        let recordInfos = []
        for (let ch of this.children) {
          switch (ch.xmlname) {
            case 'titleInfo':
              titleInfos.push(ch)
              break
            case 'name':
              names.push(ch)
              break
            case 'license':
              licenses.push(ch)
              break
            case 'recordInfo':
              recordInfos.push(ch)
              break
            default:
              otherNodes.push(ch)
          }
        }
        orderedChildren = titleInfos.concat(names).concat(otherNodes).concat(licenses).concat(recordInfos)
      }
      return orderedChildren
    }
  },
  data () {
    return {
      loading: false
    }
  },
  methods: {
    getLanguageLabel: function (ch) {
      let lab = this.getLocalizedTermLabel('lang', ch.ui_value === 'ger' ? 'deu' : ch.ui_value)
      return lab || ch.ui_value
    },
    getNodeLabel: function (ch) {
      if (ch.attributes) {
        for (let attr of ch.attributes) {
          if ((attr.xmlname === 'displayLabel') && attr.ui_value) {
            return attr.ui_value
          }
        }
        for (let attr of ch.attributes) {
          if ((attr.xmlname === 'type') && attr.ui_value) {
            return attr.ui_value
          }
        }
      }
      return ch.label
    },
    getLabel: function (ch) {
      if (ch.attributes) {
        for (let attr of ch.attributes) {
          if ((attr.xmlname === 'displayLabel') && attr.ui_value) {
            return attr.ui_value
          }
        }
      }
      return ch.label
    },
    getOriginInfoPublisher: function (ch) {
      if (ch.children) {
        for (let chch of ch.children) {
          if (chch.xmlname === 'publisher') {
            return chch.ui_value
          }
        }
      }
    },
    getOriginInfoPlace: function (ch) {
      if (ch.children) {
        for (let chch of ch.children) {
          if (chch.xmlname === 'place') {
            for (let chchch of chch.children) {
              if (chchch.xmlname === 'placeTerm') {
                return chchch.ui_value
              }
            }
          }
        }
      }
    },
    getOriginInfoDate: function (ch) {
      if (ch.children) {
        for (let chch of ch.children) {
          if (chch.xmlname === 'dateIssued') {
            return chch.ui_value
          }
          if (chch.xmlname === 'dateCreated') {
            return chch.ui_value
          }
        }
      }
    },
    getNameRole: function (ch) {
      if (ch.children) {
        for (let chch of ch.children) {
          if (chch.xmlname === 'role') {
            for (let chchch of chch.children) {
              if (chchch.xmlname === 'roleTerm') {
                return this.getLocalizedTermLabel('rolepredicate', 'role:' + chchch.ui_value)
              }
            }
          }
        }
      }
    },
    getNameName: function (ch) {
      let family = ''
      let given = ''
      if (ch.children) {
        for (let chch of ch.children) {
          if (chch.xmlname === 'namePart') {
            if (chch['attributes']) {
              let foundValue = false
              for (let chchattr of chch.attributes) {
                if (chchattr.xmlname === 'type') {
                  if (chchattr.ui_value === 'family') {
                    foundValue = true
                    family = chch.ui_value
                  }
                  if (chchattr.ui_value === 'given') {
                    foundValue = true
                    given = chch.ui_value
                  }
                }
                if (!foundValue) {
                  return chch.ui_value    
                }
              }
            } else {
              return chch.ui_value
            }
          }
        }
      }
      return given + ' ' + family
    },
    nodePath: function (ch) {
      return this.path ? this.path + '_' + ch.xmlname : ch.xmlname
    },
    isEmpty: function (node) {
      let isEmpty = true
      if (node.ui_value) {
        return false
      }
      if (node.hasOwnProperty('children')) {
        if (Array.isArray(node.children)) {
          for (let ch of node.children) {
            if (ch.ui_value) {
              isEmpty = false
              break
            } else {
              isEmpty = this.isEmpty(ch)
            }
          }
        }
      }
      return isEmpty
    }
  },
  mounted: async function () {
    await this.$store.dispatch('vocabulary/loadLanguages', this.$i18n.locale)
  }
}
</script>

<style scoped>
.wiv {
  font-weight: 400;
}
</style>
