<template>
  <div>
    <h1 class="d-sr-only">{{$t('Code of Ethics')}}</h1>
    <ExtCodeOfEthics></ExtCodeOfEthics>
  </div>
</template>
  
  <script>
  import { config } from "../mixins/config";
  
  export default {
    mixins: [config],
    metaInfo() {
      let metaInfo = {
        title: this.$t('Code of Ethics') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
      };
      return metaInfo;
    },
  }
  </script>
  