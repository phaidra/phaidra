<template>
  <v-card>
    <v-card-title class="title font-weight-light grey white--text">{{ $t('Define order') }}</v-card-title>
    <v-divider></v-divider>
    <v-card-text class="mt-4" v-if="members.length > 0">
      <div>{{ $t('Please provide the order of the members by ordering the PIDs') }}</div>
      <v-textarea auto-grow v-model="pids" :placeholder="'o:1\no:2\no:3'"></v-textarea>
    </v-card-text>
    <v-card-actions v-if="members.length > 0">
      <v-spacer></v-spacer>
      <v-btn color="primary" :disabled="loading" :loading="loading" @click="load()">{{ $t('Load current order') }}</v-btn>
      <v-btn color="primary" :disabled="loading" :loading="loading" @click="save()">{{ $t('Save') }}</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>

export default {
  name: 'p-m-sort-textinput',
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
    }
  },
  data () {
    return {
      loading: false,
      pids: ''
    }
  },
  methods: {
    load: function () {
      this.pids = ''
      for (let m of this.members) {
        this.pids += m.pid + '\n'
      }
    },
    save: async function () {
      this.loading = true
      let order = []
      let i = 0
      for (let pid of this.pids.split(/\r?\n/)) {
        if (pid) {
          i++
          order.push({ pid: pid, pos: i })
        }
      }
      try {
        var httpFormData = new FormData()
        httpFormData.append('metadata', JSON.stringify({ metadata: { members: order } }))
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
