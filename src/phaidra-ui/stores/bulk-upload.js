import { defineStore } from 'pinia'
import { fieldSettings } from '../config/bulk-upload/field-settings'
import { parseCsv } from '../mixins/csvParser'

export const useBulkUploadStore = defineStore('bulk-upload', {
  state: () => ({
    currentStep: 1,
    maxStepReached: 1,
    steps: {
      1: { route: '/bulk-upload/csv-config', completed: false },
      2: { route: '/bulk-upload/meta-data-config', completed: false },
      3: { route: '/bulk-upload/preview', completed: false },
      4: { route: '/bulk-upload/upload', completed: false }
    },
    csvContent: null,
    fileName: '',
    fieldMappings: {},
    uploadState: {},
    uploadProgress: {
      total: 0,
      completed: 0,
      failed: 0
    }
  }),
  getters: {
    singleFields: () => {
      return Object.keys(fieldSettings).filter(field => fieldSettings[field].fieldType === 'single-field')
    },
    multiFields: () => {
      return Object.keys(fieldSettings).filter(field => fieldSettings[field].fieldType === 'multi-field')
    },
    allFields: () => {
      return Object.keys(fieldSettings)
    },
    requiredFields: () => {
      return Object.keys(fieldSettings).filter(field => fieldSettings[field].required)
    },
    canAccessStep: (state) => (step) => {
      return true
    },
    getColumnHeaders: (state) => {
      if (!state.csvContent) return []
      const parsed = parseCsv(state.csvContent)
      if (!parsed || !parsed.data || parsed.data.length === 0) return []
      return parsed.data[0].map(v => v.trim())
    },
    getCurrentStepFromRoute: (state) => (route) => {
      for (const [stepNum, stepData] of Object.entries(state.steps)) {
        if (stepData.route === route) {
          return parseInt(stepNum)
        }
      }
      return 1
    },
    getFieldMapping: (state) => (field, subField) => {
      if (subField) {
        return state.fieldMappings[field]?.subFields?.[subField]
      } else {
        return state.fieldMappings[field]
      }
    },
    getAllFieldMappings: (state) => {
      return state.fieldMappings
    },
    getUploadState: (state) => (rowIndex) => {
      return state.uploadState[rowIndex] || { status: 'pending', pid: null, error: null }
    },
    getUploadProgress: (state) => {
      return state.uploadProgress
    },
    isUploadComplete: (state) => {
      return state.uploadProgress.completed === state.uploadProgress.total
    }
  },
  actions: {
    initializeState (savedState) {
      Object.assign(this, savedState)
    },
    setCurrentStep (step) {
      this.currentStep = step
      if (step > this.maxStepReached) {
        this.maxStepReached = step
      }
    },
    completeStep (step) {
      if (this.steps[step]) {
        this.steps[step].completed = true
      }
    },
    setCsvContent (content) {
      this.csvContent = content
    },
    setFileName (fileName) {
      this.fileName = fileName
    },
    setFieldMapping ({ field, source, csvValue, phaidraValue, subField }) {
      if (!source) {
        this.fieldMappings = {
          ...this.fieldMappings,
          [field]: null
        }
      } else {
        const existingMapping = this.fieldMappings[field] || {}
        const isMultiField = fieldSettings[field]?.fieldType === 'multi-field'

        if (isMultiField) {
          this.fieldMappings = {
            ...this.fieldMappings,
            [field]: {
              source,
              subFields: {
                ...(existingMapping.subFields || {}),
                [subField]: {
                  csvValue: csvValue !== undefined ? csvValue : existingMapping.subFields?.[subField]?.csvValue || null,
                  phaidraValue: phaidraValue !== undefined ? phaidraValue : existingMapping.subFields?.[subField]?.phaidraValue || null
                }
              }
            }
          }
        } else {
          if (phaidraValue && Object.keys(phaidraValue).includes('value') && !phaidraValue.value) {
            delete this.fieldMappings[field]
          } else {
            this.fieldMappings = {
              ...this.fieldMappings,
              [field]: {
                source,
                csvValue: csvValue !== undefined ? csvValue : existingMapping.csvValue || null,
                phaidraValue: phaidraValue !== undefined ? phaidraValue : existingMapping.phaidraValue || null
              }
            }
          }
        }
      }
    },
    clearFieldMappings () {
      this.fieldMappings = {}
    },
    setUploadState ({ rowIndex, status, pid, error }) {
      this.uploadState = {
        ...this.uploadState,
        [rowIndex]: { status, pid, error }
      }
    },
    setUploadProgress ({ total, completed, failed }) {
      this.uploadProgress = { total, completed, failed }
    },
    clearUploadState () {
      this.uploadState = {}
      this.uploadProgress = {
        total: 0,
        completed: 0,
        failed: 0
      }
    },
    resetSteps () {
      for (const step in this.steps) {
        this.steps[step].completed = false
      }
      this.maxStepReached = 1
      this.currentStep = 1
    },
    hardResetState () {
      this.currentStep = 1
      this.maxStepReached = 1
      this.steps = {
        1: { route: '/bulk-upload/csv-config', completed: false },
        2: { route: '/bulk-upload/meta-data-config', completed: false },
        3: { route: '/bulk-upload/preview', completed: false },
        4: { route: '/bulk-upload/upload', completed: false }
      }
      this.csvContent = null
      this.fileName = ''
      this.fieldMappings = {}
      this.uploadState = {}
      this.uploadProgress = {
        total: 0,
        completed: 0,
        failed: 0
      }
    }
  }
})

export default useBulkUploadStore
