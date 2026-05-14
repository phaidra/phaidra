<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8">
        <v-card-title class="title font-weight-light text-white">
          <span>{{ $t(label) }}</span>
          <v-spacer></v-spacer>
          <v-menu open-on-hover bottom offset-y v-if="actions.length">
            <template v-slot:activator="{ props }">
              <v-btn v-bind="props" icon variant="text" color="white">
                <v-icon>mdi-dots-vertical</v-icon>
              </v-btn>
            </template>
            <div>
              <v-list>
                <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
                  <v-list-item-title>{{ action.title }}</v-list-item-title>
                </v-list-item>
              </v-list>
            </div>
          </v-menu>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text class="mt-4">
          <v-row>
            <v-col cols="4" v-if="showtype">
              <v-autocomplete
                :model-value="getTerm('placetype', type)"
                @update:model-value="$emit('input-place-type', $event)"
                :no-data-text="$t('No data available')"
                :label="$t('Type of place')"
                :items="vocabularies['placetype'].terms"
                item-value="@id"
                :custom-filter="filterPlacetype"
                :disabled="disabletype"
                :variant="inputStyle === 'filled' ? 'filled' : (inputStyle === 'outlined' ? 'outlined' : 'underlined')"
                return-object
                clearable
              >
                <template #item="{ props, internalItem }">
                  <v-list-item v-bind="props">
                    <v-list-item-title v-html="`${getLocalizedTermLabel('placetype', internalItem.raw['@id'])}`"></v-list-item-title>
                    <v-list-item-subtitle v-if="showIds" v-html="`${internalItem.raw['@id']}`"></v-list-item-subtitle>
                  </v-list-item>
                </template>
                <template #selection="{ internalItem }">
                  <span v-html="`${getLocalizedTermLabel('placetype', internalItem['@id'])}`"></span>
                </template>
              </v-autocomplete>
            </v-col>
            <v-col :cols="showtype ? 6 : 12">
              <v-text-field
                v-model="q"
                :loading="loading"
                :label="$t(searchlabel)"
                :variant="inputStyle === 'filled' ? 'filled' : (inputStyle === 'outlined' ? 'outlined' : 'underlined')"
                clearable
                :messages="resolved"
                :hint="$t(hint)"
                autocomplete="off"
                append-inner-icon="mdi-magnify"
                @click:append-inner="search()"
                @keyup.enter="search()"
              >
              <template v-slot:message="{ key, message }">
                <div class="my-1" v-html="`${message}`"></div>
              </template>
              </v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12" md="6" v-show="showItems">
              <v-list lines="two" style="max-height: 400px" class="overflow-y-auto">
                <template v-for="(item, index) in items" :key="item.geonameId">
                  <v-list-item
                    :active="selected === index"
                    @click="selected = index"
                  >
                    <v-list-item-title v-text="item.name"></v-list-item-title>
                    <v-list-item-subtitle class="text-primary" v-text="item.countryName"></v-list-item-subtitle>
                    <v-list-item-subtitle v-text="item.fcodeName"></v-list-item-subtitle>
                    <template #append>
                      <span v-text="item.action"></span>
                      <v-icon :color="selected === index ? 'amber-darken-3' : 'grey-lighten-1'">mdi-map-marker</v-icon>
                    </template>
                  </v-list-item>
                  <v-divider v-if="index < items.length - 1"></v-divider>
                </template>
              </v-list>
            </v-col>
            <v-col cols="12" md="6" v-show="showMap && isbrowser">
              <div style="height: 400px; width: 100%" class="text-grey-10">
                <component v-if="isbrowser && leafletReady" :is="LMapComp" ref="map" :zoom="10" :center="center">
                  <component :is="LTileLayerComp" :url='"https://{s}.tile.osm.org/{z}/{x}/{y}.png"' :attribution='"© <a href=\"https://www.openstreetmap.org/copyright\" target=\"_blank\">OpenStreetMap</a> contributors"' />
                  <component :is="LMarkerComp" v-if="locationMarker" :lat-lng="locationMarker"/>
                </component>
              </div>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { markRaw } from 'vue'
import 'leaflet/dist/leaflet.css'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

const isClient = typeof window !== 'undefined'

export default {
  name: 'p-i-spatial-geonames',
  mixins: [vocabulary, fieldproperties],
  props: {
    value: {
      type: String,
      required: true
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
      default: 'Search...'
    },
    hint: {
      type: String,
      default: 'Press Enter to initiate search'
    },
    initquery: {
      type: String
    },
    required: {
      type: Boolean
    },
    disabletype: {
      type: Boolean
    },
    showtype: {
      type: Boolean,
      required: true,
      default: true
    },
    showIds: {
      type: Boolean,
      default: false
    }
  },
  watch: {
    value (val) {
      (val !== null) && this.resolve(val)
    },
    selected (val) {
      (val !== null) && this.resolve(val)
    }
  },
  computed: {
    alpha2locale: function () {
      switch (this.$i18n.locale) {
        case 'eng': return 'en'
        case 'deu': return 'de'
        case 'ita': return 'it'
        default: return 'en'
      }
    }
  },
  data () {
    return {
      center: ['48.20849', '16.37208'],
      locationMarker: null,
      showMap: false,
      showItems: false,
      items: [],
      loading: false,
      q: null,
      selected: null,
      preflabel: '',
      rdfslabel: '',
      resolved: '',
      isbrowser: isClient,
      leafletReady: false,
      LMapComp: null,
      LTileLayerComp: null,
      LMarkerComp: null
    }
  },
  methods: {
    filterPlacetype (_value, query, item) {
      const raw = item?.raw ?? item
      return this.autocompleteFilter(raw, String(query ?? '')) ? 0 : -1
    },
    resolve: async function () {
      if (this.selected !== null) {
        if (this.items[this.selected].name) {
          this.q = this.items[this.selected].name
        }
        if (this.items[this.selected].lat) {
          this.locationMarker = [this.items[this.selected].lat, this.items[this.selected].lng]
          this.center = this.locationMarker
          this.showMap = true
        }
        this.showMap = true
        this.loading = true
        let uri = ''
        if (this.items[this.selected].value) {
          uri = this.items[this.selected].value
        } else {
          uri = 'https://www.geonames.org/' + this.items[this.selected].geonameId
        }
        this.$emit('input', uri)
        try {
          let response = await this.$axios.request({
            method: 'GET',
            url: '/resolve',
            params: { uri, lang: this.alpha2locale }
          })
          // keep this next tick from showMap
          this.$refs.map?.leafletObject?.invalidateSize()
          this.preflabel = response.data[uri]['skos:prefLabel']
          this.rdfslabel = response.data[uri]['rdfs:label']
          for (var i = 0; i < this.rdfslabel.length; i++) {
            this.resolved = '<a href="' + uri + '" target="_blank">' + this.rdfslabel[i]['@value'] + '</a>'
          }
          if (response.data[uri]['schema:GeoCoordinates']) {
            this.coordinates = [
              {
                '@type': 'schema:GeoCoordinates',
                'schema:latitude': [
                  response.data[uri]['schema:GeoCoordinates']['schema:latitude']
                ],
                'schema:longitude': [
                  response.data[uri]['schema:GeoCoordinates']['schema:longitude']
                ]
              }
            ]
          }
          this.$emit('resolve', { 'skos:prefLabel': this.preflabel, 'rdfs:label': this.rdfslabel, coordinates: this.coordinates })
        } catch (error) {
          console.log(error)
        } finally {
          this.loading = false
        }
      }
    },
    search: async function () {
      this.loading = true
      this.items = []
      this.selected = null
      var params = {
        q: this.q,
        lang: this.alpha2locale
      }
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/geonames/search',
          params: params
        })
        this.items = response.data.geonames
        this.showItems = true
        this.showItems = true
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    }
  },
  mounted: function () {
    if (this.isbrowser) {
      Promise.all([
        import('leaflet'),
        import('@vue-leaflet/vue-leaflet'),
        import('leaflet/dist/images/marker-icon-2x.png'),
        import('leaflet/dist/images/marker-icon.png'),
        import('leaflet/dist/images/marker-shadow.png')
      ]).then(([leafletModule, vueLeaflet, markerIcon2x, markerIcon, markerShadow]) => {
        const L = leafletModule.default ?? leafletModule
        const markerIcon2xUrl = markerIcon2x.default ?? markerIcon2x
        const markerIconUrl = markerIcon.default ?? markerIcon
        const markerShadowUrl = markerShadow.default ?? markerShadow
        delete L.Icon.Default.prototype._getIconUrl
        L.Icon.Default.mergeOptions({
          iconRetinaUrl: markerIcon2xUrl,
          iconUrl: markerIconUrl,
          shadowUrl: markerShadowUrl
        })
        this.LMapComp = markRaw(vueLeaflet.LMap)
        this.LTileLayerComp = markRaw(vueLeaflet.LTileLayer)
        this.LMarkerComp = markRaw(vueLeaflet.LMarker)
        this.leafletReady = true
      }).catch((error) => {
        console.log(error)
      })
    }

    this.$nextTick(function () {
      this.loading = !this.vocabularies['placetype'].loaded
      // emit input to set skos:prefLabel in parent
      if (this.type) {
        this.$emit('input-place-type', this.getTerm('placetype', this.type))
      }
    })

    if (this.initquery) {
      this.items = [{ value: this.value, text: this.initquery }]
      this.model = { value: this.value, text: this.initquery }
      this.selected = 0
    }
  }
}
</script>

<style scoped>
.v-btn {
  margin: 0;
}
</style>
