<template>
<Submit></Submit>
</template>
<script>
import { config } from "../../mixins/config";
import Submit from "../../components/Submit.vue";

export default {
  middleware: "auth",
  mixins: [config],
  metaInfo() {
    let metaInfo = {
      title: this.$t('Submit') + ' - ' + this.$t(this.instanceconfig.title) + ' - ' + this.$t(this.instanceconfig.institution),
    };
    return metaInfo;
  },
}
</script>