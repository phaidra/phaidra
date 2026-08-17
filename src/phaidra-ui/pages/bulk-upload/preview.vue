<template>
  <v-container class="preview">
    <BulkUploadSteps />
    <v-row>
      <v-col>
        <h1 class="text-h4">{{$t('Step 3: Data Preview')}}</h1>
      </v-col>
    </v-row>

      <v-row v-if="isInitialized">
        <v-col>
          <v-card variant="outlined">
            <v-card-text class="table-container">
              <v-table fixed-header>
                <thead>
                  <tr>
                    <template v-for="field in allFields" :key="field">
                      <template v-if="isMultiField(field)">
                        <PreviewTableHeader
                          v-for="(subFieldConfig, subField) in getSubFields(field)"
                          :key="field + '-' + subField"
                          :field="$t(field)"
                          :sub-field="subField"
                          :is-required="subFieldConfig.required"
                          :is-mapped="!!getSourceInfo(field, subField)"
                          :source-info="getSourceInfo(field, subField)"
                        />
                      </template>
                      <PreviewTableHeader
                        v-else
                        :key="field"
                        :field="$t(field)"
                        :is-required="fieldSettings[field].required"
                        :is-mapped="!!fieldMappings[field]"
                        :source-info="getSourceInfo(field)"
                      />
                    </template>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, index) in previewData" :key="index">
                    <template v-for="field in allFields" :key="field">
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
                        :is-mapped="!!fieldMappings[field]"
                      />
                    </template>
                  </tr>
                </tbody>
              </v-table>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

    <v-row v-if="isInitialized || isError" justify="space-between" class="mt-4">
      <v-col cols="auto">
        <v-btn variant="text" :to="steps[2].route" prepend-icon="mdi-arrow-left">
          {{ $t('Back') }}
        </v-btn>
      </v-col>
      <v-col cols="auto">
        <v-btn
          :disabled="isError"
          color="primary"
          :to="steps[4].route"
          append-icon="mdi-arrow-right"
          @click="proceed"
        >
          {{ $t('Next') }}
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { useBulkUploadStore } from '~/stores/bulk-upload'
import { computed, onMounted, ref, watch } from 'vue'
import { useNuxtApp } from '#app'
import BulkUploadSteps from '../../components/BulkUploadSteps.vue'
import PreviewTableHeader from '../../components/bulk-upload/PreviewTableHeader.vue'
import PreviewTableCell from '../../components/bulk-upload/PreviewTableCell.vue'
import { fieldSettings } from '../../config/bulk-upload/field-settings'
import { parseCsv } from '../../mixins/csvParser'

definePageMeta({
  middleware: 'bulk-upload'
})

const { $i18n: i18n, $router: router, $initBulkUpload } = useNuxtApp()

const previewData = ref([])
const isInitialized = ref(false)
const isError = ref(false)

const steps = computed(() => useBulkUploadStore()?.steps ?? {})
const csvContent = computed(() => useBulkUploadStore()?.csvContent ?? null)
const fieldMappings = computed(() => useBulkUploadStore().getAllFieldMappings)
const allFields = computed(() => useBulkUploadStore().allFields)

onMounted(async () => {
  if ($initBulkUpload) {
    await $initBulkUpload()
  }
  try {
    processPreviewData()
    isInitialized.value = true
  } catch (error) {
    console.error('[bulk-upload preview] Failed to process preview data:', error)
    isError.value = true
  }
})

watch(() => i18n.locale, () => {
  if (csvContent.value) processPreviewData()
})

function isMultiField(field) {
  return fieldSettings[field]?.fieldType === 'multi-field'
}

function getSubFields(field) {
  const fields = fieldSettings[field]?.multiFieldConfig?.fields || {}
  return Object.fromEntries(
    Object.entries(fields).filter(([_, config]) => !config.hideInPreview)
  )
}

function processPreviewData() {
  const _locale = i18n.locale

  if (!csvContent.value) return

  const parsed = parseCsv(csvContent.value)
  if (!parsed?.data || parsed.data.length < 2) return

  const headers = parsed.data[0]
  const dataRows = parsed.data.slice(1)

  previewData.value = dataRows.map(values => {
    const rowData = {}

    allFields.value.forEach(field => {
      const mapping = fieldMappings.value[field]
      if (!mapping) {
        rowData[field] = ''
        return
      }

      if (isMultiField(field)) {
        rowData[field] = {}
        Object.keys(getSubFields(field)).forEach(subField => {
          const subFieldConfig = fieldSettings[field].multiFieldConfig.fields[subField]
          if (mapping.source === 'phaidra-field') {
            rowData[field][subField] = subFieldConfig.phaidraDisplayValue(mapping.subFields[subField]?.phaidraValue)
          } else if (mapping.source === 'csv-column') {
            const columnName = mapping.subFields[subField]?.csvValue
            const value = values[headers.indexOf(columnName)]
            rowData[field][subField] = subFieldConfig.csvDisplayValue?.(value, mapping.subFields, values, headers) || value
          }
        })
      } else if (mapping.source === 'phaidra-field') {
        rowData[field] = fieldSettings[field].phaidraDisplayValue(mapping.phaidraValue)
      } else if (mapping.source === 'csv-column') {
        rowData[field] = fieldSettings[field].csvDisplayValue(values[headers.indexOf(mapping.csvValue)])
      }
    })

    return rowData
  })
}

function getSourceInfo(field, subField = null) {
  const fieldMapping = fieldMappings.value[field]
  if (!fieldMapping) return null

  const mapping = subField ? fieldMapping.subFields?.[subField] : fieldMapping

  let csvSource = null
  const orcidSubField = fieldMapping.subFields?.['ORCID']
  const gndSubField = fieldMapping.subFields?.['GND']

  if (subField === 'Identifier') {
    if (orcidSubField?.csvValue) csvSource = orcidSubField.csvValue
    else if (gndSubField?.csvValue) csvSource = gndSubField.csvValue
  } else if (subField === 'Identifier Type') {
    csvSource = orcidSubField?.csvValue || gndSubField?.csvValue ? 'selection' : null
  } else {
    csvSource = mapping.csvValue
  }

  if (csvSource && subField !== 'Identifier Type') {
    csvSource = `column "${csvSource}"`
  }

  return fieldMapping.source === 'csv-column'
    ? csvSource ? `Sourced from CSV ${csvSource}` : null
    : mapping?.phaidraValue ? 'Default value sourced from Phaidra' : null
}

function proceed() {
  useBulkUploadStore().completeStep(3)
  useBulkUploadStore().setCurrentStep(4)
  router.push(steps.value[4].route)
}
</script>

<style scoped>
.preview {
  /* max-width: 1200px; */
  margin: 0 auto;
}

.table-container {
  max-height: 452px;
  overflow-y: auto;
}
</style>
