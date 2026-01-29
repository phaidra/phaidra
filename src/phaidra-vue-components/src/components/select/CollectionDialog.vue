<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card>
      <v-card-title class="title font-weight-light white--text">{{ $t('Select a collection') }}</v-card-title>
      <v-card-text class="mt-4">
        <v-text-field
          v-model="collectionsSearch"
          append-icon="mdi-magnify"
          :label="$t('Search...')"
          single-line
          hide-details
          class="mb-4"
          @keyup.enter="loadCollections"
        ></v-text-field>
        <v-data-table
          hide-default-header
          :headers="collectionsHeaders"
          :items="collections"
          :options="options"
          :server-items-length="totalCollections"
          @update:options="onOptionsUpdate"
          :loading="loading"
          :loading-text="$t('Loading...')"
          :no-data-text="$t('No data available')"
          :footer-props="{
                itemsPerPageOptions: [5, 10, 25, 50, 100],
                pageText: $t('Page'),
                itemsPerPageText: $t('Rows per page')
              }"
          :no-results-text="$t('There were no search results')"
        >
          <template v-slot:item.title="{ item }">
            <span>{{ getObjectTitle(item) | truncate(50) }}</span>
          </template>
          <template v-slot:item.created="{ item }">
            {{ item.created | date }}
          </template>
          <template v-slot:item.actions="{ item }">
            <v-btn text color="primary" @click="selectCollection(item)">{{ $t('Select') }}</v-btn>
          </template>
        </v-data-table>
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
import objectMixin from 'phaidra-vue-components/src/mixins/object'
import qs from 'qs'

export default {
  name: 'collection-dialog',
  mixins: [objectMixin],
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      dialog: false,
      loading: false,
      collectionsSearch: '',
      options: {
        page: 1,
        itemsPerPage: 5
      },
      collectionsHeaders: [
        { text: 'Pid', align: 'left', value: 'pid' },
        { text: 'Title', align: 'left', value: 'title' },
        { text: 'Created', align: 'right', value: 'created' },
        { text: 'Actions', align: 'right', value: 'actions', sortable: false }
      ],
      collections: [],
      totalCollections: 0
    }
  },
  methods: {
    onOptionsUpdate (opts) {
      this.options = { ...opts, itemsPerPage: opts.itemsPerPage === -1 ? 100 : opts.itemsPerPage }
      if (this.dialog) {
        this.loadCollections()
      }
    },
    loadCollections: async function () {
      this.loading = true
      let searchQuery = this.collectionsSearch ? this.collectionsSearch : '*:*'
      let params = {
        q: searchQuery,
        defType: 'edismax',
        wt: 'json',
        start: (this.options.page - 1) * this.options.itemsPerPage,
        rows: this.options.itemsPerPage,
        sort: 'created desc',
        fq: 'resourcetype:collection AND owner:' + this.$store.state.user.username
      }
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/search/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          },
          params: params
        })
        this.collections = response.data.response.docs
        this.totalCollections = response.data.response.numFound
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    open: async function () {
      this.dialog = true
      this.options = { page: 1, itemsPerPage: this.options.itemsPerPage }
      this.collectionsSearch = ''
    },
    selectCollection: function (item) {
      this.$emit('collection-selected', item)
      this.dialog = false
    }
  }
}
</script>
