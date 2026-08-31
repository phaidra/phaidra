import { useRootStore } from '~/stores/root'
import fields from 'phaidra-vue-components/src/utils/fields'
import {
  buildSubmitJobsFromQuery,
  isMetadataOnlySubmitMode,
  parseRoleQueryParams,
  queryScalar
} from '../utils/submitDeepLinkParams'

export const submitDeepLink = {
  computed: {
    submitTemplateId () {
      const q = this.$route.query
      if (q.template) {
        return q.template
      }
      if (this.$route.params?.templateid) {
        return this.$route.params.templateid
      }
      return null
    },
    metadataOnlyMode () {
      return isMetadataOnlySubmitMode(this.$route.query)
    },
    submitJobs () {
      return buildSubmitJobsFromQuery(this.$route.query)
    }
  },
  methods: {
    removeFileFields () {
      for (let s of this.form.sections) {
        if (!s.fields) continue
        for (let i = s.fields.length - 1; i >= 0; i--) {
          if (s.fields[i].component === 'p-file') {
            s.fields.splice(i, 1)
          }
        }
      }
    },
    applyRolePrefill (roleSpecs) {
      if (!roleSpecs.length) {
        return
      }
      const roleFields = []
      for (let s of this.form.sections) {
        if (!s.fields) continue
        for (let f of s.fields) {
          if (f.predicate === 'role') {
            roleFields.push(f)
          }
        }
      }
      for (let i = 0; i < roleSpecs.length && i < roleFields.length; i++) {
        const spec = roleSpecs[i]
        const f = roleFields[i]
        f.role = spec.role
        f.type = f.type || 'schema:Person'
        for (const [field, value] of Object.entries(spec.fields)) {
          f[field] = value
        }
      }
    },
    applyDeepLinkPrefill () {
      const q = this.$route.query
      const title = queryScalar(q, 'title')
      const language = queryScalar(q, 'language')
      const dateCreated = queryScalar(q, 'dateCreated')

      for (let s of this.form.sections) {
        if (!s.fields) continue
        for (let f of s.fields) {
          if (f.component === 'p-title' && title) {
            f.title = title
          }
          if (f.predicate === 'dcterms:language' && language) {
            f.value = language
          }
        }
      }

      this.applyRolePrefill(parseRoleQueryParams(q))

      if (dateCreated) {
        let hasDate = false
        for (let s of this.form.sections) {
          if (!s.fields) continue
          for (let f of s.fields) {
            if (f.component === 'p-date-edtf' && f.type === 'dcterms:created') {
              f.value = dateCreated
              hasDate = true
              break
            }
          }
        }
        if (!hasDate) {
          for (let s of this.form.sections) {
            if (!s.fields) continue
            let created = fields.getField('date-edtf')
            created.value = dateCreated
            created.type = 'dcterms:created'
            s.fields.unshift(created)
            break
          }
        }
      }

      if (this.metadataOnlyMode) {
        this.removeFileFields()
      }
    },
    loadSubmitTemplate: async function (self, templateId, { editableTemplate = false } = {}) {
      try {
        let response = await self.$axios.request({
          method: 'GET',
          url: '/jsonld/template/' + templateId,
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        }
        self.form = response.data.template.form
        if (editableTemplate) {
          for (let s of self.form.sections) {
            for (let f of s.fields) {
              if (f.id && typeof f.id === 'string' && f.id.includes('mime-type_')) {
                f.value = ''
              }
              f.removable = true
              f.configurable = true
            }
          }
          if (self.user?.username && response.data.template.owner && self.user.username !== response.data.template.owner) {
            self.templating = false
          }
        }
        if (response.data.template.rights) {
          self.rights = response.data.template.rights
        }
        if (response.data.template.hasOwnProperty('skipValidation')) {
          self.skipValidation = response.data.template.skipValidation
        }
        if (response.data.template.hasOwnProperty('validationfnc')) {
          self.validationfnc = response.data.template.validationfnc
        }
      } catch (error) {
        console.log(error)
        useRootStore().setAlerts([{ type: 'error', msg: error }])
      }
    }
  }
}
