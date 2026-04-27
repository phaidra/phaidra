let initializePromise = null

export default defineNuxtPlugin((nuxtApp) => {
  const store = nuxtApp.$store
  if (!process.client || !store) return

  const initialize = async () => {
    try {
      const savedState = localStorage.getItem('bulkUploadState')
      if (savedState) {
        const parsedState = JSON.parse(savedState)
        store.commit('bulk-upload/initializeState', parsedState)
      }
    } catch (error) {
      console.error('Error initializing bulk upload state:', error)
    }
  }

  initializePromise = initialize()
  store.$initBulkUpload = () => initializePromise

  store.subscribe((mutation, state) => {
    if (mutation.type.startsWith('bulk-upload/')) {
      localStorage.setItem('bulkUploadState', JSON.stringify(state['bulk-upload']))
    }
  })
})
