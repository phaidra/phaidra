<template>
  <v-container v-if="form && (form.length > 0)">
    <v-card :outlined="!title">
      <v-card-title v-if="title" class="font-weight-light grey white--text">{{ $t(title) }}<template v-if="targetpid">&nbsp;-&nbsp;<span class="text-lowercase">{{ targetpid }}</span></template></v-card-title>
      <v-alert dismissible :type="'error'" :value="!valid" transition="fade-transition">
        <span>{{ $t('Metadata validation failed') }}</span>
        <ul v-if="validationErrors.length > 0">
          <li v-for="(e, i) in this.validationErrors" :key="'valEre'+i">{{ e }}</li>
        </ul>
      </v-alert>
      <v-tabs slider-color="primary" slider-size="20px" dark background-color="grey" vertical v-model="activetab">
        <template v-for="(s, i) in this.form">
          <v-tab :active-class="'primary'" v-if="(s.xmlname !== 'annotation') && (s.xmlname !== 'etheses')" :key="'tab'+i">
            <span v-t="s.labels[alpha2locale]"></span>
          </v-tab>
        </template>
        <template v-for="(s, i) in this.form">
          <v-tab-item class="pa-3" v-if="(s.xmlname !== 'annotation') && (s.xmlname !== 'etheses')" :key="'tabitem'+i">
            <template v-if="s.children">
              <p-i-uwm-rec :disabled="disabled" :children="s.children" :parent="s" @add-field="addField($event)" @remove-field="removeField($event)"></p-i-uwm-rec>
            </template>
          </v-tab-item>
        </template>
      </v-tabs>
      <v-divider v-if="targetpid"></v-divider>
      <v-card-actions v-if="targetpid">
        <v-spacer></v-spacer>
        <v-btn @click="save()" :loading="loading" :disabled="loading" color="primary">{{ $t('Save') }}</v-btn>
      </v-card-actions>
    </v-card>
  </v-container>
</template>

<script>
import arrays from '../../utils/arrays'
import PIUwmRec from './PIUwmRec'

export default {
  name: 'p-i-form-uwm',
  components: {
    PIUwmRec
  },
  props: {
    form: {
      type: Array
    },
    targetpid: {
      type: String
    },
    title: {
      type: String
    },
    disabled: {
      type: Boolean
    }
  },
  watch: {
    form: {
      handler: function () {
        this.assignIdsAndParentsRec(this.form, 'root', { id: 'root', children: this.form })
      },
      deep: true
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
      activetab: null,
      loadedMetadata: [],
      loading: false,
      fab: false,
      addfieldselection: [],
      templatedialog: '',
      templatename: '',
      previewMember: '',
      searchfieldsinput: '',
      metadatapreview: {},
      parents: {},
      valid: true,
      validationErrors: []
    }
  },
  methods: {
    assignIdsAndParentsRec: function (arr, path, parent) {
      let i = 0
      for (let e of arr) {
        i++
        e.id = path + e.xmlname + i
        this.parents[e.id] = parent
        if (e.children) {
          this.assignIdsAndParentsRec(e.children, e.id, e)
        }
      }
    },
    addField: function (node) {
      let f;
      if(this.parents[node.id] && this.parents[node.id].children) {
        f = arrays.duplicate(this.parents[node.id].children, node)
        f.removable = true
      }
      this.assignIdsAndParentsRec(this.form, 'root', { id: 'root', children: this.form })
      this.$emit('load-form', this.form)
    },
    removeField: function (node) {
      arrays.remove(this.parents[node.id].children, node)
      this.$emit('load-form', this.form)
    },
    getMetadata: function () {
      let md = { metadata: { 'uwmetadata': this.form } }
      return md
    },
    validate: function () {
      this.valid = true
      this.validationErrors = []

      let title = this.findNodeRec('uwm_general_title', 'uwm', this.form)
      this.$set(title, 'errorMessages', [])
      this.$set(title, 'langErrorMessages', [])
      if (!title.ui_value) {
        title.errorMessages.push(this.$t('Missing title'))
        this.valid = false
        this.validationErrors.push(this.$t('Missing title'))
      }
      if (!title.value_lang) {
        title.langErrorMessages.push(this.$t('Missing title language'))
        this.valid = false
        this.validationErrors.push(this.$t('Missing title language'))
      }

      let lang = this.findNodeRec('uwm_general_language', 'uwm', this.form)
      this.$set(lang, 'errorMessages', [])
      if (!lang.ui_value) {
        lang.errorMessages.push(this.$t('Missing language'))
        this.valid = false
        this.validationErrors.push(this.$t('Missing language'))
      }

      let description = this.findNodeRec('uwm_general_description', 'uwm', this.form)
      this.$set(description, 'errorMessages', [])
      this.$set(description, 'langErrorMessages', [])
      if (!description.ui_value) {
        description.errorMessages.push(this.$t('Missing description'))
        this.valid = false
        this.validationErrors.push(this.$t('Missing description'))
      }
      if (!description.value_lang) {
        description.langErrorMessages.push(this.$t('Missing description language'))
        this.valid = false
        this.validationErrors.push(this.$t('Missing description language'))
      }

      let role = this.findNodeRec('uwm_lifecycle_contribute_role', 'uwm', this.form)
      this.$set(role, 'errorMessages', [])
      if (!role.ui_value) {
        role.errorMessages.push(this.$t('Missing role'))
        this.valid = false
        this.validationErrors.push(this.$t('Missing role'))
      } else {
        let firstname = this.findNodeRec('uwm_lifecycle_contribute_entity_firstname', 'uwm', this.form)
        let lastname = this.findNodeRec('uwm_lifecycle_contribute_entity_lastname', 'uwm', this.form)
        let institution = this.findNodeRec('uwm_lifecycle_contribute_entity_institution', 'uwm', this.form)
        this.$set(firstname, 'errorMessages', [])
        this.$set(lastname, 'errorMessages', [])
        this.$set(institution, 'errorMessages', [])
        if (!firstname.ui_value && !lastname.ui_value && !institution.ui_value) {
          firstname.errorMessages.push(this.$t('Missing firstname'))
          lastname.errorMessages.push(this.$t('Missing lastname'))
          institution.errorMessages.push(this.$t('Missing institution'))
          this.valid = false
          this.validationErrors.push(this.$t('Contribution: Missing firstname or lastname, or institution'))
        }
      }

      let lic = this.findNodeRec('uwm_rights_license', 'uwm', this.form)
      this.$set(lic, 'errorMessages', [])
      if (!lic.ui_value) {
        lic.errorMessages.push(this.$t('Missing license'))
        this.valid = false
        this.validationErrors.push(this.$t('Missing license'))
      }

      if (this.foundUndefinedLanguageRec(this.form)) {
        this.valid = false
        this.validationErrors.push(this.$t('Used text fields must define language'))
      }
      return this.valid
    },
    
    foundUndefinedLanguageRec: function (children) {
      for (let n of children) {
        if ((n.input_type === 'input_text_lang') || (n.input_type === 'input_textarea_lang')) {
          if (n.ui_value && !n.value_lang) {
            return true
          }
        }
        if (n.children) {
          if (n.children.length > 0) {
            return this.foundUndefinedLanguageRec(n.children)
          }
        }
      }
    },
    findNodeRec: function (pathToFind, currPath, children) {
      let ret = null
      for (let n of children) {
        let nodePath = currPath + '_' + n.xmlname
        if (nodePath === pathToFind) {
          ret = n
        } else {
          if (n.children) {
            if (n.children.length > 0) {
              let x = this.findNodeRec(pathToFind, nodePath, n.children)
              if (x) {
                ret = x
              }
            }
          }
        }
      }
      if (ret) {
        return ret
      }
    },
    save: async function () {
      this.validate()
      if (!this.valid) {
        window.scrollTo(0, 0)
        return
      }
      this.loading = true
      var httpFormData = new FormData()
      httpFormData.append('mimetype', this.mimetype)
      httpFormData.append('metadata', JSON.stringify(this.getMetadata()))
      try {
        let response = await this.$http.request({
          method: 'POST',
          url: this.$store.state.instanceconfig.api + '/object/' + this.targetpid + '/metadata',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          if (response.data.status === 401) {
            response.data.alerts.push({ type: 'danger', msg: 'Please log in' })
          }
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.status === 200) {
          this.$emit('object-saved', this.targetpid)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.$vuetify.goTo(0)
        this.loading = false
      }
    }
  },
  mounted: function () {
    this.$store.dispatch('vocabulary/loadLanguages', this.$i18n.locale)
  }
}
</script>

<style scoped>
.v-tab {
  justify-content: start;
}
</style>
