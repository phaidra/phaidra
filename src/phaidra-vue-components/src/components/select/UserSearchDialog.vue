<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card>
      <v-card-title class="grey white--text">{{ $t('Select a user') }}</v-card-title>
      <v-card-text>
        <v-text-field
          v-model="userSearchInp"
          append-icon="mdi-magnify"
          :label="$t('Search...')"
          single-line
          hide-details
          class="mb-4"
        ></v-text-field>
        <v-data-table
          hide-default-header
          :headers="usersHeaders"
          :items="users"
          :search="userSearchInp"
          :loading="loading"
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
          <template v-slot:item.actions="{ item }">
            <v-btn text color="primary" @click="selectUser(item)">{{ $t('Select') }}</v-btn>
          </template>
        </v-data-table>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-actions>
        <v-container fluid>
          <v-row justify="end" class="px-4">
            <v-btn color="grey" dark @click="dialog = false">{{ $t('Cancel') }}</v-btn>
          </v-row>
        </v-container>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import qs from 'qs'

export default {
  name: 'user-search-dialog',
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      dialog: false,
      loading: false,
      userSearchInp: '',
      usersHeaders: [
        { text: 'Username', align: 'left', value: 'username' },
        { text: 'Actions', align: 'right', value: 'actions', sortable: false }
      ],
      users: []
    }
  },
  watch: {
    userSearchInp(val) {
      // console.log('userSearchInp', val)
      this.fetchUser()
    }
  },
  methods: {
    fetchUser: async function() {
      if(!this.userSearchInp) {
        this.users = []
        return
      }
      this.loading = true
      try {
        let response = await this.$axios.request({
          method: 'get',
          url: `/users/search?q=${this.userSearchInp}`,
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        console.log('user response', response)
        this.users = response.data.users
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    open: async function () {
      this.dialog = true
      this.fetchUser()
    },
    selectUser: function (item) {
      this.$emit('user-selected', item)
      this.dialog = false
    }
  }
}
</script>
