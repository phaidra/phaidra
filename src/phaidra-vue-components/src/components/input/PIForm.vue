<template>
  <v-container fluid v-if="form && form.sections" >
    <v-alert
      v-model="serverSubmitError"
      dismissible
      type="error"
      transition="slide-y-transition"
    >
      <template>
        <ul>
          <li v-for="(error, i) in serverSubmitErrors" :key="'sve' + i"><span>{{ $t(error) }}</span></li>
        </ul>
      </template>
    </v-alert>
    <v-alert
      v-model="validationError"
      dismissible
      type="error"
      transition="slide-y-transition"
    >
      <span>{{ $t("Please fill in the required fields") }}.</span>
      <br />
      <template v-if="fieldsAreMissing(mandatoryFieldsFound)">
        <br />
        <span>{{ $t("Some required fields are missing") }}:</span>
        <ul>
          <li v-for="field in mandatoryFieldsMissing" :key="'mfld' + field"><span>{{ $t(field) }}</span></li>
        </ul>
      </template>
      <template v-if="fieldsNotValidated(mandatoryFieldsValidated)">
        <br />
        <span>{{ $t("Some required fields are not complete") }}:</span>
        <ul>
          <li v-for="field in mandatoryFieldsIncomplete" :key="'mfldf' + field"><span>{{ $t(field) }}</span></li>
        </ul>
      </template>
    </v-alert>
    <v-tabs v-model="activetab" align-with-title>
      <v-tab class="title font-weight-light text-capitalize">{{ $t('Metadata') }}<template v-if="targetpid">&nbsp;-&nbsp;<span class="text-lowercase">{{ targetpid }}</span></template></v-tab>
      <v-tab v-if="debug" @click="metadatapreview = getMetadata()" class="title font-weight-light text-capitalize">{{ $t('JSON-LD') }}</v-tab>
      <v-tab v-if="templating" @click="loadTemplates()" class="title font-weight-light text-capitalize">{{ $t('Templates') }}</v-tab>
      <v-tab v-if="importing" class="title font-weight-light text-capitalize">{{ $t('Import') }}</v-tab>
      <v-tab v-if="enablerights" class="title font-weight-light text-capitalize">{{ $t('Access rights') }}</v-tab>
      <v-tab v-if="enablerelationships" class="title font-weight-light text-capitalize">{{ $t('Relationships') }}</v-tab>
      <v-tab v-if="(submittype !== 'container') && enablepreview" @click="updateJsonld()" class="title font-weight-light text-capitalize">{{ $t('Preview') }}</v-tab>
      <v-tab v-if="help" class="title font-weight-light text-capitalize">{{ $t('Help') }}</v-tab>
      <v-tab v-if="feedback" class="title font-weight-light text-capitalize">{{ $t('Feedback') }}</v-tab>
    </v-tabs>

    <v-tabs-items v-model="activetab">
      <v-tab-item class="pa-3" v-if="form">

        <v-row v-for="(s) in this.form.sections" :key="s.id" class="ma-3">

          <v-card v-if="s.type === 'resourcelink'" width="100%" class="mb-6">
            <v-card-title class="title font-weight-light grey white--text">
              <span>{{s.title}}</span>
              <v-spacer></v-spacer>
            </v-card-title>
            <v-card-text class="mt-4">
              <v-text-field v-model="s.resourcelink"
                :label="$t('URL')"
                :required="true"
                :placeholder="$t('e.g.: https://phaidra.org')"
                :rules="[ v => !!v || 'Required']"
                filled
              ></v-text-field>
            </v-card-text>
          </v-card>

          <v-card :outlined="s.outlined" :flat="(!s.title || (s.mode === 'expansion' && s.collapsed) || s.flat)" v-else-if="(s.type !== 'accessrights')" width="100%">
            <v-card-title v-if="s.title" class="title font-weight-light" :class="{ 'grey white--text': (s.mode !== 'expansion' || !s.collapsed) }">
              <span v-t="s.title"></span>
              <v-spacer></v-spacer>
              <v-checkbox dark color="white" v-if="s.type === 'member'" v-model="previewMember" :label="$t('Container thumbnail')" :value="s.id"></v-checkbox>
              <v-spacer></v-spacer>
              <v-btn :dark="!s.collapsed" icon @click="s.collapsed = !s.collapsed">
                <v-icon>{{ s.collapsed ? 'mdi-chevron-down' : 'mdi-chevron-up' }}</v-icon>
              </v-btn>
              <v-menu open-on-hover bottom offset-y v-if="!s.disablemenu">
                <template v-slot:activator="{ on }">
                  <v-btn v-on="on" icon dark>
                    <v-icon dark>mdi-dots-vertical</v-icon>
                  </v-btn>
                </template>
                <v-list>
                  <v-list-item v-if="s.multiplicable && (s.type === 'member') || (s.type === 'phaidra:Subject')" @click="addSection(s)">
                    <v-list-item-title><span v-t="'Duplicate'"></span></v-list-item-title>
                  </v-list-item>
                  <v-list-item v-if="s.removable && (s.type != 'digitalobject')" @click="removeSection(s)">
                    <v-list-item-title><span v-t="'Remove'"></span></v-list-item-title>
                  </v-list-item>
                  <v-list-item v-if="s.type === 'member'" @click="sortMemberUp(s)">
                    <v-list-item-title><span v-t="'Move up'"></span></v-list-item-title>
                  </v-list-item>
                  <v-list-item v-if="s.type === 'member'" @click="sortMemberDown(s)">
                    <v-list-item-title><span v-t="'Move down'"></span></v-list-item-title>
                  </v-list-item>
                  <v-list-item v-if="s.type === 'digitalobject'" @click="$emit('add-phaidrasubject-section', s)">
                    <v-list-item-title><span v-t="'Add subject metadata section'"></span></v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
            </v-card-title>
            <v-expand-transition>
              <div v-show="!s.collapsed">
                <v-card-text class="mt-4 pb-0">

                  <div v-for="(f) in s.fields" :key="'dv'+f.id">
                    <v-tooltip :disabled="!mouseoverfielddef" open-delay="1700" bottom >
                      <template v-slot:activator="{ on }">
                        <v-row v-on="on" no-gutters>
                          <template v-if="f.component === 'p-text-field'">
                            <p-i-text-field
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:input-language="setSelected(f, 'language', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-text-field>
                          </template>

                          <template v-else-if="f.component === 'p-text-field-suggest'">
                            <p-i-text-field-suggest
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:input-language="setSelected(f, 'language', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-text-field-suggest>
                          </template>

                          <template v-else-if="f.component === 'p-keyword'">
                            <p-i-keyword
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:input-language="setSelected(f, 'language', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-keyword>
                          </template>

                          <template v-if="f.component === 'p-title'">
                            <p-i-title
                              v-bind.sync="f"
                              v-on:input-title="f.title=$event"
                              v-on:input-subtitle="f.subtitle=$event"
                              v-on:input-language="setSelected(f, 'language', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                              v-on:up="sortFieldUp(s.fields, f)"
                              v-on:down="sortFieldDown(s.fields, f)"
                            ></p-i-title>
                          </template>

                          <template v-else-if="f.component === 'p-resource-type-buttongroup'">
                            <p-i-resource-type
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                              v-bind.sync="f"
                              v-on:input="selectInput(f, $event)"
                            ></p-i-resource-type>
                          </template>

                          <template v-else-if="f.component === 'p-object-type-checkboxes'">
                            <p-i-object-type
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                              v-bind.sync="f"
                              v-on:input="handleObjectTypeCheckboxesInput(f, $event)"
                            ></p-i-object-type>
                          </template>

                          <template v-else-if="f.component === 'p-select'">
                            <p-i-select
                              v-bind.sync="f"
                              v-on:input="selectInput(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-select>
                            <v-col cols="12" v-if="(f.predicate === 'edm:rights') && f.showValueDefinition && license">
                              <p-d-license-info :license="license"></p-d-license-info>
                            </v-col>
                          </template>

                          <template v-else-if="f.component === 'p-select-text'">
                            <p-i-select-text
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:input-select="f.selectvalue=$event"
                              v-on:input-text="f.textvalue=$event"
                              v-on:input-language="setSelected(f, 'language', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-select-text>
                          </template>

                          <template v-else-if="f.component === 'p-date-edtf'">
                            <p-i-date-edtf
                              v-bind.sync="f"
                              v-on:input-date="f.value=$event"
                              v-on:input-date-type="setSelected(f, 'type', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-date-edtf>
                          </template>

                          <template v-else-if="f.component === 'p-date-edmtimespan'">
                            <p-i-date-edmtimespan
                              v-bind.sync="f"
                              v-on:input-date="f.value=$event"
                              v-on:input-date-type="setSelected(f, 'type', $event)"
                              v-on:input-language="setSelected(f, 'language', $event)"
                              v-on:input-identifier="f.identifier=$event"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-date-edmtimespan>
                          </template>

                          <template v-else-if="f.component === 'p-duration'">
                            <p-i-duration
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-duration>
                          </template>

                          <template v-else-if="f.component === 'p-series'">
                            <p-i-series
                              v-bind.sync="f"
                              v-on:input-select-journal="selectJournal(f, $event)"
                              v-on:input-title="f.title=$event"
                              v-on:input-title-language="setSelected(f, 'titleLanguage', $event)"
                              v-on:input-volume="f.volume=$event"
                              v-on:input-issue="f.issue=$event"
                              v-on:input-issued="f.issued=$event"
                              v-on:input-issn="f.issn=$event"
                              v-on:input-identifier="f.identifier=$event"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:input-page-start="f.pageStart=$event"
                              v-on:input-page-end="f.pageEnd=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-series>
                          </template>

                          <template v-else-if="f.component === 'p-citation'">
                            <p-i-citation
                              v-bind.sync="f"
                              v-on:input-citation-type="setSelected(f, 'type', $event)"
                              v-on:input-citation="f.citation=$event"
                              v-on:input-citation-language="setSelected(f, 'citationLanguage', $event)"
                              v-on:input-identifier="f.identifier=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-citation>
                          </template>

                          <template v-else-if="f.component === 'p-bf-publication'">
                            <p-i-bf-publication
                              v-bind.sync="f"
                              v-on:input-suggest-publisher="publisherSuggestInput(f, $event)"
                              v-on:input-publisher-name="f.publisherName=$event"
                              v-on:change-type="f.publisherType = $event"
                              v-on:input-publisher-select="publisherSelectInput(f, $event)"
                              v-on:input-publishing-place="f.publishingPlace=$event"
                              v-on:input-publishing-date="f.publishingDate=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-bf-publication>
                          </template>

                          <template v-else-if="f.component === 'p-instance-of'">
                            <p-i-instance-of
                              v-bind.sync="f"
                              v-on:input-title="f.title=$event"
                              v-on:input-subtitle="f.subtitle=$event"
                              v-on:input-title-language="setSelected(f, 'titleLanguage', $event)"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:input-identifier="f.identifierText = $event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-instance-of>
                          </template>

                          <template v-else-if="f.component === 'p-adaptation'">
                            <p-i-adaptation
                              v-bind.sync="f"
                              v-on:input-title="f.title=$event"
                              v-on:input-subtitle="f.subtitle=$event"
                              v-on:input-title-language="setSelected(f, 'titleLanguage', $event)"
                              v-on:input-firstname="f.firstname=$event"
                              v-on:input-lastname="f.lastname=$event"
                              v-on:input-name="f.name=$event"
                              v-on:input-role="roleInput(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-adaptation>
                          </template>

                          <template v-else-if="f.component === 'p-contained-in'">
                            <p-i-contained-in
                              v-bind.sync="f"
                              v-on:input-title="f.title=$event"
                              v-on:input-subtitle="f.subtitle=$event"
                              v-on:input-title-language="setSelected(f, 'titleLanguage', $event)"
                              v-on:input-role="containedInRoleInput(f, $event)"
                              v-on:input-series="containedInSeriesInput(f, $event)"
                              v-on:input-page-start="f.pageStart=$event"
                              v-on:input-page-end="f.pageEnd=$event"
                              v-on:input-isbn="f.isbn=$event"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:input-identifier="f.identifier = $event"
                              v-on:input-suggest-publisher="publisherSuggestInput(f, $event)"
                              v-on:input-publisher-name="f.publisherName=$event"
                              v-on:change-publisher-type="f.publisherType = $event"
                              v-on:input-publisher-select="publisherSelectInput(f, $event)"
                              v-on:input-publishing-place="f.publishingPlace=$event"
                              v-on:input-publishing-date="f.publishingDate=$event"
                              v-on:add-series="addContainedInSeries(f.series, $event)"
                              v-on:add-clear-series="addClearContainedInSeries(f.series, $event)"
                              v-on:remove-series="removeContainedInSeries(f.series, $event)"
                              v-on:add-role="addContainedInRole(f.roles, $event)"
                              v-on:remove-role="removeContainedInRole(f.roles, $event)"
                              v-on:up-role="sortContainedInRoleUp(f.roles, $event)"
                              v-on:down-role="sortContainedInRoleDown(f.roles, $event)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-contained-in>
                          </template>

                          <template v-else-if="f.component === 'p-entity'">
                            <p-i-entity
                              v-bind.sync="f"
                              v-on:input-firstname="f.firstname=$event"
                              v-on:input-lastname="f.lastname=$event"
                              v-on:input-name="f.name=$event"
                              v-on:input-identifier="f.identifierText = $event"
                              v-on:input-organization="f.organizationText=$event"
                              v-on:input-role="roleInput(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                              v-on:up="sortFieldUp(s.fields, f)"
                              v-on:down="sortFieldDown(s.fields, f)"
                              v-on:extend="extendEntity(s.fields, f)"
                            ></p-i-entity>
                          </template>

                          <template v-else-if="f.component === 'p-entity-extended'">
                            <p-i-entity-extended
                              v-bind.sync="f"
                              v-on:change-type="f.type = $event"
                              v-on:input-firstname="f.firstname = $event"
                              v-on:input-lastname="f.lastname = $event"
                              v-on:input-name="f.name = $event"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:input-identifier="f.identifierText = $event"
                              v-on:change-affiliation-type="affiliationTypeChange(f, $event)"
                              v-on:input-affiliation-select="affiliationSelectInput(f, $event)"
                              v-on:input-affiliation-ror="affiliationRorInput(f, $event)"
                              v-on:input-affiliation-other="f.affiliationText = $event"
                              v-on:change-organization-type="organizationTypeChange(f, $event)"
                              v-on:input-organization-select="organizationSelectInput(f, $event)"
                              v-on:input-organization-ror="organizationRorInput(f, $event)"
                              v-on:input-organization-other="f.organizationText = $event"
                              v-on:input-role="roleInput(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:add-clear="addEntityClear(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                              v-on:up="sortFieldUp(s.fields, f)"
                              v-on:down="sortFieldDown(s.fields, f)"
                            ></p-i-entity-extended>
                          </template>

                          <template v-else-if="f.component === 'p-entity-fixedrole-person'">
                            <p-i-entity-fixedrole-person
                              v-bind.sync="f"
                              v-on:input-firstname="f.firstname=$event"
                              v-on:input-lastname="f.lastname=$event"
                              v-on:input-identifier="f.identifierText = $event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                              v-on:up="sortFieldUp(s.fields, f)"
                              v-on:down="sortFieldDown(s.fields, f)"
                            ></p-i-entity-fixedrole-person>
                          </template>

                          <template v-else-if="f.component === 'p-subject-gnd'">
                            <p-i-subject-gnd
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:resolve="updateSubject(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-subject-gnd>
                          </template>

                          <template v-else-if="f.component === 'p-subject-bk'">
                            <p-i-subject-bk
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:resolve="updateSubject(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-subject-bk>
                          </template>

                          <template v-else-if="f.component === 'p-subject-oefos'">
                            <p-i-subject-oefos
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:resolve="updateVocSubject(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-subject-oefos>
                          </template>

                          <template v-else-if="f.component === 'p-subject-thema'">
                            <p-i-subject-thema
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:resolve="updateVocSubject(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-subject-thema>
                          </template>

                          <template v-else-if="f.component === 'p-subject-bic'">
                            <p-i-subject-bic
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:resolve="updateVocSubject(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-subject-bic>
                          </template>

                          <template v-else-if="f.component === 'p-spatial-geonames'">
                            <p-i-spatial-geonames
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:input-place-type="setSelected(f, 'type', $event)"
                              v-on:resolve="updatePlace(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-spatial-geonames>
                          </template>

                          <template v-else-if="f.component === 'p-spatial-text'">
                            <p-i-spatial-text
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:input-place-type="setSelected(f, 'type', $event)"
                              v-on:input-language="setSelected(f, 'language', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-spatial-text>
                          </template>

                          <template v-else-if="f.component === 'p-dimension'">
                            <p-i-dimension
                              v-bind.sync="f"
                              v-on:input-value="f.value=$event"
                              v-on:input-unit="setSelected(f, 'unitCode', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-dimension>
                          </template>

                          <template v-else-if="f.component === 'p-see-also'">
                            <p-i-see-also
                              v-bind.sync="f"
                              v-on:input-url="f.url=$event"
                              v-on:input-title="f.title=$event"
                              v-on:input-title-language="setSelected(f, 'titleLanguage', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-see-also>
                          </template>

                          <template v-else-if="(f.component === 'p-literal') && (f.predicate !== 'schema:pageStart') && (f.predicate !== 'schema:pageEnd')">
                            <p-i-literal
                              v-bind.sync="f"
                              v-on:input-value="f.value=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-literal>
                          </template>

                          <template v-else-if="f.component === 'p-alternate-identifier'">
                            <p-i-alternate-identifier
                              v-bind.sync="f"
                              v-on:input-identifier="f.value=$event"
                              v-on:input-identifier-type="setSelected(f, 'type', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                              class="my-2"
                            ></p-i-alternate-identifier>
                          </template>

                          <template v-else-if="f.component === 'p-study-plan'">
                            <p-i-study-plan
                              v-bind.sync="f"
                              v-on:input-identifier="f.identifier=$event"
                              v-on:input-name="f.name=$event"
                              v-on:input-name-language="setSelected(f, 'nameLanguage', $event)"
                              v-on:input-notation="f.notation=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-study-plan>
                          </template>

                          <template v-else-if="f.component === 'p-event'">
                            <p-i-event
                              v-bind.sync="f"
                              v-on:input-name="f.name=$event"
                              v-on:input-name-language="setSelected(f, 'nameLanguage', $event)"
                              v-on:input-description="f.description=$event"
                              v-on:input-description-language="setSelected(f, 'descriptionLanguage', $event)"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:input-identifier="f.identifierText = $event"
                              v-on:input-date-from="f.dateFrom=$event"
                              v-on:input-date-to="f.dateTo=$event"
                              v-on:input-place="f.place=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-event>
                          </template>

                          <template v-else-if="f.component === 'p-project'">
                            <p-i-project
                              v-bind.sync="f"
                              v-on:input-name="f.name=$event"
                              v-on:input-acronym="f.acronym=$event"
                              v-on:input-name-language="setSelected(f, 'nameLanguage', $event)"
                              v-on:input-funder-name="f.funderName=$event"
                              v-on:input-funder-name-language="setSelected(f, 'funderNameLanguage', $event)"
                              v-on:input-description="f.description=$event"
                              v-on:input-description-language="setSelected(f, 'descriptionLanguage', $event)"
                              v-on:input-code="f.code=$event"
                              v-on:input-identifier="f.identifier=$event"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:input-funder-identifier="f.funderIdentifier=$event"
                              v-on:input-funder-identifier-type="setSelected(f, 'funderIdentifierType', $event)"
                              v-on:input-homepage="f.homepage=$event"
                              v-on:input-date-from="f.dateFrom=$event"
                              v-on:input-date-to="f.dateTo=$event"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-project>
                          </template>

                          <template v-else-if="f.component === 'p-funder'">
                            <p-i-funder
                              v-bind.sync="f"
                              v-on:input-name="f.name=$event"
                              v-on:input-name-language="setSelected(f, 'nameLanguage', $event)"
                              v-on:input-identifier="f.identifier=$event"
                              v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-funder>
                          </template>

                          <template v-else-if="f.component === 'p-association'">
                            <p-i-association
                              v-bind.sync="f"
                              v-on:input="selectInput(f, $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-association>
                          </template>

                          <template v-else-if="f.component === 'p-filename'">
                            <p-i-filename
                              v-bind.sync="f"
                              v-on:input-value="f.value=$event"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-filename>
                          </template>

                          <template v-else-if="f.component === 'p-filename-readonly'">
                            <p-i-filename-readonly v-bind.sync="f" v-on:configure="editFieldProps(f)" :configurable="enablefieldconfig || f.configurable"></p-i-filename-readonly>
                          </template>

                          <template v-else-if="f.component === 'p-unknown'">
                            <p-i-unknown
                              v-bind.sync="f"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-unknown>
                          </template>

                          <template v-else-if="f.component === 'p-vocab-ext-readonly'">
                            <p-i-vocab-ext-readonly
                              v-bind.sync="f"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-vocab-ext-readonly>
                          </template>

                          <template v-else-if="f.component === 'p-spatial-readonly'">
                            <p-i-spatial-readonly
                              v-bind.sync="f"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-spatial-readonly>
                          </template>

                          <template v-else-if="f.component === 'p-file'">
                            <p-i-file
                              v-bind.sync="f"
                              v-on:input-file="setFilename(f, $event)"
                              v-on:input-mimetype="setSelected(f, 'mimetype', $event)"
                              v-on:add="addField(s.fields, f)"
                              v-on:remove="removeField(s.fields, f)"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-file>
                          </template>

                          <template v-if="f.component === 'p-note-checkbox'">
                            <p-i-note-checkbox
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-note-checkbox>
                          </template>

                          <template v-if="f.component === 'p-note-checkbox-with-link'">
                            <p-i-note-checkbox-with-link
                              v-bind.sync="f"
                              v-on:input="f.value=$event"
                              v-on:configure="editFieldProps(f)"
                              :configurable="enablefieldconfig || f.configurable"
                            ></p-i-note-checkbox-with-link>
                          </template>

                          <template v-if="f.component === 'p-alert'">
                            <p-i-alert
                              v-bind.sync="f"
                            ></p-i-alert>
                          </template>

                        </v-row>
                      </template>
                      <span>{{ $t(f.helptext ? f.helptext : f.definition)}}</span>
                    </v-tooltip>
                  </div>

                  <v-row no-gutters>
                    <v-col>
                      <v-dialog v-if="addbutton && (s.addbutton != false)" class="pb-4" v-model="s['adddialogue']" scrollable width="700px">
                        <template v-slot:activator="{ on }">
                          <v-btn v-on="on" color="grey" dark large elevation="4" class="mb-4 font-weight-black">
                            {{ $t('Add metadatafield') }}<v-icon class="ml-4" color="white" size="24" right dark>mdi-plus-circle</v-icon>
                          </v-btn>
                        </template>
                        <v-card>
                          <v-card-title class="grey white--text"><span v-t="'Add metadata fields'"></span><v-spacer></v-spacer><v-btn target='_blank' :to="'/metadata-fields-help'">{{ $t('Help') }}</v-btn></v-card-title>
                          <v-card-text>
                            <v-list three-line >
                              <v-text-field clearable :label="$t('Search...')" append-icon="mdi-magnify" v-model="searchfieldsinput"></v-text-field>
                              <div v-for="field in filteredMetadatafields" :key="field.id">
                                <v-list-item @click="addfieldselection.push(field)">
                                  <v-list-item-content>
                                    <v-list-item-title>{{ $t(field.fieldname) }}</v-list-item-title>
                                    <v-list-item-subtitle>{{ $t(field.helptext ? field.helptext : field.definition) }}</v-list-item-subtitle>
                                  </v-list-item-content>
                                </v-list-item>
                                <v-divider :key="'divi'+field.id"></v-divider>
                              </div>
                            </v-list>
                          </v-card-text>
                          <v-divider :key="'divi'+s.id"></v-divider>
                          <v-card-actions>
                            <v-container fluid>
                              <v-row>
                                <v-col v-if="addfieldselection.length > 0">
                                  <span v-t="'Selected fields:'" class="mr-2"></span> <v-chip class="mx-1" :key="'addflds'+index" v-for="(ch, index) in addfieldselection" close @click:close="removeField(addfieldselection, ch)">{{ ch.fieldname }}</v-chip>
                                </v-col>
                                <v-col v-else><span v-t="'Please select metadata fields from the list'"></span></v-col>
                              </v-row>
                              <v-row justify="end">
                                <v-btn class="mx-1" color="grey" dark @click="addfieldselection = []; s['adddialogue'] = false"><span v-t="'Cancel'"></span></v-btn>
                                <v-btn class="mx-1" color="primary" @click="addFields(s)"><span v-t="'Add'"></span></v-btn>
                              </v-row>
                            </v-container>
                          </v-card-actions>
                        </v-card>

                      </v-dialog>
                    </v-col>
                  </v-row>
                </v-card-text>
              </div>
            </v-expand-transition>
          </v-card>
        </v-row>

        <v-row class="mx-4" v-if="uploadProgress">
          <v-col cols="12">
            <v-row no-gutters>
              <v-progress-linear :indeterminate="uploadProgress === 100" v-model="uploadProgress" color="primary"></v-progress-linear>
            </v-row>
            <v-row no-gutters class="primary--text mt-1">
              <span v-if="uploadProgress < 100">{{ $t('Uploading...') + ' ' + Math.ceil(uploadProgress) }}%</span>
              <span v-else>{{ $t('Processing...') }}</span>
            </v-row>
          </v-col>
        </v-row>

        <v-row class="mt-4 mx-4">
          <v-col cols="12">
            <v-dialog v-if="templating || savetemplatebtn" v-model="templatedialog" width="500">
              <template v-slot:activator="{ on }">
                <v-btn class="mr-3 float-left" v-on="on" dark raised :loading="loading" :disabled="loading" color="grey"><span v-t="'Save as new template'"></span></v-btn>
              </template>
              <v-card>
                <v-card-title class="title font-weight-light grey lighten-2" primary-title><span v-t="'Save as new template'"></span></v-card-title>
                <v-card-text>
                  <v-text-field class="mt-4" hide-details filled single-line v-model="templatename" :label="$t('Template name')" ></v-text-field>
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn :loading="loading" :disabled="loading" color="grey" dark @click="templatedialog= false"><span v-t="'Cancel'"></span></v-btn>
                  <v-btn :loading="loading" :disabled="loading" color="primary" @click="saveAsNewTemplate()"><span v-t="'Save'"></span></v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
            <v-btn v-if="templating && $route.params.templateid" class="mr-3 float-left" dark raised :loading="loading" :disabled="loading" color="grey" @click="saveTemplate()"><span v-t="'Save template'"></span></v-btn>
            <v-spacer></v-spacer>
            <template v-if="!disablesave">
              <v-btn fixed bottom right v-if="targetpid && floatingsavebutton" raised :loading="loading" :disabled="loading" color="primary" @click="save()"><span v-t="'Save'"></span></v-btn>
              <v-btn v-else-if="targetpid && !floatingsavebutton" raised :loading="loading" :disabled="loading" class="primary float-right" @click="save()"><span v-t="'Save'"></span></v-btn>
              <v-btn v-else raised :loading="loading" :disabled="loading" class="primary float-right" @click="submit()"><span v-t="'Upload'"></span></v-btn>
            </template>
          </v-col>
        </v-row>

      </v-tab-item>
      <v-tab-item v-if="debug" class="pa-3">
        <div style="white-space: pre;">{{ JSON.stringify(metadatapreview, null, 2) }}</div>
      </v-tab-item>
      <v-tab-item v-if="templating" class="ma-4">
        <p-templates ref="templates" v-on:load-template="loadTemplate($event)"></p-templates>
      </v-tab-item>
      <v-tab-item  v-if="importing">
        <v-row no-gutters>
          <v-col cols="12">
            <object-from-search :title="$t('Import metadata from existing object')" v-on:object-selected="importFromObject($event)" :jsonld-only="true"></object-from-search>
          </v-col>
        </v-row>
      </v-tab-item>
      <v-tab-item v-if="enablerights && !targetpid">
        <v-row no-gutters>
          <v-col cols="12">
            <p-m-rights 
              :show-persons="instanceconfig.accessrestrictions_showpersons"
              :show-accounts="instanceconfig.accessrestrictions_showaccounts"
              :show-edu-person-affiliation="instanceconfig.accessrestrictions_showedupersonaffiliation"
              :show-org-units="instanceconfig.accessrestrictions_showorgunits"
              :show-groups="instanceconfig.accessrestrictions_showgroups"
              v-on:input-rights="$emit('input-rights', $event)" 
              :rights="rights"
             ></p-m-rights>
          </v-col>
        </v-row>
      </v-tab-item>
      <v-tab-item v-if="enablerelationships && !targetpid">
        <v-row no-gutters>
          <v-col cols="12">
            <p-m-relationships v-on:remove-relationship="$emit('remove-relationship', $event)" v-on:add-relationship="$emit('add-relationship', $event)" :relationships="relationships" ></p-m-relationships>
          </v-col>
        </v-row>
      </v-tab-item>
      <v-tab-item v-if="(submittype !== 'container') && enablepreview" class="pa-3">
        <p-d-jsonld :jsonld="jsonld"></p-d-jsonld>
      </v-tab-item>
      <v-tab-item v-if="help" class="pa-3">
        <p-help></p-help>
      </v-tab-item>
      <v-tab-item v-if="feedback" class="pa-3">
        <p-feedback :firstname="feedbackUser.firstname" :lastname="feedbackUser.lastname" :email="feedbackUser.email" :context="feedbackContext"></p-feedback>
      </v-tab-item>
    </v-tabs-items>
    <v-dialog v-model="showEditFieldPopup" max-width="600px" scrollable>
      <v-card>
        <v-card-title>
          <span class="text-h5">Field Settings</span>
        </v-card-title>
        <v-card-text>
          <v-container>
            <v-row v-for="(fieldProp, index) in fieldPropForm" :key="index">
              <v-col cols="12">
                <v-text-field v-if="fieldProp.fieldType === 'text'" :label="fieldProp.fieldKey" v-model="fieldProp.fieldValue" ></v-text-field>
                <v-checkbox v-if="fieldProp.fieldType === 'boolean'" :label="fieldProp.fieldKey" v-model="fieldProp.fieldValue"></v-checkbox>
              </v-col>
            </v-row>
          </v-container>
          <small>*indicates required field</small>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn @click="showEditFieldPopup = false">
            Close
          </v-btn>
          <v-btn color="primary" @click="saveFieldProp()">
            Save
          </v-btn>
        </v-card-actions>
      </v-card>
</v-dialog>

  </v-container>

</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { formvalidation } from '../../mixins/formvalidation'
import arrays from '../../utils/arrays'
import jsonLd from '../../utils/json-ld'
import fields from '../../utils/fields'
import PITextField from './PITextField'
import PITextFieldSuggest from './PITextFieldSuggest'
import PITitle from './PITitle'
import PIEntity from './PIEntity'
import PIEntityExtended from './PIEntityExtended'
import PIDateEdtf from './PIDateEdtf'
import PISelect from './PISelect'
import PISelectText from './PISelectText'
import PISubjectGnd from './PISubjectGnd'
import PISubjectBk from './PISubjectBk'
import PISubjectOefos from './PISubjectOefos'
import PISpatialGeonames from './PISpatialGeonames'
import PISpatialText from './PISpatialText'
import PIDimension from './PIDimension'
import PIDuration from './PIDuration'
import PIProject from './PIProject'
import PIEvent from './PIEvent'
import PIFunder from './PIFunder'
import PIAssociation from './PIAssociation'
import PISeries from './PISeries'
import PIContainedIn from './PIContainedIn'
import PICitation from './PICitation'
import PIBfPublication from './PIBfPublication'
import PIInstanceOf from './PIInstanceOf'
import PIAdaptation from './PIAdaptation'
import PIFilenameReadonly from './PIFilenameReadonly'
import PIFilename from './PIFilename'
import PIFile from './PIFile'
import PISpatialReadonly from './PISpatialReadonly'
import PIVocabExtReadonly from './PIVocabExtReadonly'
import PIUnknown from './PIUnknown'
import PILiteral from './PILiteral'
import PIStudyPlan from './PIStudyPlan'
import PIKeyword from './PIKeyword'
import PISeeAlso from './PISeeAlso'
import PTemplates from '../templates/PTemplates'
import ObjectFromSearch from '../select/ObjectFromSearch'
import PMRights from '../management/PMRights'
import PDLicenseInfo from '../utils/PDLicenseInfo'
import PIObjectType from './PIObjectType'
import PIResourceType from './PIResourceType'
import PIAlert from './PIAlert'
import PFeedback from '../utils/PFeedback'
import PHelp from '../info/PHelp'

export default {
  name: 'p-i-form',
  mixins: [ vocabulary, formvalidation ],
  components: {
    PITextField,
    PITextFieldSuggest,
    PITitle,
    PIEntity,
    PIEntityExtended,
    PIDateEdtf,
    PISelect,
    PISelectText,
    PISubjectGnd,
    PISubjectBk,
    PISubjectOefos,
    PISpatialGeonames,
    PISpatialText,
    PIDimension,
    PIDuration,
    PIStudyPlan,
    PIProject,
    PIEvent,
    PIFunder,
    PIAssociation,
    PISeries,
    PIContainedIn,
    PICitation,
    PIBfPublication,
    PIInstanceOf,
    PIAdaptation,
    PILiteral,
    PIKeyword,
    PIFilenameReadonly,
    PIFilename,
    PIFile,
    PIVocabExtReadonly,
    PISpatialReadonly,
    PISeeAlso,
    PIUnknown,
    PTemplates,
    PIAlert,
    ObjectFromSearch,
    PMRights,
    PDLicenseInfo,
    PIObjectType,
    PIResourceType,
    PFeedback,
    PHelp
  },
  props: {
    form: {
      type: Object
    },
    targetpid: {
      type: String
    },
    owner: {
      // if defined, phaidra will transfer ownership to this user
      // IIF the current user is authorized to do so in phaidra-api
      type: String
    },
    rights: {
      type: Object
    },
    relationships: {
      type: Object
    },
    foreignRelationships: {
      type: Object
    },
    addbutton: {
      type: Boolean,
      default: true
    },
    mouseoverfielddef: {
      type: Boolean,
      default: false
    },
    templating: {
      type: Boolean,
      default: true
    },
    savetemplatebtn: {
      type: Boolean,
      default: true
    },
    importing: {
      type: Boolean,
      default: true
    },
    debug: {
      type: Boolean,
      default: false
    },
    enablerights: {
      type: Boolean,
      default: false
    },
    enablerelationships: {
      type: Boolean,
      default: false
    },
    enablepreview: {
      type: Boolean,
      default: false
    },
    enablefieldconfig: {
      type: Boolean,
      default: false
    },
    floatingsavebutton: {
      type: Boolean,
      default: false
    },
    disablesave: {
      type: Boolean,
      default: false
    },
    validationfnc: {
      type: Function
    },
    help: {
      type: Boolean,
      default: false
    },
    feedback: {
      type: Boolean,
      default: false
    },
    feedbackUser: {
      type: Object
    },
    feedbackContext: {
      type: String
    },
    guidelinesUrl: {
      type: String
    }
  },
  watch: {
    form: {
      handler: function (val) {
        this.license = null
        if (!this.initialized) {
          this.initialize()
          this.initialized = true
        }
      },
      deep: true
    }
  },
  computed: {
    submittype: function () {
      let resourcetype
      for (let s of this.form.sections) {
        if (s.fields && (s.type !== 'member')) {
          for (let field of s.fields) {
            if (field.predicate === 'dcterms:type') {
              resourcetype = field.value
            }
          }
        }
      }
      return this.getSubmitType(resourcetype)
    },
    filteredMetadatafields () {
      if (this.searchfieldsinput) {
        return this.$store.state.vocabulary.fields.filter(f => (this.$t(f.fieldname).toLowerCase().includes(this.searchfieldsinput.toLowerCase()) || (this.$t(f.definition).toLowerCase().includes(this.searchfieldsinput.toLowerCase()))))
      } else {
        return this.$store.state.vocabulary.fields
      }
    },
    instanceconfig: function () {
      return this.$root.$store.state.instanceconfig
    }
  },
  data () {
    return {
      activetab: null,
      loadedMetadata: [],
      loading: false,
      fab: false,
      addfieldselection: [],
      templatedialog: '',
      templatename: '',
      previewMember: '',
      searchfieldsinput: '',
      metadatapreview: {},
      license: null,
      uploadProgress: 0,
      jsonld: {},
      showEditFieldPopup: false,
      selectedFieldForEdit: null,
      fieldPropForm: [],
      initonly: false,
      serverSubmitError: false,
      serverSubmitErrors: []
    }
  },
  methods: {
    initialize: function () {
      if (!this.$route.params.templateid) {
        if (this.instanceconfig.markmandatoryfnc) {
          this[this.instanceconfig.markmandatoryfnc]()
        } else {
          this.markMandatory()
        }
      }
    },
    editFieldProps: function(fieldDet) {
      this.fieldPropForm = []
      this.selectedFieldForEdit = fieldDet
      for (const fieldKey in this.selectedFieldForEdit) {
        if (Object.hasOwnProperty.call(this.selectedFieldForEdit, fieldKey)) {
          const value = this.selectedFieldForEdit[fieldKey];
          if(typeof(value) === "string"){
            this.fieldPropForm.push({
              fieldType: 'text',
              fieldKey,
              fieldValue: value,
            })
          } 
          else if(typeof(value) === "boolean"){
            this.fieldPropForm.push({
              fieldType: 'boolean',
              fieldKey,
              fieldValue: value,
            })
          }
        }
      }
      this.showEditFieldPopup = true
    },
    saveFieldProp: function() {
      this.showEditFieldPopup = false
      this.fieldPropForm.forEach(element => {
        this.selectedFieldForEdit[element.fieldKey] = element.fieldValue
      });
    },
    importFromObject: async function (doc) {
      this.loading = true
      try {
        let response = await this.$axios.request('/object/' + doc.pid + '/jsonld', {
          method: 'GET',
          mode: 'cors'
        })
        let json = await response.data
        let form = jsonLd.json2form(json, null, this.vocabularies)
        for (let s of form.sections) {
          let isFileSection = false
          for (let f of s.fields) {
            if (f.predicate === 'ebucore:filename') {
              isFileSection = true
              break
            }
          }
          if (isFileSection) {
            let newFields = []
            for (let f of s.fields) {
              if ((f.predicate !== 'ebucore:filename') && (f.predicate !== 'ebucore:hasMimeType')) {
                newFields.push(f)
              }
            }
            s.fields = newFields
            newFields.push(fields.getField('file'))
          }
        }
        this.$emit('load-form', form)
        this.activetab = 0
      } catch (error) {
        console.error(error)
      } finally {
        this.loading = false
      }
    },
    updateJsonld: function () {
      this.jsonld = jsonLd.form2json(this.form)
    },
    getMetadata: function () {
      let jsonlds
      if (!this.targetpid && (this.submittype === 'container')) {
        jsonlds = jsonLd.containerForm2json(this.form)
      } else {
        jsonlds = jsonLd.form2json(this.form)
      }
      let md = { metadata: { 'json-ld': jsonlds } }
      let colorder = []
      let i = 0
      for (let s of this.form.sections) {
        if (s.type === 'member') {
          i++
          colorder.push({ member: 'member_' + s.id, pos: i })
        }
        if (s.type === 'accessrights') {
          md['metadata']['rights'] = s.rights
        }
        if (s.type === 'resourcelink') {
          md['metadata']['resourcelink'] = s.resourcelink
        }
      }
      if (colorder.length > 0) {
        md['metadata']['membersorder'] = colorder
      }
      if (this.foreignRelationships) {
        Object.entries(this.foreignRelationships).forEach(([relation, pids]) => {
          let predicate
          for (let rel of this.vocabularies['relations'].terms) {
            for (let notation of rel['skos:notation']) {
              if (notation.toLowerCase() === relation) {
                predicate = rel['@id']
              }
              break
            }
          }
          if (Array.isArray(pids)) {
            for (let pid of pids) {
              let rel = { s: pid, p: predicate, o: 'self' }
              if (md['metadata'].hasOwnProperty('relationships')) {
                if (Array.isArray(md['metadata']['relationships'])) {
                  md['metadata']['relationships'].push({ rel })
                }
              } else {
                md['metadata']['relationships'] = [ rel ]
              }
            }
          }
        })
      }
      if (this.relationships) {
        Object.entries(this.relationships).forEach(([relation, pids]) => {
          let predicate
          for (let rel of this.vocabularies['relations'].terms) {
            for (let notation of rel['skos:notation']) {
              if (notation.toLowerCase() === relation) {
                predicate = rel['@id']
              }
              break
            }
          }
          if (Array.isArray(pids)) {
            for (let pid of pids) {
              let rel = { s: 'self', p: predicate, o: pid }
              if (md['metadata'].hasOwnProperty('relationships')) {
                if (Array.isArray(md['metadata']['relationships'])) {
                  md['metadata']['relationships'].push({ rel })
                }
              } else {
                md['metadata']['relationships'] = [ rel ]
              }
            }
          }
        })
      }
      if (this.previewMember) {
        let rel = { s: 'member_' + this.previewMember, p: 'http://phaidra.org/XML/V1.0/relations#isThumbnailFor', o: 'self' }
        if (md['metadata'].hasOwnProperty('relationships')) {
          if (Array.isArray(md['metadata']['relationships'])) {
            md['metadata']['relationships'].push(rel)
          }
        } else {
          md['metadata']['relationships'] = [ rel ]
        }
      }
      if (this.owner) {
        md['metadata']['ownerid'] = this.owner
      }
      if (this.rights) {
        if (Object.keys(this.rights).length > 0) {
          md['metadata']['rights'] = this.rights
        }
      }
      return md
    },
    loadTemplates: function () {
      if (this.$refs.templates) {
        this.$refs.templates.loadTemplates()
      }
    },
    loadTemplate: function (template) {
      this.$emit('load-form', template.form)
      this.$emit('load-rights', template.rights)
      this.activetab = 0
    },
    prepareTemplateForSave: function (form) {
      let clone = JSON.parse(JSON.stringify(form))
      for (let s of clone.sections) {
        for (let f of s.fields) {
          if (f.predicate === 'ebucore:filename') {
            f.value = null
            f.file = null
            f.mimetype = ''
          }
        }
      }
      return clone
    },
    saveAsNewTemplate: async function () {
      let template = this.prepareTemplateForSave(this.form)
      var httpFormData = new FormData()
      this.loading = true
      httpFormData.append('name', this.templatename)
      if (this.rights) {
        if (Object.keys(this.rights).length > 0) {
          httpFormData.append('rights', JSON.stringify(this.rights))
        }
      }
      httpFormData.append('form', JSON.stringify(template))
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/jsonld/template/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        this.loading = false
        this.templatedialog = false
      }
    },
    saveTemplate: async function () {
      let template = this.prepareTemplateForSave(this.form)
      var httpFormData = new FormData()
      this.loading = true
      httpFormData.append('rights', JSON.stringify(this.rights))
      httpFormData.append('form', JSON.stringify(template))
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/jsonld/template/' + this.$route.params.templateid + '/edit',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        } else {
          this.$store.commit('setAlerts', [{ type: 'success', msg: this.$t('Template saved') }])
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        this.loading = false
        this.templatedialog = false
      }
    },
    getSubmitType: function (resourcetype) {
      switch (resourcetype) {
        case 'https://pid.phaidra.org/vocabulary/44TN-P1S0':
          return 'picture'
        case 'https://pid.phaidra.org/vocabulary/8YB5-1M0J':
          return 'audio'
        case 'https://pid.phaidra.org/vocabulary/B0Y6-GYT8':
          return 'video'
        case 'https://pid.phaidra.org/vocabulary/69ZZ-2KGX':
          return 'document'
        case 'https://pid.phaidra.org/vocabulary/8MY0-BQDQ':
          return 'container'
        case 'https://pid.phaidra.org/vocabulary/T8GH-F4V8':
          return 'resource'
        case 'https://pid.phaidra.org/vocabulary/GXS7-ENXJ':
          return 'collection'
        default:
          return 'unknown'
      }
    },
    formIsValid: function () {
      if (this.validationfnc instanceof Function) {
        console.log('passed validationfnc')
        return this.validationfnc(this.targetpid)
      } else {
        if (this.instanceconfig.validationfnc) {
          console.log('configured validation: ' + this.instanceconfig.validationfnc)
          return this[this.instanceconfig.validationfnc](this.targetpid)
        } else {
          console.log('default validation')
          return this.defaultValidation(this.targetpid)
        }
      }
    },
    submit: async function () {
      this.serverSubmitError = false
      this.serverSubmitErrors = []
      if (!this.formIsValid()) {
        this.validationError = true
        return
      }
      this.loading = true
      var httpFormData = new FormData()

      let mime = null
      switch (this.submittype) {
        case 'container':
          for (let s of this.form.sections) {
            if (s.type === 'member') {
              for (let field of s.fields) {
                if (field.component === 'p-file') {
                  if (field.file !== '') {
                    httpFormData.append('member_' + s.id, field.file)
                  }
                  if (field.mimetype) {
                    mime = field.mimetype
                  }
                }
              }
            }
          }
          break

        default:
          for (let s of this.form.sections) {
            if (s.fields) {
              for (let field of s.fields) {
                if (field.component === 'p-file') {
                  if (field.file !== '') {
                    httpFormData.append('file', field.file)
                  }
                  if (field.mimetype) {
                    mime = field.mimetype
                  }
                }
              }
            }
          }
          break
      }

      httpFormData.append('metadata', JSON.stringify(this.getMetadata()))
      if (mime) {
        httpFormData.append('mimetype', mime)
      }

      let self = this
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/' + this.submittype + '/create',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData,
          onUploadProgress: function (progressEvent) {
            self.uploadProgress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.status === 200) {
          if (response.data.pid) {
            this.$emit('object-created', response.data.pid)
          }
        }
      } catch (error) {
        console.log(error)
        if (error.response && error.response.data.alerts && error.response.data.alerts.length > 0) {
          // amore readable formatting of server errors
          this.serverSubmitError = true
          for (let e of error.response.data.alerts) {
            this.serverSubmitErrors.push(e.msg)
          }
          // remove the alerts eventually set in axios hook
          this.$store.commit('setAlerts', [])
        } else {
          this.$store.commit('setAlerts', [{ type: 'error', msg: error }])
        }
      } finally {
        this.$vuetify.goTo(0)
        this.loading = false
        this.uploadProgress = 0
      }
    },
    save: async function () {
      if (!this.formIsValid()) {
        this.validationError = true
        return
      }
      this.loading = true
      var httpFormData = new FormData()
      httpFormData.append('metadata', JSON.stringify(this.getMetadata()))
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/object/' + this.targetpid + '/metadata',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          if (response.data.status === 401) {
            response.data.alerts.push({ type: 'error', msg: 'Please log in' })
          }
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.status === 200) {
          this.$emit('object-saved', this.targetpid)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        this.$vuetify.goTo(0)
        this.loading = false
      }
    },
    addField: function (arr, f) {
      var newField = arrays.duplicate(arr, f)
      if (newField) {
        newField.id = (new Date()).getTime()
        newField.firstname = ''
        newField.lastname = ''
        newField.identifierText = ''
        newField.removable = true
      }
    },
    addEntityClear: function (arr, f) {
      var newField = arrays.duplicate(arr, f)
      if (newField) {
        newField.id = (new Date()).getTime()
        newField.role = ''
        newField.name = ''
        newField.firstname = ''
        newField.lastname = ''
        newField.identifierText = ''
        newField.affiliation = ''
        newField.affiliationText = ''
        newField.affiliationType = 'select'
        newField.organization = ''
        newField.organizationText = ''
        newField.organizationType = 'select'
        newField.type = 'schema:Person'
        newField.removable = true
      }
    },
    extendEntity: function (arr, f) {
      let newRole = fields.getField('role-extended')
      newRole.identifierType = 'ids:orcid'
      newRole.firstname = f.firstname
      newRole.lastname = f.lastname
      newRole.role = f.role
      arr.splice(arr.indexOf(f), 1, newRole)
    },
    removeField: function (arr, f) {
      arrays.remove(arr, f)
    },
    sortFieldUp: function (arr, f) {
      var i = arr.indexOf(f)
      if (arr[i - 1]) {
        if (arr[i - 1].ordergroup === f.ordergroup) {
          arrays.moveUp(arr, f)
        }
      }
    },
    sortFieldDown: function (arr, f) {
      var i = arr.indexOf(f)
      if (arr[i + 1]) {
        if (arr[i + 1].ordergroup === f.ordergroup) {
          arrays.moveDown(arr, f)
        }
      }
    },
    addSeriesClear: function (arr, f) {
      var newField = arrays.duplicate(arr, f)
      if (newField) {
        newField.id = (new Date()).getTime()
        newField.title = ''
        newField.volume = ''
        newField.issue = ''
        newField.issued = ''
        newField.issn = ''
        newField.identifier = ''
        newField.pageStart = ''
        newField.pageEnd = ''
        newField.removable = true
      }
    },
    addContainedInRole: function (arr, f) {
      var newField = arrays.duplicate(arr, f)
      if (newField) {
        newField.id = (new Date()).getTime()
        newField.removable = true
      }
    },
    removeContainedInRole: function (arr, f) {
      if (arr.length > 1) {
        arrays.remove(arr, f)
      }
    },
    addContainedInSeries: function (arr, f) {
      var newField = arrays.duplicate(arr, f)
      if (newField) {
        newField.id = (new Date()).getTime()
        newField.removable = true
      }
    },
    addClearContainedInSeries: function (arr, f) {
      var newField = arrays.duplicate(arr, f)
      if (newField) {
        newField.id = (new Date()).getTime()
        newField.seriesTitle = ''
        newField.seriesVolume = ''
        newField.seriesIssue = ''
        newField.seriesIssued = ''
        newField.seriesIssn = ''
        newField.seriesIdentifier = ''
        newField.removable = true
      }
    },
    removeContainedInSeries: function (arr, f) {
      if (arr.length > 1) {
        arrays.remove(arr, f)
      }
    },
    sortContainedInRoleUp: function (arr, f) {
      var i = arr.indexOf(f)
      if (arr[i - 1]) {
        if (arr[i - 1].ordergroup === f.ordergroup) {
          arrays.moveUp(arr, f)
        }
      }
    },
    sortContainedInRoleDown: function (arr, f) {
      var i = arr.indexOf(f)
      if (arr[i + 1]) {
        if (arr[i + 1].ordergroup === f.ordergroup) {
          arrays.moveDown(arr, f)
        }
      }
    },
    sortMemberUp: function (s) {
      var i = this.form.sections.indexOf(s)
      if (this.form.sections[i - 1]) {
        if (this.form.sections[i - 1].type === 'member') {
          arrays.moveUp(this.form.sections, s)
        }
      }
    },
    sortMemberDown: function (s) {
      var i = this.form.sections.indexOf(s)
      if (this.form.sections[i + 1]) {
        if (this.form.sections[i + 1].type === 'member') {
          arrays.moveDown(this.form.sections, s)
        }
      }
    },
    addSection: function (s) {
      var ns = arrays.duplicate(this.form.sections, s)
      ns.id = (new Date()).getTime()
      ns.removable = true
      for (var i = 0; i < ns.fields.length; i++) {
        var id = (new Date()).getTime()
        if (i > 0) {
          id = ns.fields[i - 1].id + 1
        }
        ns.fields[i].id = id
        ns.fields[i].value = ''
        ns.fields[i].language = ''
      }
    },
    removeSection: function (s) {
      arrays.remove(this.form.sections, s)
    },
    selectJournal: function (f, event) {
      if (event.title) {
        f.title = event.title
      }
      if (event.issn) {
        f.issn = event.issn
      }
    },
    affiliationSelectInput: function (f, event) {
      f.affiliation = ''
      f.affiliationSelectedName = []
      if (event) {
        f.affiliation = event['@id']
        var preflabels = event['skos:prefLabel']
        Object.entries(preflabels).forEach(([key, value]) => {
          f.affiliationSelectedName.push({ '@value': value, '@language': key })
        })
      }
    },
    affiliationRorInput: function (f, event) {
      f.affiliation = ''
      f.affiliationSelectedName = []
      if (event) {
        for (const id of event['skos:exactMatch']) {
          f.affiliation = id
        }
        f.affiliationSelectedName = event['schema:name']
      }
    },
    affiliationTypeChange: function (f, event) {
      switch (event) {
        case 'select':
        case 'ror':
          f.affiliationType = 'select'
          break
        case 'other':
          f.affiliationType = 'other'
          break
      }
    },
    publisherSelectInput: function (f, event) {
      f.publisherOrgUnit = ''
      f.publisherSelectedName = []
      if (event) {
        f.publisherOrgUnit = event['@id']
        var preflabels = event['skos:prefLabel']
        Object.entries(preflabels).forEach(([key, value]) => {
          f.publisherSelectedName.push({ '@value': value, '@language': key })
        })
      }
    },
    publisherSuggestInput: function (f, event) {
      if (event) {
        f.publisherName = event['name']
      }
    },
    organizationSelectInput: function (f, event) {
      f.organization = ''
      f.organizationSelectedName = []
      if (event) {
        f.organization = event['@id']
        var preflabels = event['skos:prefLabel']
        Object.entries(preflabels).forEach(([key, value]) => {
          f.organizationSelectedName.push({ '@value': value, '@language': key })
        })
      }
    },
    organizationRorInput: function (f, event) {
      f.organization = ''
      f.organizationSelectedName = []
      if (event) {
        for (const id of event['skos:exactMatch']) {
          f.organization = id
        }
        f.organizationSelectedName = event['schema:name']
      }
    },
    organizationTypeChange: function (f, event) {
      switch (event) {
        case 'select':
        case 'ror':
          f.organizationType = 'select'
          break
        case 'other':
          f.organizationType = 'other'
          break
      }
    },
    mimeToResourceType: function (mime) {
      switch (mime) {
        case 'image/jpeg':
        case 'image/tiff':
        case 'image/gif':
        case 'image/png':
        case 'image/x-ms-bmp':
          // picture
          return 'https://pid.phaidra.org/vocabulary/44TN-P1S0'

        case 'audio/wav':
        case 'audio/mpeg':
        case 'audio/flac':
        case 'audio/ogg':
          // audio
          return 'https://pid.phaidra.org/vocabulary/8YB5-1M0J'

        case 'application/pdf':
          // document
          return 'https://pid.phaidra.org/vocabulary/69ZZ-2KGX'

        case 'video/mpeg':
        case 'video/avi':
        case 'video/mp4':
        case 'video/quicktime':
        case 'video/x-matroska':
          // video
          return 'https://pid.phaidra.org/vocabulary/B0Y6-GYT8'

        default:
          // data
          return 'https://pid.phaidra.org/vocabulary/7AVS-Y482'
      }
    },
    setSelected: function (f, property, event) {
      if (event) {
        this.$set(f, property, event['@id'])
      }
      this.$emit('form-input-' + f.component, f)
      // eg on
      // v-on:input-identifier-type="setSelected(f, 'identifierType', $event)"
      // the type property of the component should be updated, but
      // v-bind.sync="f"
      // does not work, probably because the update is too deep (form -> field -> property)
      this.$forceUpdate()
    },
    updateSubject: function (f, event) {
      f['skos:prefLabel'] = event['skos:prefLabel']
      if (f['skos:prefLabel']) {
        if (f['skos:prefLabel'].length > 0) {
          // needed to init the search input if loading from template
          // will be synced with component's initquery prop
          f.initquery = f['skos:prefLabel'][0]['@value']
        }
      }
      f['rdfs:label'] = event['rdfs:label']
      this.$emit('form-input-' + f.component, f)
    },
    updateVocSubject: function (f, event) {
      if (event) {
        f.value = event['@id']
        if (event['@type']) {
          f.type = event['@type']
        }
        if (event['skos:prefLabel']) {
          let preflabels = event['skos:prefLabel']
          f['skos:prefLabel'] = []
          Object.entries(preflabels).forEach(([key, value]) => {
            f['skos:prefLabel'].push({ '@value': value, '@language': key })
          })
        }
        if (event['rdfs:label']) {
          let rdfslabels = event['rdfs:label']
          if (rdfslabels) {
            f['rdfs:label'] = []
            Object.entries(rdfslabels).forEach(([key, value]) => {
              f['rdfs:label'].push({ '@value': value, '@language': key })
            })
          }
        }
        if (event['skos:notation']) {
          f['skos:notation'] = event['skos:notation']
        }
      } else {
        f.value = ''
        f['skos:prefLabel'] = []
        f['rdfs:label'] = []
        f['skos:notation'] = []
      }

      this.$emit('form-input-' + f.component, f)
    },
    updatePlace: function (f, event) {
      f['skos:prefLabel'] = event['skos:prefLabel']
      if (f['skos:prefLabel']) {
        if (f['skos:prefLabel'].length > 0) {
          // needed to init the search input if loading from template
          // will be synced with component's initquery prop
          f.initquery = f['skos:prefLabel'][0]['@value']
        }
      }
      f['rdfs:label'] = event['rdfs:label']
      f.coordinates = event.coordinates
      this.$emit('form-input-' + f.component, f)
    },
    handleObjectTypeCheckboxesInput: function (f, event) {
      f.selectedTerms = []
      let voc = 'objecttype'
      if (f.vocabulary) {
        voc = f.vocabulary
      }
      if (event) {
        Object.entries(event).forEach(([otkey, ot]) => {
          if (ot) {
            let term = this.$store.getters['vocabulary/getTerm'](voc, otkey)
            let field = {
              value: term['@id']
            }
            if (term['skos:prefLabel']) {
              let preflabels = term['skos:prefLabel']
              field['skos:prefLabel'] = []
              Object.entries(preflabels).forEach(([key, value]) => {
                field['skos:prefLabel'].push({ '@value': value, '@language': key })
              })
            }
            f.selectedTerms.push(field)
          }
        })
      }
    },
    selectInput: function (f, event) {
      if (event) {
        f.value = event['@id']
        if (event['@type']) {
          f.type = event['@type']
        }
        if (event['skos:prefLabel']) {
          let preflabels = event['skos:prefLabel']
          f['skos:prefLabel'] = []
          Object.entries(preflabels).forEach(([key, value]) => {
            f['skos:prefLabel'].push({ '@value': value, '@language': key })
          })
        }
        if (event['rdfs:label']) {
          let rdfslabels = event['rdfs:label']
          if (rdfslabels) {
            f['rdfs:label'] = []
            Object.entries(rdfslabels).forEach(([key, value]) => {
              f['rdfs:label'].push({ '@value': value, '@language': key })
            })
          }
        }
        if (event['skos:notation']) {
          f['skos:notation'] = event['skos:notation']
        }
      } else {
        f.value = ''
        f['skos:prefLabel'] = []
        f['rdfs:label'] = []
        f['skos:notation'] = []
      }

      if (f.predicate === 'edm:rights') {
        this.license = f.value
      }

      if (f.predicate === 'dcterms:type') {
        // set resourceType property of 'object type' field
        // so that it can filter terms from object types vocab
        for (let s of this.form.sections) {
          if (s.fields && (s.type !== 'member')) {
            for (let field of s.fields) {
              if (field.predicate === 'edm:hasType') {
                field.resourceType = f.value
              }
            }
          }
        }
        this.$emit('form-input-resource-type', f.value)
      }

      this.$emit('form-input-' + f.component, f)
    },
    roleInput: function (f, event) {
      if (event) {
        f.role = event['@id']
        this.$emit('form-input-' + f.component, f)
      }
    },
    containedInRoleInput: function (f, event) {
      for (let r of f.roles) {
        if (r.id === event.role.id) {
          if (event.hasOwnProperty('roleTerm')) {
            r.role = event.roleTerm['@id']
          }
          if (event.hasOwnProperty('name')) {
            r.name = event.name
          }
          if (event.hasOwnProperty('firstname')) {
            r.firstname = event.firstname
          }
          if (event.hasOwnProperty('lastname')) {
            r.lastname = event.lastname
          }
        }
      }
    },
    containedInSeriesInput: function (f, event) {
      for (let s of f.series) {
        if (s.id === event.series.id) {
          if (event.hasOwnProperty('seriesTitleLanguageTerm')) {
            s.seriesTitleLanguage = event.seriesTitleLanguageTerm['@id']
          }
          if (event.hasOwnProperty('seriesTitle')) {
            s.seriesTitle = event.seriesTitle
          }
          if (event.hasOwnProperty('seriesVolume')) {
            s.seriesVolume = event.seriesVolume
          }
          if (event.hasOwnProperty('seriesIssue')) {
            s.seriesIssue = event.seriesIssue
          }
          if (event.hasOwnProperty('seriesIssued')) {
            s.seriesIssued = event.seriesIssued
          }
          if (event.hasOwnProperty('seriesIssn')) {
            s.seriesIssn = event.seriesIssn
          }
          if (event.hasOwnProperty('seriesIdentifier')) {
            s.seriesIdentifier = event.seriesIdentifier
          }
          if (event.hasOwnProperty('seriesIdentifierType')) {
            s.seriesIdentifierType = event.seriesIdentifierType
          }
        }
      }
    },
    setFilename: function (f, event) {
      f.value = event.name
      f.file = event
      console.log('browser mimetype:')
      console.log(event.type)
      if (event.type === '') {
        // if browser does not provide mimetype
        // try to match the extension with our vocabulary
        let ext = event.name.split('.').pop()
        console.log('no mimetype, using extension (' + ext + ') to search vocabulary')
        for (let mt of this.vocabularies['mimetypes'].terms) {
          for (let notation of mt['skos:notation']) {
            if (ext === notation) {
              console.log('found mimetype: ' + mt['@id'])
              this.setSelected(f, 'mimetype', { '@id': mt['@id'] })
            }
          }
        }
      } else {
        this.setSelected(f, 'mimetype', { '@id': event.type })
      }
      this.$emit('form-input-' + f.component, f)
    },
    addFieldAutocompleteFilter: function (item, queryText) {
      const lab = this.$t(item['fieldname']).toLowerCase()
      const query = queryText.toLowerCase()
      return lab.indexOf(query) > -1
    },
    removeFieldChip (item) {
      const index = this.addfieldselection.indexOf(item)
      if (index >= 0) this.addfieldselection.splice(index, 1)
    },
    addFields (section) {
      for (var i = 0; i < this.addfieldselection.length; i++) {
        let f = fields.getField(this.addfieldselection[i].id)
        f.removable = true
        section.fields.push(f)
      }
      this.addfieldselection = []
      section['adddialogue'] = false
    }
  },
  mounted: function () {
    this.$store.dispatch('vocabulary/loadLanguages', this.$i18n.locale)
    this.$store.dispatch('vocabulary/sortFields', this.$i18n.locale)
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}

.prewrap {
  white-space: pre-wrap;
}

.v-input__control {
  font-weight: 400;
}
</style>
