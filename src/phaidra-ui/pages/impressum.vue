<template>
  <div>
    <h1 class="d-sr-only">{{$t('Impressum')}}</h1>
    <ExtImpressum></ExtImpressum>
  </div>
</template>

<script>
import { config } from "../mixins/config";

export default {
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.documentTitle(this.$t('Impressum')),
    };
    return metaInfo;
  },
}
</script>
