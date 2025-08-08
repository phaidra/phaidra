<template>
  <v-container class="csv-config">
    <BulkUploadSteps />
    <v-row>
      <v-col>
        <h1 class="text-h4">{{$t('Step 1: Load CSV File')}}</h1>
      </v-col>
    </v-row>

    <!-- File Upload Section -->
    <v-row class="mt-4">
      <v-col cols="12" md="6">
        <template v-if="savedFileName">
          <v-card outlined class="pa-4">
            <div class="d-flex align-center">
              <v-icon left color="primary">mdi-file-document-outline</v-icon>
              <span class="text-body-1">{{ savedFileName }}</span>
              <v-spacer></v-spacer>
              <v-btn
                text
                color="primary"
                @click="showFileInput = true"
              >
                {{$t('Change File')}}
              </v-btn>
            </div>
          </v-card>
          <v-expand-transition>
            <div v-show="showFileInput">
              <div class="d-flex align-center">
                <v-file-input
                  :key="fileInputKey"
                  ref="fileInput"
                  v-model="csvFile"
                  accept=".csv"
                  :label="$t('Select New CSV File')"
                  outlined
                  class="mt-4 flex-grow-1"
                  @change="handleFileUpload"
                  :error-messages="errorMessage"
                  persistent-hint
                  :clearable="false"
                ></v-file-input>
                <v-btn
                  text
                  color="grey"
                  class="mt-4 ml-2"
                  @click="showFileInput = false"
                >
                  {{$t('Cancel')}}
                </v-btn>
              </div>
            </div>
          </v-expand-transition>
        </template>
        <v-file-input
          v-else
          v-model="csvFile"
          accept=".csv"
          :label="$t('Select CSV File')"
          outlined
          @change="handleFileUpload"
          :error-messages="errorMessage"
          persistent-hint
          :clearable="false"
        ></v-file-input>
      </v-col>
    </v-row>

    <!-- Preview Section -->
    <v-row v-if="getColumnHeaders.length">
      <v-col cols="12">
        <v-card outlined class="pa-4">
          <div class="d-flex align-center mb-4">
            <h3 class="text-h6 mb-0 mr-4">
              {{$t('CSV Columns of your file:')}}
            </h3>
          </div>
          <v-chip
            v-for="column in getColumnHeaders"
            :key="column"
            class="mr-2 mb-2"
            outlined
          >
            {{ column }}
          </v-chip>
        </v-card>
      </v-col>
    </v-row>

    <!-- Add confirmation dialog when resetting csv file and user already was beyond step 1 -->
    <v-dialog v-model="showConfirmDialog" max-width="500">
      <v-card>
        <v-card-title class="text-h6 font-weight-light white--text">{{$t('Confirm New File Upload')}}</v-card-title>
        <v-card-text class="mt-4">
          {{$t('Loading a new file will clear all your existing progress. Are you sure you want to continue?')}}
        </v-card-text>
        <v-card-actions>
          <v-btn outlined @click="cancelNewFile">{{$t('Cancel')}}</v-btn>
          <v-spacer></v-spacer>
          <v-btn color="error" @click="confirmNewFile">{{$t('Confirm Progress Deletion')}}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Navigation -->
    <v-row justify="end" class="mt-4">
      <v-col cols="auto">
        <v-btn
          large
          color="primary"
          @click="$router.push('/bulk-upload/meta-data-config')"
          :disabled="!isValid"
        >
          {{$t('Next')}}
          <v-icon right>mdi-arrow-right</v-icon>
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { mapState, mapMutations, mapGetters } from 'vuex'
import BulkUploadSteps from '../../components/BulkUploadSteps.vue'

export default {
  name: 'CsvConfig',
  components: {
    BulkUploadSteps
  },
  middleware: 'bulk-upload',

  data() {
    return {
      errorMessage: '',
      showFileInput: false,
      showConfirmDialog: false,
      pendingFile: null,
      fileInputKey: 0
    }
  },

  computed: {
    ...mapState('bulk-upload', ['columns', 'fileName', 'maxStepReached']),
    ...mapGetters('bulk-upload', ['getColumnHeaders']),

    isValid() {
      return this.getColumnHeaders.length > 0
    },
    savedFileName() {
      return this.fileName
    },
    csvFile: {
      get() {
        return null
      },
      set(value) {
        if (!value) {
          this.setCsvContent(null)
          this.setFileName('')
        }
      }
    }
  },

  methods: {
    ...mapMutations('bulk-upload', [
      'setCsvContent',
      'setFileName',
      'completeStep',
      'hardResetState'
    ]),

    async handleFileUpload(file) {
      if (!file) {
        this.errorMessage = ''
        return
      }

      // Show confirmation dialog if user is beyond step 1 and hence has data & progress
      if (this.maxStepReached > 1) {
        this.pendingFile = file
        this.showConfirmDialog = true
        return
      }

      await this.uploadCsvFile(file)
    },

    cancelNewFile() {
      this.showConfirmDialog = false
      this.pendingFile = null

      this.fileInputKey++

      if (this.$refs.fileInput) {
        // temporarily remove the change listener, since with the listener, setting file to null (see below)
        // would completely remove the initial file and its data too
        const originalChangeListener = this.$refs.fileInput.$listeners.change
        this.$refs.fileInput.$off('change')
        
        // reset the file input using the native input element, this way a user can re-select the same file and get prompted again
        const nativeInput = this.$refs.fileInput.$el.querySelector('input[type="file"]')
        if (nativeInput) {
          nativeInput.value = ''
        }

        // set file selection to null
        this.$refs.fileInput.internalValue = null
        
        // restore the change listener
        this.$nextTick(() => {
          this.$refs.fileInput.$on('change', originalChangeListener)
        })
      }
    },

    async confirmNewFile() {
      this.showConfirmDialog = false

      const file = this.pendingFile
      this.pendingFile = null

      await this.uploadCsvFile(file)
    },

    // technically, this is not really an upload but more a processing the files and saving data to local storage
    // from a user perspective it feels like an upload so thought naming would fit well on the technical side too
    async uploadCsvFile(file) {
      try {
        this.hardResetState()

        const text = await this.readFile(file)

        await this.storeFileData(text, file.name)
        
        this.showFileInput = false
        this.errorMessage = ''
      } catch (error) {
        this.errorMessage = 'Error reading CSV file. Please make sure it\'s a valid CSV file.'
        console.error('Error reading CSV:', error)
      }
    },

    async readFile(file) {
      const text = await this.readFileContent(file)
      const firstLine = text.split('\n')[0]
      const columns = firstLine
        .split(';')
        .map(col => col.trim().replace(/["']/g, ''))
        .filter(col => col !== '')
      
      if (columns.length === 0) {
        throw new Error('No valid columns found in the CSV file')
      }
      
      return text
    },

    readFileContent(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader()
        reader.onload = (event) => resolve(event.target.result)
        reader.onerror = (error) => reject(error)
        reader.readAsText(file)
      })
    },

    async storeFileData(text, fileName) {
      const firstLine = text.split('\n')[0]
      const columns = firstLine
        .split(';')
        .map(col => col.trim().replace(/["']/g, ''))
        .filter(col => col !== '')
      
      this.setCsvContent(text)
      this.setFileName(fileName)
      this.completeStep(1)
    }
  }
}
</script>

<style scoped>
.csv-config {
  /* max-width: 1200px; */
  margin: 0 auto;
}
</style>