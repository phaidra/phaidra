<template>
  <v-col>
    <v-btn color="primary" class="my-4" :to="{ path: `/detail/${relatedpid}`, params: { pid: relatedpid } }">
      <v-icon left>mdi-arrow-left</v-icon>{{ $t('Back to detail page') }}
    </v-btn>
    <v-alert v-if="
      relation === 'hassuccessor' &&
      objectInfo &&
      objectInfo.relationships.ispartof.length > 0
    " type="info">
      <div>{{ relatedpid + " " + $t("is part of collections:") }}</div>
      <div v-for="(col, i) in objectInfo.relationships.ispartof" :key="'cola' + i">
        {{ col.pid + " (owner:" + col.owner + "): " + col.dc_title[0] }}
      </div>
      <div>
        {{
            $t(
              "Should the collection membership in collections you own be transferred to new version?"
            )
        }}
        <v-switch v-model="transferMembership" :label="transferMembership ? $t('Yes') : $t('No')"></v-switch>
      </div>
    </v-alert>
    <v-card>
      <v-card-title class="title font-weight-light white--text">
        <span class="mr-1">{{ $t("Submit of") }}</span>
        <span v-if="relation === 'references'">{{
            $t("an object referencing")
        }}</span>
        <span v-if="relation === 'isbacksideof'">{{
            $t("the back side of")
        }}</span>
        <span v-if="relation === 'isthumbnailfor'">{{
            $t("a thumbnail for")
        }}</span>
        <span v-if="relation === 'hassuccessor'">{{
            $t("a new version of")
        }}</span>
        <span v-if="relation === 'isalternativeformatof'">{{
            $t("an alternative format of")
        }}</span>
        <span v-if="relation === 'isalternativeversionof'">{{
            $t("an alternative version of")
        }}</span>
        <span v-if="relation === 'hascollectionmember'">{{
            $t("a new member of collection")
        }}</span>
        <span v-if="relation === 'hasmember'">{{
            $t("new member of container")
        }}</span>
        <span class="ml-1">{{ relatedpid }}</span>
      </v-card-title>
      <v-card-text v-if="!transferringMembership">
        <p-i-form 
        :form="form" 
        :rights="rights" 
        :relationships="relationships"
        :foreignRelationships="foreignRelationships" 
        :enablerights="true" 
        :enablerelationships="false"
        :templating="true" 
        :importing="false" 
        :addbutton="true" 
        :help="false" 
        :debug="true" 
        :feedback="true"
        :feedback-user="this.user" 
        :feedback-context="'Related object submit'" 
        :mouseoverfielddef="true"
        v-on:load-form="form = $event" 
        v-on:load-rights="rights = $event"
        v-on:object-created="objectCreated($event)"
        v-on:form-input-resource-type="handleInputResourceType($event)" 
        v-on:input-rights="rights = $event"
        v-on:input-relationships="relationships = $event"></p-i-form>
      </v-card-text>
      <v-card-text v-else>
        <v-row class="mx-4">
          <v-col cols="12">
            <v-row no-gutters>
              <v-progress-linear indeterminate color="primary"></v-progress-linear>
            </v-row>
            <v-row no-gutters class="primary--text mt-1">
              <span>{{ $t("Transferring relationships...") }}</span><span class="ml-2"
                v-if="transferMembershipAction">{{
                    transferMembershipAction
                }}</span>
            </v-row>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>
  </v-col>
</template>

<script>
import fields from "phaidra-vue-components/src/utils/fields"
import arrays from "phaidra-vue-components/src/utils/arrays"
import jsonLd from "phaidra-vue-components/src/utils/json-ld"
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary"
import { context } from "../../../mixins/context"
import { config } from "../../../mixins/config"

export default {
  mixins: [context, config, vocabulary],
  computed: {
    relatedpid: function () {
      return this.$route.params.relatedpid;
    },
    relation: function () {
      return this.$route.params.relation;
    },
    objectInfo: function () {
      return this.$store.state.objectInfo;
    },
  },
  data() {
    return {
      form: {
        sections: [
          {
            title: "",
            id: 1,
            type: "digitalobject",
            fields: [],
          },
        ],
      },
      rights: {},
      relationships: {},
      foreignRelationships: {},
      transferMembership: false,
      transferringMembership: false,
      transferMembershipAction: "",
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
      if (this.instanceconfig.submit?.markmandatoryfnc) {
        if (this.instanceconfig.submit?.markmandatoryfnc === 'markMandatoryWithOefosAndAssoc') {
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
    objectCreated: async function (event) {
      let newpid = event;
      if (this.relation === "hassuccessor" && this.transferMembership) {
        this.transferringMembership = true;
        let removeMembers = {
          metadata: { members: [{ pid: this.relatedpid }] },
        };
        let addMembers = { metadata: { members: [{ pid: newpid }] } };
        for (let col of this.objectInfo.relationships.ispartof) {
          if (col.owner === this.$store.state.user.username) {
            this.transferMembershipAction = this.$t(
              "REMOVE_COLLECTION_MEMBER",
              { oldpid: this.relatedpid, collection: col.pid }
            );
            try {
              let httpFormData = new FormData();
              httpFormData.append("metadata", JSON.stringify(removeMembers));
              let response = await this.$axios.request({
                method: "POST",
                url:
                  "/collection/" +
                  col.pid +
                  "/members/remove",
                headers: {
                  "Content-Type": "multipart/form-data",
                  "X-XSRF-TOKEN": this.$store.state.user.token,
                },
                data: httpFormData,
              });
              if (response.status !== 200) {
                if (response.data.alerts && response.data.alerts.length > 0) {
                  this.$store.commit("setAlerts", response.data.alerts);
                }
              }
            } catch (error) {
              console.log(error);
              this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
            }
            this.transferMembershipAction = this.$t("ADD_COLLECTION_MEMBER", {
              newpid: newpid,
              collection: col.pid,
            });
            try {
              let httpFormData = new FormData();
              httpFormData.append("metadata", JSON.stringify(addMembers));
              let response = await this.$axios.request({
                method: "POST",
                url:
                  "/collection/" +
                  col.pid +
                  "/members/add",
                headers: {
                  "Content-Type": "multipart/form-data",
                  "X-XSRF-TOKEN": this.$store.state.user.token,
                },
                data: httpFormData,
              });
              if (response.status !== 200) {
                if (response.data.alerts && response.data.alerts.length > 0) {
                  this.$store.commit("setAlerts", response.data.alerts);
                }
              }
            } catch (error) {
              console.log(error);
              this.$store.commit("setAlerts", [{ type: "error", msg: error }]);
            }
          }
        }
      }
      this.$router.push(this.localeLocation({ path: `/detail/${newpid}` }));
      this.$vuetify.goTo(0);
    },
    importFromRelatedObject: async function (self) {
      self.loading = true;
      try {
        let response = await self.$axios.request({
          method: "GET",
          url:
            "/object/" +
            self.relatedpid +
            "/metadata",
        });
        if (response.data.metadata.hasOwnProperty("JSON-LD")) {
          self.form = jsonLd.json2form(response.data.metadata["JSON-LD"], null, this.vocabularies);
          for (let s of self.form.sections) {
            let isFileSection = false;
            for (let f of s.fields) {
              if (f.fieldname === "Resource type") {
                f.disabled = false
                f.readonly = false
              }
              if (f.predicate === "ebucore:filename") {
                isFileSection = true;
                break;
              }
            }
            if (isFileSection) {
              let newFields = [];
              for (let f of s.fields) {
                if (
                  f.predicate !== "ebucore:filename" &&
                  f.predicate !== "ebucore:hasMimeType"
                ) {
                  newFields.push(f);
                }
              }
              s.fields = newFields;
              newFields.push(fields.getField("file"));
            }
          }
          return true;
        } else {
          if (response.data.alerts && response.data.alerts.length > 0) {
            self.$store.commit("setAlerts", response.data.alerts);
          }
          return false;
        }
      } catch (error) {
        console.error(error);
      } finally {
        self.loading = false;
      }
    },
    createForm: async function (self) {
      self.$store.dispatch("vocabulary/sortObjectTypes", this.$i18n.locale);
      self.transferMembership = false;
      self.transferringMembership = false;
      self.transferMembershipAction = "";
      self.mandatoryFieldsFound = {};
      self.mandatoryFieldsFilled = {};
      self.form = {
        sections: [
          {
            title: "",
            id: 1,
            type: "digitalobject",
            fields: [],
          },
        ],
      };
      self.rights = {};
      self.relationships = {};
      self.foreignRelationships = {};

      if (
        self.relation === "hassuccessor" ||
        self.relation === "hascollectionmember" ||
        self.relation === "hasmember"
      ) {
        self.foreignRelationships[self.relation] = [self.relatedpid];
      } else {
        self.relationships[self.relation] = [self.relatedpid];
      }

      let imported = false;
      if (
        self.relation === "hassuccessor" ||
        self.relation === "isalternativeformatof" ||
        self.relation === "isalternativeversionof"
      ) {
        imported = await self.importFromRelatedObject(self);
      }
      if (!imported) {
        let settres = await self.$axios.get("/config/public");
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
      }
    },
  },
  beforeRouteEnter: async function (to, from, next) {
    next(async function (vm) {
      vm.$store.commit("setLoading", true);
      await vm.createForm(vm);
      if (vm.relation === "hassuccessor") {
        await vm.$store.dispatch("fetchObjectInfo", vm.relatedpid);
      }
      vm.$store.commit("setLoading", false);
    });
  },
  beforeRouteUpdate: async function (to, from, next) {
    this.$store.commit("setLoading", true);
    await this.createForm(this);
    if (this.relation === "hassuccessor") {
      await this.$store.dispatch("fetchObjectInfo", this.relatedpid);
    }
    this.$store.commit("setLoading", false);
  },
  mounted() {
    console.log(
      "$route.params.relatedpid",
      this.$route.params.relatedpid,
      this.$route.params.relation
    );
  },
};
</script>