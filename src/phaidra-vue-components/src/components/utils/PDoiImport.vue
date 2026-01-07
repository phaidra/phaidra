<template>
  <v-container>
    <v-row no-gutters>
      <h3 class="title font-weight-light mb-4">
        {{ $t("Metadata-Import via DOI") }}
      </h3>
    </v-row>
    <v-row no-gutters>
      <p>
        {{
          $t(
            "Many electronically published journals assign persistent names, so called DOIs (Digital Object Identifiers), to their articles."
          )
        }}
      </p>
    </v-row>
    <v-row no-gutters>
      <p>
        {{
          $t(
            "If you enter your article's DOI here, its metadata can be loaded automatically."
          )
        }}
      </p>
    </v-row>
    <v-row no-gutters justify="center" class="mt-4">
      <v-col cols="4">
        <v-text-field
          :error-messages="doiImportErrors"
          filled
          v-model="doiImportInput"
          label="DOI"
          :placeholder="$t('please enter')"
        />
      </v-col>
      <v-col cols="3" class="ml-2">
        <v-btn
          :loading="loading"
          :disabled="loading || !doiToImport || doiToImport.length < 1"
          class="mx-2"
          color="primary"
          @click="importDOI()"
          >{{ $t("Import") }}</v-btn
        >
        <v-btn
          :loading="loading"
          :disabled="loading"
          class="mx-2"
          dark
          color="btnred"
          @click="resetDOIImport()"
          >{{ $t("Reset") }}</v-btn
        >
      </v-col>
    </v-row>
    <v-row no-gutters v-if="doiImportData" justify="center">
      <v-col cols="12" md="7">
        <v-card>
          <v-card-title
            class="title font-weight-light white--text"
            >{{
              $t("Following metadata were retrieved")
            }}
            <span class="ml-2" v-if="metaProviderName">({{ $t("Agency") }}: {{ $t(metaProviderName) }})</span>
            </v-card-title
          >
          <v-card-text>
            <v-container>
              <v-row v-if="doiImportData.title">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Title") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.title
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.descriptions && doiImportData.descriptions.length > 0">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Description") }}</v-col
                >
                <v-col md="10" cols="12">
                  <v-row v-for="(desc, i) in doiImportData.descriptions" :key="'desc' + i">
                    <v-col md="12" cols="12">{{ desc.description }} <b v-if="desc.lang">({{ desc.lang }})</b></v-col>
                  </v-row>
                </v-col>
              </v-row>
              <v-row v-if="doiImportData.subtitle">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Subtitle") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.subtitle
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.dateIssued">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Date issued") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.dateIssued
                }}</v-col>
              </v-row>
              <v-row
                v-for="(author, i) of doiImportData.authors"
                :key="'aut' + i"
              >
                <v-col
                  v-if="i === 0"
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Authors") }}</v-col
                >
                <v-col v-else md="2" cols="12"></v-col>
                <v-col
                  md="10"
                  cols="12"
                  v-if="author.firstname || author.lastname"
                  ><span class="font-weight-regular">{{
                    author.firstname + " " + author.lastname
                  }}</span
                  ><span v-if="author['orcid']">
                    ({{ author["orcid"] }})</span
                  >
                  <template v-if="author['affiliation']">
                    <template v-for="(af, i) in author['affiliation']"
                      ><p>{{ af }}</p></template
                    >
                  </template>
                </v-col>
                <v-col md="10" cols="12" v-else
                  ><span class="font-weight-regular">{{
                    author.name
                  }}</span></v-col
                >
              </v-row>
              <v-row v-if="doiImportData.keywords">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Keywords") }}</v-col
                >
                <v-col md="10" cols="12"
                  ><v-chip
                    :key="'kw' + i"
                    v-for="(kw, i) in doiImportData.keywords"
                    class="mr-2 mb-2"
                    >{{ kw }}</v-chip
                  ></v-col
                >
              </v-row>
              <v-row v-if="doiImportData.language">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Language") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.language
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.publicationType">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Type of publication") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.publicationType
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.publisher">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("PUBLISHER_VERLAG") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.publisher
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.journalTitle">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Appeared in") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.journalTitle
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.journalISSN">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("ISSN") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.journalISSN
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.journalVolume">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Volume") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.journalVolume
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.journalIssue">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Issue") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.journalIssue
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.pageStart">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Start page") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.pageStart
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.pageEnd">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("End page") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.pageEnd
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.ISBN">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right mt-4"
                  >{{ $t("ISBN") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.ISBN
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.license">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("License") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.license
                }}</v-col>
              </v-row>
              <v-row v-if="doiImportData.accessrights">
                <v-col
                  md="2"
                  cols="12"
                  class="font-weight-bold text-right"
                  >{{ $t("Access Rights") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.accessrightsLabel
                }}</v-col>
              </v-row>
            </v-container>
          </v-card-text>
        </v-card>
        <div class="font-weight-bold text-right mt-4">
          <v-btn color="primary" @click="proceedForm">{{ $t("Load Form") }}</v-btn>
        </div>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import fields from '../../utils/fields'
import {constructDataCite} from '../../utils/doiconstructor'
import { formvalidation } from '../../mixins/formvalidation'
import lang3to2map from '../../utils/lang3to2map'
export default {
  name: 'p-doi-import',
  mixins: [vocabulary, formvalidation],
  props: {
    externalForm: {
      type: Object,
      required: false
    }
  },
  data () {
    return {
      doi: {
      baseurl: 'api.crossref.org',
      accept: 'application/json',
      citationstyles: 'https://citation.crosscite.org/styles/'
    },
      form: {
        sections: [],
      },
      doiImportErrors: [],
      loading: false,
      doiImportInput: null,
      doiImportData: null,
      journalSearchQuery: null,
      journalSearchISSN: null,
      journalSearchLoading: false,
      journalSearchSelected: [],
      journalSearchItems: [],
      journalSearchErrors: [],
      doiDuplicate: null,
      metaProviderName: '',

    }
  },
  computed: {
    instanceconfig: function () {
      return this.$root.$store.state.instanceconfig
    },
    lang2to3map: function () {
      return Object.keys(lang3to2map).reduce((ret, key) => {
        ret[lang3to2map[key]] = key;
        return ret;
      }, {});
    },
    doiToImport: function () {
      if (this.doiImportInput) {
        let doi = this.doiImportInput.replace("https://", "");
        doi = doi.replace("http://", "");
        doi = doi.replace("dx.doi.org/", "");
        doi = doi.replace("doi.org/", "");
        doi = doi.replace("doi:", "");
        return doi;
      } else {
        return null;
      }
    },
  },
  methods: {
    normalizeOrcid: function (orcid) {
      if (!orcid) return orcid
      return orcid.replace(/^https?:\/\/(www\.)?orcid\.org\//i, '').trim()
    },
    cloneForm: function (form) {
      return JSON.parse(JSON.stringify(form))
    },
    findFields: function (form, predicateFn) {
      const found = []
      if (!form || !form.sections) return found
      form.sections.forEach((s, sIdx) => {
        if (!s.fields) return
        s.fields.forEach((f, fIdx) => {
          if (predicateFn(f)) {
            found.push({ field: f, sectionIndex: sIdx, fieldIndex: fIdx })
          }
        })
      })
      return found
    },
    setIfEmpty: function (obj, key, value, overwrite) {
      if (value === undefined || value === null || value === '') return
      if (overwrite || obj[key] === undefined || obj[key] === null || obj[key] === '') {
        this.$set ? this.$set(obj, key, value) : (obj[key] = value)
      }
    },
    getBaseForm: function () {
      if (this.form && this.form.sections && this.form.sections.length > 0) {
        return this.cloneForm(this.form)
      }
      if (this.externalForm && this.externalForm.sections && this.externalForm.sections.length > 0) {
        return this.cloneForm(this.externalForm)
      }
      return null
    },
    populateFormWithDoiData: function (baseForm, doiImportData, options = {}) {
      const overwrite = options.overwrite || false
      if (!baseForm || !baseForm.sections) return baseForm

      // Title
      const titleHit = this.findFields(baseForm, f => f.component === 'p-title')[0]
      if (titleHit) {
        const f = titleHit.field
        this.setIfEmpty(f, 'title', doiImportData.title, overwrite)
        this.setIfEmpty(f, 'subtitle', doiImportData.subtitle, overwrite)
        if (doiImportData.subtitle) f.hideSubtitle = false
      }

      // Description / abstract
      const descHit = this.findFields(baseForm, f => f.id === 'description' || f.fieldname === 'Description' || f.component === 'p-text-field')[0]
      if (descHit && doiImportData.descriptions && doiImportData.descriptions.length > 0) {
        const f = descHit.field
        const firstDesc = doiImportData.descriptions[0]
        this.setIfEmpty(f, 'value', firstDesc.description, overwrite)
        this.setIfEmpty(f, 'language', firstDesc.lang, overwrite)
      }

      // Language
      const langHit = this.findFields(baseForm, f => f.predicate === 'dcterms:language' || f.id === 'language')[0]
      if (langHit) {
        this.setIfEmpty(langHit.field, 'value', doiImportData.language, overwrite)
      }

      // Keywords
      const kwHit = this.findFields(baseForm, f => f.component === 'p-keyword')[0]
      if (kwHit && doiImportData.keywords && doiImportData.keywords.length > 0) {
        const f = kwHit.field
        if (overwrite || !f.value || f.value.length === 0) {
          f.value = doiImportData.keywords
        }
      }

      // Object type
      const otHit = this.findFields(baseForm, f => f.id === 'object-type-checkboxes' || f.component.includes('p-object-type'))[0]
      if (otHit && doiImportData.publicationTypeId) {
        const f = otHit.field
        f.selectedTerms = [
          { value: doiImportData.publicationTypeId }
        ]
      }

      // DOI identifier
      const altIdHit = this.findFields(baseForm, f => f.id === 'alternate-identifier' || f.component === 'p-alternate-identifier')[0]
      if (altIdHit && doiImportData.doi) {
        const f = altIdHit.field
        this.setIfEmpty(f, 'value', doiImportData.doi, overwrite)
        if (!f.type) {
          // best effort set to DOI if available in vocab
          f.type = 'ids:doi'
        }
      }

      // Date issued
      const issuedHit = this.findFields(baseForm, f => f.component === 'p-date-edtf' && (f.type === 'dcterms:issued' || f.mainSubmitDate))[0]
      if (issuedHit) {
        this.setIfEmpty(issuedHit.field, 'value', doiImportData.dateIssued, overwrite)
      }

      // Series / journal
      const seriesHit = this.findFields(baseForm, f => f.component === 'p-series')[0]
      if (seriesHit) {
        const f = seriesHit.field
        this.setIfEmpty(f, 'title', doiImportData.journalTitle, overwrite)
        this.setIfEmpty(f, 'issn', doiImportData.journalISSN, overwrite)
        this.setIfEmpty(f, 'volume', doiImportData.journalVolume, overwrite)
        this.setIfEmpty(f, 'issue', doiImportData.journalIssue, overwrite)
        this.setIfEmpty(f, 'pageStart', doiImportData.pageStart, overwrite)
        this.setIfEmpty(f, 'pageEnd', doiImportData.pageEnd, overwrite)
        this.setIfEmpty(f, 'issued', doiImportData.dateIssued, overwrite)
      }

      // Publisher
      const publHit = this.findFields(baseForm, f => f.component === 'p-bf-publication')[0]
      if (publHit) {
        const f = publHit.field
        this.setIfEmpty(f, 'publisherName', doiImportData.publisher, overwrite)
        this.setIfEmpty(f, 'publishingDate', doiImportData.dateIssued, overwrite)
      }

      // License
      const licHit = this.findFields(baseForm, f => (f.id === 'license' || f.predicate === 'edm:rights'))[0]
      if (licHit && doiImportData.license) {
        this.setIfEmpty(licHit.field, 'value', doiImportData.license, overwrite)
      }

      // Authors / roles
      if (doiImportData.authors && doiImportData.authors.length > 0) {
        const roleHits = this.findFields(baseForm, f => f.component === 'p-entity-extended' || f.component === 'p-entity')
        const targetSectionIndex = roleHits[0]?.sectionIndex ?? 0
        const targetSection = baseForm.sections[targetSectionIndex]
        const ensureRoleField = () => {
          if (roleHits.length > 0) {
            return roleHits.shift().field
          }
          // create new role-extended field if multiplicable is allowed
          const newRole = fields.getField('role-extended')
          targetSection.fields.push(newRole)
          return newRole
        }
        doiImportData.authors.forEach((author, idx) => {
          const roleField = ensureRoleField()
          if (!roleField) return
          roleField.role = 'role:aut'
          roleField.roleVocabulary = roleField.roleVocabulary || 'submitrolepredicate'
          roleField.identifierType = roleField.identifierType || 'ids:orcid'
          roleField.identifierLabel = roleField.identifierLabel || 'ORCID'
          roleField.showIdentifier = true
          roleField.showIdentifierType = roleField.showIdentifierType === undefined ? false : roleField.showIdentifierType
          if (author.type === 'schema:Person') {
            this.setIfEmpty(roleField, 'type', 'schema:Person', true)
            this.setIfEmpty(roleField, 'firstname', author.firstname, overwrite || idx === 0)
            this.setIfEmpty(roleField, 'lastname', author.lastname, overwrite || idx === 0)
            this.setIfEmpty(roleField, 'identifierText', author.orcid, overwrite || idx === 0)
            if (author.affiliation && author.affiliation.length > 0) {
              this.setIfEmpty(roleField, 'affiliationText', author.affiliation[0], overwrite || idx === 0)
              this.setIfEmpty(roleField, 'affiliationType', 'other', true)
            }
          } else if (author.type === 'schema:Organization') {
            this.setIfEmpty(roleField, 'type', 'schema:Organization', true)
            this.setIfEmpty(roleField, 'organizationText', author.name, overwrite || idx === 0)
            this.setIfEmpty(roleField, 'organizationType', 'other', true)
          }
        })
      }

      return baseForm
    },
    proceedForm: function () {
      console.log('this.form', this.form);
      this.$emit('load-form', this.form);
    },
    resetDOIImport: async function () {
      this.doiImportInput = null;
      this.doiImportData = null;
      this.doiImportErrors = [];
      this.journalSearchQuery = null;
      this.journalSearchISSN = null;
      this.journalSearchItems = [];
      this.journalSearchSelected = [];
      await this.resetForm(this, null);
    },
    importDOI: async function () {
      this.loading = true;
      this.doiImportErrors = [];
      this.doiDuplicate = null;
      this.doiImportData = null;
      this.metaProviderName = ''
      if (this.doiImportInput) {
        try {
          let doiAgency = null
          try {
            const agencyResp = await this.$axios.get(`https://api.crossref.org/works/${this.doiToImport}/agency`)
            doiAgency = agencyResp?.data?.message?.agency?.id
          } catch (error) {
            console.log('Doi agency error', error)
          }
          if(doiAgency === 'datacite'){
              this.metaProviderName = 'Datacite'
              this.doiImportData = {}
              const dataciteResp = await this.$axios.get(`https://api.datacite.org/dois/${this.doiToImport}`)
              const dataciteData = dataciteResp?.data;
              this.doiImportData = constructDataCite(dataciteData, this)
              await this.applyDoiImportData(this.doiImportData);
              if (this.doiImportData.journalISSN) {
                this.journalSearchISSN = this.doiImportData.journalISSN;
                // this.journalSearch();
              }
              return
          }
          // let solrResponse = await this.$axios.get(
          //   `${this.config.solr}/select?wt=json&q=dc_identifier:"${this.doiToImport}"`
          // );
          let solrResponse = {
            data: {
              response: {
                numFound: 0,
                docs: []
              }
            }
          }
          if (solrResponse.data.response.numFound > 0) {
            this.doiDuplicate = {
              pid: solrResponse.data.response.docs[0].pid,
              title: solrResponse.data.response.docs[0].dc_title[0],
            };
          } else {
            let response = await this.$axios.get(
              "https://" +
                this.doi.baseurl +
                "/works/" +
                this.doiToImport,
              {
                headers: {
                  Accept: this.doi.accept,
                },
              }
            );

            let crossrefData = response.data.message;

            this.doiImportData = {
              doi: this.doiToImport,
              title: "",
              dateIssued: "",
              authors: [],
              publicationType: "",
              publisher: "",
              journalTitle: "",
              journalISSN: "",
              journalVolume: "",
              journalIssue: "",
              pageStart: "",
              pageEnd: "",
              descriptions: [],
            };

            if (crossrefData["title"]) {
              if (Array.isArray(crossrefData["title"])) {
                if (crossrefData["title"].length > 0) {
                  this.doiImportData.title = crossrefData["title"][0]
                    .replace(/\s\s+/g, " ")
                    .trim();
                }
              } else {
                this.doiImportData.title = crossrefData["title"]
                  .replace(/\s\s+/g, " ")
                  .trim();
              }
            }

            if (crossrefData["subtitle"]) {
              if (Array.isArray(crossrefData["subtitle"])) {
                if (crossrefData["subtitle"].length > 0) {
                  this.doiImportData.subtitle = crossrefData["subtitle"][0]
                    .replace(/\s\s+/g, " ")
                    .trim();
                }
              } else {
                this.doiImportData.subtitle = crossrefData["subtitle"]
                  .replace(/\s\s+/g, " ")
                  .trim();
              }
            }

            if (crossrefData["issued"]) {
              if (crossrefData["issued"]["date-parts"]) {
if (crossrefData['issued']['date-parts'][0]) {
                  if (crossrefData['issued']['date-parts'][0][0]) {
                this.doiImportData.dateIssued =
                  crossrefData["issued"]["date-parts"][0][0].toString();
}}
              }
            }

            if (crossrefData["language"]) {
              if(crossrefData["language"].length === 3) {
                this.doiImportData.language = crossrefData["language"]
              } else if (this.lang2to3map[crossrefData["language"]]) {
                this.doiImportData.language = this.lang2to3map[crossrefData["language"]]
              }
            }

            let authors = crossrefData["author"];
            if (authors) {
              if (authors.length > 0) {
                for (let author of authors) {
                  if (author["given"] || author["family"]) {
                    let auth = {
                      type: "schema:Person",
                      firstname: author["given"]
                        ? author["given"].replace(/\s\s+/g, " ").trim()
                        : "",
                      lastname: author["family"]
                        ? author["family"].replace(/\s\s+/g, " ").trim()
                        : "",
                    };
                    if (author["affiliation"]) {
                      if (Array.isArray(author["affiliation"])) {
                        auth.affiliation = [];
                        for (let af of author["affiliation"]) {
                          auth.affiliation.push(af["name"]);
                        }
                      }
                    }
                    if (author["ORCID"]) {
                      auth.orcid = this.normalizeOrcid(author["ORCID"]);
                    }
                    this.doiImportData.authors.push(auth);
                  }
                  if (author["name"]) {
                    let auth = {
                      type: "schema:Organization",
                      name: author["name"],
                    };
                    this.doiImportData.authors.push(auth);
                  }
                }
              }
            }

            if (crossrefData["subject"]) {
              if (Array.isArray(crossrefData["subject"])) {
                this.doiImportData.keywords = [];
                for (let kw of crossrefData["subject"]) {
                  this.doiImportData.keywords.push(kw);
                }
              }
            }

            // https://github.com/citation-style-language/schema/blob/master/csl-types.rnc
            // https://wiki.univie.ac.at/display/IR/Mapping+CrossRef-Erscheinungsformen
            switch (crossrefData["type"]) {
              case "article":
              case "journal-article":
              case "article-journal":
                this.doiImportData.publicationType = "article";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/VKA6-9XTY";
                break;
              case "report":
                this.doiImportData.publicationType = "report";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/JMAV-7F3R";
                break;
              case "book":
              case "monograph":
              case "reference-book":
              case "edited-book":
                this.doiImportData.publicationType = "book";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/47QB-8QF1";
                break;
              case "book-chapter":
              case "book-part":
              case "book-section":
                this.doiImportData.publicationType = "book_part";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/XA52-09WA";
                break;
              case "dissertation":
                this.doiImportData.publicationType = "doctoral_thesis";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/1PHE-7VMS";
                break;
              case "proceedings-article":
              case "proceedings":
                this.doiImportData.publicationType = "conference_object";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/QKDF-E5HA";
                break;
              case "dataset":
                this.doiImportData.publicationType = "research_data";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/KW6N-2VTP";
                break;
              case "other":
              case "standard":
              case "standard-series":
              case "book-entry":
              case "book-series":
              case "book-set":
              case "book-track":
              case "component":
              case "journal-issue":
              case "journal-volume":
              case "journal":
              case "report-series":
                this.doiImportData.publicationType = "other";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/PYRE-RAWJ";
                break;
              default:
                this.doiImportData.publicationType = "other";
                this.doiImportData.publicationTypeId =
                  "https://pid.phaidra.org/vocabulary/PYRE-RAWJ";
            }

            if (crossrefData["publisher"]) {
              if (Array.isArray(crossrefData["publisher"])) {
                if (crossrefData["publisher"].length > 0) {
                  this.doiImportData.publisher = crossrefData["publisher"][0]
                    .replace(/\s\s+/g, " ")
                    .trim();
                }
              } else {
                this.doiImportData.publisher = crossrefData["publisher"]
                  .replace(/\s\s+/g, " ")
                  .trim();
              }
            }

            if (crossrefData["container-title"]) {
              if (Array.isArray(crossrefData["container-title"])) {
                if (crossrefData["container-title"].length > 0) {
                  this.doiImportData.journalTitle = crossrefData[
                    "container-title"
                  ][0]
                    .replace(/\s\s+/g, " ")
                    .trim();
                }
              } else {
                this.doiImportData.journalTitle = crossrefData[
                  "container-title"
                ]
                  .replace(/\s\s+/g, " ")
                  .trim();
              }
            }

            if (crossrefData["ISSN"]) {
              if (Array.isArray(crossrefData["ISSN"])) {
                if (crossrefData["ISSN"].length > 0) {
                  this.doiImportData.journalISSN = crossrefData["ISSN"][0]
                    .replace(/\s\s+/g, " ")
                    .trim();
                }
              } else {
                this.doiImportData.journalISSN = crossrefData["ISSN"]
                  .replace(/\s\s+/g, " ")
                  .trim();
              }
            }

            if (crossrefData["ISBN"]) {
              if (Array.isArray(crossrefData["ISBN"])) {
                if (crossrefData["ISBN"].length > 0) {
                  this.doiImportData.ISBN = crossrefData["ISBN"][0]
                    .replace(/\s\s+/g, " ")
                    .trim();
                }
              } else {
                this.doiImportData.ISBN = crossrefData["ISBN"]
                  .replace(/\s\s+/g, " ")
                  .trim();
              }
            }

            if (crossrefData["volume"]) {
              this.doiImportData.journalVolume = crossrefData["volume"]
                .replace(/\s\s+/g, " ")
                .trim();
            }

            if (crossrefData["issue"]) {
              this.doiImportData.journalIssue = crossrefData["issue"]
                .replace(/\s\s+/g, " ")
                .trim();
            }

            if (crossrefData["page"]) {
              let page = crossrefData["page"].split("-");
              let regexnum = new RegExp("^[0-9]+$");
              let startpage = page[0];
              if (regexnum.test(startpage)) {
                this.doiImportData.pageStart = startpage;
              }
              if (page.length > 1) {
                let endpage = page[1];
                if (regexnum.test(endpage)) {
                  this.doiImportData.pageEnd = endpage;
                }
              }
            }

            if (crossrefData["license"]) {
              if (Array.isArray(crossrefData["license"])) {
                for (let lic of crossrefData["license"]) {
                  if (lic["URL"]) {
                    if (this.getLocalizedTermLabel("alllicenses", lic["URL"])) {
                      this.doiImportData.license = lic["URL"];
                    }
                  }
                }
              }
            }
            if (crossrefData["abstract"] && this?.doiImportData?.license && typeof this.doiImportData.license === 'string' && this.doiImportData.license.includes('http://creativecommons.org/licenses')) {
              this.doiImportData.descriptions.push({
                description: crossrefData["abstract"]
                  .replace(/<jats:p>/g, "")
                  .replace(/<\/jats:p>/g, "")
                  .replace(/^Abstract\.\s*/i, "")
                  .trim()
              })
            }
            console.log('this.doiImportData', this.doiImportData);
            // return
            await this.applyDoiImportData(this.doiImportData);
            if (this.doiImportData.journalISSN) {
              this.journalSearchISSN = this.doiImportData.journalISSN;
              // this.journalSearch();
            }
          }
        } catch (error) {
          console.error(error);
          if (error.response?.status === 404) {
            this.doiImportErrors.push("DOI Not Found");
          } else {
            this.doiImportErrors.push(error.message || 'Unknown error');
          }
        } finally {
          this.loading = false;
        }
      }
    },
    applyDoiImportData: async function (doiImportData) {
      const baseForm = this.getBaseForm()
      if (baseForm) {
        this.form = this.populateFormWithDoiData(baseForm, doiImportData, { overwrite: false })
      } else {
        await this.resetForm(this, doiImportData)
      }
    },
    resetForm: async function (self, doiImportData) {
      self.$store.dispatch("vocabulary/sortObjectTypes", self.$i18n.locale);

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

      let defaultResourceType = "https://pid.phaidra.org/vocabulary/69ZZ-2KGX"; // document

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
      ot.ot4rt = self.instanceconfig?.data_ot4rt;
      self.form.sections[0].fields.push(ot);

      let tf = fields.getField("title");
      if (doiImportData && doiImportData.title) {
        tf.title = doiImportData.title;
      }
      if (doiImportData && doiImportData.subtitle) {
        tf.subtitle = doiImportData.subtitle;
        tf.hideSubtitle = false;
      }
      self.form.sections[0].fields.push(tf);

      let desc = fields.getField("description");
      if (doiImportData && doiImportData.descriptions && doiImportData.descriptions.length > 0) {
        desc.value = doiImportData.descriptions[0].description;
        if (doiImportData.descriptions[0].lang) {
          desc.language = doiImportData.descriptions[0].lang;
        }
      }
      self.form.sections[0].fields.push(desc);

      let lang = fields.getField("language");
      if (doiImportData && doiImportData.language) {
        lang.value = doiImportData.language;
      } else {
        lang.value = self.$i18n.locale;
      }
      lang.label = "Language of object";
      self.form.sections[0].fields.push(lang);

      let kw = fields.getField("keyword");
      if (doiImportData && doiImportData.keywords) {
        kw.value = doiImportData.keywords;
      }
      self.form.sections[0].fields.push(kw);

      if (doiImportData && doiImportData.authors && doiImportData.authors.length > 0) {
        for (let author of doiImportData.authors) {
          let role = fields.getField("role-extended");
          role.ordergroup = "role";
          role.roleVocabulary = "submitrolepredicate";
          role.identifierType = "ids:orcid";
          role.identifierLabel = "ORCID";
          role.showIdentifier = true;
          role.showIdentifierType = false;
          role.isParentSelectionDisabled = self.instanceconfig?.isParentSelectionDisabled;
          role.role = "role:aut";

          if (author.type === "schema:Person") {
            role.type = "schema:Person";
            role.firstname = author.firstname || "";
            role.lastname = author.lastname || "";
            if (author.orcid) {
              role.identifierText = author.orcid;
            }
            if (author.affiliation && author.affiliation.length > 0) {
              role.affiliationText = author.affiliation[0];
              role.affiliationType = "other";
            }
          } else if (author.type === "schema:Organization") {
            role.type = "schema:Organization";
            role.organizationText = author.name || "";
            role.organizationType = "other";
          }

          self.form.sections[0].fields.push(role);
        }
      } else {
        let role = fields.getField("role-extended");
        role.ordergroup = "role";
        role.roleVocabulary = "submitrolepredicate";
        role.identifierType = "ids:orcid";
        role.identifierLabel = "ORCID";
        role.showIdentifier = true;
        role.showIdentifierType = false;
        role.isParentSelectionDisabled = self.instanceconfig?.isParentSelectionDisabled;
        role.role = "role:aut";
        self.form.sections[0].fields.push(role);
      }

      self.form.sections[0].fields.push(fields.getField("oefos-subject"));
      
      let association = fields.getField("association");
      association.isParentSelectionDisabled = self.instanceconfig?.isParentSelectionDisabled;
      self.form.sections[0].fields.push(association);

      let lic = fields.getField("license");
      lic.showValueDefinition = true;
      lic.vocabulary = "alllicenses";
      if (doiImportData && doiImportData.license) {
        lic.value = doiImportData.license;
      }
      self.form.sections[0].fields.push(lic);

      // Section 1: Terminology services
      self.form.sections[1].fields.push(fields.getField("gnd-subject"));
      self.form.sections[1].fields.push(fields.getField("bk-subject"));

      // Section 2: Coverage
      self.form.sections[2].fields.push(fields.getField("temporal-coverage"));
      let place = fields.getField("spatial-geonames");
      place.showtype = false;
      self.form.sections[2].fields.push(place);

      // Section 3: Project
      self.form.sections[3].fields.push(fields.getField("project"));

      // Section 4: Represented object
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
      self.form.sections[4].fields.push(fields.getField("depth"));
      self.form.sections[4].fields.push(fields.getField("diameter"));
      self.form.sections[4].fields.push(fields.getField("material-text"));
      self.form.sections[4].fields.push(fields.getField("technique-text"));

      // Section 5: Bibliographic metadata
      // Alternate identifier (DOI)
      let aif = fields.getField("alternate-identifier");
      if (doiImportData && doiImportData.doi) {
        aif.value = doiImportData.doi;
        // Try to set type to DOI if available
        if (self.vocabularies && self.vocabularies['irobjectidentifiertypenoisbn']) {
          for (let term of self.vocabularies['irobjectidentifiertypenoisbn'].terms) {
            if (term['skos:notation'] && term['skos:notation'].includes('doi')) {
              aif.type = term['@id'];
              break;
            }
          }
        }
      }
      self.form.sections[5].fields.push(aif);

      // Date issued
      let published = fields.getField("date-edtf");
      published.type = 'dcterms:issued';
      if (doiImportData && doiImportData.dateIssued) {
        published.value = doiImportData.dateIssued;
      }
      self.form.sections[5].fields.push(published);

      // Volume
      let vol = fields.getField("volume");
      if (doiImportData && doiImportData.journalVolume) {
        vol.value = doiImportData.journalVolume;
      }
      self.form.sections[5].fields.push(vol);

      // Issue
      let issue = fields.getField("issue");
      if (doiImportData && doiImportData.journalIssue) {
        issue.value = doiImportData.journalIssue;
      }
      self.form.sections[5].fields.push(issue);

      // Series/Journal
      let sf = fields.getField("series");
      if (doiImportData) {
        if (doiImportData.journalTitle) {
          sf.title = doiImportData.journalTitle;
        }
        if (doiImportData.journalISSN) {
          sf.issn = doiImportData.journalISSN;
        }
        if (doiImportData.journalVolume) {
          sf.volume = doiImportData.journalVolume;
        }
        if (doiImportData.journalIssue) {
          sf.issue = doiImportData.journalIssue;
        }
        if (doiImportData.pageStart) {
          sf.pageStart = doiImportData.pageStart;
        }
        if (doiImportData.pageEnd) {
          sf.pageEnd = doiImportData.pageEnd;
        }
        if (doiImportData.dateIssued) {
          sf.issued = doiImportData.dateIssued;
        }
      }
      self.form.sections[5].fields.push(sf);

      // Publication/Publisher
      let publ = fields.getField("bf-publication");
      if (doiImportData && doiImportData.publisher) {
        publ.publisherName = doiImportData.publisher;
      }
      if (doiImportData && doiImportData.dateIssued) {
        publ.publishingDate = doiImportData.dateIssued;
      }
      self.form.sections[5].fields.push(publ);

      // Section 6: Accessibility
      let ac1 = fields.getField("accessibility-control");
      ac1.multiplicable = true;
      ac1.showValueDefinition = true;
      self.form.sections[6].fields.push(ac1);
      
      let ac2 = fields.getField("access-mode");
      ac2.multiplicable = true;
      ac2.showValueDefinition = true;
      self.form.sections[6].fields.push(ac2);
      
      let ac3 = fields.getField("accessibility-hazard");
      ac3.multiplicable = true;
      ac3.showValueDefinition = true;
      self.form.sections[6].fields.push(ac3);
      
      let ac4 = fields.getField("accessibility-feature");
      ac4.multiplicable = true;
      ac4.showValueDefinition = true;
      self.form.sections[6].fields.push(ac4);

      // Set language properties for all fields (same as upload.vue)
      for (let s of self.form.sections) {
        for (let f of s.fields) {
          f.configurable = false;
          f.multilingual = true;
          for (let prop of Object.keys(f)) {
            switch (prop) {
              case "language":
                if (!f.language) {
                  f.language = self.$i18n.locale;
                }
                break;
              case "nameLanguage":
                if (!f.nameLanguage) {
                  f.nameLanguage = self.$i18n.locale;
                }
                break;
              case "funderNameLanguage":
                if (!f.funderNameLanguage) {
                  f.funderNameLanguage = self.$i18n.locale;
                }
                break;
              case "descriptionLanguage":
                if (!f.descriptionLanguage) {
                  f.descriptionLanguage = self.$i18n.locale;
                }
                break;
              case "titleLanguage":
                if (!f.titleLanguage) {
                  f.titleLanguage = self.$i18n.locale;
                }
                break;
              case "citationLanguage":
                if (!f.citationLanguage) {
                  f.citationLanguage = self.$i18n.locale;
                }
                break;
            }
          }
        }
      }

      // Set object type if available
      if (doiImportData && doiImportData.publicationTypeId && ot) {
        self.$nextTick(() => {
          // Set object type via selectedTerms
          if (ot.selectedTerms === undefined) {
            ot.selectedTerms = [];
          }
          // Find the term in vocabulary and add to selectedTerms
          if (self.vocabularies && self.vocabularies['objecttype']) {
            for (let term of self.vocabularies['objecttype'].terms) {
              if (term['@id'] === doiImportData.publicationTypeId) {
                let field = {
                  value: term['@id']
                };
                if (term['skos:prefLabel']) {
                  let preflabels = term['skos:prefLabel'];
                  field['skos:prefLabel'] = [];
                  Object.entries(preflabels).forEach(([key, value]) => {
                    field['skos:prefLabel'].push({ '@value': value, '@language': key });
                  });
                }
                ot.selectedTerms = [field];
                break;
              }
            }
          }
        });
      }

      // Mark mandatory fields
      if (self.instanceconfig && self.instanceconfig.markmandatoryfnc) {
        self[self.instanceconfig.markmandatoryfnc]();
      } else if (self.markMandatory) {
        self.markMandatory();
      }
    }
  }
}
</script>
