<template>
  <v-container fluid>
    <v-row>
      <v-col>
        <p-i-form 
        :form="form" 
        :rights="rights" 
        :enablerights="true" 
        :addbutton="true" 
        :templating="templating"
        :validationfnc="validationfnc ? validationfnc : null" 
        v-on:load-form="form = $event" 
        v-on:load-rights="rights = $event"
        v-on:object-created="objectCreated($event)"
        v-on:form-input-resource-type="handleInputResourceType($event)"
        v-on:input-rights="rights = $event"></p-i-form>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import arrays from "phaidra-vue-components/src/utils/arrays"
import fields from "phaidra-vue-components/src/utils/fields"
import { context } from "../../../mixins/context"
import { config } from "../../../mixins/config"
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary"

export default {
  name: 'submit-custom',
  mixins: [context, config, vocabulary],
  data() {
    return {
      form: {},
      rights: {},
      skipValidation: false,
      validationfnc: null,
      templating: true
    }
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
            this.form.sections[0].fields.splice(4, 0, lang);
          }
          this.markOefosMandatory()
          break;
      }
    },
    dontValidate: function () {
      return true;
    },
    objectCreated: function (event) {
      this.$router.push(this.localeLocation({ path: `/detail/${event}` }));
      this.$vuetify.goTo(0);
    },
    loadTemplate: async function (self) {
      self.loading = true
      try {
        let response = await self.$axios.request({
          method: 'GET',
          url: '/jsonld/template/' + self.$route.params.templateid,
          headers: {
            'X-XSRF-TOKEN': self.user.token
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          self.$store.commit('setAlerts', response.data.alerts)
        }
        self.form = response.data.template.form
        if (self.user.username !== response.data.template.owner) {
          self.templating = false
        }
        for (let s of self.form.sections) {
          for (let f of s.fields) {
            if(f.id.includes('mime-type_')) {
              f.value = ''
            }
            f.removable = true
            f.configurable = true
          }
        }
        if (response.data.template.rights) {
          self.rights = response.data.template.rights
        }
        if (response.data.template.hasOwnProperty('skipValidation')) {
          self.skipValidation = response.data.template.skipValidation
        }
        if (response.data.template.hasOwnProperty('validationfnc')) {
          self.validationfnc = response.data.template.validationfnc
        }
      } catch (error) {
        console.log(error)
        self.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        self.loading = false
      }
    }
  },
  beforeRouteEnter: function (to, from, next) {
    next(vm => {
      vm.templateid = to.params.templateid
      vm.loadTemplate(vm).then(() => {
        next()
      })
    })
  },
  beforeRouteUpdate: function (to, from, next) {
    this.templateid = to.params.templateid
    this.loadTemplate(this).then(() => {
      next()
    })
  }
}
</script>