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
            size="small"
          >
            {{ $t(item.status) }}
          </v-chip>
        </template>

        <template v-slot:item.actions="{ item }">
          <template v-if="item.status === 'error'">
            <v-tooltip location="bottom">
              <template v-slot:activator="{ props: tipProps }">
                <v-icon-btn size="small"
                  color="error"
                  v-bind="tipProps"
                  @click="$emit('show-error', item)" icon="mdi-alert-circle" />
              </template>
              <span>{{$t('View Error')}}</span>
            </v-tooltip>
            <v-icon-btn size="small"
              class="ml-2"
              @click="$emit('retry-upload', item.index)" icon="mdi-refresh" />
          </template>
          <template v-else-if="item.status === 'completed'">
            <a :href="getObjectUrl(item.pid)" target="_blank" rel="noopener noreferrer" class="text-decoration-none">
              <v-icon-btn size="small" icon="mdi-open-in-new" />
            </a>
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
        { title: this.$t('Row'), key: 'index' },
        { title: this.$t('Title'), key: 'title' },
        { title: this.$t('Filename'), key: 'filename' },
        { title: this.$t('Status'), key: 'status' },
        { title: this.$t('Actions'), key: 'actions', sortable: false }
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
      return pid ? `/${pid}` : '#'
    }
  }
}
</script> 