import { fieldSettings } from '../config/bulk-upload/field-settings'

export const state = () => ({
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
  // Will store mappings like 
  // single-field: { field: { source: 'csv-column|phaidra-field', csvValue: string, phaidraValue: object } }
  // multi-field: { field: { source: 'csv-column|phaidra-field', subFields: { subField: { csvValue: string, phaidraValue: object } } } }
  //
  // Examples:
  //
  // single-field:
  //   "Description": {
  //     "source": "csv-column",
  //     "csvValue": "Description",
  //     "phaidraValue": null
  //   },
  //
  // multi-field:
  //   "Role": {
  //     "source": "csv-column",
  //     "subFields": {
  //       "Role": {
  //         "csvValue": "Role",
  //         "phaidraValue": null
  //       },
  //       "First name": {
  //         "csvValue": "First name",
  //         "phaidraValue": null
  //       }
  //     }
  //   }
  fieldMappings: {}, 
  uploadState: {}, // Will store upload state for each row { rowIndex: { status: 'pending|uploading|completed|error', pid: null, error: null } }
  uploadProgress: {
    total: 0,
    completed: 0,
    failed: 0
  }
})

export const mutations = {
  initializeState(state, savedState) {
    Object.assign(state, savedState)
  },
  setCurrentStep(state, step) {
    state.currentStep = step
    if (step > state.maxStepReached) {
      state.maxStepReached = step
    }
  },
  completeStep(state, step) {
    if (state.steps[step]) {
      state.steps[step].completed = true
    }
  },
  setCsvContent(state, content) {
    state.csvContent = content
  },
  setFileName(state, fileName) {
    state.fileName = fileName
  },
  setFieldMapping(state, { field, source, csvValue, phaidraValue, subField }) {
    if (!source) {
      state.fieldMappings = {
        ...state.fieldMappings,
        [field]: null
      }
    } else {
      const existingMapping = state.fieldMappings[field] || {}
      const isMultiField = fieldSettings[field]?.fieldType === 'multi-field'

      if (isMultiField) {
        // Handle multi-field mapping
        state.fieldMappings = {
          ...state.fieldMappings,
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
        // Handle single-field mapping
        state.fieldMappings = {
          ...state.fieldMappings,
          [field]: {
            source,
            csvValue: csvValue !== undefined ? csvValue : existingMapping.csvValue || null,
            phaidraValue: phaidraValue !== undefined ? phaidraValue : existingMapping.phaidraValue || null
          }
        }
      }
    }
  },
  clearFieldMappings(state) {
    state.fieldMappings = {}
  },
  setUploadState(state, { rowIndex, status, pid, error }) {
    state.uploadState = {
      ...state.uploadState,
      [rowIndex]: { status, pid, error }
    }
  },
  setUploadProgress(state, { total, completed, failed }) {
    state.uploadProgress = { total, completed, failed }
  },
  clearUploadState(state) {
    state.uploadState = {}
    state.uploadProgress = {
      total: 0,
      completed: 0,
      failed: 0
    }
  },
  resetSteps(state) {
    for (const step in state.steps) {
      state.steps[step].completed = false
    }
    state.maxStepReached = 1
    state.currentStep = 1
  },
  hardResetState(state) {
    // Reset to initial state
    state.currentStep = 1
    state.maxStepReached = 1
    state.steps = {
      1: { route: '/bulk-upload/csv-config', completed: false },
      2: { route: '/bulk-upload/meta-data-config', completed: false },
      3: { route: '/bulk-upload/preview', completed: false },
      4: { route: '/bulk-upload/upload', completed: false }
    }
    state.csvContent = null
    state.fileName = ''
    state.fieldMappings = {}
    state.uploadState = {}
    state.uploadProgress = {
      total: 0,
      completed: 0,
      failed: 0
    }
  }
}

export const getters = {
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
    // TODO: define logic for each step later
    return true
  },
  getColumnHeaders: (state) => {
    if (!state.csvContent) return []
    return state.csvContent.split('\n')[0].split(';').map(v => v.trim().replace(/["']/g, ''))
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
} 