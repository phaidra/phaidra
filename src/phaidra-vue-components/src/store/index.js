import { createStore } from 'vuex'
import vocabulary from './modules/vocabulary'
import info from './modules/info'
import search from './modules/search'

const debug = process.env.NODE_ENV !== 'production'

/** Attach axios instance so actions can use this.$axios (set via store plugin in main.js / host app). */
function axiosStorePlugin (store) {
  store.$axios = null
}

const store = createStore({
  state: {
    instanceconfig: {
      api: '',
      solr: '',
      baseurl: ''
    },
    appconfig: {
      search: {
        selectionlimit: 5000
      },
      apis: {
        doi: {
          baseurl: 'doi.org',
          accept: 'application/vnd.citationstyles.csl+json'
        },
        sherparomeo: {
          url: 'http://www.sherpa.ac.uk/romeo/api29.php',
          key: 'V9cjsv6PTJE'
        },
        vocserver: {
          url: 'https://vocab.phaidra.org/fuseki/',
          dataset: 'vocab'
        },
        geonames: {
          search: 'https://secure.geonames.org/searchJSON',
          username: 'phaidra',
          maxRows: 20
        },
        dante: {
          search: 'https://api.dante.gbv.de/search',
          resolve: 'https://api.dante.gbv.de/data',
          limit: 50
        }
      },
      suggesters: {}
    },
    user: {
      token: ''
    },
    alerts: [],
    loading: false
  },
  mutations: {
    setLoading (state, loading) {
      state.loading = loading
    },
    setAlerts (state, alerts) {
      state.alerts = alerts
    },
    clearAlert (state, alert) {
      state.alerts = state.alerts.filter(e => e !== alert)
    },
    clearUser (state) {
      state.user.token = ''
    },
    setToken (state, token) {
      state.user.token = token
    },
    setLoginData (state, logindata) {
      state.user.username = logindata.username
      state.user.firstname = logindata.firstname
      state.user.lastname = logindata.lastname
      state.user.email = logindata.email
      state.user.org_units_l1 = logindata.org_units_l1
      state.user.org_units_l2 = logindata.org_units_l2
    },
    initStore (state) {
      state.user.token = ''
      state.alerts = []
    },
    setInstanceApi (state, api) {
      state.instanceconfig.api = api
    },
    setVocServer (state, vocserver) {
      state.appconfig.apis.vocserver = vocserver
    },
    setInstanceSolr (state, solr) {
      state.instanceconfig.solr = solr
    },
    setInstancePhaidra (state, baseurl) {
      state.instanceconfig.baseurl = baseurl
    },
    setSuggester (state, data) {
      state.appconfig.suggesters[data.suggester] = data.url
    }
  },
  actions: {
    async login ({ commit, state }, credentials) {
      commit('initStore')
      try {
        const response = await this.$axios.request({
          method: 'GET',
          url: '/signin',
          headers: {
            Authorization: 'Basic ' + btoa(credentials.username + ':' + credentials.password)
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          commit('setAlerts', response.data.alerts)
        }
        if (response.data.status === 200) {
          commit('setToken', response.data['XSRF-TOKEN'])
          document.cookie = 'X-XSRF-TOKEN=' + response.data['XSRF-TOKEN']
        }
      } catch (error) {
        console.log(error)
        commit('setAlerts', [{ type: 'danger', msg: error }])
      }
    },
    async logout ({ commit, state }) {
      try {
        const response = await this.$axios.request({
          method: 'GET',
          url: '/signout',
          headers: {
            'X-XSRF-TOKEN': state.user.token
          }
        })
        commit('initStore')
        if (response.data.alerts && response.data.alerts.length > 0) {
          commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        commit('initStore')
      }
    },
    async getLoginData ({ commit, dispatch, state }) {
      try {
        const response = await this.$axios.get('/directory/user/data', {
          headers: {
            'X-XSRF-TOKEN': state.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          commit('setAlerts', response.data.alerts)
        }
        console.log('[' + state.user.username + '] got user data firstname[' + response.data.user_data.firstname + '] lastname[' + response.data.user_data.lastname + '] email[' + response.data.user_data.email + ']')
        commit('setLoginData', response.data.user_data)
      } catch (error) {
        if (error.response && error.response.status === 401) {
          dispatch('logout')
        }
        console.log(error)
      }
    }
  },
  modules: {
    vocabulary,
    info,
    search
  },
  strict: debug,
  plugins: [axiosStorePlugin]
})

export function setStoreAxios (axiosInstance) {
  store.$axios = axiosInstance
}

export default store
