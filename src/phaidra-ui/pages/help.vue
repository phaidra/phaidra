<template>
  <div>
    <h1 class="d-sr-only">{{$t('Help')}}</h1>
    <Help></Help>
  </div>
</template>
<script>
import { config, useTranslatedPageHead } from "../mixins/config";

export default {
  mixins: [config],
  setup() {
    useTranslatedPageHead('Help', 'meta_description_help')
  }
}
</script>