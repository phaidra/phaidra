<template>
  <v-card flat>
    <v-card-text>
      <v-col cols="12" v-if="this.form.length > 0">
        <v-container fluid v-if="objectType !== 'collection'">
          <client-only>
            <v-text-field
              v-if="objectType === 'resource'"
              :label="$t('Link')"
              :placeholder="'https://...'"
              v-model="link"
              outlined
              :error-messages="linkErrorMessages"
            ></v-text-field>
            <p-i-file
              v-else
              v-bind.sync="fileField"
              :mimetype="mimetype"
              v-on:input-file="file = $event"
              v-on:input-mimetype="mimetype = $event ? $event['@id'] : $event"
              input-style="outlined"
              :auto-mimetype="true"
              :fileErrorMessages="fileErrorMessages"
              :mimetypeErrorMessages="mimetypeErrorMessages"
              :disabled="loading"
            ></p-i-file>
          </client-only>
        </v-container>
        <client-only>
          <p-i-form-uwm
            ref="submitform"
            :form="form"
            :disabled="loading"
            v-on:object-saved="objectSaved($event)"
            v-on:load-form="form = $event"
          ></p-i-form-uwm>
        </client-only>
      </v-col>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn
        fixed
        bottom
        right
        large
        :disabled="loading"
        :loading="loading"
        class="primary mr-8"
        @click="save()"
        >{{ $t("Submit") }}</v-btn
      >
    </v-card-actions>
  </v-card>
</template>

<script>
import fields from "phaidra-vue-components/src/utils/fields";
import { context } from "../../../mixins/context";
import { config } from "../../../mixins/config";
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary";

export default {
  mixins: [config, context, vocabulary],
  computed: {
    alpha2locale: function () {
      switch (this.$i18n.locale) {
        case 'eng': return 'en'
        case 'deu': return 'de'
        case 'ita': return 'it'
        default: return 'en'
      }
    },
    objectType: function () {
      if (this.$route.params.cmodel === "collection") {
        return "collection";
      }
      if (this.$route.params.cmodel === "resource") {
        return "resource";
      }
      switch (this.mimetype) {
        case "image/jpeg":
        case "image/tiff":
        case "image/gif":
        case "image/png":
        case "image/x-ms-bmp":
          return "picture";

        case "audio/wav":
        case "audio/mpeg":
        case "audio/flac":
        case "audio/ogg":
          return "audio";

        case "application/pdf":
          return "document";

        case "video/mpeg":
        case "video/avi":
        case "video/mp4":
        case "video/quicktime":
        case "video/x-matroska":
          return "video";

        default:
          return "unknown";
      }
    },
  },
  data() {
    return {
      loading: false,
      form: [],
      file: null,
      mimetype: "",
      fileField: fields.getField("file"),
      mimetypeErrorMessages: [],
      fileErrorMessages: [],
      linkErrorMessages: [],
      link: "",
    };
  },
  methods: {
    objectSaved: function (event) {
      this.$store.commit("setAlerts", [
        { type: "success", msg: "Object " + event + " created" },
      ]);
      this.$router.push(this.localeLocation({ path: `/detail/${event}` }));
      this.$vuetify.goTo(0);
    },
    loadUwmetadata: async function (self) {
      self.loading = true;
      this.file = null;
      this.mimetype = "";
      this.form = [];
      try {
        let response = await self.$axios.request({
          method: "GET",
          url: "/uwmetadata/tree",
          params: {
            mode: "full",
          },
        });
        if (response.data.alerts && response.data.alerts.length > 0) {
          self.$store.commit("setAlerts", response.data.alerts);
        }
        if (response.data.tree) {
          self.form = response.data.tree;
          this.setLanguageRec(self.form)
        }
      } catch (error) {
        console.log(error);
      } finally {
        self.loading = false;
      }
    },
    setLanguageRec: function (nodes) {
      for (const n of nodes) {
        if (n.input_type === 'language_select') {
          n.ui_value = this.alpha2locale
        }
        n.value_lang = this.alpha2locale
        if (n.children && (n.children.length > 0)) {
          this.setLanguageRec(n.children)
        }
      }
    },
    getMetadata: function () {
      let md = { metadata: { uwmetadata: this.form } };
      if (this.objectType === "resource") {
        md["metadata"]["resourcelink"] = this.link;
      }
      return md;
    },
    save: async function () {
      let valid = this.$refs.submitform.validate();
      this.fileErrorMessages = [];
      this.linkErrorMessages = [];
      this.mimetypeErrorMessages = [];
      if (this.objectType !== "collection") {
        if (this.objectType === "resource") {
          if (this.link.length < 1) {
            this.linkErrorMessages.push(this.$t("Missing link"));
            valid = false;
          }
        } else {
          if (!this.file) {
            this.fileErrorMessages.push(this.$t("Missing file"));
            valid = false;
          }
          if (!this.mimetype) {
            this.mimetypeErrorMessages.push(this.$t("Missing file type"));
            valid = false;
          }
        }
      }
      if (valid) {
        this.loading = true;
        var httpFormData = new FormData();
        httpFormData.append("metadata", JSON.stringify(this.getMetadata()));
        if (
          this.objectType !== "resource" &&
          this.objectType !== "collection"
        ) {
          httpFormData.append("file", this.file);
          httpFormData.append("mimetype", this.mimetype);
        }
        try {
          let response = await this.$axios.request({
            method: "POST",
            url: "/" + this.objectType + "/create",
            headers: {
              "Content-Type": "multipart/form-data",
              "X-XSRF-TOKEN": this.user.token,
            },
            data: httpFormData,
          });
          if (response.data.status === 200) {
            if (response.data.pid) {
              this.$router.push(
                this.localeLocation({
                  path: `/detail/${response.data.pid}`,
                })
              );
            }
          } else {
            if (response.data.alerts && response.data.alerts.length > 0) {
              if (response.data.status === 401) {
                response.data.alerts.push({
                  type: "error",
                  msg: "Please log in",
                });
              }
              this.$store.commit("setAlerts", response.data.alerts);
            }
          }
        } catch (error) {
          console.log(error);
          this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
        } finally {
          this.$vuetify.goTo(0);
          this.loading = false;
        }
      }
    },
  },
  beforeRouteEnter: function (to, from, next) {
    next((vm) => {
      vm.$store.commit("setLoading", true);
      vm.loadUwmetadata(vm).then(() => {
        vm.$store.commit("setLoading", false);
        next();
      });
    });
  },
  beforeRouteUpdate: function (to, from, next) {
    this.$store.commit("setLoading", true);
    this.loadUwmetadata(this).then(() => {
      this.$store.commit("setLoading", false);
      next();
    });
  },
};
</script>
