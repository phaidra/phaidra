<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12">
        <p-i-form
          :form="form"
          :rights="rights"
          :enablerights="false"
          :enablerelationships="false"
          :enablepreview="true"
          :templating="true"
          :importing="false"
          :addbutton="true"
          :mouseoverfielddef="true"
          :help="false"
          :debug="false"
          :feedback="false"
          v-on:load-form="form = $event"
          v-on:load-rights="rights = $event"
          v-on:object-created="objectCreated($event)"
          v-on:form-input-resource-type="handleInputResourceType($event)"
          v-on:input-rights="rights = $event"
        ></p-i-form>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import arrays from "phaidra-vue-components/src/utils/arrays"
import fields from "phaidra-vue-components/src/utils/fields"
import { context } from "../../mixins/context"
import { config } from "../../mixins/config"
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary"

export default {
  layout: "main",
  mixins: [context, config, vocabulary],
  data() {
    return {
      form: { sections: [] },
      rights: {},
    };
  },
  methods: {
    addRemovedFieldsCol: function (rt) {
      let haslicense = false;
      for (let s of this.form.sections) {
        for (let f of s.fields) {
          if (f.predicate === "edm:rights") {
            haslicense = true;
          }
        }
      }
      if (!haslicense) {
        let f = fields.getField("license")
        f.label = f.label + ' *'
        f.showValueDefinition = true;
        f.vocabulary = "alllicenses";
        this.form.sections[0].fields.push(f);
      }
      let hasfile = false;
      for (let s of this.form.sections) {
        for (let f of s.fields) {
          if (f.component === "p-file") {
            hasfile = true;
          }
        }
      }
      if (!hasfile) {
        let file = fields.getField("file");
        file.fileInputClass = "mb-2";
        file.showMimetype = false;
        file.backgroundColor = '#0063a620';
        this.form.sections[0].fields.splice(1, 0, file);
      }
      let hasObjectType2 = false;
      for (let s of this.form.sections) {
        for (let f of s.fields) {
          if (f.predicate === "edm:hasType") {
            hasObjectType2 = true;
            f.selectedTerms = [];
          }
        }
      }
      if (!hasObjectType2) {
        let otf2 = fields.getField("object-type-checkboxes");
        let rtv2;
        for (let s of this.form.sections) {
          for (let f of s.fields) {
            if (f.predicate === "dcterms:type") {
              rtv2 = f.value;
            }
          }
        }
        otf2.resourceType = rtv2;
        otf2.showLabel = true;
        this.form.sections[0].fields.splice(2, 0, otf2);
      }
    },
    markOefosMandatory: function () {
      if (this.instanceconfig.markmandatoryfnc) {
        if (this.instanceconfig.markmandatoryfnc === 'markMandatoryWithOefosAndAssoc') {
          for (const s of this.form.sections) {
            for (const f of s.fields) {
              if (f.component === 'p-subject-oefos') {
                f.label = this.$t('Subject (ÖFOS)') + ' *'
              }
            }
          }
        }
      }
    },
    unmarkOefosMandatory: function () {
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.component === 'p-subject-oefos') {
            f.label = this.$t('Subject (ÖFOS)')
          }
        }
      }
    },
    handleInputResourceType: function (rt) {
      switch (rt) {
        case "https://pid.phaidra.org/vocabulary/44TN-P1S0":
          // add fields which were removed if switching from collection
          this.addRemovedFieldsCol(rt);
          // image => remove language
          for (let s of this.form.sections) {
            for (let f of s.fields) {
              if (f.predicate === "dcterms:language") {
                arrays.remove(s.fields, f);
                break;
              }
            }
          }
          this.markOefosMandatory()
          break;
        case "https://pid.phaidra.org/vocabulary/GXS7-ENXJ":
          // collection => remove file, language, license, oefos and object type field
          for (let s of this.form.sections) {
            for (let f of s.fields) {
              if (f.component === "p-file") {
                arrays.remove(s.fields, f);
                break;
              }
            }
          }
          for (let s of this.form.sections) {
            for (let f of s.fields) {
              if (f.predicate === "dcterms:language") {
                arrays.remove(s.fields, f);
                break;
              }
            }
          }
          for (let s of this.form.sections) {
            for (let f of s.fields) {
              if (f.predicate === "edm:hasType") {
                arrays.remove(s.fields, f);
                break;
              }
            }
          }
          for (let s of this.form.sections) {
            for (let f of s.fields) {
              if (f.predicate === "edm:rights") {
                arrays.remove(s.fields, f);
                break;
              }
            }
          }
          this.unmarkOefosMandatory()
          break;
        default:
          // add fields which were removed if switching from collection
          this.addRemovedFieldsCol(rt);
          // add language (removed if switching from picture or collection)
          let hasLang = false;
          for (let s of this.form.sections) {
            for (let f of s.fields) {
              if (f.predicate === "dcterms:language") {
                hasLang = true;
              }
            }
          }
          if (!hasLang) {
            let lang = fields.getField("language");
            lang.value = this.$i18n.locale;
            lang.label = "Language of object";
            this.form.sections[0].fields.splice(5, 0, lang);
          }
          this.markOefosMandatory()
          break;
      }
    },
    objectCreated: function (event) {
      this.$router.push(this.localeLocation({ path: `/detail/${event}` }));
      this.$vuetify.goTo(0);
    },
    createForm: async function (self, index) {
      self.$store.dispatch("vocabulary/sortObjectTypes", this.$i18n.locale);

      // mixin
      self.validationError = false;
      self.mandatoryFieldsFound = {};
      self.mandatoryFieldsFilled = {};

      self.form = {
        sections: [
          {
            title: null,
            type: "digitalobject",
            id: 1,
            fields: [],
          },
        ],
      };

      let defaultResourceType = "https://pid.phaidra.org/vocabulary/44TN-P1S0";

      let rt = fields.getField("resource-type-buttongroup");
      rt.vocabulary = "resourcetypenocontainer";
      rt.value = defaultResourceType;
      self.form.sections[0].fields.push(rt);

      let otoer = fields.getField("object-type");
      otoer.value = 'https://pid.phaidra.org/vocabulary/YA8R-1M0D'
      otoer.hidden = true;
      self.form.sections[0].fields.push(otoer);

      let ot = fields.getField("object-type");
      ot.label = 'Learning object type'
      ot.showLabel = true
      ot.vocabulary = 'oerobjecttype'
      self.form.sections[0].fields.push(ot);

      let file = fields.getField("file");
      file.fileInputClass = "mb-2";
      file.showMimetype = false;
      file.backgroundColor = '#0063a620';
      self.form.sections[0].fields.push(file);

      self.form.sections[0].fields.push(fields.getField("title"));

      let lang = fields.getField("language");
      lang.value = this.$i18n.locale;
      lang.label = "Language of object";
      self.form.sections[0].fields.push(lang);

      self.form.sections[0].fields.push(fields.getField("description"));

      let kw = fields.getField("keyword");
      kw.disableSuggest = true;
      self.form.sections[0].fields.push(kw);

      let role = fields.getField("role");
      role.ordergroup = "role";
      role.role = 'role:aut'
      role.roleVocabulary = "submitrolepredicate";
      role.identifierType = "ids:orcid";
      role.showDefinitions = true;
      role.showIdentifier = true;
      self.form.sections[0].fields.push(role);

      self.form.sections[0].fields.push(fields.getField("oefos-subject"));
      self.form.sections[0].fields.push(fields.getField("association"));

      self.form.sections[0].fields.push(fields.getField("audience"));

      let lic = fields.getField("license");
      lic.showValueDefinition = true;
      lic.vocabulary = "oerlicenses";
      self.form.sections[0].fields.push(lic);

      for (let s of self.form.sections) {
        for (let f of s.fields) {
          f.multilingual = true
          for (let prop of Object.keys(f)) {
            switch (prop) {
              case "language":
                f.language = self.$i18n.locale;
                break;
              case "nameLanguage":
                f.nameLanguage = self.$i18n.locale;
                break;
              case "funderNameLanguage":
                f.funderNameLanguage = self.$i18n.locale;
                break;
              case "descriptionLanguage":
                f.descriptionLanguage = self.$i18n.locale;
                break;
              case "titleLanguage":
                f.titleLanguage = self.$i18n.locale;
                break;
              case "citationLanguage":
                f.citationLanguage = self.$i18n.locale;
                break;
            }
          }
        }
      }
      
    },
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      await vm.createForm(vm);
    });
  },
  beforeRouteUpdate: async function (to, from, next) {
    await this.createForm(this);
    next();
  },
};
</script>