<template>
  <div v-if="content">
    <runtimetemplate :template="content" />
  </div>
  <div v-else class="ma-6">
      <p>Impressum...</p>
  </div>
</template>

<script>
export default {
  name: 'impressum',
  data() {
    return {
      content:''
    };
  },
  async fetch() {
    let settingResponse = await this.$axios.get("/app_settings")
    if (settingResponse?.data?.settings?.instanceConfig?.cms_impressum) {
      this.content = settingResponse?.data?.settings?.instanceConfig?.cms_impressum
    }
  }
}
</script>
