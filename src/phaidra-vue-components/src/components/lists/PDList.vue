<template>
  <v-container fluid>
    <v-row no-gutters v-if="list">
      <v-col cols="12">
        <v-card>
          <v-card-title class="title font-weight-light grey white--text">
            {{ list.name }}
          </v-card-title>
          <v-card-text>
            <v-data-table
              hide-default-header
              :headers="membersHeaders"
              :items="list.members"
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
                <!-- <v-toolbar flat>
                  <v-text-field
                    v-model="membersSearch"
                    append-icon="mdi-magnify"
                    :label="$t('Search...')"
                    single-line
                    hide-details
                  ></v-text-field>
                </v-toolbar> -->
              </template>
              <template v-slot:item.pid="{ item }">
                <router-link :to="{ path: `detail/${item.pid}`, params: { pid: item.pid } }">{{ item.pid }}</router-link>
              </template>
              <template v-slot:item.title="{ item }">
                {{ item.title | truncate(100) }}
              </template>
            </v-data-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  name: 'p-d-list',
  props: {
    list: {
      type: Object
    }
  },
  data () {
    return {
      membersLoading: false,
      membersSearch: '',
      membersHeaders: [
        { text: 'PID', align: 'left', value: 'pid' },
        { text: 'Title', align: 'left', value: 'title' },
        { text: 'Actions', align: 'right', value: 'actions', sortable: false }
      ],
      token: ''
    }
  }
}
</script>
