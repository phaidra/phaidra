<template>
  <div>
    <v-btn color="primary" class="my-4" :to="`/detail/${pid}`" prepend-icon="mdi-arrow-left">
      {{ $t('Back to detail page') }}
    </v-btn>
    <v-row>
      <v-col >
        <p-m-delete v-if="instanceconfig.showdeletebutton || user.isadmin" :pid="pid" :cmodel="loadedcmodel" :members="members"
          @object-deleted="objectDeleted($event)"></p-m-delete>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
definePageMeta({
  middleware: 'auth'
})
</script>

<script>
import { getCurrentInstance } from 'vue'
import { useRootStore } from '~/stores/root'
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
        useRootStore().setLoading(true)
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
        useRootStore().setAlerts([{ type: "error", msg: error }]);
      } finally {
        useRootStore().setLoading(false)
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
        sort: 'pos_in_' + pid.replace(':', '_') + ' asc, created asc, pid asc'
      }

      var query = qs.stringify(params, { encodeValuesOnly: true, indices: false })
      var url = '/search/select?' + query

      try {
        useRootStore().setLoading(true)
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
        useRootStore().setAlerts([{ type: "error", msg: error }]);
      } finally {
        useRootStore().setLoading(false)
      }

    },
    objectDeleted: function (event) {
      useRootStore().setAlerts([{ type: 'success', key: 'object_deleted_success', params: { o: this.pid }}])
      if (this.pid === this.parentpid) {
        this.$router.push(this.localeLocation({ path: `/detail/${this.pid}` }))
      } else {
        this.$router.push(this.localeLocation({ path: `/detail/${this.parentpid}` }))
      }
    }
  },
  beforeRouteEnter: function (to, from, next) {
    to.meta.deleteFromPid = from.params.pid
    next()
  },
  created: function () {
    this.parentpid = this.$route.meta.deleteFromPid
    this.loadData(this, this.pid)
  },
  beforeRouteUpdate: function (to, from, next) {
    const self = getCurrentInstance()?.proxy
    self.parentpid = from.params.pid
    self.loadData(self, to.params.pid).then(() => {
      next()
    })
  }
}
</script>
