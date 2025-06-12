<template>
  <v-container class="preview">
    <BulkUploadSteps />
    <v-row>
      <v-col>
        <h1 class="text-h4">Step 3: Data Preview</h1>
      </v-col>
    </v-row>

    <template v-if="isInitialized">
      <v-row>
        <v-col>
          <v-card outlined>
            <v-card-text class="table-container">
              <v-simple-table fixed-header>
                <template v-slot:default>
                  <thead>
                    <tr>
                      <template v-for="field in allFields">
                        <template v-if="isMultiField(field)">
                          <PreviewTableHeader
                            v-for="(subFieldConfig, subField) in getSubFields(field)"
                            :key="field + '-' + subField"
                            :field="field"
                            :sub-field="subField"
                            :is-required="subFieldConfig.required"
                            :is-mapped="!!getSourceInfo(field, subField)"
                            :source-info="getSourceInfo(field, subField)"
                          />
                        </template>
                        <PreviewTableHeader
                          v-else
                          :key="field"
                          :field="field"
                          :is-required="fieldSettings[field].required"
                          :is-mapped="!!getAllFieldMappings[field]"
                          :source-info="getSourceInfo(field)"
                        />
                      </template>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(row, index) in previewData" :key="index">
                      <template v-for="field in allFields">
                        <template v-if="isMultiField(field)">
                          <PreviewTableCell
                            v-for="(subFieldConfig, subField) in getSubFields(field)"
                            :key="field + '-' + subField"
                            :field="field"
                            :sub-field="subField"
                            :row-data="row"
                            :is-mapped="!!getSourceInfo(field, subField)"
                          />
                        </template>
                        <PreviewTableCell
                          v-else
                          :key="field"
                          :field="field"
                          :row-data="row"
                          :is-mapped="!!getAllFieldMappings[field]"
                        />
                      </template>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Navigation -->
      <v-row justify="space-between" class="mt-4">
        <v-col cols="auto">
          <v-btn
            text
            :to="steps[2].route"
          >
            <v-icon left>mdi-arrow-left</v-icon>
            Back
          </v-btn>
        </v-col>
        <v-col cols="auto">
          <v-btn
            color="primary"
            @click="proceed"
            :to="steps[4].route"
          >
            Next 
            <v-icon right>mdi-arrow-right</v-icon>
          </v-btn>
        </v-col>
      </v-row>
    </template>
  </v-container>
</template>

<script>
import { mapState, mapGetters, mapMutations } from 'vuex'
import BulkUploadSteps from '../../components/BulkUploadSteps.vue'
import PreviewTableHeader from '../../components/bulk-upload/PreviewTableHeader.vue'
import PreviewTableCell from '../../components/bulk-upload/PreviewTableCell.vue'
import { fieldSettings } from '../../config/bulk-upload/field-settings'

export default {
  name: 'Preview',
  
  components: {
    BulkUploadSteps,
    PreviewTableHeader,
    PreviewTableCell
  },

  middleware: 'bulk-upload',

  data() {
    return {
      fieldSettings,
      previewData: [],
      isInitialized: false
    }
  },

  computed: {
    ...mapState('bulk-upload', ['steps', 'csvContent']),
    ...mapGetters('bulk-upload', ['getAllFieldMappings', 'allFields', 'getColumnHeaders'])
  },

  watch: {
    '$i18n.locale': {
      handler: async function() {
        await this.processPreviewData()
      }
    }
  },

  async created() {
    // Wait for store initialization on client side
    if (process.client && this.$store.$initBulkUpload) {
      await this.$store.$initBulkUpload()
    }
    
    await this.processPreviewData()
    this.isInitialized = true
  },

  methods: {
    ...mapMutations('bulk-upload', ['completeStep', 'setCurrentStep']),

    isMultiField(field) {
      return fieldSettings[field]?.fieldType === 'multi-field'
    },

    getSubFields(field) {
      const fields = fieldSettings[field]?.multiFieldConfig?.fields || {}
      return Object.fromEntries(
        Object.entries(fields).filter(([_, config]) => !config.hideInPreview)
      )
    },

    async processPreviewData() {
      if (!this.csvContent) return

      const rows = this.csvContent.split('\n')
      const headers = this.getColumnHeaders

      const previewRows = rows.slice(1).map(row => {
        const values = this.parseCsvRow(row)
        const rowData = {}
        
        this.allFields.forEach(field => {
          const mapping = this.getAllFieldMappings[field]
          if (!mapping) {
            rowData[field] = ''
            return
          }

          if (this.isMultiField(field)) {
            rowData[field] = {}
            Object.keys(this.getSubFields(field)).forEach(subField => {
              const subFieldConfig = fieldSettings[field].multiFieldConfig.fields[subField]
              if (mapping.source === 'phaidra-field') {
                rowData[field][subField] = subFieldConfig.phaidraDisplayValue(mapping.subFields[subField]?.phaidraValue)
              } else if (mapping.source === 'csv-column') {
                const columnName = mapping.subFields[subField]?.csvValue
                const value = values[headers.indexOf(columnName)]
                rowData[field][subField] = subFieldConfig.csvDisplayValue?.(value, mapping.subFields, values, headers) || value
              }
            })
          } else {
            if (mapping.source === 'phaidra-field') {
              rowData[field] = fieldSettings[field].phaidraDisplayValue(mapping.phaidraValue)
            } else if (mapping.source === 'csv-column') {
              rowData[field] = fieldSettings[field].csvDisplayValue(values[headers.indexOf(mapping.csvValue)])
            }
          }
        })
        
        return rowData
      })

      this.previewData = previewRows
    },

    parseCsvRow(row) {
      return row.split(';').map(v => v.trim().replace(/["']/g, ''))
    },

    getSourceInfo(field, subField = null) {
      const fieldMapping = this.getAllFieldMappings[field]
      if (!fieldMapping) return null

      const mapping = subField ? fieldMapping.subFields?.[subField] : fieldMapping

      // csv source by default is simply the selected column
      // 
      // BUT:
      // for the role#identifier and role#identifierType fields
      // the source is inferred from either the CSV field ORCID or GND (these can only be selected via CSV)
      // 
      // so if the user selects ORDIC/GND and a column from their CSV, we need to infer:
      // identifierType = ORCID / GND
      // identifier = column value
      // 
      // all other fields simply grab the mapping.csvValue as the csvSource

      let csvSource = null
      const orcidSubField = fieldMapping.subFields?.['ORCID']
      const gndSubField = fieldMapping.subFields?.['GND']

      if (subField === 'Identifier') {
        if (orcidSubField?.csvValue) {
          csvSource = orcidSubField.csvValue
        }
        else if (gndSubField?.csvValue) {
          csvSource = gndSubField.csvValue
        }
      } else if (subField === 'Identifier Type') {
        csvSource = orcidSubField?.csvValue || gndSubField?.csvValue ? "selection" : null
      } else {
        csvSource = mapping.csvValue
      }

      if (csvSource && subField !== 'Identifier Type') {
        csvSource = `column "${csvSource}"`
      }

      return fieldMapping.source === 'csv-column'
        ? csvSource ? `Sourced from CSV ${csvSource}` : null
        : mapping?.phaidraValue ? 'Default value sourced from Phaidra' : null
    },

    proceed() {
      this.completeStep(3)
      this.setCurrentStep(4)
      this.$router.push(this.steps[4].route)
    }
  }
}
</script>

<style scoped>
.preview {
  max-width: 1200px;
  margin: 0 auto;
}

.table-container {
  max-height: 452px;
  overflow-y: auto;
}
</style>