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
      metaInfo() {
        let metaInfo = {
          title: this.documentTitle(this.$t('File Formats')),
        };
        return metaInfo;
      },
    }
    </script>
    