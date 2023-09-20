<template>
  <v-container fluid>
    <v-row v-if="filtersActive">
      <v-col cols="12">
        <v-btn class="my-1" dark color="grey" @click.native="resetFilters()">{{ $t('Remove filters') }}</v-btn>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12">
        <ul class="main-ul">
          <li v-for="(f, i) in facetQueries" :key="i">
            <icon @click.native="showFacet(f)" v-if="f.show" name="univie-stop2" class="primary--text"></icon>
            <icon @click.native="showFacet(f)" v-if="!f.show" name="univie-checkbox-unchecked" class="primary--text"></icon>
            <span @click="showFacet(f)" class="facet-label primary--text" :class="{ active: f.show }">{{ $t(f.label) }}</span>
            <ul v-if="f.show">
              <li v-for="(q, j) in f.queries" :key="j">
                <span @click="toggleFacet(q,f)">
                  <icon v-if="q.active" name="univie-stop2" class="primary--text"></icon>
                  <icon v-if="!q.active" name="univie-checkbox-unchecked" class="primary--text"></icon>
                  <span :class="{ active: q.active }" class="facet-label primary--text">{{ $t(q.label) }}</span>
                  <span class="facet-count grey--text" v-if="q.count > 0">({{q.count}})</span>
                </span>
                <ul v-if="q.active && q.childFacet" >
                  <li v-for="(q1, k) in q.childFacet.queries" :key="k">
                    <span @click="toggleFacet(q1,q.childFacet)">
                      <icon v-if="q1.active" name="univie-stop2" class="primary--text"></icon>
                      <icon v-if="!q1.active" name="univie-checkbox-unchecked" class="primary--text"></icon>
                      <span :class="{ active: q1.active }" class="facet-label primary--text">{{ $t(q1.label) }}</span>
                      <span class="facet-count grey--text" v-if="q1.count > 0">({{q1.count}})</span>
                    </span>
                    <ul v-if="q1.active && q1.childFacet" >
                      <li v-for="(q2, l) in q1.childFacet.queries" :key="l">
                        <span @click="toggleFacet(q2,q1.childFacet)">
                          <icon v-if="q2.active" name="univie-stop2" class="primary--text"></icon>
                          <icon v-if="!q2.active" name="univie-checkbox-unchecked" class="primary--text"></icon>
                          <span :class="{ active: q2.active }" class="facet-label primary--text">{{ $t(q2.label) }}</span>
                          <span class="facet-count grey--text" v-if="q2.count>0">({{q2.count}})</span>
                        </span>
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
                <icon @click.native="toggleOwnerFilter()" v-if="showOwnerFilter" name="univie-stop2" class="primary--text"></icon>
                <icon @click.native="toggleOwnerFilter()" v-if="!showOwnerFilter" name="univie-checkbox-unchecked" class="primary--text"></icon>
                <span @click="toggleOwnerFilter()" class="facet-label primary--text" :class="{ active: showOwnerFilter }">{{ $t('Owner') }}</span>
              </v-col>
            </v-row>
            <v-row no-gutters>
            <v-btn dark v-if="owner" class="mb-8 mt-4 grey">{{ owner }}<v-icon right @click.native="removeOwnerFilter()">mdi-close</v-icon></v-btn>
            </v-row>
            <v-row no-gutters>
              <v-autocomplete
                class="mt-2"
                v-if="showOwnerFilter"
                v-model="usernameSearchModel"
                :items="usernameSearchItems.length > 0 ? usernameSearchItems : []"
                :loading="usernameSearchLoading"
                :search-input.sync="usernameSearch"
                :label="$t('Username search')"
                :placeholder="$t('Start typing to search')"
                item-value="uid"
                item-text="uid"
                prepend-icon="mdi-database-search"
                hide-no-data
                return-object
                clearable
                @click:clear="usernameSearchItems=[]"
              >
                <template slot="item" slot-scope="{ item }">
                  <template v-if="item">
                    <v-list-item-content two-line>
                      <v-list-item-title>{{ item.uid }}</v-list-item-title>
                      <v-list-item-subtitle>{{ item.value }}</v-list-item-subtitle>
                    </v-list-item-content>
                  </template>
                </template>
              </v-autocomplete>
            </v-row>
            <v-row no-gutters>
              <v-autocomplete
                class="mt-2"
                v-if="showOwnerFilter"
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
            </v-row>
          </li>
          <li>
            <v-row no-gutters>
              <v-col>
                <icon @click.native="toggleAuthorFilter()" v-if="showAuthorFilter" name="univie-stop2" class="primary--text"></icon>
                <icon @click.native="toggleAuthorFilter()" v-if="!showAuthorFilter" name="univie-checkbox-unchecked" class="primary--text"></icon>
                <span @click="toggleAuthorFilter()" class="facet-label primary--text" :class="{ active: showAuthorFilter }">{{ $t('Authors') }}</span>
              </v-col>
            </v-row>
            <v-row no-gutters v-if="showAuthorFilter">
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
                <icon @click.native="toggleRoleFilter()" v-if="showRoleFilter" name="univie-stop2" class="primary--text"></icon>
                <icon @click.native="toggleRoleFilter()" v-if="!showRoleFilter" name="univie-checkbox-unchecked" class="primary--text"></icon>
                <span @click="toggleRoleFilter()" class="facet-label primary--text" :class="{ active: showRoleFilter }">{{ $t('Roles') }}</span>
              </v-col>
            </v-row>
            <v-row no-gutters v-if="showRoleFilter">
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

export default {
  name: 'p-search-filters',
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
        if (this.init && this.owner) {
          if (this.usernameSearchItems[0]) {
            this.usernameSearchModel = this.usernameSearchItems[0]
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
    },
    toggleOwnerFilter: function () {
      this.showOwnerFilter = !this.showOwnerFilter
      if (!this.showOwnerFilter) {
        this.owner = ''
        this.search({ owner: this.owner })
      }
    },
    toggleAuthorFilter: function () {
      this.showAuthorFilter = !this.showAuthorFilter
      if (!this.showAuthorFilter) {
        this.persAuthors.values = []
        this.corpAuthors.values = []
        this.search({ persAuthors: this.persAuthors, corpAuthors: this.corpAuthors })
      }
    },
    toggleRoleFilter: function () {
      this.showRoleFilter = !this.showRoleFilter
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
            Vue.set(q, 'active', false)
          }
        }
      }
      this.search({ page: 1, facetQueries: this.facetQueries })
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
