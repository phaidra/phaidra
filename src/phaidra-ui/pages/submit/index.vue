<template>
<Submit></Submit>
</template>
<script setup>
definePageMeta({
  middleware: 'auth'
})
</script>

<script>
import { config, useDocumentTitle } from "../../mixins/config";
import Submit from "../../components/Submit.vue";

export default {
  mixins: [config],
  setup() {
    const nuxtApp = useNuxtApp()
    const documentTitle = useDocumentTitle()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: documentTitle(t('Submit'))
      }
    })
  }
}
</script>