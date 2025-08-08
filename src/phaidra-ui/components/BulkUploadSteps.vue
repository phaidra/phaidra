<template>
  <v-card flat class="bulk-upload-steps transparent">
    <h1 class="text-h4 mb-6">{{$t('Bulk Upload')}}</h1>
    <v-stepper v-model="currentStepModel" class="steps-container">
      <v-stepper-header>
        <template v-for="(step, index) in steps">
          <v-stepper-step
            :key="`step-${index}`"
            :complete="$store.state['bulk-upload'].currentStep > index + 1"
            :step="index + 1"
            :rules="[() => true]"
          >
            {{ step.label }}
          </v-stepper-step>

          <v-divider
            v-if="index < steps.length - 1"
            :key="`divider-${index}`"
          ></v-divider>
        </template>
      </v-stepper-header>
    </v-stepper>
  </v-card>
</template>

<script>
export default {
  name: 'BulkUploadSteps',
  data() {
    return {
      steps: []
    }
  },
  computed: {
    currentStepModel: {
      get() {
        return this.$store.state['bulk-upload'].currentStep
      },
      set(value) {
        this.$store.commit('bulk-upload/setCurrentStep', value)
      }
    }
  },
  watch: {
    '$route': {
      immediate: true,
      handler(newRoute) {
        const currentStep = this.$store.getters['bulk-upload/getCurrentStepFromRoute'](newRoute.path)
        this.$store.commit('bulk-upload/setCurrentStep', currentStep)
      }
    },
    '$i18n.locale': {
      immediate: true,
      handler() {
        this.steps = [
          { label: this.$t('Load CSV'), route: '/bulk-upload/csv-config' },
          { label: this.$t('Select Mapping'), route: '/bulk-upload/meta-data-config' },
          { label: this.$t('Preview'), route: '/bulk-upload/preview' },
          { label: this.$t('Upload'), route: '/bulk-upload/upload' }
        ]
      }
    }
  }
}
</script>

<style scoped>
.bulk-upload-steps {
  margin: 30px 0;
}

.text-h4 {
  font-weight: 500;
}
</style> 