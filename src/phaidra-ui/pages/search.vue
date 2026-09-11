<template>
<client-only>
  <div>
    <h1 class="d-sr-only">{{$t('Search')}}</h1>
    <p-search :signedin="signedin"></p-search>
  </div>
</client-only>
</template>
<script>

import { config, useTranslatedPageHead } from "../mixins/config";
import { context } from "../mixins/context";

export default {
  mixins: [config, context],
  setup() {
    useTranslatedPageHead('Search', 'meta_description_search')
  }
}
</script>
