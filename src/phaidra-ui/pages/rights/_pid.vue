<template>
  <div>
    <v-btn color="primary" class="my-4" :to="{ path: `/detail/${pid}`, params: { pid: pid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-row>
      <v-col v-if="signedin && pid">
        <p-m-rights 
          :pid="pid" 
          :rights="rights"
          :show-persons="instanceconfig.accessrestrictions_showpersons"
          :show-accounts="instanceconfig.accessrestrictions_showaccounts"
          :show-edu-person-affiliation="instanceconfig.accessrestrictions_showedupersonaffiliation"
          :show-org-units="instanceconfig.accessrestrictions_showorgunits"
          :show-groups="instanceconfig.accessrestrictions_showgroups"
          v-on:load-rights="loadRights()"></p-m-rights>
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
      rights: {}
    }
  },
  methods: {
    loadRights: async function (self) {
      if (!self) {
        self = this
      }
      self.loading = true
      try {
        let response = await self.$axios.request({
          method: 'GET',
          url: '/object/' + self.pid + '/rights',
          headers: {
            'X-XSRF-TOKEN': self.$store.state.user.token
          }
        })
        if (response.data.metadata.status === 200) {
          self.rights = response.data.metadata.rights
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            self.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        // this.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        self.loading = false
      }
    }
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      await vm.loadRights(vm)
    })
  },
  beforeRouteUpdate: async function (to, from, next) {
    await this.loadRights(this)
    next()
  }
}
</script>
