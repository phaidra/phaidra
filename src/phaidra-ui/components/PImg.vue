<template>
  <v-img
    :src="src"
    :alt="alt"
    :class="$attrs.class"
    v-bind="passthroughAttrs"
  >
    <template #placeholder>
      <slot name="placeholder" />
    </template>
    <template #default>
      <slot />
    </template>
  </v-img>
</template>

<script>
export default {
  name: 'PImg',
  inheritAttrs: false,
  props: {
    src: {
      type: String,
      default: ''
    },
    alt: {
      type: String,
      default: ''
    }
  },
  computed: {
    passthroughAttrs () {
      const attrs = { ...this.$attrs }
      delete attrs.class
      return attrs
    }
  }
}
</script>

