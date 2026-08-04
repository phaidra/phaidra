<template>
  <th class="text-left">
    <div class="d-flex align-center">
      {{ displayText }}
      <v-tooltip location="bottom">
        <template v-slot:activator="{ props: tipProps }">
          <v-icon
            size="x-small"
            class="ml-1"
            :class="{ 'text-medium-emphasis': !isMapped }"
            v-bind="tipProps"
          >
            mdi-information
          </v-icon>
        </template>
        {{ sourceInfo || 'Not sourced (optional)' }}
      </v-tooltip>
    </div>
  </th>
</template>

<script>
export default {
  name: 'PreviewTableHeader',
  
  props: {
    field: {
      type: String,
      required: true
    },
    subField: {
      type: String,
      default: null
    },
    isRequired: {
      type: Boolean,
      default: false
    },
    isMapped: {
      type: Boolean,
      required: true
    },
    sourceInfo: {
      type: String,
      default: null
    }
  },

  computed: {
    displayText() {
      if (this.subField) {
        return `${this.field}: ${this.subField}${this.isRequired ? '*' : ''}`
      }
      return `${this.field}${this.isRequired ? '*' : ''}`
    }
  }
}
</script> 