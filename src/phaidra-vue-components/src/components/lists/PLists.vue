<template>
  <div>
    <h1 class="d-sr-only">{{ $t('Object lists') }}</h1>
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title class="title font-weight-light white--text">
            {{ $t('Manage object lists') }}
          </v-card-title>
          <v-card-text>
            <v-data-table
              :headers="listsHeaders"
              :items="lists"
              :search="listsSearch"
              :loading="listsLoading"
              :loading-text="$t('Loading object lists...')"
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
                    v-model="listsSearch"
                    append-icon="mdi-magnify"
                    :label="$t('Search...')"
                    single-line
                    hide-details
                  ></v-text-field>
                  <v-spacer></v-spacer>
                  <v-dialog v-model="createDialog" max-width="500px">
                    <template v-slot:activator="{ on }">
                      <v-btn color="primary" dark class="mb-2" v-on="on">{{ $t('Create new object list') }}</v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="title font-weight-light white--text">
                        {{ $t('New object list') }}
                      </v-card-title>
                      <v-card-text>
                        <v-text-field
                          v-model="newListName"
                          :label="$t('Enter object list name...')"
                          single-line
                          hide-details
                        ></v-text-field>
                      </v-card-text>
                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn outlined @click="createDialog = false">{{ $t('Cancel') }}</v-btn>
                        <v-btn @click="createList()" color="primary">{{ $t('Create') }}</v-btn>
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
                  <span>{{ item.listid }}</span>
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
                    <v-btn icon class="mx-3" color="primary" @click="loadedList = item" v-on="on" v-bind="attrs" :aria-label="$t('Edit')">
                      <v-icon>mdi-pencil</v-icon>
                    </v-btn>
                  </template>
                  <span>{{ $t('Edit') }}</span>
                </v-tooltip>
                <v-tooltip bottom>
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn icon class="mx-3" color="btnred" @click="deleteListDialog(item)" v-on="on" v-bind="attrs" :aria-label="$t('Delete')">
                      <v-icon>mdi-delete</v-icon>
                    </v-btn>
                  </template>
                  <span>{{ $t('Delete') }}</span>
                </v-tooltip>
              </template>
            </v-data-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    <v-row v-if="loadedList">
      <v-col cols="12">
        <v-card>
          <v-card-title class="title font-weight-light white--text">
            <span>{{ loadedList.name }}</span>
            <v-spacer></v-spacer>
            <template v-if="token && token.length > 0"><a class="pl-2 white--text" target="_blank" :href="'/list/' + token">{{ instance.baseurl + '/list/' + token }}</a></template>
          </v-card-title>
          <v-card-text>
            <v-data-table
              :headers="membersHeaders"
              :items="members"
              :search="membersSearch"
              :loading="membersLoading"
              :loading-text="$t('Loading object list members...')"
              :no-data-text="$t('No data available')"
              :footer-props="{
                pageText: $t('Page'),
                itemsPerPageText: $t('Rows per page'),
                itemsPerPageAllText: $t('All')
              }"
              :no-results-text="$t('There were no search results')"
            >
              <template v-slot:top>
                <v-toolbar flat color="transparent" class="mt-4">
                  <v-spacer></v-spacer>
                  <!-- <v-text-field
                    v-model="membersSearch"
                    append-icon="mdi-magnify"
                    :label="$t('Search...')"
                    single-line
                    hide-details
                  ></v-text-field> -->
                  <v-btn v-if="token && token.length > 0" color="btnred" dark class="mb-2 ml-2"  @click="deleteToken(loadedList.listid)">{{ $t('Remove public link') }}</v-btn>
                  <v-btn v-else color="primary" dark class="mb-2 ml-2"  @click="createToken(loadedList.listid)">{{ $t('Create public link') }}</v-btn>
                  <v-btn v-if="members.length > 0" color="primary" dark class="mb-2 ml-2"  @click="$refs.collectiondialog.open()">{{ $t('Add objects to collection') }}</v-btn>
                </v-toolbar>
              </template>
              <template v-slot:item.pid="{ item }">
                <nuxt-link :to="{ path: `detail/${item.pid}`, params: { pid: item.pid } }">{{ item.pid }}</nuxt-link>
              </template>
              <template v-slot:item.title="{ item }">
                {{ item.title | truncate(100) }}
              </template>
              <template v-slot:item.actions="{ item }">
                <v-tooltip bottom>
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn icon class="mx-3" color="btnred" @click="removeMember(item.pid)" v-on="on" v-bind="attrs" :aria-label="$t('Remove')">
                        <v-icon>mdi-delete</v-icon>
                      </v-btn>
                    </template>
                    <span>{{ $t('Remove') }}</span>
                </v-tooltip>                
              </template>
            </v-data-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    <v-dialog v-model="deleteDialog" max-width="500px" v-if="listToDelete">
      <v-card>
        <v-card-title class="title font-weight-light white--text">
          {{ $t('Delete object list') }}
        </v-card-title>
        <v-card-text class="mt-4">
          <p class="title font-weight-light">{{ $t('Delete object list') + ' ' + listToDelete.name + '?' }}</p>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn outlined @click="deleteDialog = false">{{ $t('Cancel') }}</v-btn>
          <v-btn dark @click="deleteList()" color="btnred">{{ $t('Delete') }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <collection-dialog ref="collectiondialog" @collection-selected="addToCollection($event)"></collection-dialog>
  </div>
</template>

<script>
import CollectionDialog from '../select/CollectionDialog'

export default {
  name: 'p-lists',
  components: {
    CollectionDialog
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      createDialog: false,
      deleteDialog: false,
      addToDialog: false,
      listToDelete: null,
      listToAddToCollection: null,
      newListName: '',
      listsLoading: false,
      listsSearch: '',
      deleteListConfirm: false,
      listsHeaders: [],
      lists: [],
      loadedList: null,
      membersLoading: false,
      membersSearch: '',
      deleteMembersConfirm: false,
      membersHeaders: [],
      members: [],
      token: null
    }
  },
  watch: {
     '$i18n.locale': {
        immediate: true, // Ensure it's set on load
        handler() {
          this.listsHeaders = [
            { text: this.$t('Name'), align: 'left', value: 'name' },
            { text: this.$t('Created'), align: 'right', value: 'created' },
            { text: this.$t('Modified'), align: 'right', value: 'updated' },
            { text: this.$t('Actions'), align: 'right', value: 'actions', sortable: false }
          ];
          this.membersHeaders = [
            { text: this.$t('PID'), align: 'left', value: 'pid' },
            { text: this.$t('Title'), align: 'left', value: 'title' },
            { text: this.$t('Actions'), align: 'right', value: 'actions', sortable: false }
          ];
        }
     },
     loadedList: {
      handler: async function () {
        if (this.loadedList) {
          await this.refreshLoadedList()
        }
      },
      deep: true
    },
  },
  methods: {
    refreshLoadedList: async function () {
      this.membersLoading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/list/' + this.loadedList.listid,
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.members = response.data.list.members
        this.token = response.data.list.token
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.membersLoading = false
      }
    },
    createToken: async function (lid) {
      try {
        this.loading = true
        let response = await this.$axios.request({
          method: 'POST',
          url: '/list/' + lid + '/token/create',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.$store.commit('setAlerts', [ { msg: this.$t('Share link successfully created'), type: 'success' } ])
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.refreshLoadedList()
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    deleteToken: async function (lid) {
      try {
        this.loading = true
        let response = await this.$axios.request({
          method: 'POST',
          url: '/list/' + lid + '/token/delete',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.$store.commit('setAlerts', [ { msg: this.$t('Share link successfully deleted'), type: 'success' } ])
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.refreshLoadedList()
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    addToCollection: async function (collection) {
      try {
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { members: this.members } }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/collection/' + collection.pid + '/members/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        this.$store.commit('setAlerts', [ { msg: this.$t('Collection successfully updated'), type: 'success' } ])
        this.$router.push({ path: `detail/${collection.pid}` })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    deleteListDialog: function (list) {
      this.listToDelete = list
      this.deleteDialog = true
    },
    addToCollectionDialog: function (list) {
      this.listToAddToCollection = list
      this.addToDialog = true
    },
    createList: async function () {
      try {
        this.createDialog = false
        this.listsLoading = true
        var httpFormData = new FormData()
        httpFormData.append('name', this.newListName)
        let response = await this.$axios.request({
          method: 'POST',
          url: '/list/add',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        this.newListName = ''
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.getLists()
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.listsLoading = false
      }
    },
    deleteList: async function () {
      this.deleteDialog = false
      this.listsLoading = true
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/list/' + this.listToDelete.listid + '/remove',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.getLists()
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.listsLoading = false
        this.listToDelete = null
      }
    },
    removeMember: async function (member) {
      try {
        this.membersLoading = true
        var httpFormData = new FormData()
        httpFormData.append('members', JSON.stringify({ members: [ member ] }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/list/' + this.loadedList.listid + '/members/remove',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        this.refreshLoadedList()
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.membersLoading = false
      }
    },
    getLists: async function () {
      this.listsLoading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/lists',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.lists = response.data.lists
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.listsLoading = false
      }
    }
  },
  mounted () {
    this.getLists()
  }
}
</script>
