import Vue from 'vue'
import axios from 'axios'
import VueAxios from 'vue-axios'

export default ({ app, $sentry }) => {
  axios.interceptors.response.use(
    async response => {
      return response
    },
    error => {
      $sentry.captureException(error)
      if (error.response?.data?.alerts?.length > 0) {
        app.store.commit('setAlerts', error.response.data.alerts)
      }
      return Promise.reject(error)
    }
  )
}

Vue.use(VueAxios, axios)
