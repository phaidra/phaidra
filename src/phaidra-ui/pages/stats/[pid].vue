<template>
  <div>
    <v-btn color="primary" class="my-4" :to="`/detail/${routepid}`" prepend-icon="mdi-arrow-left">
      {{ $t('Back to detail page') }}
    </v-btn>
    <v-tabs
      color="primary"
      v-if="downloadItems.length > 0 || detailPageItems.length > 0"
      v-model="statsTab"
    >
      <v-tab v-if="downloadItems.length > 0" value="downloads">{{ $t("Downloads") }}</v-tab>
      <v-tab v-if="detailPageItems.length > 0" value="views">{{ $t("Views") }}</v-tab>
    </v-tabs>
    <v-window v-model="statsTab">
      <v-window-item v-if="downloadItems.length > 0" value="downloads">
        <v-data-iterator
          :items="downloadItems"
          :search="searchDownloads"
          item-value="country"
          :sort-by="[{ key: 'total', order: 'desc' }]"
          :items-per-page="-1"
        >
          <template #header>
            <v-toolbar flat color="cardtitlebg" class="mb-1">
              <v-toolbar-title class="font-weight-light text-white">{{ $t("Downloads of object") }} {{ routepid }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-text-field
                v-model="searchDownloads"
                clearable
                variant="solo"
                hide-details
                density="compact"
                prepend-inner-icon="mdi-magnify"
                :label="$t('Filter by country code, eg \'AT\'')"
              />
            </v-toolbar>
          </template>
          <template #default="{ items }">
            <v-row no-gutters class="ma-4">
              <v-col v-for="wrapper in items" :key="wrapper.raw.country" cols="12" md="4">
                <v-card>
                  <v-card-title class="text-title-large font-weight-light text-white"><span>{{ wrapper.raw.country.toUpperCase()
                  }}</span><span class="ml-6">{{ wrapper.raw.total }}</span></v-card-title>
                  <v-divider></v-divider>
                  <v-list density="compact">
                    <template v-for="(value, key) in wrapper.raw" :key="String(key)">
                      <v-list-item v-if="(key != 'country') && (key != 'total')" class="d-flex flex-nowrap justify-space-between">
                        <span>{{ key }}:</span>
                        <span class="text-end">{{ value }}</span>
                      </v-list-item>
                    </template>
                  </v-list>
                </v-card>
              </v-col>
            </v-row>
          </template>
        </v-data-iterator>
      </v-window-item>
      <v-window-item v-if="detailPageItems.length > 0" value="views">
        <v-data-iterator
          :items="detailPageItems"
          :search="searchViews"
          item-value="country"
          :sort-by="[{ key: 'total', order: 'desc' }]"
          :items-per-page="-1"
        >
          <template #header>
            <v-toolbar flat color="cardtitlebg" class="mb-1">
              <v-toolbar-title class="font-weight-light text-white">{{ $t("Views of object") }} {{ routepid }}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-text-field
                v-model="searchViews"
                clearable
                variant="solo"
                hide-details
                density="compact"
                prepend-inner-icon="mdi-magnify"
                :label="$t('Filter by country code, eg \'AT\'')"
              />
            </v-toolbar>
          </template>
          <template #default="{ items }">
            <v-row no-gutters class="ma-4">
              <v-col v-for="wrapper in items" :key="wrapper.raw.country" cols="12" md="4">
                <v-card>
                  <v-card-title class="text-title-large font-weight-light text-white"><span>{{ wrapper.raw.country.toUpperCase()
                  }}</span><span class="ml-6">{{ wrapper.raw.total }}</span></v-card-title>
                  <v-divider></v-divider>
                  <v-list density="compact">
                    <template v-for="(value, key) in wrapper.raw" :key="String(key)">
                      <v-list-item v-if="(key != 'country') && (key != 'total')" class="d-flex flex-nowrap justify-space-between">
                        <span>{{ key }}:</span>
                        <span class="text-end">{{ value }}</span>
                      </v-list-item>
                    </template>
                  </v-list>
                </v-card>
              </v-col>
            </v-row>
          </template>
        </v-data-iterator>
      </v-window-item>
    </v-window>
  </div>
</template>

<script>
import { useRootStore } from '~/stores/root'
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
      statsTab: 'downloads',
      detailPageItems: [],
      downloadItems: [],
      searchViews: '',
      searchDownloads: ''
    }
  },
  methods: {
    syncStatsTab() {
      if (this.downloadItems.length > 0) {
        this.statsTab = 'downloads'
      } else if (this.detailPageItems.length > 0) {
        this.statsTab = 'views'
      }
    },
    async fetchStats(self) {
      self.detailPageItems = []
      self.downloadItems = []
      try {
        let response = await self.$axios.get('/stats/' + self.routepid + '/chart',
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
        self.syncStatsTab()
      } catch (error) {
        console.log(error)
      }
    }
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      vm.useRootStore().setLoading(true)
      await vm.fetchStats(vm, to.params.pid)
      vm.useRootStore().setLoading(false)
    })
  },
  beforeRouteUpdate: async function (to, from, next) {
    useRootStore().setLoading(true)
    await this.fetchStats(this, to.params.pid)
    useRootStore().setLoading(false)
    next()
  }
}
</script>
