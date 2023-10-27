<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8" width="100%">
        <v-card-title class="title font-weight-light grey white--text">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-btn icon dark @click="$emit('add', $event)">
            <v-icon>mdi-content-duplicate</v-icon>
          </v-btn>
          <v-btn icon dark @click="$emit('add-clear', $event)">
            <v-icon>mdi-plus</v-icon>
          </v-btn>
          <v-btn icon dark @click="$emit('remove', $event)">
            <v-icon>mdi-minus</v-icon>
          </v-btn>
          <v-btn icon dark @click="$emit('up', $event)">
            <v-icon>mdi-chevron-up</v-icon>
          </v-btn>
          <v-btn icon dark @click="$emit('down', $event)">
            <v-icon>mdi-chevron-down</v-icon>
          </v-btn>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-container fluid>
            <v-row>
              <v-col cols="8" v-if="!hideRole">
                <v-autocomplete
                  :disabled="disablerole"
                  v-on:input="$emit('input-role', $event)"
                  :label="$t(roleLabel ? roleLabel : 'Role')"
                  :items="vocabularies[roleVocabulary].terms"
                  :item-value="'@id'"
                  :value="getTerm(roleVocabulary, role)"
                  :filter="autocompleteFilter"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  :background-color="roleBackgroundColor ? roleBackgroundColor : undefined"
                  return-object
                  clearable
                  :error-messages="roleErrorMessages"
                >
                  <template slot="item" slot-scope="{ item }">
                    <v-list-item-content two-line>
                      <v-list-item-title  v-html="`${getLocalizedTermLabel(roleVocabulary, item['@id'])}`"></v-list-item-title>
                      <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
                    </v-list-item-content>
                  </template>
                  <template slot="selection" slot-scope="{ item }">
                    <v-list-item-content>
                      <v-list-item-title v-html="`${getLocalizedTermLabel(roleVocabulary, item['@id'])}`"></v-list-item-title>
                    </v-list-item-content>
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
                      :value="name"
                      :label="$t(nameLabel ? nameLabel : 'Name')"
                      v-on:blur="$emit('input-name',$event.target.value)"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                      :background-color="nameBackgroundColor ? nameBackgroundColor : undefined"
                      :error-messages="nameErrorMessages"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-else>
                  <v-col cols="12" :md="(showIdentifier && !showIdentifierType) ? 4 : 6">
                    <v-text-field
                      :value="firstname"
                      :label="$t(firstnameLabel ? firstnameLabel : 'Firstname')"
                      v-on:blur="$emit('input-firstname',$event.target.value)"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                      :background-color="firstnameBackgroundColor ? firstnameBackgroundColor : undefined"
                      :error-messages="firstnameErrorMessages"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="12" :md="(showIdentifier && !showIdentifierType) ? 4 : 6">
                    <v-text-field
                      :value="lastname"
                      :label="$t(lastnameLabel ? lastnameLabel : 'Lastname')"
                      v-on:blur="$emit('input-lastname',$event.target.value)"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                      :background-color="lastnameBackgroundColor ? lastnameBackgroundColor : undefined"
                      :error-messages="lastnameErrorMessages"
                    ></v-text-field>
                  </v-col>
                </template>
                <template v-if="showIdentifier && !showIdentifierType">
                  <v-col cols="12" md="4">
                    <v-text-field
                      v-show="identifierType === 'ids:orcid'"
                      v-mask="'####-####-####-###X'"
                      :value="identifierText"
                      :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                      v-on:blur="$emit('input-identifier', $event.target.value)"
                      :placeholder="identifierTypePlaceholder"
                      :rules="identifierType ? [validationrules['orcid']] : [validationrules['noop']]"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                    <v-text-field
                      v-show="identifierType !== 'ids:orcid'"
                      :value="identifierText"
                      :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                      v-on:blur="$emit('input-identifier', $event.target.value)"
                      :placeholder="identifierTypePlaceholder"
                      :rules="identifierType ? [validationrules[getIdentifierRuleName(identifierType)]] : [validationrules['noop']]"
                      :filled="inputStyle==='filled'"
                      :outlined="inputStyle==='outlined'"
                    ></v-text-field>
                  </v-col>
                </template>
              </v-row>
              <v-row v-if="showIdentifier && showIdentifierType">
                <v-col cols="12" md="6">
                  <v-autocomplete
                    v-on:input="$emit('input-identifier-type', $event)"
                    :label="$t('Type of identifier')"
                    :items="vocabularies[identifierVocabulary].terms"
                    :item-value="'@id'"
                    :value="getTerm(identifierVocabulary, identifierType)"
                    :filter="autocompleteFilter"
                    :disabled="disableIdentifierType"
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
                <v-col cols="12" md="6" >
                  <v-text-field
                    v-show="identifierType === 'ids:orcid'"
                    v-mask="'####-####-####-###X'"
                    :value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    v-on:blur="$emit('input-identifier', $event.target.value)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierType ? [validationrules['orcid']] : [validationrules['noop']]"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                  <v-text-field
                    v-show="identifierType !== 'ids:orcid'"
                    :value="identifierText"
                    :label="identifierLabel ? $t(identifierLabel) : $t('Identifier')"
                    v-on:blur="$emit('input-identifier', $event.target.value)"
                    :placeholder="identifierTypePlaceholder"
                    :rules="identifierType ? [validationrules[getIdentifierRuleName(identifierType)]] : [validationrules['noop']]"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                  ></v-text-field>
                </v-col>
              </v-row>
            </template>
            <template v-if="typeModel === 'schema:Organization'">
              <v-row>
                <v-col cols="2">
                  <v-radio-group v-model="organizationRadio" class="mt-0" @change="$emit('change-organization-type', $event)">
                    <v-radio color="primary" :label="$t(instanceconfig.institution)" :value="'select'"></v-radio>
                    <v-radio color="primary" :label="'ROR'" :value="'ror'"></v-radio>
                    <v-radio color="primary" :label="$t('OTHER_FEMININE')" :value="'other'"></v-radio>
                  </v-radio-group>
                </v-col>
                <v-col cols="12" md="10" v-if="organizationRadio === 'select'">
                  <v-autocomplete
                    :value="getTerm('orgunits', organization)"
                    :required="required"
                    v-on:input="handleInput($event, 'organizationPath', 'input-organization-select')"
                    :rules="required ? [ v => !!v || 'Required'] : []"
                    :items="orgunits"
                    :item-value="'@id'"
                    :loading="loading"
                    :filter="autocompleteFilterInfix"
                    hide-no-data
                    :label="$t(organizationSelectLabel)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                    return-object
                    clearable
                    :disabled="disabled"
                    :messages="organizationPath"
                    :error-messages="organizationErrorMessages"
                    :background-color="organizationBackgroundColor ? organizationBackgroundColor : undefined"
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
                <v-col cols="12" md="10" v-if="organizationRadio === 'ror'">
                  <ror-search v-on:resolve="$emit('input-organization-ror',$event)" :value="organization" :text="organizationRorName" :errorMessages="organizationErrorMessages"></ror-search>
                </v-col>
                <v-col cols="12" md="10" v-if="organizationRadio === 'other'">
                  <v-text-field
                    :value="organizationText"
                    :label="$t('Organization')"
                    v-on:blur="$emit('input-organization-other', $event.target.value)"
                    :filled="inputStyle==='filled'"
                    :outlined="inputStyle==='outlined'"
                    :error-messages="organizationTextErrorMessages"
                    :background-color="organizationBackgroundColor ? organizationBackgroundColor : undefined"
                  ></v-text-field>
                </v-col>
              </v-row>
            </template>
            <v-row v-if="typeModel === 'schema:Person'">
              <v-col cols="2">
                <v-radio-group v-model="affiliationRadio" class="mt-0" @change="$emit('change-affiliation-type', $event)">
                  <v-radio color="primary" :label="$t(instanceconfig.institution)" :value="'select'"></v-radio>
                  <v-radio color="primary" :label="'ROR'" :value="'ror'"></v-radio>
                  <v-radio color="primary" :label="$t('OTHER_FEMININE')" :value="'other'"></v-radio>
                </v-radio-group>
              </v-col>
              <v-col cols="12" md="10" v-if="affiliationRadio === 'select'">
                <v-autocomplete
                  :value="getTerm('orgunits', affiliation)"
                  :required="required"
                  v-on:input="handleInput($event, 'affiliationPath', 'input-affiliation-select')"
                  :rules="required ? [ v => !!v || 'Required'] : []"
                  :items="orgunits"
                  :item-value="'@id'"
                  :loading="loading"
                  :filter="autocompleteFilterInfix"
                  hide-no-data
                  :label="$t(affiliationSelectLabel)"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  return-object
                  clearable
                  :disabled="disabled"
                  :messages="affiliationPath"
                  :error-messages="affiliationErrorMessages"
                  :background-color="affiliationBackgroundColor ? affiliationBackgroundColor : undefined"
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
                    <v-icon v-if="enableAffTree" @click="$refs.affiliationstreedialog.open()">mdi-file-tree</v-icon>
                  </template>
                </v-autocomplete>
              </v-col>
              <v-col cols="12" md="10" v-if="affiliationRadio === 'ror'">
                <ror-search v-on:resolve="$emit('input-affiliation-ror', $event)" :value="affiliation" :text="affiliationRorName" :errorMessages="affiliationErrorMessages"></ror-search>
              </v-col>
              <v-col cols="12" md="10" v-if="affiliationRadio === 'other'">
                <v-text-field
                  :value="affiliationText"
                  :label="$t('Affiliation')"
                  v-on:blur="$emit('input-affiliation-other',$event.target.value)"
                  :filled="inputStyle==='filled'"
                  :outlined="inputStyle==='outlined'"
                  :error-messages="affiliationTextErrorMessages"
                  :background-color="affiliationBackgroundColor ? affiliationBackgroundColor : undefined"
                ></v-text-field>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>
    </v-col>
    <org-units-tree-dialog ref="organizationstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event), 'organizationPath', 'input-organization-select')"></org-units-tree-dialog>
    <org-units-tree-dialog ref="affiliationstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event), 'affiliationPath', 'input-affiliation-select')"></org-units-tree-dialog>
  </v-row>
</template>

<script>
import { mask } from 'vue-the-mask'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'
import RorSearch from '../select/RorSearch'

export default {
  name: 'p-i-entity-extended',
  mixins: [ vocabulary, fieldproperties, validationrules ],
  components: {
    OrgUnitsTreeDialog,
    RorSearch
  },
  directives: {
    mask
  },
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
    identifierVocabulary: {
      type: String,
      default: 'entityidentifiertype'
    },
    showIds: {
      type: Boolean,
      default: false
    },
    enableTypeSelect: {
      type: Boolean,
      default: true
    },
    organizationSelectLabel: {
      type: String,
      default: 'Please choose'
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
    }
  },
  computed: {
    instanceconfig: function () {
      return this.$root.$store.state.instanceconfig
    },
    appconfig: function () {
      return this.$root.$store.state.appconfig
    },
    identifierTypePlaceholder: function () {
      for (let i of this.vocabularies[this.identifierVocabulary].terms) {
        if (i['@id'] === this.identifierType) {
          return i['skos:example']
        }
      }
      return ''
    },
    orgunits: function () {
      let units = this.vocabularies['orgunits'].terms
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
      await this.$store.dispatch('vocabulary/loadOrgUnits', this.$i18n.locale)
      this.loading = !this.vocabularies[this.roleVocabulary].loaded
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
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
