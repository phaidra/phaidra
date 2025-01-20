<template>
  <v-row v-if="!hidden">
    <v-col cols="4" v-if="!hideRole">
        <v-autocomplete
          :disabled="disablerole"
          v-on:input="$emit('input-role', $event)"
          :label="$t(roleLabel ? roleLabel : 'Role')"
          :items="rolesArray"
          :item-value="'@id'"
          :value="getTerm(roleVocabulary, role)"
          :filter="autocompleteFilter"
          :filled="inputStyle==='filled'"
          :outlined="inputStyle==='outlined'"
          return-object
          clearable
          :error-messages="roleErrorMessages"
        >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel(roleVocabulary, item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle class="role-definition" v-if="showDefinitions" v-html="`${getLocalizedDefinition(roleVocabulary, item['@id'])}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel(roleVocabulary, item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <template v-if="type === 'schema:Person'">
      <template v-if="showname">
        <v-col cols="6" >
          <v-text-field
            :value="name"
            :label="$t(nameLabel ? nameLabel : 'Name')"
            v-on:blur="$emit('input-name',$event.target.value)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
            :error-messages="nameErrorMessages"
          ></v-text-field>
        </v-col>
      </template>
      <template v-else>
        <v-col :cols="showIdentifier ? '2' : '3'">
          <v-text-field
            :value="firstname"
            :label="$t(firstnameLabel ? firstnameLabel : 'Firstname')"
            v-on:blur="$emit('input-firstname',$event.target.value)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
            :error-messages="firstnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col :cols="showIdentifier ? '2' : '3'">
          <v-text-field
            :value="lastname"
            :label="$t(lastnameLabel ? lastnameLabel : 'Lastname')"
            v-on:blur="$emit('input-lastname',$event.target.value)"
            :filled="inputStyle==='filled'"
            :outlined="inputStyle==='outlined'"
            :error-messages="lastnameErrorMessages"
          ></v-text-field>
        </v-col>
        <v-col v-if="showIdentifier" :cols="showIdentifier ? '2' : '3'">
          <v-text-field
              v-show="identifierType === 'ids:orcid'"
              v-mask="'####-####-####-###X'"
              :value="identifierText"
              :label="identifierLabel ? identifierLabel : $t('ORCID')"
              v-on:blur="$emit('input-identifier', $event.target.value)"
              :placeholder="identifierTypePlaceholder"
              :rules="identifierType ? [validationrules['orcid']] : [validationrules['noop']]"
              :filled="inputStyle==='filled'"
              :outlined="inputStyle==='outlined'"
            ></v-text-field>
            <v-text-field
              v-show="identifierType !== 'ids:orcid'"
              :value="identifierText"
              :label="identifierLabel ? identifierLabel : $t('Identifier')"
              v-on:blur="$emit('input-identifier', $event.target.value)"
              :placeholder="identifierTypePlaceholder"
              :rules="identifierType ? [validationrules[getIdentifierRuleName(identifierType)]] : [validationrules['noop']]"
              :filled="inputStyle==='filled'"
              :outlined="inputStyle==='outlined'"
            ></v-text-field>
        </v-col>
      </template>
    </template>
    <v-col cols="6" v-if="type === 'schema:Organization'">
      <v-text-field
        :value="organizationText"
        :label="$t( organizationLabel ? organizationLabel : 'Organization' )"
        v-on:blur="$emit('input-organization',$event.target.value)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        :error-messages="organizationErrorMessages"
      ></v-text-field>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on }">
          <v-btn v-on="on" icon>
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
          <v-list-item @click="$emit('extend', $event)">
            <v-list-item-title>{{ $t('Extend') }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
  </v-row>
</template>

<script>
import { mask } from 'vue-the-mask'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { validationrules } from '../../mixins/validationrules'

export default {
  name: 'p-i-entity',
  mixins: [vocabulary, fieldproperties, validationrules],
  directives: {
    mask
  },
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
