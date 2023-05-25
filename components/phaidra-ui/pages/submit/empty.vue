<template>
  <v-container fluid>
    <v-card>
      <v-card-text>
        <client-only>
        <p-i-form
          :form="form"
          :disablesave="true"
          :validate="validate"
          v-on:load-form="form = $event"
          v-on:object-created="objectCreated($event)"
          v-on:add-phaidrasubject-section="addPhaidrasubjectSection($event)"
        ></p-i-form>
        </client-only>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>
import fields from "phaidra-vue-components/src/utils/fields";
import { context } from "../../mixins/context";

export default {
  mixins: [ context ],
  data () {
    return {
      form: { sections: [] }
    }
  },
  methods: {
    validate: function () {
      return true
    },
    addPhaidrasubjectSection: function (afterSection) {
      let s = {
        title: 'SUBJECT_SECTION',
        type: 'phaidra:Subject',
        id: this.form.sections.length + 1,
        removable: true,
        multiplicable: true,
        fields: []
      }
      this.form.sections.splice(this.form.sections.indexOf(afterSection) + 1, 0, s)
    },
    objectCreated: function (event) {
      this.$router.push(this.localeLocation({ path: `/detail/${event}`}))
      this.$vuetify.goTo(0)
    },
    createSimpleForm: function (index) {
      this.form = {
        sections: [
          {
            title: 'Digital object',
            type: 'digitalobject',
            id: 1,
            fields: []
          }
        ]
      }

      let defaultResourceType =
          "https://pid.phaidra.org/vocabulary/44TN-P1S0";

        let rt = fields.getField("resource-type-buttongroup");
        rt.vocabulary = "resourcetypenocontainer";
        rt.value = defaultResourceType;
        this.form.sections[0].fields.push(rt);

        let file = fields.getField("file");
        file.fileInputClass = "mb-2";
        this.form.sections[0].fields.push(file);

        let ot = fields.getField("object-type-checkboxes");
        ot.resourceType = defaultResourceType;
        ot.showLabel = true;
        this.form.sections[0].fields.push(ot);

        this.form.sections[0].fields.push(fields.getField("title"));

        this.form.sections[0].fields.push(fields.getField("description"));

        let lang = fields.getField("language");
        lang.value = this.$i18n.locale;
        lang.label = "Language of object";
        this.form.sections[0].fields.push(lang);

        let kw = fields.getField("keyword");
        kw.disableSuggest = true;
        this.form.sections[0].fields.push(kw);

        let role = fields.getField("role");
        role.ordergroup = "role";
        role.roleVocabulary = "submitrolepredicate";
        role.identifierType = "ids:orcid";
        role.showIdentifier = true;
        this.form.sections[0].fields.push(role);

        this.form.sections[0].fields.push(fields.getField("oefos-subject"));
        this.form.sections[0].fields.push(fields.getField("association"));

        let lic = fields.getField("license");
        lic.showValueDefinition = true;
        lic.vocabulary = "alllicenses";
        this.form.sections[0].fields.push(lic);
    }
  },
  mounted: function () {
    this.createSimpleForm()
  }
}
</script>
