<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card :loading="loading">
      <v-card-title class="title font-weight-light white--text">{{ $t('Select an organizational unit') }}</v-card-title>
      <v-card-text class="mt-4">
        <v-treeview :open="orgunits && orgunits.length > 0 ? [orgunits[0]] : []" :items="orgunits" item-children="subunits" item-key="@id" hoverable activatable return-object @update:active="selectUnit($event)"></v-treeview>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-actions>
        <v-container fluid>
          <v-row justify="end" class="px-4">
            <v-btn outlined @click="dialog = false">{{ $t('Cancel') }}</v-btn>
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
      loading: false
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
    },
    addNames: function (units) {
      for (let u of units) {
        if (u['skos:prefLabel']) {
          u['name'] = u['skos:prefLabel'][this.$i18n.locale]
        }
        if (u['subunits']) {
          if (u.subunits.length > 0) {
            this.addNames(u.subunits)
          }
        }
      }
    },
    selectUnit: function (item) {
      if(item.length === 0) {
        return
      }
      if (this.isParentSelectionDisabled && item[0].subunits?.length > 0) {
        return
      }
      this.$emit('unit-selected', item[0]['@id'])
      this.dialog = false
    }
  }
}
</script>
