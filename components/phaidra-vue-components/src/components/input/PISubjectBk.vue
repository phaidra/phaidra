<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card outlined class="mb-8">
        <v-card-title class="title font-weight-light grey white--text">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-menu open-on-hover bottom offset-y v-if="actions.length">
            <template v-slot:activator="{ on }">
              <v-btn v-on="on" icon dark>
                <v-icon dark>mdi-dots-vertical</v-icon>
              </v-btn>
            </template>
            <v-list>
              <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
                <v-list-item-title>{{ action.title }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row>
            <v-col cols="9">
              <v-text-field
                v-model="q"
                :loading="loading"
                :label="$t(searchlabel)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
                clearable
                :messages="resolved"
                append-icon="mdi-magnify"
                @click:append="search()"
                @keyup.enter="search()"
              >
              <template v-slot:message="{ key, message }">
                <span v-html="`${message}`"></span>
              </template>
              <template v-slot:append-outer>
                <v-icon @click="$refs.bktreedialog.open()">mdi-file-tree</v-icon>
              </template>
              </v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12" md="9" v-show="showItems">
              <v-list two-line style="max-height: 400px" class="overflow-y-auto">
                <v-list-item-group v-model="selected" active-class="text--primary">
                  <template v-for="(item, index) in items">
                    <v-list-item :key="item.uri">
                      <template v-slot:default="{ active }">
                        <v-list-item-content>
                          <v-list-item-title v-text="item.prefLabel.de"></v-list-item-title>
                          <v-list-item-subtitle v-for="(notation, idx) in item.notation" :key="'not'+idx" class="text--primary" v-text="notation"></v-list-item-subtitle>
                        </v-list-item-content>
                      </template>
                    </v-list-item>
                    <v-divider v-if="index < items.length - 1" :key="index"></v-divider>
                  </template>
                </v-list-item-group>
              </v-list>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
    <bk-tree-dialog ref="bktreedialog" @item-selected="resolve($event)"></bk-tree-dialog>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
import BkTreeDialog from '../select/BkTreeDialog'

export default {
  name: 'p-i-subject-bk',
  components: {
    BkTreeDialog
  },
  mixins: [vocabulary, fieldproperties],
  props: {
    value: {
      type: String,
      required: true
    },
    type: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    searchlabel: {
      type: String,
      default: ''
    },
    initquery: {
      type: String
    },
    required: {
      type: Boolean
    },
    disabletype: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  watch: {
    selected (val) {
      (val !== null) && this.resolve(this.items[val])
    }
  },
  data () {
    return {
      showItems: false,
      items: [],
      loading: false,
      q: null,
      selected: null,
      preflabel: [],
      rdfslabel: [],
      resolved: ''
    }
  },
  methods: {
    resolve: async function (selectedItem) {
      if (selectedItem) {
        this.$emit('input', selectedItem.uri)
        this.q = selectedItem.notation[0] + ' ' + selectedItem.prefLabel?.de
        this.preflabel.push({ '@value': selectedItem.notation[0] + ' ' + selectedItem.prefLabel?.de, '@language': 'deu' })
        let path = selectedItem.prefLabel?.de
        this.resolved = '<a href="' + selectedItem.uri + '" target="_blank">' + selectedItem.notation[0] + ' ' + selectedItem.prefLabel?.de + '</a>'
        if (selectedItem.ancestors) {
          for (let anc of selectedItem.ancestors) {
            path = anc.prefLabel?.de + ' -- ' + path
            this.resolved = '<a href="' + anc.uri + '" target="_blank">' + anc.prefLabel?.de + '</a>' + ' -- ' + this.resolved
          }
        }
        this.rdfslabel.push({ '@value': path, '@language': 'deu' })
        this.$emit('resolve', { 'skos:prefLabel': this.preflabel, 'rdfs:label': this.rdfslabel, 'skos:notation': selectedItem.notation[0] })
        this.showItems = false
      } else {
        this.$emit('input', null)
      }
    },
    search: async function () {
      this.loading = true
      this.items = []
      this.selected = null
      var params = {
        voc: 'bk',
        limit: this.$store.state.appconfig.apis.dante.limit,
        properties: 'notation,ancestors',
        query: this.q + '*'
      }
      try {
        let response = await this.$http.request({
          method: 'GET',
          url: this.$store.state.appconfig.apis.dante.search,
          params: params
        })
        this.items = response.data
        this.showItems = true
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    }
  },
  mounted: function () {
    if (this.initquery) {
      this.items = [{ value: this.value, text: this.initquery }]
      this.q = { value: this.value, text: this.initquery }
      this.resolve(this.value)
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
