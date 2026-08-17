<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card :loading="loading">
      <v-card-title class="text-title-large font-weight-light text-white">{{ $t('Select a term') }}</v-card-title>
      <v-card-text class="mt-4">
        <v-treeview
          :items="items"
          :item-title="skosVTreeItemTitle"
          :item-value="'@id'"
          :load-children="loadChildren"
        >
          <template #title="{ item }">
            <div @click="selectTerm(item)">
              {{
                item['skos:prefLabel'][$i18n.locale]
                  ? item['skos:prefLabel'][$i18n.locale]
                  : item['skos:prefLabel']['eng'] +
                    (item['skos:notation']?.[0] != null ? ' - ' + item['skos:notation'][0] : '')
              }}
            </div>
          </template>
        </v-treeview>
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
import { useHostRootStore as useRootStore } from '../../stores/host-root'
import { vocabulary } from '../../mixins/vocabulary'

export default {
  name: 'bic-tree-dialog',
  mixins: [ vocabulary ],
  computed: {
    instance: function () {
      return useRootStore().instanceconfig
    },
    items: function () {
      return this.vocabularies['bic']['tree']
    }
  },
  data () {
    return {
      dialog: false,
      loading: false,
      renderComponent: true
    }
  },
  methods: {
    prepareTree: function () {
      this.prepareLazyTree(this.items)
    },
    loadChildren: async function (item) {
      this.loadLazyTreeChildren(item)
    },
    open: async function () {
      this.prepareTree()
      this.dialog = true
    },
    selectTerm: function (term) {
      this.$emit('term-selected', term)
      this.dialog = false
    }
  }
}
</script>
