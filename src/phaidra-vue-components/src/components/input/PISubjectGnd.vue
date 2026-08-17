<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-row>
        <v-col cols="12">
          <v-card variant="outlined" class="mb-8">
            <v-card-title class="text-title-large font-weight-light text-white">
              <span>{{ $t(label) }}</span>
              <v-spacer></v-spacer>
              <v-menu open-on-hover bottom offset-y v-if="actions.length">
                <template v-slot:activator="{ props }">
                  <v-icon-btn v-bind="props" variant="text" color="white" icon="mdi-dots-vertical" />
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
                    :variant="fieldVariant"
                    clearable
                    :messages="resolved"
                    append-inner-icon="mdi-magnify"
                    @click:append-inner="search()"
                    @keyup.enter="search()"
                  >
                  <template v-slot:message="{ key, message }">
                    <span v-html="`${message}`"></span>
                  </template>
                  </v-text-field>
                </v-col>
              </v-row>
              <v-row v-if="showItems">
                <v-data-table-server
                  v-model:options="options"
                  :headers="headers"
                  :items="items"
                  :items-length="total"
                  :loading="loading"
                  :no-data-text="$t('No data available')"
                  :page-text="$t('Page')"
                  :items-per-page-text="$t('Rows per page')"
                  :row-props="({ item }) => ({ style: 'cursor: pointer', onClick: () => select(item) })"
                >
                <template v-slot:item.variantName="{ item }">
                  <template v-if="item.variantName">
                    <div v-for="(v, i) of item.variantName" :key="'vn' + i">{{ v }}</div>
                  </template>
                </template>
                <template v-slot:item.type="{ item }">
                  <template v-if="item.type">
                    <div v-for="(v, i) of item.type" :key="'vt' + i">{{ v }}</div>
                  </template>
                </template>
                </v-data-table-server>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
      <v-row v-if="dividerbottom">
        <v-divider class="mt-2 mb-6"></v-divider>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-subject-gnd',
  mixins: [vocabulary, fieldproperties],
  emits: ['input', 'resolve', 'configure', 'add', 'remove', 'add-clear', 'up', 'down'],
  props: {
    value: {
      type: String
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
    required: {
      type: Boolean
    },
    disabletype: {
      type: Boolean
    },
    showIds: {
      type: Boolean,
      default: false
    },
    dividerbottom: {
      type: Boolean,
      default: false
    },
    prefLabel: {
      type: Array,
      default: false
    }
  },
  watch: {
    options: {
      handler () {
        this.search()
      },
      deep: true
    },
    selected (item) {
      (item !== null) && this.resolve(item)
    },
    q (val) {
      if ((val === null || val === '') && this.value) {
        this.preflabel = []
        this.rdfslabel = []
        this.resolved = ''
        this.selected = null
        this.items = []
        this.showItems = false
        this.$emit('input', null)
        this.$emit('resolve', null)
      }
    }
  },
  mounted() {
    if(this.prefLabel?.length){
      this.resolved = '<a href="' + this.value + '" target="_blank">' + this.prefLabel[0]['@value'] + '</a>'
      this.q = this.prefLabel[0]['@value']
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
      resolved: '',
      options: {
        itemsPerPage: 10,
        page: 1
      },
      total: 0,
      headers: [
        { title: 'ID', key: 'gndIdentifier' },
        { title: 'Preferred name', key: 'preferredName' },
        { title: 'Variant name', key: 'variantName' },
        { title: 'Type', key: 'type' },
        { title: 'Description', key: 'biographicalOrHistoricalInformation' }
      ]
    }
  },
  methods: {
    resolve: async function (item) {
      if (item) {
        this.$emit('input', item.id)
        this.preflabel = [
          {
            '@value': item.preferredName
          }
        ]
        if (item.hasOwnProperty('variantName')) {
          for (const vn of item.variantName) {
            this.rdfslabel.push({ '@value': vn })
          }
        }
        this.resolved = '<a href="' + item.id + '" target="_blank">' + item.preferredName + '</a>'
        this.$emit('resolve', { 'skos:prefLabel': this.preflabel, 'rdfs:label': this.rdfslabel })
        this.q = item.preferredName
        this.showItems = false
      } else {
        this.preflabel = []
        this.rdfslabel = []
        this.resolved = ''
        this.$emit('input', null)
        this.$emit('resolve', null)
      }
    },
    search: async function () {
      this.loading = true
      this.items = []
      this.selected = null

      var params = {
        size: this.options.itemsPerPage,
        from: ((this.options.page - 1) * this.options.itemsPerPage),
        q: 'preferredName:' + this.q + ' OR gndIdentifier:' + this.q
      }

      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/gnd/search',
          params: params
        })
        this.items = response.data.member
        this.total = response.data.totalItems
        this.showItems = true
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    },
    select (item) {
      this.selected = item
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
