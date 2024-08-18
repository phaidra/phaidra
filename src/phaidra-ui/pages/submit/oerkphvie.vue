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
          :templating="false"
          :savetemplatebtn="false"
          :importing="false"
          :addbutton="false"
          :mouseoverfielddef="true"
          :help="false"
          :debug="false"
          :feedback="false"
          v-on:load-form="form = $event"
          v-on:object-created="objectCreated($event)"
          v-on:input-rights="rights = $event"
        ></p-i-form>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
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
          }
        ],
      };

      let defaultResourceType = "https://pid.phaidra.org/vocabulary/44TN-P1S0";

      let rt = fields.getField("resource-type-buttongroup");
      rt.vocabulary = "resourcetypenocontainer";
      rt.resourceTypes = [
      'https://pid.phaidra.org/vocabulary/44TN-P1S0',
      'https://pid.phaidra.org/vocabulary/8YB5-1M0J',
      'https://pid.phaidra.org/vocabulary/B0Y6-GYT8',
      'https://pid.phaidra.org/vocabulary/69ZZ-2KGX',
      'https://pid.phaidra.org/vocabulary/7AVS-Y482'
      ];
      rt.value = defaultResourceType;
      self.form.sections[0].fields.push(rt);

      let file = fields.getField("file");
      file.fileInputClass = "mb-2";
      file.showMimetype = false;
      file.backgroundColor = '#0063a620';
      self.form.sections[0].fields.push(file);

      let phaidra_oer = fields.getField("object-type")
      phaidra_oer.value = 'https://pid.phaidra.org/vocabulary/YA8R-1M0D'
      phaidra_oer.hidden = true
      self.form.sections[0].fields.push(phaidra_oer);

      let ot = fields.getField("object-type-checkboxes");
      ot.resourceType = defaultResourceType;
      ot.showLabel = true;
      ot.vocabulary = 'oerobjecttype';
      ot.label = 'Materialtyp'
      self.form.sections[0].fields.push(ot);

      let title = fields.getField("title")
      self.form.sections[0].fields.push(title);

      let lang = fields.getField("language");
      lang.value = this.$i18n.locale;
      lang.label = "Language of object";
      self.form.sections[0].fields.push(lang);

      let description = fields.getField("description")
      self.form.sections[0].fields.push(description);

      let kw = fields.getField("keyword");
      kw.disableSuggest = true;
      kw.label = "Schlagworte";
      self.form.sections[0].fields.push(kw);

      let role = fields.getField("fixedrole-person");
      role.roleLabel = 'Autor:in *'
      role.role = 'role:aut'
      role.ordergroup = "role_aut";
      role.roleVocabulary = "submitrolepredicate";
      role.identifierType = "ids:orcid";
      role.showIdentifier = false;
      self.form.sections[0].fields.push(role);

      let role_uploader = fields.getField("fixedrole-person");
      role_uploader.roleLabel = 'Hochladende Person, falls nicht Autor:in/Autor:innen'
      role_uploader.definition = 'Person, die das Objekt hochlädt und die Metadaten eingibt, aber das Objekt nicht erstellt hat'
      role_uploader.ordergroup = "role_upl";
      role_uploader.role = 'role:uploader'
      role_uploader.multiplicable = false
      role_uploader.roleVocabulary = "submitrolepredicate";
      role_uploader.identifierType = "ids:orcid";
      role_uploader.showIdentifier = false;
      self.form.sections[0].fields.push(role_uploader);

      let oefos = fields.getField("oefos-subject")
      oefos.label = 'Fachgebiete (ÖFOS)'
      self.form.sections[0].fields.push(oefos);

      let audience = fields.getField("audience-vocab")
      audience.vocabulary = 'oeraudience'
      self.form.sections[0].fields.push(audience);

      let lic = fields.getField("license");
      lic.showValueDefinition = true;
      lic.vocabulary = "alllicenses";
      self.form.sections[0].fields.push(lic);

      let note = fields.getField("note-checkbox-with-link")
      note.note = 'Grundsätze der Barrierearmut beachtet'
      note.labelMessageId = 'OER_ACCESSIBILITY_CHECK_LABEL'
      note.linkLabelMessageId = 'OER_ACCESSIBILITY_CHECK_LINK_LABEL'
      note.link = 'https://phaidra.kphvie.ac.at/o:13'
      note.language = 'deu'
      self.form.sections[0].fields.push(note);

      let alert = fields.getField("alert")
      alert.contentperlocale = {
        eng: 'By uploading an OER object using this template, you agree to the <strong>worldwide publication</strong> of the material. After a review, the object will be included in the OER collection and can be accessed via <a href="https://www.oerhub.at/" target="_blank">OERhub.at</a> (search engine for open educational resources from the Austrian higher education sector). <strong>The necessary criteria for OER must be met.</strong> See <a target="_blank" href="https://static.uni-graz.at/fileadmin/digitales-lehren-und-lernen/Dokumente/OER-Leitfaden_V3_2022.pdf">criteria for OER material</a>.',
        deu: 'Durch das Hochladen eines OER-Objekts mit dieser Vorlage stimmen Sie der <strong>weltweiten Veröffentlichung</strong> des Materials zu. Das Objekt wird nach einer Prüfung in die OER-Collection aufgenommen und ist über <a href="https://www.oerhub.at/" target="_blank">OERhub.at</a> (Suchmaschine für offene Bildungsressourcen aus dem österreichischen Hochschulraum) abrufbar. <strong>Notwenige Kriterien eines OERs sind unbedingt einzuhalten.</strong> Siehe Kriterien für <a target="_blank" href="https://static.uni-graz.at/fileadmin/digitales-lehren-und-lernen/Dokumente/OER-Leitfaden_V3_2022.pdf">OER-Tauglichkeit</a>.'
      }
      self.form.sections[0].fields.push(alert);

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