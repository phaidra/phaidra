export default async function ({ store, redirect, route }) {
  // Wait for store initialization on client side
  if (process.client && store.$initBulkUpload) {
    await store.$initBulkUpload()
  }

  const currentStep = store.getters['bulk-upload/getCurrentStepFromRoute'](route.path)
  if (!store.getters['bulk-upload/canAccessStep'](currentStep)) {
    // If user can't access this step, redirect to the last allowed step
    const maxStep = store.state['bulk-upload'].maxStepReached
    const allowedRoute = store.state['bulk-upload'].steps[maxStep].route
    return redirect(allowedRoute)
  }
} 