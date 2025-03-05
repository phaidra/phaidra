<template>
  <v-container fluid>
    <v-row class="mt-8">
      <v-col cols="3">
        <p-i-file
          v-bind.sync="filefield"
          v-on:input-file="setFilename(filefield, $event)"
        ></p-i-file>
      </v-col>
      <v-col cols="3">
        <v-autocomplete
        
          v-on:input="setLicense($event)"
          :items="this.vocabularies['alllicenses'].terms"
          :item-value="'@id'"
          :filter="autocompleteFilter"
          hide-no-data
          :filled="true"
          :height="7"
          :label="$t('License')"
          return-object
          clearable
          :disabled="licenseDisabled"
        >
          <!-- the attr binds the 'disabled' property of the vocabulary term (if defined) to the item component -->
          <template slot="item" slot-scope="{ attr, item }">
            <v-list-item-content two-line>
              <v-list-item-title v-html="`${getLocalizedTermLabel('alllicenses', item['@id'])}`"></v-list-item-title>
              <v-list-item-subtitle v-html="`${item['@id']}`"></v-list-item-subtitle>
            </v-list-item-content>
          </template>
          <template slot="selection" slot-scope="{ item }">
            <v-list-item-content>
              <v-list-item-title v-html="`${getLocalizedTermLabel('alllicenses', item['@id'])}`"></v-list-item-title>
            </v-list-item-content>
          </template>
      </v-autocomplete>
      </v-col>
      <v-col cols="3">
        <v-text-field
          v-model="acnumber"
          :filled="true"
          :label="$t('AC number')"
        ></v-text-field>
      </v-col>
      <v-col cols="3">
        <v-btn dark color="green" @click="fetchMetadata()">{{  $t('Fetch metadata') }}</v-btn>
        <v-btn class="primary mr-4" @click="upload()" :disabled="!uploadEnabled">{{  'Upload ' + (createmethod === 'unknown' ? 'data' : createmethod) }}</v-btn>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="2">
        <p-i-select
          v-bind.sync="objectypefield"
          v-on:input="selectInput(objectypefield, $event)"
        ></p-i-select>
      </v-col>
      <v-col cols="5">
        <p-i-association
          v-bind.sync="associationfield"
          v-on:input="selectInput(associationfield, $event)"
        ></p-i-association>
      </v-col>
      <v-col cols="5">
        <p-i-subject-oefos
          v-bind.sync="oefosfield"
          v-on:input="oefosfield.value=$event"
          v-on:resolve="updateVocSubject(oefosfield, $event)"
        ></p-i-subject-oefos>
      </v-col>
    </v-row>
    <!-- <v-row>{{ jsonldOrig }}</v-row>  -->
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title class="title font-weight-light grey white--text">{{ $t('Metadata preview') }}</v-card-title>
          <v-card-text>
            <v-container class="mt-6">
              <p-d-jsonld
                :jsonld="jsonld"
                :key="JSON.stringify(jsonld)"
              ></p-d-jsonld>
            </v-container>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    <v-row class="mx-4" v-if="uploadProgress">
      <v-col cols="12">
        <v-row no-gutters>
          <v-progress-linear :indeterminate="uploadProgress === 100" v-model="uploadProgress" color="primary"></v-progress-linear>
        </v-row>
        <v-row no-gutters class="primary--text mt-1">
          <span v-if="uploadProgress < 100">{{ $t('Uploading...') + ' ' + Math.ceil(uploadProgress) }}%</span>
          <span v-else>{{ $t('Processing...') }}</span>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import jsonLdUtils from 'phaidra-vue-components/src/utils/json-ld'
import { context } from "../../mixins/context"
import { config } from "../../mixins/config"
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary"

export default {
  layout: "main",
  mixins: [context, config, vocabulary],
  computed: {
    uploadEnabled() {
      return this.licensefield.value !== '' && 
      this.filefield.value !== '' && 
      this.acnumber !== '' && 
      Object.keys(this.jsonld).length > 3
    }
  },
  data() {
    return {
      jsonld: {},
      jsonldOrig: {},
      rights: {},
      acnumber: '',
      createmethod: 'unknown',
      uploadBtnLabel: 'Upload data',
      uploadProgress: 0,
      licenseDisabled: false,
      filefield: {
        id: 'file',
        fieldname: 'File',
        predicate: 'ebucore:filename',
        component: 'p-file',
        label: 'File to upload',
        mimeLabel: 'File type',
        value: '',
        mimetype: '',
        autoMimetype: false,
        fileErrorMessages: [],
        mimetypeErrorMessages: [],
        showMimetype: false,
        definition: 'File input.'
      },
      licensefield: {
        id: 'license',
        fieldname: 'License',
        predicate: 'edm:rights',
        component: 'p-select',
        vocabulary: 'alllicenses',
        label: 'License',
        value: '',
        'skos:prefLabel': [],
        errorMessages: [],
        definition: 'The value will indicate the copyright, usage and access rights that apply to this digital representation.'
      },
      objectypefield: {
        id: 'object-type',
        fieldname: 'Object type',
        predicate: 'edm:hasType',
        component: 'p-select',
        vocabulary: 'objecttype',
        multiplicable: false,
        label: 'Object type',
        value: 'https://pid.phaidra.org/vocabulary/47QB-8QF1',
        'skos:prefLabel': [],
        errorMessages: [],
        definition: 'This property relates a resource with the concepts it belongs to. It does not capture aboutness. Example: Photography',
        helptext: 'An object type represents real-world entity. For example, an object type can represent a photography, an interview, a lecture or a letter.'
      },
      associationfield: {
        id: 'association',
        fieldname: 'Association',
        predicate: 'rdax:P00009',
        component: 'p-association',
        multiplicable: false,
        label: 'Association',
        value:  {
          "@id": "https://pid.phaidra.org/univie-org/W2C2-DHA4",
          "@type": "foaf:Organization",
          "parent_id": "https://pid.phaidra.org/univie-org/V2XH-NPJ9",
          "skos:notation": "A150",
          "skos:prefLabel": {
            "deu": "Bibliotheks- und Archivwesen",
            "eng": "Vienna University Library and Archive Services"
          },
        },
        'skos:prefLabel': [],
        definition: 'Relates an object to a corporate body who is associated with an object.'
      },
      oefosfield: {
        id: 'oefos-subject',
        fieldname: 'Subject (ÖFOS)',
        predicate: 'dcterms:subject',
        type: 'skos:Concept',
        component: 'p-subject-oefos',
        multiplicable: false,
        label: 'Subject (ÖFOS)',
        value: '',
        'rdfs:label': [],
        'skos:prefLabel': [],
        loadedpreflabel: '',
        definition: 'The topic of the resource, represented using a controlled vocabulary.'
      }
    };
  },
  methods: {
    setLicense: async function ($event) {
      this.licensefield.value = $event['@id']
      this.mergeFormFieldsToJsonld()
      
    },
    mergeFormFieldsToJsonld: function () {
      // we want to rewrite the vlaues we set before (jsonLdUtils.push_object would otherwise keep adding them), but not it these fields had values which came from alma mapping (if there were any)
      if (this.jsonldOrig) {
        if (this.jsonldOrig['edm:hasType']) {
          this.jsonld['edm:hasType'] = JSON.parse(JSON.stringify(this.jsonldOrig['edm:hasType']))
        } else {
          delete this.jsonld['edm:hasType']
        }

        if (this.jsonldOrig['dcterms:subject']) {
          this.jsonld['dcterms:subject'] = JSON.parse(JSON.stringify(this.jsonldOrig['dcterms:subject']))
        } else {
          delete this.jsonld['dcterms:subject']
        }

        if (this.jsonldOrig['rdax:P00009']) {
          this.jsonld['rdax:P00009'] = JSON.parse(JSON.stringify(this.jsonldOrig['rdax:P00009']))
        } else {
          delete this.jsonld['rdax:P00009']
        }

        if (this.jsonldOrig['edm:rights']) {
          this.jsonld['edm:rights'] = this.jsonldOrig['edm:rights'][0]
        } else {
          delete this.jsonld['edm:rights']
        }
      }      
      jsonLdUtils.push_object(this.jsonld, this.objectypefield.predicate, jsonLdUtils.get_json_object(this.objectypefield['skos:prefLabel'], null, 'skos:Concept', [this.objectypefield.value]))
      jsonLdUtils.push_object(this.jsonld, this.oefosfield.predicate, jsonLdUtils.get_json_concept(this.oefosfield['skos:prefLabel'], this.oefosfield['rdfs:label'], 'skos:Concept', [this.oefosfield.value], this.oefosfield['skos:notation'] ? this.oefosfield['skos:notation'] : null))
      jsonLdUtils.push_object(this.jsonld, this.associationfield.predicate, jsonLdUtils.get_json_object(this.associationfield['skos:prefLabel'], null, this.associationfield.type, [this.associationfield.value]))
      this.jsonld['edm:rights'] = [ this.licensefield.value ]
      this.jsonld['ebucore:filename'] = [ this.filefield.value ]
      this.jsonld['ebucore:hasMimeType'] = [ this.filefield.mimetype ]
    },
    fetchMetadata: async function () {

      this.$store.commit('setLoading', true)
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/alma/' + this.acnumber + '/jsonld'
        })
        if (response.data) {
          this.jsonldOrig = response.data.jsonld
          if (this.jsonldOrig['edm:rights']) {
            this.licensefield.value = this.jsonldOrig['edm:rights'][0]
          }
          this.jsonld = JSON.parse(JSON.stringify(this.jsonldOrig))
          this.mergeFormFieldsToJsonld()
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    upload: async function () {

      this.$store.commit('clearAlerts')
      if (this.licensefield.value === '') {
        this.$store.commit('setAlerts', [{ type: 'error', msg: 'Missing license' }])
        return
      }

      if (!this.acnumber) {
        this.$store.commit('setAlerts', [{ type: 'error', msg: 'Missing AC number' }])
        return
      }

      this.$store.commit('clearAlerts')
      if (!this.filefield.file) {
        this.$store.commit('setAlerts', [{ type: 'error', msg: 'Missing file' }])
        this.$vuetify.goTo(0);
        return
      }
      
      var httpFormData = new FormData()
      httpFormData.append('file', this.filefield.file)
      httpFormData.append('mimetype', this.filefield.mimetype)
      httpFormData.append('metadata', JSON.stringify({ 'metadata': { 'json-ld': this.jsonld } }))
      
      let self = this
      this.$store.commit('setLoading', true)
      try {
        let response = await this.$axios.request({
          method: 'POST',
          url: '/' + this.createmethod + '/create',
          headers: {
            'Content-Type': 'multipart/form-data',
            'X-XSRF-TOKEN': this.$store.state.user.token
          },
          data: httpFormData,
          onUploadProgress: function (progressEvent) {
            self.uploadProgress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
          }
        })
        if (response.data.alerts && response.data.alerts.length > 0) {
          this.$store.commit('setAlerts', response.data.alerts)
        }
        if (response.data.status === 200) {
          console.log(response.data)
          if (response.data.pid) {
            this.$router.push(this.localeLocation({ path: `/detail/${response.data.pid}` }));
            this.$vuetify.goTo(0);
          }
        }
      } catch (error) {
        console.log(error)
        this.$store.commit('setAlerts', [{ type: 'error', msg: error }])
      } finally {
        this.$vuetify.goTo(0)
        this.$store.commit('setLoading', false)
        this.uploadProgress = 0
      }
    },
    setFilename: function (f, event) {
      f.value = event.name
      f.file = event
      console.log('browser mimetype:')
      console.log(event.type)
      if (event.type === '') {
        // if browser does not provide mimetype
        // try to match the extension with our vocabulary
        let ext = event.name.split('.').pop()
        console.log('no mimetype, using extension (' + ext + ') to search vocabulary')
        for (let mt of this.vocabularies['mimetypes'].terms) {
          for (let notation of mt['skos:notation']) {
            if (ext === notation) {
              console.log('found mimetype: ' + mt['@id'])
              f.mimetype = mt['@id']
            }
          }
        }
      } else {
        f.mimetype = event.type
      }

      switch (f.mimetype) {
        case 'image/jpeg':
        case 'image/tiff':
        case 'image/gif':
        case 'image/png':
        case 'image/x-ms-bmp':
          // picture
          this.createmethod = 'picture'
          this.uploadBtnLabel
          break

        case 'audio/wav':
        case 'audio/mpeg':
        case 'audio/flac':
        case 'audio/ogg':
          // audio
          this.createmethod = 'audio'
          break

        case 'application/pdf':
          // document
          this.createmethod = 'document'
          break

        case 'video/mpeg':
        case 'video/avi':
        case 'video/mp4':
        case 'video/quicktime':
        case 'video/x-matroska':
          // video
          this.createmethod = 'video'
          break

        default:
          // data
          this.createmethod = 'unknown'
          break
      }

      this.mergeFormFieldsToJsonld()
    },
    selectInput: function (f, event) {
      if (event) {
        f.value = event['@id']
        if (event['@type']) {
          f.type = event['@type']
        }
        if (event['skos:prefLabel']) {
          let preflabels = event['skos:prefLabel']
          f['skos:prefLabel'] = []
          Object.entries(preflabels).forEach(([key, value]) => {
            f['skos:prefLabel'].push({ '@value': value, '@language': key })
          })
        }
        if (event['rdfs:label']) {
          let rdfslabels = event['rdfs:label']
          if (rdfslabels) {
            f['rdfs:label'] = []
            Object.entries(rdfslabels).forEach(([key, value]) => {
              f['rdfs:label'].push({ '@value': value, '@language': key })
            })
          }
        }
        if (event['skos:notation']) {
          f['skos:notation'] = event['skos:notation']
        }
      } else {
        f.value = ''
        f['skos:prefLabel'] = []
        f['rdfs:label'] = []
        f['skos:notation'] = []
      }

      this.mergeFormFieldsToJsonld()
    },
    updateVocSubject: function (f, event) {
      if (event) {
        f.value = event['@id']
        if (event['@type']) {
          f.type = event['@type']
        }
        if (event['skos:prefLabel']) {
          let preflabels = event['skos:prefLabel']
          f['skos:prefLabel'] = []
          Object.entries(preflabels).forEach(([key, value]) => {
            f['skos:prefLabel'].push({ '@value': value, '@language': key })
          })
        }
        if (event['rdfs:label']) {
          let rdfslabels = event['rdfs:label']
          if (rdfslabels) {
            f['rdfs:label'] = []
            Object.entries(rdfslabels).forEach(([key, value]) => {
              f['rdfs:label'].push({ '@value': value, '@language': key })
            })
          }
        }
        if (event['skos:notation']) {
          f['skos:notation'] = event['skos:notation']
        }
      } else {
        f.value = ''
        f['skos:prefLabel'] = []
        f['rdfs:label'] = []
        f['skos:notation'] = []
      }

      this.mergeFormFieldsToJsonld()
    }
  }
};
</script>