<template>
  <v-card tile>
    <v-card-text>
      <div class="d-flex align-center justify-space-between mb-4">
        <div>
          <span class="text-h6">Files</span>
        </div>
        <div class="d-flex align-center">
          <v-file-input
            :value="value"
            multiple
            chips
            show-size
            counter
            label="Select Files"
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
export default {
  name: 'FileSelection',
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

      // Get all required filenames from CSV
      const rows = this.csvContent.split('\n')
      const headers = rows[0].split(';').map(h => h.trim()).filter(Boolean)
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
        rows.slice(1)
          .filter(row => row && row.trim()) // Skip empty rows
          .map(row => row.split(';')[filenameIndex].trim())
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