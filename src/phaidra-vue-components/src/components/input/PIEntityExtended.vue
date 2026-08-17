<template>
  <v-row v-if="!hidden" ref="rowRef">
    <v-col cols="12">
      <v-card variant="outlined" class="mb-8" width="100%">
        <v-card-title class="text-title-large font-weight-light text-white">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <template v-if="showActions">
            <v-tooltip location="bottom">
              <template v-slot:activator="{ props: activatorProps }">
                <v-icon-btn v-bind="activatorProps" variant="text" color="white" @click="$emit('add', $event)" icon="mdi-content-duplicate" />
              </template>
              <span>{{ $t('Duplicate') }}</span>
            </v-tooltip>
            <v-tooltip location="bottom">
              <template v-slot:activator="{ props: activatorProps }">
                <v-icon-btn v-bind="activatorProps" variant="text" color="white" @click="$emit('add-clear', $event)" icon="mdi-plus" />
              </template>
              <span>{{ $t('Add') }}</span>
            </v-tooltip>
            <v-tooltip location="bottom" v-if="removable !== false">
              <template v-slot:activator="{ props: activatorProps }">
                <v-icon-btn v-bind="activatorProps" variant="text" color="white" @click="$emit('remove', $event)" icon="mdi-minus" />
              </template>
              <span>{{ $t('Remove') }}</span>
            </v-tooltip>
            <v-tooltip location="bottom">
              <template v-slot:activator="{ props: activatorProps }">
                <v-icon-btn v-bind="activatorProps" variant="text" color="white" @click="$emit('up', $event)" icon="mdi-chevron-up-circle-outline" />
              </template>
              <span>{{ $t('Move up') }}</span>
            </v-tooltip>
            <v-tooltip location="bottom">
              <template v-slot:activator="{ props: activatorProps }">
                <v-icon-btn v-bind="activatorProps" variant="text" color="white" @click="$emit('down', $event)" icon="mdi-chevron-down-circle-outline" />
              </template>
              <span>{{ $t('Move down') }}</span>
            </v-tooltip>
          </template>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-container fluid>
            <v-row>
              <v-col cols="8" v-if="!hideRole">
                <v-autocomplete
                  :menu-props="formRowSelectMenu.menuProps"
                  :disabled="disablerole"
                  @update:model-value="$emit('input-role', $event)"
                  :label="$t(roleLabel ? roleLabel : 'Role')"
                  :no-data-text="$t('No data available')"
                  :items="vocabularies[roleVocabulary].terms"
                  item-value="@id"
                  :item-title="roleItemTitle"
                  :custom-filter="vocabAutocompleteFilter"
                  :model-value="roleTerm"
                  :variant="fieldVariant"
                  :bg-color="roleBackgroundColor ? roleBackgroundColor : undefined"
                  return-object
                  clearable
                  :error-messages="roleErrorMessages"
                >
                  <template #item="{ props, internalItem }">
                    <v-list-item
                      v-bind="props"
                      :lines="roleAutocompleteLines"
                    >
                      <template #title>
                        <span v-html="getLocalizedTermLabel(roleVocabulary, internalItem.raw['@id'])" />
                      </template>
                      <template v-if="showIds || showDefinitions" #subtitle>
                        <div v-if="showIds" v-html="internalItem.raw['@id']" />
                        <div
                          v-if="showDefinitions"
                          class="role-definition"
                          v-html="getLocalizedDefinition(roleVocabulary, internalItem.raw['@id'])"
                        />
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ internalItem }">
                    <span v-html="getLocalizedTermLabel(roleVocabulary, (internalItem.raw || internalItem)['@id'])" />
                  </template>
                </v-autocomplete>
              </v-col>
              <v-col v-if="enableTypeSelect" cols="2">
                <v-radio-group v-model="typeModel" class="mt-0" @change="$emit('change-type', $event)">
                  <v-radio color="primary" :label="$t('Personal')" :value="'schema:Person'"></v-radio>
                  <v-radio color="primary" :label="$t('Corporate')" :value="'schema:Organization'"></v-radio>
                </v-radio-group>
              </v-col>
            </v-row>
            <template v-if="typeModel === 'schema:Person'">
              <v-row>
                <template v-if="showname">
                  <v-col cols="12" :md="(showIdentifier && !showIdentifierType) ? 8 : 12">
                    <v-text-field
                      :model-value="name"
                      :label="$t(nameLabel ? nameLabel : 'Name')"
                      @update:model-value="$emit('input-name', $event)"
                      :variant="fieldVariant"
                      :bg-color="nameBackgroundColor ? nameBackgroundColor : undefined"
                      :error-messages="nameErrorMessages"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-else>
                  <v-col cols="12" :md="(showIdentifier && !showIdentifierType) ? 4 : 6">
                    <v-text-field
                      :model-value="firstname"
                      :label="$t(firstnameLabel ? firstnameLabel : 'Firstname')"
                      @update:model-value="$emit('input-firstname', $event)"
                      :variant="fieldVariant"
                      :bg-color="firstnameBackgroundColor ? firstnameBackgroundColor : undefined"
                      :error-messages="firstnameErrorMessages"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="12" :md="(showIdentifier && !showIdentifierType) ? 4 : 6">
                    <v-text-field
                      :model-value="lastname"
                      :label="$t(lastnameLabel ? lastnameLabel : 'Lastname')"
                      @update:model-value="$emit('input-lastname', $event)"
                      :variant="fieldVariant"
                      :bg-color="lastnameBackgroundColor ? lastnameBackgroundColor : undefined"
                      :error-messages="lastnameErrorMessages"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-if="showIdentifier && !showIdentifierType">
                  <v-col cols="12" md="4">
                    <v-text-field
                      v-show="identifierTypeId === 'ids:orcid'"
                      v-maska data-maska="####-####-####-####"
                      :model-value="identifierText"
                      :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                      @update:model-value="$emit('input-identifier', $event)"
                      :placeholder="identifierTypePlaceholder"
                      :rules="identifierTypeId ? [validationrules['orcid']] : [validationrules['noop']]"
                      :variant="fieldVariant"
                    ></v-text-field>
                    <v-text-field
                      v-show="identifierTypeId !== 'ids:orcid'"
                      :model-value="identifierText"
                      :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                      @update:model-value="$emit('input-identifier', $event)"
                      :placeholder="identifierTypePlaceholder"
                      :rules="identifierTypeId ? [validationrules[getIdentifierRuleName(identifierTypeId)]] : [validationrules['noop']]"
                      :variant="fieldVariant"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-if="showBirthAndDeathDate">
                  <v-col cols="12" md="6">
                    <v-text-field
                      :model-value="birthdate"
                      :label="$t(birthDateLabel ? birthDateLabel : 'Birth Date')"
                      @update:model-value="$emit('input-birthdate', $event)"
                      :variant="fieldVariant"
                      :rules="[validationrules.date]"
                      :hint="$t('Format YYYY-MM-DD')"
                      :bg-color="birthDateBackgroundColor ? birthDateBackgroundColor : undefined"
                      :error-messages="birthDateErrorMessages"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="12" md="6">
                    <v-text-field
                      :model-value="deathdate"
                      :label="$t(deathDateLabel ? deathDateLabel : 'Death Date')"
                      @update:model-value="$emit('input-deathdate', $event)"
                      :variant="fieldVariant"
                      :rules="[validationrules.date]"
                      :hint="$t('Format YYYY-MM-DD')"
                      :bg-color="deathDateBackgroundColor ? deathDateBackgroundColor : undefined"
                      :error-messages="deathDateErrorMessages"
                    ></v-text-field>
                  </v-col>
                </template>
              </v-row>
              <v-row v-if="showIdentifier && showIdentifierType">
                <v-col cols="12" md="6">
                  <v-autocomplete
                    @update:model-value="$emit('input-identifier-type', $event)"
                    :label="$t('Type of identifier')"
                    :no-data-text="$t('No data available')"
                    :items="vocabularies[identifierVocabulary].terms"
                    item-value="@id"
                    :item-title="identifierTypeItemTitle"
                    :custom-filter="vocabAutocompleteFilter"
                    :model-value="identifierTypeTerm"
                    :disabled="disableIdentifierType"
                    :variant="fieldVariant"
                    return-object
                    clearable
                  >
                    <template #item="{ props, internalItem }">
                      <v-list-item v-bind="props" lines="one">
                        <template #title>
                          <span v-html="getLocalizedTermLabel(identifierVocabulary, internalItem.raw['@id'])" />
                        </template>
                      </v-list-item>
                    </template>
                    <template #selection="{ internalItem }">
                      <span v-html="getLocalizedTermLabel(identifierVocabulary, (internalItem.raw || internalItem)['@id'])" />
                    </template>
                  </v-autocomplete>
                </v-col>
                <v-col cols="12" md="6" >
                  <v-text-field
                    v-show="identifierTypeId === 'ids:orcid'"
                    v-maska data-maska="####-####-####-####"
                    :model-value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    @update:model-value="$emit('input-identifier', $event)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierTypeId ? [validationrules['orcid']] : [validationrules['noop']]"
                    :variant="fieldVariant"
                  ></v-text-field>
                  <v-text-field
                    v-show="identifierTypeId !== 'ids:orcid'"
                    :model-value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    @update:model-value="$emit('input-identifier', $event)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierTypeId ? [validationrules[getIdentifierRuleName(identifierTypeId)]] : [validationrules['noop']]"
                    :variant="fieldVariant"
                  ></v-text-field>
                </v-col>
              </v-row>
            </template>
            <template v-if="typeModel === 'schema:Organization'">
              <v-row>
                <v-col cols="2">
                  <v-radio-group v-model="organizationRadio" class="mt-0" @change="$emit('change-organization-type', $event)">
                    <v-radio color="primary" :label="$t('Organizational unit')" :value="'select'"></v-radio>
                    <v-radio color="primary" :label="'ROR'" :value="'ror'"></v-radio>
                    <v-radio color="primary" :label="$t('OTHER_FEMININE')" :value="'other'"></v-radio>
                  </v-radio-group>
                </v-col>
                <v-col cols="12" md="10" v-if="organizationRadio === 'select'">
                  <v-autocomplete
                    :model-value="getTerm('orgunits', organization)"
                    :required="required"
                    @update:model-value="handleInput($event, 'organizationPath', 'input-organization-select')"
                    :rules="required ? [ v => !!v || $t('Required')] : []"
                    :items="orgunits"
                    item-value="@id"
                    :item-title="orgunitItemTitle"
                    :custom-filter="orgunitsAutocompleteFilter"
                    :loading="loading"
                    hide-no-data
                    :label="$t(organizationSelectLabel)"
                    :variant="fieldVariant"
                    return-object
                    clearable
                    :disabled="disabled"
                    :messages="organizationPath"
                    :error-messages="organizationErrorMessages"
                    :bg-color="organizationBackgroundColor ? organizationBackgroundColor : undefined"
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
                <v-col cols="12" md="10" v-if="organizationRadio === 'ror'">
                  <ror-search
                    v-on:resolve="$emit('input-organization-ror',$event)"
                    :value="organization"
                    :text="organizationRorName"
                    :errorMessages="organizationErrorMessages"
                    :label="$t(rorSearchLabel ? rorSearchLabel : 'ROR Search')"
                  ></ror-search>
                </v-col>
                <v-col cols="12" md="10" v-if="organizationRadio === 'other'">
                  <v-text-field
                    :model-value="organizationText"
                    @update:model-value="$emit('input-organization-other', $event)"
                    :variant="fieldVariant"
                    :label="$t(organizationTextLabel ? organizationTextLabel : 'Organization')"
                    :error-messages="organizationTextErrorMessages"
                    :bg-color="organizationBackgroundColor ? organizationBackgroundColor : undefined"
                  ></v-text-field>
                </v-col>
              </v-row>
              <v-row v-if="showIdentifier && !showIdentifierType">
                <v-col cols="12" md="12">
                  <v-text-field
                    v-show="identifierTypeId === 'ids:orcid'"
                    v-mask="'####-####-####-###X'"
                    :model-value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    @update:model-value="$emit('input-identifier', $event)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierTypeId ? [validationrules['orcid']] : [validationrules['noop']]"
                    variant="outlined"
                  ></v-text-field>
                  <v-text-field
                    v-show="identifierTypeId !== 'ids:orcid'"
                    :model-value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    @update:model-value="$emit('input-identifier', $event)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierTypeId ? [validationrules[getIdentifierRuleName(identifierTypeId)]] : [validationrules['noop']]"
                    variant="outlined"
                  ></v-text-field>
                </v-col>
              </v-row>
              <v-row v-if="showIdentifier && showIdentifierType">
                <v-col cols="12" md="6">
                  <v-autocomplete
                    @update:model-value="$emit('input-identifier-type', $event)"
                    :label="$t('Type of identifier')"
                    :no-data-text="$t('No data available')"
                    :items="vocabularies[identifierVocabulary].terms"
                    item-value="@id"
                    :item-title="identifierTypeItemTitle"
                    :custom-filter="vocabAutocompleteFilter"
                    :model-value="identifierTypeTerm"
                    :disabled="disableIdentifierType"
                    :variant="fieldVariant"
                    return-object
                    clearable
                  >
                    <template #item="{ props, internalItem }">
                      <v-list-item v-bind="props" lines="one">
                        <template #title>
                          <span v-html="getLocalizedTermLabel(identifierVocabulary, internalItem.raw['@id'])" />
                        </template>
                      </v-list-item>
                    </template>
                    <template #selection="{ internalItem }">
                      <span v-html="getLocalizedTermLabel(identifierVocabulary, (internalItem.raw || internalItem)['@id'])" />
                    </template>
                  </v-autocomplete>
                </v-col>
                <v-col cols="12" md="6" >
                  <v-text-field
                    v-show="identifierTypeId === 'ids:orcid'"
                    v-mask="'####-####-####-###X'"
                    :model-value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    @update:model-value="$emit('input-identifier', $event)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierTypeId ? [validationrules['orcid']] : [validationrules['noop']]"
                    variant="outlined"
                  ></v-text-field>
                  <v-text-field
                    v-show="identifierTypeId !== 'ids:orcid'"
                    :model-value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    @update:model-value="$emit('input-identifier', $event)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierTypeId ? [validationrules[getIdentifierRuleName(identifierTypeId)]] : [validationrules['noop']]"
                    variant="outlined"
                  ></v-text-field>
                </v-col>
              </v-row>
            </template>
            <v-row v-if="(typeModel === 'schema:Person') && showAffiliation">
              <v-col cols="2">
                <v-radio-group v-model="affiliationRadio" class="mt-0" @change="$emit('change-affiliation-type', $event)">
                  <v-radio color="primary" :label="$t('Organizational unit')" :value="'select'"></v-radio>
                  <v-radio color="primary" :label="'ROR'" :value="'ror'"></v-radio>
                  <v-radio color="primary" :label="$t('OTHER_FEMININE')" :value="'other'"></v-radio>
                </v-radio-group>
              </v-col>
              <v-col cols="12" md="10" v-if="affiliationRadio === 'select'">
                <v-autocomplete
                  :model-value="getTerm('orgunits', affiliation)"
                  :required="required"
                  @update:model-value="handleInput($event, 'affiliationPath', 'input-affiliation-select')"
                  :rules="required ? [ v => !!v || $t('Required')] : []"
                  :items="orgunits"
                  item-value="@id"
                  :item-title="orgunitItemTitle"
                  :custom-filter="orgunitsAutocompleteFilter"
                  :loading="loading"
                  hide-no-data
                  :label="$t(affiliationSelectLabel)"
                  :variant="fieldVariant"
                  return-object
                  clearable
                  :disabled="disabled"
                  :messages="affiliationPath"
                  :error-messages="affiliationErrorMessages"
                  :bg-color="affiliationBackgroundColor ? affiliationBackgroundColor : undefined"
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
                    <v-icon v-if="enableAffTree" @click="$refs.affiliationstreedialog.open()">mdi-file-tree</v-icon>
                  </template>
                </v-autocomplete>
              </v-col>
              <v-col cols="12" md="10" v-if="affiliationRadio === 'ror'">
                <ror-search v-on:resolve="$emit('input-affiliation-ror', $event)" :value="affiliation" :text="affiliationRorName" :errorMessages="affiliationErrorMessages"></ror-search>
              </v-col>
              <v-col cols="12" md="10" v-if="affiliationRadio === 'other'">
                <v-text-field
                  :model-value="affiliationText"
                  :label="$t('Affiliation')"
                  @update:model-value="$emit('input-affiliation-other', $event)"
                  :variant="fieldVariant"
                  :error-messages="affiliationTextErrorMessages"
                  :bg-color="affiliationBackgroundColor ? affiliationBackgroundColor : undefined"
                ></v-text-field>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>
    </v-col>
    <org-units-tree-dialog :isParentSelectionDisabled="parentSelectionDisabled" ref="organizationstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event), 'organizationPath', 'input-organization-select')"></org-units-tree-dialog>
    <org-units-tree-dialog :isParentSelectionDisabled="parentSelectionDisabled" ref="affiliationstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event), 'affiliationPath', 'input-affiliation-select')"></org-units-tree-dialog>
  </v-row>
</template>

<script>
import { vMaska } from 'maska/vue'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'
import RorSearch from '../select/RorSearch'
import { createSelectMenuMaxWidthController } from '../../composables/selectMenuMaxWidth'

export default {
  name: 'p-i-entity-extended',
  mixins: [ vocabulary, fieldproperties, validationrules ],
  components: {
    OrgUnitsTreeDialog,
    RorSearch
  },
  directives: {
    maska: vMaska
  },
  emits: [
    'input',
    'change-type',
    'input-firstname',
    'input-birthdate',
    'input-deathdate',
    'input-lastname',
    'input-name',
    'input-identifier-type',
    'input-identifier',
    'change-affiliation-type',
    'input-affiliation-select',
    'input-affiliation-ror',
    'input-affiliation-other',
    'change-organization-type',
    'input-organization-select',
    'input-organization-ror',
    'input-organization-other',
    'input-role',
    'add',
    'add-clear',
    'remove',
    'configure',
    'up',
    'down'
  ],
  props: {
    label: {
      type: String
    },
    firstname: {
      type: String
    },
    lastname: {
      type: String
    },
    birthdate: {
      type: String
    },
    deathdate: {
      type: String
    },
    name: {
      type: String
    },
    roleLabel: {
      type: String
    },
    firstnameLabel: {
      type: String
    },
    lastnameLabel: {
      type: String
    },
    birthDateLabel: {
      type: String
    },
    deathDateLabel: {
      type: String
    },
    nameLabel: {
      type: String
    },
    affiliation: {
      type: String
    },
    affiliationText: {
      type: String
    },
    affiliationRorName: {
      type: String
    },
    affiliationType: {
      type: String
    },
    organization: {
      type: String
    },
    organizationText: {
      type: String
    },
    organizationRorName: {
      type: String
    },
    organizationType: {
      type: String
    },
    identifierText: {
      type: String
    },
    identifierType: {
      type: String
    },
    identifierLabel: {
      type: String
    },
    showIdentifier: {
      type: Boolean
    },
    showIdentifierType: {
      type: Boolean
    },
    disableIdentifierType: {
      type: Boolean
    },
    role: {
      type: String
    },
    hideRole: {
      type: Boolean
    },
    type: {
      type: String
    },
    required: {
      type: Boolean
    },
    disablerole: {
      type: Boolean,
      default: false
    },
    nameErrorMessages: {
      type: Array
    },
    firstnameErrorMessages: {
      type: Array
    },
    lastnameErrorMessages: {
      type: Array
    },
    birthDateErrorMessages: {
      type: Array
    },
    deathDateErrorMessages: {
      type: Array
    },
    roleErrorMessages: {
      type: Array
    },
    affiliationErrorMessages: {
      type: Array
    },
    affiliationTextErrorMessages: {
      type: Array
    },
    organizationErrorMessages: {
      type: Array
    },
    organizationTextErrorMessages: {
      type: Array
    },
    showname: {
      type: Boolean,
      default: false
    },
    roleVocabulary: {
      type: String,
      default: 'rolepredicate'
    },
    showDefinitions: {
      type: Boolean,
      default: false
    },
    identifierVocabulary: {
      type: String,
      default: 'entityidentifiertype'
    },
    showIds: {
      type: Boolean,
      default: false
    },
    showBirthAndDeathDate: {
      type: Boolean,
      default: true
    },
    showActions: {
      type: Boolean,
      default: true
    },
    showAffiliation: {
      type: Boolean,
      default: true
    },
    enableTypeSelect: {
      type: Boolean,
      default: true
    },
    organizationSelectLabel: {
      type: String,
      default: 'Please choose'
    },
    rorSearchLabel: {
      type: String
    },
    organizationTextLabel: {
      type: String
    },
    affiliationSelectLabel: {
      type: String,
      default: 'Please choose'
    },
    roleBackgroundColor: {
      type: String,
      default: undefined
    },
    nameBackgroundColor: {
      type: String,
      default: undefined
    },
    firstnameBackgroundColor: {
      type: String,
      default: undefined
    },
    birthDateBackgroundColor: {
      type: String,
      default: undefined
    },
    deathDateBackgroundColor: {
      type: String,
      default: undefined
    },
    lastnameBackgroundColor: {
      type: String,
      default: undefined
    },
    organizationBackgroundColor: {
      type: String,
      default: undefined
    },
    affiliationBackgroundColor: {
      type: String,
      default: undefined
    },
    enableOrgTree: {
      type: Boolean,
      default: true
    },
    enableAffTree: {
      type: Boolean,
      default: true
    },
    isParentSelectionDisabled: {
      type: Boolean,
      default: false
    },
    removable: {
      type: Boolean,
      default: true
    }
  },
  created () {
    this.formRowSelectMenu = createSelectMenuMaxWidthController()
  },
  computed: {
    roleAutocompleteLines () {
      if (this.showIds && this.showDefinitions) return 'three'
      if (this.showIds || this.showDefinitions) return 'two'
      return 'one'
    },
    instanceconfig: function () {
      return this.$store.state.instanceconfig
    },
    appconfig: function () {
      return this.$store.state.appconfig
    },
    parentSelectionDisabled: function () {
      return this.isParentSelectionDisabled || this.instanceconfig?.isParentSelectionDisabled || false
    },
    isMandatory: function () {
      return this.required === true
    },
    identifierTypeId () {
      if (!this.identifierType) return ''
      if (typeof this.identifierType === 'string') return this.identifierType
      return this.identifierType['@id'] || ''
    },
    identifierTypeTerm () {
      return this.getTerm(this.identifierVocabulary, this.identifierTypeId || this.identifierType)
    },
    roleTerm () {
      return this.getTerm(this.roleVocabulary, this.role)
    },
    identifierTypePlaceholder: function () {
      for (let i of this.vocabularies[this.identifierVocabulary].terms) {
        if (i['@id'] === this.identifierTypeId) {
          return i['skos:example']
        }
      }
      return ''
    },
    orgunits: function () {
      let units = this.vocabularies['orgunits'].terms
      if (this.parentSelectionDisabled) {
        units = units.filter(element => !element.hasChildren)
      }
      let groups = []
      for (let u of units) {
        if (u['phaidra:orgGroupOrdinal']) {
          if (!Array.isArray(groups[u['phaidra:orgGroupOrdinal']])) {
            groups[u['phaidra:orgGroupOrdinal']] = []
          }
          groups[u['phaidra:orgGroupOrdinal']].push(u)
        }
      }
      let groupedUnits = []
      for (let g of groups) {
        if (g) {
          let i = 0
          for (let u of g) {
            if (i === 0) {
              groupedUnits.push({ divider: true })
              groupedUnits.push({ header: u['phaidra:orgGroup'] })
            }
            groupedUnits.push(u)
            i++
          }
        }
      }
      return groupedUnits.length === 0 ? units : groupedUnits
    }
  },
  data () {
    return {
      loading: false,
      disabled: false,
      typeModel: this.type,
      affiliationRadio: this.affiliationType,
      organizationRadio: this.organizationType,
      affiliationPath: '',
      organizationPath: ''
    }
  },
  methods: {
    roleItemTitle (item) {
      const raw = item?.raw !== undefined ? item.raw : item
      if (!raw || !raw['@id']) return ''
      const s = this.getLocalizedTermLabel(this.roleVocabulary, raw['@id'])
      return typeof s === 'string' ? s.replace(/<[^>]+>/g, '') : String(s || '')
    },
    identifierTypeItemTitle (item) {
      const raw = item?.raw !== undefined ? item.raw : item
      if (!raw || !raw['@id']) return ''
      const s = this.getLocalizedTermLabel(this.identifierVocabulary, raw['@id'])
      return typeof s === 'string' ? s.replace(/<[^>]+>/g, '') : String(s || '')
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
          if (this.$i18n) {
            pathLabels.push(u['skos:prefLabel'][this.$i18n.locale])
          }
        }
        this[propName] = pathLabels.join(' > ')
      }
      this.$emit(eventName, unit)
    }
  },
  mounted: async function () {
    this.$nextTick(async function () {
      this.formRowSelectMenu.observe(() => this.$refs.rowRef?.$el ?? this.$refs.rowRef)
      await this.$store.dispatch('vocabulary/loadOrgUnits', this.$i18n.locale)
      this.loading = !this.vocabularies[this.roleVocabulary].loaded
      this.$store.dispatch('vocabulary/sortRoles', this?.$i18n?.locale || 'eng')
      // emit input to set skos:prefLabel in parent
      if (this.role) {
        this.$emit('input', this.getTerm(this.roleVocabulary, this.role))
      }
      if (this.organization && this.organization.startsWith('https://pid.phaidra.org/')) {
        this.handleInput(this.getTerm('orgunits', this.organization), 'organizationPath', 'input-organization-select')
      }
      if (this.affiliation && this.affiliation.startsWith('https://pid.phaidra.org/')) {
        this.handleInput(this.getTerm('orgunits', this.affiliation), 'affiliationPath', 'input-affiliation-select')
      }
    })
  },
  beforeUnmount () {
    this.formRowSelectMenu.disconnect()
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
.role-definition {
  white-space: unset;
}
</style>
