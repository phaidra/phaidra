<template>
    <div>
      <h1 class="d-sr-only">{{$t('File Formats')}}</h1>
      <ExtFileFormats></ExtFileFormats>
    </div>
  </template>
    
    <script>
    import { config } from "../mixins/config";
    
    export default {
      mixins: [config],
      setup() {
        const nuxtApp = useNuxtApp()
        useHead(() => {
          const t = nuxtApp.$i18n?.t || ((v) => v)
          return {
            title: this.documentTitle(t('File Formats'))
          }
        })
      }
    }
    </script>
    