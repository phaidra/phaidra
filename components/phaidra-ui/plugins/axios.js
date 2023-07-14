export default function ({ store, $axios, $sentry }) {
  $axios.onRequest(config => {
    console.log('axios ' + config.method.toUpperCase() + ' ' + config.baseURL + $axios.getUri(config))
  })

  $axios.onError(error => {
    $sentry.captureException(error)
    if (error.response?.data?.alerts?.length > 0) {
      store.commit('setAlerts', error.response.data.alerts)
    }
    return Promise.reject(error)
  })
}
