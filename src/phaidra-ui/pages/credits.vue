<template>
  <div>
    <h1 class="d-sr-only">{{$t('Credits')}}</h1>
    <Credits></Credits>
  </div>
</template>

<script>
import { config, useTranslatedPageHead } from "../mixins/config";

export default {
  mixins: [config],
  setup() {
    useTranslatedPageHead('Credits', 'meta_description_credits')
  }
}
</script>
