<template>
<client-only>
  <div>
    <h1 class="d-sr-only">{{$t('Groups')}}</h1>
    <p-groups></p-groups>
  </div>
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
        title: documentTitle(t('Groups'))
      }
    })
  }
}
</script>
