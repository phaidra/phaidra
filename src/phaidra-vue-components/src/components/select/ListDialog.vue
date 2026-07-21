<template>
  <v-dialog v-model="dialog" width="700px">
    <v-card>
      <v-card-title class="text-h6 font-weight-light text-white">{{ $t('Select a list') }}</v-card-title>
      <v-card-text class="mt-4">
        <!-- <v-text-field
          v-model="listsSearch"
          append-inner-icon="mdi-magnify"
          :label="$t('Search...')"
          single-line
          hide-details
          class="mb-4"
        ></v-text-field> -->
        <v-data-table
          hide-default-header
          :headers="listsHeaders"
          :items="lists"
          :search="listsSearch"
          :loading="loading"
          :loading-text="$t('Loading...')"
          :items-per-page="5"
          :no-data-text="$t('No data available')"
          :no-results-text="$t('There were no search results')"
        >
          <template v-slot:item.name="{ item }">
            <v-tooltip location="bottom">
              <template v-slot:activator="{ props: activatorProps }">
                <span v-bind="activatorProps">{{ $truncate(item.name, 50) }}</span>
              </template>
              <span>{{ item.listid }}</span>
            </v-tooltip>
          </template>
          <template v-slot:item.created="{ item }">
            {{ $unixtime(item.created) }}
          </template>
          <template v-slot:item.updated="{ item }">
            {{ $unixtime(item.updated) }}
          </template>
          <template v-slot:item.actions="{ item }">
            <v-btn variant="text" color="primary" @click="selectList(item)">{{ $t('Select') }}</v-btn>
          </template>
        </v-data-table>
      </v-card-text>
      <v-divider></v-divider>
      <v-card-actions>
        <v-container fluid>
          <v-row justify="end" class="px-4">
            <v-btn variant="outlined" @click="dialog = false">{{ $t('Cancel') }}</v-btn>
          </v-row>
        </v-container>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  name: 'list-dialog',
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    }
  },
  data () {
    return {
      dialog: false,
      loading: false,
      listsSearch: '',
      listsHeaders: [
        { title: 'Name', align: 'start', key: 'name' },
        { title: 'Created', align: 'end', key: 'created' },
        { title: 'Updated', align: 'end', key: 'updated' },
        { title: 'Actions', align: 'end', key: 'actions', sortable: false }
      ],
      lists: []
    }
  },
  methods: {
    open: async function () {
      this.dialog = true
      this.loading = true
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/lists',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        this.lists = response.data.lists
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
      }
    },
    selectList: function (item) {
      this.$emit('list-selected', item)
      this.dialog = false
    }
  }
}
</script>
