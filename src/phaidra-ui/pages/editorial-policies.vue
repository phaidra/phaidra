<template>
  <div>
    <h1 class="d-sr-only">{{$t('Editorial Policies')}}</h1>
    <ExtEditorialPolicies></ExtEditorialPolicies>
  </div>
</template>
  
  <script>
    import { config, useTranslatedPageHead } from "../mixins/config";
  
  export default {
    mixins: [config],
    setup() {
      useTranslatedPageHead('Editorial Policies', 'meta_description_editorial_policies')
    }
  }
  </script>
  