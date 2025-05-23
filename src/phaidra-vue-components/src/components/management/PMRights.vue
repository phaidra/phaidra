<template>
  <v-card :flat="!title">
    <v-card-title v-if="title" class="title font-weight-light white--text">{{ title }}</v-card-title>
    <v-divider v-if="title"></v-divider>
    <v-card-text>
        <v-row>
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ (rightsArray.length > 0) ? $t('The following entities have access to the object') : $t('This object is worldwide accessible') }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="pt-4">
                <v-data-table
                  hide-default-footer
                  :items="rightsArray"
                  :headers="rightsHeaders"
                  :loading="loading"
                  :loading-text="$t('Loading...')"
                  :items-per-page="1000"
                  :no-data-text="$t('No access restrictions are defined')"
                  :footer-props="{
                    pageText: $t('Page'),
                    itemsPerPageText: $t('Rows per page'),
                    itemsPerPageAllText: $t('All')
                  }"
                  :no-results-text="$t('There were no search results')"
                >
                  <template v-slot:item.description="{ item }">
                    <span :title="item.notation">{{item.notation}} {{ item.description }}</span>
                  </template>
                  <template v-slot:item.expires="{ item }">
                    {{ item.expires | date }}
                  </template>
                  <template v-slot:item.actions="{ item }">
                    <v-btn text color="primary" @click="openDateDialog(item)">{{ $t('Edit expiration date') }}</v-btn>
                    <v-btn v-if="item.expires" text color="btnred" @click="removeExpires(item)">{{ $t('Remove expiration date') }}</v-btn>
                    <v-btn text color="btnred" @click="removeRight(item)">{{ $t('Remove right') }}</v-btn>
                  </template>
                </v-data-table>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ $t('Restrict access rights to the owner of the object') }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-container fluid>
                  <v-row>
                    <v-col cols="12" v-if="doc" >
                      <v-btn class="primary" :disabled="loading || userSearchLoading" @click="addOwner()">
                        <div v-if="doc.owner == $store.state.user.username">{{ $t('Restrict access to me') }}</div>
                        <div v-else-if="doc.owner">{{ $t('Restrict access to owner') }} ({{ doc.owner }})</div>
                        <div v-else>{{ $t('Restrict access to me') }}</div>
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-if="showPersons">
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ $t('Restrict access rights to particular persons') }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-container fluid>
                  <v-row>
                    <v-col cols="8">
                      <v-autocomplete
                        v-model="userSearchModel"
                        :items="userSearchItems.length > 0 ? userSearchItems : []"
                        :loading="userSearchLoading"
                        :search-input.sync="userSearch"
                        :label="$t('User search')"
                        :placeholder="$t('Start typing to search')"
                        item-value="uid"
                        item-text="value"
                        prepend-icon="mdi-database-search"
                        hide-no-data
                        hide-selected
                        return-object
                        clearable
                        @click:clear="userSearchItems=[]"
                      >
                        <template slot="item" slot-scope="{ item }">
                          <template v-if="item">
                            <v-list-item-content two-line>
                              <v-list-item-title>{{ item.value }}</v-list-item-title>
                              <v-list-item-subtitle>{{ item.uid }}</v-list-item-subtitle>
                            </v-list-item-content>
                          </template>
                        </template>
                      </v-autocomplete>
                    </v-col>
                    <v-col cols="1" class="pt-6">
                      <v-btn class="primary" :disabled="loading || userSearchLoading" @click="addUser()">{{ $t('Apply') }}</v-btn>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-if="showAccounts">
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ $t('Restrict access rights to particular account') }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-container fluid>
                  <v-row>
                    <v-col>
                      <v-btn class="mb-4 mt-4 primary" @click="$refs.userSearchdialog.open()">
                        {{ $t('Username search') }}
                        <v-icon
                          right
                          dark
                        >
                          mdi-database-search
                        </v-icon>
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-if="showEduPersonAffiliation">
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ $t('Restrict access rights to particular eduPersonAffiliation values') }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-container fluid>
                  <v-row>
                    <v-col cols="8">
                      <v-select
                        v-model="selectedEduPersonAffiliation"
                        :items="instance.data_affiliations"
                        :label="$t('eduPersonAffiliation')"
                        filled
                      ></v-select>
                    </v-col>
                    <v-col cols="1" class="pt-6">
                      <v-btn class="primary" :disabled="loading" @click="addEduPersonAffiliation()">{{ $t('Apply') }}</v-btn>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-if="showOrgUnits">
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ $t('Restrict access rights to organisational units/subunits') }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-container fluid>
                  <v-row>
                    <v-col cols="8">
                      <v-autocomplete
                        v-model="orgunit"
                        v-on:input="handleInput($event)"
                        :items="vocabularies['orgunits'].terms"
                        :item-value="'@id'"
                        :filter="autocompleteFilter"
                        :label="$t('Select organizational unit')"
                        :messages="path"
                        filled
                        hide-no-data
                        return-object
                        clearable
                      >
                        <template slot="item" slot-scope="{ item }">
                          <v-list-item-content two-line>
                            <v-list-item-title v-html="`${getLocalizedTermLabel('orgunits', item['@id'])}`"></v-list-item-title>
                            <v-list-item-subtitle v-html="`${item['@id']}`"></v-list-item-subtitle>
                          </v-list-item-content>
                        </template>
                        <template slot="selection" slot-scope="{ item }">
                          <v-list-item-content>
                            <v-list-item-title v-html="`${getLocalizedTermLabel('orgunits', item['@id'])}`"></v-list-item-title>
                          </v-list-item-content>
                        </template>
                        <template v-slot:append-outer>
                          <v-icon @click="$refs.orgunitstreedialog.open()">mdi-file-tree</v-icon>
                        </template>
                      </v-autocomplete>
                    </v-col>
                    <org-units-tree-dialog ref="orgunitstreedialog" @unit-selected="handleInput(getTerm('orgunits', $event))"></org-units-tree-dialog>
                    <v-col cols="1" class="pt-6">
                      <v-btn class="primary" :disabled="loading" @click="addOrgUnit()">{{ $t('Apply') }}</v-btn>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-if="showGroups">
          <v-col cols="12">
            <v-card>
              <v-card-title class="title font-weight-light white--text">{{ $t('Restrict access rights to particular groups') }}</v-card-title>
              <v-divider></v-divider>
              <v-card-text class="mt-4">
                <v-data-table
                  :items="groups"
                  :headers="groupsHeaders"
                  :loading="groupsLoading"
                  :loading-text="$t('Loading...')"
                  :items-per-page="5"
                  :no-data-text="$t('No data available')"
                  :footer-props="{
                    pageText: $t('Page'),
                    itemsPerPageText: $t('Rows per page'),
                    itemsPerPageAllText: $t('All')
                  }"
                  :no-results-text="$t('There were no search results')"
                >
                  <template v-slot:item.description="{ item }">
                    <span :title="item.groupid">{{ item.name }}</span>
                  </template>
                  <template v-slot:item.actions="{ item }">
                    <v-btn text :disabled="loading" color="primary" @click="addGroup(item)">{{ $t('Apply') }}</v-btn>
                  </template>
                </v-data-table>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        <v-dialog
          ref="dialog"
          v-model="dateDialog"
          persistent
          width="290px"
        >
          <v-date-picker
            color="primary"
            v-model="dateModel"
            :first-day-of-week="1"
            :locale="alpha2bcp47($i18n.locale)"              
            scrollable
          >
            <v-spacer></v-spacer>
            <v-btn outlined @click="dateDialog = false">{{ $t('Cancel') }}</v-btn>
            <v-btn color="primary" @click="setExpires()">OK</v-btn>
          </v-date-picker>
        </v-dialog>
        <user-search-dialog ref="userSearchdialog" @user-selected="searchUserSelected($event)"></user-search-dialog>
    </v-card-text>
  </v-card>
</template>

<script>
import qs from 'qs'
import arrays from '../../utils/arrays'
import datepickerproperties from '../../mixins/datepickerproperties'
import { vocabulary } from '../../mixins/vocabulary'
import OrgUnitsTreeDialog from '../select/OrgUnitsTreeDialog'
import UserSearchDialog from '../select/UserSearchDialog'

export default {
  name: 'p-m-rights',
  mixins: [vocabulary, datepickerproperties],
  components: {
    OrgUnitsTreeDialog,
    UserSearchDialog
  },
  props: {
    pid: {
      type: String
    },
    rights: {
      type: Object,
      required: true
    },
    title: {
      type: String
    },
    showOrgUnits: {
      type: Boolean,
      default: false
    },
    showGroups: {
      type: Boolean,
      default: false
    },
    showAccounts: {
      type: Boolean,
      default: false
    },
    showPersons: {
      type: Boolean,
      default: false
    },
    showEduPersonAffiliation: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      doc: {},
      loading: false,
      userSearchLoading: false,
      userSearchExactLoading: false,
      groupsLoading: false,
      groupsHeaders: [
        { text: this.$t('Name'), align: 'left', value: 'description', sortable: false },
        { text: '', align: 'right', value: 'actions', sortable: false }
      ],
      groups: [],
      rightsjson: {},
      path: '',
      rightsArray: [],
      rightsHeaders: [],
      dateModel: new Date().toISOString().substr(0, 10),
      dateDialog: false,
      dateDialogItem: null,
      orgunit: null,
      selectedEduPersonAffiliation: null,
      userSearch: null,
      userSearchModel: null,
      userSearchItems: [],
      userSearchExact: null,
      userSearchExactModel: null,
      userSearchExactItems: []
    }
  },
  watch: {
    '$i18n.locale': {
      immediate: true, // Ensure it's set on load
      handler() {
        this.rightsHeaders = [
          { text: this.$t('Rule'), align: 'left', value: 'description', sortable: false },
          { text: this.$t('Expires'), align: 'left', value: 'expires', sortable: false },
          { text: '', align: 'right', value: 'actions', sortable: false }
        ];
      }
    },
    rights: {
      handler: async function (val) {
        this.rightsjson = val
        this.rightsJsonToRightsArray()
      },
      deep: true
    },
    userSearch: async function (val) {
      if (val && (val.length < 2)) {
        this.userSearchItems = []
        return
      }
      if (this.userSearchLoading) return
      this.userSearchLoading = true
      try {
        let response = await this.$axios.get('/directory/user/search', {
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          params: {
            q: val
          }
        })
        if (response.data) {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
          this.userSearchItems = response.data.accounts ? response.data.accounts : []
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.userSearchLoading = false
      }
    },
    userSearchExact: async function (val) {
      if (val && (val.length < 2)) {
        this.userSearchExactItems = []
        return
      }
      if (this.userSearchExactLoading) return
      this.userSearchExactLoading = true
      try {
        let response = await this.$axios.get('/directory/user/search', {
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          params: {
            q: val,
            exact: 1
          }
        })
        if (response.data) {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
          this.userSearchExactItems = response.data.accounts ? response.data.accounts : []
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.userSearchExactLoading = false
      }
    }
  },
  methods: {
    handleInput: function (unit) {
      this.orgunit = unit
      this.path = ''
      let pathArr = []
      if (unit && !unit.hasOwnProperty('@id')) {
        unit = this.getTerm('orgunits', unit)
      }
      this.getOrgPath(unit, this.vocabularies['orgunits'].tree, pathArr)
      let pathLabels = []
      for (let u of pathArr) {
        pathLabels.push(u['skos:prefLabel'][this.$i18n.locale])
      }
      this.path = pathLabels.join(' > ')
    },
    openDateDialog: function (item) {
      this.dateDialogItem = item
      this.dateDialog = true
    },
    removeExpires: async function (item) {
      item.expires = null
      this.saveRights()
    },
    setExpires: async function () {
      this.dateDialogItem.expires = this.dateModel
      this.dateDialog = false
      this.saveRights()
    },
    removeRight: async function (item) {
      arrays.remove(this.rightsArray, item)
      this.saveRights()
    },
    addOwner: async function () {
      if (this.doc['owner']) {
        this.rightsArray.push({ type: 'username', notation: this.doc.owner, description: this.doc.owner + ' (owner of ' + this.pid + ')', expires : null })
        this.saveRights()
      } else {
        this.rightsArray.push({ type: 'username', notation: this.$store.state.user.username, description: this.$store.state.user.username + ' (uploader)', expires: null })
        this.saveRights()
      }
    },
    addEduPersonAffiliation: async function () {
      if (this.selectedEduPersonAffiliation) {
        this.rightsArray.push({ type: 'affiliation', notation: this.selectedEduPersonAffiliation, description: this.selectedEduPersonAffiliation, expires: null })
        this.saveRights()
      }
    },
    addUser: function () {
      if (this.userSearchModel) {
        this.rightsArray.push({ type: 'username', notation: this.userSearchModel.uid, description: this.userSearchModel.value, expires: null })
        this.saveRights()
      }
    },
    searchUserSelected: function(selectedUser) {
      if(selectedUser) {
        this.rightsArray.push({ type: 'username', notation: selectedUser.username, expires: null })
        this.saveRights()
      }
    },
    addUserExact: function () {
      if (this.userSearchExactModel) {
        this.rightsArray.push({ type: 'username', notation: this.userSearchExactModel.uid, description: this.userSearchExactModel.value, expires: null })
        this.saveRights()
      }
    },
    addGroup: function (group) {
      this.rightsArray.push({ type: 'gruppe', notation: group.groupid, description: group.name, expires: null })
      this.saveRights()
    },
    addOrgUnit: function () {
      let type = ''
      if (this.orgunit) {
        // let's say if parent is faculty, this is a 'department' type rule
        if (this.orgunit.parent) {
          if (this.orgunit.parent['@type'] === 'aiiso:Faculty') {
            type = 'department'
          } else {
            type = 'faculty'
          }
          if (this.orgunit.parent['@id'] === 'https://pid.phaidra.org/univie-org/V2XH-NPJ9') {
            type = 'department'
          }
        } else {
          type = 'faculty'
        }
        let notation = this.orgunit['skos:notation']
        let description = this.getLocalizedTermLabel('orgunits', this.orgunit['@id'])
        if (!description) {
          description = notation
        }
        this.rightsArray.push({ type: type, notation: notation, description: description, expires: null })
        this.saveRights()
      }
    },
    getNameFromUsername: async function (username) {
      this.loading = true
      try {
        let response = await this.$axios.get('/directory/user/' + username + '/name', {
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        return response.data.name
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    getGroupName: async function (groupid) {
      this.loading = true
      try {
        let response = await this.$axios.get('/group/' + groupid, {
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        return response.data.group.name
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    saveRights: async function () {
      let rights = {}
      for (let r of this.rightsArray) {
        if (!rights[r.type]) {
          rights[r.type] = []
        }
        if (r.expires) {
          rights[r.type].push({ value: r.notation, expires: new Date(r.expires).toISOString() })
        } else {
          rights[r.type].push(r.notation)
        }
      }
      if (this.pid) {
        this.loading = true
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { rights: rights } }))
        this.rightsArray = []
        this.rightsjson = {}
        try {
          let response = await this.$axios.request({
            method: 'POST',
            url: '/object/' + this.pid + '/rights',
            data: httpFormData,
            headers: {
              'X-XSRF-TOKEN': this.$store.state.user.token,
              'Content-Type': 'multipart/form-data'
            }
          })
          if (response.status === 200) {
            this.$store.commit('setAlerts', [{ type: 'success', key: 'object_rights_saved_success', params: { o: this.pid }}])
          } else {
            if (response.data.alerts && response.data.alerts.length > 0) {
              this.$store.commit('setAlerts', response.data.alerts)
            }
          }
        } catch (error) {
          console.log(error)
          this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
        } finally {
          this.$emit('load-rights')
          this.loading = false
        }
      } else {
        this.$emit('input-rights', rights)
      }
    },
    rightsJsonToRightsArray: async function () {
      this.rightsArray = []
      // 'username' => 1, 'department' => 1, 'faculty' => 1, 'gruppe' => 1, 'spl' => 1, 'kennzahl' => 1, 'perfunk' => 1

      if (this.rightsjson['username']) {
        for (let r of this.rightsjson['username']) {
          let notation = ''
          let name = ''
          let expires = ''
          if (r['value']) {
            notation = r['value']
            expires = r['expires']
          } else {
            notation = r
          }
          name = await this.getNameFromUsername(notation)
          this.rightsArray.push({ type: 'username', notation: notation, description: name, expires: expires })
        }
      }
      if (this.rightsjson['affiliation']) {
        for (let r of this.rightsjson['affiliation']) {
          let notation = ''
          let name = ''
          let expires = ''
          if (r['value']) {
            notation = r['value']
            expires = r['expires']
            name = r['value'] + ' affiliation'
          } else {
            notation = r
            name = r + ' affiliation'
          }
          this.rightsArray.push({ type: 'affiliation', notation: notation, description: name, expires: expires })
        }
      }
      if (this.rightsjson['department']) {
        for (let r of this.rightsjson['department']) {
          let notation = ''
          let name = ''
          let expires = ''
          if (r['value']) {
            notation = r['value']
            expires = r['expires']
          } else {
            notation = r
          }
          if (notation === 'A-1') {
            name = this.$t('Whole University')
          } else {
            name = this.$store.getters['vocabulary/getLocalizedTermLabelByNotation']('orgunits', notation, this.$i18n.locale)
            if (!name) {
              name = notation
            }
          }
          this.rightsArray.push({ type: 'department', notation: notation, description: name, expires: expires })
        }
      }
      if (this.rightsjson['faculty']) {
        for (let r of this.rightsjson['faculty']) {
          let notation = ''
          let name = ''
          let expires = ''
          if (r['value']) {
            notation = r['value']
            expires = r['expires']
          } else {
            notation = r
          }
          if (notation === 'A-1') {
            name = this.$t('Whole University')
          } else {
            name = this.$store.getters['vocabulary/getLocalizedTermLabelByNotation']('orgunits', notation, this.$i18n.locale)
            if (!name) {
              name = notation
            }
          }
          this.rightsArray.push({ type: 'faculty', notation: notation, description: name, expires: expires })
        }
      }
      if (this.rightsjson['gruppe']) {
        for (let r of this.rightsjson['gruppe']) {
          let notation = ''
          let name = ''
          let expires = ''
          if (r['value']) {
            notation = r['value']
            expires = r['expires']
          } else {
            notation = r
          }
          name = await this.getGroupName(notation)
          this.rightsArray.push({ type: 'gruppe', notation: notation, description: name, expires: expires })
        }
      }
    },
    loadGroups: async function () {
      this.groupsLoading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/groups',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.status === 200) {
          this.groups = response.data.groups
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.groupsLoading = false
      }
    },
    loadDoc: async function () {
      var params = {
        q: '*:*',
        fq: 'pid:"' + this.pid + '"',
        defType: 'edismax',
        wt: 'json'
      }

      var query = qs.stringify(params, { encodeValuesOnly: true, indices: false })
      var url = '/search/select?' + query
      
      try {
        this.$store.commit('setLoading', true)
        let response = await this.$axios.request({
          method: "GET",
          url: url,
        });
        
        if (response.data.response.numFound > 0) {
          this.doc = response.data.response.docs[0]
        }
      } catch (error) {
        console.log(error);
        this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
      } finally {
        this.$store.commit('setLoading', false)
      }
    }
  },
  mounted: async function () {
    await this.loadDoc()
    this.$nextTick(async function () {
      if (!this.vocabularies['orgunits'].loaded) {
        this.$store.dispatch('vocabulary/loadOrgUnits', this.$i18n.locale)
      }
      this.loadGroups()
      this.rightsjson = this.rights
      this.rightsJsonToRightsArray()
    })
  }
}
</script>
