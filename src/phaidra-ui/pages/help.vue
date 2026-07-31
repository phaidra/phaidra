<template>
  <div>
    <h1 class="d-sr-only">{{$t('Help')}}</h1>
    <Help></Help>
  </div>
</template>
<script>
import { config } from "../mixins/config";

export default {
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.documentTitle(this.$t('Help')),
    };
    return metaInfo;
  },
}
</script>