<template>
  <div>
    <h1 class="d-sr-only">{{$t('Contact')}}</h1>
    <ExtContact></ExtContact>
  </div>
</template>

<script>
import { config } from "../mixins/config";

export default {
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.documentTitle(this.$t('Contact')),
    };
    return metaInfo;
  },
}
</script>
