let initializePromise = null

export default ({ store }) => {
  // Only run on client-side
  if (process.client) {
    // Create an initialization function that returns a promise
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

    // Store the initialization promise so it can be awaited
    initializePromise = initialize()

    // Add the initialization promise to the store
    store.$initBulkUpload = () => initializePromise

    // Subscribe to store mutations
    store.subscribe((mutation, state) => {
      if (mutation.type.startsWith('bulk-upload/')) {
        localStorage.setItem('bulkUploadState', JSON.stringify(state['bulk-upload']))
      }
    })
  }
} 