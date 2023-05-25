<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card :loading="loading">
      <v-card-title class="grey white--text">{{ $t('Select a term') }}</v-card-title>
      <v-card-text>
        <v-treeview
          :active.sync="active"
          :items="items"
          :load-children="loadChildren"
          :open.sync="opened"
          item-key="uri"
          transition
          activatable
          hoverable
          @update:active="selectItem($event)
          ">
        </v-treeview>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-actions>
        <v-container fluid>
          <v-row justify="end" class="px-4">
            <v-btn color="grey" dark @click="dialog = false">{{ $t('Cancel') }}</v-btn>
          </v-row>
        </v-container>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>

export default {
  name: 'bk-tree-dialog',
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      dialog: false,
      loading: false,
      items: [],
      opened: [],
      active: [],
      init: true
    }
  },
  methods: {
    open: async function () {
      this.dialog = true
      if (this.init) {
        this.loadRoot()
        this.init = false
      }
    },
    loadRoot: async function () {
      this.items = [
        {
          uri: 'http://uri.gbv.de/terminology/bk/0',
          notation: ['0'],
          name: 'Allgemeine Werke und Philosophie',
          children: []
        },
        {
          uri: 'http://uri.gbv.de/terminology/bk/1-2',
          notation: ['1-2'],
          name: 'Geisteswissenschaften',
          children: []
        },
        {
          uri: 'http://uri.gbv.de/terminology/bk/3-4',
          notation: ['3-4'],
          name: 'Naturwissenschaften',
          children: []
        },
        {
          uri: 'http://uri.gbv.de/terminology/bk/5',
          notation: ['5'],
          name: 'Ingenieurwissenschaften',
          children: []
        },
        {
          uri: 'http://uri.gbv.de/terminology/bk/7-8',
          notation: ['7-8'],
          name: 'Sozialwissenschaften',
          children: []
        }
      ]
    },
    loadChildren: async function (item) {
      var params = {
        properties: 'notation,narrower,ancestors',
        uri: item.uri
      }
      try {
        let response = await this.$http.request({
          method: 'GET',
          url: this.$store.state.appconfig.apis.dante.resolve,
          params: params
        })
        if (response.data) {
          for (let ob of response.data) {
            if (ob.narrower) {
              for (let nar of ob.narrower) {
                item.children.push({
                  uri: nar.uri,
                  name: nar.prefLabel.de,
                  children: []
                })
              }
            }
          }
        }
        this.showItems = true
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    },
    selectItem: async function (uri) {
      var params = {
        properties: 'notation,ancestors',
        uri: uri[0]
      }
      try {
        let response = await this.$http.request({
          method: 'GET',
          url: this.$store.state.appconfig.apis.dante.resolve,
          params: params
        })
        this.$emit('item-selected', response.data[0])
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
      this.dialog = false
    }
  }
}
</script>
