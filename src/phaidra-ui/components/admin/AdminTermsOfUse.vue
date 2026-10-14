<template>
  <v-card>
    <v-card-title class="d-flex align-center text-title-large font-weight-light text-white">
      {{ $t('Terms of use') }}
      <v-spacer />
      <v-btn color="primary" class="mr-2" @click="openAddLanguage">{{ $t('Add language') }}</v-btn>
      <v-btn color="primary" @click="openCreateVersion">{{ $t('Create new version') }}</v-btn>
    </v-card-title>
    <v-card-text>
      <v-alert type="warning" variant="tonal" density="compact" class="mt-4 mb-4">
        {{ $t('Each new version requires new consent from all users.') }}
      </v-alert>
      <v-data-table
        :headers="headers"
        :items="items"
        :loading="loading"
        :sort-by="[{ key: 'version', order: 'desc' }]"
        item-value="tid"
      >
        <template #item.terms="{ item }">
          <span class="text-truncate d-inline-block" style="max-width: 420px">{{ preview(item.terms) }}</span>
        </template>
        <template #item.actions="{ item }">
          <v-tooltip location="bottom">
            <template #activator="{ props }">
              <v-icon-btn v-bind="props" icon="mdi-pencil" color="primary" :aria-label="$t('Edit')" @click="openEdit(item)" />
            </template>
            <span>{{ $t('Edit') }}</span>
          </v-tooltip>
        </template>
      </v-data-table>
    </v-card-text>
  </v-card>

  <v-dialog v-model="editDialog" max-width="900">
    <v-card>
      <v-card-title class="text-title-large font-weight-light text-white">
        {{ dialogTitle }}
      </v-card-title>
      <v-card-text class="pt-6">
        <v-alert v-if="mode === 'create-version'" type="warning" variant="tonal" density="compact" class="mb-4">
          {{ $t('Each new version requires new consent from all users.') }}
        </v-alert>
        <v-row v-if="mode === 'add-language'">
          <v-col cols="12" md="6">
            <v-select
              v-model="form.version"
              :items="versionOptions"
              :label="$t('Version')"
              :disabled="!versionOptions.length"
            />
          </v-col>
        </v-row>
        <template v-if="mode === 'edit'">
          <v-row>
            <v-col cols="12" md="4">
              <v-text-field :model-value="form.version" :label="$t('Version')" disabled />
            </v-col>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="form.isocode"
                :label="$t('Language code')"
                maxlength="2"
                hint="e.g. en, de, it"
                persistent-hint
              />
            </v-col>
          </v-row>
          <v-textarea
            v-model="form.terms"
            :label="$t('Terms')"
            rows="14"
            auto-grow
          />
        </template>
        <template v-else>
          <div v-for="(entry, index) in form.entries" :key="index" class="mb-6">
            <v-row>
              <v-col cols="12" md="4">
                <v-text-field
                  v-model="entry.isocode"
                  :label="$t('Language code')"
                  maxlength="2"
                  hint="e.g. en, de, it"
                  persistent-hint
                />
              </v-col>
              <v-col cols="12" md="8" class="d-flex align-center justify-end">
                <v-btn
                  v-if="form.entries.length > 1"
                  variant="outlined"
                  color="btnred"
                  @click="removeEntry(index)"
                >
                  {{ $t('Remove') }}
                </v-btn>
              </v-col>
            </v-row>
            <v-textarea
              v-model="entry.terms"
              :label="$t('Terms')"
              rows="10"
              auto-grow
            />
          </div>
          <v-btn v-if="mode === 'create-version'" variant="outlined" @click="addEntry">
            {{ $t('Add language') }}
          </v-btn>
        </template>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="outlined" @click="editDialog = false">{{ $t('Cancel') }}</v-btn>
        <v-btn color="primary" :loading="saving" :disabled="!canSave" @click="save">{{ $t('Save') }}</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import { useRootStore } from '~/stores/root'

const emptyEntry = () => ({ isocode: '', terms: '' })

export default {
  name: 'AdminTermsOfUse',
  data() {
    return {
      items: [],
      loading: false,
      saving: false,
      editDialog: false,
      mode: 'edit',
      form: {
        tid: null,
        version: null,
        isocode: '',
        terms: '',
        entries: [emptyEntry()]
      }
    }
  },
  computed: {
    headers() {
      return [
        { title: this.$t('Version'), key: 'version' },
        { title: this.$t('Language'), key: 'isocode' },
        { title: this.$t('Added'), key: 'added' },
        { title: this.$t('Terms'), key: 'terms', sortable: false },
        { title: this.$t('Actions'), key: 'actions', sortable: false }
      ]
    },
    token() {
      return useRootStore().user.token
    },
    versionOptions() {
      return [...new Set(this.items.map((item) => item.version))].sort((a, b) => b - a)
    },
    dialogTitle() {
      if (this.mode === 'create-version') return this.$t('Create new version')
      if (this.mode === 'add-language') return this.$t('Add language')
      return this.$t('Edit terms of use')
    },
    canSave() {
      if (this.mode === 'edit') {
        return this.form.isocode?.length === 2 && !!this.form.terms?.trim()
      }
      if (this.mode === 'add-language' && !this.form.version) return false
      return this.form.entries.every((entry) => entry.isocode?.length === 2 && entry.terms?.trim())
    }
  },
  mounted() {
    this.load()
  },
  methods: {
    request(options) {
      return this.$axios.request({
        ...options,
        headers: {
          'X-XSRF-TOKEN': this.token,
          ...(options.headers || {})
        }
      })
    },
    alerts(response) {
      if (response?.data?.alerts?.length) {
        useRootStore().setAlerts(response.data.alerts)
      }
    },
    errorAlert(error) {
      const alerts = error.response?.data?.alerts
      useRootStore().setAlerts(alerts?.length ? alerts : [{ type: 'error', msg: this.$t('The operation failed') }])
    },
    preview(terms) {
      return (terms || '').replace(/\s+/g, ' ').trim()
    },
    async load() {
      this.loading = true
      try {
        const response = await this.request({ method: 'GET', url: '/admin/termsofuse' })
        this.items = response.data.terms || []
        this.alerts(response)
      } catch (error) {
        this.errorAlert(error)
      } finally {
        this.loading = false
      }
    },
    latestEntries() {
      if (!this.items.length) return [emptyEntry()]
      const latestVersion = Math.max(...this.items.map((item) => item.version))
      return this.items
        .filter((item) => item.version === latestVersion)
        .map((item) => ({ isocode: item.isocode, terms: item.terms }))
    },
    openCreateVersion() {
      this.mode = 'create-version'
      this.form = {
        tid: null,
        version: null,
        isocode: '',
        terms: '',
        entries: this.latestEntries()
      }
      this.editDialog = true
    },
    openAddLanguage() {
      this.mode = 'add-language'
      this.form = {
        tid: null,
        version: this.versionOptions[0] || null,
        isocode: '',
        terms: '',
        entries: [emptyEntry()]
      }
      this.editDialog = true
    },
    openEdit(item) {
      this.mode = 'edit'
      this.form = {
        tid: item.tid,
        version: item.version,
        isocode: item.isocode,
        terms: item.terms,
        entries: [emptyEntry()]
      }
      this.editDialog = true
    },
    addEntry() {
      this.form.entries.push(emptyEntry())
    },
    removeEntry(index) {
      this.form.entries.splice(index, 1)
    },
    async save() {
      this.saving = true
      try {
        let response
        if (this.mode === 'edit') {
          response = await this.request({
            method: 'POST',
            url: '/admin/termsofuse/' + encodeURIComponent(this.form.tid),
            data: {
              isocode: this.form.isocode.trim().toLowerCase(),
              terms: this.form.terms
            }
          })
        } else {
          const data = {
            entries: this.form.entries.map((entry) => ({
              isocode: entry.isocode.trim().toLowerCase(),
              terms: entry.terms
            }))
          }
          if (this.mode === 'add-language') {
            data.version = this.form.version
          }
          response = await this.request({
            method: 'POST',
            url: '/admin/termsofuse',
            data
          })
        }
        this.alerts(response)
        this.editDialog = false
        await this.load()
      } catch (error) {
        this.errorAlert(error)
      } finally {
        this.saving = false
      }
    }
  }
}
</script>
