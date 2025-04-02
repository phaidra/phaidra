<template>
  <v-card>
    <v-card-title class="title font-weight-light white--text">{{ $t('Sort') }}</v-card-title>
    <v-divider></v-divider>
    <v-card-text class="mt-4" v-if="members.length > 0">
      <div>{{ $t('Here you can sort members of this object (drag & drop).') }}</div>
      <PSortableList lockAxis="y" v-model="memberscomputed">
        <PSortableSolrDoc v-for="(item, index) in memberscomputed" :index="index" :key="index" :item="item"/>
      </PSortableList>
    </v-card-text>
    <v-card-actions v-if="members.length > 0">
      <v-spacer></v-spacer>
      <v-btn color="primary" :disabled="loading" :loading="loading" @click="save()">{{ $t('Save') }}</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import PSortableList from '../utils/PSortableList'
import PSortableSolrDoc from '../utils/PSortableSolrDoc'

export default {
  name: 'p-m-sort',
  components: {
    PSortableSolrDoc,
    PSortableList
  },
  props: {
    pid: {
      type: String
    },
    cmodel: {
      type: String
    },
    members: {
      type: Array
    }
  },
  computed: {
    instance: function () {
      return this.$store.state.instanceconfig
    },
    memberscomputed: {
      get: function () {
        return this.membersdata
      },
      set: function (newValue) {
        this.membersdata = newValue
      }
    }
  },
  data () {
    return {
      loading: false,
      membersdata: this.members
    }
  },
  methods: {
    save: async function () {
      this.loading = true
      let colorder = []
      let i = 0
      for (let m of this.membersdata) {
        i++
        colorder.push({ pid: m.pid, pos: i })
      }
      try {
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { members: colorder } }))
        let response = await this.$axios.request({
          method: 'POST',
          url: '/' + this.cmodel.toLowerCase() + '/' + this.pid + '/members/order',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          if (response.data.status === 401) {
            response.data.alerts.push({ type: 'danger', msg: 'Please log in' })
          }
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.status === 200) {
          this.$emit('order-saved', this.pid)
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
      } finally {
        this.loading = false
        this.$vuetify.goTo(0)
      }
    }
  }
}
</script>
