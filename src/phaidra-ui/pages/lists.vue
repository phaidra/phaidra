<template>
<client-only>
  <p-lists></p-lists>
</client-only>
</template>
<script>
import { config } from "../mixins/config";
export default {
  middleware: "auth",
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.$t('Manage object lists') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
  },
}
</script>
