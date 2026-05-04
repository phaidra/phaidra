<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card :loading="loading">
      <v-card-title class="title font-weight-light text-white">{{ $t('Select an organizational unit') }}</v-card-title>
      <v-card-text class="mt-4">
        <v-treeview
          v-model:opened="openedUnits"
          :items="orgunits"
          item-children="subunits"
          item-title="name"
          :item-value="'@id'"
          activatable
          return-object
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
      openedUnits: []
    }
  },
  props: {
    isParentSelectionDisabled: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    open: async function () {
      this.dialog = true
      this.addNames(this.orgunits)
      const root = this.orgunits && this.orgunits[0]
      this.openedUnits = root && root['@id'] != null ? [root['@id']] : []
    },
    addNames: function (units) {
      for (let u of units) {
        if (u['skos:prefLabel']) {
          const pl = u['skos:prefLabel']
          u.name = pl[this.$i18n.locale] || pl.eng || pl.deu || Object.values(pl).find(Boolean) || ''
        }
        if (u['subunits']) {
          if (u.subunits.length > 0) {
            this.addNames(u.subunits)
          }
        }
      }
    },
    selectUnit: function (activated) {
      const list = Array.isArray(activated) ? activated : activated != null ? [activated] : []
      if (!list.length) {
        return
      }
      const node = list[0]
      if (this.isParentSelectionDisabled && typeof node === 'object' && node?.subunits?.length > 0) {
        return
      }
      const id = typeof node === 'object' && node != null ? node['@id'] : node
      if (id == null) {
        return
      }
      this.$emit('unit-selected', id)
      this.dialog = false
    }
  }
}
</script>
