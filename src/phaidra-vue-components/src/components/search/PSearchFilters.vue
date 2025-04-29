<template>
  <v-container fluid>
    <v-row v-if="filtersActive">
      <v-col cols="12">
        <v-btn class="my-1" color="primary" @click.native="resetFilters()">{{ $t('Remove filters') }}</v-btn>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12">
        <ul class="main-ul searchFilters">
          <li v-for="(f, i) in facetQueries" :key="i">
            <v-checkbox
              v-model="f.show"
              @change="showFacet(f)"
              :label="$t(f.label ? f.label.toString() : '')"
              class="facet-label primary--text"
              hide-details
              dense
              :aria-expanded="f.show"
              :aria-controls="'facet-content-' + i"
              :id="'facet-control-' + i"
            ></v-checkbox>
            <ul v-if="f.show" :id="'facet-content-' + i" role="region" :aria-labelledby="'facet-control-' + i">
              <template v-if="f.exclusive">
                  <v-radio-group
                    hide-details
                    v-model="f.selectedRadioValue"
                    class="facet-radio-group mt-0"
                  >
                    <v-radio
                      @change="handleRadioChange(q, f)"
                      v-for="(q, j) in f.queries" :key="i+j"
                      :value="q.id"
                      :label="$t(q.label ? q.label.toString() : '')"
                      class="facet-label primary--text"
                      
                      :aria-expanded="q.active && q.childFacet"
                      :aria-controls="q.childFacet ? 'facet-subcontent-' + i + '-' + j : null"
                      :id="'facet-subcontrol-' + i + '-' + j"
                    >
                      <template v-slot:label>
                        <span class="facet-label primary--text">{{ $t(q.label ? q.label.toString() : '') }}</span>
                        <span class="facet-count secondary--text font-weight-medium" v-if="q.count > 0">({{q.count}})</span>
                      </template>
                    </v-radio>
                  </v-radio-group>
                </template>
              <li v-for="(q, j) in f.queries" :key="i+j" v-else>
                <v-checkbox
                  v-model="q.active"
                  @change="toggleFacet(q,f)"
                  :label="$t(q.label ? q.label.toString() : '')"
                  class="facet-label primary--text"
                  hide-details
                  dense
                  :aria-expanded="q.active && q.childFacet"
                  :aria-controls="q.childFacet ? 'facet-subcontent-' + i + '-' + j : null"
                  :id="'facet-subcontrol-' + i + '-' + j"
                >
                  <template v-slot:label>
                    <span class="facet-label primary--text">{{ $t(q.label ? q.label.toString() : '') }}</span>
                    <span class="facet-count secondary--text font-weight-medium" v-if="q.count > 0">({{q.count}})</span>
                  </template>
                </v-checkbox>
                <ul v-if="q.active && q.childFacet" :id="'facet-subcontent-' + i + '-' + j" role="region" :aria-labelledby="'facet-subcontrol-' + i + '-' + j">
                  <li v-for="(q1, k) in q.childFacet.queries" :key="i+j+k">
                      <v-checkbox
                        v-model="q1.active"
                        @change="toggleFacet(q1,q.childFacet)"
                        :label="$t(q1.label ? q1.label.toString() : '')"
                        class="facet-label primary--text"
                        hide-details
                        dense
                        :aria-expanded="q1.active && q1.childFacet"
                        :aria-controls="q1.childFacet ? 'facet-subsubcontent-' + i + '-' + j + '-' + k : null"
                        :id="'facet-subsubcontrol-' + i + '-' + j + '-' + k"
                      >
                        <template v-slot:label>
                          <span class="facet-label primary--text">{{ $t(q1.label ? q1.label.toString() : '') }}</span>
                          <span class="facet-count secondary--text font-weight-medium" v-if="q1.count > 0">({{q1.count}})</span>
                        </template>
                      </v-checkbox>
                    <ul v-if="q1.active && q1.childFacet" :id="'facet-subsubcontent-' + i + '-' + j + '-' + k" role="region" :aria-labelledby="'facet-subsubcontrol-' + i + '-' + j + '-' + k">
                      <li v-for="(q2, l) in q1.childFacet.queries" :key="i+j+k+l">
                          <v-checkbox
                            v-model="q2.active"
                            @change="toggleFacet(q2,q1.childFacet)"
                            :label="$t(q2.label ? q2.label.toString() : '')"
                            class="facet-label primary--text"
                            hide-details
                            dense
                            :id="'facet-item-' + i + '-' + j + '-' + k + '-' + l"
                          >
                            <template v-slot:label>
                              <span class="facet-label primary--text">{{ $t(q2.label ? q2.label.toString() : '') }}</span>
                              <span class="facet-count secondary--text font-weight-medium" v-if="q2.count>0">({{q2.count}})</span>
                            </template>
                          </v-checkbox>
                      </li>
                    </ul>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
          <li v-if="$store.state.user.token">
            <v-row no-gutters>
              <v-col>
                <v-checkbox
                  v-model="showOwnerFilter"
                  @change="toggleOwnerFilter()"
                  :label="$t('Owner')"
                  class="facet-label primary--text"
                  hide-details
                  dense
                  :aria-expanded="showOwnerFilter"
                  :aria-controls="'owner-content'"
                  id="owner-control"
                ></v-checkbox>
              </v-col>
            </v-row>
            <v-row no-gutters v-if="showOwnerFilter" id="owner-content" role="region" aria-labelledby="owner-control">
            <v-btn v-if="owner" class="mb-8 mt-4" color="primary">{{ owner }}<v-icon right @click.native="removeOwnerFilter()">mdi-close</v-icon></v-btn>
            </v-row>
            
            <v-row no-gutters>
              <v-btn class="mb-4 mt-4 primary" @click="$refs.userSearchdialog.open()" v-if="showOwnerFilter">
                {{ $t('Username search') }}
                <v-icon
                  right
                  dark
                >
                  mdi-database-search
                </v-icon>
              </v-btn>
            </v-row>
          </li>
          <li>
            <v-row no-gutters>
              <v-col>
                <v-checkbox
                  v-model="showAuthorFilter"
                  @change="toggleAuthorFilter()"
                  :label="$t('Authors')"
                  class="facet-label primary--text"
                  hide-details
                  dense
                  :aria-expanded="showAuthorFilter"
                  :aria-controls="'author-content'"
                  id="author-control"
                ></v-checkbox>
              </v-col>
            </v-row>
            <v-row no-gutters v-if="showAuthorFilter" id="author-content" role="region" aria-labelledby="author-control">
              <v-col cols="12">
                <v-combobox
                  class="mt-4"
                  :placeholder="$t('ADD_PREFIX') + ' '  + $t('Author') + ' ' + $t('ADD_SUFFIX') + '...'"
                  :hint="$t('Personal')"
                  persistent-hint
                  chips
                  clearable
                  deletable-chips
                  multiple
                  filled
                  single-line
                  v-model="persAuthors.values"
                  @input="setPersAuthors()"/>
              </v-col>
            </v-row>
            <v-row no-gutters v-if="showAuthorFilter">
              <v-col cols="12">
                <v-combobox
                  class="mt-4"
                  :placeholder="$t('ADD_PREFIX') + ' '  + $t('Author') + ' ' + $t('ADD_SUFFIX') + '...'"
                  :hint="$t('Corporate')"
                  persistent-hint
                  chips
                  clearable
                  deletable-chips
                  multiple
                  filled
                  single-line
                  v-model="corpAuthors.values"
                  @input="setCorpAuthors()"/>
              </v-col>
            </v-row>
          </li>
          <li>
            <v-row no-gutters>
              <v-col>
                <v-checkbox
                  v-model="showRoleFilter"
                  @change="toggleRoleFilter()"
                  :label="$t('Roles')"
                  class="facet-label primary--text"
                  hide-details
                  dense
                  :aria-expanded="showRoleFilter"
                  :aria-controls="'role-content'"
                  id="role-control"
                ></v-checkbox>
              </v-col>
            </v-row>
            <v-row no-gutters v-if="showRoleFilter" id="role-content" role="region" aria-labelledby="role-control">
              <v-select
                class="mt-4"
                :placeholder="$t('Add role') + '...'"
                :hint="$t('Personal')"
                :items="marcRolesArray"
                v-model="selectedRole.pers"
                @input="addRoleFilter('pers')"
                :menu-props="{maxHeight:'400'}"
                persistent-hint
                filled
                single-line
              ></v-select>
              <v-select
                class="mt-4"
                :placeholder="$t('Add role') + '...'"
                :hint="$t('Corporate')"
                :items="marcRolesArray"
                v-model="selectedRole.corp"
                @input="addRoleFilter('corp')"
                :menu-props="{maxHeight:'400'}"
                persistent-hint
                filled
                single-line
              ></v-select>
              <div v-for="(role, i) in roles" :key="i" v-if="roles.length > 0" >
                <v-row no-gutters>
                  <v-col cols="10">
                    <v-combobox
                      :hint="role.type === 'pers' ? $t('Personal') : $t('Corporate')"
                      persistent-hint
                      class="mt-4"
                      :placeholder="$t('ADD_PREFIX') + ' '  + $t(role.label) + ' ' + $t('ADD_SUFFIX') + '...'"
                      chips
                      clearable
                      deletable-chips
                      multiple
                      filled
                      single-line
                      :items="role.values"
                      v-model="role.values"
                      @input="setRoleFilterValues(role)"
                    />
                  </v-col>
                  <v-col cols="2">
                    <icon name="material-navigation-close" class="primary--text" height="100%" @click.native="removeRoleFilter(role)"></icon>
                  </v-col>
                </v-row>
              </div>
            </v-row>
          </li>
        </ul>
      </v-col>
    </v-row>
    <user-search-dialog ref="userSearchdialog" @user-selected="searchUserSelected($event)"></user-search-dialog>
  </v-container>
</template>

<script>
import Vue from 'vue'
import '@/compiled-icons/univie-stop2'
import '@/compiled-icons/univie-checkbox-unchecked'
import '@/compiled-icons/material-action-account-balance'
import '@/compiled-icons/material-social-person'
import '@/compiled-icons/material-navigation-close'
import { marcRoles } from './filters'
import { toggleFacet, showFacet } from './facets'
import UserSearchDialog from '../select/UserSearchDialog'

export default {
  name: 'p-search-filters',
  components: {
    UserSearchDialog
  },
  props: {
    search: {
      type: Function,
      required: true
    },
    facetQueries: {
      type: Array,
      required: true
    },
    persAuthorsProp: {
      type: Object,
      required: true
    },
    corpAuthorsProp: {
      type: Object,
      required: true
    },
    rolesProp: {
      type: Array,
      required: true
    },
    ownerProp: {
      type: String,
      required: true
    }
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    },
    filtersActive () {
      for (let fq of this.facetQueries) {
        if (fq.resetable) {
          for (let q of fq.queries) {
            if (q.active) {
              return true
            }
          }
        }
      }
      return false
    },
    marcRolesArray () {
      this.$store.dispatch('vocabulary/sortRoles', this.$i18n.locale)
      let arr = []
      let roles = this.$store.state.vocabulary.vocabularies.rolepredicate['terms']
      let lang = this.$i18n.locale
      for (let role of roles) {
        arr.push({ value: role['@id'].replace('role:', ''), text: role['skos:prefLabel'][lang] })
      }
      let otherRole = arr.find(elem => elem.value === 'oth')
      let filteredRoles = arr.filter(elem => elem.value !== 'oth')
      arr = filteredRoles
      arr.unshift(otherRole)
      return arr
    }
  },
  data () {
    return {
      showOwnerFilter: false,
      showAuthorFilter: false,
      showRoleFilter: false,
      selectedRole: { pers: '', corp: '' },
      marcRoles,
      roles: [],
      persAuthors: {},
      corpAuthors: {},
      owner: '',
      userSearchLoading: false,
      userSearch: null,
      userSearchModel: null,
      userSearchItems: [],
      usernameSearchLoading: false,
      usernameSearch: null,
      usernameSearchModel: null,
      usernameSearchItems: [],
      init: true
    }
  },
  watch: {
    rolesProp: function (v) {
      this.roles = v
      if (v.length) {
        this.showRoleFilter = true
      }
    },
    ownerProp: async function (v) {
      this.owner = v
      this.showOwnerFilter = v.length
      if (v.length && this.$store.state.user.token) {
        this.usernameSearch = v
      }
    },
    persAuthorsProp: function (v) {
      this.persAuthors = v
      if (v.length) {
        this.showAuthorFilter = true
      }
    },
    corpAuthorsProp: function (v) {
      this.corpAuthors = v
      if (v.length) {
        this.showAuthorFilter = true
      }
    },
    userSearch: async function (val) {
      if ((val && (val.length < 2)) || !val) {
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
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.userSearchItems = response.data.accounts ? response.data.accounts : []
        if (this.init && this.owner) {
          this.userSearchModel = this.userSearchItems[0]
          this.init = false
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.userSearchLoading = false
      }
    },
    usernameSearch: async function (val) {
      if ((val && (val.length < 2)) || !val) {
        this.usernameSearchItems = []
        return
      }
      if (this.usernameSearchLoading) return
      this.usernameSearchLoading = true
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
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.usernameSearchItems = response.data.accounts ? response.data.accounts : []
        console.log('usernameSearchItems', this.usernameSearchItems)
        if (this.usernameSearchItems.length > 0) {
          for (let usr of this.usernameSearchItems) {
            if (usr.uid === this.owner) {
                this.usernameSearchModel = usr
            }
          }
          this.init = false
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.usernameSearchLoading = false
      }
    },
    userSearchModel: function (v) {
      if (v) {
        this.owner = v.uid
      } else {
        this.owner = ''
      }
      this.search({ owner: this.owner })
    },
    usernameSearchModel: function (v) {
      if (v) {
        this.owner = v.uid
      } else {
        this.owner = ''
      }
      this.search({ owner: this.owner })
    }
  },
  methods: {
    searchUserSelected: function (val) {
      this.owner = val.username;
      this.search({ owner: this.owner })
    },
    resetInit: function () {
      this.init = true
    },
    showFacet: function (f) {
      showFacet(f)
      this.search({ facetQueries: this.facetQueries })
    },
    toggleFacet: function (q, f) {
      toggleFacet(q, f)
      this.search({ page: 1, facetQueries: this.facetQueries })
      this.$forceUpdate()
    },
    toggleOwnerFilter: function () {
      if (!this.showOwnerFilter) {
        this.owner = ''
        this.search({ owner: this.owner })
      }
    },
    toggleAuthorFilter: function () {
      if (!this.showAuthorFilter) {
        this.persAuthors.values = []
        this.corpAuthors.values = []
        this.search({ persAuthors: this.persAuthors, corpAuthors: this.corpAuthors })
      }
    },
    toggleRoleFilter: function () {
      if (!this.showRoleFilter) {
        this.roles = []
      }
      this.search({ roles: this.roles })
    },
    addRoleFilter: function (type) {
      if (this.selectedRole[type]) {
        this.roles.push({
          field: 'bib_roles_' + type + '_' + this.selectedRole[type],
          label: this.$t(this.marcRoles[this.selectedRole[type]]),
          values: [],
          type: type
        })
      }
    },
    removeRoleFilter: function (role) {
      this.roles.splice(this.roles.indexOf(role), 1)
      this.search({ roles: this.roles })
    },
    removeOwnerFilter: function (role) {
      this.owner = ''
      this.search({ owner: this.owner })
    },
    setRoleFilterValues: function (role) {
      this.roles[this.roles.indexOf(role)].values = role.values
      this.search({ roles: this.roles })
    },
    removeRoleFilterValue: function (role, value) {
      this.roles[this.roles.indexOf(role)].values.splice(this.roles[this.roles.indexOf(role)].values.indexOf(value), 1)
      this.search({ roles: this.roles })
    },
    setPersAuthors: function () {
      this.search({ persAuthors: this.persAuthors })
    },
    setCorpAuthors: function () {
      this.search({ corpAuthors: this.corpAuthors })
    },
    resetFilters: function () {
      for (const fq of this.facetQueries) {
        if (fq.resetable) {
          for (const q of fq.queries) {
            if(q.active) {
              Vue.set(q, 'active', false)              
            }
          }
          if (fq.exclusive) {
            Vue.set(fq, 'selectedRadioValue', null)
          }
        }
      }
      this.search({ page: 1, facetQueries: this.facetQueries })
    },
    handleRadioChange: function (q, f) {
      // Deactivate all other queries in this facet
      f.queries.forEach(query => {
        query.active = (query.id === q.id);
      });
      this.toggleFacet(q, f);
    }
  },
  mounted () {
    if (this.$router.currentRoute.query.collection) {
      this.resetFilters()
    }
    // for (let role in this.marcRoles) {
    //   this.marcRolesArray.push({ value: role, text: this.$t(this.marcRoles[role]) })
    // }
    this.persAuthors = this.persAuthorsProp
    this.corpAuthors = this.corpAuthorsProp
  }
}
</script>

<style lang="stylus" scoped>
.container
  padding-top: 1em
  padding-left: 0

ul
  list-style: none
  padding-left: 1em

.facet-label
  cursor: pointer

.facet-count
  margin-left: 5px

svg
  margin-bottom: 3px
  cursor: pointer

svg.primary--text
  margin-right: 4px
</style>
