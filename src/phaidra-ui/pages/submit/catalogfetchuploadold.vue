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
          :value = "getTerm('alllicenses', 'http://rightsstatements.org/vocab/InC/1.0/')"
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
              <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
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
     <!--<v-row>{{ mods }}</v-row>
    <v-row>{{ modsjson }}</v-row> -->
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-card-title class="title font-weight-light grey white--text">{{ $t('Metadata preview') }}</v-card-title>
          <v-card-text>
            <v-container class="mt-6">
              <p-d-mods-rec
                :children="modsjson"
              ></p-d-mods-rec>
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
import { context } from "../../mixins/context"
import { config } from "../../mixins/config"
import { vocabulary } from "phaidra-vue-components/src/mixins/vocabulary"

export default {
  layout: "main",
  mixins: [context, config, vocabulary],
  data() {
    return {
      uploadEnabled: false,
      mods: '',
      modsjson: [],
      rights: {},
      license: { '@id': 'http://rightsstatements.org/vocab/InC/1.0/' },
      acnumber: '',
      createmethod: 'unknown',
      uploadBtnLabel: 'Upload data',
      uploadProgress: 0,
      licenseDisabled: true,
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
        value: 'http://rightsstatements.org/vocab/InC/1.0/',
        'skos:prefLabel': [],
        errorMessages: [],
        definition: 'The value will indicate the copyright, usage and access rights that apply to this digital representation.'
      }
    };
  },
  methods: {
    setLicense: async function ($event) {
      this.license = $event
      this.fetchMetadata()
    },
    fetchMetadata: async function () {
      
      this.$store.commit('clearAlerts')
      if (this.license === null) {
        this.$store.commit('setAlerts', [{ type: 'error', msg: 'Missing license' }])
        this.uploadEnabled = false
        return
      }
      if (!this.acnumber) {
        this.$store.commit('setAlerts', [{ type: 'error', msg: 'Missing AC number' }])
        this.uploadEnabled = false
        return
      }

      this.$store.commit('setLoading', true)
      try {
        let response = await this.$axios.request({
          method: 'GET',
          url: '/alma/search',
          params: {
            version: '1.2',
            operation: 'searchRetrieve',
            recordSchema: 'mods',
            maximumRecords: 10,
            startRecord: 1,
            query: 'local_control_field_009=' + this.acnumber
          }
        })
        if (response.data) {
          let xml = response.data
          console.log(xml)
          const parser = new DOMParser()
          const doc = parser.parseFromString(xml, 'application/xml')
          
          let ac = doc.createElementNS('http://www.loc.gov/mods/v3','identifier')
          ac.setAttribute('type', 'acnumber')
          ac.innerHTML = this.acnumber

          let ri = doc.querySelector('mods recordInfo')
          ri.before(ac)

          let existingLic = doc.querySelector("mods accessCondition[type='use and reproduction']")
          if (existingLic) {
            this.licenseDisabled = true
          } else {
            this.licenseDisabled = false
            let lic = doc.createElementNS('http://www.loc.gov/mods/v3','accessCondition')
            lic.setAttribute('type', 'use and reproduction')
            lic.innerHTML = this.license['@id']
            ac.after(lic)
          }

          this.mods = doc.querySelector('mods').outerHTML

          this.$store.commit('setLoading', true)
          try {
            let response = await this.$axios.post('mods/xml2json', this.mods, { headers: { 'Content-Type': 'text/xml'} } )
            if (response.data) {
              this.modsjson = response.data.metadata.mods
            }
            this.uploadEnabled = true
          } catch (error) {
            console.log(error)
          } finally {
            this.$store.commit('setLoading', false)
          }
        }
      } catch (error) {
        console.log(error)
      } finally {
        this.$store.commit('setLoading', false)
      }
    },
    upload: async function () {
      this.$store.commit('clearAlerts')
      if (!this.filefield.file) {
        this.$store.commit('setAlerts', [{ type: 'error', msg: 'Missing file' }])
        this.$vuetify.goTo(0);
        return
      }
      
      var httpFormData = new FormData()
      httpFormData.append('file', this.filefield.file)
      httpFormData.append('mimetype', this.filefield.mimetype)
      httpFormData.append('metadata', JSON.stringify({ 'metadata': { 'mods': this.modsjson } }))
      
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
    }
  }
};
</script>