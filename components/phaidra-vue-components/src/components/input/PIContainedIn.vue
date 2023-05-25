<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8">
        <v-card-title class="title font-weight-light grey white--text">
          <span>{{ $t(label) }}</span>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row>
            <v-col>
              <v-row >
                <v-col cols="12" :md="multilingual ? 4 : 6">
                  <v-text-field
                    :value="title"
                    :label="$t('Title')"
                    v-on:blur="$emit('input-title',$event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                    :error-messages="titleErrorMessages"
                    :background-color="titleBackgroundColor ? titleBackgroundColor : undefined"
                  ></v-text-field>
                </v-col>
                <v-col cols="12" :md="multilingual ? 4 : 6">
                  <v-text-field
                    :value="subtitle"
                    :label="$t('Subtitle')"
                    v-on:blur="$emit('input-subtitle',$event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
                <v-col cols="4" v-if="multilingual">
                  <v-autocomplete
                    :value="getTerm('lang', titleLanguage)"
                    v-on:input="$emit('input-title-language', $event)"
                    :items="vocabularies['lang'].terms"
                    :filter="autocompleteFilter"
                    hide-no-data
                    :label="$t('Language')"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                    return-object
                    clearable
                    :item-value="'@id'"
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
              <v-row v-for="(role, i) in roles" :key="'role'+i">
                <v-col cols="4">
                  <v-autocomplete
                    :disabled="disablerole"
                    v-on:input="$emit('input-role', { role: role, roleTerm: $event })"
                    :label="$t('Role')"
                    :items="vocabularies[rolesVocabulary].terms"
                    :value="getTerm(rolesVocabulary, role.role)"
                    :filter="autocompleteFilter"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                    return-object
                    clearable
                    :item-value="'@id'"
                  >
                    <template slot="item" slot-scope="{ item }">
                      <v-list-item-content two-line>
                        <v-list-item-title  v-html="`${getLocalizedTermLabel(rolesVocabulary, item['@id'])}`"></v-list-item-title>
                        <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
                      </v-list-item-content>
                    </template>
                    <template slot="selection" slot-scope="{ item }">
                      <v-list-item-content>
                        <v-list-item-title v-html="`${getLocalizedTermLabel(rolesVocabulary, item['@id'])}`"></v-list-item-title>
                      </v-list-item-content>
                    </template>
                  </v-autocomplete>
                </v-col>
                <template v-if="showname">
                  <v-col cols="4" >
                    <v-text-field
                      :value="role.name"
                      :label="$t('Name')"
                      v-on:blur="$emit('input-role',{ role: role, name: $event.target.value })"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-else>
                  <v-col cols="3">
                    <v-text-field
                      :value="role.firstname"
                      :label="$t('Firstname')"
                      v-on:blur="$emit('input-role',{ role: role, firstname: $event.target.value })"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="3">
                    <v-text-field
                      :value="role.lastname"
                      :label="$t('Lastname')"
                      v-on:blur="$emit('input-role',{ role: role, lastname: $event.target.value })"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                  </v-col>
                </template>
                <v-col cols="1" v-if="roleActions.length">
                  <v-menu open-on-hover bottom offset-y>
                    <template v-slot:activator="{ on }">
                      <v-btn v-on="on" icon>
                        <v-icon>mdi-dots-vertical</v-icon>
                      </v-btn>
                    </template>
                    <v-list>
                      <v-list-item v-for="(action, i) in roleActions" :key="i" @click="$emit(action.event, role)">
                        <v-list-item-title>{{ action.title }}</v-list-item-title>
                      </v-list-item>
                    </v-list>
                  </v-menu>
                </v-col>
              </v-row>
              <v-row>
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
              <v-row>
                <v-col :cols="12">
                  <v-text-field
                    :value="isbn"
                    :label="$t(isbnLabel)"
                    v-on:blur="$emit('input-isbn',$event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                    :placeholder="isbnPlaceholder"
                    :error-messages="isbnErrorMessages"
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
                    v-on:blur="$emit('input-identifier', $event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
          <v-row v-for="(s,i) in series" :key="'series'+i">
            <v-col cols="12">
              <v-card class="mb-8">
                <v-card-title class="title font-weight-light grey white--text">
                  <span>{{ $t(seriesLabel) }}</span>
                  <v-spacer></v-spacer>
                  <v-btn v-if="s.multiplicable" icon dark @click="$emit('add-series', s)">
                    <v-icon>mdi-content-duplicate</v-icon>
                  </v-btn>
                  <v-btn v-if="s.multiplicableCleared" icon dark @click="$emit('add-clear-series', s)">
                    <v-icon>mdi-plus</v-icon>
                  </v-btn>
                  <v-btn v-if="s.removable" icon dark @click="$emit('remove-series', s)">
                    <v-icon>mdi-minus</v-icon>
                  </v-btn>
                  <span>
                    <v-icon dark v-show="collapseSeriesModel" @click="collapseSeriesModel=!collapseSeriesModel">mdi-arrow-right-drop-circle</v-icon>
                    <v-icon dark v-show="!collapseSeriesModel" @click="collapseSeriesModel=!collapseSeriesModel">mdi-arrow-down-drop-circle</v-icon>
                  </span>
                </v-card-title>
                <v-card-text class="mt-4" v-show="!collapseSeriesModel">
                  <v-container fluid>
                    <v-row >
                      <v-col cols="12" :md="multilingual ? 10 : 12">
                        <v-text-field
                          :value="s.seriesTitle"
                          :label="$t('Title')"
                          v-on:blur="$emit('input-series', { series: s, seriesTitle: $event.target.value })"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                        ></v-text-field>
                      </v-col>
                      <v-col cols="12" md="2" v-if="multilingual">
                        <v-autocomplete
                          :value="getTerm('lang', s.seriesTitleLanguage)"
                          v-on:input="$emit('input-series', { series: s, seriesTitleLanguageTerm: $event })"
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

                      <v-col cols="12" :md="(hideSeriesIssue && hideSeriesIssued) ? 12 : (hideSeriesIssue || hideSeriesIssued) ? 6 : 4" v-if="!hideSeriesVolume">
                        <v-text-field
                          :value="s.seriesVolume"
                          :label="$t('Volume')"
                          v-on:blur="$emit('input-series', { series: s, seriesVolume: $event.target.value })"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                        ></v-text-field>
                      </v-col>

                      <v-col cols="12" :md="(hideSeriesVolume && hideSeriesIssued) ? 12 : (hideSeriesVolume || hideSeriesIssued) ? 6:  4" v-if="!hideSeriesIssue">
                        <v-text-field
                          :value="s.seriesIssue"
                          :label="$t('Issue')"
                          v-on:blur="$emit('input-series', { series: s, seriesIssue: $event.target.value })"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                        ></v-text-field>
                      </v-col>

                      <v-col cols="12" :md="(hideSeriesVolume && hideSeriesIssue) ? 12 : (hideSeriesVolume && hideSeriesIssue) ? 6 : 4" v-if="!hideSeriesIssued">

                        <v-text-field
                          :value="s.seriesIssued"
                          v-on:blur="$emit('input-series', { series: s, seriesIssued: $event.target.value })"
                          :label="$t(seriesIssuedDateLabel ? seriesIssuedDateLabel : 'Issued')"
                          :hint="dateFormatHint"
                          :rules="[validationrules.date]"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                        ></v-text-field>

                      </v-col>

                    </v-row>

                    <v-row >

                      <v-col cols="6" v-if="!hideSeriesIssn">
                        <v-text-field
                          :value="s.seriesIssn"
                          :label="$t('ISSN')"
                          v-on:blur="$emit('input-series', { series: s, seriesIssn: $event.target.value })"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col :cols="6" v-if="showSeriesIdentifierType && !hideSeriesIdentifier">
                        <v-autocomplete
                          v-on:input="$emit('input-series', { series: s, seriesIdentifierType: $event['@id'] })"
                          :label="$t('Type of identifier')"
                          :items="vocabularies[seriesIdentifierVocabulary].terms"
                          :item-value="'@id'"
                          :value="getTerm(seriesIdentifierVocabulary, s.seriesIdentifierType)"
                          :filter="autocompleteFilter"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                          return-object
                          clearable
                        >
                          <template slot="item" slot-scope="{ item }">
                            <v-list-item-content two-line>
                              <v-list-item-title  v-html="`${getLocalizedTermLabel(seriesIdentifierVocabulary, item['@id'])}`"></v-list-item-title>
                            </v-list-item-content>
                          </template>
                          <template slot="selection" slot-scope="{ item }">
                            <v-list-item-content>
                              <v-list-item-title v-html="`${getLocalizedTermLabel(seriesIdentifierVocabulary, item['@id'])}`"></v-list-item-title>
                            </v-list-item-content>
                          </template>
                        </v-autocomplete>
                      </v-col>

                      <v-col :cols="showSeriesIdentifierType ? 6 : 12" v-if="!hideSeriesIdentifier">
                        <v-text-field
                          :value="s.seriesIdentifier"
                          :label="$t('Identifier')"
                          v-on:blur="$emit('input-series', { series: s, seriesIdentifier: $event.target.value })"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                        ></v-text-field>
                      </v-col>

                    </v-row>
                  </v-container>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12">
              <v-card class="mb-8">
                <v-card-title class="title font-weight-light grey white--text">
                  <span>{{ $t(publisherLabel) }}</span>
                  <v-spacer></v-spacer>
                  <span>
                    <v-icon dark v-show="collapsePublisherModel" @click="collapsePublisherModel=!collapsePublisherModel">mdi-arrow-right-drop-circle</v-icon>
                    <v-icon dark v-show="!collapsePublisherModel" @click="collapsePublisherModel=!collapsePublisherModel">mdi-arrow-down-drop-circle</v-icon>
                  </span>
                </v-card-title>
                <v-divider></v-divider>
                <v-card-text class="mt-4" v-show="!collapsePublisherModel">
                  <v-row>
                    <v-col cols="2" v-show="!publisherHideType">
                      <v-radio-group v-model="publisherTypeModel" class="mt-0" @change="$emit('change-publisher-type', $event)">
                        <v-radio color="primary" :label="$t(instanceconfig.institution)" :value="'select'"></v-radio>
                        <v-radio color="primary" :label="$t('PUBLISHER_VERLAG')" :value="'other'"></v-radio>
                      </v-radio-group>
                    </v-col>
                    <template v-if="publisherTypeModel === 'select'">
                      <v-col cols="10">
                        <v-autocomplete
                          :value="getTerm('orgunits', publisherOrgUnit)"
                          v-on:input="handleInput($event, 'organizationPath', 'input-publisher-select')"
                          :items="vocabularies['orgunits'].terms"
                          :item-value="'@id'"
                          :loading="loading"
                          :filter="autocompleteFilter"
                          hide-no-data
                          :label="$t('Please choose')"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                          return-object
                          clearable
                          :error-messages="publisherOrgUnitErrorMessages"
                          :messages="organizationPath"
                          :background-color="publisherBackgroundColor ? publisherBackgroundColor : undefined"
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
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                          :error-messages="publisherNameErrorMessages"
                          :background-color="publisherBackgroundColor ? publisherBackgroundColor : undefined"
                        ></v-text-field>
                      </v-col>
                    </template>
                  </v-row>
                  <v-row>
                    <v-col v-if="publisherShowPlace" cols="12" :md="publisherShowDate ? 8 : 12">
                      <v-text-field
                        :value="publishingPlace"
                        v-on:blur="$emit('input-publishing-place',$event.target.value)"
                        :label="$t(publishingPlaceLabel ? publishingPlaceLabel : '')"
                        :filled="inputStyle==='filled'"
                        :outlined="inputStyle==='outlined'"
                      ></v-text-field>
                    </v-col>
                    <v-col v-if="publisherShowDate" cols="12" :md="publisherShowPlace ? 4 : 12">
                      <template v-if="publishingDatePicker">
                        <v-text-field
                          :value="publishingDate"
                          v-on:blur="$emit('input-publishing-date',$event.target.value)"
                          :label="$t(publishingDateLabel ? publishingDateLabel : 'Date')"
                          :rules="[validationrules.date]"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                          :error-messages="publishingDateErrorMessages"
                        >
                          <template v-slot:append>
                            <v-fade-transition leave-absolute>
                              <v-menu
                                ref="menu1"
                                v-model="publisherDateMenu"
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
                                  :value="publishingDate"
                                  :show-current="false"
                                  v-model="publisherPickerModel"
                                  :locale="$i18n.locale === 'deu' ? 'de-AT' : 'en-GB' "
                                  v-on:input="publisherDateMenu = false; $emit('input-publishing-date', $event)"
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
                          :hint="dateFormatHint"
                          :rules="[validationrules.date]"
                          :filled="inputStyle==='filled'"
                          :outlined="inputStyle==='outlined'"
                        ></v-text-field>
                      </template>
                    </v-col>
                    <org-units-tree-dialog ref="organizationstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event), 'organizationPath', 'input-publisher-select')"></org-units-tree-dialog>
                  </v-row>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'
import { vocabulary } from '../../mixins/vocabulary'
import { validationrules } from '../../mixins/validationrules'
import xmlUtils from '../../utils/xml'
import qs from 'qs'
import axios from 'axios'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'
var iconv = require('iconv-lite')

export default {
  name: 'p-i-contained-in',
  mixins: [fieldproperties, vocabulary, validationrules],
  components: {
    OrgUnitsTreeDialog
  },
  props: {
    type: {
      type: String
    },
    multilingual: {
      type: Boolean
    },
    label: {
      type: String
    },
    title: {
      type: String
    },
    titleErrorMessages: {
      type: Array
    },
    subtitle: {
      type: String
    },
    titleLanguage: {
      type: String
    },
    roles: {
      type: Array
    },
    rolesVocabulary: {
      type: String,
      default: 'rolepredicate'
    },
    disablerole: {
      type: Boolean,
      default: false
    },
    showname: {
      type: Boolean,
      default: false
    },
    showIds: {
      type: Boolean,
      default: false
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
    isbn: {
      type: String
    },
    isbnLabel: {
      type: String
    },
    isbnPlaceholder: {
      type: String,
      default: '978-3-16-148410-0'
    },
    isbnErrorMessages: {
      type: Array
    },
    identifier: {
      type: String
    },
    identifierType: {
      type: String
    },
    hideIdentifier: {
      type: Boolean,
      default: false
    },
    showIdentifierType: {
      type: Boolean,
      default: true
    },
    identifierVocabulary: {
      type: String,
      default: 'objectidentifiertype'
    },
    series: {
      type: Array
    },
    seriesLabel: {
      type: String
    },
    hideSeriesVolume: {
      type: Boolean
    },
    hideSeriesIssue: {
      type: Boolean
    },
    hideSeriesIssued: {
      type: Boolean
    },
    seriesIssuedDateLabel: {
      type: String
    },
    hideSeriesIssn: {
      type: Boolean
    },
    hideSeriesIdentifier: {
      type: Boolean,
      default: false
    },
    showSeriesIdentifierType: {
      type: Boolean,
      default: true
    },
    seriesIdentifierVocabulary: {
      type: String,
      default: 'objectidentifiertype'
    },
    seriesCollapse: {
      type: Boolean,
      default: false
    },
    publisherName: {
      type: String
    },
    publisherNameErrorMessages: {
      type: Array
    },
    publisherOrgUnit: {
      type: String
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
    publisherLabel: {
      type: String
    },
    publisherNameLabel: {
      type: String
    },
    publishingDateLabel: {
      type: String
    },
    publishingDateErrorMessages: {
      type: Array
    },
    publishingPlaceLabel: {
      type: String
    },
    publisherType: {
      type: String
    },
    publishingDatePicker: {
      type: Boolean
    },
    publisherShowPlace: {
      type: Boolean,
      default: true
    },
    publisherShowDate: {
      type: Boolean,
      default: true
    },
    publisherCollapse: {
      type: Boolean,
      default: false
    },
    publisherHideType: {
      type: Boolean,
      default: false
    },
    titleBackgroundColor: {
      type: String,
      default: undefined
    },
    publisherBackgroundColor: {
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
    },
    roleActions: function () {
      var arr = []
      arr.push({ title: this.$t('Remove'), event: 'remove-role' })
      arr.push({ title: this.$t('Duplicate'), event: 'add-role' })
      arr.push({ title: this.$t('Move up'), event: 'up-role' })
      arr.push({ title: this.$t('Move down'), event: 'down-role' })
      return arr
    }
  },
  watch: {
    publisherSearchQuery (val) {
      val && this.publisherSearchDebounceFunction(val)
    }
  },
  data () {
    return {
      collapseSeriesModel: this.seriesCollapse,
      collapsePublisherModel: this.publisherCollapse,
      publisherTypeModel: this.publisherType,
      publisherPickerModel: new Date().toISOString().substr(0, 10),
      publisherDateMenu: false,
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
          let response = await axios.request({
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
.vertical-center {
 align-items: center;
}
</style>
