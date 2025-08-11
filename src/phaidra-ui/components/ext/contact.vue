<template>
  <div v-if="instanceconfig.cms_contact">
    <runtimetemplate :template="instanceconfig.cms_contact" />
  </div>
  <div v-else class="ma-6">
      <p>Contact...</p>
  </div>
</template>

<script>
import { config } from "@/mixins/config";

export default {
  name: 'contact',
  mixins: [config]
}
</script>
