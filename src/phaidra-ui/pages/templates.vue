<template>  
  <div>
    <v-container fluid>
        <v-card-text>
            <p-templates
                class="mt-4"
                ref="templatesRef"
                :items-per-page="5"
                :id-only="true"
                type="navtemplate"
                v-on:load-template="loadTemplate($event)"
                v-on:edit-validation="editValidation($event)"
                v-on:public-toggle="publicToggle($event)"
            ></p-templates>
        </v-card-text>
        <v-dialog  v-model="validationEdit" width="500">
              <v-card>
                <v-card-title class="title font-weight-light grey lighten-2" primary-title><span v-t="'Edit Template Validation'"></span></v-card-title>
                <v-card-text>
                  <v-alert
                    v-model="validationError"
                    dismissible
                    type="error"
                    transition="slide-y-transition"
                  >
                    <span>{{ $t("Please fill the validation with following options") }}.</span>
                    <br />
                    <template>
                      <ul>
                        <li v-for="field in availableValidationOptions" :key="'mfld' + field"><span>{{ $t(field) }}</span></li>
                      </ul>
                    </template>
                  </v-alert>
                  <v-text-field class="mt-4" hide-details filled single-line v-model="validationName" :label="$t('Validation name')" ></v-text-field>
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn :loading="validationSaveLoading" :disabled="validationSaveLoading" color="grey" dark @click="validationEdit= false"><span v-t="'Cancel'"></span></v-btn>
                  <v-btn :loading="validationSaveLoading" :disabled="validationSaveLoading" color="primary" @click="saveValidation()"><span v-t="'Save'"></span></v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
    </v-container>
  </div>
</template>

<script>
import { context } from "../mixins/context";

export default {
  mixins: [],
  middleware: "auth",
  watch: {
  },
  methods: {
    updateTemplateProp: async function (value) {
      var httpFormData = new FormData()
      httpFormData.append('public', value.public || false)
      httpFormData.append('validationfnc', value.validationfnc || '')
      let response = await this.$axios.request({
          method: 'POST',
          data: httpFormData,
          url: `/jsonld/template/${value.tid}/edit?type=navtemplate`,
          headers: {
            'X-XSRF-TOKEN': this.$store.state.user.token
          }
        })
        return response
    },
    publicToggle: async function (templateItem) {
      await this.updateTemplateProp({
        public: templateItem.public,
        validationfnc: templateItem.validationfnc,
        tid: templateItem.tid,
      })
    },
    loadTemplate: async function (templateid) {
      this.$router.push(
        this.localeLocation({ path: `/submit/custom/${templateid}` })
      );
      this.templateDialog = false;
    },
    editValidation: async function (templateItem) {
      this.validationError = false
      this.selectedTemplate = templateItem;
      this.validationName = templateItem.validationfnc || ''
      this.validationEdit = true;
    },
    saveValidation: async function() {
     if(!this.availableValidationOptions.includes(this.validationName)) {
      this.validationError = true
      return
     }
     this.validationSaveLoading = true
      await this.updateTemplateProp({
        tid: this.selectedTemplate.tid,
        public: this.selectedTemplate.public,
        validationfnc: this.validationName,
      })
     this.validationSaveLoading = false
     this.validationEdit = false;
     this.$refs.templatesRef.loadTemplates()

    }
  },
  data() {
    return {
      validationEdit: false,
      validationName: '',
      selectedTemplate: null,
      validationSaveLoading: false,
      validationError: false,
      availableValidationOptions: [
        'noValidation',
        'defaultValidation',
        'validationWithoutKeywords',
        'validationWithOefos',
        'validationWithOefosAndAssoc',
        'validationThesis',
      ]
    };
  },
};
</script>
