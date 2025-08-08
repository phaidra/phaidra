<!-- file to redirect the user to the last visited bulk upload step -->

<template>
  <div class="redirect-container">
    <h1 class="text-h4 mb-6">{{$t('Bulk Upload')}} </h1>
    <div class="loader"></div>
    <div class="redirect-text">{{$t('Loading local storage...')}}</div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import BulkUploadSteps from '../../components/BulkUploadSteps.vue'

export default {
  name: 'BulkUploadIndex',

  components: {
    BulkUploadSteps
  },

  computed: {
    ...mapState('bulk-upload', ['currentStep', 'steps'])
  },

  mounted() {
    if (process.client) {
      this.handleRedirect()
    }
  },

  methods: {
    handleRedirect() {
      // we set a timeout for better user experience
      setTimeout(() => {
        if (!this.currentStep) {
          return this.steps[1].route
        }

        let redirectStep = this.currentStep || 1

        if (this.steps) {
          this.$router.push(this.steps[redirectStep].route)
        } else {
          this.$router.push('/bulk-upload/csv-config')
        }
      }, 1200)
    }
  },
}
</script>

<style scoped>
.redirect-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 50vh;
  gap: 1rem;
}

.redirect-text {
  color: #666;
  font-size: 1.2rem;
}

.loader {
  width: 48px;
  height: 48px;
  border: 5px solid #f3f3f3;
  border-radius: 50%;
  border-top: 5px solid #3498db;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>