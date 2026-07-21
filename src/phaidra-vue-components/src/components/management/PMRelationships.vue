<template>
  <v-card :flat="!title">
    <v-card-title v-if="title" class="text-h6 font-weight-light text-white">{{ title }}</v-card-title>
    <v-divider v-if="title"></v-divider>
    <v-card-text>
        <v-row>
          <v-col>
            <h2 class="text-h6 font-weight-light">{{ $t('Here you can add or remove relationships to other objects inside this repository.') }}</h2>
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
              :no-results-text="$t('There were no search results')"
            >
              <template v-slot:item.relation="{ item }">
                {{ getLocalizedTermLabel('relations', item.relation) }}
              </template>
              <template v-slot:item.object="{ item }">
                <a target="_blank" :href="instance.baseurl + '/' + item.object">{{ item.object }}</a>
              </template>
              <template v-slot:item.actions="{ item }">
                <v-tooltip location="bottom">
                  <template v-slot:activator="{ props: activatorProps }">
                    <v-icon-btn :disabled="loading" class="mx-3" color="btnred" @click="removeRelationship(item)" v-bind="activatorProps" :aria-label="$t('Remove')" icon="mdi-delete" />
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
              <v-card-title class="text-h6 font-weight-light text-white">{{ $t('Add new relationship of object') + ' ' + pid }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-container fluid>
                  <v-row>
                    <v-col cols="4">
                      <v-select
                        v-model="selectedRelationship"
                        :label="$t('Choose relationship')"
                        :items="relationshipSelect"
                        item-title="text"
                        item-value="value"
                        variant="filled"
                      />
                    </v-col>
                    <v-col cols="5">
                      <v-autocomplete
                        :no-data-text="$t('No data available')"
                        v-model="objectSearchModel"
                        :items="objectSearchItems.length > 0 ? objectSearchItems : []"
                        :loading="objectSearchLoading"
                        v-model:search="objectSearch"
                        :label="$t('Object search')"
                        :placeholder="$t('Start typing to search')"
                        :custom-filter="customFilter"
                        item-title="text"
                        item-value="value"
                        prepend-inner-icon="mdi-magnify"
                        hide-no-data
                        hide-selected
                        return-object
                        clearable
                        @click:clear="userSearchItems=[]"
                      >
                        <template #selection="{ internalItem }">
                          <span><span class="text-primary">{{ (internalItem.raw || internalItem).value }}:</span> {{ (internalItem.raw || internalItem).text }}</span>
                        </template>
                        <template #item="{ props, internalItem }">
                          <v-list-item v-if="internalItem.raw || internalItem" v-bind="props" lines="two">
                            <template #title>{{ (internalItem.raw || internalItem).text }}</template>
                            <template #subtitle>{{ (internalItem.raw || internalItem).value }}</template>
                          </v-list-item>
                        </template>
                      </v-autocomplete>
                    </v-col>
                    <v-col cols="1" class="pt-1">
                      <v-btn class="bg-primary" :disabled="loading" @click="addRelationship()">{{ $t('Add') }}</v-btn>
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
          { title: this.$t('Relation'), align: 'start', key: 'relation' },
          { title: this.$t('Object'), align: 'start', key: 'object' },
          { title: this.$t('Title'), align: 'start', key: 'title' },
          { title: this.$t('Actions'), align: 'end', key: 'actions', sortable: false }
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
    customFilter (_value, query, item) {
      const raw = item?.raw ?? item
      if (!raw || raw.text == null || raw.value == null) return -1
      const text = String(raw.text).toLowerCase()
      const value = String(raw.value).toLowerCase()
      const searchText = String(query ?? '').toLowerCase()
      return text.indexOf(searchText) > -1 || value.indexOf(searchText) > -1 ? 0 : -1
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
          titles[d.pid] = d['dc_title'] ? d['dc_title'][0] : ''
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
