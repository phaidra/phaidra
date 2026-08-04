<template>
  <div>
    <h1 class="d-sr-only">{{$t('Code of Ethics')}}</h1>
    <ExtCodeOfEthics></ExtCodeOfEthics>
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
          title: documentTitle(t('Code of Ethics'))
        }
      })
    }
  }
  </script>
  