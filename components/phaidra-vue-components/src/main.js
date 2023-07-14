import Vue from 'vue'
import store from './store'
import VueRouter from 'vue-router'
import SvgIcon from 'vue-svgicon'
import i18n from './i18n/i18n'
import App from './App.vue'
import moment from 'moment'
import vuetify from './plugins/vuetify'

Vue.config.productionTip = false

Vue.use(VueRouter)
Vue.use(SvgIcon, {
  tagName: 'icon',
  defaultWidth: '1em',
  defaultHeight: '1em'
})

Vue.filter('unixtime', function (value) {
  if (value) {
    return moment.unix(String(value)).format('DD.MM.YYYY hh:mm:ss')
  }
})

Vue.filter('date', function (value) {
  if (value) {
    return moment(String(value)).format('DD.MM.YYYY')
  }
})

Vue.filter('datetime', function (value) {
  if (value) {
    return moment(String(value)).format('DD.MM.YYYY hh:mm:ss')
  }
})

Vue.filter('datetimeutc', function (value) {
  if (value) {
    return moment.utc(String(value)).format('DD.MM.YYYY hh:mm:ss')
  }
})

Vue.filter('bytes', function (bytes, precision) {
  if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) return '-'
  if (typeof precision === 'undefined') precision = 1
  var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB']
  var number = Math.floor(Math.log(bytes) / Math.log(1024))
  return (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) + ' ' + units[number]
})

Vue.filter('truncate', function (text, length, clamp) {
  clamp = clamp || '...'
  length = length || 30

  if (text.length <= length) return text

  var tcText = text.slice(0, length - clamp.length)
  var last = tcText.length - 1

  while (last > 0 && tcText[last] !== ' ' && tcText[last] !== clamp[0]) last -= 1

  // Fix for case when text does not have any space
  last = last || length - clamp.length

  tcText = tcText.slice(0, last)

  return tcText + clamp
})

const router = new VueRouter({
  routes: [
    {
      name: 'detail',
      path: '/details',
      component: {
        template: '<div><b>Details</b> not implemented in PVC demo app</div>'
      }
    }
  ]
})

new Vue({
  store,
  i18n,
  router,
  vuetify,
  render: h => h(App)
}).$mount('#app')
