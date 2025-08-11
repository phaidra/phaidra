<template>
    <ExtEditorialPolicies></ExtEditorialPolicies>
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
  