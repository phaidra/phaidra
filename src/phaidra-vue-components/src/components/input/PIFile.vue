<template>
  <v-row v-if="!hidden"
    v-cloak
    @drop.prevent="addDropFile"
    @dragover.prevent
  >
    <v-col :cols="!showMimetype ? (actions.length ? 10 : 12) : (actions.length ? 6 : 8)">
      <v-file-input
        :value="value"
        :error-messages="fileErrorMessages"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        :background-color="backgroundColor ? backgroundColor : undefined"
        show-size
        :hint="$t('You can use drag & drop')"
        persistent-hint
        @change="fileInput($event)"
        :label="$t(label)"
        :prepend-icon="''"
        :append-icon="'mdi-paperclip'"
        :disabled="disabled"
        :class="fileInputClass"
      ></v-file-input>
    </v-col>
    <v-col v-if="showMimetype" cols="4">
      <v-autocomplete
        :value="getTerm('mimetypes', mimetype)"
        v-on:input="$emit('input-mimetype', $event)"
        :background-color="backgroundColor ? backgroundColor : undefined"
        :items="vocabularies['mimetypes'].terms"
        :item-value="'@id'"
        :loading="loading"
        :filter="autocompleteFilter"
        hide-no-data
        :label="$t(mimeLabel)"
        :filled="inputStyle==='filled'"
        :outlined="inputStyle==='outlined'"
        return-object
        clearable
        :disabled="disabled"
        :error-messages="mimetypeErrorMessages"
      >
        <template slot="item" slot-scope="{ item }">
          <v-list-item-content two-line>
            <v-list-item-title  v-html="`${getLocalizedTermLabel('mimetypes', item['@id'])}`"></v-list-item-title>
            <v-list-item-subtitle v-if="showIds" v-html="`${item['@id']}`"></v-list-item-subtitle>
          </v-list-item-content>
        </template>
        <template slot="selection" slot-scope="{ item }">
          <v-list-item-content>
            <v-list-item-title v-html="`${getLocalizedTermLabel('mimetypes', item['@id'])}`"></v-list-item-title>
          </v-list-item-content>
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ on, attrs }">
          <v-btn v-on="on" v-bind="attrs" icon>
            <v-icon>mdi-dots-vertical</v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item v-for="(action, i) in actions" :key="i" @click="$emit(action.event, $event)">
            <v-list-item-title>{{ action.title }}</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-col>
    <v-dialog v-model="dialog" width="500">
      <v-card>
        <v-card-text class="pa-4">{{ $t('Please select only one file.') }}</v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="dialog = false" >Ok</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-row>
</template>

<script>
import { vocabulary } from '../../mixins/vocabulary'
import { fieldproperties } from '../../mixins/fieldproperties'

export default {
  name: 'p-i-file',
  mixins: [vocabulary, fieldproperties],
  props: {
    label: {
      type: String,
      required: true
    },
    mimeLabel: {
      type: String,
      required: true
    },
    mimetype: {
      type: String,
      required: true
    },
    autoMimetype: {
      type: Boolean,
      default: false
    },
    showMimetype: {
      type: Boolean,
      default: true
    },
    fileErrorMessages: {
      type: Array
    },
    mimetypeErrorMessages: {
      type: Array
    },
    showIds: {
      type: Boolean,
      default: false
    },
    disabled: {
      type: Boolean
    },
    fileInputClass: {
      type: String,
      default: ''
    }
  },
  data () {
    return {
      dialog: false,
      loading: false,
      value: null
    }
  },
  methods: {
    addDropFile (e) {
      if (e.dataTransfer.files.length > 1) {
        this.dialog = true
        return
      }
      this.value = e.dataTransfer.files[0]
      this.fileInput(e.dataTransfer.files[0])
    },
    fileInput (file) {
      if (file) {
        this.$emit('input-file', file)
        if (this.autoMimetype) {
          if (file.name) {
            let ext = file.name.split('.').pop()
            for (let mt of this.vocabularies['mimetypes'].terms) {
              for (let notation of mt['skos:notation']) {
                if (ext === notation) {
                  this.$emit('input-mimetype', mt)
                }
              }
            }
          }
        }
      }
    }
  }
}
</script>
