import axios from 'axios'

export default defineNuxtPlugin((nuxtApp) => {
  const runtime = useRuntimeConfig()
  const baseURL = import.meta.server
    ? (runtime.apiBaseURL || runtime.public.apiBaseURL || '')
    : (runtime.public.apiBaseURL || runtime.public?.axios?.browserBaseURL || '')

  const instance = axios.create({
    baseURL: baseURL || undefined,
    timeout: 0
  })

  const errorHandlers = []
  instance.onError = (fn) => {
    errorHandlers.push(fn)
  }

  if (instance?.interceptors?.response?.use) {
    instance.interceptors.response.use(
      (response) => response,
      (error) => {
        for (const fn of errorHandlers) {
          try {
            fn(error)
          } catch (_) {}
        }
        return Promise.reject(error)
      }
    )
  }

  nuxtApp.vueApp.config.globalProperties.$axios = instance
  nuxtApp.$axios = instance

  nuxtApp.provide('axios', instance)

  const sentry = nuxtApp.$sentry
  const store = nuxtApp.$store

  instance.onError((error) => {
    if (sentry?.captureException) {
      sentry.captureException(error)
    }
    if (store && error?.response?.data?.alerts?.length > 0) {
      if (error.response?.status !== 403) {
        store.commit('setAlerts', error.response.data.alerts)
      }
    }
  })
})
