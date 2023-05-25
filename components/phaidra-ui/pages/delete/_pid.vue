<template>
  <div>
    <v-btn class="my-4" :to="{ path: `/detail/${pid}`, params: { pid: pid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-row>
      <v-col v-if="signedin">
        <p-m-delete v-if="appconfig.enabledelete" :pid="pid" :cmodel="loadedcmodel" :members="members"
          @object-deleted="objectDeleted($event)"></p-m-delete>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import qs from 'qs'
import axios from 'axios'
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
    loadData: function (self, pid) {
      return self.loadDoc(self, pid)
        .then(function (response) {
          return self.loadMembers(self, pid)
        })
    },
    loadDoc: function (self, pid) {
      this.members = []

      var params = {
        q: 'pid:"' + pid + '"',
        defType: 'edismax',
        wt: 'json',
        qf: 'pid^5'
      }

      var query = qs.stringify(params, { encodeValuesOnly: true, indices: false })
      var url = this.instanceconfig.solr + '/select?' + query
      var promise = axios.get(url)
        .then(function (response) { return response.json() })
        .then(function (json) {
          if (json.response.numFound > 0) {
            self.doc = json.response.docs[0]
          } else {
            self.doc = {}
          }
        })
        .catch(function (error) {
          console.log(error)
        })

      return promise
    },
    loadMembers(self, pid) {
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
      var url = this.instanceconfig.solr + '/select?' + query
      var promise = axios.get(url)
        .then(function (response) { return response.json() })
        .then(function (json) {
          if (json.response.numFound > 0) {
            self.members = json.response.docs
          } else {
            self.members = []
          }
        })
        .catch(function (error) {
          console.log(error)
        })

      return promise
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
