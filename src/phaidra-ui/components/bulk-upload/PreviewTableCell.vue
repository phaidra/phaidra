<template>
  <td :class="{ 'grey--text': !isMapped }">
    {{ displayValue || '-' }}
  </td>
</template>

<script>
export default {
  name: 'PreviewTableCell',
  
  props: {
    field: {
      type: String,
      required: true
    },
    subField: {
      type: String,
      default: null
    },
    rowData: {
      type: Object,
      required: true
    },
    isMapped: {
      type: Boolean,
      required: true
    }
  },

  computed: {
    displayValue() {
      if (this.subField) {
        return this.rowData[this.field]?.[this.subField]
      }
      return this.rowData[this.field]
    }
  }
}
</script> 