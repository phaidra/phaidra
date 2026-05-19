<template>

  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card variant="outlined" class="mb-8">
        <v-card-title class="title font-weight-light text-white">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-menu open-on-hover bottom offset-y v-if="actions.length">
            <template v-slot:activator="{ props: activatorProps }">
              <v-btn v-bind="activatorProps" icon variant="text" color="white">
                <v-icon>mdi-dots-vertical</v-icon>
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
            <v-col>
              <v-row >
                <v-col cols="12" :md="multilingual ? 4 : 6">
                  <v-text-field
                    :model-value="title"
                    :label="$t('Title')"
                    @update:model-value="$emit('input-title', $event)"
                    :variant="fieldVariant"
                    :error-messages="titleErrorMessages"
                    :bg-color="titleBackgroundColor ? titleBackgroundColor : undefined"
                  ></v-text-field>
                </v-col>
                <v-col cols="12" :md="multilingual ? 4 : 6">
                  <v-text-field
                    :model-value="subtitle"
                    :label="$t('Subtitle')"
                    @update:model-value="$emit('input-subtitle', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
                <v-col cols="1" v-if="multilingual">
                  <v-btn variant="text" @click="$refs.langdialogtitle.open()">
                    <span>
                      ({{ titleLanguage ? titleLanguage : '--' }})
                    </span>
                  </v-btn>
                  <select-language ref="langdialogtitle" @language-selected="$emit('input-title-language', $event)"></select-language>
                </v-col>
              </v-row>
              <v-row v-for="(role, i) in roles" :key="'role'+i">
                <v-col cols="4">
                  <v-autocomplete
                    :no-data-text="$t('No data available')"
                    :disabled="disablerole"
                    @update:model-value="$emit('input-role', { role: role, roleTerm: $event })"
                    :label="$t('Role')"
                    :items="vocabularies[rolesVocabulary].terms"
                    :model-value="getTerm(rolesVocabulary, role.role)"
                    :item-title="(item) => skosTermItemTitle(item, rolesVocabulary)"
                    :custom-filter="vocabAutocompleteFilter"
                    :variant="fieldVariant"
                    return-object
                    clearable
                    item-value="@id"
                  >
                    <template #item="{ props, internalItem }">
                      <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
                        <template #title>
                          <span v-html="`${getLocalizedTermLabel(rolesVocabulary, internalItem.raw['@id'])}`" />
                        </template>
                        <template v-if="showIds" #subtitle>
                          <span v-html="internalItem.raw['@id']" />
                        </template>
                      </v-list-item>
                    </template>
                    <template #selection="{ internalItem }">
                      <span v-html="`${getLocalizedTermLabel(rolesVocabulary, (internalItem.raw || internalItem)['@id'])}`" />
                    </template>
                  </v-autocomplete>
                </v-col>
                <template v-if="showname">
                  <v-col cols="4" >
                    <v-text-field
                      :model-value="role.name"
                      :label="$t('Name')"
                      @update:model-value="$emit('input-role',{ role: role, name: $event })"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-else>
                  <v-col cols="3">
                    <v-text-field
                      :model-value="role.firstname"
                      :label="$t('Firstname')"
                      @update:model-value="$emit('input-role',{ role: role, firstname: $event })"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="3">
                    <v-text-field
                      :model-value="role.lastname"
                      :label="$t('Lastname')"
                      @update:model-value="$emit('input-role',{ role: role, lastname: $event })"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                </template>
                <v-col cols="1" v-if="roleActions.length">
                  <v-menu open-on-hover bottom offset-y>
                    <template v-slot:activator="{ props: activatorProps }">
                      <v-btn v-bind="activatorProps" icon variant="text">
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
              <v-row>
                <v-col :cols="12">
                  <v-text-field
                    :model-value="isbn"
                    :label="$t(isbnLabel)"
                    @update:model-value="$emit('input-isbn', $event)"
                    :variant="fieldVariant"
                    :placeholder="isbnPlaceholder"
                    :error-messages="isbnErrorMessages"
                  ></v-text-field>
                </v-col>
              </v-row>
              <v-row>
                <v-col :cols="6" v-if="showIdentifierType && !hideIdentifier">
                  <v-autocomplete
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
                <v-col :cols="showIdentifierType ? 6 : 12" v-if="!hideIdentifier">
                  <v-text-field
                    :model-value="identifier"
                    :label="$t('Identifier')"
                    @update:model-value="$emit('input-identifier', $event)"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
          <v-row v-for="(s,i) in series" :key="'series'+i">
            <v-col cols="12">
              <v-card variant="outlined" class="mb-8">
                <v-card-title class="title font-weight-light text-white">
                  <span>{{ $t(seriesLabel) }}</span>
                  <v-spacer></v-spacer>
                  <v-btn v-if="s.multiplicable" icon variant="text" color="white" @click="$emit('add-series', s)">
                    <v-icon>mdi-content-duplicate</v-icon>
                  </v-btn>
                  <v-btn v-if="s.multiplicableCleared" icon variant="text" color="white" @click="$emit('add-clear-series', s)">
                    <v-icon>mdi-plus</v-icon>
                  </v-btn>
                  <v-btn v-if="s.removable" icon variant="text" color="white" @click="$emit('remove-series', s)">
                    <v-icon>mdi-minus</v-icon>
                  </v-btn>
                  <span>
                    <v-btn theme="dark" icon v-show="collapseSeriesModel" @click="collapseSeriesModel=!collapseSeriesModel">
                      <v-icon>mdi-chevron-up</v-icon>
                    </v-btn>
                    <v-btn theme="dark" icon v-show="!collapseSeriesModel" @click="collapseSeriesModel=!collapseSeriesModel">
                      <v-icon>mdi-chevron-down</v-icon>
                    </v-btn>
                  </span>
                </v-card-title>
                <v-card-text class="mt-4" v-show="!collapseSeriesModel">
                  <v-container fluid>
                    <v-row >
                      <v-col cols="12" :md="multilingual ? 10 : 12">
                        <v-text-field
                          :model-value="s.seriesTitle"
                          :label="$t('Title')"
                          @update:model-value="$emit('input-series', { series: s, seriesTitle: $event })"
                          :variant="fieldVariant"
                        ></v-text-field>
                      </v-col>
                      <v-col cols="12" md="2" v-if="multilingual">
                        <v-btn variant="text" @click="$refs['langdialogtitleseries' + s.id][0].open()">
                          <span>
                            ({{ s.seriesTitleLanguage ? s.seriesTitleLanguage : '--' }})
                          </span>
                        </v-btn>
                        <select-language :ref="'langdialogtitleseries' + s.id" @language-selected="$emit('input-series', { series: s, seriesTitleLanguageTerm: $event })"></select-language>
                      </v-col>

                    </v-row>

                    <v-row >

                      <v-col cols="12" :md="multilingual ? ((hideSeriesIssue && hideSeriesIssued) ? 10 : 4) : ((hideSeriesIssue && hideSeriesIssued) ? 12 : (hideSeriesIssue || hideSeriesIssued) ? 6 : 4)" v-if="!hideSeriesVolume">
                        <v-text-field
                          :model-value="s.seriesVolume"
                          :label="$t('Volume')"
                          @update:model-value="$emit('input-series', { series: s, seriesVolume: $event })"
                          :variant="fieldVariant"
                        ></v-text-field>
                      </v-col>
                      <v-col cols="12" md="2" v-if="!hideSeriesVolume && multilingual">
                        <v-btn variant="text" @click="$refs['langdialogvolumeseries' + s.id][0].open()">
                          <span>
                            ({{ s.seriesVolumeLanguage ? s.seriesVolumeLanguage : '--' }})
                          </span>
                        </v-btn>
                        <select-language :ref="'langdialogvolumeseries' + s.id" :showReset="s.seriesVolumeLanguage ? true : false" @language-selected="$emit('input-series', { series: s, seriesVolumeLanguageTerm: $event })"></select-language>
                      </v-col>

                      <v-col cols="12" :md="multilingual ? ((hideSeriesVolume && hideSeriesIssued) ? 10 : 4) : ((hideSeriesVolume && hideSeriesIssued) ? 12 : (hideSeriesVolume || hideSeriesIssued) ? 6:  4)" v-if="!hideSeriesIssue">
                        <v-text-field
                          :model-value="s.seriesIssue"
                          :label="$t('Issue')"
                          @update:model-value="$emit('input-series', { series: s, seriesIssue: $event })"
                          :variant="fieldVariant"
                        ></v-text-field>
                      </v-col>
                      <v-col cols="12" md="2" v-if="!hideSeriesIssue && multilingual">
                        <v-btn variant="text" @click="$refs['langdialogissueseries' + s.id][0].open()">
                          <span>
                            ({{ s.seriesIssueLanguage ? s.seriesIssueLanguage : '--' }})
                          </span>
                        </v-btn>
                        <select-language :ref="'langdialogissueseries' + s.id" :showReset="s.seriesIssueLanguage ? true : false" @language-selected="$emit('input-series', { series: s, seriesIssueLanguageTerm: $event })"></select-language>
                      </v-col>

                      <v-col cols="12" :md="(hideSeriesVolume && hideSeriesIssue) ? 12 : (hideSeriesVolume && hideSeriesIssue) ? 6 : 4" v-if="!hideSeriesIssued">

                        <v-text-field
                          :model-value="s.seriesIssued"
                          @update:model-value="$emit('input-series', { series: s, seriesIssued: $event })"
                          :label="$t(seriesIssuedDateLabel ? seriesIssuedDateLabel : 'Issued')"
                          :hint="$t(dateFormatHint)"
                          :rules="[validationrules.date]"
                          :variant="fieldVariant"
                        ></v-text-field>

                      </v-col>

                    </v-row>

                    <v-row >

                      <v-col cols="6" v-if="!hideSeriesIssn">
                        <v-text-field
                          :model-value="s.seriesIssn"
                          :label="$t('ISSN')"
                          @update:model-value="$emit('input-series', { series: s, seriesIssn: $event })"
                          :variant="fieldVariant"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col :cols="6" v-if="showSeriesIdentifierType && !hideSeriesIdentifier">
                        <v-autocomplete
                          :no-data-text="$t('No data available')"
                          @update:model-value="$emit('input-series', { series: s, seriesIdentifierType: $event && $event['@id'] })"
                          :label="$t('Type of identifier')"
                          :items="vocabularies[seriesIdentifierVocabulary].terms"
                          item-value="@id"
                          :item-title="(item) => skosTermItemTitle(item, seriesIdentifierVocabulary)"
                          :model-value="getTerm(seriesIdentifierVocabulary, s.seriesIdentifierType)"
                          :custom-filter="vocabAutocompleteFilter"
                          :variant="fieldVariant"
                          return-object
                          clearable
                        >
                          <template #item="{ props, internalItem }">
                            <v-list-item v-bind="props" lines="one">
                              <template #title>
                                <span v-html="`${getLocalizedTermLabel(seriesIdentifierVocabulary, internalItem.raw['@id'])}`" />
                              </template>
                            </v-list-item>
                          </template>
                          <template #selection="{ internalItem }">
                            <span v-html="`${getLocalizedTermLabel(seriesIdentifierVocabulary, (internalItem.raw || internalItem)['@id'])}`" />
                          </template>
                        </v-autocomplete>
                      </v-col>

                      <v-col :cols="showSeriesIdentifierType ? 6 : 12" v-if="!hideSeriesIdentifier">
                        <v-text-field
                          :model-value="s.seriesIdentifier"
                          :label="$t('Identifier')"
                          @update:model-value="$emit('input-series', { series: s, seriesIdentifier: $event })"
                          :variant="fieldVariant"
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
              <v-card variant="outlined" class="mb-8">
                <v-card-title class="title font-weight-light text-white">
                  <span>{{ $t(publisherLabel) }}</span>
                  <v-spacer></v-spacer>
                  <span>
                    <v-btn theme="dark" icon v-show="collapsePublisherModel" @click="collapsePublisherModel=!collapsePublisherModel">
                      <v-icon>mdi-chevron-up</v-icon>
                    </v-btn>
                    <v-btn theme="dark" icon v-show="!collapsePublisherModel" @click="collapsePublisherModel=!collapsePublisherModel">
                      <v-icon>mdi-chevron-down</v-icon>
                    </v-btn>
                  </span>
                </v-card-title>
                <v-divider></v-divider>
                <v-card-text class="mt-4" v-show="!collapsePublisherModel">
                  <v-row>
                    <v-col cols="2" v-show="!publisherHideType">
                      <v-radio-group v-model="publisherTypeModel" class="mt-0" @change="$emit('change-publisher-type', $event)">
                        <v-radio color="primary" :label="$t('Organizational unit')" :value="'select'"></v-radio>
                        <v-radio color="primary" :label="$t('PUBLISHER_VERLAG')" :value="'other'"></v-radio>
                      </v-radio-group>
                    </v-col>
                    <template v-if="publisherTypeModel === 'select'">
                      <v-col cols="10">
                        <v-autocomplete
                          :model-value="getTerm('orgunits', publisherOrgUnit)"
                          @update:model-value="handleInput($event, 'organizationPath', 'input-publisher-select')"
                          :items="orgunits"
                          item-value="@id"
                          :item-title="orgunitItemTitle"
                          :loading="loading"
                          :custom-filter="orgunitsAutocompleteFilter"
                          hide-no-data
                          :label="$t('Please choose')"
                          :variant="fieldVariant"
                          return-object
                          clearable
                          :error-messages="publisherOrgUnitErrorMessages"
                          :messages="organizationPath"
                          :bg-color="publisherBackgroundColor ? publisherBackgroundColor : undefined"
                        >
                          <template #item="{ props, internalItem }">
                            <v-divider v-if="internalItem.raw && internalItem.raw.divider" />
                            <v-list-subheader v-else-if="internalItem.raw && internalItem.raw.header != null">
                              {{ internalItem.raw.header }}
                            </v-list-subheader>
                            <v-list-item
                              v-else
                              v-bind="props"
                              :lines="showIds ? 'two' : 'one'"
                            >
                              <template #title>
                                <span v-html="getLocalizedTermLabel('orgunits', internalItem.raw['@id'])" />
                              </template>
                              <template v-if="showIds" #subtitle>
                                <span v-html="internalItem.raw['@id']" />
                              </template>
                            </v-list-item>
                          </template>
                          <template #selection="{ internalItem }">
                            <span v-html="getLocalizedTermLabel('orgunits', (internalItem.raw || internalItem)['@id'])" />
                          </template>
                          <template #append>
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
                          v-model:search="publisherSearchQuery"
                          :error-messages="publisherSearchErrors"
                          @update:model-value="$emit('input-suggest-publisher', $event)"
                          hide-no-data
                          hide-selected
                          return-object
                          item-title="name"
                          item-value="name"
                          :placeholder="$t('search publishers')"
                          :variant="fieldVariant"
                          clearable
                          append-inner-icon="mdi-magnify"
                        >
                          <template #item="{ props, internalItem }">
                            <v-list-item v-bind="props" :lines="internalItem.raw.alias ? 'two' : 'one'">
                              <template #title>{{ internalItem.raw.name }}</template>
                              <template v-if="internalItem.raw.alias" #subtitle>{{ $t('Alias') + ': ' + internalItem.raw.alias }}</template>
                            </v-list-item>
                          </template>
                          <template #selection="{ internalItem }">
                            {{ (internalItem.raw || internalItem).name }}
                          </template>
                        </v-combobox>
                      </v-col>
                      <v-col cols="12" :md="publisherSearch ? 5 : 10">
                        <v-text-field
                          :model-value="publisherName"
                          @update:model-value="$emit('input-publisher-name', $event)"
                          :label="$t(publisherNameLabel ? publisherNameLabel : '')"
                          :variant="fieldVariant"
                          :error-messages="publisherNameErrorMessages"
                          :bg-color="publisherBackgroundColor ? publisherBackgroundColor : undefined"
                        ></v-text-field>
                      </v-col>
                    </template>
                  </v-row>
                  <v-row>
                    <v-col v-if="publisherShowPlace" cols="12" :md="publisherShowDate ? 8 : 12">
                      <v-text-field
                        :model-value="publishingPlace"
                        @update:model-value="$emit('input-publishing-place', $event)"
                        :label="$t(publishingPlaceLabel ? publishingPlaceLabel : '')"
                        :variant="fieldVariant"
                      ></v-text-field>
                    </v-col>
                    <v-col v-if="publisherShowDate" cols="12" :md="publisherShowPlace ? 4 : 12">
                      <template v-if="publishingDatePicker">
                        <v-text-field
                          :model-value="publishingDate"
                          @update:model-value="$emit('input-publishing-date', $event)"
                          :label="$t(publishingDateLabel ? publishingDateLabel : 'Date')"
                          :rules="[validationrules.date]"
                          :variant="fieldVariant"
                          :error-messages="publishingDateErrorMessages"
                        >
                          <template v-slot:append-inner>
                            <v-menu
                              ref="menu1"
                              v-model="publisherDateMenu"
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
                                v-model="publisherPickerModel"
                                :first-day-of-week="1"
                                :locale="alpha2bcp47($i18n.locale)"
                                @update:model-value="publisherDateMenu = false; $emit('input-publishing-date', $event)"
                              ></v-date-picker>
                            </v-menu>
                          </template>
                        </v-text-field>
                      </template>
                      <template v-else>
                        <v-text-field
                          :model-value="publishingDate"
                          @update:model-value="$emit('input-publishing-date', $event)"
                          :label="$t(publishingDateLabel ? publishingDateLabel : 'Date')"
                          :hint="$t(dateFormatHint)"
                          :rules="[validationrules.date]"
                          :variant="fieldVariant"
                        ></v-text-field>
                      </template>
                    </v-col>
                    <org-units-tree-dialog :isParentSelectionDisabled="parentSelectionDisabled" ref="organizationstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event), 'organizationPath', 'input-publisher-select')"></org-units-tree-dialog>
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
import datepickerproperties from '../../mixins/datepickerproperties'
import { fieldproperties } from '../../mixins/fieldproperties'
import { vocabulary } from '../../mixins/vocabulary'
import { validationrules } from '../../mixins/validationrules'
import xmlUtils from '../../utils/xml'
import qs from 'qs'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-contained-in',
  mixins: [fieldproperties, vocabulary, validationrules, datepickerproperties],
  components: {
    OrgUnitsTreeDialog,
    SelectLanguage
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
    hidePages: {
      type: Boolean,
      default: false
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
    },
    isParentSelectionDisabled: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    appconfig: function () {
      return this.$store.state.appconfig
    },
    instanceconfig: function () {
      return this.$store.state.instanceconfig
    },
    parentSelectionDisabled: function () {
      return this.isParentSelectionDisabled || this.instanceconfig?.isParentSelectionDisabled || false
    },
    roleActions: function () {
      var arr = []
      arr.push({ title: this.$t('Remove'), event: 'remove-role' })
      arr.push({ title: this.$t('Duplicate'), event: 'add-role' })
      arr.push({ title: this.$t('Move up'), event: 'up-role' })
      arr.push({ title: this.$t('Move down'), event: 'down-role' })
      return arr
    },
    filteredIdentifierTypes: function () {
      if (this.vocabularies[this.identifierVocabulary] && this.vocabularies[this.identifierVocabulary].terms) {
        return this.vocabularies[this.identifierVocabulary].terms.filter(term => term['@id'] !== 'ids:isbn')
      }
      return []
    },
    orgunits: function () {
      let units = this.vocabularies['orgunits'].terms
      if (this.parentSelectionDisabled) {
        units = units.filter(element => !element.hasChildren)
      }
      return units
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
          let response = await this.$axios.request({
            method: 'GET',
            url: this.appconfig.apis.sherparomeo.url + '?' + query,
            responseType: 'arraybuffer'
          })
          const bytes = response.data instanceof ArrayBuffer ? new Uint8Array(response.data) : new Uint8Array(response.data);
          const utfxml = new TextDecoder('iso-8859-1').decode(bytes)
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
          pathLabels.push(u['skos:prefLabel'][this?.$i18n?.locale || 'eng'])
        }
        this[propName] = pathLabels.join(' > ')
      }
      this.$emit(eventName, unit)
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      if (!this.vocabularies['orgunits'].loaded) {
        this.$store.dispatch('vocabulary/loadOrgUnits', this?.$i18n?.locale || 'eng')
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
