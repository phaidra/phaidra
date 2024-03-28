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
              </v-text-field>
            </v-col>
          </v-row>
          <v-row v-if="showItems">
            <v-data-table
              :headers="headers"
              :items="items"
              :options.sync="options"
              :server-items-length="total"
              :loading="loading"
              @click:row="select"
              :no-data-text="$t('No data available')"
              :footer-props="{
                pageText: $t('Page'),
                itemsPerPageText: $t('Rows per page'),
                itemsPerPageAllText: $t('All')
              }"
              :no-results-text="$t('There were no search results')"
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
            </v-data-table>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-subject-gnd',
  mixins: [vocabulary, fieldproperties],
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
        { text: 'ID', value: 'gndIdentifier' },
        { text: 'Preferred name', value: 'preferredName' },
        { text: 'Variant name', value: 'variantName' },
        { text: 'Type', value: 'type' },
        { text: 'Description', value: 'biographicalOrHistoricalInformation' }
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
        this.$emit('input', null)
      }
    },
    search: async function () {
      this.loading = true
      this.items = []
      this.selected = null

      var params = {
        size: this.options.itemsPerPage,
        from: ((this.options.page - 1) * this.options.itemsPerPage),
        q: 'preferredName:' + this.q + ' OR gndIdentifier:' + this.q,
        format: 'json'
      }

      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: 'https://' + this.$store.state.appconfig.apis.lobid.baseurl + '/gnd/search',
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
