<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12">
        <p-i-form
          :form="form"
          :rights="rights"
          :enablerights="true"
          :enablerelationships="false"
          :enablepreview="true"
          :templating="false"
          :forcePreview="instanceconfig.forcePreview"
          :importing="false"
          :addbutton="true"
          :mouseoverfielddef="true"
          :help="false"
          :debug="false"
          :feedback="instanceconfig.feedback"
          :feedback-user="this.user"
          :feedback-context="'Upload'"
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
  metaInfo() {
    let metaInfo = {
      title: this.$t('Upload') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
  },
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
            f.label = this.$t('Object type') + ' *'
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
        otf2.label = this.$t('Object type') + ' *';
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
            this.form.sections[0].fields.splice(4, 0, lang);
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

      if (this.instanceconfig.defaulttemplateid) {
        try {
          let tmpres = await self.$axios.request({
            method: 'GET',
            url: '/jsonld/template/' + this.instanceconfig.defaulttemplateid,
            headers: {
              'X-XSRF-TOKEN': self.$store.state.user.token
            }
          })
          if (tmpres.data.alerts && tmpres.data.alerts.length > 0) {
            self.$store.commit('setAlerts', tmpres.data.alerts)
          }
          self.form = tmpres.data.template.form
          // if (tmpres.data.template.hasOwnProperty('skipValidation')) {
          //   self.skipValidation = tmpres.data.template.skipValidation
          // }
        } catch (error) {
          console.log(error)
          self.$store.commit('setAlerts', [{ type: 'error', msg: error }])
        } finally {
          self.loading = false
        }
      } else {

        self.form = {
          sections: [
            {
              title: null,
              type: "digitalobject",
              id: 1,
              fields: [],
            },
            {
              title: "Terminology services",
              mode: "expansion",
              addbutton: false,
              disablemenu: true,
              collapsed: true,
              outlined: true,
              id: 2,
              fields: [],
            },
            {
              title: "Coverage",
              mode: "expansion",
              addbutton: false,
              disablemenu: true,
              collapsed: true,
              outlined: true,
              id: 3,
              fields: [],
            },
            {
              title: "Project",
              mode: "expansion",
              addbutton: false,
              disablemenu: true,
              collapsed: true,
              outlined: true,
              id: 4,
              fields: [],
            },
            {
              title: "Represented object",
              type: "phaidra:Subject",
              mode: "expansion",
              disablemenu: true,
              collapsed: true,
              outlined: true,
              id: 5,
              fields: [],
            },
            {
              title: "Bibliographic metadata",
              mode: "expansion",
              addbutton: false,
              disablemenu: true,
              collapsed: true,
              outlined: true,
              id: 6,
              fields: [],
            },
            {
              title: "Accessibility",
              mode: "expansion",
              addbutton: false,
              disablemenu: true,
              collapsed: true,
              outlined: true,
              id: 7,
              fields: [],
            }
          ],
        };

        let defaultResourceType = "https://pid.phaidra.org/vocabulary/44TN-P1S0";

        let rt = fields.getField("resource-type-buttongroup");
        rt.vocabulary = "resourcetypenocontainer";
        rt.value = defaultResourceType;
        self.form.sections[0].fields.push(rt);

        let file = fields.getField("file");
        file.fileInputClass = "mb-2";
        file.showMimetype = false;
        file.backgroundColor = '#0063a620';
        self.form.sections[0].fields.push(file);

        let ot = fields.getField("object-type-checkboxes");
        ot.resourceType = defaultResourceType;
        ot.showLabel = true;
        self.form.sections[0].fields.push(ot);

        self.form.sections[0].fields.push(fields.getField("title"));
        self.form.sections[0].fields.push(fields.getField("description"));

        let lang = fields.getField("language");
        lang.value = this.$i18n.locale;
        lang.label = "Language of object";
        self.form.sections[0].fields.push(lang);

        let kw = fields.getField("keyword");
        kw.disableSuggest = true;
        self.form.sections[0].fields.push(kw);

        let role = fields.getField("role");
        role.ordergroup = "role";
        role.roleVocabulary = "submitrolepredicate";
        role.identifierType = "ids:orcid";
        role.showDefinitions = true;
        role.showIdentifier = true;
        self.form.sections[0].fields.push(role);

        self.form.sections[0].fields.push(fields.getField("oefos-subject"));
        self.form.sections[0].fields.push(fields.getField("association"));

        let lic = fields.getField("license");
        lic.showValueDefinition = true;
        lic.vocabulary = "alllicenses";
        self.form.sections[0].fields.push(lic);

        self.form.sections[1].fields.push(fields.getField("gnd-subject"));
        self.form.sections[1].fields.push(fields.getField("bk-subject"));

        self.form.sections[2].fields.push(fields.getField("temporal-coverage"));
        let place = fields.getField("spatial-geonames");
        place.showtype = false;
        self.form.sections[2].fields.push(place);

        self.form.sections[3].fields.push(fields.getField("project"));

        self.form.sections[4].fields.push(fields.getField("date-edtf"));
        self.form.sections[4].fields.push(fields.getField("inscription"));
        self.form.sections[4].fields.push(fields.getField("shelf-mark"));
        self.form.sections[4].fields.push(fields.getField("accession-number"));
        self.form.sections[4].fields.push(fields.getField("provenance"));
        self.form.sections[4].fields.push(fields.getField("production-company"));
        self.form.sections[4].fields.push(fields.getField("production-place"));
        self.form.sections[4].fields.push(fields.getField("physical-location"));
        self.form.sections[4].fields.push(fields.getField("condition-note"));
        self.form.sections[4].fields.push(fields.getField("height"));
        self.form.sections[4].fields.push(fields.getField("width"));
        self.form.sections[4].fields.push(fields.getField("material-text"));
        self.form.sections[4].fields.push(fields.getField("technique-text"));

        self.form.sections[5].fields.push(fields.getField("alternate-identifier"))
        let published = fields.getField("date-edtf")
        published.type = 'dcterms:issued'
        self.form.sections[5].fields.push(published)
        self.form.sections[5].fields.push(fields.getField("volume"));
        self.form.sections[5].fields.push(fields.getField("issue"));
        self.form.sections[5].fields.push(fields.getField("series"));
        let publ = fields.getField("bf-publication")
        self.form.sections[5].fields.push(publ);

        let ac1 = fields.getField("accessibility-control")
        ac1.multiplicable = true
        ac1.showValueDefinition = true;
        self.form.sections[6].fields.push(ac1);
        let ac2 = fields.getField("access-mode")
        ac2.multiplicable = true
        ac2.showValueDefinition = true;
        self.form.sections[6].fields.push(ac2);
        let ac3 = fields.getField("accessibility-hazard")
        ac3.multiplicable = true
        ac3.showValueDefinition = true;
        self.form.sections[6].fields.push(ac3);
        let ac4 = fields.getField("accessibility-feature")
        ac4.multiplicable = true
        ac4.showValueDefinition = true;
        self.form.sections[6].fields.push(ac4);
      }

      for (let s of self.form.sections) {
        for (let f of s.fields) {
          f.configurable = false
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