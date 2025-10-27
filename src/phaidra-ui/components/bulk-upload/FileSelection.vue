<template>
  <v-card tile>
    <v-card-text>
      <div class="d-flex align-center justify-space-between mb-4">
        <div>
          <span class="text-h6">{{$t('Files')}}</span>
        </div>
        <div class="d-flex align-center">
          <v-file-input
            :value="value"
            multiple
            chips
            show-size
            counter
            :label="$t('Select Files')"
            outlined
            dense
            class="max-w-500"
            :error-messages="error"
            @change="handleFileSelection"
          ></v-file-input>
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
    value: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      error: ''
    }
  },
  methods: {
    handleFileSelection(files) {
      this.error = ''
      if (!files || files.length === 0) {
        this.$emit('input', [])
        return
      }

      const parsed = this.parseCsvContent(this.csvContent)

      parsed.data = parsed.data.map(row => {
        if(row.length === 1 && row[0].includes(';')){
          return row[0].split(';')
        }
        return row
      })

      if (!parsed || !parsed.data || parsed.data.length < 2) {
        this.error = 'Invalid CSV data'
        this.$emit('input', [])
        return
      }

      const headers = parsed.data[0]
      const dataRows = parsed.data.slice(1)
      const filenameMapping = this.fieldMappings['Filename']
      
      if (!filenameMapping || filenameMapping.source !== 'csv-column') {
        this.error = 'No filename column mapped in CSV configuration'
        this.$emit('input', [])
        return
      }

      const filenameIndex = headers.indexOf(filenameMapping.csvValue)
      if (filenameIndex === -1) {
        this.error = 'Mapped filename column not found in CSV'
        this.$emit('input', [])
        return
      }

      const requiredFiles = new Set(
        dataRows
          .map(row => row[filenameIndex] ? row[filenameIndex].trim() : '')
          .filter(Boolean)
      )

      // Check if all required files are present
      const selectedFileNames = new Set(files.map(f => f.name).filter(Boolean))
      const missingFiles = [...requiredFiles].filter(f => !selectedFileNames.has(f))
      const extraFiles = [...selectedFileNames].filter(f => !requiredFiles.has(f))

      if (missingFiles.length > 0) {
        this.error = `Missing required files: ${missingFiles.join(', ')}`
        this.$emit('input', [])
      } else if (extraFiles.length > 0) {
        this.error = `Extra files not in CSV: ${extraFiles.join(', ')}`
        this.$emit('input', [])
      } else {
        this.$emit('input', files)
      }
    }
  }
}
</script> 