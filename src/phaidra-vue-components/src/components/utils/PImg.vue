<template>
  <VImg v-bind="$attrs" @error="onError">
    <slot />
    <template v-if="$slots.placeholder" #placeholder>
      <slot name="placeholder" />
    </template>
  </VImg>
</template>

<script>
import { VImg } from 'vuetify/components'

export default {
  name: 'p-img',
  components: { VImg },
  inheritAttrs: false,
  methods: {
    onError () {
      // Declutter console when thumbnails fail (e.g. offline sandbox).
    }
  }
}
</script>
