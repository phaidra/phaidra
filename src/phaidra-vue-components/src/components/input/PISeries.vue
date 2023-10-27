<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8">
        <v-card-title class="title font-weight-light grey white--text">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-btn v-if="multiplicable" icon dark @click="$emit('add', $event)">
            <v-icon>mdi-content-duplicate</v-icon>
          </v-btn>
          <v-btn v-if="multiplicableCleared" icon dark @click="$emit('add-clear', $event)">
            <v-icon>mdi-plus</v-icon>
          </v-btn>
          <v-btn v-if="removable" icon dark @click="$emit('remove', $event)">
            <v-icon>mdi-minus</v-icon>
          </v-btn>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row v-if="journalSuggest" no-gutters>
            <v-combobox
              v-model="journalSearchModel"
              :items="journalSearchItems"
              :loading="journalSearchLoading"
              :search-input.sync="journalSearchQuery"
              :error-messages="journalSearchErrors"
              v-on:input="$emit('input-select-journal', $event)"
              cache-items
              hide-no-data
              hide-selected
              return-object
              item-text="title"
              item-value="issn"
              :placeholder="$t('please enter exact journal title or ISSN')"
              :filled="inputStyle==='filled'"
              :outlined="inputStyle==='outlined'"
              clearable
              append-icon="mdi-magnify"
            >
              <template slot="item" slot-scope="{ item }">
                <v-list-item-content>
                  <v-list-item-title>{{ item.title }}</v-list-item-title>
                  <v-list-item-subtitle v-if="item.issn">{{ $t('ISSN') + ': ' + item.issn }}</v-list-item-subtitle>
                  <v-list-item-subtitle v-if="item.romeopub">{{ $t('PUBLISHER_VERLAG') + ': ' + item.romeopub }}</v-list-item-subtitle>
                </v-list-item-content>
              </template>
              <template slot="selection" slot-scope="{ item }">
                <v-list-item-content>
                  <v-list-item-title>{{ item.title }}</v-list-item-title>
                </v-list-item-content>
              </template>
            </v-combobox>
          </v-row>
          <v-row >
            <v-col cols="12" :md="multilingual ? 10 : 12">
              <v-text-field
                :value="title"
                :label="$t('Title')"
                v-on:blur="$emit('input-title',$event.target.value)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
                :background-color="titleBackgroundColor ? titleBackgroundColor : undefined"
                :error-messages="titleErrorMessages"
              >
              </v-text-field>
            </v-col>
            <v-col cols="12" md="2" v-if="multilingual">
              <v-autocomplete
                :value="getTerm('lang', titleLanguage)"
                v-on:input="$emit('input-title-language', $event )"
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

          </v-row>

          <v-row >

            <v-col cols="12" :md="(hideIssue && hideIssued)? 12 : 4" v-if="!hideVolume">
              <v-text-field
                :value="volume"
                :label="$t('Volume')"
                v-on:blur="$emit('input-volume',$event.target.value)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>

            <v-col cols="12" :md="(hideVolume && hideIssued)? 12 : 4" v-if="!hideIssue">
              <v-text-field
                :value="issue"
                :label="$t('Issue')"
                v-on:blur="$emit('input-issue',$event.target.value)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>

            <v-col cols="12" :md="(hideVolume && hideIssue)? 12 : 4" v-if="!hideIssued">
              <template v-if="issuedDatePicker">
                <v-text-field
                  :value="issued"
                  v-on:blur="$emit('input-issued',$event.target.value)"
                  :label="$t(issuedDateLabel ? issuedDateLabel : 'Issued')"
                  :rules="[validationrules.date]"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                >
                  <template v-slot:append>
                    <v-fade-transition leave-absolute>
                      <v-menu
                        ref="menu1"
                        v-model="dateMenu"
                        :close-on-content-click="false"
                        transition="scale-transition"
                        offset-y
                        max-width="290px"
                        min-width="290px"
                      >
                        <template v-slot:activator="{ on }">
                          <v-icon v-on="on">mdi-calendar</v-icon>
                        </template>
                        <v-date-picker
                          color="primary"
                          :value="issued"
                          :show-current="false"
                          v-model="pickerModel"
                          :locale="$i18n.locale === 'deu' ? 'de-AT' : 'en-GB' "
                          v-on:input="dateMenu = false; $emit('input-issued', $event)"
                        ></v-date-picker>
                      </v-menu>
                    </v-fade-transition>
                  </template>
                </v-text-field>
              </template>
              <template v-else>
                <v-text-field
                  :value="issued"
                  v-on:blur="$emit('input-issued',$event.target.value)"
                  :label="$t(issuedDateLabel ? issuedDateLabel : 'Issued')"
                  :hint="dateFormatHint"
                  :rules="[validationrules.date]"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                ></v-text-field>
              </template>
            </v-col>

          </v-row>

          <v-row v-if="!hidePages">
            <v-col cols="12" md="6">
              <v-text-field
                :value="pageStart"
                :label="$t(pageStartLabel)"
                v-on:blur="$emit('input-page-start',$event.target.value)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="6">
              <v-text-field
                :value="pageEnd"
                :label="$t(pageEndLabel)"
                v-on:blur="$emit('input-page-end',$event.target.value)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>
          </v-row>

          <v-row >

            <v-col cols="12" v-if="!hideIssn">
              <v-text-field
                :value="issn"
                :label="$t('ISSN')"
                v-on:blur="$emit('input-issn',$event.target.value)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col :cols="6" v-if="showIdentifierType && !hideIdentifier">
              <v-autocomplete
                v-on:input="$emit('input-identifier-type', $event)"
                :label="$t('Type of identifier')"
                :items="vocabularies[identifierVocabulary].terms"
                :item-value="'@id'"
                :value="getTerm(identifierVocabulary, identifierType)"
                :filter="autocompleteFilter"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
                return-object
                clearable
              >
                <template slot="item" slot-scope="{ item }">
                  <v-list-item-content two-line>
                    <v-list-item-title  v-html="`${getLocalizedTermLabel(identifierVocabulary, item['@id'])}`"></v-list-item-title>
                  </v-list-item-content>
                </template>
                <template slot="selection" slot-scope="{ item }">
                  <v-list-item-content>
                    <v-list-item-title v-html="`${getLocalizedTermLabel(identifierVocabulary, item['@id'])}`"></v-list-item-title>
                  </v-list-item-content>
                </template>
              </v-autocomplete>
            </v-col>

            <v-col :cols="showIdentifierType ? 6 : 12" v-if="!hideIdentifier">
              <v-text-field
                :value="identifier"
                :label="$t('Identifier')"
                v-on:blur="$emit('input-identifier',$event.target.value)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>

          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import xmlUtils from '../../utils/xml'
import qs from 'qs'
var iconv = require('iconv-lite')

export default {
  name: 'p-i-series',
  mixins: [vocabulary, fieldproperties, validationrules],
  props: {
    label: {
      type: String
    },
    title: {
      type: String
    },
    titleLanguage: {
      type: String
    },
    hideVolume: {
      type: Boolean
    },
    volume: {
      type: String
    },
    hideIssue: {
      type: Boolean
    },
    issue: {
      type: String
    },
    hideIssued: {
      type: Boolean
    },
    issued: {
      type: String
    },
    issuedDateLabel: {
      type: String
    },
    issuedDatePicker: {
      type: Boolean,
      default: true
    },
    hideIssn: {
      type: Boolean
    },
    issn: {
      type: String
    },
    hideIdentifier: {
      type: Boolean
    },
    identifierType: {
      type: String
    },
    identifier: {
      type: String
    },
    showIdentifierType: {
      type: Boolean,
      default: true
    },
    identifierVocabulary: {
      type: String,
      default: 'objectidentifiertype'
    },
    journalSuggest: {
      type: Boolean,
      default: false
    },
    titleErrorMessages: {
      type: Array
    },
    hidePages: {
      type: Boolean,
      default: true
    },
    pageStartLabel: {
      type: String
    },
    pageEndLabel: {
      type: String
    },
    pageStart: {
      type: String
    },
    pageEnd: {
      type: String
    },
    multilingual: {
      type: Boolean,
      default: false
    },
    titleBackgroundColor: {
      type: String,
      default: undefined
    },
    dateFormatHint: {
      type: String,
      default: 'Format YYYY-MM-DD'
    }
  },
  computed: {
    appconfig: function () {
      return this.$root.$store.state.appconfig
    }
  },
  watch: {
    journalSearchQuery (val) {
      val && this.queryJournalSearchDebounce(val)
    }
  },
  data () {
    return {
      pickerModel: new Date().toISOString().substr(0, 10),
      dateMenu: false,
      journalSearchModel: null,
      journalSearchItems: [],
      journalSearchErrors: [],
      journalSearchData: null,
      journalSearchLoading: false,
      journalSearchQuery: '',
      journalSearchDebounce: 500,
      journalSearchMinLetters: 3,
      journalSearchDebounceTask: null
    }
  },
  methods: {
    queryJournalSearchDebounce (value) {
      this.showList = true
      if (this.journalSearchDebounce) {
        if (this.journalSearchDebounceTask !== undefined) clearTimeout(this.journalSearchDebounceTask)
        this.journalSearchDebounceTask = setTimeout(() => {
          return this.suggestJournals(value)
        }, this.journalSearchDebounce)
      } else {
        return this.suggestJournals(value)
      }
    },
    async suggestJournals (q) {
      if (process.browser) {
        if (q.length < this.journalSearchMinLetters || !this.appconfig.apis.sherparomeo) return

        this.journalSearchLoading = true
        this.journalSearchItems = []

        var params = {
          ak: this.appconfig.apis.sherparomeo.key,
          versions: 'all',
          qtype: 'contains',
          jtitle: q
        }

        var query = qs.stringify(params)

        try {
          let response = await this.$axios.request({
            method: 'GET',
            url: this.appconfig.apis.sherparomeo.url + '?' + query,
            responseType: 'arraybuffer'
          })
          let utfxml = iconv.decode(Buffer.from(response.data), 'ISO-8859-1')
          let dp = new window.DOMParser()
          let obj = xmlUtils.xmlToJson(dp.parseFromString(utfxml, 'text/xml'))
          for (let j of obj.romeoapi[1].journals.journal) {
            this.journalSearchItems.push(
              {
                title: j.jtitle['#text'],
                issn: j.issn['#text'],
                romeopub: j.romeopub['#text'] ? j.romeopub['#text'] : this.$t('Not available')
              }
            )
          }
        } catch (error) {
          console.log(error)
          this.journalSearchErrors.push(error)
        } finally {
          this.journalSearchLoading = false
        }
      }
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
.vertical-center {
 align-items: center;
}
</style>
