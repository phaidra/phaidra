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
      title: this.$t('Contact') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
  },
}
</script>
