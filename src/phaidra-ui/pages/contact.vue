<template>
  <div>
    <h1 class="d-sr-only">{{$t('Contact')}}</h1>
    <ExtContact></ExtContact>
  </div>
</template>

<script>
import { config, useTranslatedPageHead } from "../mixins/config";

export default {
  mixins: [config],
  setup() {
    useTranslatedPageHead('Contact', 'meta_description_contact')
  }
}
</script>
