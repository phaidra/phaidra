<template>
  <v-card >
    <v-card-title class="title font-weight-light grey white--text">{{ $t('Delete') }}</v-card-title>
    <v-divider></v-divider>
    <v-card-text class="mt-4">
      <v-alert :type="'info'" :value="true" transition="slide-y-transition" v-if="(cmodel === 'Container') && (members.length > 0)">{{ $t('MEMBERS_DELETE_ALERT_CONTAINER', { nrmembers: members.length }) }}</v-alert>
      <div v-else>{{ $t('DELETE_OBJECT', { pid: instance.baseurl + '/' + pid }) }}</div>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-dialog v-model="dialog" width="500" >
        <template v-slot:activator="{ on }">
          <v-btn color="red" class="white--text" v-on="on" :disabled="(members.length > 0) || !pid || !cmodel">{{ $t('Delete') }}</v-btn>
        </template>
        <v-card>
          <v-card-title class="title font-weight-light grey lighten-2" primary-title >{{ $t('Delete') }}</v-card-title>
          <v-card-text>{{ $t('DELETE_OBJECT_CONFIRM', { pid: instance.baseurl + '/' +  pid })}}</v-card-text>
          <v-divider></v-divider>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="red" class="white--text" :loading="loading" :disabled="loading" @click="deleteObject(pid)">{{ $t('Delete') }}</v-btn>
            <v-btn :disabled="loading" @click="dialog = false">{{ $t('Cancel') }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-card-actions>
  </v-card>
</template>

<script>

export default {
  name: 'p-m-delete',
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
      dialog: false
    }
  },
  methods: {
    deleteObject: async function (pid) {
      this.loading = true
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/object/' + pid + '/delete',
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        if (response.data.status === 200) {
          this.$emit('object-deleted', this.pid)
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }

        this.dialog = false
        this.$vuetify.goTo(0)
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'danger', msg: 'Error deleting object: ' + error }])
      } finally {
        this.loading = false
        this.dialog = false
        this.$vuetify.goTo(0)
      }
    }
  }
}
</script>
