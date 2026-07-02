<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card variant="outlined" class="mb-8">
        <v-card-title class="title font-weight-light text-white">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-icon-btn v-if="multiplicable" variant="text" color="white" @click="$emit('add', $event)" icon="mdi-content-duplicate" />
          <v-icon-btn v-if="multiplicableCleared" variant="text" color="white" @click="$emit('add-clear', $event)" icon="mdi-plus" />
          <v-icon-btn v-if="removable" variant="text" color="white" @click="$emit('remove', $event)" icon="mdi-minus" />
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row v-if="journalSuggest" no-gutters>
            <v-combobox
              v-model="journalSearchModel"
              :items="journalSearchItems"
              :loading="journalSearchLoading"
              v-model:search="journalSearchQuery"
              :error-messages="journalSearchErrors"
              @update:model-value="$emit('input-select-journal', $event)"
              hide-no-data
              hide-selected
              return-object
              item-title="title"
              item-value="issn"
              :placeholder="$t('please enter exact journal title or ISSN')"
              :variant="fieldVariant"
              clearable
              append-inner-icon="mdi-magnify"
            >
              <template #item="{ props, internalItem }">
                <v-list-item
                  v-bind="props"
                  :lines="(internalItem.raw.issn || internalItem.raw.romeopub) ? 'two' : 'one'"
                >
                  <template #title>{{ internalItem.raw.title }}</template>
                  <template v-if="internalItem.raw.issn || internalItem.raw.romeopub" #subtitle>
                    <template v-if="internalItem.raw.issn">{{ $t('ISSN') + ': ' + internalItem.raw.issn }}</template>
                    <template v-if="internalItem.raw.issn && internalItem.raw.romeopub"> · </template>
                    <template v-if="internalItem.raw.romeopub">{{ $t('PUBLISHER_VERLAG') + ': ' + internalItem.raw.romeopub }}</template>
                  </template>
                </v-list-item>
              </template>
              <template #selection="{ internalItem }">
                {{ (internalItem.raw || internalItem).title }}
              </template>
            </v-combobox>
          </v-row>
          <v-row >
            <v-col cols="12" :md="multilingual ? 10 : 12">
              <v-text-field
                :model-value="title"
                :label="$t('Title')"
                @update:model-value="$emit('input-title', $event)"
                :variant="fieldVariant"
                :bg-color="titleBackgroundColor ? titleBackgroundColor : undefined"
                :error-messages="titleErrorMessages"
              >
              </v-text-field>
            </v-col>
            <v-col cols="12" md="2" v-if="multilingual">
              <v-btn variant="text" @click="$refs.langdialog.open()">
                <span>
                  ({{ titleLanguage ? titleLanguage : '--' }})
                </span>
              </v-btn>
              <select-language ref="langdialog" @language-selected="$emit('input-title-language', $event)"></select-language>
            </v-col>

          </v-row>

          <v-row >

            <v-col cols="12" :md="multilingual ? ((hideIssue && hideIssued)? 10 : 4) : ((hideIssue && hideIssued)? 12 : 4)" v-if="!hideVolume">
              <v-text-field
                :model-value="volume"
                :label="$t('Volume')"
                @update:model-value="$emit('input-volume', $event)"
                :variant="fieldVariant"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="2" v-if="!hideVolume && multilingual">
              <v-btn variant="text" @click="$refs.volumelangdialog.open()">
                <span>
                  ({{ volumeLanguage ? volumeLanguage : '--' }})
                </span>
              </v-btn>
              <select-language ref="volumelangdialog" :showReset="volumeLanguage ? true : false" @language-selected="$emit('input-volume-language', $event)"></select-language>
            </v-col>

            <v-col cols="12" :md="multilingual ? ((hideVolume && hideIssued)? 10 : 4) : ((hideVolume && hideIssued)? 12 : 4)" v-if="!hideIssue">
              <v-text-field
                :model-value="issue"
                :label="$t('Issue')"
                @update:model-value="$emit('input-issue', $event)"
                :variant="fieldVariant"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="2" v-if="!hideIssue && multilingual">
              <v-btn variant="text" @click="$refs.issuelangdialog.open()">
                <span>
                  ({{ issueLanguage ? issueLanguage : '--' }})
                </span>
              </v-btn>
              <select-language ref="issuelangdialog" :showReset="issueLanguage ? true : false" @language-selected="$emit('input-issue-language', $event)"></select-language>
            </v-col>

            <v-col cols="12" :md="(hideVolume && hideIssue)? 12 : 4" v-if="!hideIssued">
              <template v-if="issuedDatePicker">
                <v-text-field
                  :model-value="issued"
                  @update:model-value="$emit('input-issued', $event)"
                  :label="$t(issuedDateLabel ? issuedDateLabel : 'Issued')"
                  :rules="[validationrules.date]"
                  :variant="fieldVariant"
                >
                  <template v-slot:append-inner>
                    <v-menu
                      ref="menu1"
                      v-model="dateMenu"
                      :close-on-content-click="false"
                      transition="scale-transition"
                      offset-y
                      max-width="290px"
                      min-width="290px"
                    >
                      <template v-slot:activator="{ props: activatorProps }">
                        <v-icon v-bind="activatorProps">mdi-calendar</v-icon>
                      </template>
                      <v-date-picker
                        color="primary"
                        :show-current="false"
                        v-model="pickerModel"
                        :first-day-of-week="1"
                        :locale="alpha2bcp47($i18n.locale)"
                        @update:model-value="dateMenu = false; $emit('input-issued', $event)"
                      ></v-date-picker>
                    </v-menu>
                  </template>
                </v-text-field>
              </template>
              <template v-else>
                <v-text-field
                  :model-value="issued"
                  @update:model-value="$emit('input-issued', $event)"
                  :label="$t(issuedDateLabel ? issuedDateLabel : 'Issued')"
                  :hint="$t(dateFormatHint)"
                  :rules="[validationrules.date]"
                  :variant="fieldVariant"
                ></v-text-field>
              </template>
            </v-col>

          </v-row>

          <v-row v-if="!hidePages">
            <v-col cols="12" md="6">
              <v-text-field
                :model-value="pageStart"
                :label="$t(pageStartLabel)"
                @update:model-value="$emit('input-page-start', $event)"
                :variant="fieldVariant"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="6">
              <v-text-field
                :model-value="pageEnd"
                :label="$t(pageEndLabel)"
                @update:model-value="$emit('input-page-end', $event)"
                :variant="fieldVariant"
              ></v-text-field>
            </v-col>
          </v-row>

          <v-row >

            <v-col cols="12" v-if="!hideIssn">
              <v-text-field
                :model-value="issn"
                :label="$t('ISSN')"
                @update:model-value="$emit('input-issn', $event)"
                :variant="fieldVariant"
              ></v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col :cols="6" v-if="!hideIdentifierType && !hideIdentifier">
              <v-autocomplete
                :no-data-text="$t('No data available')"
                @update:model-value="$emit('input-identifier-type', $event)"
                :label="$t('Type of identifier')"
                :items="vocabularies[identifierVocabulary].terms"
                item-value="@id"
                :item-title="(item) => skosTermItemTitle(item, identifierVocabulary)"
                :model-value="getTerm(identifierVocabulary, identifierType)"
                :custom-filter="vocabAutocompleteFilter"
                :variant="fieldVariant"
                return-object
                clearable
              >
                <template #item="{ props, internalItem }">
                  <v-list-item v-bind="props" lines="one">
                    <template #title>
                      <span v-html="`${getLocalizedTermLabel(identifierVocabulary, internalItem.raw['@id'])}`" />
                    </template>
                  </v-list-item>
                </template>
                <template #selection="{ internalItem }">
                  <span v-html="`${getLocalizedTermLabel(identifierVocabulary, (internalItem.raw || internalItem)['@id'])}`" />
                </template>
              </v-autocomplete>
            </v-col>

            <v-col :cols="!hideIdentifierType ? 6 : 12" v-if="!hideIdentifier">
              <v-text-field
                :model-value="identifier"
                :label="$t('Identifier')"
                @update:model-value="$emit('input-identifier', $event)"
                :variant="fieldVariant"
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
import datepickerproperties from '../../mixins/datepickerproperties'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import SelectLanguage from '../select/SelectLanguage'
import xmlUtils from '../../utils/xml'
import qs from 'qs'

export default {
  name: 'p-i-series',
  mixins: [vocabulary, fieldproperties, validationrules, datepickerproperties],
  components: {
    SelectLanguage
  },
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
    volumeLanguage: {
      type: String
    },
    hideIssue: {
      type: Boolean
    },
    issue: {
      type: String
    },
    issueLanguage: {
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
    hideIdentifierType: {
      type: Boolean,
      default: false
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
      return this.$store.state.appconfig
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
          const bytes = response.data instanceof ArrayBuffer ? new Uint8Array(response.data) : new Uint8Array(response.data);
          const utfxml = new TextDecoder('iso-8859-1').decode(bytes)
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
