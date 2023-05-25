export const displayproperties = {
  props: {
    labelColMd: {
      type: String,
      default: '2'
    },
    valueColMd: {
      type: String,
      default: '10'
    },
    showLang: {
      type: Boolean,
      default: true
    },
    boldLabelFields: {
      type: Array,
      default: () => ([])
    }
  }
}
