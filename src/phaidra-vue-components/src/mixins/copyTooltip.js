export default {
  data () {
    return {
      copiedTooltipKey: null,
      copyTooltipResetTimer: null
    }
  },
  methods: {
    getCopyTooltipText (tooltipKey) {
      return this.copiedTooltipKey === tooltipKey ? 'Copied' : 'Copy to clipboard'
    },
    resetCopyTooltip () {
      this.copiedTooltipKey = null
      if (this.copyTooltipResetTimer) {
        clearTimeout(this.copyTooltipResetTimer)
        this.copyTooltipResetTimer = null
      }
    },
    copyWithTooltip (value, tooltipKey) {
      navigator.clipboard.writeText(value)
      this.copiedTooltipKey = tooltipKey
      if (this.copyTooltipResetTimer) {
        clearTimeout(this.copyTooltipResetTimer)
      }
      this.copyTooltipResetTimer = setTimeout(() => {
        this.copiedTooltipKey = null
        this.copyTooltipResetTimer = null
      }, 1500)
    }
  }
}

