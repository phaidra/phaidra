<template>
<client-only>
  <div>
    <h1 class="d-sr-only">{{$t('Search')}}</h1>
    <p-search></p-search>
  </div>
</client-only>
</template>
<script>

import { config } from "../mixins/config";

export default {
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.$t('Search') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
  },
}
</script>
