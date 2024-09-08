<template>
  <div>
    <v-btn class="my-4" :to="{ path: `/detail/${pid}`, params: { pid: pid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-row>
      <v-col >
        <p-m-delete v-if="instanceconfig.showdeletebutton || user.isadmin" :pid="pid" :cmodel="loadedcmodel" :members="members"
          @object-deleted="objectDeleted($event)"></p-m-delete>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import qs from 'qs'
import { context } from '../../mixins/context'
import { config } from '../../mixins/config'

export default {
  mixins: [context, config],
  computed: {
    loadedcmodel: function () {
      return 'cmodel' in this.doc ? this.doc.cmodel : 'unknown'
    },
    pid() {
      return this.$route.params.pid
    }
  },
  data() {
    return {
      members: [],
      doc: {},
      parentpid: ''
    }
  },
  methods: {
    loadData: async function (self, pid) {
      await self.loadDoc(self, pid)
      await self.loadMembers(self, pid)
    },
    loadDoc: async function (self, pid) {
      this.members = []

      var params = {
        q: 'pid:"' + pid + '"',
        defType: 'edismax',
        wt: 'json',
        qf: 'pid^5'
      }

      var query = qs.stringify(params, { encodeValuesOnly: true, indices: false })
      var url = '/search/select?' + query
      
      try {
        this.$store.commit('setLoading', true)
        let response = await this.$axios.request({
          method: "GET",
          url: url,
        });
        
        if (response.data.numFound > 0) {
          self.doc = response.data.docs[0]
        } else {
          self.doc = {}
        }
      } catch (error) {
        console.log(error);
        this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
      } finally {
        this.$store.commit('setLoading', false)
      }

    },
    loadMembers: async function (self, pid) {
      this.members = []

      var params = {
        q: 'ismemberof:"' + pid + '"',
        defType: 'edismax',
        wt: 'json',
        qf: 'ismemberof^5',
        fl: 'pid,cmodel,dc_title,created',
        sort: 'pos_in_' + pid.replace(':', '_') + ' asc'
      }

      var query = qs.stringify(params, { encodeValuesOnly: true, indices: false })
      var url = '/search/select?' + query

      try {
        this.$store.commit('setLoading', true)
        let response = await this.$axios.request({
          method: "GET",
          url: url,
        });
        
        if (response.data.numFound > 0) {
          self.members = response.data.docs
        } else {
          self.members = []
        }
      } catch (error) {
        console.log(error);
        this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
      } finally {
        this.$store.commit('setLoading', false)
      }

    },
    objectDeleted: function (event) {
      this.$store.commit('setAlerts', [{ type: 'success', msg: 'Object' + this.pid + ' was successfully deleted.' }])
      if (this.pid === this.parentpid) {
        this.$router.push(this.localeLocation({ path: '/search' }))
      } else {
        this.$router.push(this.localeLocation({ path: `/detail/${this.parentpid}` }))
      }
    }
  },
  beforeRouteEnter: function (to, from, next) {
    next(vm => {
      vm.parentpid = from.params.pid
      vm.loadData(vm, to.params.pid).then(() => {
        next()
      })
    })
  },
  beforeRouteUpdate: function (to, from, next) {
    this.parentpid = from.params.pid
    this.loadData(this, to.params.pid).then(() => {
      next()
    })
  }
}
</script>
