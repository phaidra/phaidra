<template>
  <v-card>
    <v-card-title class="d-flex align-center text-title-large font-weight-light text-white">
      {{ $t('Users') }}
      <v-spacer />
      <v-btn color="primary" @click="openCreate">{{ $t('Create user') }}</v-btn>
    </v-card-title>
    <v-card-text>
      <v-text-field
        v-model="search"
        class="mt-4"
        append-inner-icon="mdi-magnify"
        :label="$t('Search...')"
        hide-details
      />
      <v-data-table
        :headers="headers"
        :items="users"
        :search="search"
        :loading="loading"
        item-value="username"
      >
        <template #item.name="{ item }">
          {{ [item.firstname, item.lastname].filter(Boolean).join(' ') }}
        </template>
        <template #item.active="{ item }">
          <v-chip :color="item.active ? 'success' : 'error'" size="small">
            {{ item.active ? $t('Active') : $t('Inactive') }}
          </v-chip>
        </template>
        <template #item.password_set="{ item }">
          <v-icon :color="item.password_set ? 'success' : 'grey'">
            {{ item.password_set ? 'mdi-lock' : 'mdi-lock-open-variant' }}
          </v-icon>
        </template>
        <template #item.roles="{ item }">
          <v-chip v-for="role in item.roles || []" :key="role" class="mr-1" size="small">{{ role }}</v-chip>
        </template>
        <template #item.actions="{ item }">
          <v-tooltip location="bottom">
            <template #activator="{ props }">
              <v-icon-btn v-bind="props" icon="mdi-pencil" color="primary" :aria-label="$t('Edit')" @click="openEdit(item)" />
            </template>
            <span>{{ $t('Edit') }}</span>
          </v-tooltip>
          <v-tooltip location="bottom">
            <template #activator="{ props }">
              <v-icon-btn v-bind="props" icon="mdi-email-sync" color="primary" :aria-label="$t('Send password reset')" @click="sendReset(item)" />
            </template>
            <span>{{ $t('Send password reset') }}</span>
          </v-tooltip>
          <v-tooltip location="bottom">
            <template #activator="{ props }">
              <v-icon-btn v-bind="props" icon="mdi-delete" color="btnred" :aria-label="$t('Delete')" @click="confirmDelete(item)" />
            </template>
            <span>{{ $t('Delete') }}</span>
          </v-tooltip>
        </template>
      </v-data-table>
    </v-card-text>
  </v-card>

  <v-dialog v-model="editDialog" max-width="900">
    <v-card>
      <v-card-title class="text-title-large font-weight-light text-white">
        {{ creating ? $t('Create user') : $t('Edit user') }}
      </v-card-title>
      <v-card-text class="pt-6">
        <v-row>
          <v-col cols="12" md="6">
            <v-text-field v-model="form.username" :disabled="!creating" :label="$t('Username')" maxlength="128" required autocomplete="off" />
          </v-col>
          <v-col cols="12" md="6">
            <v-text-field v-model="form.email" :label="$t('Email')" maxlength="254" type="email" autocomplete="off" />
          </v-col>
          <v-col cols="12" md="6">
            <v-text-field v-model="form.firstname" :label="$t('First name')" maxlength="128" />
          </v-col>
          <v-col cols="12" md="6">
            <v-text-field v-model="form.lastname" :label="$t('Last name')" maxlength="128" />
          </v-col>
          <v-col cols="12" md="6">
            <v-combobox v-model="form.roles" :items="roles" :label="$t('Roles')" multiple chips closable-chips />
          </v-col>
          <v-col cols="12" md="6">
            <v-text-field v-model="form.expires_at" :label="$t('Expiration')" type="datetime-local" />
          </v-col>
          <v-col cols="12" md="6">
            <v-combobox v-model="form.affiliation" :label="$t('Affiliations')" multiple chips closable-chips />
          </v-col>
          <v-col cols="12" md="6">
           <v-autocomplete
             v-model="form.org_units"
             :items="orgUnitOptions"
             :label="$t('Organisation units')"
             multiple
             chips
             closable-chips
           />
          </v-col>
          <v-col cols="12" md="6">
            <v-text-field
              v-model="form.password"
              :label="$t('Password (leave empty to keep unchanged)')"
              type="password"
              autocomplete="new-password"
              hint="Minimum 12 characters and at least 3 character types"
              persistent-hint
            />
          </v-col>
          <v-col cols="12">
            <v-checkbox v-model="form.active" :label="$t('Active')" />
          </v-col>
        </v-row>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="outlined" @click="editDialog = false">{{ $t('Cancel') }}</v-btn>
        <v-btn color="primary" :loading="saving" :disabled="!form.username" @click="saveUser">{{ $t('Save') }}</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <v-dialog v-model="deleteDialog" max-width="500">
    <v-card>
      <v-card-title class="text-title-large font-weight-light text-white">{{ $t('Delete user') }}</v-card-title>
      <v-card-text class="pt-6">
        {{ $t('Delete user {username}?', { username: selectedUser?.username }) }}
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="outlined" @click="deleteDialog = false">{{ $t('Cancel') }}</v-btn>
        <v-btn color="btnred" :loading="saving" @click="deleteUser">{{ $t('Delete') }}</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import { useRootStore } from '~/stores/root'
import { useVocabularyStore } from 'phaidra-vue-components/src/stores/vocabulary'

const emptyUser = () => ({
  username: '',
  firstname: '',
  lastname: '',
  email: '',
  affiliation: [],
  org_units: [],
  roles: [],
  active: true,
  expires_at: '',
  password: ''
})

export default {
  name: 'AdminUsers',
  data() {
    return {
      users: [],
      roles: [],
      orgUnits: [],
      search: '',
      loading: false,
      saving: false,
      creating: false,
      editDialog: false,
      deleteDialog: false,
      selectedUser: null,
      form: emptyUser()
    }
  },
  computed: {
    headers() {
      return [
        { title: this.$t('Username'), key: 'username' },
        { title: this.$t('Name'), key: 'name' },
        { title: this.$t('Email'), key: 'email' },
        { title: this.$t('Roles'), key: 'roles', sortable: false },
        { title: this.$t('Status'), key: 'active' },
        { title: this.$t('Password'), key: 'password_set' },
        { title: this.$t('Last login'), key: 'last_login_at' },
        { title: this.$t('Expiration'), key: 'expires_at' },
        { title: this.$t('Actions'), key: 'actions', sortable: false }
      ]
    },
    token() {
      return useRootStore().user.token
    },
    orgUnitOptions() {
      const locale = this.$i18n.locale
      const vocabulary = useVocabularyStore()
      return vocabulary.vocabularies.orgunits.terms.map((unit) => {
        const notation = unit['skos:notation']
        const labels = unit['skos:prefLabel'] || {}
        const label = labels[locale] || labels.eng || Object.values(labels)[0] || notation
        return { title: `${label} (${notation})`, value: unit['@id'] }
      })
    }
  },
  mounted() {
    this.loadUsers()
    this.loadOrgUnits()
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
    async loadOrgUnits() {
      await useVocabularyStore().loadOrgUnits(this.$i18n.locale)
    },
    async loadUsers() {
      this.loading = true
      try {
        const response = await this.request({ method: 'GET', url: '/admin/users' })
        this.users = response.data.users || []
        this.roles = response.data.roles || []
        if (!this.roles.length) {
          try {
            const roleResponse = await this.request({ method: 'GET', url: '/admin/users/roles' })
            this.roles = roleResponse.data.roles || []
          } catch (_) { }
        }
        this.alerts(response)
      } catch (error) {
        this.errorAlert(error)
      } finally {
        this.loading = false
      }
    },
    openCreate() {
      this.creating = true
      this.form = emptyUser()
      this.editDialog = true
    },
    openEdit(user) {
      this.creating = false
      this.form = {
        ...emptyUser(),
        ...user,
        affiliation: [...(user.affiliation || [])],
        org_units: [...(user.org_units || [])],
        roles: [...(user.roles || [])],
        expires_at: user.expires_at ? user.expires_at.replace(' ', 'T').slice(0, 16) : '',
        password: ''
      }
      this.editDialog = true
    },
    async saveUser() {
      this.saving = true
      try {
        const data = { ...this.form, expires_at: this.form.expires_at || null }
        if (!data.password) delete data.password
        const response = await this.request({
          method: 'POST',
          url: this.creating ? '/admin/users' : '/admin/users/' + encodeURIComponent(this.form.username),
          data
        })
        this.alerts(response)
        this.editDialog = false
        await this.loadUsers()
      } catch (error) {
        this.errorAlert(error)
      } finally {
        this.saving = false
      }
    },
    confirmDelete(user) {
      this.selectedUser = user
      this.deleteDialog = true
    },
    async deleteUser() {
      this.saving = true
      try {
        const response = await this.request({ method: 'POST', url: '/admin/users/' + encodeURIComponent(this.selectedUser.username) + '/delete' })
        this.alerts(response)
        this.deleteDialog = false
        await this.loadUsers()
      } catch (error) {
        this.errorAlert(error)
      } finally {
        this.saving = false
      }
    },
    async sendReset(user) {
      try {
        const response = await this.request({ method: 'POST', url: '/admin/users/' + encodeURIComponent(user.username) + '/password-reset' })
        this.alerts(response)
      } catch (error) {
        this.errorAlert(error)
      }
    }
  }
}
</script>
