<template>
  <div>
    <v-btn class="my-4" :to="{ path: `/detail/${routepid}`, params: { pid: routepid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-tabs>
      <v-tab v-if="downloadItems.length > 0">Downloads</v-tab>
      <v-tab v-if="detailPageItems.length > 0">Views</v-tab>
      <v-tab-item v-if="downloadItems.length > 0">
        <v-data-iterator :items="downloadItems" :search="searchDownloads" :item-key="'country'" :sort-by="'total'"
          :sort-desc="true" hide-default-footer>
          <template v-slot:header>
            <v-toolbar dark color="grey darken-3" class="mb-1">
              <v-toolbar-title>Downloads of object {{ routepid }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-text-field v-model="searchDownloads" clearable flat solo-inverted hide-details
                prepend-inner-icon="mdi-map-marker" label="Filter by country code"></v-text-field>
            </v-toolbar>
          </template>
          <template v-slot:default="props">
            <v-row>
              <v-col v-for="item in props.items" :key="item.country" cols="12" md="4">
                <v-card>
                  <v-card-title class="subheading"><span class="primary--text">{{ item.country.toUpperCase()
                  }}</span><span class="ml-6">{{ item.total }}</span></v-card-title>
                  <v-divider></v-divider>
                  <v-list dense>
                    <template v-for="(value, key) in item">
                      <v-list-item :key="key" v-if="(key != 'country') && (key != 'total')">
                        <v-list-item-content>{{ key }}:</v-list-item-content>
                        <v-list-item-content class="align-end">{{ value }}</v-list-item-content>
                      </v-list-item>
                    </template>
                  </v-list>
                </v-card>
              </v-col>
            </v-row>
          </template>
        </v-data-iterator>
      </v-tab-item>
      <v-tab-item v-if="detailPageItems.length > 0">
        <v-data-iterator :items="detailPageItems" :search="searchViews" :item-key="'country'" :sort-by="'total'"
          :sort-desc="true" hide-default-footer>
          <template v-slot:header>
            <v-toolbar dark color="grey darken-3" class="mb-1">
              <v-toolbar-title>Views of object {{ routepid }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-text-field v-model="searchViews" clearable flat solo-inverted hide-details
                prepend-inner-icon="mdi-magnify" label="Filter by country code"></v-text-field>
            </v-toolbar>
          </template>
          <template v-slot:default="props">
            <v-row>
              <v-col v-for="item in props.items" :key="item.country" cols="12" md="4">
                <v-card>
                  <v-card-title class="subheading"><span class="primary--text">{{ item.country.toUpperCase()
                  }}</span><span class="ml-6">{{ item.total }}</span></v-card-title>
                  <v-divider></v-divider>
                  <v-list dense>
                    <template v-for="(value, key) in item">
                      <v-list-item :key="key" v-if="(key != 'country') && (key != 'total')">
                        <v-list-item-content>{{ key }}:</v-list-item-content>
                        <v-list-item-content class="align-end">{{ value }}</v-list-item-content>
                      </v-list-item>
                    </template>
                  </v-list>
                </v-card>
              </v-col>
            </v-row>
          </template>
        </v-data-iterator>
      </v-tab-item>
    </v-tabs>
  </div>
</template>

<script>
import { context } from '../../mixins/context'
import { config } from '../../mixins/config'

export default {
  mixins: [context, config],
  computed: {
    routepid: function () {
      return this.$route.params.pid
    }
  },
  data() {
    return {
      detailPageItems: [],
      downloadItems: [],
      searchViews: '',
      searchDownloads: ''
    }
  },
  methods: {
    async fetchStats(self) {
      self.detailPageItems = []
      self.downloadItems = []
      try {
        let response = await self.$http.get(self.instanceconfig.api + '/stats/' + self.routepid + '/chart',
          {
            headers: {
              'X-XSRF-TOKEN': self.user.token
            }
          }
        )
        if (response.data.stats) {
          if (response.data.stats.detail_page) {
            Object.entries(response.data.stats.detail_page).forEach(([country, dates]) => {
              let obj = dates
              let total = 0
              Object.entries(dates).forEach(([date, count]) => {
                total += count
              })
              obj['total'] = total
              obj['country'] = country
              self.detailPageItems.push(obj)
            })
          }
          if (response.data.stats.downloads) {
            Object.entries(response.data.stats.downloads).forEach(([country, dates]) => {
              let obj = dates
              let total = 0
              Object.entries(dates).forEach(([date, count]) => {
                total += count
              })
              obj['total'] = total
              obj['country'] = country
              self.downloadItems.push(obj)
            })
          }
        }
      } catch (error) {
        console.log(error)
      }
    }
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      vm.$store.commit('setLoading', true)
      await vm.fetchStats(vm, to.params.pid)
      vm.$store.commit('setLoading', false)
    })
  },
  beforeRouteUpdate: async function (to, from, next) {
    this.$store.commit('setLoading', true)
    await this.fetchStats(this, to.params.pid)
    this.$store.commit('setLoading', false)
    next()
  }
}
</script>
