<template>
  <v-card>
    <v-card-title class="title font-weight-light grey white--text">{{ $t('Feedback') }}</v-card-title>
    <v-divider></v-divider>
    <v-card-text class="mt-4">
      <v-form v-if="!sent" ref="form" v-model="valid">
        <v-container fluid>
          <v-row>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="fn"
                :rules="nameRules"
                :label="$t('Firstname')"
                required
                filled
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="ln"
                :rules="nameRules"
                :label="$t('Lastname')"
                required
                filled
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="mail"
                :rules="emailRules"
                :label="$t('E-mail')"
                required
                filled
              ></v-text-field>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12">
              <v-textarea
                v-model="feedback"
                :rules="feedbackRules"
                :label="$t('Feedback')"
                required
                filled
              ></v-textarea>
            </v-col>
          </v-row>
        </v-container>
      </v-form>
      <span v-else class="ma-8">{{ $t('Thank you for your feedback!') }}</span>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn v-if="!sent" class="primary" :loading="loading" :disabled="loading" @click="send()">{{ $t('Send') }}</v-btn>
      <v-btn v-if="sent" :loading="loading" :disabled="loading" @click="newFeedback()">{{ $t('New feedback') }}</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
export default {
  name: 'p-feedback',
  props: {
    firstname: {
      type: String
    },
    lastname: {
      type: String
    },
    email: {
      type: String
    },
    context: {
      type: String
    }
  },
  data () {
    return {
      valid: false,
      fn: this.firstname,
      ln: this.lastname,
      nameRules: [
        v => !!v || this.$t('Name is required')
      ],
      mail: this.email,
      emailRules: [
        v => !!v || this.$t('E-mail is required'),
        v => /.+@.+/.test(v) || this.$t('E-mail must be valid')
      ],
      feedback: '',
      feedbackRules: [
        v => !!v || this.$t('Name is required')
      ],
      loading: false,
      sent: false
    }
  },
  methods: {
    send: async function () {
      if (this.$refs.form.validate()) {
        this.loading = true
        var httpFormData = new FormData()
        httpFormData.append('context', this.context)
        httpFormData.append('firstname', this.fn)
        httpFormData.append('lastname', this.ln)
        httpFormData.append('email', this.mail)
        httpFormData.append('message', this.feedback)
        this.rightsArray = []
        this.rightsjson = {}
        try {
          let response = await this.$axios.request({
            method: 'POST',
            url: '/feedback',
            data: httpFormData,
            headers: {
              'X-XSRF-TOKEN': this.$store.state.user.token,
              'Content-Type': 'multipart/form-data'
            }
          })
          if (response.status === 200) {
            this.sent = true
          } else {
            if (response.data.alerts && response.data.alerts.length > 0) {
              this.$store.commit('setAlerts', response.data.alerts)
            }
          }
        } catch (error) {
          console.log(error)
          this.$store.commit('setAlerts', [{ type: 'danger', msg: error }])
        } finally {
          this.loading = false
        }
      }
    },
    newFeedback: function () {
      this.feedback = ''
      this.sent = false
    }
  }
}
</script>
