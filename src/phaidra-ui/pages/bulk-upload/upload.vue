<template>
  <v-container class="upload">
    <BulkUploadSteps />
    <v-row>
      <v-col>
        <h1 class="text-h4">Step 4: Upload</h1>
        <p class="text-subtitle-1 mt-2">
          Upload your data to PHAIDRA. You can close the page and return later to resume any interrupted uploads.
        </p>
      </v-col>
    </v-row>

    <div class="position-relative">
      <LoginOverlay :is-logged-in="!!isLoggedIn" />
      <CompletionOverlay />

      <v-row class="mt-4">
        <v-col cols="12">
          <FileSelection
            :csv-content="csvContent"
            :field-mappings="fieldMappings"
            v-model="selectedFiles"
          />
        </v-col>
      </v-row>

      <v-row class="mt-4">
        <v-col cols="12">
          <UploadProgress :progress="getUploadProgress" />
        </v-col>
      </v-row>

      <v-row class="mt-4">
        <v-col cols="12">
          <UploadTable
            :table-data="tableData"
            @show-error="showError"
            @retry-upload="retryUpload"
          />
        </v-col>
      </v-row>
    </div>

    <!-- Navigation -->
    <v-row justify="space-between" class="mt-4">
      <v-col cols="auto">
        <v-btn
          :disabled="isUploading || isUploadComplete"
          text
          :to="steps[3].route"
        >
          <v-icon left>mdi-arrow-left</v-icon>
          Back
        </v-btn>
      </v-col>
      <v-col cols="auto">
        <v-btn
          color="primary"
          :loading="isUploading"
          :disabled="!isLoggedIn || isUploading || isUploadComplete"
          @click="startUpload"
        >
          <template v-if="hasFailedUploads">
            Retry Failed Uploads
          </template>
          <template v-else>
            Start Upload
          </template>
          <v-icon right>mdi-cloud-upload</v-icon>
        </v-btn>
      </v-col>
    </v-row>

    <!-- Error Dialog -->
    <v-dialog
      v-model="errorDialog.show"
      max-width="500"
    >
      <v-card>
        <v-card-title>Upload Error</v-card-title>
        <v-card-text>
          <p class="mb-2"><strong>Row:</strong> {{ errorDialog.row }}</p>
          <p class="mb-0"><strong>Error:</strong> {{ errorDialog.error }}</p>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            text
            @click="errorDialog.show = false"
          >
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import { mapState, mapGetters, mapMutations } from 'vuex'
import BulkUploadSteps from '../../components/BulkUploadSteps.vue'
import LoginOverlay from '../../components/bulk-upload/LoginOverlay.vue'
import CompletionOverlay from '../../components/bulk-upload/CompletionOverlay.vue'
import UploadTable from '../../components/bulk-upload/UploadTable.vue'
import UploadProgress from '../../components/bulk-upload/UploadProgress.vue'
import FileSelection from '../../components/bulk-upload/FileSelection.vue'
import { context } from "../../mixins/context"
import { config } from "../../mixins/config"
import jsonld from "phaidra-vue-components/src/utils/json-ld"
import { fieldSettings } from '../../config/bulk-upload/field-settings'

export default {
  name: 'Upload',
  components: {
    BulkUploadSteps,
    LoginOverlay,
    CompletionOverlay,
    UploadTable,
    UploadProgress,
    FileSelection
  },
  mixins: [context, config],
  middleware: 'bulk-upload',

  data() {
    return {
      fieldSettings,
      isUploading: false,
      selectedFiles: [],
      errorDialog: {
        show: false,
        row: null,
        error: null
      }
    }
  },

  computed: {
    ...mapState('bulk-upload', ['steps', 'csvContent', 'fieldMappings']),
    ...mapGetters('bulk-upload', ['getUploadState', 'getUploadProgress', 'isUploadComplete']),

    hasFailedUploads() {
      return this.getUploadProgress.failed > 0
    },

    tableData() {
      if (!this.csvContent) return []

      const rows = this.csvContent.split('\n')
      const headers = rows[0].split(';').map(h => h.trim()).filter(Boolean)
      
      return rows.slice(1)
        .filter(row => row && row.trim()) // Skip empty rows
        .map((row, index) => {
          const values = row.split(';').map(v => v.trim())
          const uploadState = this.getUploadState(index)
          
          // Get title and filename from mapping
          const titleMapping = this.fieldMappings['Title']
          const filenameMapping = this.fieldMappings['Filename']
          
          const title = titleMapping?.source === 'phaidra-field' 
            ? titleMapping.phaidraValue
            : titleMapping?.source === 'csv-column'
              ? values[headers.indexOf(titleMapping.csvValue)] || 'No title'
              : 'No title'
              
          const filename = filenameMapping?.source === 'phaidra-field'
            ? filenameMapping.phaidraValue
            : filenameMapping?.source === 'csv-column'
              ? values[headers.indexOf(filenameMapping.csvValue)]
              : null

          return {
            index: index + 1,
            title,
            filename,
            status: uploadState.status,
            pid: uploadState.pid,
            error: uploadState.error
          }
        })
    },

    isLoggedIn() {
      return this.user && this.user.username
    }
  },

  methods: {
    ...mapMutations('bulk-upload', [
      'setUploadState',
      'setUploadProgress',
      'clearUploadState',
      'completeStep',
      'hardResetState'
    ]),

    showError(item) {
      this.errorDialog = {
        show: true,
        row: item.index,
        error: item.error
      }
    },

    async startUpload() {
      if (this.isUploading) return

      this.isUploading = true
      const rows = this.csvContent?.split('\n') || []
      const headers = rows[0].split(';').map(h => h.trim()).filter(Boolean)
      
      // Filter out empty rows
      const validRows = rows.slice(1).filter(row => row && row.trim())

      // Initialize progress
      this.setUploadProgress({
        total: validRows.length,
        completed: this.getUploadProgress.completed,
        failed: this.getUploadProgress.failed
      })

      // Process each row
      for (let i = 0; i < validRows.length; i++) {
        const rowIndex = i
        const uploadState = this.getUploadState(rowIndex)

        // Skip if already completed
        if (uploadState.status === 'completed') continue

        try {
          this.setUploadState({ rowIndex, status: 'uploading', pid: null, error: null })
          const values = validRows[i].split(';').map(v => v.trim())

          const formData = new FormData()
          const formMetadata = await this.createFormMetadata(headers, values)

          // Upload to PHAIDRA
          // // Mock 50% chance of failure
          // const shouldFail = Math.random() < 0.5;
          
          // if (shouldFail) {
          //   throw new Error('Mock upload failure: Random error occurred');
          // }

          let createmethod = 'unknown'

          // Add file data if present
          const filenameMapping = this.fieldMappings['Filename']
          const filenameIndex = headers.indexOf(filenameMapping.csvValue)
          const filename = values[filenameIndex]
          if (filename) {
            const file = this.selectedFiles.find(f => f.name === filename)
            if (file) {
              formData.append('file', file)
              formData.append('mimetype', file.type || 'application/octet-stream')

              // add filename and mimetype to metadata
              formMetadata.sections[0].fields.push(
                {
                  id: 'file',
                  predicate: 'ebucore:filename',
                  component: 'p-file',
                  value: filename,
                  mimetype: file.type
                }
              )

              // choose upload method
              switch (file.type) {
                case 'image/jpeg':
                case 'image/tiff':
                case 'image/gif':
                case 'image/png':
                case 'image/x-ms-bmp':
                  createmethod = 'picture'
                  break

                case 'audio/wav':
                case 'audio/mpeg':
                case 'audio/flac':
                case 'audio/ogg':
                  createmethod = 'audio'
                  break

                case 'application/pdf':
                  createmethod = 'document'
                  break

                case 'video/mpeg':
                case 'video/avi':
                case 'video/mp4':
                case 'video/quicktime':
                case 'video/x-matroska':
                  createmethod = 'video'
                  break

                default:
                  // data
                  createmethod = 'unknown'
                  break
              }
            } else {
              throw new Error(`File not found: ${filename}`)
            }
          }

          // Create metadata object
          let metadata = { 
            metadata: {
              'json-ld': jsonld.form2json(formMetadata),
              ownerid: this.user.username
            }
          }
          console.log('Final metadata:', metadata)    
          formData.append('metadata', JSON.stringify(metadata))

          const response = await this.$axios.request({
            method: 'POST',
            url: `http://localhost:8899/api/${createmethod}/create`,
            headers: {
              'Content-Type': 'multipart/form-data',
              'X-XSRF-TOKEN': this.user.token
            },
            data: formData
          })

          if (response.data.status === 200 && response.data.pid) {
            this.setUploadState({ 
              rowIndex, 
              status: 'completed', 
              pid: response.data.pid, 
              error: null 
            })
            this.setUploadProgress({
              ...this.getUploadProgress,
              completed: this.getUploadProgress.completed + 1
            })
          } else {
            throw new Error('Upload failed: No PID received')
          }
        } catch (error) {
          console.error('Upload error:', error)
          this.setUploadState({ 
            rowIndex, 
            status: 'error', 
            pid: null, 
            error: error.message || 'Unknown error occurred' 
          })
          this.setUploadProgress({
            ...this.getUploadProgress,
            failed: this.getUploadProgress.failed + 1
          })
        }
      }

      this.isUploading = false
      if (this.isUploadComplete && this.getUploadProgress.failed === 0) {
        this.completeStep(4)
      }
    },

    async retryUpload(rowIndex) {
      // Reset the state for this row
      this.setUploadState({ 
        rowIndex: rowIndex - 1, 
        status: 'pending', 
        pid: null, 
        error: null 
      })
      this.setUploadProgress({
        ...this.getUploadProgress,
        failed: this.getUploadProgress.failed - 1
      })
      
      // Start upload
      await this.startUpload()
    },

    async createFormMetadata(headers, values) {
      console.log('Creating form data with mappings:', this.fieldMappings)
      
      let form = { 
        sections: [{ 
          title: null, 
          type: "digitalobject",
          id: 1, 
          fields: [] 
        }] 
      }

      // Map fields based on fieldMappings
      for (const [field, mapping] of Object.entries(this.fieldMappings || {})) {
        if (!mapping) continue
        // Skip Filename and Subtitle fields as they're handled separately
        if (field === 'Filename' || field === 'Subtitle') continue
        
        console.log(`Processing field: ${field} with mapping:`, mapping)
        
        try {
          let value = null
          if (mapping.source === 'phaidra-field') {
            value = mapping.phaidraValue
          } else if (mapping.source === 'csv-column') {
            const columnIndex = headers.indexOf(mapping.csvValue)
            value = values[columnIndex]
          }

          const fieldConfig = this.fieldSettings[field]
          const f = fieldConfig.phaidraComponentMapping[0].getProps(value)
          
          // Handle concept properties for special fields
          if (field === 'Type') {
            this.setTypeProperties(f, value)
          }
          else if (field === 'OEFOS') {
            this.setOefosProperties(f, value)
          }
          else if (field === 'ORG Unit / Association') {
            this.setOrgUnitProperties(f, value)
          } else if (field === 'Title') {
            f.title = value
          } else if (field === 'Role') {
            this.setRoleProperties(f, mapping, headers, values)
          } else {
            if (mapping.source === 'phaidra-field') {
              f.value = fieldConfig.phaidraAPIValue
                ? fieldConfig.phaidraAPIValue(value) 
                : value
            } else if (mapping.source === 'csv-column') {
              f.value = fieldConfig.csvAPIValue 
                ? fieldConfig.csvAPIValue(value)
                : value
            }
          }

          // Set common field properties
          if (f) {
            form.sections[0].fields.push(f)
          } else {
            console.warn(`Could not create field for: ${field}`)
          }
        } catch (error) {
          console.error(`Error processing field ${field}:`, error)
          throw new Error(`Failed to process field ${field}: ${error.message}`)
        }
      }

      // Process Subtitle separately after all other fields
      const subtitleMapping = this.fieldMappings['Subtitle']
      if (subtitleMapping) {
        const subtitleValue = values[headers.indexOf(subtitleMapping.csvValue)]
        if (subtitleValue) {
          const titleField = form.sections[0].fields.find(field => field.title !== undefined)
          if (titleField) {
            titleField.subtitle = subtitleValue
          }
        }
      }

      console.log('Final form:', form)

      return form
    },

    setTypeProperties(f, value) {
      f.value = value['@id']
      f['skos:prefLabel'] = []
      Object.entries(value['skos:prefLabel']).forEach(([key, value]) => {
        f['skos:prefLabel'].push({ '@value': value, '@language': key })
      })
    },

    setOefosProperties(f, value) {
      f.value = value['@id']
      f['rdfs:label'] = []
      Object.entries(value['rdfs:label']).forEach(([key, value]) => {
        f['rdfs:label'].push({ '@value': value, '@language': key })
      })
      f['skos:prefLabel'] = []
      Object.entries(value['skos:prefLabel']).forEach(([key, value]) => {
        f['skos:prefLabel'].push({ '@value': value, '@language': key })
      })
      f['skos:notation'] = value['skos:notation']
    },

    setOrgUnitProperties(f, value) {
      f.value = value['@id']
      f.type = value['@type']
      f['skos:prefLabel'] = []
      Object.entries(value['skos:prefLabel']).forEach(([key, value]) => {
        f['skos:prefLabel'].push({ '@value': value, '@language': key })
      })
      f['skos:notation'] = value['skos:notation']
      f.parent_id = value['parent_id']
    },

    setRoleProperties(f, mapping, headers, values) {
      if (mapping.source === 'phaidra-field') {
        f.role = mapping.subFields['Role']?.phaidraValue?.['@id'] || ''
        f.name = mapping.subFields['First name']?.phaidraValue || ''
        f.lastname = mapping.subFields['Last name']?.phaidraValue || ''
        f.identifierType = mapping.subFields['Identifier Type']?.phaidraValue?.['@id'] || ''
        f.identifierText = mapping.subFields['Identifier']?.phaidraValue || ''
        f.value = f.role
      } else if (mapping.source === 'csv-column') {
        f.role = `role:${values[headers.indexOf(mapping.subFields['Role']?.csvValue)]}`
        f.name = values[headers.indexOf(mapping.subFields['First name']?.csvValue)]
        f.lastname = values[headers.indexOf(mapping.subFields['Last name']?.csvValue)]
        if (mapping.subFields['ORCID']) {
          f.identifierType = 'ids:orcid'
          f.identifierText = values[headers.indexOf(mapping.subFields['ORCID']?.csvValue)]
        } else if (mapping.subFields['GND']) {
          f.identifierType = 'ids:gnd'
          f.identifierText = values[headers.indexOf(mapping.subFields['GND']?.csvValue)]
        }
        f.value = f.role
      }
    }
  },

  created() {
    // Initialize upload progress if not already set
    if (this.getUploadProgress.total === 0) {
      const rows = this.csvContent?.split('\n') || []
      const validRows = rows.slice(1).filter(row => row && row.trim())
      this.setUploadProgress({
        total: validRows.length,
        completed: 0,
        failed: 0
      })
    }
  }
}
</script>

<style scoped>
.upload {
  max-width: 1200px;
  margin: 0 auto;
}

.position-relative {
  position: relative;
}
</style>