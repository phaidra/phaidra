<template>
  <v-card class="mt-4">
    <v-card-title class="title font-weight-light white--text">
      {{ title ? title : $t('Select an object') }}
      <v-spacer></v-spacer>
      <v-switch
        dark
        v-model="ownerFilter"
        :label="$t('Show only my objects')"
      ></v-switch>
    </v-card-title>
    <v-card-text>
      <v-text-field
        v-model="objectsSearch"
        append-icon="mdi-magnify"
        :label="$t('Search...')"
        @keydown="handleKeyDown"
        single-line
        hide-details
        class="mb-4"
        v-on:blur="search()"
      ></v-text-field>
      <v-data-table
        :headers="objectsHeaders"
        :items="objects"
        :loading="loading"
        :loading-text="$t('Loading...')"
        :options.sync="options"
        :server-items-length="totalObjects"
        :no-data-text="$t('No data available')"
        :footer-props="{
          itemsPerPageOptions: [10, 50, 100],
          pageText: $t('Page'),
          itemsPerPageText: $t('Rows per page'),
          itemsPerPageAllText: $t('All')
        }"
        :no-results-text="$t('There were no search results')"
      >
        <template v-slot:item.title="{ item }">
          <span v-if="item.dc_title">{{ item.dc_title[0] | truncate(50) }}</span>
        </template>
        <template v-slot:item.created="{ item }">
          {{ item.created | date }}
        </template>
        <template v-slot:item.actions="{ item }">
          <v-btn text color="primary" @click="selectObject(item)">{{ $t('Select') }}</v-btn>
        </template>
      </v-data-table>
    </v-card-text>
    <v-divider></v-divider>
  </v-card>
</template>

<script>
import qs from 'qs'

export default {
  name: 'object-from-search',
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  props: {
    title: {
      type: String
    },
    jsonldOnly: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      ownerFilter: false,
      loading: false,
      options: {
        page: 1,
        itemsPerPage: 10
        // sortBy: string[]
        // sortDesc: boolean[]
        // groupBy: string[]
        // groupDesc: boolean[]
        // multiSort: boolean
        // mustSort: boolean
      },
      objectsSearch: '',
      objectsHeaders: [],
      objects: [],
      totalObjects: 0
    }
  },
  watch: {
    '$i18n.locale': {
      immediate: true, // Ensure it's set on load
      handler() {
        this.objectsHeaders = [
        { text: this.$t('Pid'), align: 'left', value: 'pid' },
        { text: this.$t('Title'), align: 'left', value: 'title' },
        { text: this.$t('Created'), align: 'right', value: 'created' },
        { text: this.$t('Actions'), align: 'right', value: 'actions', sortable: false }
      ];
      }
    },
    options: {
      handler () {
        this.search()
      },
      deep: true
    },
    ownerFilter: {
      handler () {
        this.search()
      }
    }
  },
  methods: {
    search: async function () {
      this.loading = true
      let params = {
        q: this.objectsSearch ? this.objectsSearch : '*:*',
        defType: 'edismax',
        wt: 'json',
        start: (this.options.page - 1) * this.options.itemsPerPage,
        rows: this.options.itemsPerPage,
        sort: 'created desc',
        fq: []
      }
      if (this.ownerFilter) {
        params.fq.push('owner:' + this.$store.state.user.username)
      }
      if (this.jsonldOnly) {
        params.fq.push('datastreams:"JSON-LD"')
      }
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/search/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded',
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.objects = response.data.response.docs
        this.totalObjects = response.data.response.numFound
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    handleKeyDown (e) {
      if (e.keyCode === 13) {
        this.search()
      }
    },
    selectObject: function (item) {
      this.$emit('object-selected', item)
    },
    mounted () {
      this.search()
    }
  }
}
</script>
