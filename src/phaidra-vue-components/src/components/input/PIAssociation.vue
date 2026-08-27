<template>
  <v-row v-if="!hidden">
    <v-col cols="10">
      <v-autocomplete
        :model-value="getTerm('orgunits', value)"
        :required="required"
        @update:model-value="handleInput($event)"
        :rules="required ? [ v => !!v || $t('Required')] : []"
        :items="getOrgUnitsTerms"
        item-value="@id"
        :item-title="(item) => skosTermItemTitle(item, 'orgunits')"
        :loading="loading"
        :custom-filter="orgunitsAutocompleteFilter"
        hide-no-data
        :label="$t(label)"
        :variant="fieldVariant"
        return-object
        clearable
        :disabled="disabled"
        :messages="path"
        :error-messages="errorMessages"
      >
        <template #item="{ props, internalItem }">
          <v-list-item v-bind="props" :lines="showIds ? 'two' : 'one'">
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
          <v-icon @click="$refs.orgunitstreedialog.open()">mdi-file-tree</v-icon>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ props: activatorProps }">
          <v-icon-btn v-bind="activatorProps" variant="text" icon="mdi-dots-vertical" />
        </template>
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
    <org-units-tree-dialog ref="orgunitstreedialog" :isParentSelectionDisabled="parentSelectionDisabled" :selected="value" @unit-selected="handleInput(getTerm('orgunits', $event))"></org-units-tree-dialog>
  </v-row>
</template>

<script>
import { useHostRootStore as useRootStore } from '../../stores/host-root'
import { useVocabularyStore } from '../../stores/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import { vocabulary } from '../../mixins/vocabulary'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'

export default {
  name: 'p-i-association',
  mixins: [fieldproperties, vocabulary],
  components: {
    OrgUnitsTreeDialog
  },
  emits: ['input', 'configure', 'add', 'remove', 'add-clear', 'up', 'down'],
  computed: {
    instanceconfig: function () {
      return useRootStore().instanceconfig
    },
    parentSelectionDisabled: function () {
      return this.isParentSelectionDisabled || this.instanceconfig?.isParentSelectionDisabled || false
    },
    getOrgUnitsTerms: function () {
      return !this.parentSelectionDisabled ? this.vocabularies['orgunits'].terms : this.vocabularies['orgunits'].terms.filter(element => !element.hasChildren)
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
          pathLabels.push(u['skos:prefLabel'][this?.$i18n?.locale || 'eng'])
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
        useVocabularyStore().loadOrgUnits(this?.$i18n?.locale || 'eng')
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
