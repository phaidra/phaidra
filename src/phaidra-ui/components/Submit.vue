<template>
  <v-container fluid>
    <v-row class="my-6" justify="start">
      <div class="d-flex flex-row ml-6">
        <v-btn
          large
          class="primary"
          @click="$router.push(localePath('/submit/upload'))"
        >
          <v-icon dark class="mr-4">mdi-plus-circle</v-icon> {{ $t("Create new object") }}
        </v-btn>
        </div>
      <div class="d-flex flex-row pt-3 ml-6">
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
    <template v-if="instanceconfig.irbaseurl !== ''">
      <v-row class="my-6" justify="start">
        <div class="d-flex flex-row ml-6">
          <v-btn
            large
            class="primary"
            :href="'https://uscholar.univie.ac.at/login'"
          >
            <v-icon dark class="mr-4">mdi-school</v-icon> {{ $t("Upload publication (via u:scholar)") }}
          </v-btn>
        </div>
          <div class="d-flex flex-row pt-3 ml-6">
          {{
            $t(
              "Upload journal articles, reports, reviews, working papers, conference papers, monographs, individual chapters from monographs ..."
            )
          }}

        </div>
      </v-row>
      <v-divider class="my-2"></v-divider>
    </template>
    <template v-if="instanceconfig.uwmsubmit">
      <v-row class="my-6" justify="start">
        <v-col cols="12">
          <span class="title font-weight-light primary--text">{{
            $t("Legacy (Uwmetadata)")
          }}</span>
        </v-col>
      </v-row>
      <v-row class="my-6" justify="start">
        <v-col cols="12">
          <v-btn
            large
            dark
            color="grey white--text mr-8"
            :to="localePath({ path: '/submit/uwm/asset'})"
          >
            {{ $t("File") }}
          </v-btn>
          <v-btn
            large
            dark
            color="grey white--text mr-8"
            :to="localePath({ path: '/submit/uwm/collection'})"
          >
            {{ $t("Collection") }}
          </v-btn>
        </v-col>
      </v-row>
      <v-divider class="my-2"></v-divider>
    </template>
    <v-row class="my-6" justify="start">
      <div class="d-flex flex-row ml-6">
        <v-dialog class="pb-4" v-model="templateDialog" width="700px">
          <template v-slot:activator="{ on }">
            <v-btn v-on="on" large dark color="grey">
              <v-icon dark class="mr-4">mdi-script</v-icon>
              {{ $t("Open template") }}
            </v-btn>
          </template>
          <v-card>
            <v-card-title
              dark
              class="title font-weight-light grey white--text"
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
              ><v-btn @click="templateDialog = false">{{ $t("Cancel") }}</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </div>
      <div class="d-flex flex-row pt-3 ml-6">
        <span>
            {{
              $t(
                "Open a previously created upload template."
              )
            }}
          </span>
      </div>
    </v-row>
    <v-divider class="my-2"></v-divider>
    <v-row class="my-6" justify="start">
      <div class="d-flex flex-row ml-6">
        <v-btn
          large
          dark
          color="grey white--text"
          @click="$router.push(localePath({ path: '/submit/empty' }))"
        >
          <v-icon dark class="mr-4">mdi-script-outline</v-icon>
          {{ $t("Create new template") }}
        </v-btn>
      </div>
      <div class="d-flex flex-row pt-3 ml-6">
        <span>
            {{
              $t(
                "Compose your own upload form."
              )
            }}
          </span>
      </div>
    </v-row>
    <template v-if="false">
      <v-row class="my-6" justify="start">
        <v-col cols="12">
          <span class="title font-weight-light primary--text">{{
            $t("Legacy (Uwmetadata)")
          }}</span>
          <v-divider></v-divider>
        </v-col>
      </v-row>
      <v-row class="my-6" justify="start">
        <v-col cols="12">
          <v-btn
            large
            dark
            color="grey white--text mr-8"
            @click="$router.push(localePath({ path: '/submit/uwm/asset' }))"
          >
            {{ $t("File") }}
          </v-btn>
          <v-btn
            large
            dark
            color="grey white--text mr-8"
            @click="
              $router.push(localePath({ path: '/submit/uwm/collection' }))
            "
          >
            {{ $t("Collection") }}
          </v-btn>
        </v-col>
      </v-row>
    </template>
    <template
      v-if="
        this.user.username === 'ethnograpp95' ||
        this.user.username === 'ethnograps52' ||
        this.user.username === 'bib-phaidra' || this.user.username === 'hudakr4'
      "
    >
      <v-row class="my-6" justify="start">
        <v-col cols="12">
          <span class="title font-weight-light primary--text">{{
            $t("Extra")
          }}</span>
          <v-divider></v-divider>
        </v-col>
      </v-row>
      <v-row class="my-6" justify="start">
        <v-col cols="12">
          <v-btn
            v-if="
              this.user.username === 'ethnograpp95' ||
              this.user.username === 'ethnograps52' || this.user.username === 'hudakr4'
            "
            large
            dark
            color="grey white--text mr-8"
            @click="$router.push(localePath('/submit/ksa-eda'))"
          >
            <v-icon dark class="mr-4">mdi-file-star</v-icon> {{ $t("EDA") }}
          </v-btn>
          <v-btn
            v-if="this.user.username === 'bib-phaidra'"
            large
            dark
            color="grey white--text mr-8"
            @click="$router.push(localePath('/submit/bruckneruni'))"
          >
            <v-icon dark class="mr-4">mdi-file-star</v-icon>
            {{ $t("Bruckneruni") }}
          </v-btn>
        </v-col>
      </v-row>
    </template>
  </v-container>
</template>

<script>
import { context } from "../mixins/context";
import { config } from "../mixins/config";

export default {
  mixins: [context,config],
  middleware: "auth",
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
