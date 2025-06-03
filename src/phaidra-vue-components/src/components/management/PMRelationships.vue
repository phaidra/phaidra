<template>
  <v-card :flat="!title">
    <v-card-title v-if="title" class="title font-weight-light white--text">{{ title }}</v-card-title>
    <v-divider v-if="title"></v-divider>
    <v-card-text>
        <v-row>
          <v-col>
            <h2 class="title font-weight-light">{{ $t('Here you can add or remove relationships to other objects inside this repository.') }}</h2>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12">
            <v-data-table
              hide-default-footer
              :items="relationshipsArray"
              :headers="relationshipsHeaders"
              :loading="loading"
              :loading-text="$t('Loading...')"
              :items-per-page="1000"
              :no-data-text="$t('No data available')"
              :footer-props="{
                pageText: $t('Page'),
                itemsPerPageText: $t('Rows per page'),
                itemsPerPageAllText: $t('All')
              }"
              :no-results-text="$t('There were no search results')"
            >
              <template v-slot:item.relation="{ item }">
                {{ getLocalizedTermLabel('relations', item.relation) }}
              </template>
              <template v-slot:item.object="{ item }">
                <a target="_blank" :href="instance.baseurl + '/' + item.object">{{ item.object }}</a>
              </template>
              <template v-slot:item.actions="{ item }">
                <v-tooltip bottom>
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn :disabled="loading" icon class="mx-3" color="btnred" @click="removeRelationship(item)" v-on="on" v-bind="attrs" :aria-label="$t('Remove')">
                      <v-icon>mdi-delete</v-icon>
                    </v-btn>
                  </template>
                  <span>{{ $t('Remove') }}</span>
                </v-tooltip>                
              </template>
            </v-data-table>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ $t('Add new relationship of object') + ' ' + pid }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-container fluid>
                  <v-row>
                    <v-col cols="4">
                      <v-select
                        v-model="selectedRelationship"
                        :label="$t('Choose relationship')"
                        :items="relationshipSelect"
                      />
                    </v-col>
                    <v-col cols="5">
                      <v-autocomplete
                        v-model="objectSearchModel"
                        :items="objectSearchItems.length > 0 ? objectSearchItems : []"
                        :loading="objectSearchLoading"
                        :search-input.sync="objectSearch"
                        :label="$t('Object search')"
                        :placeholder="$t('Start typing to search')"
                        :filter="customFilter"
                        prepend-inner-icon="mdi-magnify"
                        hide-no-data
                        hide-selected
                        return-object
                        clearable
                        @click:clear="userSearchItems=[]"
                      >
                        <template slot="selection" slot-scope="{ item }">
                          <v-list-item-content>
                            <v-list-item-title><span class="primary--text">{{ item.value }}:</span> {{ item.text }}</v-list-item-title>
                          </v-list-item-content>
                        </template>
                        <template slot="item" slot-scope="{ item }">
                          <template v-if="item">
                            <v-list-item-content two-line>
                              <v-list-item-title>{{ item.text }}</v-list-item-title>
                              <v-list-item-subtitle>{{ item.value }}</v-list-item-subtitle>
                            </v-list-item-content>
                          </template>
                        </template>
                      </v-autocomplete>
                    </v-col>
                    <v-col cols="1" class="pt-6">
                      <v-btn class="primary" :disabled="loading" @click="addRelationship()">{{ $t('Add') }}</v-btn>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
    </v-card-text>
  </v-card>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import qs from 'qs'

export default {
  name: 'p-m-relationships',
  mixins: [ vocabulary ],
  props: {
    pid: {
      type: String
    },
    relationships: {
      type: Object,
      required: true
    },
    title: {
      type: String
    }
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    },
    relationshipSelect: function () {
      let arr = []
      for (let rel of this.vocabularies['relations'].terms) {
        arr.push({ text: this.getLocalizedTermLabel('relations', rel['@id']), value: rel['@id'] })
      }
      return arr
    },
    map: function () {
      let map = {}
      for (let rel of this.vocabularies['relations'].terms) {
        for (let notation of rel['skos:notation']) {
          map[notation.toLowerCase()] = {
            uri: rel['@id']
          }
          break
        }
      }
      return map
    }
  },
  data () {
    return {
      loading: false,
      relationshipsArray: [],
      relationshipsHeaders: [],
      selectedRelationship: null,
      objectSearch: null,
      objectSearchModel: null,
      objectSearchItems: [],
      objectSearchLoading: false
    }
  },
  watch: {
    '$i18n.locale': {
      immediate: true, // Ensure it's set on load
      handler() {
        this.relationshipsHeaders = [
          { text: this.$t('Relation'), align: 'left', value: 'relation' },
          { text: this.$t('Object'), align: 'left', value: 'object' },
          { text: this.$t('Title'), align: 'left', value: 'title' },
          { text: this.$t('Actions'), align: 'right', value: 'actions', sortable: false }
        ]
      }
    },
    relationships: {
      handler: async function (val) {
        this.loading = true
        let pids = []
        Object.entries(val).forEach(([key, value]) => {
          for (let o of value) {
            pids.push(o)
          }
        })
        this.relationshipsArray = []
        let titles = await this.getTitlesHash(pids)
        Object.entries(val).forEach(([key, value]) => {
          if (this.map[key]) {
            for (let o of value) {
              this.relationshipsArray.push({ relation: this.map[key].uri, object: o, title: titles[o] })
            }
          } else {
            if (key !== 'haspart') {
              console.log('Error loading relationships: unknown relation: ' + key)
            }
          }
        })
        this.loading = false
      },
      deep: true
    },
    objectSearch: async function (val) {
      if (val && (val.length < 2)) {
        return
      }
      if (this.objectSearchLoading) return
      if (this.objectSearchModel) return
      this.objectSearchItems = []
      this.objectSearchLoading = true
      try {
        let params = {
          q: val + ' OR pid:"' + val + '"',
          defType: 'edismax',
          fq: 'dc_title:*',
          wt: 'json',
          fl: 'pid,dc_title',
          start: 0,
          rows: 100
        }
        let response = await this.$axios.request({
          method: 'POST',
          url: '/search/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })
        for (let d of response.data.response.docs) {
          this.objectSearchItems.push({ text: d['dc_title'][0], value: d.pid })
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.objectSearchLoading = false
      }
    }
  },
  methods: {
    customFilter (item, queryText) {
      const text = item.text.toLowerCase()
      const value = item.value.toLowerCase()
      const searchText = queryText.toLowerCase()
      console.log(searchText + ' found in [' + text + ']:' + (text.indexOf(searchText) > -1) + ' or [' + value + ']:' + (value.indexOf(searchText) > -1))
      return text.indexOf(searchText) > -1 ||
        value.indexOf(searchText) > -1
    },
    getTitlesHash: async function (pids) {
      let titles = {}
      try {
        let params = {
          q: 'pid:"("' + pids.join('" OR "') + '")"',
          defType: 'edismax',
          wt: 'json',
          fl: 'pid,dc_title',
          start: 0,
          rows: 5000
        }
        let response = await this.$axios.request({
          method: 'POST',
          url: '/search/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })
        let docs = response.data.response.docs
        for (let d of docs) {
          titles[d.pid] = d['dc_title']
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      }
      return titles
    },
    addRelationship: async function () {
      if (this.objectSearchModel) {
        if (this.pid) {
          this.loading = true
          try {
            var httpFormData = new FormData()
            httpFormData.append('predicate', this.selectedRelationship)
            httpFormData.append('object', 'info:fedora/' + this.objectSearchModel.value)
            let response = await this.$axios.request({
              method: 'POST',
              url: '/object/' + this.pid + '/relationship/add',
              headers: {
                'Content-Type': 'multipart/form-data',
                'X-XSRF-TOKEN': this.$store.state.user.token
              },
              data: httpFormData
            })
            if (response.status === 200) {
              this.$store.commit('setAlerts', [{ type: 'success', msg: 'Relationship successfully added' }])
            } else {
              if (response.data.alerts && response.data.alerts.length > 0) {
                this.$store.commit('setAlerts', response.data.alerts)
              }
            }
          } catch (error) {
            console.log(error)
            this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
          } finally {
            this.loading = false
            this.$emit('load-relationships')
          }
        } else {
          this.$emit('add-relationship', { s: 'self', p: this.selectedRelationship, o: 'info:fedora/' + this.objectSearchModel.value })
        }
      }
    },
    removeRelationship: async function (item) {
      if (this.pid) {
        this.loading = true
        try {
          var httpFormData = new FormData()
          httpFormData.append('predicate', item.relation)
          httpFormData.append('object', 'info:fedora/' + item.object)
          let response = await this.$axios.request({
            method: 'POST',
            url: '/object/' + this.pid + '/relationship/remove',
            headers: {
              'Content-Type': 'multipart/form-data',
              'X-XSRF-TOKEN': this.$store.state.user.token
            },
            data: httpFormData
          })
          if (response.status === 200) {
            this.$store.commit('setAlerts', [{ type: 'success', msg: 'Relationship successfully removed' }])
          } else {
            if (response.data.alerts && response.data.alerts.length > 0) {
              this.$store.commit('setAlerts', response.data.alerts)
            }
          }
        } catch (error) {
          console.log(error)
          this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
        } finally {
          this.loading = false
          this.$emit('load-relationships')
        }
      } else {
        this.$emit('remove-relationship', { s: 'self', p: item.relation, o: 'info:fedora/' + item.object })
      }
    }
  }
}
</script>
