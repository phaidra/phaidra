<template>
  <v-container class="text-break" fluid>
    <v-divider v-if="selectioncheck"></v-divider>
    <v-slide-y-transition hide-on-leave>
      <v-row v-if="selectioncheck" no-gutters class="my-4">
        <span class="mt-2"><a @click="selectPage()">{{ $t('Select this page') }}</a><span class="mx-2">/</span><a @click="unselectPage()">{{ $t('Unselect this page') }}</a><span class="mx-2">/</span><a @click="selectAllResults()">{{ $t('Select all results') }}</a><span class="mx-2">/</span><a @click="selection = []">{{ $t('Clear selection') }}</a></span>
        <v-spacer></v-spacer>
        <v-menu offset-y>
          <template v-slot:activator="{ on: menu, attrs }">
            <v-btn v-on="{ ...menu }" v-bind="attrs" text outlined color="primary" class="mx-4" :disabled="!selection.length">{{ $t('Selected results') }} ({{ selection.length }})</v-btn>
          </template>
          <v-list>
            <v-list-item @click="$refs.addlistdialog.open()">
              <v-list-item-title>{{ $t('Add to object list') }} ...</v-list-item-title>
            </v-list-item>
            <v-list-item @click="$refs.removelistdialog.open()">
              <v-list-item-title>{{ $t('Remove from object list') }} ...</v-list-item-title>
            </v-list-item>
            <v-list-item @click="$refs.addcollectiondialog.open()">
              <v-list-item-title>{{ $t('Add to collection') }} ...</v-list-item-title>
            </v-list-item>
            <v-list-item @click="$refs.removecollectiondialog.open()">
              <v-list-item-title>{{ $t('Remove from collection') }} ...</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </v-row>
    </v-slide-y-transition>
    <v-divider v-if="selectioncheck" class="mb-4"></v-divider>
    <div v-for="(doc, i) in this.docs" :key="'doc'+i">
      <v-row>
        <v-slide-x-transition hide-on-leave>
          <v-col cols="1" v-if="selectioncheck" align-self="center">
            <v-checkbox color="primary" @change="selectDoc($event, doc)" :value="selectionIncludes(doc)"></v-checkbox>
          </v-col>
        </v-slide-x-transition>
        <v-divider inset vertical v-if="selectioncheck"></v-divider>
        <v-col :cols="selectioncheck ? 11 : 12">
          <v-row :key="'prev'+doc.pid">
            <v-col cols="2" >
              <nuxt-link :to="{ path: `detail/${doc.pid}`, params: { pid: doc.pid } }">
                <p-img :src="instance.api + '/object/' + doc.pid + '/thumbnail'" class="preview-maxwidth elevation-1 mt-2" :alt="doc.dc_title ? doc.dc_title[0] : doc.pid">
                  <template v-slot:placeholder>
                    <div class="fill-height ma-0" align="center" justify="center" >
                      <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
                    </div>
                  </template>
                </p-img>
              </nuxt-link>
            </v-col>
            <v-col cols="10">
              <v-row >
                <v-col cols="12" md="9">
                  <h2 class="title font-weight-light primary--text" @click.stop v-if="doc.dc_title">
                    <nuxt-link :to="{ path: `detail/${doc.pid}`, params: { pid: doc.pid } }">{{ doc.dc_title[0] }}</nuxt-link>
                  </h2>
                </v-col>
                <v-col cols="12" md="3" class="text-right">
                  <v-chip class="pointer-disabled" v-if="doc.created" color="transparent">{{ doc.created | date }}
                    <v-icon v-if="doc.cmodel == 'Video'" class="mx-2" color="grey">mdi-video</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'Picture'" class="mx-2" color="grey">mdi-image</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'Audio'" class="mx-2" color="grey">mdi-volume-high</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'PDFDocument'" class="mx-2" color="grey">mdi-file-document</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'Asset'" class="mx-2" color="grey">mdi-file</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'Resource'" class="mx-2" color="grey">mdi-link</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'Collection'" class="mx-2" color="grey">mdi-folder-open</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'Container'" class="mx-2" color="grey">mdi-folder</v-icon>
                    <v-icon v-else-if="doc.cmodel == 'Book'" class="mx-2" color="grey">mdi-book-open-variant</v-icon>
                  </v-chip>
                </v-col>
              </v-row>
              <v-row class="my-4 mr-2">
                <v-col>
                  <span>
                    <span v-for="(roleDoc,i) in getRoleList(doc)" :key="'pers'+i">
                      {{roleDoc}}<span v-if="(i+1) < getRoleList(doc).length">; </span>
                    </span>
                    <!-- <span v-for="(aut,i) in doc.bib_roles_corp_aut" :key="'corp'+i">
                      {{aut}}<span v-if="(i+1) < doc.bib_roles_corp_aut.length">; </span>
                    </span> -->
                  </span>
                </v-col>
              </v-row>
              <v-row class="my-4 mr-2" v-if="doc.dc_description">
                <v-col>
                  <p-expand-text :text="doc.dc_description[0]" :moreStr="$t('read more')" :lang="getDescriptionLanguage(doc)" />
                </v-col>
              </v-row>
              <v-row v-if="doc.isrestricted">
                <v-col>
                  <v-chip class="pointer-disabled" label dark color="btnred"><v-icon small left>mdi-lock</v-icon>{{ $t('Restricted access') }}</v-chip>
                </v-col>
              </v-row>
              <v-row >
                <v-col cols="12" md="9">
                  <a class="font-weight-light" :href="`${instance.baseurl}/${doc.pid}`">{{ instance.baseurl }}/{{ doc.pid }}</a>
                </v-col>
                <v-col cols="12" md="3" class="text-right pr-5">
                  <p-d-license v-if="doc.dc_rights" :hideLabel="true" :o="doc.dc_rights[0]"></p-d-license>
                </v-col>
              </v-row>
              
            </v-col>
          </v-row>
          
        </v-col>
      </v-row>
      <v-divider :key="'div'+doc.pid" class="mt-6 mb-4 mr-2"></v-divider>
    </div>

    <list-dialog ref="addlistdialog" @list-selected="addToList($event)"></list-dialog>
    <list-dialog ref="removelistdialog" @list-selected="removeFromList($event)"></list-dialog>
    <collection-dialog ref="addcollectiondialog" @collection-selected="addToCollection($event)"></collection-dialog>
    <collection-dialog ref="removecollectiondialog" @collection-selected="removeFromCollection($event)"></collection-dialog>

  </v-container>
</template>

<script>
import PDLicense from '../display/PDLicense'
import PImg from '../utils/PImg'
import PExpandText from '../utils/PExpandText'
import ListDialog from '../select/ListDialog'
import CollectionDialog from '../select/CollectionDialog'

export default {
  name: 'p-search-results',
  components: {
    PDLicense,
    PImg,
    PExpandText,
    CollectionDialog,
    ListDialog
  },
  props: {
    getallresults: {
      type: Function,
      required: true
    },
    docs: {
      type: Array
    },
    selectioncheck: Boolean,
    total: Number
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      selection: []
    }
  },
  methods: {
    getRoleList: function (doc) {
      let roles = []
      if (doc.bib_roles_pers_aut) {
        roles = roles.concat(doc.bib_roles_pers_aut)
      }
      if (doc.bib_roles_pers_edt) {
        roles = roles.concat(doc.bib_roles_pers_edt)
      }
      if (doc.bib_roles_pers_cmp) {
        roles = roles.concat(doc.bib_roles_pers_cmp)
      }
      if (doc.bib_roles_pers_art) {
        roles = roles.concat(doc.bib_roles_pers_art)
      }
      return roles
    },
    getDescriptionLanguage: function (item) {
      let description = item.dc_description[0];
      let lang = 'en';
      for (const key in item) {
          if (key.startsWith('dc_description_')) {
              const element = item[key];
              if(element && element[0] && element[0] === description && key.substr(15,2) !== 'en'){
                lang = key.substr(15,2);
                break;
              }
          }
      }
      return lang;
    },
    selectionIncludes: function (doc) {
      for (let s of this.selection) {
        if (s.pid === doc.pid) {
          return true
        }
      }
      return false
    },
    addToCollection: async function (collection) {
      try {
        this.$store.commit('setLoading', true)
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { members: this.selection } }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/collection/' + collection.pid + '/members/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.status === 200) {
          this.$store.commit('setAlerts', [ { msg: this.$t('Collection successfully updated'), type: 'success' } ])
          this.$router.push({ path: `detail/${collection.pid}`, params: { pid: collection.pid } })
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    removeFromCollection: async function (collection) {
      try {
        this.$store.commit('setLoading', true)
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { members: this.selection } }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/collection/' + collection.pid + '/members/remove',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.status === 200) {
          this.$store.commit('setAlerts', [ { msg: this.$t('Collection successfully updated'), type: 'success' } ])
          this.$router.push({ path: `detail/${collection.pid}`, params: { pid: collection.pid } })
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    addToList: async function (list) {
      try {
        this.$store.commit('setLoading', true)
        var httpFormData = new FormData()
        httpFormData.append('members', JSON.stringify({ members: this.selection }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/list/' + list.listid + '/members/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.status === 200) {
          this.$store.commit('setAlerts', [ { msg: this.$t('Object list successfully updated'), type: 'success' } ])
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    removeFromList: async function (list) {
      try {
        this.$store.commit('setLoading', true)
        var httpFormData = new FormData()
        httpFormData.append('members', JSON.stringify({ members: this.selection }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/list/' + list.listid + '/members/remove',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.status === 200) {
          this.$store.commit('setAlerts', [ { msg: this.$t('Object list successfully updated'), type: 'success' } ])
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    selectDoc: function (value, doc) {
      if (value) {
        let found = false
        for (let s of this.selection) {
          if (s.pid === doc.pid) {
            found = true
          }
        }
        if (!found) {
          let t = ''
          if (doc.dc_title) {
            t = doc.dc_title[0]
          }
          this.selection.push({
            pid: doc.pid,
            title: t
          })
        }
      } else {
        let i = 0
        for (let s of this.selection) {
          if (s.pid === doc.pid) {
            this.selection.splice(i, 1)
            break
          }
          i++
        }
      }
    },
    selectPage: function () {
      for (let d of this.docs) {
        let found = false
        for (let s of this.selection) {
          if (s.pid === d.pid) {
            found = true
          }
        }
        if (!found) {
          let t = ''
          if (d.dc_title) {
            t = d.dc_title[0]
          }
          this.selection.push({
            pid: d.pid,
            title: t
          })
        }
      }
    },
    unselectPage: function () {
      for (let d of this.docs) {
        let i = 0
        for (let s of this.selection) {
          if (s.pid === d.pid) {
            this.selection.splice(i, 1)
            break
          }
          i++
        }
      }
    },
    selectAllResults: async function () {
      let docs = await this.getallresults()
      if (docs) {
        if (docs.length > 0) {
          for (let d of docs) {
            let add = true
            for (let ind of this.selection) {
              if (d.pid === ind.pid) {
                add = false
                break
              }
            }
            if (add) {
              let nd = { pid: d.pid, title: '' }
              if (d.dc_title) {
                nd.title = d.dc_title[0]
              }
              this.selection.push(nd)
            }
          }
        }
      }
    }
  }
}
</script>

<style scoped>
.preview-maxwidth {
  max-width: 120px;
}

.card__title--primary {
  padding-top: 10px;
}

.card__text {
  padding-top: 0px;
}

.container {
  padding: 0;
}


</style>
