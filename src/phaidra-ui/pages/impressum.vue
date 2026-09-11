<template>
  <div>
    <h1 class="d-sr-only">{{$t('Impressum')}}</h1>
    <ExtImpressum></ExtImpressum>
  </div>
</template>

<script>
import { config, useTranslatedPageHead } from "../mixins/config";

export default {
  mixins: [config],
  setup() {
    useTranslatedPageHead('Impressum', 'meta_description_impressum')
  }
}
</script>
