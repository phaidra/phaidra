<template>
<client-only>
  <div>
    <h1 class="d-sr-only">{{$t('Search')}}</h1>
    <p-search :signedin="signedin"></p-search>
  </div>
</client-only>
</template>
<script>

import { config } from "../mixins/config";
import { context } from "../mixins/context";

export default {
  mixins: [config, context],
  setup() {
    const nuxtApp = useNuxtApp()
    useHead(() => {
      const t = nuxtApp.$i18n?.t || ((v) => v)
      return {
        title: this.documentTitle(t('Search'))
      }
    })
  }
}
</script>
