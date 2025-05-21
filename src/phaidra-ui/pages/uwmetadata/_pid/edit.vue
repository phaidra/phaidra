<template>
  <client-only>
    <div>
      <v-btn color="primary" class="my-4" :to="{ path: `/detail/${pid}`, params: { pid: pid } }">
        <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
      </v-btn>
      <p-i-form-uwm
        title="Metadata"
        :form="editform"
        :targetpid="this.pid"
        v-on:object-saved="objectSaved($event)"
        v-on:load-form="editform = $event"
      ></p-i-form-uwm>
    </div>
  </client-only>
</template>

<script>
import { context } from '../../../mixins/context'
import { config } from '../../../mixins/config'

export default {
  mixins: [ context, config ],
  watch: {
    '$i18n.locale': function (newVal) {
      this.sortUwmetadata(this.uwmetadata, '', newVal)
    }
  },
  data () {
    return {
      loading: false,
      editform: [],
      parentpid: '',
      uwmetadata: [],
      sortXmlNamePaths: [
        'lifecycle->contribute->role->',
        'histkult->dimensions->resource->',
        'provenience->contribute->resource->',
        'provenience->contribute->role->'
      ]
    }
  },
  computed: {
    pid: function () {
      return this.$route.params.pid
    }
  },
  methods: {
    objectSaved: function (event) {
      this.$store.commit('setAlerts', [{ type: 'success', key: 'object_metadata_saved_success', params: { o: event }}])
      this.$router.push(this.localeLocation({ path: `/detail/${event}`}))
      this.$vuetify.goTo(0)
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
    postLoadUwmetadata: function (self, uwmetadata) {
      let lic = this.findNodeRec('uwm_rights_license', 'uwm', uwmetadata)
      if (lic.ui_value && (lic.ui_value !== 'http://phaidra.univie.ac.at/XML/metadata/lom/V1.0/voc_21/1')) {
        lic.disabled = true
      }
      this.sortUwmetadata(uwmetadata, '', this.$i18n.locale)
      this.uwmetadata = uwmetadata
      self.editform = uwmetadata
    },
    sortUwmetadata: function (uwmetadata, path, locale) {
      uwmetadata.forEach(element => {
        let xmlnamePath = path;
        xmlnamePath += element.xmlname + '->';
        if(this.sortXmlNamePaths.includes(xmlnamePath)) {
          if(element.vocabularies.length > 0) {
            element.vocabularies[0].terms.sort((a, b) => {
              if(locale === 'ita' && a.labels.it && b.labels.it) {
                return a.labels.it.localeCompare(b.labels.it)
              } else if(locale === 'deu' && a.labels.de && b.labels.de) {
                return a.labels.de.localeCompare(b.labels.de)
              } else {
                return a.labels.en.localeCompare(b.labels.en)
              }
            })
          }
        }
        if(element.children) {
          this.sortUwmetadata(element.children, xmlnamePath, locale)
        }
      });
    },
    loadUwmetadata: async function (self, pid) {
      self.loading = true
      try {
        let response = await self.$axios.request({
          method: 'GET',
          url: '/object/' + pid + '/metadata',
          params: {
            mode: 'full'
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          self.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.metadata['uwmetadata']) {
          this.postLoadUwmetadata(self, response.data.metadata['uwmetadata'])
        }
      } catch (error) {
        console.log(error)
      } finally {
        self.loading = false
      }
    }
  },
  beforeRouteEnter: function (to, from, next) {
    next(vm => {
      vm.parentpid = from.params.pid
      vm.$store.commit('setLoading', true)
      vm.loadUwmetadata(vm, to.params.pid).then(() => {
        vm.$store.commit('setLoading', false)
        next()
      })
    })
  },
  beforeRouteUpdate: function (to, from, next) {
    this.parentpid = from.params.pid
    this.$store.commit('setLoading', true)
    this.loadUwmetadata(this, to.params.pid).then(() => {
      this.$store.commit('setLoading', false)
      next()
    })
  }
}
</script>
