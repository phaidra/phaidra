<template>
  <v-row v-if="!hidden">
    <v-col cols="10">
      <v-autocomplete
        :value="getTerm('orgunits', value)"
        :required="required"
        v-on:input="handleInput($event)"
        :rules="required ? [ v => !!v || 'Required'] : []"
        :items="getOrgUnitsTerms"
        :item-value="'@id'"
        :loading="loading"
        :filter="autocompleteFilterInfix"
        hide-no-data
        :label="$t(label)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
        :disabled="disabled"
        :messages="path"
        :error-messages="errorMessages"
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
          <v-icon @click="$refs.orgunitstreedialog.open()">mdi-file-tree</v-icon>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on, attrs }">
          <v-btn v-on="on" v-bind="attrs" icon>
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
    <org-units-tree-dialog ref="orgunitstreedialog" :isParentSelectionDisabled="isParentSelectionDisabled" @unit-selected="handleInput(getTerm('orgunits', $event))"></org-units-tree-dialog>
  </v-row>
</template>

<script>
import { fieldproperties } from '../../mixins/fieldproperties'
import { vocabulary } from '../../mixins/vocabulary'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'

export default {
  name: 'p-i-association',
  mixins: [fieldproperties, vocabulary],
  components: {
    OrgUnitsTreeDialog
  },
  computed: {
    getOrgUnitsTerms: function () {
      return !this.isParentSelectionDisabled ? this.vocabularies['orgunits'].terms : this.vocabularies['orgunits'].terms.filter(element => !element.hasChildren)
    }
  },
  methods: {
    handleInput: function (unit) {
      this.path = ''
      let pathArr = []
      if (unit) {
        if (!unit.hasOwnProperty('@id')) {
          unit = this.getTerm('orgunits', unit)
        }
        this.getOrgPath(unit, this.vocabularies['orgunits'].tree, pathArr)
        let pathLabels = []
        for (let u of pathArr) {
          pathLabels.push(u['skos:prefLabel'][this.$i18n.locale])
        }
        this.path = pathLabels.join(' > ')
      }
      this.$emit('input', unit)
    }
  },
  props: {
    value: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    errorMessages: {
      type: Array
    },
    required: {
      type: Boolean
    },
    disabled: {
      type: Boolean,
      default: false
    },
    showIds: {
      type: Boolean,
      default: false
    },
    isParentSelectionDisabled: {
      type: Boolean,
      default: false
    },
  },
  data () {
    return {
      loading: false,
      path: ''
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      if (!this.vocabularies['orgunits'].loaded) {
        this.$store.dispatch('vocabulary/loadOrgUnits', this.$i18n.locale)
      }
      // emit input to set skos:prefLabel in parent
      if (this.value) {
        this.handleInput(this.value)
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
