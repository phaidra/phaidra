import { defineStore } from 'pinia'

/**
 * Minimal root store for the PVC demo app.
 * Host apps (phaidra-ui) register their own richer store with the same id 'root'.
 */
export const useRootStore = defineStore('root', {
  state: () => ({
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
    loading: false,
    snackbar: false
  }),
  actions: {
    setLoading (loading) {
      this.loading = loading
    },
    setAlerts (alerts) {
      for (const a of alerts) {
        if (a.type === 'success') {
          this.snackbar = true
        }
      }
      this.alerts = alerts
    },
    clearAlert (alert) {
      this.alerts = this.alerts.filter(e => e !== alert)
    },
    clearUser () {
      this.user.token = ''
    },
    setToken (token) {
      this.user.token = token
    },
    setLoginData (logindata) {
      this.user.username = logindata.username
      this.user.firstname = logindata.firstname
      this.user.lastname = logindata.lastname
      this.user.email = logindata.email
      this.user.org_units_l1 = logindata.org_units_l1
      this.user.org_units_l2 = logindata.org_units_l2
    },
    initStore () {
      this.user.token = ''
      this.alerts = []
    },
    setInstanceApi (api) {
      this.instanceconfig.api = api
    },
    setVocServer (vocserver) {
      this.appconfig.apis.vocserver = vocserver
    },
    setInstanceSolr (solr) {
      this.instanceconfig.solr = solr
    },
    setInstancePhaidra (baseurl) {
      this.instanceconfig.baseurl = baseurl
    },
    setSuggester (data) {
      this.appconfig.suggesters[data.suggester] = data.url
    },
    async login (credentials) {
      this.initStore()
      try {
        const response = await this.$axios.request({
          method: 'GET',
          url: '/signin',
          headers: {
            Authorization: 'Basic ' + btoa(credentials.username + ':' + credentials.password)
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.setAlerts(response.data.alerts)
        }
        if (response.data.status === 200) {
          this.setToken(response.data['XSRF-TOKEN'])
          document.cookie = 'X-XSRF-TOKEN=' + response.data['XSRF-TOKEN']
        }
      } catch (error) {
        console.log(error)
        this.setAlerts([{ type: 'danger', msg: error }])
      }
    },
    async logout () {
      try {
        const response = await this.$axios.request({
          method: 'GET',
          url: '/signout',
          headers: {
            'X-XSRF-TOKEN': this.user.token
          }
        })
        this.initStore()
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.setAlerts(response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.setAlerts([{ type: 'danger', msg: error }])
      } finally {
        this.initStore()
      }
    },
    async getLoginData () {
      try {
        const response = await this.$axios.get('/directory/user/data', {
          headers: {
            'X-XSRF-TOKEN': this.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.setAlerts(response.data.alerts)
        }
        this.setLoginData(response.data.user_data)
      } catch (error) {
        if (error.response && error.response.status === 401) {
          this.logout()
        }
        console.log(error)
      }
    }
  }
})

export default useRootStore
