<template>
  <div v-if="instanceconfig.cms_editorial_policies">
    <runtimetemplate :template="instanceconfig.cms_editorial_policies" />
  </div>
  <div v-else class="ma-6">
      <p>Editorial Policies...</p>
  </div>
</template>

<script>
import { config } from "@/mixins/config";

export default {
  name: 'editorial-policies',
  mixins: [config]
}
</script>
