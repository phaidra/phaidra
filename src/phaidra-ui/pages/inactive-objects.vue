<template>
  <v-container fluid>
    <h1 class="d-sr-only">{{ pageTitle }}</h1>
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title class="text-title-large font-weight-light text-white">
            {{ pageTitle }}
          </v-card-title>
          <v-card-text>
            <v-data-table-server
              :headers="headers"
              :items="objects"
              :items-length="total"
              :loading="loading"
              :loading-text="$t('Loading...')"
              :no-data-text="$t('No inactive objects')"
              :no-results-text="$t('There were no search results')"
              v-model:page="page"
              v-model:items-per-page="itemsPerPage"
              :items-per-page-options="[10, 25, 50, 100]"
              :page-text="$t('Page')"
              :items-per-page-text="$t('Rows per page')"
              @update:options="onTableOptions"
            >
              <template v-slot:top>
                <v-toolbar flat color="transparent" class="my-4">
                  <v-text-field
                    v-model="search"
                    append-inner-icon="mdi-magnify"
                    :label="$t('Search...')"
                    single-line
                    hide-details
                  ></v-text-field>
                  <v-spacer></v-spacer>
                  <v-dialog v-if="canManage || isAdmin" v-model="registerDialog" max-width="500px">
                    <template v-slot:activator="{ props: activatorProps }">
                      <v-btn color="primary" theme="dark" class="mb-2" v-bind="activatorProps">
                        {{ $t('Register inactive object') }}
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="text-title-large font-weight-light text-white">
                        {{ $t('Register inactive object') }}
                      </v-card-title>
                      <v-form @submit.prevent="registerObject">
                      <v-card-text>
                        <p class="mb-4">
                          {{ $t('Register an existing Inactive object so its owner can see it under My inactive objects. Reads owner, cmodel and title from Fedora / JSON-LD.') }}
                        </p>
                        <v-text-field
                          v-model="registerPid"
                          :label="$t('PID')"
                          hide-details
                          class="mb-3"
                          autofocus
                        ></v-text-field>
                        <v-text-field
                          v-model="registerSource"
                          :label="$t('Source')"
                          hide-details
                          class="mb-3"
                        ></v-text-field>
                        <v-text-field
                          v-if="isAdmin"
                          v-model="registerStatus"
                          :label="$t('Status')"
                          hide-details
                        ></v-text-field>
                      </v-card-text>
                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn variant="outlined" :disabled="registerLoading" @click="registerDialog = false">{{ $t('Cancel') }}</v-btn>
                        <v-btn
                          type="submit"
                          color="primary"
                          :loading="registerLoading"
                          :disabled="!registerPid || registerLoading"
                        >{{ $t('Register') }}</v-btn>
                      </v-card-actions>
                      </v-form>
                    </v-card>
                  </v-dialog>
                </v-toolbar>
              </template>
              <template v-slot:item.pid="{ item }">
                {{ item.pid }}
              </template>
              <template v-slot:item.title="{ item }">
                {{ item.title || '—' }}
              </template>
              <template v-slot:item.created="{ item }">
                {{ formatDate(item.created) }}
              </template>
              <template v-slot:item.updated="{ item }">
                {{ formatDate(item.updated) }}
              </template>
              <template v-slot:item.status="{ item }">
                {{ item.status ? $t(item.status) : '—' }}
              </template>
              <template v-slot:item.actions="{ item }">
                <v-tooltip location="bottom">
                  <template v-slot:activator="{ props: activatorProps }">
                    <v-icon-btn
                      variant="text"
                      class="mx-1"
                      @click="openPreview(item)"
                      v-bind="activatorProps"
                      :aria-label="$t('Preview')"
                      icon="mdi-eye"
                    />
                  </template>
                  <span>{{ $t('Preview') }}</span>
                </v-tooltip>
                <v-tooltip location="bottom">
                  <template v-slot:activator="{ props: activatorProps }">
                    <v-icon-btn
                      variant="text"
                      class="mx-1"
                      @click="downloadObject(item.pid)"
                      v-bind="activatorProps"
                      :aria-label="$t('Download')"
                      icon="mdi-download"
                    />
                  </template>
                  <span>{{ $t('Download') }}</span>
                </v-tooltip>
                <template v-if="canManage || isAdmin">
                  <v-tooltip location="bottom">
                    <template v-slot:activator="{ props: activatorProps }">
                      <v-icon-btn
                        variant="text"
                        class="mx-1"
                        color="primary"
                        @click="editMetadata(item)"
                        v-bind="activatorProps"
                        :aria-label="$t('Edit metadata')"
                        icon="mdi-pencil"
                      />
                    </template>
                    <span>{{ $t('Edit metadata') }}</span>
                  </v-tooltip>
                  <v-tooltip location="bottom">
                    <template v-slot:activator="{ props: activatorProps }">
                      <v-icon-btn
                        variant="text"
                        class="mx-1"
                        color="primary"
                        :loading="actionPid === item.pid && actionType === 'activate'"
                        :disabled="!!actionPid"
                        @click="activateObject(item)"
                        v-bind="activatorProps"
                        :aria-label="$t('Activate')"
                        icon="mdi-check-circle"
                      />
                    </template>
                    <span>{{ $t('Activate') }}</span>
                  </v-tooltip>
                  <v-tooltip location="bottom">
                    <template v-slot:activator="{ props: activatorProps }">
                      <v-icon-btn
                        variant="text"
                        class="mx-1"
                        @click="deregisterObject(item)"
                        v-bind="activatorProps"
                        :aria-label="$t('Deregister')"
                        icon="mdi-playlist-remove"
                      />
                    </template>
                    <span>{{ $t('Deregister') }}</span>
                  </v-tooltip>
                  <v-tooltip location="bottom">
                    <template v-slot:activator="{ props: activatorProps }">
                      <v-icon-btn
                        variant="text"
                        class="mx-1"
                        color="btnred"
                        @click="openDeleteDialog(item)"
                        v-bind="activatorProps"
                        :aria-label="$t('Delete')"
                        icon="mdi-delete"
                      />
                    </template>
                    <span>{{ $t('Delete') }}</span>
                  </v-tooltip>
                </template>
              </template>
            </v-data-table-server>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-dialog v-model="previewDialog" max-width="900px" scrollable>
      <v-card v-if="previewItem">
        <v-card-title class="text-title-large font-weight-light text-white">
          {{ $t('Preview') }} — {{ previewItem.pid }}
        </v-card-title>
        <v-card-text class="mt-4 inactive-preview-jsonld" style="max-height: 70vh;">
          <div v-if="previewLoading" class="text-center py-8">
            <v-progress-circular indeterminate color="primary"></v-progress-circular>
          </div>
          <p-d-jsonld v-else-if="previewJsonld" :jsonld="previewJsonld"></p-d-jsonld>
          <div v-else>{{ $t('No data available') }}</div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="outlined" @click="previewDialog = false">{{ $t('Close') }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="deleteDialog" max-width="500px" v-if="deleteItem">
      <v-card>
        <v-card-title class="text-title-large font-weight-light text-white">
          {{ $t('Delete') }}
        </v-card-title>
        <v-card-text class="mt-4">
          {{ $t('DELETE_OBJECT_CONFIRM', { pid: (instanceconfig.baseurl || '') + '/' + deleteItem.pid }) }}
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="outlined" :disabled="deleteLoading" @click="deleteDialog = false">{{ $t('Cancel') }}</v-btn>
          <v-btn theme="dark" color="btnred" :loading="deleteLoading" :disabled="deleteLoading" @click="deleteObject()">{{ $t('Delete') }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import { useRootStore } from '~/stores/root'
import { context } from '../mixins/context'
import { config, useDocumentTitle } from '../mixins/config'

export default {
  mixins: [context, config],
  setup() {
    definePageMeta({
      middleware: 'auth'
    })
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      const store = useRootStore()
      const title = (store.user?.isadmin || store.canManageInactiveObjects) ? t('Inactive objects') : t('My inactive objects')
      return { title: documentTitle(title) }
    })
  },
  data() {
    return {
      loading: false,
      search: '',
      searchTimer: null,
      objects: [],
      total: 0,
      page: 1,
      itemsPerPage: 10,
      sortKey: 'created',
      sortOrder: 'desc',
      canManage: false,
      isAdmin: false,
      headers: [],
      registerDialog: false,
      registerPid: '',
      registerSource: 'manual',
      registerStatus: 'Awaiting upload',
      registerLoading: false,
      previewDialog: false,
      previewItem: null,
      previewJsonld: null,
      previewLoading: false,
      deleteDialog: false,
      deleteItem: null,
      deleteLoading: false,
      actionPid: null,
      actionType: null
    }
  },
  computed: {
    pageTitle() {
      return (this.canManage || this.isAdmin) ? this.$t('Inactive objects') : this.$t('My inactive objects')
    }
  },
  watch: {
    '$i18n.locale'() {
      this.buildHeaders()
    },
    search() {
      clearTimeout(this.searchTimer)
      this.searchTimer = setTimeout(() => {
        this.page = 1
        this.loadObjects()
      }, 300)
    }
  },
  created() {
    this.buildHeaders()
  },
  beforeUnmount() {
    clearTimeout(this.searchTimer)
  },
  methods: {
    buildHeaders() {
      const headers = [
        { title: this.$t('PID'), key: 'pid' },
        { title: this.$t('Title'), key: 'title' }
      ]
      if (this.canManage || this.isAdmin) {
        headers.push({ title: this.$t('Owner'), key: 'owner' })
      }
      headers.push(
        { title: this.$t('Resource type'), key: 'cmodel' },
        { title: this.$t('Source'), key: 'source' },
        { title: this.$t('Status'), key: 'status' },
        { title: this.$t('Created'), align: 'end', key: 'created' },
        { title: this.$t('Updated'), align: 'end', key: 'updated' },
        { title: this.$t('Actions'), align: 'end', key: 'actions', sortable: false }
      )
      this.headers = headers
    },
    formatDate(val) {
      if (!val) return '—'
      return String(val).replace('T', ' ').replace(/\.\d+Z?$/, '').replace(/Z$/, '')
    },
    downloadUrl(pid) {
      return (this.instanceconfig?.api || '') + '/object/' + pid + '/download'
    },
    downloadObject(pid) {
      window.location.href = this.downloadUrl(pid)
    },
    editMetadata(item) {
      this.$router.push(this.localePath({
        path: '/metadata/' + item.pid + '/edit',
        query: { from: 'inactive-objects' }
      }))
    },
    onTableOptions(options) {
      this.page = options.page || 1
      this.itemsPerPage = options.itemsPerPage || 10
      const sort = Array.isArray(options.sortBy) && options.sortBy.length ? options.sortBy[0] : null
      this.sortKey = sort?.key || sort?.value || 'created'
      this.sortOrder = sort?.order || 'desc'
      this.loadObjects()
    },
    async loadObjects() {
      this.loading = true
      try {
        const params = {
          page: this.page,
          limit: this.itemsPerPage,
          sort: this.sortKey,
          order: this.sortOrder
        }
        if (this.search && this.search.trim()) {
          params.q = this.search.trim()
        }
        const response = await this.$axios.get('/inactive-objects', {
          params,
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        }
        this.objects = response.data.objects || []
        const total = Number(response.data.total)
        this.total = Number.isFinite(total) ? total : this.objects.length
        this.canManage = !!response.data.can_manage
        this.isAdmin = !!response.data.is_admin
        useRootStore().canManageInactiveObjects = this.canManage
        useRootStore().isInactiveObjectsAdmin = this.isAdmin
        useRootStore().hasInactiveObjects = this.total > 0
        this.buildHeaders()
      } catch (err) {
        console.error(err)
        useRootStore().setAlerts([{ type: 'error', msg: err }])
      } finally {
        this.loading = false
      }
    },
    async registerObject() {
      if (!this.registerPid) return
      this.registerLoading = true
      try {
        const pid = this.registerPid.trim()
        const params = {}
        if (this.registerSource) {
          params.source = this.registerSource.trim()
        }
        if (this.isAdmin && this.registerStatus) {
          params.status = this.registerStatus.trim()
        }
        const response = await this.$axios.request({
          method: 'POST',
          url: '/inactive-objects/' + encodeURIComponent(pid) + '/register',
          params,
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        } else {
          useRootStore().setAlerts([{ type: 'success', msg: this.$t('Inactive object registered') }])
        }
        this.registerDialog = false
        this.registerPid = ''
        this.registerSource = 'manual'
        this.registerStatus = 'Awaiting upload'
        await this.loadObjects()
      } catch (error) {
        console.error(error)
      } finally {
        this.registerLoading = false
      }
    },
    async openPreview(item) {
      this.previewItem = item
      this.previewJsonld = null
      this.previewDialog = true
      this.previewLoading = true
      try {
        const response = await this.$axios.get('/object/' + item.pid + '/jsonld', {
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        this.previewJsonld = response.data?.['JSON-LD'] || response.data
      } catch (error) {
        console.error(error)
        useRootStore().setAlerts([{ type: 'error', msg: error }])
      } finally {
        this.previewLoading = false
      }
    },
    async activateObject(item) {
      this.actionPid = item.pid
      this.actionType = 'activate'
      try {
        const response = await this.$axios.request({
          method: 'POST',
          url: '/inactive-objects/' + encodeURIComponent(item.pid) + '/activate',
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        } else {
          useRootStore().setAlerts([{ type: 'success', msg: this.$t('Object activated') }])
        }
        await this.loadObjects()
      } catch (error) {
        console.error(error)
      } finally {
        this.actionPid = null
        this.actionType = null
      }
    },
    async deregisterObject(item) {
      this.actionPid = item.pid
      this.actionType = 'deregister'
      try {
        const response = await this.$axios.request({
          method: 'POST',
          url: '/inactive-objects/' + encodeURIComponent(item.pid) + '/remove',
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        } else {
          useRootStore().setAlerts([{ type: 'success', msg: this.$t('Object deregistered') }])
        }
        await this.loadObjects()
      } catch (error) {
        console.error(error)
      } finally {
        this.actionPid = null
        this.actionType = null
      }
    },
    openDeleteDialog(item) {
      this.deleteItem = item
      this.deleteDialog = true
    },
    async deleteObject() {
      if (!this.deleteItem) return
      this.deleteLoading = true
      try {
        const pid = this.deleteItem.pid
        const response = await this.$axios.request({
          method: 'POST',
          url: '/inactive-objects/' + encodeURIComponent(pid) + '/delete',
          headers: {
            'X-XSRF-TOKEN': useRootStore().user.token
          }
        })
        if (response.data.status === 200 || response.status === 200) {
          useRootStore().setAlerts([{ type: 'success', msg: this.$t('Object deleted') }])
          this.deleteDialog = false
          this.deleteItem = null
          await this.loadObjects()
        } else if (response.data.alerts && response.data.alerts.length > 0) {
          useRootStore().setAlerts(response.data.alerts)
        }
      } catch (error) {
        console.error(error)
        useRootStore().setAlerts([{ type: 'error', msg: 'Error deleting object: ' + error }])
      } finally {
        this.deleteLoading = false
      }
    }
  }
}
</script>

<style scoped>
.inactive-preview-jsonld :deep(a:not(.v-btn)) {
  color: rgb(var(--v-theme-primary));
}
</style>
