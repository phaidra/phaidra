import { useBulkUploadStore } from '~/stores/bulk-upload'

let initializePromise = null

export default defineNuxtPlugin((nuxtApp) => {
  if (!import.meta.client) return

  const bulk = useBulkUploadStore(nuxtApp.$pinia)

  const initialize = async () => {
    try {
      const savedState = localStorage.getItem('bulkUploadState')
      if (savedState) {
        const parsedState = JSON.parse(savedState)
        bulk.initializeState(parsedState)
      }
    } catch (error) {
      console.error('Error initializing bulk upload state:', error)
    }
  }

  initializePromise = initialize()
  nuxtApp.provide('initBulkUpload', () => initializePromise)

  bulk.$subscribe((_mutation, state) => {
    localStorage.setItem('bulkUploadState', JSON.stringify(state))
  })
})
