<template>
  <div :class="{ 'highlight-field': (allowedSources.length > 1 && !selectedSource && fieldSettings[field]?.required) }">
    <v-radio-group
      v-if="shouldShowRadioButtons"
      v-model="selectedSource"
      dense
      class="mt-0 p-2 source-select"
    >
      <v-radio
        value="csv-column"
        class="mt-0"
        label="CSV"
        dense
      ></v-radio>
      <v-radio
        value="phaidra-field"
        label="Phaidra"
        dense
      ></v-radio>
    </v-radio-group>
    <div v-else class="text-caption">
      {{ restrictionMessage }}
    </div>
  </div>
</template>

<script>
import { fieldSettings } from '../../config/bulk-upload/field-settings'

export default {
  name: 'SourceSelector',

  props: {
    field: {
      type: String,
      required: true
    },
    allowedSources: {
      type: Array,
      required: true
    },
    value: {
      type: String,
      default: null
    }
  },

  data() {
    return {
      fieldSettings
    }
  },

  computed: {
    selectedSource: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    },

    shouldShowRadioButtons() {
      return this.allowedSources.length > 1
    },

    restrictionMessage() {
      if (this.allowedSources[0] === 'csv-column') {
        return `can only be sourced from a CSV column`
      } else if (this.allowedSources[0] === 'phaidra-field') {
        return `can only be sourced from a default Phaidra value`
      }
      return ''
    }
  }
}
</script>

<style global>
  /* highlight the field from outside ("indirect "parent selector") */
  div.col:has(> .highlight-field) {
    background-color: #fff5e6;
    border-radius: 4px;
    position: relative;
  }
</style>

<style scoped>
.source-select :deep(.v-input--radio-group__input) {
  margin: 0;
}

</style> 