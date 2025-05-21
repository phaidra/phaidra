<template>
  <div>
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title class="title font-weight-light white--text">
            {{ $t('Manage user groups') }}
          </v-card-title>
          <v-card-text>
            <v-data-table
              :headers="groupsHeaders"
              :items="groups"
              :search="groupsSearch"
              :loading="groupsLoading"
              :loading-text="$t('Loading groups...')"
              :no-data-text="$t('No data available')"
              :footer-props="{
                pageText: $t('Page'),
                itemsPerPageText: $t('Rows per page'),
                itemsPerPageAllText: $t('All')
              }"
              :no-results-text="$t('There were no search results')"
            >
              <template v-slot:top>
                <v-toolbar flat color="transparent" class="my-4">
                  <v-text-field
                    v-model="groupsSearch"
                    append-icon="mdi-magnify"
                    :label="$t('Search...')"
                    single-line
                    hide-details
                  ></v-text-field>
                  <v-spacer></v-spacer>
                  <v-dialog v-model="createDialog" max-width="500px">
                    <template v-slot:activator="{ on }">
                      <v-btn color="primary" dark class="mb-2" v-on="on">{{ $t('Create new group') }}</v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="title font-weight-light white--text">
                        {{ $t('New group') }}
                      </v-card-title>
                      <v-card-text class="my-4">
                        <v-text-field
                          v-model="newGroupName"
                          :label="$t('Enter group name...')"
                          single-line
                          hide-details
                        ></v-text-field>
                      </v-card-text>
                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn outlined @click="createDialog = false">{{ $t('Cancel') }}</v-btn>
                        <v-btn @click="createGroup()" color="primary">{{ $t('Create') }}</v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </v-toolbar>
              </template>
              <template v-slot:item.name="{ item }">
                <v-tooltip bottom>
                  <template v-slot:activator="{ on, attrs }">
                    <span v-on="on" v-bind="attrs">{{ item.name }}</span>
                  </template>
                  <span>{{ item.groupid }}</span>
                </v-tooltip>
              </template>
              <template v-slot:item.created="{ item }">
                {{ item.created | unixtime }}
              </template>
              <template v-slot:item.updated="{ item }">
                {{ item.updated | unixtime }}
              </template>
              <template v-slot:item.actions="{ item }">
                <v-tooltip bottom>
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn icon color="primary" @click="loadedGroup = item" v-on="on" v-bind="attrs" :aria-label="$t('Edit')">
                      <v-icon>mdi-pencil</v-icon>
                    </v-btn>
                  </template>
                  <span>{{ $t('Edit')}}</span>
                </v-tooltip>
                <v-tooltip bottom>
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn icon color="btnred" @click="deleteGroupDialog(item)" v-on="on" v-bind="attrs" :aria-label="$t('Delete')">
                      <v-icon>mdi-delete</v-icon>
                    </v-btn>
                  </template>
                  <span>{{ $t('Delete')}}</span>
                </v-tooltip>
              </template>
            </v-data-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    <v-row v-if="loadedGroup">
      <v-col cols="12">
        <v-card>
          <v-card-title class="title font-weight-light white--text">
            {{ loadedGroup.name }}
          </v-card-title>
          <v-card-text>
            <v-data-table
              :headers="membersHeaders"
              :items="members"
              :search="membersSearch"
              :loading="membersLoading"
              :loading-text="$t('Loading group members...')"
              :no-data-text="$t('No data available')"
              :footer-props="{
                pageText: $t('Page'),
                itemsPerPageText: $t('Rows per page'),
                itemsPerPageAllText: $t('All')
              }"
              :no-results-text="$t('There were no search results')"
              class="mt-4"
            >
              <!-- <template v-slot:top>
                <v-toolbar flat>
                  <v-text-field
                    v-model="membersSearch"
                    append-icon="mdi-magnify"
                    :label="$t('Search...')"
                    single-line
                    hide-details
                  ></v-text-field>
                </v-toolbar>
              </template> -->
              <template v-slot:item.pid="{ item }">
                {{ item.name }}
              </template>
              <template v-slot:item.title="{ item }">
                [{{ item.username }}]
              </template>
              <template v-slot:item.actions="{ item }">
                <v-tooltip bottom>
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn icon color="btnred" @click="removeMember(item.username)" v-on="on" v-bind="attrs" :aria-label="$t('Delete')">
                      <v-icon>mdi-delete</v-icon>
                    </v-btn>
                  </template>
                  <span>{{ $t('Delete')}}</span>
                </v-tooltip>                
              </template>
            </v-data-table>
            <v-card-actions>
              <v-btn color="primary" @click="$refs.userSearchdialog.open()">
                {{ $t('Username search') }}
                <v-icon
                  right
                  dark
                >
                  mdi-database-search
                </v-icon>
              </v-btn>
              <v-spacer></v-spacer>
            </v-card-actions>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    <v-dialog v-model="deleteDialog" max-width="500px" v-if="groupToDelete">
      <v-card>
        <v-card-title class="title font-weight-light white--text">
          {{ $t('Delete group') }}
        </v-card-title>
        <v-card-text class="my-4">
          <p class="title font-weight-light">{{ $t('Delete group') + ' ' + groupToDelete.name + '?' }}</p>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn outlined @click="deleteDialog = false">{{ $t('Cancel') }}</v-btn>
          <v-btn dark @click="deleteGroup()" color="btnred">{{ $t('Delete') }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <user-search-dialog ref="userSearchdialog" @user-selected="searchUserSelected($event)"></user-search-dialog>
  </div>
</template>

<script>
import UserSearchDialog from '../select/UserSearchDialog'

export default {
  name: 'p-groups',
  components: {
    UserSearchDialog
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  watch: {
    loadedGroup: {
      handler: async function () {
        if (this.loadedGroup) {
          this.membersLoading = true
          try {
            let response = await this.$axios.request({
              method: 'GET',
              url: '/group/' + this.loadedGroup.groupid,
              headers: {
                'X-XSRF-TOKEN': this.$store.state.user.token
              }
            })
            if (response.status === 200) {
              this.members = response.data.group.members
            } else {
              if (response.data.alerts && response.data.alerts.length > 0) {
                this.$store.commit('setAlerts', response.data.alerts)
              }
            }
          } catch (error) {
            console.log(error)
          } finally {
            this.membersLoading = false
          }
        }
      },
      deep: true
    },
    userSearch: async function (val) {
      if (val && (val.length < 2)) {
        this.userSearchItems = []
        return
      }
      // if (this.userSearchItems.length > 0) return
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
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.userSearchLoading = false
      }
    }
  },
  data () {
    return {
      createDialog: false,
      deleteDialog: false,
      groupToDelete: null,
      newGroupName: '',
      groupsLoading: false,
      groupsSearch: '',
      deleteGroupConfirm: false,
      groupsHeaders: [],
      groups: [],
      loadedGroup: null,
      membersLoading: false,
      membersSearch: '',
      deleteMembersConfirm: false,
      membersHeaders: [],
      members: [],
      userSearch: null,
      userSearchModel: null,
      userSearchItems: [],
      userSearchLoading: false
    }
  },
  watch: {
     '$i18n.locale': {
        immediate: true, // Ensure it's set on load
        handler() {
          this.groupsHeaders = [
              { text: this.$t('Name'), align: 'left', value: 'name' },
              { text: this.$t('Created'), align: 'right', value: 'created' },
              { text: this.$t('Modified'), align: 'right', value: 'updated' },
              { text: this.$t('Actions'), align: 'right', value: 'actions', sortable: false }
            ];
          this.membersHeaders = [
              { text: this.$t('Name'), align: 'left', value: 'name' },
              { text: this.$t('Username'), align: 'left', value: 'username' },
              { text: this.$t('Actions'), align: 'right', value: 'actions', sortable: false }
            ];
        }
     }
  },
  methods: {
    searchUserSelected: function(selectedUser) {
      this.userSearchModel = {
        uid: selectedUser.username
      }
      this.addMember()
    },
    deleteGroupDialog: function (group) {
      this.groupToDelete = group
      this.deleteDialog = true
    },
    createGroup: async function () {
      try {
        this.createDialog = false
        this.groupsLoading = true
        var httpFormData = new FormData()
        httpFormData.append('name', this.newGroupName)
        let response = await this.$axios.request({
          method: 'POST',
          url: '/group/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        this.newGroupName = ''
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        response = await this.$axios.request({
          method: 'GET',
          url: '/groups',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.groups = response.data.groups
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.groupsLoading = false
      }
    },
    deleteGroup: async function () {
      this.deleteDialog = false
      this.groupsLoading = true
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/group/' + this.groupToDelete.groupid + '/remove',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        response = await this.$axios.request({
          method: 'GET',
          url: '/groups',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.groups = response.data.groups
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.groupsLoading = false
        this.groupToDelete = null
      }
    },
    removeMember: async function (member) {
      try {
        this.membersLoading = true
        var httpFormData = new FormData()
        httpFormData.append('members', JSON.stringify({ members: [ member ] }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/group/' + this.loadedGroup.groupid + '/members/remove',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        response = await this.$axios.request({
          method: 'GET',
          url: '/group/' + this.loadedGroup.groupid,
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.members = response.data.group.members
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.membersLoading = false
      }
    },
    addMember: async function () {
      try {
        this.membersLoading = true
        var httpFormData = new FormData()
        httpFormData.append('members', JSON.stringify({ members: [ this.userSearchModel.uid ] }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/group/' + this.loadedGroup.groupid + '/members/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        response = await this.$axios.request({
          method: 'GET',
          url: '/group/' + this.loadedGroup.groupid,
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.members = response.data.group.members
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.membersLoading = false
      }
    },
    getGroups: async function () {
      this.groupsLoading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/groups',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.groups = response.data.groups
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.groupsLoading = false
      }
    }
  },
  created: function () {
    console.log('lgroups mounted')
    this.getGroups()
  },
  // The below method is not working in nuxt js
  beforeRouteEnter: async function (to, from, next) {
    next(async vm => {
      vm.groupsLoading = true
      try {
        let response = await vm.$axios.request({
          method: 'GET',
          url: '/groups',
          headers: {
            'X-XSRF-TOKEN': vm.$store.state.user.token
          }
        })
        vm.groups = response.data.groups
        if (response.data.alerts && response.data.alerts.length > 0) {
          vm.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        vm.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        vm.groupsLoading = false
      }
    })
  }
}
</script>
