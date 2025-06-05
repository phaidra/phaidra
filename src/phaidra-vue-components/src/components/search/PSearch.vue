<template>
    <v-row no-gutters>
      <v-col md="9" cols="12" class="pr-2">
        <v-row align="start" class="pt-2 pb-4">
          <v-col md="6" cols="9">
            <p-search-autocomplete
              :placeholder="$t('SEARCH_PLACEHOLDER')"
              name="autocomplete"
              :initValue="q"
              :customParams="{ token: 'dev' }"
              :classes="{ input: 'form-control', wrapper: 'input-wrapper'}"
              :onSelect="handleSelect"
              solo
              :messages="[ total + ' ' + $t('objects') ]"
            ></p-search-autocomplete>
             <a href="#filters" class="skip-link d-sr-only-focusable">{{ $t('Go to Search Filters') }}</a>
          </v-col>
          <v-spacer></v-spacer>
          <v-col  md="6" cols="12">
            <p-search-toolbar
              :setSort="setSort"
              :sortIsActive="sortIsActive"
              :link="link"
              :toggleSelection="toggleSelection"
              :selectioncheck="selectioncheck"
              :csvExport="csvExport" />
          </v-col>
        </v-row>
        <v-row class="hidden-md-and-up">
          <v-bottom-sheet v-model="filterdialog" scrollable>
            <template v-slot:activator="{ on }">
              <v-btn class="ml-4 mb-6" color="primary" v-on="on">{{ $t('Filters') }}</v-btn>
            </template>
            <v-card height="400px">
              <v-card-title>
                <h2 class="title font-weight-light white--text">{{ $t('Filters') }}</h2>
                <v-spacer></v-spacer>
                <v-btn icon dark @click="filterdialog = !filterdialog" :aria-label="$t('Close')">
                  <v-icon>mdi-close</v-icon>
                </v-btn>
              </v-card-title>
              <v-card-text>
                <p-search-filters
                  :search="search"
                  :facetQueries="facetQueries"
                  :persAuthorsProp="persAuthors"
                  :corpAuthorsProp="corpAuthors"
                  :rolesProp="roles"
                  :ownerProp="owner"
                ></p-search-filters>
              </v-card-text>
              <v-divider></v-divider>
            </v-card>
          </v-bottom-sheet>
        </v-row>
        <v-row no-gutters>
          <v-btn v-if="inCollection" class="mb-8" color="primary">{{ $t('Members of') }}<nuxt-link class="ml-1 white--text" :to="localePath(`/detail/${inCollection}`)">{{ inCollection }}</nuxt-link><v-icon right @click.native="removeCollectionFilter()">mdi-close</v-icon></v-btn>
          <v-pagination
          :wrapper-aria-label="$t('pagination')"
          :page-aria-label="$t('page')"
          :previous-aria-label="$t('previous')"
          :next-aria-label="$t('next')"
          :current-page-aria-label="$t('currentPage')" 
          v-if="total>pagesize" v-bind:length="totalPages" justify="center" total-visible="10" v-model="page" class="mb-8" />
          <p-search-results
            :docs="docs"
            :total="total"
            :selectioncheck="selectioncheck"
            :getallresults="getAllResults">
          </p-search-results>
          <v-pagination
          :wrapper-aria-label="$t('pagination')"
          :page-aria-label="$t('page')"
          :previous-aria-label="$t('previous')"
          :next-aria-label="$t('next')"
          :current-page-aria-label="$t('currentPage')"
          v-if="total>pagesize" v-bind:length="totalPages" total-visible="10" v-model="page" class="mb-3" />
        </v-row>
      </v-col>
      <v-divider vertical class="divider hidden-sm-and-down"></v-divider>
      <v-col cols="3" class="pa-3 pt-2 hidden-sm-and-down">
        <h2 id="filters" class="h5 font-weight-light">{{ $t('Filters') }}</h2>
        <v-divider class="mt-3 divider"></v-divider>
        <p-search-filters
          ref="searchFilters"
          :search="search"
          :facetQueries="facetQueries"
          :persAuthorsProp="persAuthors"
          :corpAuthorsProp="corpAuthors"
          :rolesProp="roles"
          :ownerProp="owner"
          ></p-search-filters>
      </v-col>
      <v-dialog v-model="limitdialog" width="500">
        <v-card>
          <v-card-title class="title font-weight-light white--text">{{ $t('Selection limit') }}</v-card-title>
          <v-card-text class="mt-4">
            {{ $t('SELECTION_LIMIT', { limit: appconfig.search.selectionlimit }) }}
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn outlined @click="limitdialog = false">{{ $t("Close") }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-row>
</template>

<script>
import qs from 'qs'
import PSearchAutocomplete from './PSearchAutocomplete'
import PSearchResults from './PSearchResults'
import PSearchFilters from './PSearchFilters'
import PSearchToolbar from './PSearchToolbar'
import '@/compiled-icons/fontello-sort-name-up'
import '@/compiled-icons/fontello-sort-name-down'
import '@/compiled-icons/fontello-sort-number-up'
import '@/compiled-icons/fontello-sort-number-down'
import '@/compiled-icons/material-content-link'
import '@/compiled-icons/material-action-bookmark'
import '@/compiled-icons/material-toggle-check-box-outline-blank'
import { buildDateFacet, updateFacetQueries, persAuthors, corpAuthors, deactivateFacetQueries } from './facets'
import { buildParams, buildSearchDef, sortdef } from './utils'
import { setSearchParams } from './location'
import { saveAs } from 'file-saver'

export default {
  name: 'p-search',
  components: {
    PSearchAutocomplete,
    PSearchResults,
    PSearchFilters,
    PSearchToolbar
  },
  computed: {
    page: {
      get () {
        return this.currentPage
      },
      set (value) {
        this.currentPage = value
        this.search()
        window.scrollTo(0, 0)
      }
    },
    totalPages: function () {
      return Math.ceil(this.total / this.pagesize)
    },
    instance: function () {
      return this.$root.$store.state.instanceconfig
    },
    appconfig: function () {
      return this.$root.$store.state.appconfig
    }
  },
  props: {
    collection: {
      type: String,
      default: ''
    },
    ownerProp: {
      type: String,
      default: ''
    }
  },
  methods: {
    csvExport: async function () {
      let { searchdefarr, ands } = buildSearchDef(this)
      let params = buildParams(this, ands)
      if (this.inCollection) {
        const pid = this.inCollection.replace(/[o:]/g, '')
        params.sort = `pos_in_o_${pid} asc`
      }
      // we only need count now
      params.rows = 0

      try {
        this.$store.commit('setLoading', true)
        let response = await this.$axios.request({
          method: 'POST',
          url: '/search/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })
        params.rows = response.data.response.numFound
        params.indent = 'on'
        params.wt = 'csv'
        params.fl = ['pid', 'dc_title', 'dc_creator', 'bib_published']
        params['fl.alias'] = ''
        const csvquery = qs.stringify(params, { encodeValuesOnly: true, indices: false })
        this.$axios.request('/search/select?' + csvquery, {
          method: 'POST',
          mode: 'cors'
        })
          .then(function (response) { return response.data })
          .then(function (text) {
            var blob = new Blob([text], {
              type: 'text/csv;charset=utf-8'
            })
            saveAs(blob, 'search-results.csv')
          })
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    search: async function (options) {
      // `options` are combined into the PSearch component. The later are sent
      // over from child components: e.g. SearchFilters.
      // This allows us the buildSearchDef/buildParams functions to pick out
      // whatever properties they might need.

      // exclude 'collection' from above manipulation, since it's only passed as a prop
      let { collection } = options || {}
      if (collection) {
        this.inCollection = collection
        delete options.collection
      }

      Object.assign(this, options)

      if (this.instance.search) {
        if (this.instance.search.baseands) {
          this['baseAnds'] = this.instance.search.baseands
        }
      }

      let { searchdefarr, ands } = buildSearchDef(this)
      let params = buildParams(this, ands)
      if (this.inCollection) {
        const pid = this.inCollection.replace(/[o:]/g, '')
        const activeSortLength = this.sortdef.filter(x => x.active).length
        if(!activeSortLength){
          params.sort = `pos_in_o_${pid} asc`
        }
      }
      if (process.browser) {
        this.link = location.protocol + '//' + location.host + location.pathname + '?' + searchdefarr.join('&')
        window.history.replaceState(null, this.$t('Search results'), this.link)
      }

      try {
        this.$store.commit('setLoading', true)
        let response = await this.$axios.request({
          method: 'POST',
          url: '/search/select',
          data: qs.stringify(params, { arrayFormat: 'repeat' }),
          headers: {
            'content-type': 'application/x-www-form-urlencoded'
          }
        })
        this.$store.commit('setLoading', false)
        this.docs = response.data.response.docs
        this.total = response.data.response.numFound
        this.facet_counts = response.data.facet_counts
        updateFacetQueries(response.data.facet_counts.facet_queries, this.facetQueries)
        this.$nextTick(() => {
          this.$forceUpdate()
        })
      } catch (error) {
        this.$store.commit('setLoading', false)
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      }
    },
    handleSelect: function ({ term, payload }) {
      // called from Autocomplete
      // When an item has been clicked on explicitly - issue a quoted search on it's title,
      // otherwise too many unrealted results are returned
      this.q = payload ? `"${payload}"` : term
      this.search()
    },
    getAllResults: async function () {
      if (this.total > this.appconfig.search.selectionlimit) {
        this.limitdialog = true
      } else {
        let { ands } = buildSearchDef(this)
        let params = buildParams(this, ands)
        params.page = 0
        params.rows = this.total
        params.fl = [ 'pid', 'dc_title' ]
        try {
          this.$store.commit('setLoading', true)
          let response = await this.$axios.request({
            method: 'POST',
            url: '/search/select',
            data: qs.stringify(params, { arrayFormat: 'repeat' }),
            headers: {
              'content-type': 'application/x-www-form-urlencoded'
            }
          })
          this.$store.commit('setLoading', false)
          return response.data.response.docs
        } catch (error) {
          console.log(error)
          this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
          this.$store.commit('setLoading', false)
        }
      }
    },
    setSort: function (sort) {
      for (let i = 0; i < this.sortdef.length; i++) {
        if (this.sortdef[i].id === sort) {
          this.sortdef[i].active = !this.sortdef[i].active
        } else {
          this.sortdef[i].active = false
        }
      }
      this.search()
    },
    sortIsActive: function (sort) {
      for (let i = 0; i < this.sortdef.length; i++) {
        if (this.sortdef[i].id === sort) {
          return this.sortdef[i].active
        }
      }
    },
    removeCollectionFilter: function () {
      this.inCollection = ''
      this.search()
    },
    resetSearchParams: function () {
      this.q = ''
      this.inCollection = ''
      this.owner = ''
      // TODO pass showAuthorFiler
      // and showRoleFilter to searchFilters
      // as props so that we can hide toggle them off here
      // the same for roles
      this.corpAuthors.values = []
      this.persAuthors.values = []
      this.roles = []
      this.currentPage = 1
      this.pagesize = 10
      console.log(this.facetQueries)
      for (let fq of this.facetQueries) {
        // resetable might be set to false in case this search should
        // work only in limited scope (eg only in a particular collection)
        if (fq.resetable) {
          for (let q of fq.queries) {
            q.active = false
          }
          deactivateFacetQueries(fq)
        }
      }
    },
    toggleSelection: function () {
      this.selectioncheck = !this.selectioncheck
    }
  },
  watch: {
    collection: function (col) {
      this.inCollection = col
      this.search()
    },
    ownerProp: function (owner) {
      this.owner = owner
      this.search()
    },
    '$route.params': async function () {
      if (this.$route.query.reset) {
        console.log('reseting search')
        this.resetSearchParams()
        if (this.$route.query.q) {
          this.q = this.$route.query.q
        } else {
          this.q = ''
        }
        if (this.$route.query.owner) {
          this.owner = this.$route.query.owner
          this.$refs.searchFilters.resetInit()
        } else {
          this.owner = ''
        }
        if (this.$route.query.collection) {
          this.inCollection = this.$route.query.collection
        } else {
          this.inCollection = ''
        }
        await this.search()
      }
    }
  },
  data () {
    return {
      link: '',
      limitdialog: false,
      linkdialog: false,
      selectioncheck: false,
      filterdialog: false,
      q: '',
      inCollection: this.collection,
      currentPage: 1,
      pagesize: 10,
      sortdef,
      lang: 'en',
      facetQueries: [],

      corpAuthors,
      persAuthors,
      roles: [],
      owner: this.ownerProp,

      docs: [],
      total: 0,
      facet_counts: null
    }
  },
  beforeRouteUpdate: async function (to, from, next) {
    if (to.query.reset) {
      console.log('beforeRouteUpdate reseting search')
      this.resetSearchParams()
      if (to.query.q) {
        this.q = to.query.q
      } else {
        this.q = ''
      }
      if (to.query.owner) {
        this.owner = to.query.owner
      } else {
        this.owner = ''
      }
      if (to.query.collection) {
        this.inCollection = to.query.collection
      } else {
        this.inCollection = ''
      }
    }
    await this.search()
    next()
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async vm => {
      if (to.query.reset) {
        console.log('beforeRouteEnter reseting search')
        vm.resetSearchParams()
        if (to.query.q) {
          vm.q = to.query.q
        } else {
          vm.q = ''
        }
        if (to.query.owner) {
          vm.owner = to.query.owner
        } else {
          vm.owner = ''
        }
        if (to.query.collection) {
          vm.inCollection = to.query.collection
        } else {
          vm.inCollection = ''
        }
      }
      await vm.search()
    })
  },
  mounted: function () {
    this.facetQueries = JSON.parse(JSON.stringify(this.$store.state.search.facetQueries));
    this.facetQueries.push(buildDateFacet())
    
    setSearchParams(this, this.$route.query)

    // This call is delayed because at this point
    // `setInstanceSolr` has not yet been executed and
    // the solr url is missing.
    setTimeout(() => { this.search() }, 100)   
  }
}
</script>

<style scoped>
.divider {
  border-color: #bdbdbd;
}

svg {
  cursor: pointer
}

.theme--light.v-pagination .v-pagination__item--active {
  box-shadow: none;
  -webkit-box-shadow: none;
  }

.skip-link {
  position: absolute;
  left: -9999px;
  top: 10px;
}
</style>
