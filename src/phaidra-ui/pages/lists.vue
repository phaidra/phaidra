<template>
<client-only>
  <p-lists></p-lists>
</client-only>
</template>
<script>
import { config } from "../mixins/config";
export default {
  middleware: "auth",
  mixins: [config],
  setup() {
    const nuxtApp = useNuxtApp()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: this.documentTitle(t('Manage object lists'))
      }
    })
  }
}
</script>
