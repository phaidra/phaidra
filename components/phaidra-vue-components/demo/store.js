var store = new Vuex.Store({
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
          }
        },
        suggesters: {}
      },
      user: {
        username: '',
        token: ''
      },
      alerts: {
        alerts: []
      }
    },
    mutations: {
      setAlerts (state, alerts) {
        state.alerts.alerts = alerts
      },
      clearAlert (state, alert) {
        state.alerts.alerts = state.alerts.alerts.filter(e => e !== alert)
      },
      setUsername (state, username) {
        state.user.username = username
      },
      clearUser (state) {
        state.user.username = '',
        state.user.token = ''
      },
      setToken (state, token) {
        state.user.token = token
      },
      initStore (state) {
        state.user.username = '',
        state.user.token = '',
        state.alerts.alerts = []
      },
      clearUser (state) {
        state.user.username = '',
        state.user.token = ''
      },
      setInstanceApi (state, api) {
        state.instanceconfig.api = api
      },
      setInstanceSolr (state, solr) {
        state.instanceconfig.solr = solr
      },
      setInstancePhaidra (state, baseurl) {
        state.instanceconfig.baseurl = baseurl
      },
      setSuggester (state, data) {
        Vue.set(state.appconfig.suggesters, data.suggester, data.url)
      }
    },
    actions: {
  
      login ({ commit, dispatch, state, rootState }, credentials) {
        return new Promise((resolve, reject) => {
          commit('initStore')
    
          commit('setUsername', credentials.username)
    
          fetch(rootState.instanceconfig.api + '/signin', {
            method: 'GET',
            mode: 'cors',
            headers: {
              'Authorization': 'Basic ' + btoa(credentials.username + ':' + credentials.password)
            }
          })
          .then(function (response) { return response.json() })
          .then(function (json) {
            if (json.alerts && json.alerts.length > 0) {
              commit('setAlerts', json.alerts)
            }
            if (json.status === 200) {
              commit('setToken', json['XSRF-TOKEN'])
              document.cookie = 'X-XSRF-TOKEN=' + json['XSRF-TOKEN']
            }
          })
          .catch(function (error) {
            console.log(error)
            reject()
          })
        })
      },
      logout ({ commit, dispatch, state, rootState }) {
        return new Promise((resolve, reject) => {
          fetch(rootState.instanceconfig.api + '/signout', {
            method: 'GET',
            mode: 'cors',
            headers: {
              'X-XSRF-TOKEN': state.token
            }
          })
          .then(function (response) { return response.json() })
          .then(function (json) {
            commit('initStore')
            if (json.alerts && json.alerts.length > 0) {
              commit('setAlerts', json.alerts)
            }
            resolve()
          })
          .catch(function (error) {
            console.log(error)
            commit('initStore')
            resolve()
          })
        })
      }
    },
    modules: {
      vocabularystore
    },
    strict: true
  })
  