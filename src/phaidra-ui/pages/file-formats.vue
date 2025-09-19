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
          title: this.$t('File Formats') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
        };
        return metaInfo;
      },
    }
    </script>
    