import Vue from 'vue'
import qs from 'qs'
import config from '../config/phaidra-ui'

export const state = () => ({
  config,
  appconfig: config.global,
  instanceconfig: config.instances[config.defaultinstance],
  snackbar: false,
  alerts: [],
  objectInfo: null,
  objectMembers: [],
  collectionMembers: [],
  user: {
    token: null
  },
  groups: [],
  breadcrumbs: [],
  loading: false,
  chartsUrl: []
})

export const mutations = {
  setInstanceConfig(state, instanceconfig) {
    let configurable = [
      'title', 
      'institution', 
      'institutionurl', 
      'address', 
      'phone', 
      'email', 
      'oaidataprovider',
      'languages', 
      'owneremailoverride', 
      'showdeletebutton',
      'markmandatoryfnc',
      'requestdoiemail', 
      'validationfnc',
      'groups',
      'defaulttemplateid',
      'cms_header',
      'cms_footer',
      'cms_home',
      'cms_impressum',
      'cms_submit',
      'cms_css',
      'cms_help',
      'accessrestrictions_showpersons',
      'accessrestrictions_showaccounts',
      'accessrestrictions_showedupersonaffiliation',
      'accessrestrictions_showorgunits',
      'accessrestrictions_showgroups'
    ] 
    for (const p of configurable) {
      if (instanceconfig.hasOwnProperty(p)) {
        state.instanceconfig[p] = instanceconfig[p]
      }
    }
  },
  setInstanceConfigBaseUrl(state, baseurl) {
    Vue.set(state.instanceconfig, 'baseurl', baseurl)
  },
  setInstanceConfigApiBaseUrl(state, api) {
    Vue.set(state.instanceconfig, 'api', api)
  },
  updateBreadcrumbs(state, transition) {
    state.breadcrumbs = [
      {
        text: this.$i18n.t(state.instanceconfig.institution),
        external: true,
        to: state.instanceconfig.institutionurl
      },
      {
        text: state.instanceconfig.title,
        to: transition.localePath('/')
      }
    ]
    if (transition.to.path.includes('/repostats')) {
      state.breadcrumbs.push(
        {
          text: 'Repository statistics',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/metadata-fields-help')) {
      state.breadcrumbs.push(
        {
          text: 'Metadata fields overview',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/impressum')) {
      state.breadcrumbs.push(
        {
          text: 'Impressum',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/statistics')) {
      state.breadcrumbs.push(
        {
          text: 'Statistics',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/search')) {
      state.breadcrumbs.push(
        {
          text: 'Search',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('lists')) {
      state.breadcrumbs.push(
        {
          text: 'Object lists',
          to: { name: transition.to.path, params: { token: transition.to.params.token } },
          disabled: true
        }
      )
    } else {
      if (transition.to.path.includes('list')) {
        state.breadcrumbs.push(
          {
            text: transition.to.params.token,
            to: { name: transition.to.path, params: { token: transition.to.params.token } },
            disabled: true
          }
        )
      }
    }
    if (transition.to.path.includes('detail')) {
      if (transition.from.path.includes('/search')) {
        state.breadcrumbs.push(
          {
            text: 'Search',
            to: transition.from.path
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Detail ' + transition.to.params.pid,
          to: { name: transition.to.path, params: { pid: transition.to.params.pid } },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/metadata') && !transition.to.path.includes('edit') && !transition.to.path.includes('help')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Metadata ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('metadata') && transition.to.path.includes('edit') && !transition.to.path.includes('help')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Metadata editor ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }

    // if (transition.to.path.includes('uwmetadata')) {
    //   if (transition.from.path.includes('detail')) {
    //     state.breadcrumbs.push(
    //       {
    //         text: 'Detail ' + transition.from.params.pid,
    //         to: { path: transition.from.path }
    //       }
    //     )
    //   }
    //   state.breadcrumbs.push(
    //     {
    //       text: 'Metadata editor ' + transition.to.params.pid,
    //       to: { path: transition.to.path },
    //       disabled: true
    //     }
    //   )
    // }

    if (transition.to.path.includes('rights')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Access rights ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('sort')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Sort ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('relationships')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Relationships of ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('delete')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Delete of ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('upload-webversion')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Upload web version of ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('submitrelated')) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Submit of an object related to ' + transition.from.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('stats') && (!transition.to.path.includes('repostats'))) {
      if (transition.from.path.includes('detail')) {
        state.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      state.breadcrumbs.push(
        {
          text: 'Usage statistics for ' + transition.from.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }

    if (transition.to.path.includes('submit') && transition.to.params && transition.to.params.cmodel && !transition.to.params.submitform) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      state.breadcrumbs.push(
        {
          text: 'Upload ' + transition.to.params.cmodel,
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit') && transition.to.params && transition.to.params.cmodel && transition.to.params.submitform) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      if (transition.to.params.cmodel !== 'resource') {
        state.breadcrumbs.push(
          {
            text: 'Upload ' + transition.to.params.cmodel,
            to: { path: transition.from.path }
          }
        )
      }
      if (transition.to.params.submitform !== 'general') {
        state.breadcrumbs.push(
          {
            text: 'Upload ' + transition.to.params.cmodel + ' ' + transition.to.params.submitform,
            disabled: true
          }
        )
      } else {
        state.breadcrumbs.push(
          {
            text: 'Upload ' + transition.to.params.cmodel,
            disabled: true
          }
        )
      }
    } else if (transition.to.path.includes('submit/simple')) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      state.breadcrumbs.push(
        {
          text: 'Simple upload',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit-custom')) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      state.breadcrumbs.push(
        {
          text: 'Upload template ' + transition.to.params.templateid,
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit/uwm')) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      state.breadcrumbs.push(
        {
          text: 'Legacy Upload (UWMetadata)',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('/submit/empty')) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      state.breadcrumbs.push(
        {
          text: 'New template',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit/ksa-eda')) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      state.breadcrumbs.push(
        {
          text: 'KSA EDA',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit/bruckneruni')) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      state.breadcrumbs.push(
        {
          text: 'Bruckneruni',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit')) {
      state.breadcrumbs.push(
        {
          text: 'Upload',
          disabled: true
        }
      )
    }
  },
  setLoading(state, loading) {
    state.loading = loading
  },
  setGroups(state, groups) {
    state.groups = groups
  },
  setObjectInfo(state, objectInfo) {
    state.objectInfo = objectInfo
  },
  setObjectMembers(state, objectMembers) {
    state.objectMembers = objectMembers
  },
  setCollectionMembers(state, collectionMembers) {
    state.collectionMembers = collectionMembers
  },
  setCollectionMembersTotal(state, collectionMembersTotal) {
    state.collectionMembersTotal = collectionMembersTotal
  },
  switchInstance(state, instance) {
    state.instance = state.config.instances[instance]
  },
  hideSnackbar(state) {
    state.snackbar = false
  },
  setAlerts(state, alerts) {
    for (const a of alerts) {
      if (a.type === 'success') {
        state.snackbar = true
      }
    }
    state.alerts = alerts
  },
  clearAlert(state, alert) {
    state.alerts = state.alerts.filter(e => e !== alert)
  },
  clearAlerts(state, alert) {
    state.alerts = []
  },
  setUserData(state, user) {
    const data = {
      ...state.user,
      ...user
    }
    state.user = data
  },
  setUsername(state, username) {
    Vue.set(state.user, 'username', username)
  },
  setToken(state, token) {
    Vue.set(state.user, 'token', token)
    if (process.browser) {
      window.localStorage.setItem("XSRF-TOKEN", token)
    }
  },
  setLoginData(state, logindata) {
    console.log('setLoginData: ')
    const user = {
      isadmin: logindata.isadmin,
      username: logindata.username,
      firstname: logindata.firstname,
      lastname: logindata.lastname,
      email: logindata.email,
      org_units_l1: logindata.org_units_l1,
      org_units_l2: logindata.org_units_l2
    }
    console.log(user)
    const data = {
      ...state.user,
      ...user
    }
    state.user = data
  },
  clearUser(state) {
    state.user = {}
    let cookieOptions = {
      path: '/',
      secure: true,
      sameSite: 'Strict',
      domain: state.instanceconfig.cookiedomain
    }
    this.$cookies.remove('XSRF-TOKEN', cookieOptions)
    if (process.browser) {
      window.localStorage.removeItem("XSRF-TOKEN")
    }
  },
  clearStore(state) {
    state.objectInfo = null
    state.objectMembers = []
    state.collectionMembers = []
    state.user = {}
    state.groups = []
    let cookieOptions = {
      path: '/',
      secure: true,
      sameSite: 'Strict',
      domain: state.instanceconfig.cookiedomain
    }
    this.$cookies.remove('XSRF-TOKEN', cookieOptions)
    if (process.browser) {
      window.localStorage.removeItem("XSRF-TOKEN")
    }
  },
  setCharts(state, url) {
    state.chartsUrl.push(url)
  },
  clearCharts(state) {
    state.chartsUrl = []
  }
}

export const actions = {

  setInstanceConfig({ commit }, config) {
    commit('setInstanceConfig', config)
  },

  async nuxtServerInit({ commit, dispatch }, { req }) {
    const token = this.$cookies.get('XSRF-TOKEN')
    commit('setToken', token)
    if (token) {
      await dispatch('getLoginData')
    }
  },

  async fetchObjectInfo({ commit, state }, pid) {

    console.log('fetching object info in store: ' + pid)
    try {
      let response
      if (state.user.token) {
        response = await this.$axios.get('/object/' + pid + '/info',
          {
            headers: {
              'X-XSRF-TOKEN': state.user.token
            }
          }
        )
      } else {
        response = await this.$axios.get('/object/' + pid + '/info')
      }
      commit('setObjectInfo', response.data.info)
    } catch (error) {
      if (error.response?.status === 410) {
        console.log('deleted object data')
        console.log(error.response.data.info)
        commit('setObjectInfo', error.response.data.info)
      } else {
        console.log('fetchObjectInfo error')
        console.log(error)
      }
    }
  },
  async fetchObjectMembers({ dispatch, commit, state }, parent) {
    commit('setObjectMembers', [])
    try {
      if (parent.members.length > 0) {
        const members = []
        for (const doc of parent.members) {
          let memresponse
          if (state.user.token) {
            memresponse = await this.$axios.get('/object/' + doc.pid + '/info',
              {
                headers: {
                  'X-XSRF-TOKEN': state.user.token
                }
              }
            )
          } else {
            memresponse = await this.$axios.get('/object/' + doc.pid + '/info')
          }
          members.push(memresponse.data.info)
        }
        const posField = 'pos_in_' + parent.pid.replace(':', '_')
        for (const m of members) {
          if (!m[posField]) {
            m[posField] = members.length
          }
        }
        members.sort((a, b) => a[posField] - b[posField])
        commit('setObjectMembers', members)
      } else {
        commit('setObjectMembers', [])
      }
    } catch (error) {
    }
  },
  async fetchCollectionMembers({ dispatch, commit, state }, options) {
    commit('setCollectionMembers', [])
    commit('setCollectionMembersTotal', 0)
    const id = options.pid.replace(/[o:]/g, '')
    const params = {
      q: '-ismemberof:["" TO *]',
      defType: 'edismax',
      wt: 'json',
      fq: `owner:* AND ispartof:"${options.pid}"`,
      start: (options.page - 1) * options.pagesize,
      rows: options.pagesize,
      sort: `pos_in_o_${id} asc`
    }
    if (options.onlylatestversion) {
      params.q = '-hassuccessor:* AND ' + params.q
    }
    try {
      commit('setLoading', true)
      const response = await this.$axios.request({
        method: 'POST',
        url: '/search/select',
        data: qs.stringify(params, { arrayFormat: 'repeat' }),
        headers: {
          'content-type': 'application/x-www-form-urlencoded'
        }
      })
      console.log('setCollectionMembersTotal:' + response.data.response.numFound)
      commit('setCollectionMembers', response.data.response.docs)
      commit('setCollectionMembersTotal', response.data.response.numFound)
    } catch (error) {
      commit('setAlerts', [{ type: 'error', msg: error }])
    } finally {
      commit('setLoading', false)
    }
  },
  async getLoginData({ commit, dispatch, state }) {
    console.log('getLoginData token: ' + state.user.token)
    try {
      const response = await this.$axios.get('/directory/user/data', {
        headers: {
          'X-XSRF-TOKEN': state.user.token
        }
      })
      if (response.data.alerts && response.data.alerts.length > 0) {
        commit('setAlerts', response.data.alerts)
      }
      commit('setLoginData', response.data.user_data)
    } catch (error) {
      console.log('getLoginData error')
      console.log(error)
      if (error.response?.status === 401) {
        commit('setAlerts', [{ type: 'success', msg: 'You have been logged out' }])
        commit('clearStore')
      }
    }
  },
  async login({ commit, dispatch, state }, credentials) {
    commit('clearStore')
    commit('clearAlerts')
    commit('setUsername', credentials.username)
    try {
      const response = await this.$axios.get('/signin', {
        headers: {
          Authorization: 'Basic ' + btoa(credentials.username + ':' + credentials.password)
        }
      })
      if (response.data.alerts && response.data.alerts.length > 0) {
        commit('setAlerts', response.data.alerts)
      }
      if (response.status === 200) {
        if (state.instanceconfig.cookiedomain) {
          let cookieOptions = {
            path: '/',
            secure: true,
            sameSite: 'Strict',
            domain: state.instanceconfig.cookiedomain
          }
          // we need this because on instances where api runs under services.phaidra... the api
          // cannot set the cookie
          console.log('setting cookie ' + response.data['XSRF-TOKEN'])
          console.log(cookieOptions)
          this.$cookies.set('XSRF-TOKEN', response.data['XSRF-TOKEN'], cookieOptions)
        }
        console.log('setting token ' + response.data['XSRF-TOKEN'])
        commit('setToken', response.data['XSRF-TOKEN'])
        dispatch('getLoginData')
      }
    } catch (error) {
      console.log('login error')
      console.log(error)
    }
  },
  async logout({ commit, dispatch, state }) {
    commit('clearAlerts')
    try {
      const response = await this.$axios.get('/signout', {
        headers: {
          'X-XSRF-TOKEN': state.user.token
        }
      })
      if (response.data.alerts && response.data.alerts.length > 0) {
        console.log(response.data.alerts)
      }
    } catch (error) {
      console.log(error)
    } finally {
      commit('setAlerts', [{ type: 'success', msg: 'You have been logged out' }])
      commit('clearStore')
    }
  },
  async getUserGroups({ commit, state }) {
    commit('clearAlerts')
    try {
      const response = await this.$axios.get('/groups', {
        headers: {
          'X-XSRF-TOKEN': state.user.token
        }
      })
      if (response.data.alerts && response.data.alerts.length > 0) {
        commit('setAlerts', response.data.alerts)
      }
      commit('setGroups', response.data.groups)
    } catch (error) {
      console.log(error)
    }
  },
  switchInstance({ commit }, instance) {
    commit('switchInstance', instance)
  },

  setCharts({ commit, dispatch, state }, chartUrl) {
    commit('setCharts', chartUrl)
  },

  clearCharts({ commit, dispatch, state }) {
    commit('clearCharts')
  }
}
