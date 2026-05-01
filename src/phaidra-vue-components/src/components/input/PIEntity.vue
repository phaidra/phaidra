<template>
  <v-row v-if="!hidden">
    <v-col cols="4" v-if="!hideRole">
        <v-autocomplete
          :no-data-text="$t('No data available')"
          :disabled="disablerole"
          @update:model-value="$emit('input-role', $event)"
          :label="$t(roleLabel ? roleLabel : 'Role')"
          :items="rolesArray"
          item-value="@id"
          :item-title="roleItemTitle"
          :model-value="getTerm(roleVocabulary, role)"
          :variant="fieldVariant"
          return-object
          clearable
          :error-messages="roleErrorMessages"
        >
        <template #item="{ props, internalItem }">
          <v-list-item
            v-bind="props"
            :lines="showDefinitions ? 'two' : 'one'"
          >
            <template #title>
              <span v-html="getLocalizedTermLabel(roleVocabulary, internalItem.raw['@id'])"></span>
            </template>
            <template v-if="showDefinitions" #subtitle>
              <span class="role-definition" v-html="getLocalizedDefinition(roleVocabulary, internalItem.raw['@id'])"></span>
            </template>
          </v-list-item>
        </template>
        <template #selection="{ internalItem }">
          <span v-html="getLocalizedTermLabel(roleVocabulary, (internalItem.raw || internalItem)['@id'])"></span>
        </template>
      </v-autocomplete>
    </v-col>
    <template v-if="type === 'schema:Person'">
      <template v-if="showname">
        <v-col cols="6" >
          <v-text-field
            :model-value="name"
            @update:model-value="$emit('input-name', $event)"
            :label="$t(nameLabel ? nameLabel : 'Name')"
            :variant="fieldVariant"
            :error-messages="nameErrorMessages"
          ></v-text-field>
        </v-col>
      </template>
      <template v-else>
        <v-col :cols="showIdentifier ? '2' : '3'">
          <v-text-field
            :model-value="firstname"
            @update:model-value="$emit('input-firstname', $event)"
            :label="$t(firstnameLabel ? firstnameLabel : 'Firstname')"
            :variant="fieldVariant"
            :error-messages="firstnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col :cols="showIdentifier ? '2' : '3'">
          <v-text-field
            :model-value="lastname"
            @update:model-value="$emit('input-lastname', $event)"
            :label="$t(lastnameLabel ? lastnameLabel : 'Lastname')"
            :variant="fieldVariant"
            :error-messages="lastnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col v-if="showIdentifier" :cols="showIdentifier ? '2' : '3'">
          <v-text-field
              v-show="identifierType === 'ids:orcid'"
              v-maska data-maska="####-####-####-####"
              :model-value="identifierText"
              @update:model-value="$emit('input-identifier', $event)"
              :label="identifierLabel ? identifierLabel : $t('ORCID')"
              :placeholder="identifierTypePlaceholder"
              :rules="identifierType ? [validationrules['orcid']] : [validationrules['noop']]"
              :variant="fieldVariant"
            ></v-text-field>
            <v-text-field
              v-show="identifierType !== 'ids:orcid'"
              :model-value="identifierText"
              @update:model-value="$emit('input-identifier', $event)"
              :label="identifierLabel ? identifierLabel : $t('Identifier')"
              :placeholder="identifierTypePlaceholder"
              :rules="identifierType ? [validationrules[getIdentifierRuleName(identifierType)]] : [validationrules['noop']]"
              :variant="fieldVariant"
            ></v-text-field>
        </v-col>
      </template>
    </template>
    <v-col
      :cols="multilingual
        ? (actions.length ? 4 : 6)
        : (hideRole
          ? (actions.length ? 10 : 12)
          : (actions.length ? 6 : 8)
        )"
      v-if="type === 'schema:Organization'">
      <v-text-field
        :model-value="organizationText"
        @update:model-value="$emit('input-organization', $event)"
        :label="$t( organizationLabel ? organizationLabel : 'Organization' )"
        :variant="fieldVariant"
        :error-messages="organizationErrorMessages"
      ></v-text-field>
    </v-col>
    <v-col cols="12" md="2" v-if="(type === 'schema:Organization' && multilingual) || actions.length">
      <v-row>
        <v-col v-if="type === 'schema:Organization' && multilingual" cols="6">
          <v-btn variant="text" @click="$refs.langdialog.open()">
            <span>
              ({{ language ? language : '--' }})
            </span>
          </v-btn>
        </v-col>
        <v-col cols="6" v-if="actions.length">
          <v-menu location="bottom end" close-on-content-click>
            <template #activator="{ props: menuActivatorProps }">
              <v-btn icon v-bind="menuActivatorProps">
                <v-icon>mdi-dots-vertical</v-icon>
              </v-btn>
            </template>
            <v-list density="compact">
              <v-list-item
                v-for="(action, i) in actions"
                :key="i"
                @click="$emit(action.event, $event)"
              >
                <v-list-item-title>{{ action.title }}</v-list-item-title>
              </v-list-item>
              <v-list-item @click="$emit('extend', $event)">
                <v-list-item-title>{{ $t('Extend') }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
        </v-col>
      </v-row>

      <select-language v-if="type === 'schema:Organization' && multilingual" ref="langdialog" :showReset="allowLanguageCancel && language ? true : false" @language-selected="$emit('input-language', $event)"></select-language>
    </v-col>
  </v-row>
</template>

<script>
import { vMaska } from 'maska/vue'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'
import SelectLanguage from '../select/SelectLanguage'

export default {
  name: 'p-i-entity',
  mixins: [vocabulary, fieldproperties, validationrules],
  components: {
    SelectLanguage
  },
  directives: {
    maska: vMaska
  },
  emits: [
    'input',
    'input-role',
    'input-firstname',
    'input-lastname',
    'input-name',
    'input-identifier',
    'input-organization',
    'add',
    'remove',
    'configure',
    'up',
    'down',
    'extend'
  ],
  props: {
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
    organizationText: {
      type: String
    },
    organizationLabel: {
      type: String
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
    organizationErrorMessages: {
      type: Array
    },
    showIdentifier: {
      type: Boolean,
      default: false
    },
    identifierVocabulary: {
      type: String,
      default: 'entityidentifiertype'
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
    language: {
      type: String
    },
    multilingual: {
      type: Boolean
    },
    allowLanguageCancel: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    rolesArray () {
      let arr = this.vocabularies[this.roleVocabulary].terms
      let otherRole = arr.find(elem => elem['@id'] === 'role:oth')
      let filteredRoles = arr.filter(elem => elem['@id'] !== 'role:oth')
      arr = filteredRoles
      arr.unshift(otherRole)
      return arr
    },
    identifierTypePlaceholder: function () {
      for (let i of this.vocabularies[this.identifierVocabulary].terms) {
        if (i['@id'] === this.identifierType) {
          return i['skos:example']
        }
      }
      return ''
    }
  },
  methods: {
    roleItemTitle (item) {
      if (!item || !item['@id']) return ''
      return this.getLocalizedTermLabel(this.roleVocabulary, item['@id'])
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      this.loading = !this.vocabularies[this.roleVocabulary].loaded
      this.$store.dispatch('vocabulary/sortRoles', this.$i18n.locale)
      // emit input to set skos:prefLabel in parent
      if (this.role) {
        this.$emit('input', this.getTerm(this.roleVocabulary, this.role))
      }
    })
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
