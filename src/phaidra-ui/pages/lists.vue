<template>
<client-only>
  <p-lists></p-lists>
</client-only>
</template>
<script>
import { config, useDocumentTitle } from "../mixins/config";
export default {
  mixins: [config],
  setup() {
    definePageMeta({
      middleware: 'auth'
    })
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: documentTitle(t('Manage object lists'))
      }
    })
  }
}
</script>
