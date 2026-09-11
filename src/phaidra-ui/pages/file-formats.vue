<template>
    <div>
      <h1 class="d-sr-only">{{$t('File Formats')}}</h1>
      <ExtFileFormats></ExtFileFormats>
    </div>
  </template>
    
    <script>
    import { config, useTranslatedPageHead } from "../mixins/config";
    
    export default {
      mixins: [config],
      setup() {
        useTranslatedPageHead('File Formats', 'meta_description_file_formats')
      }
    }
    </script>
    