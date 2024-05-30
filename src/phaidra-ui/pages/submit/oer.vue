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
          v-on:form-input-p-file="handleMimeSelect($event)"
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

        // eg application/x-iso9660-image
        default:
          // data
          return "https://pid.phaidra.org/vocabulary/7AVS-Y482";
      }
    },
    handleMimeSelect: function (field) {
      if (field.predicate === "ebucore:filename") {
        for (let s of this.form.sections) {
          if (s.fields) {
            let isParentSection = false;
            for (let f of s.fields) {
              if (f.predicate === "ebucore:filename" && f.id === field.id) {
                isParentSection = true;
              }
            }
            if (isParentSection) {
              for (let f of s.fields) {
                if (f.predicate === "dcterms:type") {
                  f.value = this.getResourceTypeFromMimeType(field.mimetype);
                  f["skos:prefLabel"] = [];
                  for (let rt of this.vocabularies.resourcetype.terms) {
                    if (rt["@id"] === f.value) {
                      Object.entries(rt["skos:prefLabel"]).forEach(
                        ([key, value]) => {
                          f["skos:prefLabel"].push({
                            "@value": value,
                            "@language": key,
                          });
                        }
                      );
                    }
                  }
                }
              }
            }
          }
        }
      }
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
      rt.hidden = true
      self.form.sections[0].fields.push(rt);

      let file = fields.getField("file");
      file.fileInputClass = "mb-2";
      file.showMimetype = false;
      file.backgroundColor = '#0063a620';
      self.form.sections[0].fields.push(file);

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

      self.form.sections[0].fields.push(fields.getField("oefos-subject"));

      let audience = fields.getField("audience-vocab")
      audience.vocabulary = 'oeraudience'
      self.form.sections[0].fields.push(audience);

      let lic = fields.getField("license");
      lic.showValueDefinition = true;
      lic.vocabulary = "alllicenses";
      self.form.sections[0].fields.push(lic);

      let note = fields.getField("note-checkbox")
      note.note = 'Grundsätze der Barrierefreiheit beachtet'
      note.label = 'Grundsätze der Barrierefreiheit beachtet'
      note.language = 'deu'
      self.form.sections[0].fields.push(note);

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