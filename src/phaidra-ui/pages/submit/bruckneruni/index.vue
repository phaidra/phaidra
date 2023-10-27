<template>
  <p-i-form
    :form="form"
    :rights="rights"
    :enablerights="true"
    :validate="validate"
    v-on:load-form="form = $event"
    v-on:object-created="objectCreated($event)"
    v-on:form-input-p-select="handleSelect($event)"
    v-on:add-phaidrasubject-section="addPhaidrasubjectSection($event)"
    v-on:input-rights="rights = $event"
  ></p-i-form>
</template>

<script>
import fields from "phaidra-vue-components/src/utils/fields";
import { context } from "../../../mixins/context";
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary";

export default {
  mixins: [context, vocabulary],
  data() {
    return {
      contentmodel: "https://pid.phaidra.org/vocabulary/8MY0-BQDQ",
      contentmodels: [
        {
          text: "Data",
          value: "https://pid.phaidra.org/vocabulary/7AVS-Y482",
        },
        {
          text: "Picture",
          value: "https://pid.phaidra.org/vocabulary/44TN-P1S0",
        },
        {
          text: "Audio",
          value: "https://pid.phaidra.org/vocabulary/8YB5-1M0J",
        },
        {
          text: "Video",
          value: "https://pid.phaidra.org/vocabulary/B0Y6-GYT8",
        },
        {
          text: "Document",
          value: "https://pid.phaidra.org/vocabulary/69ZZ-2KGX",
        },
        {
          text: "Container",
          value: "https://pid.phaidra.org/vocabulary/8MY0-BQDQ",
        },
      ],
      form: { sections: [] },
      rights: {},
    };
  },
  methods: {
    validate: function () {
      return true;
    },
    getResourceTypeFromMimeType: function (mime) {
      switch (mime) {
        case "image/jpeg":
        case "image/tiff":
        case "image/gif":
        case "image/png":
        case "image/x-ms-bmp":
          // picture
          return "https://pid.phaidra.org/vocabulary/44TN-P1S0";

        case "audio/wav":
        case "audio/mpeg":
        case "audio/flac":
        case "audio/ogg":
          // audio
          return "https://pid.phaidra.org/vocabulary/8YB5-1M0J";

        case "application/pdf":
          // document
          return "https://pid.phaidra.org/vocabulary/69ZZ-2KGX";

        case "video/mpeg":
        case "video/avi":
        case "video/mp4":
        case "video/quicktime":
        case "video/x-matroska":
          // video
          return "https://pid.phaidra.org/vocabulary/B0Y6-GYT8";

        // should currently not happen, nothing else is in the selectbox
        default:
          // data
          return "https://pid.phaidra.org/vocabulary/7AVS-Y482";
      }
    },
    handleSelect: function (val) {
      var i;
      var j;
      var k;
      if (val.predicate === "ebucore:hasMimeType") {
        for (i = 0; i < this.form.sections.length; i++) {
          if (this.form.sections[i].type === "member") {
            var mime;
            for (j = 0; j < this.form.sections[i].fields.length; j++) {
              if (
                this.form.sections[i].fields[j].predicate ===
                "ebucore:hasMimeType"
              ) {
                mime = this.form.sections[i].fields[j].value;
              }
            }
            var resourcetype = this.getResourceTypeFromMimeType(mime);
            for (j = 0; j < this.form.sections[i].fields.length; j++) {
              if (
                this.form.sections[i].fields[j].predicate === "dcterms:type"
              ) {
                var rt = this.form.sections[i].fields[j];
                rt.value = resourcetype;
                var preflabels;
                for (
                  k = 0;
                  k < this.vocabularies["resourcetype"].terms.length;
                  k++
                ) {
                  if (
                    this.vocabularies["resourcetype"].terms[k]["@id"] ===
                    rt.value
                  ) {
                    preflabels =
                      this.vocabularies["resourcetype"].terms[k][
                        "skos:prefLabel"
                      ];
                  }
                }
                rt["skos:prefLabel"] = [];
                Object.entries(preflabels).forEach(([key, value]) => {
                  rt["skos:prefLabel"].push({
                    "@value": value,
                    "@language": key,
                  });
                });
              }
            }
            this.form.sections.splice(i, 1, this.form.sections[i]);
          }
        }
      }
    },
    objectCreated: function (event) {
      this.$router.push(this.localeLocation({ path: `/detail/${event}` }));
      this.$vuetify.goTo(0);
    },
    resetForm: function (cm) {
      this.createContainerForm();
      this.setLangGerman();
    },
    setLangGerman: function () {
      for (var i = 0; i < this.form.sections.length; i++) {
        for (var j = 0; j < this.form.sections[i].fields.length; j++) {
          if (this.form.sections[i].fields[j].language === "eng") {
            this.form.sections[i].fields[j].language = "deu";
          }
          if (this.form.sections[i].fields[j].nameLanguage === "eng") {
            this.form.sections[i].fields[j].nameLanguage = "deu";
          }
          if (this.form.sections[i].fields[j].descriptionLanguage === "eng") {
            this.form.sections[i].fields[j].descriptionLanguage = "deu";
          }
        }
      }
    },
    createContainerForm: function (index) {
      this.form = {
        sections: [
          {
            title: "General metadata",
            type: "digitalobject",
            id: 1,
            fields: [],
          },
          {
            title: "File",
            id: 2,
            type: "member",
            multiplicable: true,
            fields: [],
          },
        ],
      };
      var rt = fields.getField("resource-type");
      rt.value = this.contentmodel;
      this.form.sections[0].fields.push(rt);

      this.form.sections[0].fields.push(fields.getField("object-type"));

      this.form.sections[0].fields.push(fields.getField("title"));

      let paralleltit = fields.getField("title");
      paralleltit.type = "bf:ParallelTitle";
      this.form.sections[0].fields.push(paralleltit);

      this.form.sections[0].fields.push(fields.getField("role"));

      this.form.sections[0].fields.push(fields.getField("bf-publication"));

      this.form.sections[0].fields.push(fields.getField("description"));

      this.form.sections[0].fields.push(fields.getField("note"));

      var lang = fields.getField("language");
      lang.value = "deu";
      this.form.sections[0].fields.push(lang);

      this.form.sections[0].fields.push(fields.getField("keyword"));

      this.form.sections[0].fields.push(fields.getField("gnd-subject"));

      this.form.sections[0].fields.push(fields.getField("temporal-coverage"));

      this.form.sections[0].fields.push(fields.getField("date-edtf"));

      this.form.sections[1].fields.push(fields.getField("file"));

      this.form.sections[1].fields.push(fields.getField("title"));

      let paralleltit2 = fields.getField("title");
      paralleltit2.type = "bf:ParallelTitle";
      this.form.sections[1].fields.push(paralleltit2);

      this.form.sections[1].fields.push(fields.getField("role"));

      this.form.sections[1].fields.push(fields.getField("bf-publication"));

      this.form.sections[1].fields.push(fields.getField("description"));

      this.form.sections[1].fields.push(fields.getField("note"));

      var lang2 = fields.getField("language");
      lang2.value = "deu";
      this.form.sections[1].fields.push(lang2);

      this.form.sections[1].fields.push(fields.getField("keyword"));

      this.form.sections[1].fields.push(fields.getField("gnd-subject"));

      this.form.sections[1].fields.push(fields.getField("temporal-coverage"));

      this.form.sections[1].fields.push(fields.getField("date-edtf"));

      this.form.sections[1].fields.push(fields.getField("carrier-type"));

      this.form.sections[1].fields.push(fields.getField("duration"));

      this.form.sections[1].fields.push(fields.getField("inscription"));

      this.form.sections[1].fields.push(fields.getField("material-text"));

      this.form.sections[1].fields.push(fields.getField("technique-text"));

      let width = fields.getField("width");
      width.vocabulary = "uncefactsize";
      this.form.sections[1].fields.push(width);

      let height = fields.getField("height");
      height.vocabulary = "uncefactsize";
      this.form.sections[1].fields.push(height);

      let depth = fields.getField("depth");
      depth.vocabulary = "uncefactsize";
      this.form.sections[1].fields.push(depth);

      let weight = fields.getField("weight");
      weight.vocabulary = "uncefactweight";
      this.form.sections[1].fields.push(weight);

      this.form.sections[1].fields.push(fields.getField("provenance"));

      this.form.sections[1].fields.push(fields.getField("shelf-mark"));

      this.form.sections[1].fields.push(fields.getField("physical-location"));

      this.form.sections[1].fields.push(fields.getField("license"));

      this.form.sections[1].fields.push(fields.getField("rights"));
    },
  },
  mounted: function () {
    this.createContainerForm();
    this.setLangGerman();
  },
};
</script>

<style>
</style>
