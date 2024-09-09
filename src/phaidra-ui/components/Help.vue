<template>
    <div v-if="instanceconfig.cms_help">
      <runtimetemplate :template="instanceconfig.cms_help" />
    </div>
    <div v-else>
      <p-help></p-help>
    </div>
  </template>
  
  <script>
  import { config } from "../mixins/config";
  
  export default {
    mixins: [ config ]
  }
  </script>
  