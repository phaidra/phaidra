import { defineStore } from 'pinia'
import qs from 'qs'
import config from '../config/phaidra-ui'

export const useRootStore = defineStore('root', {
  state: () => ({
    config,
    appconfig: config.global,
    instanceconfig: config.instances[config.defaultinstance],
    snackbar: false,
    alerts: [],
    objectInfo: null,
    objectMembers: [],
    collectionMembers: [],
    collectionMembersTotal: 0,
    user: {
      token: null
    },
    groups: [],
    breadcrumbs: [],
    loading: false,
    chartsUrl: []
  }),
  actions: {

  setInstanceConfig(instanceconfig) {
    // Remove any API field from config to prevent conflicts
    if (instanceconfig && instanceconfig.api) {
      delete instanceconfig.api
    }

    let configurable = [
      'baseurl',
      'api',
      'title', 
      'institution', 
      'institutionurl', 
      'address', 
      'phone', 
      'email', 
      'oaidataprovider',
      'googlesiteverificationcode',
      'languages',
      'owneremailoverride',
      'showdeletebutton',
      'markmandatoryfnc',
      'requestdoiemail',
      'requestdoiusemailto',
      'validationfnc',
      'groups',
      'defaulttemplateid',
      'cms_header',
      'cms_footer',
      'cms_home',
      'cms_impressum',
      'cms_contact',
      'cms_code_of_ethics',
      'cms_editorial_policies',
      'cms_file_formats',
      'cms_submit',
      'cms_css',
      'cms_help',
      'accessrestrictions_showpersons',
      'accessrestrictions_showaccounts',
      'accessrestrictions_showedupersonaffiliation',
      'accessrestrictions_showorgunits',
      'accessrestrictions_showgroups',
      'data_affiliations',
      'feedback',
      'disableUploader',
      'doiImport',
      'enableresourcelink',
      'addannotation',
      'forcePreview',
      'hideInstitutionName',
      'isParentSelectionDisabled',
      'hideBreadcrumbsOnHomepage',
      'data_ot4rt',
      'enableCookieBanner',
      'cookiePrivacyPolicyUrl',
      'enableInfoBanner',
      'infoBannerMessage',
      'data_i18n',
      'customJavaScript',
      'downloadabledatastreams',
      'disableChecksum',
      'searchbaseands',
      'irbaseurl',
      'phaidra_doi_prefix',
      'hideContainedInPages',
      'extendedContribution'
    ]
    for (const p of configurable) {
      if (instanceconfig.hasOwnProperty(p)) {
        this.instanceconfig[p] = instanceconfig[p]
      }
    }
  },
  setInstanceConfigBaseUrl(baseurl) {
    this.instanceconfig.baseurl = baseurl
  },
  setInstanceConfigApiBaseUrl(api) {
    this.instanceconfig.api = api
  },
  setInstanceConfigCookieDomain(cookieDomain) {
    this.instanceconfig.cookiedomain = cookieDomain
  },
  updateBreadcrumbs(transition) {
    this.breadcrumbs = [
      {
        text: this.instanceconfig.title,
        to: transition.localePath('/')
      }
    ]
    if (!this.instanceconfig.hideInstitutionName) {
      this.breadcrumbs.unshift(
        {
          text: this.instanceconfig.institution || '',
          external: true,
          to: this.instanceconfig.institutionurl
        }
      )
    }
    if (transition.to.path.includes('/bulk-upload')) {
      this.breadcrumbs.push(
        {
          text: 'Bulk upload',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/contact')) {
      this.breadcrumbs.push(
        {
          text: 'Contact',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/editorial-policies')) {
      this.breadcrumbs.push(
        {
          text: 'Editorial Policies',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/code-of-ethics')) {
      this.breadcrumbs.push(
        {
          text: 'Code of Ethics',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/file-formats')) {
      this.breadcrumbs.push(
        {
          text: 'File Formats',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/repostats')) {
      this.breadcrumbs.push(
        {
          text: 'Repository statistics',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/metadata-fields-help')) {
      this.breadcrumbs.push(
        {
          text: 'Metadata fields overview',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/impressum')) {
      this.breadcrumbs.push(
        {
          text: 'Impressum',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/statistics')) {
      this.breadcrumbs.push(
        {
          text: 'Statistics',
          to: transition.to.name,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/search')) {
      this.breadcrumbs.push(
        {
          text: 'Search',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/templates')) {
      this.breadcrumbs.push(
        {
          text: 'Templates',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('lists')) {
      this.breadcrumbs.push(
        {
          text: 'Object lists',
          to: { name: transition.to.path, params: { token: transition.to.params.token } },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/credits')) {
      this.breadcrumbs.push(
        {
          text: 'Credits',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/admin')) {
      this.breadcrumbs.push(
        {
          text: 'Admin',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/termsofuse')) {
      this.breadcrumbs.push(
        {
          text: 'Terms of use',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/login')) {
      this.breadcrumbs.push(
        {
          text: 'Login',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/help')) {
      this.breadcrumbs.push(
        {
          text: 'Help',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/groups')) {
      this.breadcrumbs.push(
        {
          text: 'Groups',
          to: transition.to.path,
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('detail')) {
      if (transition.from.path.includes('/search')) {
        this.breadcrumbs.push(
          {
            text: 'Search',
            to: transition.from.path
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Detail ' + transition.to.params.pid,
          to: { name: transition.to.path, params: { pid: transition.to.params.pid } },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('/metadata') && !transition.to.path.includes('edit') && !transition.to.path.includes('help')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Metadata ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('metadata') && transition.to.path.includes('edit') && !transition.to.path.includes('help')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Metadata editor ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }

    // if (transition.to.path.includes('uwmetadata')) {
    //   if (transition.from.path.includes('detail')) {
    //     this.breadcrumbs.push(
    //       {
    //         text: 'Detail ' + transition.from.params.pid,
    //         to: { path: transition.from.path }
    //       }
    //     )
    //   }
    //   this.breadcrumbs.push(
    //     {
    //       text: 'Metadata editor ' + transition.to.params.pid,
    //       to: { path: transition.to.path },
    //       disabled: true
    //     }
    //   )
    // }

    if (transition.to.path.includes('rights')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Access rights ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('sort')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Sort ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('relationships')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Relationships of ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('delete')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Delete of ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('upload-webversion')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Upload web version of ' + transition.to.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('submitrelated')) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Submit of an object related to ' + transition.from.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }
    if (transition.to.path.includes('stats') && (!transition.to.path.includes('repostats'))) {
      if (transition.from.path.includes('detail')) {
        this.breadcrumbs.push(
          {
            text: 'Detail ' + transition.from.params.pid,
            to: { path: transition.from.path }
          }
        )
      }
      this.breadcrumbs.push(
        {
          text: 'Usage statistics for ' + transition.from.params.pid,
          to: { path: transition.to.path },
          disabled: true
        }
      )
    }

    if (transition.to.path.includes('submit') && transition.to.params && transition.to.params.cmodel && !transition.to.params.submitform) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      this.breadcrumbs.push(
        {
          text: 'Upload ' + transition.to.params.cmodel,
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit') && transition.to.params && transition.to.params.cmodel && transition.to.params.submitform) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      if (transition.to.params.cmodel !== 'resource') {
        this.breadcrumbs.push(
          {
            text: 'Upload ' + transition.to.params.cmodel,
            to: { path: transition.from.path }
          }
        )
      }
      if (transition.to.params.submitform !== 'general') {
        this.breadcrumbs.push(
          {
            text: 'Upload ' + transition.to.params.cmodel + ' ' + transition.to.params.submitform,
            disabled: true
          }
        )
      } else {
        this.breadcrumbs.push(
          {
            text: 'Upload ' + transition.to.params.cmodel,
            disabled: true
          }
        )
      }
    } else if (transition.to.path.includes('submit/simple')) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      this.breadcrumbs.push(
        {
          text: 'Simple upload',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit-custom')) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      this.breadcrumbs.push(
        {
          text: 'Upload template ' + transition.to.params.templateid,
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit/uwm')) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      this.breadcrumbs.push(
        {
          text: 'Legacy Upload (UWMetadata)',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('/submit/empty')) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      this.breadcrumbs.push(
        {
          text: 'New template',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit/ksa-eda')) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      this.breadcrumbs.push(
        {
          text: 'KSA EDA',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit/bruckneruni')) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          to: transition.from.path
        }
      )
      this.breadcrumbs.push(
        {
          text: 'Bruckneruni',
          disabled: true
        }
      )
    } else if (transition.to.path.includes('submit')) {
      this.breadcrumbs.push(
        {
          text: 'Upload',
          disabled: true
        }
      )
    }
  },
  addBreadcrumb(breadcrumb) {
    this.breadcrumbs.push(breadcrumb)
  },
  updateCollectionBreadcrumb(title) {
    if (this.breadcrumbs.length > 0) {
      const lastBreadcrumb = this.breadcrumbs[this.breadcrumbs.length - 1]
      if (lastBreadcrumb && lastBreadcrumb.disabled) {
        lastBreadcrumb.text = title
      }
    }
  },
  setLoading(loading) {
    this.loading = loading
  },
  setGroups(groups) {
    this.groups = groups
  },
  setObjectInfo(objectInfo) {
    this.objectInfo = objectInfo
  },
  setObjectMembers(objectMembers) {
    this.objectMembers = objectMembers
  },
  setCollectionMembers(collectionMembers) {
    this.collectionMembers = collectionMembers
  },
  setCollectionMembersTotal(collectionMembersTotal) {
    this.collectionMembersTotal = collectionMembersTotal
  },
  switchInstance(instance) {
    this.instance = this.config.instances[instance]
  },
  hideSnackbar() {
    this.snackbar = false
  },
  setAlerts(alerts) {
    for (const a of alerts) {
      if (a.type === 'success') {
        this.snackbar = true
      }
    }
    this.alerts = alerts
  },
  clearAlert(alert) {
    this.alerts = this.alerts.filter(e => e !== alert)
  },
  clearAlerts(alert) {
    this.alerts = []
  },
  setUserData(user) {
    const data = {
      ...this.user,
      ...user
    }
    this.user = data
  },
  setUsername(username) {
    this.user.username = username
  },
  setToken(token) {
    this.user.token = token
    if (import.meta.client) {
      window.localStorage.setItem("XSRF-TOKEN", token)
    }
  },
  setLoginData(logindata) {
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
      ...this.user,
      ...user
    }
    this.user = data
  },
  clearUser() {
    this.user = {}
    let cookieOptions = {
      path: '/',
      secure: true,
      sameSite: 'Strict'
    }
    this.$cookies.remove('XSRF-TOKEN', cookieOptions)
    if (import.meta.client) {
      window.localStorage.removeItem("XSRF-TOKEN")
    }
  },
  clearStore() {
    this.objectInfo = null
    this.objectMembers = []
    this.collectionMembers = []
    this.user = {}
    this.groups = []
    let cookieOptions = {
      path: '/',
      secure: true,
      sameSite: 'Strict'
    }
    this.$cookies.remove('XSRF-TOKEN', cookieOptions)
    if (import.meta.client) {
      window.localStorage.removeItem("XSRF-TOKEN")
    }
  },
  setCharts(url) {
    this.chartsUrl.push(url)
  },
  clearCharts() {
    this.chartsUrl = []
  }
,

  async nuxtServerInit({ token } = {}) {
    const xsrfToken = token ?? this.$cookies?.get?.('XSRF-TOKEN')
    this.setToken(xsrfToken)
    if (xsrfToken) {
      await this.getLoginData()
    }
  },

  async fetchObjectInfo(pid) {

    console.log('fetching object info in store: ' + pid)
    try {
      let response
      if (this.user.token) {
        response = await this.$axios.get('/object/' + pid + '/info',
          {
            headers: {
              'X-XSRF-TOKEN': this.user.token
            }
          }
        )
      } else {
        response = await this.$axios.get('/object/' + pid + '/info')
      }
      this.setObjectInfo(response.data.info)
    } catch (error) {
      if (error.response?.status === 410) {
        console.log('deleted object data')
        console.log(error.response.data.info)
        this.setObjectInfo(error.response.data.info)
      } else {
        console.log('fetchObjectInfo error')
        console.log(error)
        throw error
      }
    }
  },
  async fetchObjectMembers(parent) {
    this.setObjectMembers([])
    try {
      if (parent.members.length > 0) {
        const members = []
        for (const doc of parent.members) {
          let memresponse
          if (this.user.token) {
            memresponse = await this.$axios.get('/object/' + doc.pid + '/info',
              {
                headers: {
                  'X-XSRF-TOKEN': this.user.token
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
        this.setObjectMembers(members)
      } else {
        this.setObjectMembers([])
      }
    } catch (error) {
    }
  },
  async fetchCollectionMembers(options) {
    this.setCollectionMembers([])
    this.setCollectionMembersTotal(0)
    const id = options.pid.replace(/[o:]/g, '')
    const params = {
      q: '-ismemberof:["" TO *]',
      defType: 'edismax',
      wt: 'json',
      fq: `owner:* AND ispartof:"${options.pid}"`,
      start: (options.page - 1) * options.pagesize,
      rows: options.pagesize,
      sort: `pos_in_o_${id} asc, created asc, pid asc`
    }
    if (options.onlylatestversion) {
      params.q = '-hassuccessor:* AND ' + params.q
    }
    try {
      this.setLoading(true)
      const response = await this.$axios.request({
        method: 'POST',
        url: '/search/select',
        data: qs.stringify(params, { arrayFormat: 'repeat' }),
        headers: {
          'content-type': 'application/x-www-form-urlencoded'
        }
      })
      const solr = response.data?.response
      if (!solr?.docs) {
        this.setCollectionMembers([])
        this.setCollectionMembersTotal(0)
        return
      }
      console.log('setCollectionMembersTotal:' + solr.numFound)
      this.setCollectionMembers(solr.docs)
      this.setCollectionMembersTotal(solr.numFound)
    } catch (error) {
      this.setAlerts([{ type: 'error', msg: error }])
    } finally {
      this.setLoading(false)
    }
  },
  async getLoginData() {
    console.log('getLoginData token: ' + this.user.token)
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
      console.log('getLoginData error')
      console.log(error)
      if (error.response?.status === 401) {
        this.setAlerts([{ type: 'success', msg: 'You have been logged out' }])
        this.clearStore()
      }
    }
  },
  async login(credentials) {
    this.clearStore()
    this.clearAlerts()
    this.setUsername(credentials.username)
    try {
      const response = await this.$axios.get('/signin', {
        headers: {
          Authorization: 'Basic ' + btoa(credentials.username + ':' + credentials.password)
        }
      })
      if (response.data.alerts && response.data.alerts.length > 0) {
        this.setAlerts(response.data.alerts)
      }
      if (response.status === 200) {
        console.log('setting token ' + response.data['XSRF-TOKEN'])
        this.setToken(response.data['XSRF-TOKEN'])
        this.getLoginData()
      }
    } catch (error) {
      console.log('login error')
      console.log(error)
      const alerts = error.response?.data?.alerts
      if (alerts?.length > 0) {
        this.setAlerts(alerts)
      }
    }
  },
  async logout() {
    this.clearAlerts()
    try {
      const response = await this.$axios.get('/signout', {
        headers: {
          'X-XSRF-TOKEN': this.user.token
        }
      })
      if (response.data.alerts && response.data.alerts.length > 0) {
        console.log(response.data.alerts)
      }
    } catch (error) {
      console.log(error)
    } finally {
      this.setAlerts([{ type: 'success', msg: 'You have been logged out' }])
      this.clearStore()
    }
  },
  async getUserGroups() {
    this.clearAlerts()
    try {
      const response = await this.$axios.get('/groups', {
        headers: {
          'X-XSRF-TOKEN': this.user.token
        }
      })
      if (response.data.alerts && response.data.alerts.length > 0) {
        this.setAlerts(response.data.alerts)
      }
      this.setGroups(response.data.groups)
    } catch (error) {
      console.log(error)
    }
  }
  }
})

export default useRootStore
