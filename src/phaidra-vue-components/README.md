# phaidra-vue-components

## Example usage

Create a new Vue project
```bash
vue create test-phaidra-components
```

Install additional dependencies
```bash
npm install --save-dev stylus
npm install --save-dev stylus-loader
npm install --save vuetify
npm install --save vuex
npm install --save vue-i18n
npm install --save phaidra-vue-components
```

main.js
```js
import Vue from 'vue'
import './plugins/vuetify'
import Vuetify from 'vuetify'
import VueI18n from 'vue-i18n'
import store from 'phaidra-vue-components/src/store'
import eng from 'phaidra-vue-components/src/i18n/eng'
import deu from 'phaidra-vue-components/src/i18n/deu'
import ita from 'phaidra-vue-components/src/i18n/ita'
import PhaidraVueComponents from 'phaidra-vue-components'
import App from './App.vue'

Vue.config.productionTip = false

Vue.use(Vuetify)
Vue.use(VueI18n)
Vue.use(PhaidraVueComponents)

const messages = { eng, deu, ita }
const i18n = new VueI18n({
  locale: 'deu',
  messages: messages
})

new Vue({
  store,
  i18n,
  render: h => h(App),
}).$mount('#app')

```

Add material icons and font to public/index.html
```html
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Material+Icons">
```

Create src/plugins/vuetify.js
```
import Vue from 'vue'
import Vuetify from 'vuetify/lib'
import 'vuetify/src/stylus/app.styl'

Vue.use(Vuetify, {
  iconfont: 'md',
})
```

Copy the template of App.vue from phaidra-vue-components library, in the template remove `{{version}}` from heading, as for the js part, use this js instead:
```js
import fields from 'phaidra-vue-components/src/utils/fields'

export default {
  name: 'app',
  computed: {
    user: function() {
      return this.$store.state.user.lastname ? this.$store.state.user.firstname + ' ' + this.$store.state.user.lastname : null
    }
  },
  data () {
    return {
      alerts: [],
      window: 0,
      loadedform: {},
      form: {
        sections: [
          {
            title: 'General metadata',
            id: 1,
            fields: []
          },
          {
            title: 'Digitized object',
            type: 'phaidra:DigitizedObject',
            id: 2,
            fields: []
          },
          {
            title: 'Subject',
            type: 'phaidra:Subject',
            id: 3,
            multiplicable: true,
            fields: []
          }
        ]
      },
      pid: '',
      solrbaseurl: 'https://app01.cc.univie.ac.at:8983/solr/phaidra_sandbox',
      apibaseurl: 'https://services.phaidra-sandbox.univie.ac.at/api',
      credentials: {
        username: '',
        password: ''
      },
      contentmodel: 'unknown',
      contentmodels: [ { text: 'Data', value: 'unknown' }, { text: 'Picture', value: 'picture' } ],
      psvis: true
    }
  },
  methods: {
    loadDisplay: function() {
      this.$refs.display.loadMetadata(this.pid)
    },
    loadEdit: function() {
      this.$refs.edit.loadMetadata(this.pid)
    },
    login: function () {
      this.$store.dispatch('login', this.credentials)
    },
    logout: function () {
      this.$store.dispatch('logout')
    },
    objectCreated: function (event) {
      alert('Object ' + event + ' created')
    },
    objectSaved: function (event) {
      alert('Metadata for object ' + event + ' saved')
    },
    toggleVisibility: function () {
      this.psvis = !this.psvis
    },    
    dismiss: function (alert) {
      this.$store.commit('clearAlert', alert)
    }
  },
  mounted: function () {
    this.$store.commit('setInstanceApi', this.apibaseurl)
    this.$store.commit('setInstanceSolr', this.solrbaseurl)

    this.form.sections[0].fields.push(fields.getField('file'))
    this.form.sections[0].fields.push(fields.getField('resource-type'))
    this.form.sections[0].fields.push(fields.getField('title'))
    this.form.sections[0].fields.push(fields.getField('language'))
    this.form.sections[0].fields.push(fields.getField('description'))
    this.form.sections[0].fields.push(fields.getField('keyword'))
    this.form.sections[0].fields.push(fields.getField('project'))
    this.form.sections[0].fields.push(fields.getField('funder'))
    this.form.sections[0].fields.push(fields.getField('role'))
    this.form.sections[0].fields.push(fields.getField('license'))

    this.form.sections[1].fields.push(fields.getField('title'))
    this.form.sections[1].fields.push(fields.getField('description'))
    this.form.sections[1].fields.push(fields.getField('inscription'))
    this.form.sections[1].fields.push(fields.getField('height'))
    this.form.sections[1].fields.push(fields.getField('shelf-mark'))
    this.form.sections[1].fields.push(fields.getField('technique-getty-aat-select'))
    this.form.sections[1].fields.push(fields.getField('digitization-note'))
    this.form.sections[1].fields.push(fields.getField('reproduction-note'))
    
    this.form.sections[2].fields.push(fields.getField('title'))
    this.form.sections[2].fields.push(fields.getField('description'))
    this.form.sections[2].fields.push(fields.getField('temporal-coverage'))
    this.form.sections[2].fields.push(fields.getField('spatial-text'))
    
  }
}
```

If you are using a store in your app, you need to add the necessary phaidra-vue-components store modules to your store:
store/index.js
```js
import vocabulary from 'phaidra-vue-components/src/store/modules/vocabulary'
...
export default new Vuex.Store({
...
  modules: {
...    ,
    vocabulary
  }
})
```

Issue
```
npm run serve
```
or use 'vue ui' to start your application.

# dev

## Prerequisities

You might need more watchers, see [Webpack documentation](https://webpack.js.org/configuration/watch/#not-enough-watchers)

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Run your tests
```
npm run test
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
