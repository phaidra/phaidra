<template>
  <div>
    <v-btn color="primary" class="my-4" :to="{ path: `/detail/${pid}`, params: { pid: pid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-row>
      <v-col v-if="signedin && pid">
        <p-m-relationships :relationships="relationships" :pid="pid" v-on:load-relationships="loadRelationships()">
        </p-m-relationships>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import { context } from '../../mixins/context'
import { config } from '../../mixins/config'

export default {
  mixins: [context, config],
  computed: {
    pid() {
      return this.$route.params.pid
    }
  },
  data() {
    return {
      loading: false,
      relationships: {}
    }
  },
  methods: {
    loadRelationships: async function (self) {
      if (!self) {
        self = this
      }
      self.loading = true
      self.relationships = {}
      try {
        let response = await self.$axios.request({
          method: 'GET',
          url: '/object/' + self.pid + '/relationships',
          headers: {
            'X-XSRF-TOKEN': self.$store.state.user.token
          }
        })
        if (response.status === 200) {
          this.relationships = response.data.relationships
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            self.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        self.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        self.loading = false
      }
    }
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      await vm.loadRelationships(vm)
    })
  },
  beforeRouteUpdate: async function (to, from, next) {
    await this.loadRelationships(this)
    next()
  }
}
</script>
