<template>
  <v-col>
    <v-row v-for="(ch, i) in children" :key="ch.xmlname+i">
      <template v-if="skip(ch) || isEmpty(ch)"></template>
      <template v-else-if="ch.input_type === 'static'">
        <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
        <v-col cols="12" md="10">{{ ch.ui_value }}</v-col>
      </template>
      <template v-else-if="ch.input_type === 'input_text'">
        <template v-if="nodePath(ch) === 'uwm_general_title'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}<template v-if="getLangAttr(ch)"> ({{getLangAttr(ch)}})</template></v-col>
          <v-col cols="12" md="10" class="wiv">{{ ch.ui_value }}</v-col>
        </template>
        <template v-else-if="nodePath(ch) === 'uwm_lifecycle_upload_date'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ ch.ui_value | datetimeutc }} UTC</v-col>
        </template>
        <template v-else-if="ch.datatype === 'ClassificationSource'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ ch.ui_value }}</v-col>
        </template>
        <template v-else-if="ch.datatype === 'FileSize'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ ch.ui_value | bytes }}</v-col>
        </template>
        <template v-else-if="ch.datatype === 'Taxon'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ ch.ui_value }}</v-col>
        </template>
        <template v-else-if="ch.datatype === 'DateTime'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ dateModifierFn(ch.ui_value, this) }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'description'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}<template v-if="getLangAttr(ch)"> ({{getLangAttr(ch)}})</template></v-col>
          <v-col cols="12" md="10" class="valuefield" ref="autolink">{{ ch.ui_value }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'alephurl'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}<template v-if="getLangAttr(ch)"> ({{getLangAttr(ch)}})</template></v-col>
          <v-col cols="12" md="10" class="valuefield" ref="autolink">{{ ch.ui_value }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'keyword' && i === firstKeywordIndex">
          <template v-for="(keywords, language) in langKeywords">
            <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }} <template v-if="language"> ({{language}})</template></v-col>
            <v-col cols="12" md="10" class="valuefield" ref="autolink">
                <v-chip :key="'kw' + language + i" v-for="(kw, i) in keywords" class="mr-2 mb-2 pointer-disabled">{{kw}}</v-chip>
            </v-col>
          </template>
        </template>
        <template v-else-if="ch.xmlname !== 'keyword'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}<template v-if="getLangAttr(ch)"> ({{getLangAttr(ch)}})</template></v-col>
          <v-col cols="12" md="10" class="valuefield">{{ ch.ui_value }}</v-col>
        </template>
      </template>
      <template v-else-if="ch.input_type === 'select'">
        <template v-if="ch.xmlname === 'language'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ getLangLabel(ch.ui_value) }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'license'">
          <template v-if="(cmodel !== 'Collection') && (cmodel !== 'Resource')">
            <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
            <v-col cols="12" md="10" class="wiv">
              <span v-if="dc_rights && dc_rights.length > 0">
                <a :href="dc_rights[1]" target="_blank">{{ ch.labels[alpha2locale] }}</a>
              </span>
              <span v-else>
                {{ ch.labels[alpha2locale] }}
              </span>
            </v-col>
          </template>
        </template>
        <template v-else>
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10" v-if="ch.labels">{{ ch.labels[alpha2locale] }}</v-col>
        </template>
      </template>
      <template v-else-if="ch.input_type === 'node'">
        <template v-if="ch.xmlname === 'identifiers'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ getChildLabel(ch, 'resource') || $t("Other identifier") }}</v-col>
          <v-col cols="12" md="10">{{ getChildValue(ch, 'identifier') }}</v-col>
        </template>
        <template v-else-if="nodePath(ch) === 'uwm_lifecycle_contribute'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ getChildLabel(ch, 'role') }}</v-col>
          <v-col cols="12" md="10">
            <v-row no-gutters v-for="(entity, i) in getEntities(ch)" :key="'en'+i">
              <v-col :cols="getChildValue(entity, 'date') ? 10 : 12">
                <span v-if="getChildValue(entity, 'orcid')">
                  <a :href="'https://orcid.org/' + getChildValue(entity, 'orcid').replace('https://orcid.org/','')" target="_blank">
                    <icon width="16px" height="16px" class="mr-1 mb-1" name="orcid"></icon>
                    <span v-if="getChildValue(entity, 'firstname')" class="wiv">{{ getChildValue(entity, 'firstname') }}</span>
                    <span v-if="getChildValue(entity, 'lastname')" class="wiv">{{ getChildValue(entity, 'lastname') }}</span>
                  </a>
                </span>
                <span v-else>
                  <span v-if="getChildValue(entity, 'firstname')" class="wiv">{{ getChildValue(entity, 'firstname') }}</span>
                  <span v-if="getChildValue(entity, 'lastname')" class="wiv">{{ getChildValue(entity, 'lastname') }}</span>
                </span>
                <span v-if="getChildValue(entity, 'institution') && (getChildValue(entity, 'firstname') || getChildValue(entity, 'lastname'))" class="secondary--text">&nbsp;({{ getChildValue(entity, 'institution') }})</span>
                <span v-else-if="getChildValue(entity, 'institution')">{{ getChildValue(entity, 'institution') }}</span>
                <span v-if="getChildValue(entity, 'viaf')"> VIAF: <a :href="'https://viaf.org/viaf/' + getChildValue(entity, 'viaf')" target="_blank">{{ getChildValue(entity, 'viaf') }}</a></span>
                <span v-if="getChildValue(entity, 'wdq')"> Wikidata: <a :href="'https://www.wikidata.org/wiki/' + getChildValue(entity, 'wdq')" target="_blank">{{ getChildValue(entity, 'wdq') }}</a></span>
                <span v-if="getChildValue(entity, 'gnd')"> GND: <a :href="'https://d-nb.info/gnd/' + getChildValue(entity, 'gnd')" target="_blank">{{ getChildValue(entity, 'gnd') }}</a></span>
                <span v-if="getChildValue(entity, 'lcnaf')"> LCCN: <a :href="'https://lccn.loc.gov/' + getChildValue(entity, 'lcnaf')" target="_blank">{{ getChildValue(entity, 'lcnaf') }}</a></span>
                <span v-if="getChildValue(entity, 'isni')"> ISNI: <a :href="'http://isni.org/isni/' + getChildValue(entity, 'isni')" target="_blank">{{ getChildValue(entity, 'isni') }}</a></span>
              </v-col>
            </v-row>
          </v-col>
          <v-col v-if="getChildValue(ch, 'date')" cols="12" md="10" offset-md="2">
            {{ getChildValue(ch, 'date') | date }}
          </v-col>
        </template>
        <template v-else-if="nodePath(ch) === 'uwm_provenience_contribute'">
          <v-card outlined class="mt-4" :width="'100%'">
            <v-card-text>
              <div class="overline mb-4">{{ $t(nodePath(ch)) }}</div>
              <v-row v-if="getChildLabel(ch, 'resource')">
                <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('uwm_provenience_contribute_resource') }}</v-col>
                <v-col cols="12" md="10">{{ getChildLabel(ch, 'resource') }}</v-col>
              </v-row>
              <v-row v-for="(child, i) in getMultipleChild(ch, 'comment')" :key="'comment'+i">
                <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('uwm_provenience_contribute_comment') }}<template v-if="getLangAttr(child)"> ({{getLangAttr(child)}})</template></v-col>
                <v-col cols="12" md="10"><span v-html="link(child.ui_value)"></span></v-col>
              </v-row>
              <v-row v-if="getChildValue(ch, 'role')">
                <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ getChildLabel(ch, 'role') }}</v-col>
                <v-col cols="12" md="10">
                  <v-row no-gutters v-for="(entity, i) in getEntities(ch)" :key="'en'+i">
                    <v-col>
                      <span v-if="getChildValue(entity, 'firstname')" class="wiv">{{ getChildValue(entity, 'firstname') }}</span>
                      <span v-if="getChildValue(entity, 'lastname')" class="wiv">{{ getChildValue(entity, 'lastname') }}</span>
                      <span v-if="getChildValue(entity, 'institution') && (getChildValue(entity, 'firstname') || getChildValue(entity, 'lastname'))" class="secondary--text">&nbsp;({{ getChildValue(entity, 'institution') }})</span>
                      <span v-else-if="getChildValue(entity, 'institution')">{{ getChildValue(entity, 'institution') }}</span>                      
                    </v-col>
                  </v-row>
                </v-col>
              </v-row>
              <v-row v-if="getChildValue(ch, 'date_from')">
                <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('uwm_provenience_contribute_date_from') }}</v-col>
                <v-col cols="12" md="10">{{ getChildValue(ch, 'date_from') | date }}</v-col>
              </v-row>
              <v-row v-if="getChildValue(ch, 'date_to')">
                <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('uwm_provenience_contribute_date_to') }}</v-col>
                <v-col cols="12" md="10">{{ getChildValue(ch, 'date_to') | date }}</v-col>
              </v-row>
              <v-row v-for="(child, i) in getMultipleChild(ch, 'chronological')" :key="'chron'+i">
                <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('uwm_provenience_contribute_chronological') }}<template v-if="getLangAttr(child)"> ({{getLangAttr(child)}})</template></v-col>
                <v-col cols="12" md="10">{{ child.ui_value }}</v-col>
              </v-row>
              <v-row v-for="(child, i) in getMultipleChild(ch, 'location')" :key="'loc'+i">
                <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t('uwm_provenience_contribute_location') }}<template v-if="getLangAttr(child)"> ({{getLangAttr(child)}})</template></v-col>
                <v-col cols="12" md="10">{{ child.ui_value }}</v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </template>
        <template v-else-if="ch.xmlname === 'taxonpath'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ getChildLabel(ch, 'source') }}</v-col>
          <v-col cols="12" md="10">{{ getLastChildLabel(ch, 'taxon') }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'orgassignment'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ getOrgAssignment(ch) }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'curriculum'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">{{ getStudy(ch) }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'reference_number'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ getChildLabel(ch, 'reference') }}</v-col>
          <v-col cols="12" md="10">{{ getChildValue(ch, 'number') }}</v-col>
        </template>
        <template v-else-if="ch.xmlname === 'dimensions'">
          <v-col cols="12" md="2" class="pdlabel secondary--text font-weight-bold text-md-right">{{ $t(nodePath(ch)) }}</v-col>
          <v-col cols="12" md="10">
            <template v-for="(d, i) in ch.children">
              <span v-if="d.xmlname === 'resource'" :key="i+'dima'"><span class="secondary--text font-weight-bold">{{ $t(nodePath(ch)+'_resource') }}</span>: {{ getLabel(d) }}</span>
              <span v-else-if="d.xmlname === 'dimension_unit'" :key="i+'dimb'"><span class="secondary--text font-weight-bold ml-4">{{ $t(nodePath(ch)+'_dimension_unit') }}</span>: {{ getLabel(d) }}</span>
              <span v-else :key="i+'dimc'"><span class="secondary--text font-weight-bold ml-4">{{ $t(nodePath(ch) + '_' + d.xmlname) }}</span>: {{ d.ui_value }}</span>
            </template>
          </v-col>
        </template>
        <template v-else-if="hideNodeBorder(nodePath(ch))">
          <p-d-uwm-rec v-if="ch.children" :children="ch.children" :cmodel="cmodel" :dc_rights="dc_rights" :path="nodePath(ch)"></p-d-uwm-rec>
        </template>
        <v-card v-else outlined class="mt-4" :width="'100%'">
          <v-card-text>
            <div class="overline mb-4">{{ $t(nodePath(ch)) }}</div>
            <p-d-uwm-rec v-if="ch.children" :children="ch.children" :cmodel="cmodel" :dc_rights="dc_rights" :path="nodePath(ch)"></p-d-uwm-rec>
          </v-card-text>
        </v-card>
      </template>
      <v-alert v-else dense type="error" :value="true">Unknown field type {{ch.xmlname}} {{ch.input_type}}</v-alert>
    </v-row>
  </v-col>
</template>

<script>
import Autolinker from 'autolinker'
import '@/compiled-icons/orcid'
import uwmlangs from '../../utils/uwmlangs'
import lang3to2map from '../../utils/lang3to2map'
import { validationrules } from '../../mixins/validationrules'
import PDateModifier from '../../utils/PDateModifier'

export default {
  name: 'p-d-uwm-rec',
  mixins: [ validationrules ],
  props: {
    children: {
      type: Array
    },
    path: {
      type: String,
      default: 'uwm'
    },
    cmodel: {
      type: String
    },
    dc_rights: {
      type: Array
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
          arr.push({
            text: term['skos:prefLabel'][this.$i18n.locale],
            value: lang3to2map[term['@id']]
          })
        }
      }
      return arr
    },
    langKeywords: function () {
      let hash = {}
      this.children.forEach(ch => {
        if (ch && ch.xmlname === 'keyword') {
          let lang = null
          if(ch.attributes && ch.attributes.length) {
            lang = ch.attributes[0].ui_value
            if (!hash[lang]) {
              hash[lang] = []
            }
            hash[lang].push(ch.ui_value)
          }
        }
      });
      return hash
    },
    firstKeywordIndex() {
      return this.children.findIndex(ch => ch.xmlname === 'keyword');
    },
  },
  data () {
    return {
      loading: false,
      orgLoading: false,
      splLoading: false,
      clsLoading: false,
      studyNames: {}
    }
  },
  methods: {
    dateModifierFn: function (v) {
      return PDateModifier.dateModifierFn(v, this)
    },
    link: function (v) {
      if (typeof v === 'string') {
        return Autolinker.link(v, {
          stripPrefix: false,
          stripTrailingSlash: false
        })
      } else {
        return v
      }
    },
    hideNodeBorder: function (nodePath) {
      switch (nodePath) {
        case 'uwm_general':
        case 'uwm_lifecycle':
        case 'uwm_technical':
        case 'uwm_educational':
        case 'uwm_classification':
        case 'uwm_rights':
        case 'uwm_organization':
        case 'uwm_provenience':
        case 'uwm_histkult':
        case 'uwm_digitalbook':
          return true
        default:
          return false
      }
    },
    getLangLabel: function (code) {
      if (uwmlangs[code]) {
        if (uwmlangs[code][this.alpha2locale]) {
          return uwmlangs[code][this.alpha2locale]
        }
      }
      return code
    },
    getOrgAssignment: function (node) {
      let ass = ''
      let faculty = this.getChildLabel(node, 'faculty')
      let department = this.getChildLabel(node, 'department')
      if (faculty) {
        ass += faculty
      }
      if (department) {
        ass += faculty ? ' > ' + department : department
      }
      return ass
    },
    getEntities: function (node) {
      let entities = []
      for (let ch of node.children) {
        if (ch.xmlname === 'entity') {
          if (ch.attributes) {
            for (let a of ch.attributes) {
              if (a.xmlname === 'data_order') {
                ch.data_order = a.ui_value
              }
            }
          }
          entities.push(ch)
        }
      }
      entities.sort(function (a, b) {
        return a.data_order - b.data_order
      })
      return entities
    },
    getStudy: function (node) {
      let study = ''
      study += this.getChildLabel(node, 'spl')
      study += this.getKennzahlChain(node)
      return study
    },
    getKennzahlChain: function (node) {
      let kennzahls = []
      for (let ch of node.children) {
        if (ch.xmlname === 'kennzahl') {
          if (ch.attributes) {
            for (let a of ch.attributes) {
              if (a.xmlname === 'data_order') {
                ch.data_order = a.ui_value
              }
            }
          }
          kennzahls.push(ch)
        }
      }
      kennzahls.sort(function (a, b) {
        return a.data_order - b.data_order
      })
      let kennzahlchain = []
      for (let k of kennzahls) {
        kennzahlchain.push(k.ui_value)
      }
      if (kennzahlchain.length > 0) {
        return ' > ' + kennzahlchain.join(' > ')
      }
      return ''
    },
    getChildLabel: function (id, xmlname) {
      if (id.children) {
        for (let ch of id.children) {
          if (ch.xmlname === xmlname) {
            if (ch.labels) {
              return ch.labels[this.alpha2locale]
            }
          }
        }
      }
    },
    getLabel: function (node) {
      if (node.labels) {
        return node.labels[this.alpha2locale]
      }
    },
    getLastChildLabel: function (id, xmlname) {
      let lastLabel = null
      if (id.children) {
        for (let ch of id.children) {
          if (ch.xmlname === xmlname) {
            if (ch.labels) {
              lastLabel = ch.labels[this.alpha2locale]
            }
          }
        }
      }
      return lastLabel
    },
    getChildValue: function (id, xmlname) {
      if (id.children) {
        for (let ch of id.children) {
          if (ch.xmlname === xmlname) {
            return ch.ui_value
          }
        }
      }
    },
    getMultipleChild: function (id, xmlname) {
      if (id.children) {
        let values = []
        for (let ch of id.children) {
          if (ch.xmlname === xmlname) {
            values.push(ch)
          }
        }
        return values
      }
    },
    getChild: function (id, xmlname) {
      if (id.children) {
        for (let ch of id.children) {
          if (ch.xmlname === xmlname) {
            return ch
          }
        }
      }
    },
    getLangAttr: function (ch) {
      if (ch) {
        if (ch.attributes) {
          if (ch.attributes.length > 0) {
            for (let a of ch.attributes) {
              if (a.xmlname === 'lang') {
                return a.ui_value
              }
            }
          }
        }
      }
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
              if (!isEmpty) {
                break;
              }
            }
          }
        }
      }
      return isEmpty
    },
    skip: function (node) {
      if (node.hidden) {
        return true
      } else {
        switch (node.xmlns) {
          case 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0':
            switch (node.xmlname) {
              case 'identifier':
              case 'version':
              case 'status':
              case 'requirement':
              case 'cost':
              case 'copyright':
              case 'purpose':
              case 'location':
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
          case 'http://phaidra.univie.ac.at/XML/metadata/extended/V1.0':
            switch (node.xmlname) {
              case 'irdata':
              case 'peer_reviewed':
              case 'metadataqualitycheck':
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
  mounted: function () {
    this.$nextTick(function () {
      if (this.$refs && this.$refs.autolink && this.$refs.autolink.length) {
        this.$refs.autolink[0].innerHTML = Autolinker.link(this.$refs.autolink[0].innerHTML, {
          stripPrefix: false,
          stripTrailingSlash: false
        })
      }
    })
  },
  updated: function () {
    this.$nextTick(function () {
      if (this.$refs && this.$refs.autolink && this.$refs.autolink.length) {
        this.$refs.autolink[0].innerHTML = Autolinker.link(this.$refs.autolink[0].innerHTML, {
          stripPrefix: false,
          stripTrailingSlash: false
        })
      }
    })
  }
}
</script>

<style scoped>
.valuefield {
  white-space: pre-wrap;
}

.wiv {
  font-weight: 400;
}
</style>
