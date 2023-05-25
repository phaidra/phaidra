<template>
  <div>
    <v-row class="my-6 ml-2">
      <v-btn :to="{ path: `/detail/${pid}`, params: { pid: pid } }">
        <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
      </v-btn>
    </v-row>
    <v-row>
      <v-col v-if="signedin">
        <template v-if="members.length > 0">
          <p-m-sort-textinput :pid="pid" :cmodel="loadedcmodel" :members="members" @input="members = $event"
          @order-saved="orderSaved($event)"></p-m-sort-textinput>
        </template>
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
      count: 0
    }
  },
  methods: {
    loadData: async function (self, pid) {
      await self.loadDoc(self, pid)

      let rel = 'ismemberof'
      if (this.doc.cmodel === 'Collection') {
        rel = 'ispartof'
      }
      return self.loadMembers(self, pid, rel)
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
      var promise = fetch(url, {
        method: 'GET',
        mode: 'cors'
      })
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
    loadMembers: async function (self, pid, rel) {

      var params = {
        q: rel + ':"' + pid + '"',
        defType: 'edismax',
        wt: 'json',
        qf: rel + '^5',
        rows: 0
      }

      var query = qs.stringify(params, { encodeValuesOnly: true, indices: false })
      var url = this.instanceconfig.solr + '/select?' + query
      var promise = fetch(url, {
        method: 'GET',
        mode: 'cors'
      })
        .then(function (response) { return response.json() })
        .then(function (json) {
          self.count = json.response.numFound
        })
        .catch(function (error) {
          console.log(error)
        })

      await promise

      this.members = []

      var params = {
        q: rel + ':"' + pid + '"',
        defType: 'edismax',
        wt: 'json',
        qf: rel + '^5',
        fl: 'pid',
        sort: 'pos_in_' + pid.replace(':', '_') + ' asc',
        rows: this.count
      }

      var query = qs.stringify(params, { encodeValuesOnly: true, indices: false })
      var url = this.instanceconfig.solr + '/select?' + query
      var promise = fetch(url, {
        method: 'GET',
        mode: 'cors'
      })
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
    orderSaved: function (event) {
      this.$store.commit('setAlerts', [{ type: 'success', msg: 'Order for object ' + event + ' saved' }])
    }
  },
  beforeRouteEnter: function (to, from, next) {
    next(vm => {
      vm.loadData(vm, to.params.pid).then(() => {
        next()
      })
    })
  },
  beforeRouteUpdate: function (to, from, next) {
    this.loadData(this, to.params.pid).then(() => {
      next()
    })
  }
}
</script>

<style>
.list {
  max-height: 80vh;
  margin: 0 auto;
  padding: 0;
  overflow: auto;
  background-color: #f3f3f3;
  border: 1px solid #efefef;
  border-radius: 3;
}

.list-item {
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-align: center;
  -ms-flex-align: center;
  align-items: center;
  width: 100%;
  padding: 20px;
  background-color: #fff;
  border-bottom: 1px solid #efefef;
  box-sizing: border-box;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
  color: #333;
  font-weight: 400;
}

.list-item-title {
  padding-left: 20px;
}
</style>
