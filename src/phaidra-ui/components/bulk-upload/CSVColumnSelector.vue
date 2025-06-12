<template>
  <div>
    <v-select
      v-model="selectedColumn"
      :items="availableColumns"
      outlined
      dense
      clearable
      :label="'Select CSV column'"
      hide-details
      class="flex-grow-0 mr-8"
      style="width: 200px"
      :disabled="disabled"
      :class="{ 'grey-input': disabled }"
    ></v-select>
  </div>
</template>

<script>
export default {
  name: 'CSVColumnSelector',

  props: {
    field: {
      type: String,
      required: true
    },
    columns: {
      type: Array,
      required: true
    },
    value: {
      type: String,
      default: null
    },
    disabled: {
      type: Boolean,
      default: false
    },
    allMappings: {
      type: Object,
      required: true
    }
  },

  computed: {
    selectedColumn: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    },

    availableColumns() {
      const selectedValues = new Set()
      
      // Collect all used CSV column values except the current one
      Object.values(this.allMappings).forEach(mapping => {
        if (mapping.subFields) {
          // For multi-field mappings, collect all subfield values
          Object.values(mapping.subFields).forEach(subMapping => {
            if (subMapping?.csvValue) {
              selectedValues.add(subMapping.csvValue)
            }
          })
        } else if (mapping.csvValue) {
          // For single-field mappings, collect the value
          selectedValues.add(mapping.csvValue)
        }
      })

      // Always make the current value available
      if (this.value) {
        selectedValues.delete(this.value)
      }
      
      // Return available columns sorted alphabetically
      return this.columns
        .filter(col => !selectedValues.has(col))
        .sort((a, b) => a.localeCompare(b))
    }
  }
}
</script>

<style scoped>
.grey-input :deep(.v-input__slot) {
  background-color: #f5f5f5 !important;
}
</style> 