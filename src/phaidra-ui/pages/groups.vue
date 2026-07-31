<template>
<client-only>
  <div>
    <h1 class="d-sr-only">{{$t('Groups')}}</h1>
    <p-groups></p-groups>
  </div>
</client-only>
</template>
<script>
import { config } from "../mixins/config";
export default {
  middleware: "auth",
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.documentTitle(this.$t('Groups')),
    };
    return metaInfo;
  }
}
</script>
