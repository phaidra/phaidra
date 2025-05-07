<template>
  <div>
    <h1 class="d-sr-only">{{$t('Credits')}}</h1>
    <Credits></Credits>
  </div>
</template>

<script>
import { config } from "../mixins/config";

export default {
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.$t('Credits') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
  },
}
</script>
