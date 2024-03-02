export default function ({ store, $axios, $sentry }) {

  $axios.onError(error => {
    $sentry.captureException(error)
    if (error.response?.data?.alerts?.length > 0) {
      if (error.response?.status !== 403) {
        store.commit('setAlerts', error.response.data.alerts)
      }
    }
    return Promise.reject(error)
  })
}
