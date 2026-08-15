<template>
  <div>
    <div v-if="instanceconfig.cms_submit">
      <runtimetemplate :template="instanceconfig.cms_submit" />
    </div>
    
    <div v-else>
      <v-row class="my-6" justify="start">
        <div class="d-flex flex-row ml-3">
          <v-btn
            color="primary"
            variant="elevated"
            prepend-icon="mdi-plus-circle"
            @click="$router.push(localePath('/submit/upload'))"
          >
            {{ $t("Create new object") }}
          </v-btn>
          </div>
        <div class="d-flex flex-row pt-3 ml-3 ml-md-6">
          <span>
          {{
            $t(
              "Upload Picture, Audio, Video, Document, Data or create an empty Collection."
            )
          }}
          </span>
        </div>
      </v-row>
      <v-divider class="my-2"></v-divider>
      <v-row class="my-6" justify="start">
        <div class="d-flex flex-row ml-3">
          <v-btn
            color="primary"
            variant="elevated"
            prepend-icon="mdi-plus-circle"
            @click="$router.push(localePath('/submit/oer'))"
          >
            {{ $t("Open Educational Resources (OER) upload") }}
          </v-btn>
          </div>
        <div class="d-flex flex-row pt-3 ml-3 ml-md-6">
          <span>
          {{
            $t(
              "Publish your openly licensed teaching/learning materials here - videos, scripts, audios, quizzes, images, slide sets, Moodle elements, etc."
            )
          }}
          </span>
        </div>
      </v-row>
      <v-divider class="my-2"></v-divider>
      <template v-if="instanceconfig.irbaseurl && (instanceconfig.irbaseurl !== '')">
        <v-row class="my-6" justify="start">
          <div class="d-flex flex-row ml-3">
            <v-btn
              color="primary"
              variant="elevated"
              prepend-icon="mdi-school"
              :href="'https://uscholar.univie.ac.at/login'"
            >
              {{ $t("Upload publication (via u:scholar)") }}
            </v-btn>
          </div>
            <div class="d-flex flex-row pt-3 ml-3 ml-md-6">
            {{
              $t(
                "Upload journal articles, reports, reviews, working papers, conference papers, monographs, individual chapters from monographs ..."
              )
            }}

          </div>
        </v-row>
        <v-divider class="my-2"></v-divider>
      </template>
      <template v-if="user.authzForms && user.authzForms.catalogfetchupload">
        <v-row class="my-6" justify="start">
          <div class="d-flex flex-row ml-3">
            <v-btn
              color="primary"
              variant="elevated"
              prepend-icon="mdi-plus-circle"
              @click="$router.push(localePath('/submit/catalogfetchupload'))"
            >
              {{ $t("Catalog-fetch upload") }}
            </v-btn>
            </div>
          <div class="d-flex flex-row pt-3 ml-3 ml-md-6">
            <span>
            {{
              $t(
                "Upload objects by pulling metadata from catalogue."
              )
            }}
            </span>
          </div>
        </v-row>
        <v-divider class="my-2"></v-divider>
      </template>
      <template v-if="instanceconfig.uwmsubmit">
        <v-row class="my-6" justify="start">
          <v-col cols="12">
            <span class="text-title-large font-weight-light text-primary">{{
              $t("Legacy (Uwmetadata)")
            }}</span>
          </v-col>
        </v-row>
        <v-row class="my-6" justify="start">
          <v-col cols="12">
            <v-btn
              large
              theme="dark"
              color="grey text-white mr-8"
              :to="localePath({ path: '/submit/uwm/asset'})"
            >
              {{ $t("File") }}
            </v-btn>
            <v-btn
              large
              theme="dark"
              color="grey text-white mr-8"
              :to="localePath({ path: '/submit/uwm/collection'})"
            >
              {{ $t("Collection") }}
            </v-btn>
          </v-col>
        </v-row>
        <v-divider class="my-2"></v-divider>
      </template>
      <template v-if="user.authzForms && user.authzForms.bulkupload">
        <v-row class="my-6" justify="start">
          <div class="d-flex flex-row ml-3">
            <v-btn
              color="primary"
              variant="elevated"
              prepend-icon="mdi-upload-multiple"
              @click="$router.push(localePath('/bulk-upload'))"
            >
              {{ $t("Bulk upload") }}
            </v-btn>
          </div>
        </v-row>
        <v-divider class="my-2"></v-divider>
      </template>
      <v-row class="my-6" justify="start">
        <div class="d-flex flex-row ml-3">
          <v-dialog class="pb-4" v-model="templateDialog" width="900px">
            <template v-slot:activator="{ props: activatorProps }">
              <v-btn v-bind="activatorProps" color="primary" variant="elevated" prepend-icon="mdi-script">
                {{ $t("Open template") }}
              </v-btn>
            </template>
            <v-card>
              <v-card-title                
                class="text-title-large font-weight-light text-white"
                >{{ $t("Open template") }}</v-card-title
              >
              <v-card-text>
                <p-templates
                  class="mt-4"
                  ref="templates"
                  :items-per-page="5"
                  :id-only="true"
                  v-on:load-template="loadTemplate($event)"
                ></p-templates>
              </v-card-text>
              <v-card-actions>
                <v-spacer></v-spacer
                ><v-btn variant="outlined" @click="templateDialog = false">{{ $t("Cancel") }}</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
        <div class="d-flex flex-row pt-3 ml-3 ml-md-6">
          <span>
              {{
                $t(
                  "Open a previously created upload template."
                )
              }}
            </span>
        </div>
      </v-row>
      <template v-if="false">
        <v-row class="my-6" justify="start">
          <v-col cols="12">
            <span class="text-title-large font-weight-light text-primary">{{
              $t("Legacy (Uwmetadata)")
            }}</span>
            <v-divider></v-divider>
          </v-col>
        </v-row>
        <v-row class="my-6" justify="start">
          <v-col cols="12">
            <v-btn
              large
              theme="dark"
              color="grey text-white mr-8"
              @click="$router.push(localePath({ path: '/submit/uwm/asset' }))"
            >
              {{ $t("File") }}
            </v-btn>
            <v-btn
              large
              theme="dark"
              color="grey text-white mr-8"
              @click="
                $router.push(localePath({ path: '/submit/uwm/collection' }))
              "
            >
              {{ $t("Collection") }}
            </v-btn>
          </v-col>
        </v-row>
      </template>
    </div>
  </div>
</template>

<script>
import { context } from "../mixins/context";
import { config, useDocumentTitle } from "../mixins/config";

export default {
  mixins: [context,config],
  setup() {
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: documentTitle(t('Upload'))
      }
    })
  },
  watch: {
    templateDialog(opened) {
      if (opened) {
        // this.$refs.templates.loadTemplates()
      }
    },
  },
  methods: {
    loadTemplate: async function (templateid) {
      this.$router.push(
        this.localeLocation({ path: `/submit/custom/${templateid}` })
      );
      this.templateDialog = false;
    }
  },
  data() {
    return {
      templateDialog: false
    };
  },
};
</script>
