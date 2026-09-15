<template>
<client-only>
  <p-lists></p-lists>
</client-only>
</template>
<script setup>
definePageMeta({
  middleware: 'auth'
})
</script>

<script>
import { config, useDocumentTitle } from "../mixins/config";
export default {
  mixins: [config],
  setup() {
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
