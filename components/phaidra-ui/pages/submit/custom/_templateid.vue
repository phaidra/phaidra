<template>
  <v-container fluid>
    <v-row>
      <v-col>
        <p-i-form :form="form" :rights="rights" :enablerights="true" :addbutton="true" :templating="true"
          :validate="skipValidation ? dontValidate : validate" v-on:load-form="form = $event" v-on:object-created="objectCreated($event)"
          v-on:input-rights="rights = $event"></p-i-form>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { context } from "../../../mixins/context";
import { config } from "../../../mixins/config";
import { formvalidation } from "../../../mixins/formvalidation";

export default {
  name: 'submit-custom',
  mixins: [context, formvalidation, config],
  data() {
    return {
      form: {},
      rights: {},
      skipValidation: false
    }
  },
  methods: {
    dontValidate: function () {
      return true;
    },
    objectCreated: function (event) {
      this.$router.push({ name: 'detail', params: { pid: event } })
      this.$vuetify.goTo(0)
    },
    loadTemplate: async function (self) {
      self.loading = true
      try {
        let response = await self.$http.request({
          method: 'GET',
          url: self.instanceconfig.api + '/jsonld/template/' + self.$route.params.templateid,
          headers: {
            'X-XSRF-TOKEN': self.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          self.$store.commit('setAlerts', response.data.alerts)
        }
        self.form = response.data.template.form
        if (response.data.template.hasOwnProperty('skipValidation')) {
          self.skipValidation = response.data.template.skipValidation
        }
      } catch (error) {
        console.log(error)
        self.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        self.loading = false
      }
    }
  },
  beforeRouteEnter: function (to, from, next) {
    next(vm => {
      vm.templateid = to.params.templateid
      vm.loadTemplate(vm).then(() => {
        next()
      })
    })
  },
  beforeRouteUpdate: function (to, from, next) {
    this.templateid = to.params.templateid
    this.loadTemplate(this).then(() => {
      next()
    })
  }
}
</script>
