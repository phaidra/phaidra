<template>
 
  <v-container class="mt-8" fluid>

    <div class="mb-4"><strong>Note:</strong> Config is cached in each worker, don't forget to restart phaidra-api to apply changes.</div>
    <v-tabs slider-color="primary"  dark background-color="grey" vertical v-model="activetab">
      <v-tab :active-class="'primary'" >
        <span>{{ $t('Public') }}</span>
      </v-tab>
      <v-tab :active-class="'primary'" >
        <span>{{ $t('Private') }}</span>
      </v-tab>
      <v-tab :active-class="'primary'" >
        <span>{{ $t('Import/Export') }}</span>
      </v-tab>

      <v-tab-item>
        <v-card tile>
          
          <v-tabs slider-color="primary" dark background-color="grey" vertical v-model="activetab2">

            <v-tab :active-class="'primary'" >
              <span>{{ $t('General') }}</span>
            </v-tab>
            <v-tab :active-class="'primary'">
              <span>{{ $t('Functionality') }}</span>
            </v-tab>
            <v-tab :active-class="'primary'">
              <span>{{ $t('CMS') }}</span>
            </v-tab>
            <v-tab :active-class="'primary'">
              <span>{{ $t('Datastructures') }}</span>
            </v-tab>

            <v-tab-item class="pa-8">
              <v-container>
                <v-row>
                  <v-col>
                    <v-text-field
                      :label="$t('Name of the repository')"
                      v-model="parsedPublicConfigData.title"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-6"></v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Institution"
                      v-model="parsedPublicConfigData.institution"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t('Used eg. in breadcrumbs.') }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Institution URL"
                      v-model="parsedPublicConfigData.institutionurl"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t('Used eg. in breadcrumbs.') }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Address"
                      v-model="parsedPublicConfigData.address"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t('Used eg. in footer.') }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Phone"
                      v-model="parsedPublicConfigData.phone"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t('Used eg. in footer.') }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Email"
                      v-model="parsedPublicConfigData.email"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t('Used eg. in footer and as a contact address throughout the site.') }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="OAI data provider"
                      v-model="parsedPublicConfigData.oaidataprovider"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t('Used in the EDM schema in OAI-PMH.') }}</v-col>
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
                    <v-row>
                      <span>
                        {{
                          $t(
                            "Select which template should be used as the submit form."
                          )
                        }}
                      </span>
                    </v-row>
                    <v-row v-if="selectedTemplateId">
                      <span>
                        {{ $t("Currently selected") }}: {{ this.selectedTemplateId }}
                      </span>
                    </v-row>
                    <v-row v-else>
                      <span>
                        {{
                          $t(
                            "No template is currently selected. Default submit will be used."
                          )
                        }}
                      </span>
                    </v-row>
                  </v-col>
                </v-row>
                <v-divider class="my-8"></v-divider>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Show delete link"
                      v-model="parsedPublicConfigData.showdeletebutton"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t("Only shows/hides the delete button on object's detail page. Does NOT prevent delete via API, if enabledelete is true in private config!") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Owner email override"
                      v-model="parsedPublicConfigData.owneremailoverride"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("If defined, this email is used as object's owner email on object's detail page. Useful if you want a service email to be contacted in case of enquiries, instead of the original owner.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Languages"
                      v-model="parsedPublicConfigData.languages"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("Comma separated list of languages the language switcher should show.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Validation method"
                      v-model="parsedPublicConfigData.validationfnc"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("Which method shold be used to validate metadata forms.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Mark mandatory method"
                      v-model="parsedPublicConfigData.markmandatoryfnc"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("Which method shold be used to makr fields as mandatory in submit form.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-text-field
                      label="Request DOI email"
                      v-model="parsedPublicConfigData.requestdoiemail"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("Leave empty to disable the 'Request DOI' button.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Enable groups"
                      v-model="parsedPublicConfigData.groups"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("Enable link to 'Groups' in navigation") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Access restrictions: show persons"
                      v-model="parsedPublicConfigData.accessrestrictions_showpersons"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("This only shows/hides the particular frontend components for rights management. Persons is effective the same as accounts, only we search in names instead of usernames.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Access restrictions: show accounts"
                      v-model="parsedPublicConfigData.accessrestrictions_showaccounts"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("This only shows/hides the particular frontend components for rights management.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Access restrictions: show eduPersonAffiliation"
                      v-model="parsedPublicConfigData.accessrestrictions_showedupersonaffiliation"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("This only shows/hides the particular frontend components for rights management.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Access restrictions: show org units"
                      v-model="parsedPublicConfigData.accessrestrictions_showorgunits"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("This only shows/hides the particular frontend components for rights management.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Access restrictions: show groups"
                      v-model="parsedPublicConfigData.accessrestrictions_showgroups"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-4">{{ $t("This only shows/hides the particular frontend components for rights management.") }}</v-col>
                </v-row>
              </v-container>
            </v-tab-item>

            <v-tab-item class="pa-8">
              <v-container>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Header"
                      v-model="parsedPublicConfigData.cms_header"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Header component. Enclose template in a div.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Footer"
                      v-model="parsedPublicConfigData.cms_footer"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Footer component. Enclose template in a div.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Homepage"
                      v-model="parsedPublicConfigData.cms_home"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Homepage component. Enclose template in a div.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Impressum"
                      v-model="parsedPublicConfigData.cms_impressum"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Impressum component. Enclose template in a div.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Submit langing page"
                      v-model="parsedPublicConfigData.cms_submit"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Submit langing page component. Enclose template in a div.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Help page"
                      v-model="parsedPublicConfigData.cms_help"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Help page component. Enclose template in a div.") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="CSS"
                      v-model="parsedPublicConfigData.cms_css"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Custom CSS to add to header") }}</v-col>
                </v-row>
              </v-container>
            </v-tab-item>
            <v-tab-item class="pa-8">
              <v-container>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Org units"
                      v-model="data_orgunits_text"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("The organigram in json structure") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Vocabularies"
                      v-model="data_vocabularies_text"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Custom controlled vocabularies") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="i18n overrrides"
                      v-model="data_i18n_text"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Override localisation values") }}</v-col>
                </v-row>
                <v-row>
                  <v-col>
                    <v-textarea
                      label="Facet queries"
                      v-model="data_facetqueries_text"
                    ></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-4">{{ $t("Override facet queries") }}</v-col>
                </v-row>
              </v-container>
            </v-tab-item>
          </v-tabs>
          <v-btn fixed bottom right raised color="primary" :loading="loading" @click="save()">{{ $t('Save') }}</v-btn>
        </v-card>
      </v-tab-item>

      <v-tab-item>
        <v-card tile>
          
          <v-tabs slider-color="primary" slider-size="20px" dark background-color="grey" vertical v-model="activetabprivate">

            <v-tab :active-class="'primary'">
              <span>{{ $t('Functionality') }}</span>
            </v-tab>

            <v-tab-item class="pa-8">
              <v-container>
                <v-row>
                  <v-col>
                    <v-checkbox
                      label="Enable delete"
                      v-model="parsedPrivateConfigData.enabledelete"
                    ></v-checkbox>
                  </v-col>
                  <v-col cols="6" class="mt-6">{{ $t("Allows delete of owned objects for normal users. Admin can always delete any object. (This setting only applies in Authorizatio/authorize which is currently only use on Fedora 6.x instances.)") }}</v-col>
                </v-row>
                
              </v-container>
            </v-tab-item>

          </v-tabs>
          <v-btn fixed bottom right raised color="primary" :loading="loading" @click="save()">{{ $t('Save') }}</v-btn>
        </v-card>

      </v-tab-item>

      <v-tab-item>
        <v-card tile>
          
          <v-tabs slider-color="primary" slider-size="20px" dark background-color="grey" vertical v-model="activetabimpexp">

            <v-tab :active-class="'primary'">
              <span>{{ $t('Export') }}</span>
            </v-tab>
            <v-tab :active-class="'primary'">
              <span>{{ $t('Import') }}</span>
            </v-tab>

            <v-tab-item class="pa-8">
              <v-container>
                <v-row>
                  <v-col>
                    <v-textarea label="Config as JSON" v-model="configAsJSON"></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-6">{{ $t("This is the whole config. You can copy it to back it up or to use the Import tab to import it on another 'instance'. Don't forget to adapt API base URL.") }}</v-col>
                </v-row>
              </v-container>
            </v-tab-item>

            <v-tab-item class="pa-8">
              <v-container>
                <v-row>
                  <v-col>
                    <v-textarea label="Config as JSON" v-model="configAsJSONToImport"></v-textarea>
                  </v-col>
                  <v-col cols="3" class="mt-6">
                    <v-row>
                      <v-col>
                        {{ $t("Enter config here.") }}
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col>
                        <v-btn raised color="primary" @click="importConfig()">Import</v-btn>
                      </v-col>
                    </v-row>
                  </v-col>
                </v-row>
              </v-container>
            </v-tab-item>

          </v-tabs>
          <v-btn fixed bottom right raised color="primary" :loading="loading" @click="save()">{{ $t('Save') }}</v-btn>
        </v-card>
      </v-tab-item>


    </v-tabs>

    
  </v-container>

</template>
<script>

export default {
  middleware: "auth",
  computed: {
    configAsJSON: {
      get: function () {
        let publicConfig = {...this.parsedPublicConfigData}
        delete publicConfig['_id']
        publicConfig.data_orgunits = this.data_orgunits
        publicConfig.data_vocabularies = this.data_vocabularies
        publicConfig.data_i18n = this.data_i18n

        let privateConfig = {...this.parsedPrivateConfigData}
        delete privateConfig['_id']
        let config = {
          public: publicConfig,
          private: privateConfig
        }
        return JSON.stringify(config, null, 2)
      },
      set: function () {}
    }
  },
  data() {
    return {
      templateDialog: false,
      selectedTemplateId: null,
      jsonInput: "",
      parsedPublicConfigData: {},
      parsedPrivateConfigData: {},
      data_orgunits: [],
      data_orgunits_text: '',
      data_vocabularies: {},
      data_vocabularies_text: '',
      data_i18n: {},
      data_i18n_text: '',
      data_facetqueries: [],
      data_facetqueries_text: '',
      loading: false,
      activetabimpexp: null,
      activetab: null,
      activetab2: null,
      activetabprivate: null,
      configAsJSONToImport: ''
    };
  },
  methods: {
    importConfig: async function () {
      this.loading = true
      try {
        let config = JSON.parse(this.configAsJSONToImport)

        var httpFormData = new FormData()
        httpFormData.append('public_config', JSON.stringify(config.public))
        await this.$axios.request({
          method: 'POST',
          url: '/config/public',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData
        })

        this.$axios.defaults.baseURL = config.public.api
        this.$store.commit('setInstanceConfig', config.public)

        const privateConfData = {...this.parsedPrivateConfigData}
        var httpFormData = new FormData()
        httpFormData.append('private_config', JSON.stringify(config.private))
        await this.$axios.request({
          method: 'POST',
          url: '/config/private',
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
    },
    save: async function () {
      this.loading = true
      try {

        // public
        const instanceConfData = {...this.parsedPublicConfigData}

        if (this.data_orgunits_text) {
          this.data_orgunits = JSON.parse(this.data_orgunits_text)
        }
        instanceConfData['data_orgunits'] = this.data_orgunits

        if (this.data_vocabularies_text) {
          this.data_vocabularies = JSON.parse(this.data_vocabularies_text)
        }
        instanceConfData['data_vocabularies'] = this.data_vocabularies

        if (this.data_i18n_text) {
          this.data_i18n = JSON.parse(this.data_i18n_text)
        }
        instanceConfData['data_i18n'] = this.data_i18n

        if (this.data_facetqueries_text) {
          this.data_facetqueries = JSON.parse(this.data_facetqueries_text)
        }
        instanceConfData['data_facetqueries'] = this.data_facetqueries

        instanceConfData['defaulttemplateid'] = this.selectedTemplateId

        var httpFormData = new FormData()
        httpFormData.append('public_config', JSON.stringify(instanceConfData))
        await this.$axios.request({
            method: 'POST',
            url: '/config/public',
            headers: {
              'Content-Type': 'multipart/form-data',
              'X-XSRF-TOKEN': this.$store.state.user.token
            },
            data: httpFormData
          })

        if(instanceConfData?.api){
          this.$axios.defaults.baseURL = instanceConfData.api
        }
        this.$store.commit('setInstanceConfig', instanceConfData)

        // private
        const privateConfData = {...this.parsedPrivateConfigData}
        var httpFormData = new FormData()
        httpFormData.append('private_config', JSON.stringify(privateConfData))
        await this.$axios.request({
            method: 'POST',
            url: '/config/private',
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
    },
    reset: async function () {
      window.location.reload()
    },
    removeDefaultTemplate: async function () {
      this.onTemplateSelect("")
    },
    onTemplateSelect: async function (templateid) {
      this.selectedTemplateId = templateid
      this.templateDialog = false;
    },
    getExistingAppSetting: async function () {
      this.loading = true
      let response = null;

      // public
      try {
        response = await this.$axios.get("/config/public?nocache=1");
      } catch (error) {
        console.error(error)
      }
      this.selectedTemplateId = response?.data?.public_config?.defaulttemplateid
      if(response?.data?.public_config){
        this.parsedPublicConfigData = {...response?.data?.public_config}

        this.data_orgunits = response?.data?.public_config?.data_orgunits
        this.data_orgunits_text = JSON.stringify(this.data_orgunits, null, 2)

        this.data_vocabularies = response?.data?.public_config?.data_vocabularies
        this.data_vocabularies_text = JSON.stringify(this.data_vocabularies, null, 2)

        this.data_i18n = response?.data?.public_config?.data_i18n
        this.data_i18n_text = JSON.stringify(this.data_i18n, null, 2)

        this.data_facetqueries = response?.data?.public_config?.data_facetqueries
        this.data_facetqueries_text = JSON.stringify(this.data_facetqueries, null, 2)
      } else {
        if(this.$store?.state?.instanceconfig){
          this.parsedPublicConfigData = {...this.$store.state.instanceconfig}
        }
      }

      // private
      try {
        response = await this.$axios.get("/config/private?nocache=1", {
          headers: {
            "X-XSRF-TOKEN": this.$store.state.user.token,
          },
        });
      } catch (error) {
        console.error(error)
      }
      
      if(response?.data?.private_config){
        this.parsedPrivateConfigData = {...response?.data?.private_config}
      }
      this.loading = false
    }
  },
  mounted() {
    this.getExistingAppSetting()
  },
}
</script>
