<template>
  <v-container>
    <v-row no-gutters>
      <h3 class="title font-weight-light primary--text mb-4">
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
    <v-row no-gutters justify="center">
      <v-col cols="4">
        <v-text-field
          :error-messages="doiImportErrors"
          filled
          v-model="doiImportInput"
          label="DOI"
          :placeholder="$t('please enter')"
        />
      </v-col>
      <v-col cols="3" class="ml-4 mt-2">
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
          color="grey"
          @click="resetDOIImport()"
          >{{ $t("Reset") }}</v-btn
        >
      </v-col>
    </v-row>
    <v-row no-gutters v-if="doiImportData" justify="center">
      <v-col cols="12" md="7">
        <v-card>
          <v-card-title
            class="title font-weight-light grey white--text"
            >{{
              $t("Following metadata were retrieved")
            }}
            <p class="m-0 ml-2" v-if="metaProviderName">(Agency: {{ metaProviderName }})</p>
            </v-card-title
          >
          <v-card-text>
            <v-container>
              <v-row v-if="doiImportData.title">
                <v-col
                  md="2"
                  cols="12"
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
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
                  class="primary--text text-right"
                  >{{ $t("Access Rights") }}</v-col
                >
                <v-col md="10" cols="12">{{
                  doiImportData.accessrightsLabel
                }}</v-col>
              </v-row>
            </v-container>
          </v-card-text>
        </v-card>
        <div class="text-right mt-4">
          <v-btn color="primary" @click="proceedForm">Load Form</v-btn>
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
    // loadForm: {
    //   type: Function,
    //   required: true
    // }
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
    proceedForm: function () {
      console.log('this.form', this.form);
      this.$emit('load-form', this.form);
    },
    resetDOIImport: function () {
      this.doiImportInput = null;
      this.doiImportData = null;
      this.doiImportErrors = [];
      this.journalSearchQuery = null;
      this.journalSearchISSN = null;
      this.journalSearchItems = [];
      this.journalSearchSelected = [];
      this.resetForm(this, null);
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
              this.resetForm(this, this.doiImportData);
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
                      auth.orcid = author["ORCID"].replace(
                        "http://orcid.org/",
                        ""
                      );
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

            if (crossrefData["abstract"] && doiImportData.license.includes('http://creativecommons.org/licenses')) {
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
            this.resetForm(this, this.doiImportData);
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
    resetForm: function (self, doiImportData) {
      self.$store.commit("vocabulary/enableAllVocabularyTerms", "versiontypes");
      self.$store.commit(
        "vocabulary/enableAllVocabularyTerms",
        self.irObjectTypeVocabulary
      );

      self.form = {
        sections: [],
      };

      let smf = [];

      let rt = fields.getField("resource-type");
      rt.value = "https://pid.phaidra.org/vocabulary/69ZZ-2KGX";
      smf.push(rt);

      let f = fields.getField("file");
      f.multiplicable = false;
      f.mimetype = "application/pdf";
      f.autoMimetype = true;
      f.showMimetype = false;
      smf.push(f);

      let tf = fields.getField("title");
      if (doiImportData && doiImportData.title) {
        tf.title = doiImportData.title;
      }
      if (doiImportData && doiImportData.subtitle) {
        tf.subtitle = doiImportData.subtitle;
        tf.hideSubtitle = false;
      }
      tf.multilingual = false;
      tf.multiplicable = false;
      smf.push(tf);
      if (doiImportData && doiImportData.descriptions.length > 0) {
        for (let descItem of doiImportData.descriptions) {
          let descField = fields.getField("description");
          descField.value = descItem.description;
          descField.language = descItem.lang;
          descField.type = "bf:Summary";
          smf.push(descField);
        }
      }

      if (doiImportData && doiImportData.authors.length > 0) {
        for (let author of doiImportData.authors) {
          let role = fields.getField("role-extended");
          role.type = author.type;
          role.role = "role:aut";
          role.showBirthAndDeathDate = false
          if (
            self.submitformparam === "journal-article" ||
            self.submitformparam === "book-part"
          ) {
            role.hideRole = true;
            role.label = "Author";
          }
          role.roleVocabulary = "irrolepredicate";
          role.ordergroup = "roles";
          role.firstname = author["firstname"] ? author["firstname"] : "";
          role.lastname = author["lastname"] ? author["lastname"] : "";
          role.showIdentifierType = false;
          role.identifierType = "ids:orcid";
          role.identifierLabel = "ORCID";
          role.identifierText = author["orcid"] ? author["orcid"] : "";
          if (author["affiliation"]) {
            role.affiliationType = "other";
            // iterate, although currently multiple affiliations are not supported
            for (let af of author["affiliation"]) {
              role.affiliationText = af;
              break;
            }
          } else {
            role.affiliationType = "";
          }
          if (author.type === "schema:Organization") {
            role.organizationType = "other";
            role.organizationText = author["name"];
          }
          smf.push(role);
        }
      } else {
        let role = fields.getField("role-extended");
        role.role = "role:aut";
        role.type = "schema:Person";
        role.enableTypeSelect = false;
        role.showBirthAndDeathDate = false
        if (
          self.submitformparam === "journal-article" ||
          self.submitformparam === "book-part"
        ) {
          role.hideRole = true;
          role.label = "Author";
        }
        role.roleVocabulary = "irrolepredicate";
        role.ordergroup = "roles";
        role.showIdentifierType = false;
        role.identifierType = "ids:orcid";
        role.identifierLabel = "ORCID";
        role.affiliationType = "";
        smf.push(role);
      }

      let vtf = fields.getField("version-type");
      vtf.showValueDefinition = true;
      smf.push(vtf);

      let issued = fields.getField("date-edtf");
      issued.mainSubmitDate = true; // we need to find this field again when changing predicates
      issued.picker = true;
      issued.type = "dcterms:issued";
      issued.hideType = true;
      issued.dateLabel = "Date issued";
      issued.multiplicable = false;
      if (doiImportData && doiImportData.dateIssued) {
        issued.value = doiImportData.dateIssued;
      }
      smf.push(issued);

      let lmf = fields.getField("language");
      lmf.multiplicable = false;
      if (doiImportData && doiImportData.language) {
        lmf.value = doiImportData.language;
      }
      smf.push(lmf);

      let otf = fields.getField("object-type");
      otf.vocabulary = 'objecttype';
      otf.multiplicable = false;
      otf.label = "Type of publication";
      otf.showValueDefinition = true;
      if (doiImportData && doiImportData.publicationTypeId) {
        otf.value = doiImportData.publicationTypeId;
      }
      if (self.submitformparam === "book") {
        otf.value = "https://pid.phaidra.org/vocabulary/47QB-8QF1";
        otf.disabled = true;
      }
      if (self.submitformparam === "book-part") {
        otf.value = "https://pid.phaidra.org/vocabulary/XA52-09WA";
        otf.disabled = true;
      }
      smf.push(otf);

      if (self.submitformparam === "book-part") {
        let sf = fields.getField("contained-in");
        sf.label = "Appeared in";
        sf.multilingual = false;
        sf.series[0].multiplicableCleared = true;
        sf.hideSeriesIssn = true;
        sf.hideSeriesIssue = true;
        sf.hideSeriesIssued = true;
        sf.collapseSeries = true;
        sf.hidePages = false;
        sf.publicationType = "other";
        sf.publisherSearch = false;
        sf.publisherShowDate = true;
        sf.publisherLabel = "PUBLISHER_VERLAG";
        if (doiImportData) {
          if (doiImportData.pageStart) {
            sf.pageStart = doiImportData.pageStart;
          }
          if (doiImportData.pageEnd) {
            sf.pageEnd = doiImportData.pageEnd;
          }
          if (doiImportData.publisher) {
            sf.publisherName = doiImportData.publisher;
          }
          if (doiImportData.dateIssued) {
            sf.publishingDate = doiImportData.dateIssued;
          }
        }
        smf.push(sf);
      }

      if (self.submitformparam === "book") {
        let pf = fields.getField("bf-publication");
        pf.publisherSearch = false;
        pf.multiplicable = false;
        pf.showDate = true;
        pf.label = "PUBLISHER_VERLAG";
        if (doiImportData && doiImportData.publisher) {
          pf.publisherName = doiImportData.publisher;
        }
        if (doiImportData && doiImportData.dateIssued) {
          pf.publishingDate = doiImportData.dateIssued;
        }
        smf.push(pf);
      }

      let arf = fields.getField("access-right");
      arf.vocabulary = "iraccessright";
      arf.showValueDefinition = true;
      if (doiImportData && doiImportData.accessrights) {
        arf.value = doiImportData.accessrights
      }
      smf.push(arf);

      let embargoDate = fields.getField("date-edtf");
      embargoDate.picker = true;
      embargoDate.type = "dcterms:available";
      embargoDate.hideType = true;
      embargoDate.dateLabel = "Embargo date";
      embargoDate.multiplicable = false;
      smf.push(embargoDate);

      let lic = fields.getField("license");
      if (doiImportData && doiImportData.license) {
        lic.value = doiImportData.license;
      } else {
        lic.value = 'http://rightsstatements.org/vocab/InC/1.0/';
      }
      lic.label = 'Rights';
      smf.push(lic);


      // handled by submit-ir-description-keyword component
      smf.push(fields.getField("abstract"));
      self.keywordsValue = [];
      let keyws = fields.getField("keyword");
      if (doiImportData) {
        if (doiImportData.keywords) {
          keyws.value = doiImportData.keywords;
          self.keywordsValue = doiImportData.keywords;
        }
      }
      smf.push(keyws);

      if (self.submitformparam === "book") {
        let isbn = {
          id: "alternate-identifier",
          fieldname: "Alternate identifier",
          predicate: "rdam:P30004",
          component: "isbn",
          type: "ids:isbn",
          showType: false,
          disableType: true,
          multiplicable: false,
          identifierLabel: "ISBN",
          valueErrorMessages: [],
          value: "",
        };
        if (doiImportData && doiImportData.ISBN) {
          isbn.value = doiImportData.ISBN;
        }
        smf.push(isbn);
      }

      let aif = fields.getField("alternate-identifier");
      aif.label = "Identifier";
      aif.identifierLabel = "Publication identifier(s)";
      aif.vocabulary = "irobjectidentifiertypenoisbn";
      aif.multiplicable = true;
      aif.addOnly = true;
      aif.subloopFlag = true;
      if (doiImportData && doiImportData.doi) {
        aif.type = "ids:doi";
        aif.value = doiImportData.doi;
      }
      smf.push(aif);

      // handled by submit-ir-funding-field component
      let pof = fields.getField("project");
      pof.label = "Funder/Project";
      pof.multiplicable = true;
      pof.multiplicableCleared = true;
      pof.subloopFlag = true;
      smf.push(pof);

      if (self.submitformparam === "book") {
        let nop = fields.getField("number-of-pages");
        nop.multiplicable = false;
        smf.push(nop);
      }

      if (
        self.submitformparam === "journal-article" ||
        self.submitformparam === "book"
      ) {
        let sf = fields.getField("series");
        sf.multilingual = false;
        sf.multiplicableCleared = self.submitformparam === "book";
        sf.hideIdentifier = true;
        sf.label =
          self.submitformparam === "book" ? "Series" : "Journal/Series";
        sf.hidePages = self.submitformparam !== "journal-article";
        sf.hideIssue = self.submitformparam !== "journal-article";
        sf.hideIssued = self.submitformparam !== "journal-article";
        sf.hideIssn = self.submitformparam !== "journal-article";
        sf.issuedDatePicker = true;
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
          if (doiImportData && doiImportData.dateIssued) {
            sf.issued = doiImportData.dateIssued;
          }
        }
        smf.push(sf);
      }


      self.form.sections.push({
        type: "digitalobject",
        obligation: "mandatory",
        id: 5,
        fields: smf,
      });

      self.$nextTick().then(function () {
        // put things here which might be overwritten
        // when components re-initialize
        // some use nextTick to wait for vocabularies or
        // something, and then fire input event which is cought
        // eg by selectInput here, but they fire AFTER resetForm
        // while still having old values set
        self.license = null;
        self.showEmbargoDate = false;
      });
      if (this.instanceconfig.markmandatoryfnc) {
          this[this.instanceconfig.markmandatoryfnc]()
        } else {
          this.markMandatory()
        }
    }
  }
}
</script>
