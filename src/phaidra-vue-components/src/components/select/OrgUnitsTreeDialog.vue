<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card :loading="loading">
      <v-card-title class="title font-weight-light text-white">{{ $t('Select an organizational unit') }}</v-card-title>
      <v-card-text class="mt-4">
        <v-treeview
          v-model:opened="openedUnits"
          v-model:activated="activatedUnits"
          :items="orgunits"
          :item-children="orgunitChildren"
          item-title="name"
          item-value="@id"
          activatable
          color="primary"
          @update:activated="selectUnit"
        ></v-treeview>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-actions>
        <v-container fluid>
          <v-row justify="end" class="px-4">
            <v-btn variant="outlined" @click="dialog = false">{{ $t('Cancel') }}</v-btn>
          </v-row>
        </v-container>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'org-units-tree-dialog',
  mixins: [ vocabulary ],
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    },
    orgunits: function () {
      return this.vocabularies['orgunits']['tree']
    }
  },
  data () {
    return {
      dialog: false,
      loading: false,
      openedUnits: [],
      activatedUnits: []
    }
  },
  props: {
    isParentSelectionDisabled: {
      type: Boolean,
      default: false
    },
    selected: {
      type: String,
      default: null
    }
  },
  methods: {
    orgunitChildren (item) {
      const subunits = item?.subunits
      return Array.isArray(subunits) && subunits.length > 0 ? subunits : undefined
    },
    open: async function () {
      this.dialog = true
      this.addNames(this.orgunits)
      const root = this.orgunits && this.orgunits[0]
      this.openedUnits = root && root['@id'] != null ? [root['@id']] : []
      this.activatedUnits = this.selected ? [this.selected] : []
    },
    addNames: function (units) {
      for (let u of units) {
        if (u['skos:prefLabel']) {
          u['name'] = u['skos:prefLabel'][this.$i18n.locale]
        }
        if (u['subunits'] && u.subunits.length > 0) {
          this.addNames(u.subunits)
        }
      }
    },
    selectUnit: function (activated) {
      if (!activated?.length) {
        return
      }
      const id = activated[0]
      if (this.isParentSelectionDisabled && this.getTerm('orgunits', id)?.hasChildren) {
        this.activatedUnits = this.selected ? [this.selected] : []
        return
      }
      this.$emit('unit-selected', id)
      this.dialog = false
    }
  }
}
</script>
