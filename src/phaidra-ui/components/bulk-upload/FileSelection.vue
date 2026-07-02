<template>
  <v-card tile>
    <v-card-text>
      <div class="d-flex align-center justify-space-between mb-4">
        <div>
          <span class="text-h6">{{$t('Files')}}</span>
        </div>
        <div class="file-input-wrapper">
          <v-file-input
            :model-value="modelValue"
            multiple
            chips
            show-size
            counter
            :label="$t('Select Files')"
            :placeholder="$t('Select Files')"
            variant="outlined"
            density="comfortable"
            class="file-input-field"
            :hide-details="!error && !modelValue.length"
            :error-messages="error"
            @update:model-value="handleFileSelection"
          />
        </div>
      </div>
    </v-card-text>
  </v-card>
</template>

<script>
import { csvParser } from '../../mixins/csvParser'

export default {
  name: 'FileSelection',
  mixins: [csvParser],
  props: {
    csvContent: {
      type: String,
      required: true
    },
    fieldMappings: {
      type: Object,
      required: true
    },
    modelValue: {
      type: Array,
      default: () => []
    }
  },
  emits: ['update:modelValue'],
  data() {
    return {
      error: ''
    }
  },
  methods: {
    handleFileSelection(files) {
      this.error = ''
      if (!files || files.length === 0) {
        this.$emit('update:modelValue', [])
        return
      }

      const parsed = this.parseCsvContent(this.csvContent)

      if (!parsed || !parsed.data || parsed.data.length < 2) {
        this.error = 'Invalid CSV data'
        this.$emit('update:modelValue', [])
        return
      }

      const headers = parsed.data[0]
      const dataRows = parsed.data.slice(1)
      const filenameMapping = this.fieldMappings['Filename']

      if (!filenameMapping || filenameMapping.source !== 'csv-column') {
        this.error = 'No filename column mapped in CSV configuration'
        this.$emit('update:modelValue', [])
        return
      }

      const filenameIndex = headers.indexOf(filenameMapping.csvValue)
      if (filenameIndex === -1) {
        this.error = 'Mapped filename column not found in CSV'
        this.$emit('update:modelValue', [])
        return
      }

      const requiredFiles = new Set(
        dataRows
          .map(row => row[filenameIndex] ? row[filenameIndex].trim() : '')
          .filter(Boolean)
      )

      const selectedFileNames = new Set(files.map(f => f.name).filter(Boolean))
      const missingFiles = [...requiredFiles].filter(f => !selectedFileNames.has(f))
      const extraFiles = [...selectedFileNames].filter(f => !requiredFiles.has(f))

      if (missingFiles.length > 0) {
        this.error = `Missing required files: ${missingFiles.join(', ')}`
        this.$emit('update:modelValue', [])
      } else if (extraFiles.length > 0) {
        this.error = `Extra files not in CSV: ${extraFiles.join(', ')}`
        this.$emit('update:modelValue', [])
      } else {
        this.$emit('update:modelValue', files)
      }
    }
  }
}
</script>

<style scoped>
.file-input-wrapper {
  flex: 0 0 500px;
  min-width: 500px;
  max-width: 500px;
}

.file-input-field {
  width: 100%;
}

/* Keep the selection area wide enough for the placeholder when empty */
.file-input-field :deep(.v-field__input) {
  min-width: 0;
  flex-wrap: wrap;
}
</style>
