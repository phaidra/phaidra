<template>
  <div class="d-flex align-center">
    <component
      :is="phaidraComponent"
      v-bind="phaidraProps"
      class="flex-grow-1"
      @input="handleInput"
      @change="handleInput"
      @resolve="handleInput"
      @input-role="value => handleInput(value, 'Role')"
      @input-firstname="value => handleInput(value, 'First name')"
      @input-lastname="value => handleInput(value, 'Last name')"
      @input-identifier="value => handleInput(value, 'Identifier')"
      @input-identifier-type="value => handleInput(value, 'Identifier Type')"
      :disabled="disabled"
      :class="{ 'grey-input': disabled }"
    ></component>
  </div>
</template>

<script>
import { fieldSettings } from '../../config/bulk-upload/field-settings'

export default {
  name: 'PhaidraFieldSelector',

  props: {
    field: {
      type: String,
      required: true
    },
    value: {
      type: [String, Object],
      default: null
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },

  computed: {
    getAllowedSources() {
      return fieldSettings[this.field]?.allowedSources || ['csv-column', 'phaidra-field']
    },

    phaidraComponent() {
      const elementConfig = fieldSettings[this.field]?.phaidraComponentMapping?.[0]
      if (!elementConfig) return 'v-text-field'
      return elementConfig.component || 'v-text-field'
    },

    phaidraProps() {
      const elementConfig = fieldSettings[this.field]?.phaidraComponentMapping?.[0]
      if (!elementConfig) return {}

      const fieldValue = fieldSettings[this.field]?.phaidraFieldValue?.(this.value)

      if (fieldSettings[this.field]?.fieldType === 'multi-field') {
        const props = elementConfig.getProps(null, this.handleInput)
        return {
          ...props,
          ...fieldValue
        }
      } else {
        return elementConfig.getProps(
          fieldValue,
          this.handleInput
        )
      }
    }
  },

  methods: {
    handleInput(value, subField = null) {
      this.$emit('input', {
        value,
        subField
      })
    }
  }
}
</script>

<style scoped>
.grey-input :deep(.v-input__slot) {
  background-color: #f5f5f5 !important;
}
</style> 