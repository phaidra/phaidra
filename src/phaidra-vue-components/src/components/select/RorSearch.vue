<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card outlined class="mb-8">
        <v-card-title class="title font-weight-light white--text">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-menu open-on-hover bottom offset-y v-if="actions.length">
            <template v-slot:activator="{ on, attrs }">
              <v-btn v-on="on" v-bind="attrs" icon dark>
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
                :label="$t(label)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
                clearable
                :messages="resolved"
                :error-messages="errorMessages"
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
            <template v-slot:item.acronyms="{ item }">
              <template v-if="item.acronyms">
                <div v-for="(v, i) of item.acronyms" :key="'vn' + i">{{ v }}</div>
              </template>
            </template>
            <template v-slot:item.aliases="{ item }">
              <template v-if="item.aliases">
                <div v-for="(v, i) of item.aliases" :key="'va' + i">{{ v }}</div>
              </template>
            </template>
            <template v-slot:item.types="{ item }">
              <template v-if="item.types">
                <div v-for="(v, i) of item.types" :key="'vt' + i">{{ v }}</div>
              </template>
            </template>
            <template v-slot:item.addresses="{ item }">
              <template v-if="item.addresses">
                <div v-for="(v, i) of item.addresses" :key="'vad' + i">{{ v.city }}</div>
              </template>
            </template>
            <template v-slot:item.country="{ item }">
              <template v-if="item.country">
                {{ item.country.country_name }}
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
  name: 'ror-search',
  mixins: [vocabulary, fieldproperties],
  props: {
    value: {
      type: String
    },
    text: {
      type: String
    },
    label: {
      type: String,
      default: 'ROR Search'
    },
    searchlabel: {
      type: String,
      default: ''
    },
    errorMessages: {
      type: Array
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
    }//, 
    // text: {
    //   handler () {
    //     const item = {
    //       id: this.value,
    //       name: this.text
    //     }
    //     this.resolve(item)
    //   }
    // }
  },
  data () {
    return {
      showItems: false,
      items: [],
      loading: false,
      q: null,
      selected: null,
      resolved: '',
      options: {
        page: 1
      },
      total: 0,
      headers: [
        { text: 'ID', value: 'id' },
        { text: 'Name', value: 'name' },
        { text: 'Acronyms', value: 'acronyms' },
        { text: 'Aliases', value: 'aliases' },
        { text: 'Types', value: 'types' },
        { text: 'City', value: 'addresses' },
        { text: 'Country', value: 'country' }
      ]
    }
  },
  methods: {
    resolve: async function (item) {
      if (item) {
        this.$emit('input', item.id)
        this.resolved = '<a href="' + item.id + '" target="_blank">' + item.name + '</a>'
        this.$emit('resolve', {
          '@type': 'schema:Organization',
          'skos:exactMatch': [ item.id ],
          'schema:name': [ { '@value': item.name } ]
        }
        )
        this.q = item.name
        this.showItems = false
      }
    },
    search: async function () {
      this.loading = true
      this.items = []
      this.selected = null

      var params = {
        page: this.options.page,
        query: this.q,
        format: 'json'
      }

      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: 'https://' + this.$store.state.appconfig.apis.ror.baseurl + '/organizations',
          params: params
        })
        this.items = response.data.items
        this.total = response.data.number_of_results
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
  },
  mounted: async function () {
    if (this.value) {
      const item = {
        id: this.value,
        name: this.text
      }
      this.resolve(item)
    }
  }
}
</script>
