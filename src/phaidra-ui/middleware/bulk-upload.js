export default defineNuxtRouteMiddleware(async (to) => {
  const { $store: store } = useNuxtApp()
  if (!store) return

  if (!store.state?.user?.token) {
    if (import.meta.client) {
      localStorage.setItem('redirect', to.fullPath)
    }
    return navigateTo('/login')
  }

  // Wait for store initialization on client side
  if (import.meta.client && store.$initBulkUpload) {
    await store.$initBulkUpload()
  }

  const getCurrentStep = store.getters['bulk-upload/getCurrentStepFromRoute']
  const canAccessStep = store.getters['bulk-upload/canAccessStep']
  if (typeof getCurrentStep !== 'function' || typeof canAccessStep !== 'function') return

  const currentStep = getCurrentStep(to.path)
  if (!canAccessStep(currentStep)) {
    // If user can't access this step, redirect to the last allowed step.
    const maxStep = store.state['bulk-upload']?.maxStepReached
    const allowedRoute = store.state['bulk-upload']?.steps?.[maxStep]?.route
    if (allowedRoute) {
      return navigateTo(allowedRoute)
    }
  }
})