<template>
  <svg
    v-if="iconDef"
    xmlns="http://www.w3.org/2000/svg"
    :viewBox="iconDef.viewBox"
    :width="normalizedWidth"
    :height="normalizedHeight"
    :class="$attrs.class"
    :style="{ color }"
    role="img"
    aria-hidden="true"
    v-html="iconDef.data"
  />
</template>

<script>
import { computed } from 'vue'
import { getIcon } from './iconRegistry'

export default {
  name: 'icon',
  inheritAttrs: false,
  props: {
    name: {
      type: String,
      required: true
    },
    width: {
      type: [String, Number],
      default: null
    },
    height: {
      type: [String, Number],
      default: null
    },
    color: {
      type: String,
      default: 'currentColor'
    }
  },
  setup (props) {
    const iconDef = computed(() => getIcon(props.name))
    const normalizedWidth = computed(() => props.width || iconDef.value?.width || 16)
    const normalizedHeight = computed(() => props.height || iconDef.value?.height || 16)
    return { iconDef, normalizedWidth, normalizedHeight }
  }
}
</script>

