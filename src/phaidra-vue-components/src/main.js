import { createApp } from 'vue'
import axios from 'axios'
import App from './App.vue'
import './styles/vuetify2-compat.css'
import router from './router'
import store, { setStoreAxios } from './store'
import vuetify from './plugins/vuetify'
import { registerFormatters } from './utils/formatters'
import { RouterLink } from 'vue-router'

const app = createApp(App)

registerFormatters(app)

const axiosInstance = axios.create({
  withCredentials: true
})

app.config.globalProperties.$axios = axiosInstance
setStoreAxios(axiosInstance)

app.use(store)
app.use(router)
app.use(vuetify)
app.component('RouterLink', RouterLink)
app.provide('phaidraLink', RouterLink)
app.provide('phaidraLocalePath', (path) => path)

app.mount('#app')
