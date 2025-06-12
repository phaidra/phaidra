<template>
  <v-card tile>
    <v-card-text>
      <v-data-table
        :headers="headers"
        :items="tableData"
        :items-per-page="10"
        class="elevation-1"
      >
        <template v-slot:item.status="{ item }">
          <v-chip
            :color="getStatusColor(item.status)"
            small
          >
            {{ item.status }}
          </v-chip>
        </template>

        <template v-slot:item.actions="{ item }">
          <template v-if="item.status === 'error'">
            <v-tooltip bottom>
              <template v-slot:activator="{ on, attrs }">
                <v-btn
                  icon
                  small
                  color="error"
                  v-bind="attrs"
                  v-on="on"
                  @click="$emit('show-error', item)"
                >
                  <v-icon small>mdi-alert-circle</v-icon>
                </v-btn>
              </template>
              <span>View Error</span>
            </v-tooltip>
            <v-btn
              icon
              small
              class="ml-2"
              @click="$emit('retry-upload', item.index)"
            >
              <v-icon small>mdi-refresh</v-icon>
            </v-btn>
          </template>
          <template v-else-if="item.status === 'completed'">
            <v-btn
              icon
              small
              :href="getObjectUrl(item.pid)"
              target="_blank"
            >
              <v-icon small>mdi-open-in-new</v-icon>
            </v-btn>
          </template>
        </template>
      </v-data-table>
    </v-card-text>
  </v-card>
</template>

<script>
export default {
  name: 'UploadTable',
  props: {
    tableData: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      headers: [
        { text: 'Row', value: 'index' },
        { text: 'Title', value: 'title' },
        { text: 'Filename', value: 'filename' },
        { text: 'Status', value: 'status' },
        { text: 'Actions', value: 'actions', sortable: false }
      ]
    }
  },
  methods: {
    getStatusColor(status) {
      switch (status) {
        case 'completed': return 'success'
        case 'error': return 'error'
        case 'uploading': return 'primary'
        default: return 'grey'
      }
    },
    getObjectUrl(pid) {
      return pid ? `http://localhost:8899/${pid}` : '#'
    }
  }
}
</script> 