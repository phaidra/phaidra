<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card>
      <v-card-title class="grey white--text">{{ $t('Select a collection') }}</v-card-title>
      <v-card-text>
        <v-text-field
          v-model="collectionsSearch"
          append-icon="mdi-magnify"
          :label="$t('Search...')"
          single-line
          hide-details
          class="mb-4"
        ></v-text-field>
        <v-data-table
          hide-default-header
          :headers="collectionsHeaders"
          :items="collections"
          :search="collectionsSearch"
          :custom-filter="filterTitle"
          :loading="loading"
          :loading-text="$t('Loading...')"
          :items-per-page="5"
          :no-data-text="$t('No data available')"
          :footer-props="{
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
            <v-btn text color="primary" @click="selectCollection(item)">{{ $t('Select') }}</v-btn>
          </template>
        </v-data-table>
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
import qs from 'qs'

export default {
  name: 'collection-dialog',
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
      collectionsHeaders: [
        { text: 'Pid', align: 'left', value: 'pid' },
        { text: 'Title', align: 'left', value: 'title' },
        { text: 'Created', align: 'right', value: 'created' },
        { text: 'Actions', align: 'right', value: 'actions', sortable: false }
      ],
      collections: []
    }
  },
  methods: {
    filterTitle (value, search, item) {
      if (item.dc_title) {
        if (item.dc_title.length > 0) {
          return item.dc_title[0].indexOf(search) !== -1
        } else {
          return false
        }
      } else {
        return false
      }
    },
    open: async function () {
      this.dialog = true
      this.loading = true
      let params = {
        q: '*:*',
        defType: 'edismax',
        wt: 'json',
        start: 0,
        rows: 1000,
        sort: 'created desc',
        fq: 'resourcetype:collection AND owner:' + this.$store.state.user.username
      }
      try {
        let response = await this.$http.request({
          method: 'POST',
          url: this.instance.solr + '/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          },
          params: params
        })
        this.collections = response.data.response.docs
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    selectCollection: function (item) {
      this.$emit('collection-selected', item)
      this.dialog = false
    }
  }
}
</script>
