<template>
  <v-row v-if="!hidden"
    v-cloak
    @drop.prevent="addDropFile"
    @dragover.prevent
  >
    <v-col :cols="!showMimetype ? (actions.length ? 10 : 12) : (actions.length ? 6 : 8)">
      <v-file-input
        v-model="value"
        :error-messages="fileErrorMessages"
        :variant="fieldVariant"
        :bg-color="backgroundColor ? backgroundColor : undefined"
        show-size
        :hint="$t('You can use drag & drop')"
        persistent-hint
        @update:model-value="onFileModelUpdate"
        :label="$t(label)"
        prepend-icon=""
        append-inner-icon="mdi-paperclip"
        :disabled="disabled"
        :class="fileInputClass"
      ></v-file-input>
    </v-col>
    <v-col v-if="showMimetype" cols="4">
      <v-autocomplete
        :model-value="getTerm('mimetypes', mimetype)"
        @update:model-value="$emit('input-mimetype', $event)"
        :bg-color="backgroundColor ? backgroundColor : undefined"
        :items="vocabularies['mimetypes'].terms"
        item-value="@id"
        :item-title="mimeItemTitle"
        :custom-filter="vocabAutocompleteFilter"
        :loading="loading"
        hide-no-data
        :label="$t(mimeLabel)"
        :variant="fieldVariant"
        return-object
        clearable
        :disabled="disabled"
        :error-messages="mimetypeErrorMessages"
      >
        <template #item="{ props, item }">
          <v-list-item
            v-bind="props"
            :lines="showIds ? 'two' : 'one'"
          >
            <template #title>
              <span v-html="getLocalizedTermLabel('mimetypes', item.raw['@id'])" />
            </template>
            <template v-if="showIds" #subtitle>
              <span v-html="item.raw['@id']" />
            </template>
          </v-list-item>
        </template>
        <template #selection="{ item }">
          <span v-html="getLocalizedTermLabel('mimetypes', (item.raw || item)['@id'])" />
        </template>
      </v-autocomplete>
    </v-col>
    <v-col cols="1" v-if="actions.length">
      <v-menu open-on-hover bottom offset-y>
        <template v-slot:activator="{ props: activatorProps }">
          <v-btn v-bind="activatorProps" icon variant="text">
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
  emits: ['input-file', 'input-mimetype', 'add', 'remove', 'configure'],
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
    },
    required: {
      type: Boolean
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
    mimeItemTitle (item) {
      if (!item || !item['@id']) return ''
      return this.getLocalizedTermLabel('mimetypes', item['@id'])
    },
    addDropFile (e) {
      if (e.dataTransfer.files.length > 1) {
        this.dialog = true
        return
      }
      const file = e.dataTransfer.files[0]
      this.value = file
      this.emitFileSelection(file)
    },
    onFileModelUpdate (val) {
      this.value = val
      const file = Array.isArray(val) ? val[0] : val
      this.emitFileSelection(file || null)
    },
    emitFileSelection (file) {
      if (!file) {
        this.$emit('input-file', null)
        return
      }
      if (!(file instanceof File)) {
        return
      }
      this.$emit('input-file', file)
      if ((this.autoMimetype || file.name.endsWith('.glb')) && file.name) {
        const ext = file.name.split('.').pop()
        for (const mt of this.vocabularies['mimetypes'].terms) {
          for (const notation of mt['skos:notation']) {
            if (ext === notation) {
              this.$emit('input-mimetype', mt)
            }
          }
        }
      }
    }
  }
}
</script>
