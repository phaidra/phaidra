<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8">
        <v-card-title class="title font-weight-light white--text">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-menu open-on-hover bottom offset-y v-if="actions.length">
            <template v-slot:activator="{ on, attrs }">
              <v-btn v-on="on" v-bind="attrs" icon dark>
                <v-icon dark>mdi-dots-vertical</v-icon>
              </v-btn>
            </template>
            <v-list>
              <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
                <v-list-item-title>{{ action.title }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row>
            <v-col cols="2" v-show="!hideType">
              <v-radio-group v-model="typeModel" class="mt-0" @change="$emit('change-type', $event)">
                <v-radio color="primary" :label="$t(instanceconfig.institution)" :value="'select'"></v-radio>
                <v-radio color="primary" :label="'ROR'" :value="'ror'"></v-radio>
                <v-radio color="primary" :label="$t('PUBLISHER_VERLAG')" :value="'other'"></v-radio>
              </v-radio-group>
            </v-col>
            <template v-if="typeModel === 'select'">
              <v-col cols="10">
                <v-autocomplete
                  :value="getTerm('orgunits', publisherOrgUnit)"
                  :required="required"
                  v-on:input="handleInput($event, 'organizationPath', 'input-publisher-select')"
                  :rules="required ? [ v => !!v || 'Required'] : []"
                  :items="vocabularies['orgunits'].terms"
                  :item-value="'@id'"
                  :loading="loading"
                  :filter="autocompleteFilterInfix"
                  hide-no-data
                  :label="$t('Please choose')"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  return-object
                  clearable
                  :error-messages="publisherOrgUnitErrorMessages"
                  :messages="organizationPath"
                >
                  <template slot="item" slot-scope="{ item }">
                    <v-list-item-content two-line>
                      <v-list-item-title  v-html="`${getLocalizedTermLabel('orgunits', item['@id'])}`"></v-list-item-title>
                      <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
                    </v-list-item-content>
                  </template>
                  <template slot="selection" slot-scope="{ item }">
                    <v-list-item-content>
                      <v-list-item-title v-html="`${getLocalizedTermLabel('orgunits', item['@id'])}`"></v-list-item-title>
                    </v-list-item-content>
                  </template>
                  <template v-slot:append-outer>
                    <v-icon v-if="enableOrgTree" @click="$refs.organizationstreedialog.open()">mdi-file-tree</v-icon>
                  </template>
                </v-autocomplete>
              </v-col>
            </template>
            <template v-if="typeModel === 'ror'">
              <v-col cols="12" md="10">
                <ror-search v-on:resolve="$emit('input-publisher-ror',$event)" :value="publisherRor" :text="publisherRorName" :errorMessages="publisherRorNameErrorMessages"></ror-search>
              </v-col>
            </template>
            <template v-else>
              <v-col v-if="publisherSearch" cols="12" md="5">
                <v-combobox
                  v-model="publisherSearchModel"
                  :items="publisherSearchItems"
                  :loading="publisherSearchLoading"
                  :search-input.sync="publisherSearchQuery"
                  :error-messages="publisherSearchErrors"
                  v-on:input="$emit('input-suggest-publisher', $event)"
                  cache-items
                  hide-no-data
                  hide-selected
                  return-object
                  item-text="name"
                  item-value="name"
                  :placeholder="$t('search publishers')"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  clearable
                  append-icon="mdi-magnify"
                >
                  <template slot="item" slot-scope="{ item }">
                    <v-list-item-content>
                      <v-list-item-title>{{ item.name }}</v-list-item-title>
                      <v-list-item-subtitle v-if="item.alias">{{ $t('Alias') + ': ' + item.alias }}</v-list-item-subtitle>
                    </v-list-item-content>
                  </template>
                  <template slot="selection" slot-scope="{ item }">
                    <v-list-item-content>
                      <v-list-item-title>{{ item.name }}</v-list-item-title>
                    </v-list-item-content>
                  </template>
                </v-combobox>
              </v-col>
              <v-col cols="12" :md="publisherSearch ? 5 : 10">
                <v-text-field
                  :value="publisherName"
                  v-on:blur="$emit('input-publisher-name',$event.target.value)"
                  :label="$t(publisherNameLabel ? publisherNameLabel : '')"
                  :required="required"
                  :rules="required ? [ v => !!v || 'Required'] : []"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  :error-messages="publisherNameErrorMessages"
                  :background-color="publisherBackgroundColor ? publisherBackgroundColor : undefined"
                ></v-text-field>
              </v-col>
            </template>
          </v-row>
          <v-row>
            <v-col v-if="showPlace" cols="12" :md="showDate ? 8 : 12">
              <v-text-field
                :value="publishingPlace"
                v-on:blur="$emit('input-publishing-place',$event.target.value)"
                :label="$t(publishingPlaceLabel ? publishingPlaceLabel : '')"
                :required="required"
                :rules="required ? [ v => !!v || 'Required'] : []"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
              ></v-text-field>
            </v-col>
            <v-col v-if="showDate" cols="12" :md="showPlace ? 4 : 12">
              <template v-if="publishingDatePicker">
                <v-text-field
                  :value="publishingDate"
                  v-on:blur="$emit('input-publishing-date',$event.target.value)"
                  :label="$t(publishingDateLabel ? publishingDateLabel : 'Date')"
                  :required="required"
                  :rules="[validationrules.date]"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  :error-messages="publishingDateErrorMessages"
                  :background-color="publishingDateBackgroundColor ? publishingDateBackgroundColor : undefined"
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
                        <template v-slot:activator="{ on, attrs }">
                          <v-icon v-on="on" v-bind="attrs">mdi-calendar</v-icon>
                        </template>
                        <v-date-picker
                          color="primary"
                          :value="publishingDate"
                          :show-current="false"
                          v-model="pickerModel"
                          :first-day-of-week="1"
                          :locale="alpha2bcp47($i18n.locale)"
                          v-on:input="dateMenu = false; $emit('input-publishing-date', $event)"
                        ></v-date-picker>
                      </v-menu>
                    </v-fade-transition>
                  </template>
                </v-text-field>
              </template>
              <template v-else>
                <v-text-field
                  :value="publishingDate"
                  v-on:blur="$emit('input-publishing-date',$event.target.value)"
                  :label="$t(publishingDateLabel ? publishingDateLabel : 'Date')"
                  :required="required"
                  :hint="$t(dateFormatHint)"
                  :rules="[validationrules.date]"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  :background-color="publishingDateBackgroundColor ? publishingDateBackgroundColor : undefined"
                ></v-text-field>
              </template>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
    <org-units-tree-dialog ref="organizationstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event), 'organizationPath', 'input-publisher-select')"></org-units-tree-dialog>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import datepickerproperties from '../../mixins/datepickerproperties'
import { vocabulary } from '../../mixins/vocabulary'
import xmlUtils from '../../utils/xml'
import qs from 'qs'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'
import RorSearch from '../select/RorSearch'
var iconv = require('iconv-lite')

export default {
  name: 'p-i-bf-publication',
  mixins: [validationrules, fieldproperties, vocabulary, datepickerproperties],
  components: {
    OrgUnitsTreeDialog,
    RorSearch
  },
  props: {
    publisherName: {
      type: String,
      required: true
    },
    publisherNameErrorMessages: {
      type: Array
    },
    publisherOrgUnit: {
      type: String
    },
    publisherRor: {
      type: String
    },
    publisherRorName: {
      type: String
    },
    publisherRorNameErrorMessages: {
      type: Array
    },
    publisherSelectedName: {
      type: Array
    },
    publisherOrgUnitErrorMessages: {
      type: Array
    },
    publisherSearch: {
      type: Boolean,
      default: false
    },
    publishingDate: {
      type: String
    },
    publishingPlace: {
      type: String
    },
    label: {
      type: String
    },
    publisherNameLabel: {
      type: String
    },
    publishingDateLabel: {
      type: String
    },
    publishingPlaceLabel: {
      type: String
    },
    publishingDateErrorMessages: {
      type: Array
    },
    publisherType: {
      type: String
    },
    publishingDatePicker: {
      type: Boolean
    },
    required: {
      type: Boolean
    },
    showPlace: {
      type: Boolean,
      default: true
    },
    showDate: {
      type: Boolean,
      default: true
    },
    showIds: {
      type: Boolean,
      default: false
    },
    hideType: {
      type: Boolean,
      default: false
    },
    publisherBackgroundColor: {
      type: String,
      default: undefined
    },
    publishingDateBackgroundColor: {
      type: String,
      default: undefined
    },
    dateFormatHint: {
      type: String,
      default: 'Format YYYY-MM-DD'
    },
    enableOrgTree: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    instanceconfig: function () {
      return this.$root.$store.state.instanceconfig
    },
    appconfig: function () {
      return this.$root.$store.state.appconfig
    }
  },
  watch: {
    publisherSearchQuery (val) {
      val && this.publisherSearchDebounceFunction(val)
    }
  },
  data () {
    return {
      typeModel: this.publisherType,
      pickerModel: new Date().toISOString().substr(0, 10),
      dateMenu: false,
      loading: false,
      publisherSearchModel: null,
      publisherSearchItems: [],
      publisherSearchErrors: [],
      publisherSearchData: null,
      publisherSearchLoading: false,
      publisherSearchQuery: '',
      publisherSearchDebounce: 500,
      publisherSearchMinLetters: 3,
      publisherSearchDebounceTask: null,
      organizationPath: ''
    }
  },
  methods: {
    publisherSearchDebounceFunction (value) {
      this.showList = true
      if (this.publisherSearchDebounce) {
        if (this.publisherSearchDebounceTask !== undefined) clearTimeout(this.publisherSearchDebounceTask)
        this.publisherSearchDebounceTask = setTimeout(() => {
          return this.suggestPublishers(value)
        }, this.publisherSearchDebounce)
      } else {
        return this.suggestPublishers(value)
      }
    },
    async suggestPublishers (q) {
      if (process.browser) {
        if (q.length < this.publisherSearchMinLetters || !this.appconfig.apis.sherparomeo) return

        this.publisherSearchLoading = true
        this.publisherSearchItems = []

        var params = {
          ak: this.appconfig.apis.sherparomeo.key,
          versions: 'all',
          qtype: 'exact',
          pub: q
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
          for (let p of obj.romeoapi[1].publishers.publisher) {
            this.publisherSearchItems.push(
              {
                name: p.name['#text'],
                alias: p.alias['#text']
              }
            )
          }
        } catch (error) {
          console.log(error)
          this.publisherSearchErrors.push(error)
        } finally {
          this.publisherSearchLoading = false
        }
      }
    },
    handleInput: function (unit, propName, eventName) {
      this[propName] = ''
      if (unit) {
        let path = []
        if (!unit.hasOwnProperty('@id')) {
          unit = this.getTerm('orgunits', unit)
        }
        this.getOrgPath(unit, this.vocabularies['orgunits'].tree, path)
        let pathLabels = []
        for (let u of path) {
          pathLabels.push(u['skos:prefLabel'][this.$i18n.locale])
        }
        this[propName] = pathLabels.join(' > ')
      }
      this.$emit(eventName, unit)
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      if (!this.vocabularies['orgunits'].loaded) {
        this.$store.dispatch('vocabulary/loadOrgUnits', this.$i18n.locale)
      }
      if (this.publisherOrgUnit) {
        this.$emit('input-publisher-select', this.getTerm('orgunits', this.publisherOrgUnit))
      }
    })
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
