<template>
  <v-container fluid>
    <v-alert
      :value="validationError"
      dismissible
      type="error"
      transition="slide-y-transition"
    >
      <span>{{ $t("Please fill in the required fields") }}</span>
      <template v-if="fieldsMissing.length > 0">
        <br />
        <span>{{ $t("Some required fields are missing") }}:</span>
        <ul>
          <li v-for="(f, i) in fieldsMissing" :key="'mfld' + i">{{ f }}</li>
        </ul>
      </template>
    </v-alert>
    <v-row>
      <v-col cols="12">
        <p-i-form
          :form="form"
          :rights="rights"
          :enablerights="true"
          :enablerelationships="false"
          :enablepreview="true"
          :templating="false"
          :importing="false"
          :addbutton="true"
          :mouseoverfielddef="true"
          :help="false"
          :debug="false"
          :feedback="true"
          :feedback-user="this.user"
          :feedback-context="'Upload'"
          :validate="validationMethod"
          v-on:load-form="form = $event"
          v-on:object-created="objectCreated($event)"
          v-on:form-input-resource-type="handleInputResourceType($event)"
          v-on:input-rights="rights = $event"
        ></p-i-form>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import arrays from "phaidra-vue-components/src/utils/arrays";
import fields from "phaidra-vue-components/src/utils/fields";
import { context } from "../../mixins/context";
import { config } from "../../mixins/config";
import { formvalidation } from "../../mixins/formvalidation";
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary";

export default {
  layout: "main",
  mixins: [context, config, vocabulary, formvalidation],
  data() {
    return {
      form: { sections: [] },
      rights: {},
    };
  },
  methods: {
    validationMethod: function () {
      if (this.instanceconfig.submit?.validationmethod) {
        return this[this.instanceconfig.submit?.validationmethod]()
      }
      return this.validate()
    },
    markMandatoryMethod: function() {
      if (this.instanceconfig.submit?.markmandatorymethod) {
        return this[this.instanceconfig.submit?.markmandatorymethod]()
      }
      return this.markMandatory()
    },
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
        this.form.sections[0].fields.splice(1, 0, fields.getField("file"));
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
        this.form.sections[0].fields.splice(2, 0, otf2);
      }
    },
    markOefosMandatory: function () {
      if (this.instanceconfig.submit?.markmandatorymethod) {
        if (this.instanceconfig.submit?.markmandatorymethod === 'markMandatoryNoOefosNoAssoc') {
          return
        }
      }
      for (const s of this.form.sections) {
        for (const f of s.fields) {
          if (f.component === 'p-subject-oefos') {
            f.label = this.$t('Subject (ÖFOS)') + ' *'
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

      self.validationError = false;
      self.fieldsMissing = [];

      let settres = await self.$axios.get("/app_settings", {
        headers: {
          "X-XSRF-TOKEN": self.$store.state.user.token,
        },
      });
      if (settres?.data?.settings?.defaultTemplateId) {
        try {
          let tmpres = await self.$axios.request({
            method: 'GET',
            url: '/jsonld/template/' + settres?.data?.settings?.defaultTemplateId,
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

        let title = fields.getField("title")
        title.multilingual = false
        self.form.sections[0].fields.push(title);

        let description = fields.getField("description")
        description.multilingual = false
        self.form.sections[0].fields.push(description);

        let lang = fields.getField("language");
        lang.value = this.$i18n.locale;
        lang.label = "Language of object";
        self.form.sections[0].fields.push(lang);

        let kw = fields.getField("keyword");
        kw.multilingual = false;
        kw.disableSuggest = true;
        self.form.sections[0].fields.push(kw);

        let role = fields.getField("role");
        role.ordergroup = "role";
        role.roleVocabulary = "submitrolepredicate";
        role.identifierType = "ids:orcid";
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

        let tempcov = fields.getField("temporal-coverage")
        tempcov.multilingual = false;
        self.form.sections[2].fields.push(tempcov);
        let place = fields.getField("spatial-geonames");
        place.showtype = false;
        self.form.sections[2].fields.push(place);

        let proj = fields.getField("project")
        proj.multilingual = false
        self.form.sections[3].fields.push(proj);

        self.form.sections[4].fields.push(fields.getField("date-edtf"));
        let inscrip = fields.getField("inscription")
        inscrip.multilingual = false
        self.form.sections[4].fields.push(inscrip);
        self.form.sections[4].fields.push(fields.getField("shelf-mark"));
        self.form.sections[4].fields.push(fields.getField("accession-number"));
        let prov = fields.getField("provenance")
        prov.multilingual = false
        self.form.sections[4].fields.push(prov);
        self.form.sections[4].fields.push(fields.getField("production-company"));
        self.form.sections[4].fields.push(fields.getField("production-place"));
        let loc = fields.getField("physical-location")
        loc.multilingual = false
        self.form.sections[4].fields.push(loc);
        let cond = fields.getField("condition-note")
        cond.multilingual = false
        self.form.sections[4].fields.push(cond);
        self.form.sections[4].fields.push(fields.getField("height"));
        self.form.sections[4].fields.push(fields.getField("width"));
        let mat = fields.getField("material-text")
        mat.multilingual = false
        self.form.sections[4].fields.push(mat);
        let tech = fields.getField("technique-text")
        tech.multilingual = false
        self.form.sections[4].fields.push(tech);

        self.form.sections[5].fields.push(fields.getField("alternate-identifier"))
        let published = fields.getField("date-edtf")
        published.type = 'dcterms:issued'
        self.form.sections[5].fields.push(published)
        self.form.sections[5].fields.push(fields.getField("volume"));
        self.form.sections[5].fields.push(fields.getField("issue"));
        self.form.sections[5].fields.push(fields.getField("series"));
        let publ = fields.getField("bf-publication")
        self.form.sections[5].fields.push(publ);

        self.markMandatoryMethod()

      }

      for (let s of self.form.sections) {
        for (let f of s.fields) {
          f.configurable = false
          for (let prop of Object.keys(f)) {
            switch (prop) {
              case "language":
                f.language = self.$i18n.locale;
                break;
              case "nameLanguage":
                f.nameLanguage = self.$i18n.locale;
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
