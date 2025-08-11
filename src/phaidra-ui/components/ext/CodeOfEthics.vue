<template>
  <div v-if="instanceconfig.cms_code_of_ethics">
    <runtimetemplate :template="instanceconfig.cms_code_of_ethics" />
  </div>
  <div v-else class="ma-6">
      <p>Code of Ethics...</p>
  </div>
</template>

<script>
import { config } from "@/mixins/config";

export default {
  name: 'code-of-ethics',
  mixins: [config]
}
</script>
