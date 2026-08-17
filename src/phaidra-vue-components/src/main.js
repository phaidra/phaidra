import { createApp } from 'vue'
import { createPinia } from 'pinia'
import axios from 'axios'
import App from './App.vue'
import './styles/vuetify2-compat.css'
import router from './router'
import { useRootStore } from './stores/root'
import { useVocabularyStore } from './stores/vocabulary'
import { useSearchStore } from './stores/search'
import { useInfoStore } from './stores/info'
import vuetify from './plugins/vuetify'
import { registerFormatters } from './utils/formatters'
import { RouterLink } from 'vue-router'

const app = createApp(App)

registerFormatters(app)

const axiosInstance = axios.create({
  withCredentials: true
})

app.config.globalProperties.$axios = axiosInstance

const pinia = createPinia()
pinia.use(({ store }) => {
  store.$axios = axiosInstance
})
app.use(pinia)

// Register stores
useRootStore(pinia)
useVocabularyStore(pinia)
useSearchStore(pinia)
useInfoStore(pinia)

app.use(router)
app.use(vuetify)
app.component('RouterLink', RouterLink)
app.provide('phaidraLink', RouterLink)
app.provide('phaidraLocalePath', (path) => path)

app.mount('#app')
