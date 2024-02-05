<template>
  <v-container fluid class="ksa-submit">
    <v-card>
      <v-toolbar flat>
        <v-toolbar-title>Submit</v-toolbar-title>
        <v-divider class="mx-3" inset vertical></v-divider>
        <v-select
          :items="contentmodels"
          v-model="contentmodel"
          label="Object type"
          single-line
          v-on:change="resetForm($event)"
        ></v-select>
        <v-spacer></v-spacer>
      </v-toolbar>
      <v-card-text>
        <p-i-form
          :form="form"
          :rights="rights"
          :enablerights="true"
          :validate="validate"
          v-on:load-form="form = $event"
          v-on:object-created="objectCreated($event)"
          v-on:add-phaidrasubject-section="addPhaidrasubjectSection($event)"
          v-on:input-rights="rights = $event"
        ></p-i-form>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>
import fields from "phaidra-vue-components/src/utils/fields";
import { context } from "../../../mixins/context";

export default {
  mixins: [context],
  computed: {
    vocabularies: function () {
      return this.$store.state.vocabulary.vocabularies;
    },
  },
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
  watch: {
    contentmodel: function (val) {
      for (var i = 0; i < this.form.sections.length; i++) {
        for (var j = 0; j < this.form.sections[i].fields.length; j++) {
          if (this.form.sections[i].fields[j].predicate === "dcterms:type") {
            this.form.sections[i].fields[j].value = this.contentmodel;
            return;
          }
        }
      }
    },
  },
  methods: {
    validate: function () {
      return true;
    },
    objectCreated: function (event) {
      this.$router.push(this.localeLocation({ path: `/detail/${event}` }));
      this.$vuetify.goTo(0);
    },
    resetForm: function (cm) {
      if (cm === "https://pid.phaidra.org/vocabulary/8MY0-BQDQ") {
        this.createContainerForm();
        this.setLangGerman();
      } else {
        this.createSimpleForm();
        this.setLangGerman();
      }
    },
    setLangGerman: function () {
      for (let s of this.form.sections) {
        for (let f of s.fields) {
          if (f.language === "eng") {
            f.language = "deu";
          }
          if (f.nameLanguage === "eng") {
            f.nameLanguage = "deu";
          }
          if (f.descriptionLanguage === "eng") {
            f.descriptionLanguage = "deu";
          }
        }
      }
    },
    createSimpleForm: function (index) {
      this.form = {
        sections: [
          {
            title: "General metadata",
            type: "digitalobject",
            id: 1,
            fields: [],
          },
          {
            title: "Represented object",
            type: "phaidra:Subject",
            removable: true,
            id: 2,
            fields: [],
          },
          {
            title: "Represented object",
            type: "phaidra:Subject",
            id: 3,
            multiplicable: true,
            removable: true,
            fields: [],
          },
          {
            title: "File",
            id: 4,
            type: "",
            multiplicable: false,
            fields: [],
          },
        ],
      };
      var rt = fields.getField("resource-type");
      rt.value = this.contentmodel;
      this.form.sections[0].fields.push(rt);
      this.form.sections[0].fields.push(fields.getField("title"));
      this.form.sections[0].fields.push(fields.getField("description"));
      this.form.sections[0].fields.push(
        fields.getField("sociocultural-category")
      );
      this.form.sections[0].fields.push(fields.getField("keyword"));
      var lang = fields.getField("language");
      lang.value = "deu";
      this.form.sections[0].fields.push(lang);
      this.form.sections[0].fields.push(fields.getField("role"));
      this.form.sections[0].fields.push(fields.getField("note"));
      this.form.sections[0].fields.push(fields.getField("project"));
      this.form.sections[0].fields.push(fields.getField("funder"));

      let lvlDig = fields.getField("level-of-description")
      lvlDig.value = 'https://pid.phaidra.org/vocabulary/HQ7N-3Q2W'
      this.form.sections[1].fields.push(lvlDig);
      this.form.sections[1].fields.push(fields.getField("title"));
      this.form.sections[1].fields.push(fields.getField("role"));
      this.form.sections[1].fields.push(fields.getField("shelf-mark"));
      this.form.sections[1].fields.push(fields.getField("temporal-coverage"));
      this.form.sections[1].fields.push(fields.getField("provenance"));
      this.form.sections[1].fields.push(fields.getField("physical-location"));
      // eingangsdatum
      var accessiondate = fields.getField("date-edtf");
      accessiondate.type = "phaidra:dateAccessioned";
      this.form.sections[1].fields.push(accessiondate);
      this.form.sections[1].fields.push(fields.getField("accession-number"));
      this.form.sections[1].fields.push(fields.getField("condition-note"));
      this.form.sections[1].fields.push(fields.getField("reproduction-note"));
      this.form.sections[1].fields.push(fields.getField("technique-vocab"));
      this.form.sections[1].fields.push(fields.getField("technique-text"));
      this.form.sections[1].fields.push(fields.getField("material-text"));
      this.form.sections[1].fields.push(fields.getField("height"));
      this.form.sections[1].fields.push(fields.getField("width"));
      this.form.sections[1].fields.push(fields.getField("inscription"));
      let spgs = fields.getField("spatial-geonames");
      spgs.showtype = true;
      spgs.removable = true;
      this.form.sections[1].fields.push(spgs);
      var localname = fields.getField("spatial-text");
      localname.label = "Depicted/Represented place (native name)";
      this.form.sections[1].fields.push(localname);

      let lvlRep = fields.getField("level-of-description")
      lvlRep.value = 'https://pid.phaidra.org/vocabulary/TG30-5EM3'
      this.form.sections[2].fields.push(lvlRep);
      this.form.sections[2].fields.push(fields.getField("title"));
      this.form.sections[2].fields.push(fields.getField("description"));
      this.form.sections[2].fields.push(fields.getField("shelf-mark"));
      this.form.sections[2].fields.push(fields.getField("temporal-coverage"));
      this.form.sections[2].fields.push(fields.getField("provenance"));
      this.form.sections[2].fields.push(fields.getField("physical-location"));
      this.form.sections[2].fields.push(fields.getField("role"));
      // eingangsdatum
      var accessiondate2 = fields.getField("date-edtf");
      accessiondate2.type = "phaidra:dateAccessioned";
      this.form.sections[2].fields.push(accessiondate2);
      this.form.sections[2].fields.push(fields.getField("accession-number"));
      this.form.sections[2].fields.push(fields.getField("technique-text"));
      this.form.sections[2].fields.push(fields.getField("material-text"));
      this.form.sections[2].fields.push(fields.getField("height"));
      this.form.sections[2].fields.push(fields.getField("width"));
      this.form.sections[2].fields.push(fields.getField("depth"));

      this.form.sections[3].fields.push(fields.getField("file"));
      this.form.sections[3].fields.push(fields.getField("license"));
      this.form.sections[3].fields.push(fields.getField("rights"));
    },
    createContainerForm: function (index) {
      this.createSimpleForm();
      this.form.sections[3] = {
        title: "File",
        id: 4,
        type: "member",
        multiplicable: true,
        fields: [],
      };
      this.form.sections[3].fields.push(fields.getField("file"));
      this.form.sections[3].fields.push(fields.getField("title"));
      this.form.sections[3].fields.push(fields.getField("description"));
      this.form.sections[3].fields.push(fields.getField("digitization-note"));
      this.form.sections[3].fields.push(fields.getField("role"));
      this.form.sections[3].fields.push(fields.getField("license"));
      this.form.sections[3].fields.push(fields.getField("rights"));
    },
    addPhaidrasubjectSection: function (afterSection) {
      let s = {
        title: "SUBJECT_SECTION",
        type: "phaidra:Subject",
        id: this.form.sections.length + 1,
        removable: true,
        multiplicable: true,
        fields: [],
      };
      this.form.sections.splice(
        this.form.sections.indexOf(afterSection) + 1,
        0,
        s
      );
    },
  },
  mounted: async function () {
    this.createContainerForm();
    this.setLangGerman();
  },
};
</script>

<style>
</style>
