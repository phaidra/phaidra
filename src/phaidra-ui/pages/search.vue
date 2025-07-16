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
  metaInfo() {
    let metaInfo = {
      title: this.$t('Search') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
  },
}
</script>
