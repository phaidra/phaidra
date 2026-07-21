<template>
  <v-card>
    <v-card-title class="text-h6 font-weight-light text-white">{{ $t('Sort') }}</v-card-title>
    <v-divider></v-divider>
    <v-card-text class="mt-4" v-if="members.length > 0">
      <div>{{ $t('Here you can sort members of this object (drag & drop).') }}</div>
      <draggable
        v-model="membersdata"
        tag="ul"
        class="sortable-list mt-4"
        :animation="200"
        ghost-class="sortable-ghost"
      >
        <PSortableSolrDoc
          v-for="element in membersdata"
          :key="element.pid"
          :item="element"
        />
      </draggable>
    </v-card-text>
    <v-card-actions v-if="members.length > 0">
      <v-spacer></v-spacer>
      <v-btn color="primary" :disabled="loading" :loading="loading" @click="save()">{{ $t('Save') }}</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import { VueDraggableNext as draggable } from 'vue-draggable-next'
import PSortableSolrDoc from '../utils/PSortableSolrDoc'

export default {
  name: 'p-m-sort',
  emits: ['order-saved'],
  components: {
    PSortableSolrDoc,
    draggable
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
    }
  },
  watch: {
    members: {
      handler (value) {
        this.membersdata = Array.isArray(value) ? [...value] : []
      },
      immediate: true
    }
  },
  data () {
    return {
      loading: false,
      membersdata: []
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
        window.scrollTo({ top: 0, behavior: 'smooth' })
      }
    }
  }
}
</script>

<style scoped>
.sortable-list {
  max-height: 80vh;
  padding: 0;
  overflow: auto;
  background-color: #f3f3f3;
  border: 1px solid #efefef;
  border-radius: 3px;
  list-style: none;
}

.sortable-ghost {
  opacity: 0.5;
}
</style>
