<template>
<Submit></Submit>
</template>
<script>
import { config, useDocumentTitle } from "../../mixins/config";
import Submit from "../../components/Submit.vue";

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
        title: documentTitle(t('Submit'))
      }
    })
  }
}
</script>