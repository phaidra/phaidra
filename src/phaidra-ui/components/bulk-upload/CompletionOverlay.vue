<template>
  <v-overlay :value="isUploadComplete" absolute>
    <v-card class="pa-6 text-center" light>
      <v-icon size="64" color="success" class="mb-4">mdi-check-circle</v-icon>
      <h2 class="text-h5 mb-4">{{$t('Bulk Upload Complete!')}}</h2>
      <p class="mb-4">
        {{$t('All files have been successfully uploaded to PHAIDRA.')}}
      </p>
      <v-btn
        color="success"
        large
        @click="startNewBulkUpload"
      >
        {{$t('Start New Bulk Upload')}}
      </v-btn>
    </v-card>
  </v-overlay>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'

export default {
  name: 'CompletionOverlay',
  computed: {
    ...mapGetters('bulk-upload', ['isUploadComplete']),
  },
  methods: {
    ...mapMutations('bulk-upload', ['hardResetState']),
    async startNewBulkUpload() {
      try {
        // Reset all bulk upload data including localStorage
        this.hardResetState()
        
        // Redirect to the first step
        this.$router.push('/bulk-upload/csv-config')
      } catch (error) {
        console.error(this.$t('Error starting new bulk upload:'), error)
      }
    }
  }
}
</script> 