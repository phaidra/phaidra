<template>
  <div>
    <v-row class="my-6" justify="start">
      <div class="d-flex flex-row ml-6">
        <v-dialog class="pb-4" v-model="templateDialog" width="700px">
          <template v-slot:activator="{ on }">
            <v-btn v-on="on" large dark color="grey">
              <v-icon dark class="mr-4">mdi-script</v-icon>
              {{ $t("Select submit template") }}
            </v-btn>
          </template>
          <v-card>
            <v-card-title dark class="title font-weight-light grey white--text">{{ $t("Select submit template") }}</v-card-title>
            <v-card-text>
              <p-templates class="mt-4" ref="templates" :items-per-page="5" :id-only="true" :isDefaultSelect="true"
                :selectedTemplateId="selectedTemplateId" v-on:load-template="onTemplateSelect($event)"></p-templates>
            </v-card-text>
            <v-card-actions>
              <v-spacer></v-spacer><v-btn @click="templateDialog = false">{{ $t("Cancel") }}</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </div>
      <div class="d-flex flex-row pt-3 ml-6">
        <span>
          {{
            $t(
              "Select which template should be used as the submit form."
            )
          }}
        </span>
      </div>
    </v-row>
    <v-row class="my-6" justify="start">
      <div class="d-flex flex-row ml-6">
        <v-dialog class="pb-4" v-model="configDialog" width="700px" scrollable>
          <template v-slot:activator="{ on }">
            <v-btn v-on="on" large dark color="grey">
              <!-- <v-icon dark class="mr-4">mdi-script</v-icon> -->
              {{ $t("Open Config") }}
            </v-btn>
          </template>
          <v-card>
            <v-card-title dark class="title font-weight-light grey white--text">{{ $t("Open Config") }}</v-card-title>
            <v-card-text>
              <v-container>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Title"
                          v-model="parsedConfigData.title"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Api"
                          readonly
                          v-model="parsedConfigData.api"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Primary Color"
                          v-model="parsedConfigData.primary"
                        ></v-text-field>
                        <!--<v-color-picker
                          dot-size="25"
                          v-model="parsedConfigData.primary"
                          hide-canvas
                          hide-inputs
                        ></v-color-picker>-->
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Institution"
                          v-model="parsedConfigData.institution"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Institution URL"
                          v-model="parsedConfigData.institutionurl"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Address"
                          v-model="parsedConfigData.address"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Phone"
                          v-model="parsedConfigData.phone"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          label="Email"
                          v-model="parsedConfigData.email"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                  </v-container>
            </v-card-text>
            <v-card-actions>
              <v-spacer></v-spacer><v-btn @click="configDialog = false">{{ $t("Cancel") }}</v-btn>
              <v-btn :loading="isConfigSaveLoading" color="primary" @click="saveConfigPopupData()">{{ $t("Save") }}</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </div>
      <div class="d-flex flex-row pt-3 ml-6">
        <span>
          {{
            $t(
              "Open Config editor."
            )
          }}
        </span>
      </div>
    </v-row>
    <!-- <v-row>
      <textarea v-model="jsonInput" cols=150 rows=25></textarea>
      <v-btn @click="saveConfig()">Save Config</v-btn>
      <v-btn @click="resetConfig()">Reset Config</v-btn>
    </v-row> -->
  </div>
</template>
<script>

export default {
  data() {
    return {
      templateDialog: false,
      configDialog: false,
      selectedTemplateId: null,
      jsonInput: "",
      parsedConfigData: {},
      isConfigSaveLoading: false,
    };
  },
  methods: {
    saveConfigPopupData: async function () {
      // return
      this.isConfigSaveLoading = true
      try {
        const instanceConfData = {...this.parsedConfigData}
        var httpFormData = new FormData()
        httpFormData.append('settings', JSON.stringify({
          instanceConfig: instanceConfData
        }))
        await this.$axios.request({
            method: 'POST',
            url: '/app_settings',
            headers: {
              'Content-Type': 'multipart/form-data',
              'X-XSRF-TOKEN': this.$store.state.user.token
            },
            data: httpFormData
          })
          if(instanceConfData?.primary){
            this.$vuetify.theme.themes.light.primary = instanceConfData.primary
            this.$vuetify.theme.themes.dark.primary = instanceConfData.primary
          }
          if(instanceConfData?.api){
            this.$axios.defaults.baseURL = instanceConfData.api
          }
          this.$store.commit('setInstanceConfig', instanceConfData)
          this.configDialog = false;
      } catch (error) {
        console.log('error =>>', error)
      }
      this.isConfigSaveLoading = false
    },
    resetConfig: async function () {
      var httpFormData = new FormData()
      httpFormData.append('settings', JSON.stringify({
        instanceConfig: ""
      }))
      await this.$axios.request({
        method: 'POST',
        url: '/app_settings',
        headers: {
          'Content-Type': 'multipart/form-data',
          'X-XSRF-TOKEN': this.$store.state.user.token
        },
        data: httpFormData
      })
      // this.getExistingAppSetting()
      window.location.reload()
    },
    saveConfig: async function () {
      try {
        if(this.jsonInput){
          const parsedValue = JSON.parse(this.jsonInput)
          var httpFormData = new FormData()
          httpFormData.append('settings', JSON.stringify({
            instanceConfig: parsedValue
          }))
          await this.$axios.request({
            method: 'POST',
            url: '/app_settings',
            headers: {
              'Content-Type': 'multipart/form-data',
              'X-XSRF-TOKEN': this.$store.state.user.token
            },
            data: httpFormData
          })
          if(parsedValue?.primary){
            this.$vuetify.theme.themes.light.primary = parsedValue.primary
            this.$vuetify.theme.themes.dark.primary = parsedValue.primary
          }
          if(parsedValue?.api){
            this.$axios.defaults.baseURL = parsedValue.api
          }
          this.$store.commit('setInstanceConfig', parsedValue)
        }
      } catch (error) {
        console.log('error', error)
      }
    },
    loadJsonInput: function (value) {
      this.parsedConfigData = {...value}
      // this.jsonInput = JSON.stringify(value, undefined, 4)
    },
    removeDefaultTemplate: async function () {
      this.onTemplateSelect("")
    },
    onTemplateSelect: async function (templateid) {
      var httpFormData = new FormData()
      httpFormData.append('settings', JSON.stringify({
        defaultTemplateId: templateid
      }))
      await this.$axios.request({
        method: 'POST',
        url: '/app_settings',
        headers: {
          'Content-Type': 'multipart/form-data',
          'X-XSRF-TOKEN': this.$store.state.user.token
        },
        data: httpFormData
      })
      this.selectedTemplateId = templateid
      this.templateDialog = false;
    },
    getExistingAppSetting: async function () {
      let response = null;
      try {
        response = await this.$axios.get("/app_settings", {
          headers: {
            "X-XSRF-TOKEN": this.$store.state.user.token,
          },
        });
      } catch (error) {
        console.log('error', error)
      }
      this.selectedTemplateId = response?.data?.settings?.defaultTemplateId
      if(response?.data?.settings?.instanceConfig){
        this.loadJsonInput(response?.data?.settings?.instanceConfig)
      } else {
        if(this.$store?.state?.instanceconfig){
          this.loadJsonInput(this.$store.state.instanceconfig)
        }
      }
    }
  },
  mounted() {
    this.getExistingAppSetting()
  },
}
</script>
