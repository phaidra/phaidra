import { useRootStore } from '~/stores/root'
import { useBulkUploadStore } from '~/stores/bulk-upload'

export default defineNuxtRouteMiddleware(async (to) => {
  const { $pinia, $initBulkUpload } = useNuxtApp()
  const root = useRootStore($pinia)
  const bulk = useBulkUploadStore($pinia)

  if (!root.user?.token) {
    if (import.meta.client) {
      localStorage.setItem('redirect', to.fullPath)
    }
    return navigateTo('/login')
  }

  // Wait for store initialization on client side
  if (import.meta.client && $initBulkUpload) {
    await $initBulkUpload()
  }

  const currentStep = bulk.getCurrentStepFromRoute(to.path)
  if (!bulk.canAccessStep(currentStep)) {
    const allowedRoute = bulk.steps?.[bulk.maxStepReached]?.route
    if (allowedRoute) {
      return navigateTo(allowedRoute)
    }
  }
})
