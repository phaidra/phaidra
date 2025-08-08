<template>
  <v-app>
    <v-app-bar app>
      <!-- Your app bar content -->
    </v-app-bar>

    <v-main>
      <v-container fluid>
        <div class="bulk-upload-layout">
          <BulkUploadSteps />
          <div class="content">
            <Nuxt />
          </div>
        </div>
      </v-container>
    </v-main>

    <v-footer app>
      <!-- Your footer content -->
    </v-footer>
  </v-app>
</template>

<script>
import BulkUploadSteps from '../components/BulkUploadSteps.vue'

export default {
  name: 'BulkUploadLayout',
  components: {
    BulkUploadSteps
  }
}
</script>

<style scoped>
.bulk-upload-layout {
  padding: 20px;
}

.content {
  /* max-width: 1200px; */
  margin: 0 auto;
}
</style>