import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import vocabulary from './modules/vocabulary'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
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
      Vue.set(state.user, 'token', '')
    },
    setToken (state, token) {
      Vue.set(state.user, 'token', token)
    },
    setLoginData (state, logindata) {
      Vue.set(state.user, 'username', logindata.username)
      Vue.set(state.user, 'firstname', logindata.firstname)
      Vue.set(state.user, 'lastname', logindata.lastname)
      Vue.set(state.user, 'email', logindata.email)
      Vue.set(state.user, 'org_units_l1', logindata.org_units_l1)
      Vue.set(state.user, 'org_units_l2', logindata.org_units_l2)
    },
    initStore (state) {
      Vue.set(state.user, 'token', '')
      state.alerts = []
    },
    setInstanceApi (state, api) {
      Vue.set(state.instanceconfig, 'api', api)
    },
    setVocServer (state, vocserver) {
      Vue.set(state.appconfig.apis, 'vocserver', vocserver)
    },
    setInstanceSolr (state, solr) {
      Vue.set(state.instanceconfig, 'solr', solr)
    },
    setInstancePhaidra (state, baseurl) {
      Vue.set(state.instanceconfig, 'baseurl', baseurl)
    },
    setSuggester (state, data) {
      Vue.set(state.appconfig.suggesters, data.suggester, data.url)
    }
  },
  actions: {

    async login ({ commit, state }, credentials) {
      commit('initStore')
      try {
        let response = await axios.request({
          method: 'GET',
          url: state.instanceconfig.api + '/signin',
          headers: {
            'Authorization': 'Basic ' + btoa(credentials.username + ':' + credentials.password)
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
        let response = await axios.request({
          method: 'GET',
          url: state.instanceconfig.api + '/signout',
          headers: {
            'X-XSRF-TOKEN': state.token
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
        let response = await axios.get(state.instanceconfig.api + '/directory/user/data', {
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
        if (error.response.status === 401) {
          // this token is invalid
          dispatch('logout')
        }
        console.log(error)
      }
    }
  },
  modules: {
    vocabulary
  },
  strict: debug
})
