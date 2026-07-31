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
      title: this.documentTitle(this.$t('Manage object lists')),
    };
    return metaInfo;
  },
}
</script>
