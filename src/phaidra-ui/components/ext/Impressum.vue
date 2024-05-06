<template>
  <div v-if="instanceconfig.cms_impressum">
    <runtimetemplate :template="instanceconfig.cms_impressum" />
  </div>
  <div v-else class="ma-6">
      <p>Impressum...</p>
  </div>
</template>

<script>
import { config } from "@/mixins/config";

export default {
  name: 'impressum',
  mixins: [config]
}
</script>
