<template>
  <v-row v-if="!hidden">
    <v-col cols="12">
      <v-card class="mb-8">
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
            <v-col cols="4" v-if="showtype">
              <v-autocomplete
                v-on:input="$emit('input-place-type', $event)"
                :label="$t('Type of place')"
                :items="vocabularies['placetype'].terms"
                :item-value="'@id'"
                :value="getTerm('placetype', type)"
                :filter="autocompleteFilter"
                :disabled="disabletype"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
                return-object
                clearable
              >
                <template slot="item" slot-scope="{ item }">
                  <v-list-item-content two-line>
                    <v-list-item-title  v-html="`${getLocalizedTermLabel('placetype', item['@id'])}`"></v-list-item-title>
                    <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
                  </v-list-item-content>
                </template>
                <template slot="selection" slot-scope="{ item }">
                  <v-list-item-content>
                    <v-list-item-title v-html="`${getLocalizedTermLabel('placetype', item['@id'])}`"></v-list-item-title>
                  </v-list-item-content>
                </template>
              </v-autocomplete>
            </v-col>
            <v-col :cols="showtype ? 6 : 12">
              <v-text-field
                v-model="q"
                :loading="loading"
                :label="$t(searchlabel)"
                :filled="inputStyle==='filled'"
                :outlined="inputStyle==='outlined'"
                clearable
                :messages="resolved"
                :hint="$t(hint)"
                autocomplete="off"
                append-icon="mdi-magnify"
                @click:append="search()"
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
              <v-list two-line style="max-height: 400px" class="overflow-y-auto">
                <v-list-item-group v-model="selected" active-class="text--primary">
                  <div v-for="(item, index) in items" :key="item.geonameId">
                    <v-list-item>
                      <template v-slot:default="{ active }">
                        <v-list-item-content>
                          <v-list-item-title v-text="item.name"></v-list-item-title>
                          <v-list-item-subtitle class="text--primary" v-text="item.countryName"></v-list-item-subtitle>
                          <v-list-item-subtitle v-text="item.fcodeName"></v-list-item-subtitle>
                        </v-list-item-content>
                        <v-list-item-action>
                          <v-list-item-action-text v-text="item.action"></v-list-item-action-text>
                          <v-icon v-if="!active" color="grey lighten-1">mdi-map-marker</v-icon>
                          <v-icon v-else color="yellow darken-3">mdi-map-marker</v-icon>
                        </v-list-item-action>
                      </template>
                    </v-list-item>
                    <v-divider v-if="index < items.length - 1" :key="index"></v-divider>
                  </div>
                </v-list-item-group>
              </v-list>
            </v-col>
            <v-col cols="12" md="6" v-show="showMap && isbrowser">
              <div style="height: 400px; width: 100%" class="text-grey-10">
                <l-map ref="map" :zoom="10" :center="center">
                  <l-tile-layer :url='"https://{s}.tile.osm.org/{z}/{x}/{y}.png"' :attribution='"© <a href=\"https://www.openstreetmap.org/copyright\" target=\"_blank\">OpenStreetMap</a> contributors"' />
                  <l-marker v-if="locationMarker" :lat-lng="locationMarker"/>
                </l-map>
              </div>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import 'leaflet/dist/leaflet.css'
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'
let Vue2Leaflet = {}
let OpenStreetMapProvider = {}
let L = {}

if (process.browser) {
  OpenStreetMapProvider = require('leaflet-geosearch')
  Vue2Leaflet = require('vue2-leaflet')
  L = require('leaflet')
  delete L.Icon.Default.prototype._getIconUrl
  L.Icon.Default.mergeOptions({
    iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
    iconUrl: require('leaflet/dist/images/marker-icon.png'),
    shadowUrl: require('leaflet/dist/images/marker-shadow.png')
  })
}

export default {
  name: 'p-i-spatial-geonames',
  components: {
    LMap: Vue2Leaflet.LMap,
    LTileLayer: Vue2Leaflet.LTileLayer,
    LMarker: Vue2Leaflet.LMarker
  },
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
      required: true
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
      geosearchOptions: {
        provider: {}
      },
      isbrowser: process.browser
    }
  },
  methods: {
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
          this.$refs.map.mapObject.invalidateSize()
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
        maxRows: this.$store.state.appconfig.apis.geonames.maxRows,
        username: this.$store.state.appconfig.apis.geonames.username,
        q: this.q,
        lang: this.alpha2locale
      }
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: this.$store.state.appconfig.apis.geonames.search,
          params: params
        })
        this.items = response.data.geonames
        this.showItems = true
      } catch (error) {
        console.log(error)
      } finally {
        this.loading = false
      }
    }
  },
  mounted: function () {
    this.geosearchOptions.provider = new OpenStreetMapProvider.OpenStreetMapProvider()
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
