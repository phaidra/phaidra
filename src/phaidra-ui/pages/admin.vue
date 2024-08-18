<template>
 
  <v-container class="mt-8">
  <v-card >
    <v-card-title class="font-weight-light grey white--text">{{ $t('PHAIDRA Public Config') }}</v-card-title>
    <v-tabs slider-color="primary" slider-size="20px" dark background-color="grey" vertical v-model="activetab">

      <v-tab :active-class="'primary'" >
        <span>{{ $t('General') }}</span>
      </v-tab>
      <v-tab :active-class="'primary'">
        <span>{{ $t('Functionality') }}</span>
      </v-tab>
      <v-tab :active-class="'primary'">
        <span>{{ $t('CMS') }}</span>
      </v-tab>

      <v-tab-item class="pa-8">
        <v-container>
          <v-row>
            <v-col>
              <v-text-field
                :label="$t('Name of the repository')"
                v-model="parsedConfigData.title"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-6"></v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Institution"
                v-model="parsedConfigData.institution"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-6">{{ $t('Used eg. in breadcrumbs.') }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Institution URL"
                v-model="parsedConfigData.institutionurl"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-6">{{ $t('Used eg. in breadcrumbs.') }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Address"
                v-model="parsedConfigData.address"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-6">{{ $t('Used eg. in footer.') }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Phone"
                v-model="parsedConfigData.phone"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-6">{{ $t('Used eg. in footer.') }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Email"
                v-model="parsedConfigData.email"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-6">{{ $t('Used eg. in footer and as a contact address throughout the site.') }}</v-col>
          </v-row>
        </v-container>
      </v-tab-item>

      <v-tab-item class="pa-8">
        <v-container>
          <v-row justify="start">
            <v-col>
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
            </v-col>
            <v-col cols="6" class="mt-3">
              <span>
                {{
                  $t(
                    "Select which template should be used as the submit form."
                  )
                }}
              </span>
            </v-col>
          </v-row>
          <v-divider class="my-8"></v-divider>
          <v-row>
            <v-col>
              <v-checkbox
                label="Show delete button"
                v-model="parsedConfigData.enabledelete"
              ></v-checkbox>
            </v-col>
            <v-col cols="6" class="mt-6">{{ $t("Shows/Hides the delete button on object's detail page. Does NOT prevent delete via API.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Owner email override"
                v-model="parsedConfigData.owneremailoverride"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-4">{{ $t("If defined, this email is used as object's owner email on object's detail page. Useful if you want a service email to be contacted in case of enquiries, instead of the original owner.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Languages"
                v-model="parsedConfigData.languages"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-4">{{ $t("Comma separated list of languages the language switcher should show.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Validation method"
                v-model="parsedConfigData.validationfnc"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-4">{{ $t("Which method shold be used to validate metadata forms.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Mark mandatory method"
                v-model="parsedConfigData.markmandatoryfnc"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-4">{{ $t("Which method shold be used to makr fields as mandatory in submit form.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-text-field
                label="Request DOI email"
                v-model="parsedConfigData.requestdoiemail"
              ></v-text-field>
            </v-col>
            <v-col cols="6" class="mt-4">{{ $t("Leave empty to disable the 'Request DOI' button.") }}</v-col>
          </v-row>
        </v-container>
      </v-tab-item>

      <v-tab-item class="pa-8">
        <v-container>
          <v-row>
            <v-col>
              <v-textarea
                label="Header"
                v-model="parsedConfigData.cms_header"
              ></v-textarea>
            </v-col>
            <v-col cols="3" class="mt-4">{{ $t("Header component. Enclose template in a div.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-textarea
                label="Footer"
                v-model="parsedConfigData.cms_footer"
              ></v-textarea>
            </v-col>
            <v-col cols="3" class="mt-4">{{ $t("Footer component. Enclose template in a div.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-textarea
                label="Homepage"
                v-model="parsedConfigData.cms_home"
              ></v-textarea>
            </v-col>
            <v-col cols="3" class="mt-4">{{ $t("Homepage component. Enclose template in a div.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-textarea
                label="Impressum"
                v-model="parsedConfigData.cms_impressum"
              ></v-textarea>
            </v-col>
            <v-col cols="3" class="mt-4">{{ $t("Impressum component. Enclose template in a div.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-textarea
                label="Submit langing page"
                v-model="parsedConfigData.cms_submit"
              ></v-textarea>
            </v-col>
            <v-col cols="3" class="mt-4">{{ $t("Submit langing page component. Enclose template in a div.") }}</v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-textarea
                label="CSS"
                v-model="parsedConfigData.cms_css"
              ></v-textarea>
            </v-col>
            <v-col cols="3" class="mt-4">{{ $t("Custom CSS to add to header") }}</v-col>
          </v-row>
        </v-container>
      </v-tab-item>
    </v-tabs>
    <v-btn fixed bottom right raised color="primary" :loading="loading" @click="save()">{{ $t('Save') }}</v-btn>
  </v-card>
</v-container>

</template>
<script>

export default {
middleware: "auth",
data() {
  return {
    templateDialog: false,
    selectedTemplateId: null,
    jsonInput: "",
    parsedConfigData: {},
    loading: false,
    activetab: null
  };
},
methods: {
  save: async function () {
    this.loading = true
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
    } catch (error) {
      console.error(error)
    } finally {
      this.loading = false
    }
  },
  reset: async function () {
    window.location.reload()
  },
  loadJsonInput: function (value) {
    this.parsedConfigData = {...value}
    // this.jsonInput = JSON.stringify(value, undefined, 4)
  },
  removeDefaultTemplate: async function () {
    this.onTemplateSelect("")
  },
  onTemplateSelect: async function (templateid) {
    this.loading = true
    var httpFormData = new FormData()
    httpFormData.append('settings', JSON.stringify({
      defaultTemplateId: templateid
    }))
    try {
      await this.$axios.request({
        method: 'POST',
        url: '/app_settings',
        headers: {
          'Content-Type': 'multipart/form-data',
          'X-XSRF-TOKEN': this.$store.state.user.token
        },
        data: httpFormData
      })
    } catch (error) {
      console.error(error)
    } finally {
      this.loading = false
    }
    this.selectedTemplateId = templateid
    this.templateDialog = false;
  },
  getExistingAppSetting: async function () {
    this.loading = true
    let response = null;
    try {
      response = await this.$axios.get("/app_settings", {
        headers: {
          "X-XSRF-TOKEN": this.$store.state.user.token,
        },
      });
    } catch (error) {
      console.error(error)
    }
    this.selectedTemplateId = response?.data?.settings?.defaultTemplateId
    if(response?.data?.settings?.instanceConfig){
      this.loadJsonInput(response?.data?.settings?.instanceConfig)
    } else {
      if(this.$store?.state?.instanceconfig){
        this.loadJsonInput(this.$store.state.instanceconfig)
      }
    }
    this.loading = false
  }
},
mounted() {
  this.getExistingAppSetting()
},
}
</script>
