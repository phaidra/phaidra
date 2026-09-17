<template>
  <div>
    <h1 class="d-sr-only">{{$t('Code of Ethics')}}</h1>
    <ExtCodeOfEthics></ExtCodeOfEthics>
  </div>
</template>
  
  <script>
  import { config, useTranslatedPageHead } from "../mixins/config";
  
  export default {
    mixins: [config],
    setup() {
      useTranslatedPageHead('Code of Ethics', 'meta_description_code_of_ethics')
    }
  }
  </script>
  