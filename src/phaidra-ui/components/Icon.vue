<template>
  <span
    v-if="iconDef"
    class="p-icon"
    :class="[{ 'p-icon--left': left }, $attrs.class]"
    :style="wrapperStyle"
    aria-hidden="true"
  >
    <svg
      :viewBox="iconDef.viewBox"
      :width="computedWidth"
      :height="computedHeight"
      :style="{ display: 'block' }"
      v-html="iconDef.data"
    />
  </span>
  <span v-else class="p-icon p-icon--fallback" aria-hidden="true">?</span>
</template>

<script>
import { ICONS } from '~/icons/registry'

export default {
  name: 'Icon',
  inheritAttrs: false,
  props: {
    name: {
      type: String,
      required: true
    },
    color: {
      type: String,
      default: undefined
    },
    width: {
      type: [String, Number],
      default: undefined
    },
    height: {
      type: [String, Number],
      default: undefined
    },
    left: {
      type: Boolean,
      default: false
    },
    dark: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    iconDef () {
      return ICONS[this.name]
    },
    computedWidth () {
      if (this.width != null) return this.width
      return this.iconDef?.width || 16
    },
    computedHeight () {
      if (this.height != null) return this.height
      return this.iconDef?.height || 16
    },
    wrapperStyle () {
      return {
        display: 'inline-block',
        width: this.computedWidth + 'px',
        height: this.computedHeight + 'px',
        // Inherit surrounding text/link color by default; explicit prop still wins.
        fill: this.color || 'currentColor'
      }
    }
  }
}
</script>

<style scoped>
.p-icon {
  vertical-align: middle;
}
.p-icon--left {
  margin-right: 4px;
}
.p-icon--fallback {
  font-size: 0.75rem;
  opacity: 0.6;
}
</style>


