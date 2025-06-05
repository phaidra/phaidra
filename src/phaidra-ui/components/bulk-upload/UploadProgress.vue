<template>
  <v-card tile>
    <v-card-text>
      <div class="d-flex align-center justify-space-between mb-2">
        <div>
          <span class="text-h6">Upload Progress</span>
        </div>
        <div class="d-flex align-center">
          <v-chip class="mr-2" color="success" outlined>
            {{ progress.completed }} Completed
          </v-chip>
          <v-chip class="mr-2" color="error" outlined>
            {{ progress.failed }} Failed
          </v-chip>
          <v-chip color="primary" outlined>
            {{ progress.total - progress.completed }} Remaining
          </v-chip>
        </div>
      </div>
      <v-progress-linear
        :value="(progress.completed) / Math.max(1, progress.total) * 100"
        height="20"
        color="primary"
        striped
      >
        <template v-slot:default>
          {{ Math.round((progress.completed) / Math.max(1, progress.total) * 100) }}%
        </template>
      </v-progress-linear>
    </v-card-text>
  </v-card>
</template>

<script>
export default {
  name: 'UploadProgress',
  props: {
    progress: {
      type: Object,
      required: true,
      validator: (value) => {
        return 'total' in value && 'completed' in value && 'failed' in value
      }
    }
  }
}
</script> 