<template>
  <div>
    <h1 class="d-sr-only">{{$t('Credits')}}</h1>
    <Credits></Credits>
  </div>
</template>

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
        title: documentTitle(t('Credits'))
      }
    })
  }
}
</script>
