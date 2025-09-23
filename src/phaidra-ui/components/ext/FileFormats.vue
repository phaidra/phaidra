<template>
  <div v-if="instanceconfig.cms_file_formats">
    <runtimetemplate :template="instanceconfig.cms_file_formats" />
  </div>
  <div v-else class="ma-6">
      <p>File Formats...</p>
  </div>
</template>

<script>
import { config } from "@/mixins/config";

export default {
  name: 'file-formats',
  mixins: [config]
}
</script>
