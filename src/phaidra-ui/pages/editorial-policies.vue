<template>
  <div>
    <h1 class="d-sr-only">{{$t('Editorial Policies')}}</h1>
    <ExtEditorialPolicies></ExtEditorialPolicies>
  </div>
</template>
  
  <script>
  import { config } from "../mixins/config";
  
  export default {
    mixins: [config],
    metaInfo() {
      let metaInfo = {
        title: this.$t('Editorial Policies') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
      };
      return metaInfo;
    },
  }
  </script>
  