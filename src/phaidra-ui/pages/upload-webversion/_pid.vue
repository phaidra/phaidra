<template>
  <v-col>
    <v-btn class="mt-2 mb-4" :to="{ path: `/detail/${parentpid}`, params: { pid: parentpid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-card>
      <v-card-title class="title font-weight-light grey white--text">{{ $t('Upload web-optimized version of') }} {{
          parentpid
      }}</v-card-title>
      <v-card-text>
        <v-container fluid>
          <v-row>
            <v-checkbox v-model="checkbox" color="primary" :error-messages="checkboxErrors">
              <template v-slot:label>
                {{ $t('WEBVERSIONSUBMIT', { pid: 'https://' + instanceconfig.baseurl + '/' + parentpid }) }}
              </template>
            </v-checkbox>
          </v-row>
          <v-row>
            <v-col cols="12" md="10">
              <client-only>
                <p-i-file :label="$t('Select file')" :mimeLabel="$t('Select mime type')" v-on:input-file="file = $event"
                  v-on:input-mimetype="mimetype = $event['@id']"></p-i-file>
              </client-only>
            </v-col>
            <v-col cols="12" md="2">
              <v-btn color="primary" :disabled="loading" @click="upload()" class="mt-6">{{ $t('Upload') }}</v-btn>
            </v-col>
          </v-row>
        </v-container>
      </v-card-text>
    </v-card>
  </v-col>
</template>

<script>
import { context } from '../../mixins/context'
import { config } from '../../mixins/config'

export default {
  mixins: [context, config],
  data() {
    return {
      loading: false,
      checkbox: false,
      file: null,
      mimetype: null,
      checkboxErrors: []
    }
  },
  computed: {
    parentpid: function () {
      return this.$route.params.pid
    }
  },
  methods: {
    upload: async function () {
      this.checkboxErrors = []
      if (!this.checkbox) {
        this.checkboxErrors.push(this.$t('Missing confirmation'))
        return
      }
      this.loading = true
      try {
        var httpFormData = new FormData()
        httpFormData.append('dscontent', this.file)
        httpFormData.append('mimetype', this.mimetype)
        httpFormData.append('dslabel', this.file.name)
        httpFormData.append('controlgroup', 'M')
        let response = await this.$axios.request({
          method: 'POST',
          url: '/object/' + this.parentpid + '/datastream/WEBVERSION',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })
        if (response.status === 200) {
          this.$store.commit('setAlerts', [{ type: 'success', msg: 'Web-optimized version successfully uploaded' }])
          this.$router.push(this.localeLocation({ path: `/detail/${this.parentpid}` }))
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            this.$store.commit('setAlerts', response.data.alerts)
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        this.loading = false
      }
    }
  }
}
</script>
